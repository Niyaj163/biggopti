# Biggopti - Project Planning Blueprint

> Status: Planning Phase (no code yet)
> Author: You + Claude
> Last updated: 14 August 2026
> Window: ~10 days (compressed from original 20-day plan)
> Goal: Win the BDapps (National Android Development Bootcamp) competition by shipping a polished, AI-powered, Bangla-first notice digest app.

Note on encoding: this planning document is written in pure ASCII to keep Windows PowerShell reading it cleanly. The Bangla copy strings (onboarding headlines, button labels, etc.) will live in `lib/l10n/app_bn.arb` later, not here.

---

## 1. One-Line Pitch

Biggopti is the "AI newsboy" for Bangladesh - it reads every new government job, bank, and university circular, boils it down into a 30-second Bangla summary, and pushes it straight to your phone (even offline via BDapps SMS).

---

## 2. Problem Statement

| Pain | Evidence |
|------|----------|
| Bangladeshi job circulars are 10-page Bangla PDFs with dense administrative language. | BPSC, National University, Ministry sites, BCS prep portals. |
| Students waste hours daily scrolling Facebook groups and messy portals. | Existing apps (Bdjobs, Govt Job BD) just dump raw PDFs. |
| Existing aggregator apps fail without 4G/Wi-Fi - push notifications never arrive. | No telco-integrated digest service exists. |
| Even when found, users must manually extract age, deadline, eligibility. | No AI digest layer in any existing BD job app. |
| Rural / lower-bandwidth users (the majority audience) are locked out. | No SMS fallback in competitors. |

---

## 3. Target Users and Personas

### Persona A - "BCS Rahim" (Primary)
- Age: 22-28
- Location: Dhaka, Rajshahi, Chattogram, Sylhet, district towns
- Goal: Crack BCS / Bank / Govt job within 12 months
- Pain: Tracks 5+ Facebook groups daily; misses deadlines; reads PDFs slowly
- Willingness to pay: 3 BDT/day ~= 90 BDT/month. YES, if it saves 30 min/day.

### Persona B - "Versity Priya" (Secondary)
- Age: 19-24
- Location: National University / private university students
- Goal: Track admission test dates, scholarship notices, exam reschedules
- Willingness to pay: 3 BDT/day. YES, but seasonal (drops after admissions close).

### Persona C - "Mess Bablu" (Tertiary, word-of-mouth)
- Age: 21-25
- Role: Bachelor / mess-manager who forwards notices to friends
- Behaviors: Uses app, then screenshots and shares in WhatsApp groups - free viral marketing.

---

## 4. Value Proposition

Stop scrolling 10 Facebook groups. Biggopti watches every official notice for you, gives you a 30-second Bangla summary, and texts you the deadline - even when your data is off.

Three things no competitor does together:
1. AI-digested (not raw PDF dumps).
2. SMS fallback via BDapps (works offline).
3. Bangla-first UI (Hind Siliguri fonts, native rendering).

---

## 5. Business Model

