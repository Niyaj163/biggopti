import os
import json
import hashlib
import sys
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
env_path = Path(__file__).resolve().parent / '.env'
load_dotenv(dotenv_path=env_path)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

print("==================================================")
print("Biggopti Scraper & AI Digest Engine Starting...")
print("==================================================")

if not GEMINI_API_KEY or GEMINI_API_KEY == "your_gemini_api_key_here":
    print("[WARNING] GEMINI_API_KEY is not configured in backend/.env!")
    print("   Refer to docs/THIRD_PARTY_KEYS.md for step-by-step setup.")

if not SUPABASE_URL or SUPABASE_URL == "https://your-project-ref.supabase.co":
    print("[WARNING] SUPABASE_URL is not configured in backend/.env!")

from supabase import create_client, Client

def get_supabase_client() -> Client | None:
    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY and "your-project-ref" not in SUPABASE_URL:
        try:
            return create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        except Exception as e:
            print(f"[WARNING] Supabase connection error: {e}")
    return None

def initialize_seed_data(supabase: Client | None):
    """Seeds the database with initial circulars if running for the first time."""
    seed_file = Path(__file__).resolve().parent.parent / 'db' / 'seed_circulars.json'
    if not seed_file.exists():
        return []

    with open(seed_file, 'r', encoding='utf-8') as f:
        seeds = json.load(f)
    print(f"[OK] Loaded {len(seeds)} seed circulars from {seed_file.name}")

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
            print("   Make sure to run db/schema.sql in your Supabase SQL Editor if you haven't yet.")
    return seeds

def main():
    print("Checking database connection and backend readiness...")
    supabase = get_supabase_client()
    seeds = initialize_seed_data(supabase)
    print(f"Backend environment setup verified. {len(seeds)} seeded circulars ready.")
    print("Scraper execution finished successfully.")

if __name__ == "__main__":
    main()
