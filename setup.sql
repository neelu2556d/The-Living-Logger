-- Imperium: run this ONCE in Supabase > SQL Editor > New query > Run. Safe to run again.
-- It gives every signed-in user one private row that holds all of their app data.
create table if not exists user_state (
  user_id    uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data       jsonb not null default '{}',
  updated_at timestamptz not null default now()
);
alter table user_state enable row level security;
drop policy if exists "own state" on user_state;
create policy "own state" on user_state for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Optional: lets people who used the old Living Logger / Fuel pages bring their data across.
-- (If these tables never existed for you, this part does nothing.)
do $$ begin
  if to_regclass('public.user_data') is not null then
    execute 'alter table user_data enable row level security';
    execute 'drop policy if exists "own data delete" on user_data';
    execute 'create policy "own data delete" on user_data for delete using (auth.uid() = user_id)';
  end if;
  if to_regclass('public.fuel_data') is not null then
    execute 'alter table fuel_data enable row level security';
    execute 'drop policy if exists "own fuel delete" on fuel_data';
    execute 'create policy "own fuel delete" on fuel_data for delete using (auth.uid() = user_id)';
  end if;
end $$;
