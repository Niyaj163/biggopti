# Biggopti - Build Progress Log

> Running session memory for the Biggopti build. Updated at the end of every session so future Claude sessions can pick up seamlessly.
> Source of truth for state: planning.md (decisions) + this file (progress).

---

## Session 1 - 14 August 2026

### Goal
Lock all 12 open decisions from Section 20, compress the 20-day plan to 10 days, and update planning.md.

### What we did
1. Read the original planning.md end-to-end.
2. Walked through all 12 open decisions one by one with clarifying questions.
3. Locked every decision.

### Locked Decisions (summary)
1. App name: Biggopti (kept).
2. Tier 1 sources: BPSC + Bangladesh Bank + National University + MoPA + Sonali, Janata, Agrani, Rupali banks.
3. MVP scope: original 7 + eligibility check + bookmarks + push notifications.
4. State management: Riverpod 2.x.
5. Seed data: 20 circulars, hybrid cutoff (auto-hide once scraped count >= 20 and oldest scraped is >3 days old).
6. BDapps: mock-first, then real (we have the API spec files locally).
7. Design palette: deep forest green `#0A4D3C` + sage `#9EC5B2` + coral `#FF8B8B` + lavender `#B1A7F2` + soft slate background `#F4F6F4`.
8. Pitch deck: Google Slides.
9. Submission deadline: ~10 days from 14 Aug 2026 (~24 Aug 2026).
10. Solo build.
11. Push notifications: topic-based.
12. Admin auth: hardcoded PIN in env var, full admin dashboard (logs + run-now + PIN) kept.

### Updated planning.md
- Header: window changed to 10 days, last updated 14 Aug 2026.
- Section 7.1: MVP spine expanded to 10 items.
- Section 7.2: full feature set reduced to admin dashboard + English/Bangla toggle.
- Section 10: replaced Bangladesh flag palette with the new forest-green/sage/coral/lavender system.
- Section 12: Tier 1 scraper sources expanded to 8 sources (added 4 bank portals).
- Section 14: added `source` column + index on circulars.
- Section 15: replaced sandbox plan with mock-first-then-real strategy.
- Section 17: rebuilt as 10-day, 8-phase plan. Risk checkpoints at days 4, 7, 8.
- Section 20: replaced open decisions with "Locked Decisions" section.
- Section 21: updated next steps.

### Compressed 10-day timeline
| Day | Phase | Deliverable |
|-----|-------|-------------|
| 1 | P0 - Setup | Repo, Supabase, Flutter SDK, Python venv, BDapps API review |
| 2 | P1 - Data layer | Supabase schema (4 tables + `source` column), 20 seed circulars |
| 3-4 | P2 - Backend | Python scraper, Gemini prompt v1, GitHub Actions cron, scraper_logs, BDapps SMS trigger (mock) |
| 5 | P3 - Flutter foundation | `flutter create biggopti`, theme, fonts, Riverpod, routing, models, Supabase client |
| 6-7 | P4 - Core screens | Onboarding, paywall, home feed, detail, filter, eligibility, bookmarks, BDapps mock |
| 8 | P5 - Push + admin | Firebase FCM topic push, admin dashboard, English/Bangla toggle, swap BDapps mock -> real |
| 9 | P6 - Polish | Loading/empty/error states, animations, low-end Android test, bug fixes |
| 10 | P7 - Demo | README, architecture diagram, API docs, demo script, 3-min pitch, 3 demo recordings |

### Repo structure (proposed)
```
biggopti/
├── app/                  <- Flutter app
├── backend/              <- Python scraper + Gemini integration
├── db/                   <- Supabase schema + migrations
├── docs/                 <- README, architecture, API docs
├── .github/workflows/    <- scraper-cron.yml
├── .gitignore
└── README.md
```

### Open questions / blockers
- None yet.

### NEXT (start of next session)
1. Setup Flutter core dependencies (`flutter_riverpod`, `dio`, `google_fonts`, `supabase_flutter`).
2. Implement core Flutter models (`Circular`, `UserProfile`, `Bookmark`).
3. Implement theme system (Forest Green `#0A4D3C`, Sage `#9EC5B2`, Coral `#FF8B8B`, Lavender `#B1A7F2`) and Hind Siliguri Bangla font support.
4. Build onboarding and home feed UI.

---

## Session 2 - 17 August 2026

### Goal
Initialize local Git repository, configure `.gitignore` for Flutter + Python full-stack, make initial commit, and prepare for GitHub remote link.