| Layer | Detail |
|-------|--------|
| Pricing | 3 BDT/day subscription via BDapps carrier billing (CaaS). |
| Billing | Direct airtime deduction (Robi / Airtel / Banglalink / Grameenphone / Teletalk). |
| Revenue split | Negotiated with BDapps (typical 50/50 or 60/40 in dev's favor after an initial period - confirm in BDapps portal). |
| Free tier | Last 7 circulars visible without subscription; subscription unlocks full archive + SMS alerts. |
| LTV math | 3 BDT x 30 days x 60% retention = ~54 BDT per subscriber/month. |

Revenue ceiling check (rough): 1,000 active subs x 90 BDT/month = ~90,000 BDT/month gross. Modest, but the competition is judged on innovation and execution, not revenue.

---

## 6. Market and Competitor Analysis

| App | Strengths | Gaps Biggopti Exploits |
|-----|-----------|-------------------------|
| Bdjobs | Corporate/private job leader | No govt/varsity focus, no SMS fallback, no AI digest. |
| Govt Job BD / JobAlert BD | Aggregates notices | Dumps raw PDFs, no AI parsing, no offline SMS. |
| Live MCQ / Shikho / 10 Minute School | Exam prep | Static question banks, not real-time notice tracker. |
| My DPDC / DESCO / BREB | Bill payment | Reactive, no proactive SMS. |
| Bijli Pulse (if it exists) | Community reports | Crowdsourced, not official. |

Judge defense: "Apps exist that aggregate notices or pay utility bills. Biggopti is the only one that combines AI PDF digestion with BDapps SMS delivery so the answer reaches the user even when their data is off."

---

## 7. Product Scope (Full Build, 20-day Window)

All items below are in scope. No feature is "stretch" - we have time to do them all properly.

### 7.1 Core features (MVP spine)
1. Onboarding flow + BDapps subscription activation.
2. Home feed of latest circulars (cards: org, deadline, age, eligibility, 3-bullet Bangla summary).
3. Filter by category (Govt / Bank / Varsity).
4. Circular detail screen with "Open Original PDF" button.
5. BDapps SMS trigger demo (simulated live in pitch).
6. Bangla-first UI with custom fonts.
7. 20 seeded circulars (hybrid cutoff - auto-hide once scraper has 20+ rows and oldest scraped is >3 days old).
8. Personalized eligibility check ("Are YOU eligible?").
9. Save / bookmark circulars.
10. Push notifications via Firebase (topic-based).

### 7.2 Full feature set (built in days 7-8)
| # | Feature | Why build it | Est. time |
|---|---------|--------------|-----------|
| 1 | Multi-language (English toggle) | Wider audience; private-university students prefer English. | ~4-6 hours |
| 2 | Admin dashboard (scraper logs + run-now + PIN login) | Proves engineering depth; only field-grade apps have this. | ~1.5 days |

This is a deliberate scope expansion. By day 8 you should have a full-feature app; days 9-10 are for polish, testing, demo, and documentation.

---

## 8. Core User Flows

### Flow 1 - First-time user
```
Splash -> Onboarding (3 Bangla explainer cards)
   -> Subscription paywall (BDapps CaaS)
       -> OTP / PIN confirmation (BDapps CaaS callback)
           -> Home feed (latest circulars)
```

### Flow 2 - Returning user
```
Splash -> Home feed (auto-loaded from Supabase)
   -> Filter chip tap (Govt / Bank / Varsity)
       -> Card tap -> Detail screen
           -> "Open PDF" external link
```

### Flow 3 - Eligibility check
```
Settings -> "Are YOU eligible?" tile
   -> Profile form (age, degree, quota, district)
       -> Match against parsed fields of every circular
           -> Show "Eligible" / "Not eligible" verdict per circular
```

### Flow 4 - Backend (every day at 8 AM BD time)
```
GitHub Actions cron fires
   -> Python scraper fetches new PDFs from source list
       -> pdfplumber extracts text
           -> Gemini 2.5 Flash returns structured JSON (Bangla)
               -> Insert into Supabase
                   -> If high-priority -> trigger BDapps SMS broadcast
                       -> Also push Firebase notification to topic subscribers
```

---

## 9. Information Architecture

| Screen | Purpose |
|--------|---------|
| Splash | Brand logo (Biggopti), fade-in animation. |
| Onboarding (3 pages) | 1. "Notice asleo pora jay na", 2. "AI pore dey 3 point-e", 3. "Data off thakleo SMS ashbe". |
| Subscription Paywall | "Matra 3 taka / din" headline, benefits list, "Subscribe" CTA -> BDapps CaaS. |
| Home Feed | Category chips at top, vertical list of circular cards (infinite scroll). |
| Circular Card | Org name (bold), title, deadline badge (color-coded: red <3d, orange <7d, green >7d), 3 bullet Bangla summary. |
| Circular Detail | Full summary, eligibility card, age card, "Open PDF" button, bookmark heart icon. |
| Eligibility | Profile form (age, degree, quota, district) + verdict list per circular. |
| Bookmarks | Vertical list of saved circulars (subset of home feed data). |
| Settings | About, language toggle, profile, admin login entry, contact, unsubscribe. |
| Admin Login | Hidden route; PIN-only access (env-set). |
| Admin Dashboard | Scraper logs table, recent runs chart, error count, "Run now" button. |

---

## 10. Design System

### Color Palette (Modern, Organic & Elegant)
| Token | Hex | Use |
|-------|-----|-----|
| primary | #0A4D3C (Deep Forest Green) | App bar, primary buttons, hero sections. |
| primaryDark | #062F25 (derived) | Status bar, top gradients. |
| secondary | #9EC5B2 (Sage Green / Soft Mint) | Secondary backgrounds, sage highlights. |
| accent | #FF8B8B (Coral Pink / Peach) | Coral CTAs, notification badges, live indicators. |
| accentLavender | #B1A7F2 (Soft Lavender / Periwinkle) | Gradient glows, badge backgrounds. |
| surface | #FFFFFF (Pure White) | Floating cards, input fields, popups. |
| bg | #F4F6F4 (Off-white / soft slate) | Scaffold background. |
| textPrimary | #1A2320 (Dark Typography) | Headlines, body text. |
| textSecondary | #5A6B63 (Muted / Body Text) | Subtitles, metadata. |
| success | #1B873F | Verified, eligible status (semantic). |
| warning | #FFB300 | Approaching deadline (semantic). |
| danger | #D0021B | Past deadline / ineligible (semantic). |

### Typography
- Headlines: Hind Siliguri Bold (24-32sp).
- Body: Hind Siliguri Regular (14-16sp).
- Bullet points: Hind Siliguri Medium (15sp).
- English fallback: Inter or system default.

### Iconography
- Material Icons (rounded). A few hand-drawn Bangla accent glyphs on category chips are an optional polish item.

### Layout Principles
- Bangla-first (LTR; mirror-aware if mixed RTL appears).
- Cards: 16dp corner radius, soft shadow.
- Tap targets: minimum 48dp.
- Min font size: 14sp for accessibility.

---

## 11. Technical Architecture

```
+--------------------------------------------------------------+
|                 DATA SOURCES (External)                      |
|  bpsc.gov.bd  /  national university  /  ministry portals    |
|  bank.org.bd  /  varsity.ac.bd  /  BCS prep portals          |
+----------------------------+---------------------------------+
                             |  (scraped 2x/day)
                             v
+--------------------------------------------------------------+
|   GitHub Actions Cron (free) - runs Python scraper           |
|   python main.py -> pdfplumber -> Gemini 2.5 Flash API       |
+----------------------------+---------------------------------+
                             |  (structured Bangla JSON)
                             v
+--------------------------------------------------------------+
|   Supabase PostgreSQL (free tier)                            |
|   Tables: circulars, subscribers, bookmarks, scraper_logs    |
+--------------+--------------------------+--------------------+
             |  (REST / realtime)        |  (webhook + topic)
             v                          v
+-------------------------+   +-------------------------------+
|   Flutter Mobile App    |   |   BDapps SMS Gateway          |
|   (Android + iOS)       |   |   (carrier-billed, offline)   |
|   Firebase FCM <-+      |   +-------------------------------+
+-------------------------+
        ^
        |  (topic push)
        |
+-------------------------+
|  Firebase FCM (free)    |
+-------------------------+
```

### Stack Summary
| Layer | Technology | Why |
|-------|------------|-----|
| Mobile | Flutter 3.x / Dart | Required by competition. |
| State | Riverpod 2.x | Cleaner than Provider, easier with AI assistance. |
| HTTP | Dio | Interceptors, retries. |
| Local cache | Hive or SharedPreferences | Offline last-known feed. |
| Fonts | google_fonts (Hind Siliguri) | Zero-config Bangla typography. |
| L10n | flutter intl + .arb | Bangla default + English toggle. |
| Push | firebase_messaging | FCM topic push from backend. |
| Backend | Python 3.11 | Standard for scraping + AI. |
| PDF parse | pdfplumber | Robust Bangla Unicode extraction. |
| AI | google-genai (Gemini 2.5 Flash) | Free tier, strong Bangla, JSON mode. |
| DB | Supabase (PostgreSQL) | Realtime, REST auto-gen, free tier. |
| Hosting / Cron | cPanel (Python App / cPanel Cron Job) or GitHub Actions | User hosting preference: cPanel server for backend execution. |
| Telco | BDapps CaaS + SMS API | Competition platform. |

Total infrastructure cost: 0 BDT / minimal cPanel host cost; revenue-share only when monetized through BDapps.

---

## 12. Scraper and Source Strategy

### Tier 1 - Start here (must scrape for MVP)
| Source | URL pattern | Type |
|--------|-------------|------|
| BPSC | bpsc.gov.bd notice page | Govt |
| Bangladesh Bank | bb.org.bd career section | Bank |
| National University | nu.ac.bd/notice | Varsity |
| Ministry of Public Administration | mopa.gov.bd | Govt |
| Sonali Bank | sonalibank.com.bd career page | Bank |
| Janata Bank | janatabankbd.com career page | Bank |
| Agrani Bank | agranibank.org career page | Bank |
| Rupali Bank | rupalibank.org career page | Bank |

### Tier 2 - Add if time allows
- BCS prep portals (BCS viva schedule, seat plans).
- Bank job portals (Sonali, Janata, Agrani, Rupali).
- Private university admission notices (BRAC, North South, IUB).

### Scraper approach
- Simple HTML scrape with requests + BeautifulSoup.
- Detect new PDF links (compare hash with scraper_logs.last_seen_hash).
- Download PDF -> pdfplumber -> Gemini -> insert.
- No Selenium needed for v1 (statics-first).
- Wrap every source in try/except and log failures to scraper_logs.

---

## 13. AI Prompt Strategy

### Master prompt (sent to Gemini 2.5 Flash)

The prompt file will live at `backend/prompts/parse_circular.txt`. It is UTF-8 encoded and contains the Bangla field names so the model emits a predictable JSON shape. We force JSON via `response_mime_type="application/json"`.

Key decisions:
- Output language: Bangla, even if the source PDF mixes English (we translate on the fly using the model).
- Hard schema: `org_name`, `title`, `category` (govt/bank/varsity/other), `deadline`, `age_limit`, `eligibility`, `summary_bullets` (array of 3 strings).
- Truncate input to ~4,000 characters; this is fast enough on Flash and still within free-tier limits.

### Robustness tactics
- Set `response_mime_type="application/json"` so we always parse cleanly.
- Truncate input to 4,000 chars (Gemini Flash can handle 1M, but cost/time scales).
- If parsing fails -> log to `scraper_logs.errors` and retry once.
- Cache parsed results by PDF URL hash to avoid duplicate API calls.

---

## 14. Database Schema (Supabase PostgreSQL)

```sql
-- circulars: AI-digested notices
CREATE TABLE circulars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    org_name VARCHAR(255) NOT NULL,
    category VARCHAR(50) CHECK (category IN ('govt','bank','varsity','other')),
    deadline VARCHAR(100),
    age_limit VARCHAR(100),
    eligibility TEXT,
    summary_bullets JSONB,
    original_pdf_url TEXT UNIQUE,
    pdf_hash VARCHAR(64),
    is_high_priority BOOLEAN DEFAULT FALSE,
    source VARCHAR(20) DEFAULT 'scraped' CHECK (source IN ('seed','scraped','manual')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for the hybrid-cutoff filter
CREATE INDEX idx_circulars_source_created ON circulars (source, created_at DESC);

-- subscribers: BDapps SMS push targets
CREATE TABLE subscribers (
    phone_number VARCHAR(15) PRIMARY KEY,
    subscription_status VARCHAR(20) DEFAULT 'ACTIVE',
    subscribed_at TIMESTAMPTZ DEFAULT NOW(),
    last_billed_at TIMESTAMPTZ
);

-- bookmarks: saved circulars per phone number
CREATE TABLE bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(15) REFERENCES subscribers(phone_number) ON DELETE CASCADE,
    circular_id UUID REFERENCES circulars(id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(phone_number, circular_id)
);

-- scraper_logs: health monitoring + dedupe
CREATE TABLE scraper_logs (
    id SERIAL PRIMARY KEY,
    source_url TEXT,
    pdf_hash VARCHAR(64),
    status VARCHAR(20),
    error_message TEXT,
    ran_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 15. BDapps Integration Plan (cPanel Gateway Architecture)

### 15.1 Core Architecture
Calls from Flutter are proxied through a **cPanel PHP gateway** (`https://<your-cpanel-domain>/bdapps_gateway/`) to secure `appId` and `appPassword`. Payloads are sent via `application/x-www-form-urlencoded`.

### 15.2 Gateway Endpoints & Flow
1. **Check Subscription Status**: `POST /check_subscription.php` (`user_mobile`)
   - `S1000` -> `REGISTERED`
   - `E1951` / null -> `UNREGISTERED`
2. **Request OTP**: `POST /send_otp.php` (`user_mobile`)
   - `S1000` -> Returns `referenceNo` for OTP verification.
   - `E1351` -> User already registered.
3. **Verify OTP**: `POST /verify_otp.php` (`Otp`, `referenceNo`)
   - `S1000` -> Activation successful (`REGISTERED`).
4. **Unsubscribe**: `POST /unsubscribe.php` (`user_mobile`)
   - `S1000` -> Unsubscribed (`UNREGISTERED`). Trigger automatic app logout callback.

### 15.3 BDapps Compliance Requirements
- **Pricing Copy**: Must explicitly state `2.78 BDT/day` (or `3.00 BDT/day` incl. VAT+SD+SC for Robi & Airtel users).
- **Mandatory Unsubscription Logout**: On unsubscription success, automatically clear session and log user out.

### 15.4 Build Strategy: Mock-First, Then Real Gateway
- `BdappsServiceMock`: Uses canned responses during local UI development.
- `BdappsServiceReal`: Calls cPanel PHP gateway (`BdAppsApi`) based on reference implementation.
- Toggled via `useMock` in `app_config.dart`.

---

## 16. Flutter Folder Structure (final)

```
lib/
|-- main.dart
|-- core/
|   |-- constants/
|   |   |-- app_colors.dart
|   |   `-- api_constants.dart
|   |-- services/
|   |   |-- supabase_service.dart
|   |   |-- bdapps_service.dart
|   |   |-- firebase_service.dart
|   |   `-- localization_service.dart
|   `-- theme/
|       `-- app_theme.dart
|-- models/
|   |-- circular_model.dart
|   |-- bookmark_model.dart
|   `-- user_profile.dart
|-- providers/
|   |-- circular_provider.dart
|   |-- subscription_provider.dart
|   |-- bookmark_provider.dart
|   |-- profile_provider.dart
|   `-- locale_provider.dart
`-- views/
    |-- onboarding/
    |-- paywall/
    |-- home/
    |   |-- home_screen.dart
    |   `-- widgets/
    |       |-- category_chip.dart
    |       `-- circular_card.dart
    |-- detail/
    |   `-- circular_detail_screen.dart
    |-- eligibility/
    |   |-- eligibility_screen.dart
    |   `-- widgets/
    |       `-- profile_form.dart
    |-- bookmarks/
    |   `-- bookmarks_screen.dart
    |-- admin/
    |   |-- admin_login_screen.dart
    |   |-- admin_dashboard_screen.dart
    |   `-- widgets/
    |       |-- scraper_log_table.dart
    |       `-- run_now_button.dart
    `-- settings/
        `-- settings_screen.dart

lib/l10n/
|-- app_bn.arb
`-- app_en.arb
```

---

## 17. Development Phases and Timeline (10 days, compressed)

> Treat this as a product build, not a hackathon. Every day has a concrete deliverable. Days 9-10 are reserved for polish, testing, and demo prep - do not let feature creep eat the buffer. Solo build, so daily cadence is tighter.

### Phase overview

| Phase | Days | Focus | Deliverables |
|-------|------|-------|--------------|
| P0 - Setup lock | 1 | Read-only + setup | planning.md signed off, source list finalized, GitHub repo created, Supabase project + Flutter SDK + Python venv ready. |
| P1 - Data layer | 2 | Backend | Supabase schema (4 tables + `source` column on circulars), 20 demo circulars seeded. |
| P2 - Backend pipeline | 3-4 | Backend | Python scraper, Gemini prompt v1 + JSON parsing, GitHub Actions cron, scraper_logs, error retries, BDapps SMS trigger (mock). |
| P3 - Flutter foundation | 5 | Flutter | `flutter create biggopti`, theme + custom palette, Hind Siliguri fonts, Riverpod setup, routing, models, Supabase client. |
| P4 - Flutter core screens | 6-7 | Flutter | Onboarding, paywall, home feed, detail, category filter, eligibility check, bookmarks, BDapps mock service wired. |
| P5 - Push + admin | 8 | Flutter | Firebase FCM topic push, admin dashboard (scraper logs + run-now + PIN login), English/Bangla toggle, swap BDapps mock -> real. |
| P6 - Polish and QA | 9 | Testing | Loading/empty/error states, animations, accessibility, low-end Android test, bug fixes. |
| P7 - Demo and submission | 10 | Docs + Pitch | README, architecture diagram, API docs, GitHub Actions secrets, demo script, 3-min pitch practice, 3 demo recordings. |

### Daily cadence (solo, 10-day crunch)
- Morning (3-4 hrs): implement today's deliverable.
- Afternoon (3-4 hrs): test on real device + write commit message.
- Evening (1 hr): update this doc with progress, blockers, learnings.
- End of every phase: stop and verify all deliverables before moving on.

### Risks during the timeline
- Day 4 is the first risk checkpoint - if Gemini returns garbage JSON, pause and tune the prompt. Don't push forward with a broken AI layer.
- Day 7 is the second checkpoint - if core screens aren't done, cut English/Bangla toggle, not the eligibility check.
- Day 8 is the freeze - no new features after this, only polish.

---

## 18. Risks and Mitigations

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| BDapps sandbox credentials arrive late | High | Build with mock subscription UI; swap to real at the end. |
| Gemini free tier rate limit hit | Low | Cache parsed PDFs by hash; only call on new PDFs (~5-10/day). |
| Bangla font rendering on low-end Android | Medium | Use system Bangla fallback if Hind Siliguri fails; test on Android 8 emulator. |
| Government websites change structure | High | Wrap scraper in try/except, log to scraper_logs; manual fallback to seeded data for demo. |
| pdfplumber fails on scanned PDFs | Medium | Use Gemini's multimodal capability - pass the PDF file directly, not extracted text. |
| BDapps SMS API not available during demo | Medium | Pre-record an SMS arriving on a phone; play video live. |
| Firebase setup on Android 8/9 fails | Medium | Test push on real device by day 14; have local notification fallback. |
| Admin dashboard scope creeps | Medium | Lock admin scope to: scraper_logs table view + 1 chart + "Run now" button. Nothing more. |

---

## 19. Pitch Strategy (3 minutes)

| Time | Slide / Action | Key message |
|------|----------------|-------------|
| 0:00-0:30 | The Pain | Every BCS candidate wastes 2 hours daily reading 10-page PDFs in 10 Facebook groups. |
| 0:30-1:30 | Live Demo | Show: 1) Open app, 2) AI summary card, 3) Filter by Bank, 4) Tap detail, 5) Simulate offline -> SMS still arrives. |
| 1:30-2:15 | Business Model | 3 BDT/day via BDapps carrier billing. Zero infra cost. Bangla-first, offline-first. |
| 2:15-2:45 | Innovation | First app in Bangladesh combining AI PDF digestion + telco SMS fallback. |
| 2:45-3:00 | Roadmap | v2: eligibility checker, multi-language, admin dashboard. |

