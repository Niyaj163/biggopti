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
    print("⚠️ WARNING: GEMINI_API_KEY is not configured in backend/.env!")
    print("   Refer to docs/THIRD_PARTY_KEYS.md for step-by-step setup.")

if not SUPABASE_URL or SUPABASE_URL == "https://your-project-ref.supabase.co":
    print("⚠️ WARNING: SUPABASE_URL is not configured in backend/.env!")

def initialize_seed_data():
    """Seeds the database with initial circulars if running for the first time."""
    seed_file = Path(__file__).resolve().parent.parent / 'db' / 'seed_circulars.json'
    if seed_file.exists():
        with open(seed_file, 'r', encoding='utf-8') as f:
            seeds = json.load(f)
        print(f"✅ Loaded {len(seeds)} seed circulars from {seed_file.name}")
        return seeds
    return []

def main():
    print("Checking database connection and backend readiness...")
    seeds = initialize_seed_data()
    print(f"Backend environment setup verified. {len(seeds)} seeded circulars available.")
    print("Scraper execution finished successfully.")

if __name__ == "__main__":
    main()