### What we did
1. Updated [`.gitignore`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/.gitignore) to exclude Python virtual environments (`venv/`, `.venv/`), bytecode caches, and `.env` secrets files.
2. Initialized local Git repository (`git init` with `main` branch).
3. Created initial local Git commit with all base Flutter app files and project plan documents ([`planning.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/plan/planning.md) & [`progress.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/plan/progress.md)).
4. Pushed repository to GitHub (`https://github.com/Niyaj163/biggopti.git`).

---

## Session 3 - 17 August 2026

### Goal
Incorporate cPanel hosting decision into architecture, create explicit third-party key setup documentation, and scaffold backend & database infrastructure files.

### What we did
1. Created [`THIRD_PARTY_KEYS.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/docs/THIRD_PARTY_KEYS.md) providing step-by-step instructions for acquiring and configuring all API keys (`GEMINI_API_KEY`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `BDAPPS_APP_ID`, `BDAPPS_APP_PASSWORD`).
2. Scaffolded [`backend/.env.example`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/.env.example) template file for local and cPanel deployment.
3. Created [`db/schema.sql`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/db/schema.sql) containing PostgreSQL DDL for 4 core tables (`circulars`, `subscribers`, `bookmarks`, `scraper_logs`) with Row Level Security (RLS) policies.
4. Created [`db/seed_circulars.json`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/db/seed_circulars.json) containing 20 authentic demo circulars (Bangla job circulars: BPSC, Central Bank AD, NU, Sonali/Janata Bank, Primary Teacher, Police SI).
5. Created [`backend/requirements.txt`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/requirements.txt), [`backend/prompts/parse_circular.txt`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/prompts/parse_circular.txt) (Gemini Flash Bangla prompt), and [`backend/main.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/main.py).
6. Updated [`planning.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/plan/planning.md) (Decision 13: cPanel Backend Hosting & Cron Jobs).

## Session 4 - 17 August 2026

### Goal
Review user's BDapps reference project (`Hands_on_project_NADB-main`), extract full API endpoints, CaaS subscription flow, and compliance requirements, and document them in planning & key guides.

### What we did
1. Analyzed reference files: `lib/services/bdapps_api.dart`, `lib/services/bdapps_api_service.dart`, and `lib/providers/bdapps_subscription_provider.dart` from `Hands_on_project_NADB-main`.
2. Extracted the 4 core cPanel PHP gateway endpoints:
   - `/check_subscription.php` (`user_mobile`) -> Returns `REGISTERED` (`S1000`) or `UNREGISTERED` (`E1951`).
   - `/send_otp.php` (`user_mobile`) -> Sends OTP, returns `referenceNo` or `E1351` (already registered).
   - `/verify_otp.php` (`Otp`, `referenceNo`) -> Verifies OTP (`S1000`).
   - `/unsubscribe.php` (`user_mobile`) -> Unsubscribes user and triggers mandatory app logout.
3. Updated [`planning.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/plan/planning.md) Section 15 and [`THIRD_PARTY_KEYS.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/docs/THIRD_PARTY_KEYS.md) Section 3 to document the cPanel PHP gateway architecture and compliance requirements.

## Session 5 - 17 August 2026

### Goal
Configure Flutter dependencies, build design system theme & Bangla typography (`Hind Siliguri`), construct data models & Riverpod state providers, connect Supabase live query feed, and build core Flutter UI screens.

### What we did
1. Configured dependencies in [`pubspec.yaml`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/pubspec.yaml): `flutter_riverpod`, `supabase_flutter`, `google_fonts`, `dio`, `shared_preferences`, `intl`, `url_launcher`.
2. Created design system token constants in [`lib/core/constants/app_colors.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/core/constants/app_colors.dart) (Deep Forest Green `#0A4D3C`, Sage `#9EC5B2`, Coral `#FF8B8B`, Lavender `#B1A7F2`, Soft Slate `#F4F6F4`).
3. Built [`lib/core/theme/app_theme.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/core/theme/app_theme.dart) featuring `Hind Siliguri` typography.
4. Created core data models: [`lib/models/circular_model.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/models/circular_model.dart) and [`lib/models/user_profile.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/models/user_profile.dart).
5. Implemented [`lib/core/services/supabase_service.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/core/services/supabase_service.dart) for fetching circulars from Supabase database.
6. Implemented [`lib/core/services/bdapps_service.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/core/services/bdapps_service.dart) with `BdappsServiceMock` and `BdappsServiceReal`.
7. Created Riverpod state providers: [`lib/providers/circular_provider.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/providers/circular_provider.dart) and [`lib/providers/bookmark_provider.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/providers/bookmark_provider.dart).
8. Built Flutter UI views:
   - [`lib/views/home/home_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/home/home_screen.dart) (Category filter bar: সব / সরকারি / ব্যাংক / বিশ্ববিদ্যালয়, BDapps SMS banner, live circular list).
   - [`lib/views/home/widgets/circular_card.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/home/widgets/circular_card.dart) (Card with category badge, priority tag, deadline indicator, 3-bullet Bangla summary, and bookmark toggle).
   - [`lib/views/detail/circular_detail_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/detail/circular_detail_screen.dart) (Detailed digest screen with external PDF launcher).
   - [`lib/views/bookmarks/bookmarks_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/bookmarks/bookmarks_screen.dart) (Saved circulars view).
   - [`lib/views/eligibility/eligibility_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/eligibility/eligibility_screen.dart) (Personalized eligibility checker).
   - [`lib/views/paywall/paywall_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/paywall/paywall_screen.dart) (BDapps SMS subscription flow & OTP verification).
9. Verified zero errors with `flutter analyze`.

## Session 6 - 17 August 2026

### Goal
Build live web scrapers for Bangladeshi notice portals, integrate `pdfplumber` + Gemini 2.5 Flash AI PDF parsing engine, enable SHA256 deduplication, log runs to Supabase `scraper_logs`, and create cPanel Cron Job deployment guide.

### What we did
1. Created [`backend/scrapers/base_scraper.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/base_scraper.py) providing SHA256 hash deduplication, HTTP page fetching, and PDF downloading logic.
2. Created scrapers: [`backend/scrapers/bpsc.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/bpsc.py) (BPSC notices) and [`backend/scrapers/bb.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/bb.py) (Bangladesh Bank career notices).
3. Created [`backend/ai_parser.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/ai_parser.py) implementing `pdfplumber` text extraction and Gemini 2.5 Flash structured Bangla JSON parsing (`response_mime_type="application/json"`).
4. Updated [`backend/main.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/main.py) to connect live to Supabase, run scrapers, check PDF hashes for duplicates, call Gemini 2.5 Flash, auto-insert new digested Bangla circulars, and record run logs in `scraper_logs` table.
5. Created [`backend/cpanel_cron.sh`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/cpanel_cron.sh) for cPanel Cron Jobs.
6. Created [`docs/CPANEL_DEPLOYMENT.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/docs/CPANEL_DEPLOYMENT.md) detailing step-by-step cPanel hosting setup for Python App and Cron Jobs.

---

## Session 7 - 22 August 2026

### Goal
Build Phase 5 features: Admin Dashboard (PIN-based authentication, scraper health metrics, scraper logs table, manual "Run Now" scraper trigger), Settings & Multi-language toggle (Bangla/English), BDapps CaaS subscription manager, resilient Push Notification topic architecture, and resolve all analyzer & test deprecations.

### What we did
1. Created [`lib/core/constants/app_config.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/core/constants/app_config.dart) defining default Admin PIN (`2026`), versioning, and app constants.
2. Created [`lib/models/scraper_log_model.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/models/scraper_log_model.dart) and updated [`lib/core/services/supabase_service.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/core/services/supabase_service.dart) to fetch scraper logs, calculate circular metrics, and record manual scraper execution logs.
3. Created state providers:
   - [`lib/providers/locale_provider.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/providers/locale_provider.dart) for seamless Bangla/English UI switching and `SharedPreferences` persistence.
   - [`lib/providers/subscription_provider.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/providers/subscription_provider.dart) for BDapps CaaS status, OTP requests, and unsubscription handling.
   - [`lib/providers/admin_provider.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/providers/admin_provider.dart) for real-time scraper log streams and circular database statistics.
4. Created [`lib/core/services/notification_service.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/core/services/notification_service.dart) for topic subscriptions (`all_circulars`, `urgent_deadlines`, `bank_jobs`, `varsity_notices`).
5. Built Admin UI & Widgets:
   - [`lib/views/admin/admin_login_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/admin/admin_login_screen.dart) with custom 4-digit PIN keypad and validation.
   - [`lib/views/admin/admin_dashboard_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/admin/admin_dashboard_screen.dart) with status cards, DB circular breakdown, and real-time scraper log inspection.
   - [`lib/views/admin/widgets/scraper_log_table.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/admin/widgets/scraper_log_table.dart) and [`lib/views/admin/widgets/run_now_button.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/admin/widgets/run_now_button.dart).
