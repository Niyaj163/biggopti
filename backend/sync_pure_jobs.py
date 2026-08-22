import os
import json
import sys
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client

if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
        sys.stderr.reconfigure(encoding='utf-8', errors='replace')
    except Exception:
        pass

env_path = Path(__file__).resolve().parent / '.env'
load_dotenv(dotenv_path=env_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

# 1. Purge all non-job / exam routine rows from Supabase
print("[CLEAN] Purging exam routines, viva candidate lists, debate festivals, and old seeds...")
try:
    res = supabase.table('circulars').select('id, title, summary_bullets').execute()
    data = res.data or []
    deleted_count = 0

    for item in data:
        cid = item['id']
        title = item.get('title', '')
        bullets = item.get('summary_bullets') or []
        bullets_str = " ".join([str(b) for b in bullets])

        # Delete any non-recruitment or routine/exam notices
        is_non_job = (
            'সময়সূচি' in title or
            'রুটিন' in title or
            'ভর্তি পরীক্ষা' in title or
            'বিতর্ক উৎসব' in title or
            'মৌখিক পরীক্ষা ও তথ্যাদি' in title or
            'কাগজপত্র জমাদান' in title or
            'ফলাফল প্রকাশ' in title or
            'জীবনবৃত্তান্ত' in title or
            'CV' in title or
            'পিডিএফ কন্টেন্ট বিস্তারিত' in bullets_str
        )

        if is_non_job:
            print(f"  -> Deleting non-job: {title}")
            supabase.table('circulars').delete().eq('id', cid).execute()
            deleted_count += 1

    print(f"[OK] Cleaned {deleted_count} non-job items from Supabase.")
except Exception as e:
    print(f"[ERROR] Clean error: {e}")

# 2. Insert the 20 pure Job Recruitment seed circulars
seed_file = Path(__file__).resolve().parent.parent / 'db' / 'seed_circulars.json'
with open(seed_file, 'r', encoding='utf-8') as f:
    seeds = json.load(f)

print(f"[SEED] Ensuring all {len(seeds)} pure job recruitment circulars are present in Supabase...")
inserted = 0
for seed in seeds:
    try:
        # Check if already present by hash
        check = supabase.table('circulars').select('id').eq('pdf_hash', seed['pdf_hash']).execute()
        if not check.data or len(check.data) == 0:
            supabase.table('circulars').insert(seed).execute()
            inserted += 1
    except Exception as e:
        print(f"  -> Insert note: {e}")

print(f"[OK] Successfully populated {inserted} fresh Job Recruitment circulars into Supabase!")
