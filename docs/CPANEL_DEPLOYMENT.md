# Biggopti - cPanel Backend & Cron Job Deployment Guide

This guide walks you through deploying the **Biggopti Backend Scraper Pipeline** and **BDapps PHP Gateway** to your cPanel hosting server.

---

## 📁 1. Files to Upload to cPanel

Zip and upload the following folders from `biggopti/` to your cPanel File Manager (e.g. `/home/username/biggopti/`):

```text
biggopti/
├── backend/
│   ├── scrapers/
│   ├── prompts/
│   ├── main.py
│   ├── ai_parser.py
│   ├── requirements.txt
│   ├── cpanel_cron.sh
│   └── .env                   <- Your private secrets file
└── db/
    └── seed_circulars.json
```

---

## 🔑 2. Environment Variables Configuration (`.env`)

Create or upload your `.env` file inside `/home/username/biggopti/backend/.env`:

```env
GEMINI_API_KEY=your_gemini_api_key_here
SUPABASE_URL=https://mpdpjezvzgwfxgqayilz.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
BDAPPS_APP_ID=APP_000123
BDAPPS_APP_PASSWORD=your_bdapps_secret
ADMIN_PIN=123456
```

---

## 🐍 3. Setup Python App or Virtual Environment on cPanel

1. Log into your cPanel dashboard.
2. Under **Software**, click **"Setup Python App"** (or use SSH).
3. Create App:
   - **Python Version**: `3.10` or `3.11`
   - **App Directory**: `biggopti/backend`
   - **App Domain/URI**: `backend`
4. Run pip install inside cPanel terminal:
   ```bash
   pip install -r /home/username/biggopti/backend/requirements.txt
   ```

---

## ⏰ 4. Setting Up cPanel Cron Job

To run the automated scraper every 12 hours:

1. In cPanel, search for **"Cron Jobs"**.
2. Under **Add New Cron Job**:
   - **Common Settings**: `Twice a day (0 0,12 * * *)`
   - **Command**:
     ```bash
     /usr/bin/bash /home/username/biggopti/backend/cpanel_cron.sh
     ```
3. Click **Add New Cron Job**.

The scraper will now automatically check government and bank portals twice daily, parse new PDFs with Gemini 2.5 Flash, insert structured Bangla JSON into Supabase, and write log entries to `cron.log`!
