import os
import json
import sys
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client, Client

from ai_parser import AIParser
from scrapers import BPSCScraper, BangladeshBankScraper

# Load environment variables
env_path = Path(__file__).resolve().parent / '.env'
load_dotenv(dotenv_path=env_path)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

print("==================================================")
print("Biggopti Scraper & AI Digest Engine Starting...")
print("==================================================")

def get_supabase_client() -> Client | None:
    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY and "your-project-ref" not in SUPABASE_URL:
        try:
            return create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        except Exception as e:
            print(f"[WARNING] Supabase connection error: {e}")
    return None

def initialize_seed_data(supabase: Client | None):
    """Seeds the database with 20 demo circulars if running for the first time."""
    seed_file = Path(__file__).resolve().parent.parent / 'db' / 'seed_circulars.json'
    if not seed_file.exists():
        return []

    with open(seed_file, 'r', encoding='utf-8') as f:
        seeds = json.load(f)

    if supabase:
        try:
            res = supabase.table('circulars').select('id', count='exact').execute()
            count = res.count if res.count is not None else len(res.data)
            print(f"[DB] Current circular count in Supabase: {count}")
            if count == 0:
                print("[DB] Seeding 20 demo circulars into Supabase...")
                supabase.table('circulars').insert(seeds).execute()
                print("[OK] Successfully seeded 20 circulars into Supabase!")
        except Exception as e:
            print(f"[NOTE] Supabase table query notice: {e}")
    return seeds

def log_scraper_run(supabase: Client | None, source_url: str, pdf_hash: str, status: str, error_msg: str = ""):
    """Logs scraper runs into Supabase scraper_logs table for admin dashboard."""
    if not supabase:
        return
    try:
        supabase.table('scraper_logs').insert({
            'source_url': source_url,
            'pdf_hash': pdf_hash,
            'status': status,
            'error_message': error_msg,
        }).execute()
    except Exception as e:
        print(f"[LOG] Scraper logging notice: {e}")

def run_scrapers():
    """Runs all scrapers, processes new PDFs with Gemini Flash, and stores in Supabase."""
    supabase = get_supabase_client()
    initialize_seed_data(supabase)

    if not GEMINI_API_KEY or GEMINI_API_KEY == "your_gemini_api_key_here":
        print("[SKIP] Gemini API Key missing. Skipping live scraping & AI parsing.")
        return

    ai_parser = AIParser(api_key=GEMINI_API_KEY)
    scrapers = [BPSCScraper(), BangladeshBankScraper()]

    for scraper in scrapers:
        print(f"\n[SCRAPE] Starting scraper: {scraper.name} ({scraper.source_url})...")
        notices = scraper.scrape_notices()
        print(f"[SCRAPE] Found {len(notices)} potential notice links from {scraper.name}.")

        for notice in notices:
            pdf_url = notice['pdf_url']
            print(f"[FETCH] Checking PDF: {pdf_url}")
            pdf_bytes = scraper.fetch_pdf_bytes(pdf_url)
            
            if not pdf_bytes:
                log_scraper_run(supabase, pdf_url, "", "FAILED", "Failed to download PDF bytes")
                continue

            pdf_hash = scraper.compute_hash(pdf_bytes)

            # Deduplication check in Supabase
            if supabase:
                try:
                    res = supabase.table('circulars').select('id').eq('pdf_hash', pdf_hash).execute()
                    if res.data and len(res.data) > 0:
                        print(f"[SKIP] PDF hash {pdf_hash[:10]} already exists in DB. Skipping.")
                        continue
                except Exception as e:
                    print(f"[DB] Deduplication check note: {e}")

            # AI Digest Parsing
            print(f"[AI] Sending PDF to Gemini 2.5 Flash for Bangla digestion...")
            digested_circular = ai_parser.parse_circular(pdf_bytes, pdf_url, pdf_hash)

            if digested_circular:
                print(f"[OK] Digest Created: {digested_circular.get('title')}")
                if supabase:
                    try:
                        supabase.table('circulars').insert(digested_circular).execute()
                        print("[DB] Digested circular inserted into Supabase!")
                        log_scraper_run(supabase, pdf_url, pdf_hash, "SUCCESS")
                    except Exception as e:
                        print(f"[DB] Insert error: {e}")
                        log_scraper_run(supabase, pdf_url, pdf_hash, "FAILED", str(e))
            else:
                print(f"[WARNING] AI parsing returned null for {pdf_url}")
                log_scraper_run(supabase, pdf_url, pdf_hash, "FAILED", "AI parsing returned null")

def main():
    print("Executing Biggopti live scraper & AI pipeline...")
    run_scrapers()
    print("\n==================================================")
    print("Pipeline Execution Completed Successfully.")
    print("==================================================")

if __name__ == "__main__":
    main()
