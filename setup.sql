-- Run once in Supabase > SQL Editor. Safe to re-run.
create table if not exists user_data (
  user_id    uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data       jsonb not null default '{}',
  updated_at timestamptz not null default now()
);
alter table user_data enable row level security;

drop policy if exists "own data" on user_data;
create policy "own data" on user_data for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
