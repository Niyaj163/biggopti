-- ==============================================================================
-- Biggopti - Supabase PostgreSQL Database Schema
-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard)
-- ==============================================================================

-- 1. Circulars Table (Stores AI-digested notices)
CREATE TABLE IF NOT EXISTS circulars (
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

-- Index for category filter and hybrid cutoff query
CREATE INDEX IF NOT EXISTS idx_circulars_source_created ON circulars (source, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_circulars_category ON circulars (category);

-- 2. Subscribers Table (BDapps target phone numbers)
CREATE TABLE IF NOT EXISTS subscribers (
    phone_number VARCHAR(15) PRIMARY KEY,
    subscription_status VARCHAR(20) DEFAULT 'ACTIVE',
    subscribed_at TIMESTAMPTZ DEFAULT NOW(),
    last_billed_at TIMESTAMPTZ
);

-- 3. Bookmarks Table (User saved circulars)
CREATE TABLE IF NOT EXISTS bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(15) REFERENCES subscribers(phone_number) ON DELETE CASCADE,
    circular_id UUID REFERENCES circulars(id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(phone_number, circular_id)
);

-- 4. Scraper Logs Table (Monitoring & Deduplication)
CREATE TABLE IF NOT EXISTS scraper_logs (
    id SERIAL PRIMARY KEY,
    source_url TEXT,
    pdf_hash VARCHAR(64),
    status VARCHAR(20),
    error_message TEXT,
    ran_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security (RLS) Enablement
ALTER TABLE circulars ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE scraper_logs ENABLE ROW LEVEL SECURITY;

-- Allow public read access to circulars
CREATE POLICY "Allow public read access to circulars" ON circulars
    FOR SELECT USING (true);

-- Allow public insert/select for bookmarks
CREATE POLICY "Allow public read/write to bookmarks" ON bookmarks
    FOR ALL USING (true);

-- Allow public insert/read to subscribers
CREATE POLICY "Allow public access to subscribers" ON subscribers
    FOR ALL USING (true);

-- Allow public read for scraper_logs
CREATE POLICY "Allow public access to scraper_logs" ON scraper_logs
    FOR ALL USING (true);
