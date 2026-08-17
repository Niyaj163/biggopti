# Biggopti - Third-Party Keys & Environment Setup Guide

This document lists **every external API key, URL, and credential** required by Biggopti. 

Whenever a backend file requires a secret or URL, it will read from the `.env` file (locally or on cPanel). Follow this guide to acquire and set up each key step-by-step.

---

## Summary Checklist of Required Keys & URLs

| Key / Variable Name | Service | Purpose | Where to Get | Required For |
|---|---|---|---|---|
| `GEMINI_API_KEY` | Google AI Studio | AI PDF digestion into structured Bangla JSON | [Google AI Studio](https://aistudio.google.com/app/apikey) (Free) | Backend Scraper |
| `SUPABASE_URL` | Supabase | PostgreSQL REST API Endpoint | [Supabase Console](https://supabase.com) Project Settings -> API | Backend + Flutter App |
| `SUPABASE_ANON_KEY` | Supabase | Client API Key for read/write | Supabase Project Settings -> API | Backend + Flutter App |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase | Admin key for scraper bulk writes | Supabase Project Settings -> API | Backend Scraper |
| `BDAPPS_APP_ID` | BDapps Portal | Telco SMS & CaaS identification | [BDapps Developer Portal](https://bdapps.com) | BDapps Integration |
| `BDAPPS_APP_PASSWORD` | BDapps Portal | Telco API authentication secret | BDapps Developer Portal | BDapps Integration |
| `ADMIN_PIN` | Custom | Security PIN to access Admin Dashboard | You decide (e.g. `123456`) | Flutter Admin Screen |

---

## Step-by-Step Instructions

### 1. Google Gemini API Key (`GEMINI_API_KEY`)
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Sign in with your Google account.
3. Click **"Get API key"** -> **"Create API key in new project"**.
4. Copy the generated key (starts with `AIzaSy...`).
5. Paste it in your `.env` file as:
   ```env
   GEMINI_API_KEY=AIzaSyYourActualKeyHere
   ```

---

### 2. Supabase Credentials (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`)
1. Go to [Supabase](https://supabase.com) and create a free account.
2. Click **"New Project"**, name it `biggopti-db`, set a database password, and choose region (e.g. `Singapore`).
3. Once created, go to **Project Settings** (gear icon on bottom left) -> **API**.
4. You will see:
   - **Project URL**: Copy this (e.g. `https://xyzcompany.supabase.co`). This is your `SUPABASE_URL`.
   - **Project API keys -> `anon` `public`**: Copy this long string. This is your `SUPABASE_ANON_KEY`.
   - **Project API keys -> `service_role` `secret`**: Copy this long string. This is your `SUPABASE_SERVICE_ROLE_KEY`.
5. Paste them into `.env`:
   ```env
   SUPABASE_URL=https://xyzcompany.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

---

### 3. BDapps API Credentials & cPanel Gateway

> Note: For initial development and demo, `BdappsServiceMock` uses canned responses so you don't need real credentials right away!

When deploying live to BDapps using cPanel gateway (based on your reference implementation):
1. **cPanel Base Gateway URL**: Your PHP gateway folder URL (e.g. `https://your-domain.com/NADB26121` or `https://your-domain.com/bdapps_gateway`).
2. **BDapps Developer Portal Credentials**:
   - `BDAPPS_APP_ID` (e.g. `APP_139347`)
   - `BDAPPS_APP_PASSWORD` (e.g. `2dd1a269dae6c481e11aadd988037e4d`)
3. **cPanel Gateway Files**:
   - `check_subscription.php`: Receives `user_mobile`, calls BDapps API, returns status (`REGISTERED` / `UNREGISTERED`).
   - `send_otp.php`: Receives `user_mobile`, requests OTP, returns `referenceNo`.
   - `verify_otp.php`: Receives `Otp` & `referenceNo`, activates subscription (`S1000`).
   - `unsubscribe.php`: Receives `user_mobile`, unsubscribes user (`UNREGISTERED`).
4. **Mandatory Compliance Rule**: When a user unsubscribes, the app must immediately log them out.


---

### 4. Setting Up on cPanel

When hosting the backend on cPanel:
1. Upload the `backend/` folder to your cPanel directory (e.g., `/home/username/biggopti_backend`).
2. Create a `.env` file in `/home/username/biggopti_backend/.env` containing all the key-value pairs above.
3. In cPanel **Cron Jobs**, set up a command to run every 12 hours:
   ```bash
   /usr/bin/python3 /home/username/biggopti_backend/main.py >> /home/username/biggopti_backend/cron.log 2>&1
   ```

---

### 5. Keeping Keys Safe
* Never push `.env` to GitHub. It is listed in `.gitignore`.
* Use `.env.example` as a template when setting up new environments.
