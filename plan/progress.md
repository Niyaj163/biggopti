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
1. Link remote GitHub repo (`git remote add origin ...` and `git push -u origin main`).
2. Scaffold the folder structure: `backend/`, `db/`, `docs/`, `.github/workflows/`.
3. Set up Supabase schema & 20 seeded demo circulars.
4. Set up Python scraper environment & Gemini API parsing.
5. Setup Flutter dependencies (Riverpod, Dio, Google Fonts, Supabase).

---

## Session 2 - 17 August 2026

### Goal
Initialize local Git repository, configure `.gitignore` for Flutter + Python full-stack, make initial commit, and prepare for GitHub remote link.

### What we did
1. Updated [`.gitignore`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/.gitignore) to exclude Python virtual environments (`venv/`, `.venv/`), bytecode caches, and `.env` secrets files.
2. Initialized local Git repository (`git init` with `main` branch).
3. Created initial local Git commit with all base Flutter app files and project plan documents ([`planning.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/plan/planning.md) & [`progress.md`](file:///d:/Education/nadb_app_dev/Biggopti/biggopti/plan/progress.md)).

---

