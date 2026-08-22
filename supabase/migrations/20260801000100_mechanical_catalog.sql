-- ============================================================================
-- Mechanical Issues Catalog
-- ----------------------------------------------------------------------------
-- Creates two tables:
--   1. public.mechanical_issues    — flat list of issue names (common + extra)
--   2. public.car_model_catalog    — brand/model/year/extra-flag lookup rows
--
-- Idempotent: safe to run more than once (IF NOT EXISTS / guarded constraints /
-- dropped-then-recreated policies).
--
-- How to run:
--   Option A (recommended): supabase SQL Editor → paste → Run
--   Option B (CLI):
--       supabase link --project-ref uewkpfwrmmpklpleqltg
--       supabase db push            (or `supabase db reset`)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1) mechanical_issues
-- ----------------------------------------------------------------------------
create table if not exists public.mechanical_issues (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    is_common boolean not null default true,
    created_at timestamptz not null default now()
);

-- Guarded unique constraint so re-running the migration does not fail.
do $$
begin
    if not exists (
        select 1
        from pg_constraint
        where conname = 'mechanical_issues_name_key'
          and conrelid = 'public.mechanical_issues'::regclass
    ) then
        alter table public.mechanical_issues
            add constraint mechanical_issues_name_key unique (name);
    end if;
end $$;

-- Index used to dedupe during seeding (exact name match already covered by the
-- unique constraint; this index supports ILIKE lookups if ever needed).
create index if not exists mechanical_issues_name_idx
    on public.mechanical_issues (name);

-- Row Level Security: clients (anon/authenticated) may read the catalog.
alter table public.mechanical_issues enable row level security;

drop policy if exists "mechanical_issues_select_all" on public.mechanical_issues;
create policy "mechanical_issues_select_all"
    on public.mechanical_issues
    for select
    using (true);

-- ----------------------------------------------------------------------------
-- 2) car_model_catalog
-- ----------------------------------------------------------------------------
create table if not exists public.car_model_catalog (
    id uuid primary key default gen_random_uuid(),
    brand text not null,
    model text not null,
    year_start integer,
    year_end integer,
    gets_extra_issues boolean not null default false,
    created_at timestamptz not null default now()
);

-- Case-insensitive + trimmed unique brand/model so the seed script can run
-- repeatedly without creating duplicates ("Hyundai" vs "hyundai" are the same).
create unique index if not exists car_model_catalog_brand_model_unique
    on public.car_model_catalog (lower(btrim(brand)), lower(btrim(model)));

-- Typical lookups are by brand + model (case-insensitive).
create index if not exists car_model_catalog_brand_name_idx
    on public.car_model_catalog (lower(btrim(brand)), lower(btrim(model)));

-- Row Level Security: clients (anon/authenticated) may read the catalog.
alter table public.car_model_catalog enable row level security;

drop policy if exists "car_model_catalog_select_all" on public.car_model_catalog;
create policy "car_model_catalog_select_all"
    on public.car_model_catalog
    for select
    using (true);

-- ----------------------------------------------------------------------------
-- Implementation notes
-- ----------------------------------------------------------------------------
-- * Matching in the app uses BRAND + MODEL ONLY (case-insensitive, trimmed).
--   year_start / year_end are stored for future use/display and are NOT part
--   of the matching condition.
-- * The catalog is read-only for clients; seeding is done with the service-role
--   key (see tool/seed_mechanical_catalog.dart), which bypasses RLS.
-- ============================================================================