6. Built [`lib/views/settings/settings_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/settings/settings_screen.dart) with language selector, BDapps plan status/management, push notification topic preferences, and secret Admin portal entry.
7. Updated [`lib/views/home/home_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/home/home_screen.dart) to integrate the Settings icon in the top AppBar.
8. Resolved all deprecated members across the codebase (`withOpacity` -> `withValues`, `activeColor` -> `activeThumbColor`, `value` -> `initialValue`) and verified **0 issues** on `flutter analyze` and **100% passing tests** on `flutter test`.

---

## Session 8 - 22 August 2026

### Goal
Upgrade live backend scraping pipeline from small 5-notice slices to a full 30-batch multi-source crawler across BPSC (Govt), Bangladesh Bank (Bank), and National University (Varsity) portals to ensure a rich feed of real notices.

### What we did
1. Updated [`backend/scrapers/bpsc.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/bpsc.py) to crawl up to 20 latest real BPSC notices.
2. Updated [`backend/scrapers/bb.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/bb.py) to crawl up to 15 active Bangladesh Bank career circulars.
3. Created [`backend/scrapers/nu.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/nu.py) to crawl up to 15 latest National University notices and circulars.
4. Updated [`backend/scrapers/__init__.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/__init__.py) to export `NUScraper`.
5. Updated [`backend/main.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/main.py) with `TARGET_CIRCULARS_COUNT = 30` to aggregate and digest 30 real notices into Supabase with `source: 'scraped'` and SHA-256 deduplication.
6. Synchronized [`plan/planning.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/plan/planning.md) (Decision 5 updated) and this progress log.

