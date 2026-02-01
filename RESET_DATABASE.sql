-- ==========================================
-- SINO DATABASE RESET SCRIPT
-- ==========================================
-- Run this in the Supabase SQL Editor to fix "didn't change" issues.
-- It will DROP existing tables and recreate them cleanly.

-- 1. DROP EXISTING TABLES (Clean Slate)
DROP TABLE IF EXISTS mood_entries; 
DROP TABLE IF EXISTS academic_tasks;
DROP TABLE IF EXISTS profiles;

-- 2. CREATE PROFILES TABLE
create table profiles (
  id uuid references auth.users not null primary key,
  sino_points int default 0,
  updated_at timestamp with time zone
);

-- 3. CREATE MOOD ENTRIES TABLE
create table mood_entries (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  mood_level int not null,
  sentiment_score float,
  context text,
  source text,
  metadata jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. CREATE ACADEMIC TASKS TABLE
create table academic_tasks (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  title text not null,
  description text,
  due_date timestamp with time zone,
  priority int default 0,
  is_completed boolean default false,
  subject text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. ENABLE SECURITY (RLS)
alter table profiles enable row level security;
alter table mood_entries enable row level security;
alter table academic_tasks enable row level security;

-- 6. CREATE POLICIES (Access Rules)
create policy "Users can view own profile" on profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

create policy "Users can view own moods" on mood_entries for select using (auth.uid() = user_id);
create policy "Users can insert own moods" on mood_entries for insert with check (auth.uid() = user_id);

create policy "Users can view own tasks" on academic_tasks for select using (auth.uid() = user_id);
create policy "Users can insert own tasks" on academic_tasks for insert with check (auth.uid() = user_id);
create policy "Users can update own tasks" on academic_tasks for update using (auth.uid() = user_id);
create policy "Users can delete own tasks" on academic_tasks for delete using (auth.uid() = user_id);

-- 7. USER SIGNUP TRIGGER (Auto-create profile)
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

-- Drop trigger first if exists to avoid error
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- CONFIRMATION
SELECT 'Database successfully reset and initialized' as result;
