-- Earth Orbit: Supabase setup (run in SQL Editor)
-- 1) Create an admin in Authentication -> Users.
-- 2) Copy that user's UUID (User UID column / user details) into the INSERT at the bottom.
-- 3) Run the whole script. Existing earth_orbit_state data is preserved.

create table if not exists public.earth_orbit_state (
  id integer primary key check (id = 1),
  state jsonb not null default '{"users":[],"pendingRequests":[]}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.earth_orbit_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table if not exists public.earth_orbit_requests (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 40),
  email text not null check (char_length(email) between 3 and 254),
  info text not null default '' check (char_length(info) <= 240),
  created_at timestamptz not null default now()
);

alter table public.earth_orbit_state enable row level security;
alter table public.earth_orbit_admins enable row level security;
alter table public.earth_orbit_requests enable row level security;
grant select, insert, update on public.earth_orbit_state to anon, authenticated;
grant select, insert, delete on public.earth_orbit_requests to anon, authenticated;
grant select, insert on public.earth_orbit_admins to anon, authenticated;
create or replace function public.is_earth_orbit_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.earth_orbit_admins a where a.user_id = (select auth.uid()));
$$;
revoke all on function public.is_earth_orbit_admin() from public;
grant execute on function public.is_earth_orbit_admin() to anon, authenticated;

drop policy if exists "Anyone can read Earth Orbit state" on public.earth_orbit_state;
create policy "Anyone can read Earth Orbit state" on public.earth_orbit_state for select to anon, authenticated using (true);
drop policy if exists "Bootstrap initial Earth Orbit state" on public.earth_orbit_state;
create policy "Bootstrap initial Earth Orbit state" on public.earth_orbit_state for insert to anon, authenticated with check (id = 1 and not exists (select 1 from public.earth_orbit_state));
drop policy if exists "Admins can update Earth Orbit state" on public.earth_orbit_state;
create policy "Admins can update Earth Orbit state" on public.earth_orbit_state for update to authenticated using (public.is_earth_orbit_admin()) with check (public.is_earth_orbit_admin());
drop policy if exists "Admins can insert Earth Orbit state" on public.earth_orbit_state;
create policy "Admins can insert Earth Orbit state" on public.earth_orbit_state for insert to authenticated with check (public.is_earth_orbit_admin());

drop policy if exists "No direct access to Earth Orbit admins" on public.earth_orbit_admins;
create policy "No direct access to Earth Orbit admins" on public.earth_orbit_admins for all to anon, authenticated using (false) with check (false);
drop policy if exists "Anyone can submit a join request" on public.earth_orbit_requests;
create policy "Anyone can submit a join request" on public.earth_orbit_requests for insert to anon, authenticated with check (char_length(trim(name)) > 0 and char_length(trim(email)) >= 3 and char_length(info) <= 240);
drop policy if exists "Admins can read join requests" on public.earth_orbit_requests;
create policy "Admins can read join requests" on public.earth_orbit_requests for select to authenticated using (public.is_earth_orbit_admin());
drop policy if exists "Admins can delete join requests" on public.earth_orbit_requests;
create policy "Admins can delete join requests" on public.earth_orbit_requests for delete to authenticated using (public.is_earth_orbit_admin());

do $$ begin alter publication supabase_realtime add table public.earth_orbit_state; exception when duplicate_object then null; when others then if sqlstate <> '42710' then raise; end if; end $$;
do $$ begin alter publication supabase_realtime add table public.earth_orbit_requests; exception when duplicate_object then null; when others then if sqlstate <> '42710' then raise; end if; end $$;

-- Replace UUID below with your admin user's UID from Authentication -> Users.
insert into public.earth_orbit_admins(user_id) values ('45ad0d54-56a8-42fb-a0c9-3bc823c3f51c'::uuid) on conflict (user_id) do nothing;