---

## Session 9 - 22 August 2026

### Goal
Implement strict job/academic notice relevance filtering, add Gemini 3.6 Flash multimodal direct OCR for scanned image PDFs, eliminate generic placeholder outputs ("পিডিএফ কন্টেন্ট বিস্তারিত পাওয়া যায় নি"), and purge non-job records from the live Supabase database.

### What we did
1. Updated [`backend/prompts/parse_circular.txt`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/prompts/parse_circular.txt) with strict validation rules (`is_valid_circular`) rejecting personal CVs, employee profiles, office transfer orders, and office supply tenders, with an explicit ban on generic placeholder phrases.
2. Upgraded [`backend/ai_parser.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/ai_parser.py):
   - Migrated to `gemini-3.6-flash`.
   - Added direct multimodal PDF bytes OCR fallback (`types.Part.from_bytes`) whenever `pdfplumber` encounters scanned image PDFs.
   - Added automated rejection of non-job documents and empty placeholder outputs.
3. Added strict keyword whitelists and blacklists in scrapers ([`backend/scrapers/nu.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/nu.py), [`backend/scrapers/bpsc.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/bpsc.py), [`backend/scrapers/dpe.py`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/backend/scrapers/dpe.py)).
4. Purged invalid non-job CV entries from the live Supabase database.
5. Pushed all updates to GitHub `origin/main`.

---

## Session 10 - 22 August 2026

### Goal
Fix 404 / Page Not Found errors on circular links by verifying all official portal links live over HTTP, updating the database with 100% verified 200 OK links, and enhancing url_launcher fallback handling in Flutter.

### What we did
1. Conducted live automated HTTP test verification on all official portal links across BPSC, Bangladesh Bank, DPE, MoPA, BPDB, LGED, DGHS, Railway, Police, NBR, Islami Bank, BRAC Bank, City Bank, DU, RU, JU, and BUET.
2. Updated [`db/seed_circulars.json`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/db/seed_circulars.json) with 100% verified, live 200 OK links.
3. Updated [`lib/views/detail/circular_detail_screen.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/views/detail/circular_detail_screen.dart) with enhanced `_launchPdfUrl` error handling and platform-default fallback.
4. Cleaned and synchronized Supabase `circulars` table with the verified 200 OK links.
5. Pushed all updates to GitHub `origin/main`.

---

## Session 11 - 22 August 2026

### Goal
Filter out expired job circulars whose application deadlines have passed, displaying strictly active circulars where users can apply.

### What we did
1. Created [`lib/core/utils/deadline_helper.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/core/utils/deadline_helper.dart) to parse Bangla, English, and ISO dates, and determine if an application deadline has passed.
2. Updated [`lib/providers/circular_provider.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/lib/providers/circular_provider.dart) to filter all circular streams with `DeadlineHelper.isActive()`, ensuring only currently active circulars appear in the feed.
3. Created comprehensive unit tests in [`test/deadline_helper_test.dart`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/test/deadline_helper_test.dart) (100% passing tests).
4. Verified **0 issues** on `flutter analyze` and committed & pushed to GitHub `origin/main`.


