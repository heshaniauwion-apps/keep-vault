-- Run this in your Supabase project's SQL Editor
-- (Dashboard -> SQL Editor -> New query -> paste -> Run)
--
-- If you previously ran the old setup with a single "vaults" table,
-- run this first to remove it (your old data will be lost):
-- drop table if exists vaults;

-- ---------- profiles: one row per user, stores name + the salt used to derive their encryption key ----------
create table if not exists profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  name text,
  salt text not null,
  check_enc text not null,
  updated_at timestamptz not null default now()
);

-- ---------- credentials: Bank / Gmail / Apps / Other tab ----------
-- password_enc, pin_enc, notes_enc are encrypted client-side before they ever reach Supabase.
-- category, title, username stay in plain text so you can browse/search the table.
create table if not exists credentials (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null,
  title text not null,
  username text,
  password_enc text,
  pin_enc text,
  atm_enc text,
  notes_enc text,
  updated_at timestamptz not null default now()
);

-- If you already created the credentials table before this update, run this
-- one line instead to add just the new column:
-- alter table credentials add column if not exists atm_enc text;

-- ---------- notes: Notes tab ----------
-- title stays plain text, body_enc is encrypted client-side.
create table if not exists notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text,
  body_enc text,
  updated_at timestamptz not null default now()
);

-- ---------- tasks: Task list / Time table / Completed tabs ----------
-- nothing sensitive here, stored in plain text.
create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  text text not null,
  category text not null default 'other',
  date date,
  time text,
  done boolean not null default false,
  created_at timestamptz not null default now()
);

-- ---------- Row Level Security: every table, every user can only touch their own rows ----------
alter table profiles enable row level security;
alter table credentials enable row level security;
alter table notes enable row level security;
alter table tasks enable row level security;

create policy "own profile select" on profiles for select using (auth.uid() = user_id);
create policy "own profile insert" on profiles for insert with check (auth.uid() = user_id);
create policy "own profile update" on profiles for update using (auth.uid() = user_id);
create policy "own profile delete" on profiles for delete using (auth.uid() = user_id);

create policy "own credentials select" on credentials for select using (auth.uid() = user_id);
create policy "own credentials insert" on credentials for insert with check (auth.uid() = user_id);
create policy "own credentials update" on credentials for update using (auth.uid() = user_id);
create policy "own credentials delete" on credentials for delete using (auth.uid() = user_id);

create policy "own notes select" on notes for select using (auth.uid() = user_id);
create policy "own notes insert" on notes for insert with check (auth.uid() = user_id);
create policy "own notes update" on notes for update using (auth.uid() = user_id);
create policy "own notes delete" on notes for delete using (auth.uid() = user_id);

create policy "own tasks select" on tasks for select using (auth.uid() = user_id);
create policy "own tasks insert" on tasks for insert with check (auth.uid() = user_id);
create policy "own tasks update" on tasks for update using (auth.uid() = user_id);
create policy "own tasks delete" on tasks for delete using (auth.uid() = user_id);