### Likely judge questions and answers
- "How is this different from Bdjobs?" -> Bdjobs is private-sector + no SMS + no AI.
- "Who pays the Gemini API cost?" -> Free tier (1,500 req/day) covers our volume (<=10 req/day).
- "What if the government's website changes?" -> Scraper logs alert us; we fallback to manual seeding.
- "How will you retain users past 7 days?" -> SMS fallback makes the app useful even without internet - daily utility, not curiosity.
- "Why Bangla-first?" -> 95% of the audience reads Bangla first; English is the toggle, not the default.

---

## 20. Locked Decisions (final, 14 August 2026)

All 12 open decisions have been agreed. They are:

1. **App name**: Biggopti (kept).
2. **Tier 1 scraper sources**: BPSC, Bangladesh Bank, National University, Ministry of Public Administration, plus the four bank portals (Sonali, Janata, Agrani, Rupali).
3. **MVP scope**: All 7 original items + eligibility check + bookmarks + push notifications. (Admin dashboard and English/Bangla toggle live in the full feature set instead.)
4. **State management**: Riverpod 2.x.
5. **Seed data**: 20 hand-crafted circulars (Bangla, mixed categories, varied deadlines). Hybrid cutoff: auto-hide once scraped count >= 20 and oldest scraped is >3 days old. Implemented via a `source` column (`seed` | `scraped` | `manual`) and a query filter.
6. **BDapps integration**: Mock-first, then real. We have the BDapps API spec files locally. Build `BdappsService` interface with `BdappsServiceMock` (canned responses, used in dev and demo) and `BdappsServiceReal` (calls actual endpoints via the spec files). A `useMock` flag in `app_config.dart` toggles between them. Wire the real implementation after all screens are stable.
7. **Design palette**: Modern, organic & elegant. Deep forest green `#0A4D3C` + sage `#9EC5B2` + coral `#FF8B8B` + lavender `#B1A7F2` + soft slate background `#F4F6F4`. Semantic colors (success, warning, danger) preserved.
8. **Pitch deck**: Google Slides.
9. **Submission deadline**: ~10 days from 14 August 2026 (around 24 August 2026).
10. **Solo build** (heavily leveraging AI sub-agents for parallel work).
11. **Push notifications**: Topic-based (subscribers join topics like `bank`, `govt`, `varsity`, `high_priority`).
12. **Admin auth**: Hardcoded PIN in env var. Login screen compares input to PIN. Full admin dashboard (scraper logs + run-now button + PIN) is kept.
13. **Backend Hosting**: cPanel hosting environment (supporting cPanel Cron Jobs / Python App) for automated scraping, DB synchronization, and API integration. All third-party secrets managed via cPanel `.env` configuration.

---

## 21. Next Steps (decisions locked, build starts)

1. ~~Lock answers to the 12 open decisions in section 20.~~ DONE.
2. I generate the seeded `circulars.json` (20 demo entries) + the Supabase SQL with the `source` column.
3. I scaffold the Flutter project (`flutter create biggopti`) and the folder structure.
4. We write the Python scraper and Gemini prompt together.
5. We build the Flutter screens one at a time, on the 10-day timeline in section 17.

---

> Action item for you: read section 20 (Open Decisions) and reply with your choices. Once locked, we move to section 21.