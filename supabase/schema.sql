-- TRADE AR MONEY core schema. Run in Supabase SQL Editor.
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 email text, role text not null default 'user' check (role in ('user','admin')),
 created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile" on public.profiles for select using (auth.uid()=id);
drop policy if exists "Users can create own user profile" on public.profiles;
create policy "Users can create own user profile" on public.profiles for insert with check (auth.uid()=id and role='user');
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,email,role) values(new.id,new.email,'user') on conflict(id) do update set email=excluded.email; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

create table if not exists public.result_history (
 id bigint generated always as identity primary key, source text not null,
 result_label text not null, result_value text, observed_at timestamptz not null,
 created_at timestamptz not null default now()
);
alter table public.result_history enable row level security;
drop policy if exists "Authenticated users can read result history" on public.result_history;
create policy "Authenticated users can read result history" on public.result_history for select to authenticated using(true);
drop policy if exists "Admins can manage result history" on public.result_history;
create policy "Admins can manage result history" on public.result_history for all to authenticated using(public.is_admin()) with check(public.is_admin());

create table if not exists public.app_notifications (
 id bigint generated always as identity primary key, title text not null, body text not null,
 audience text not null default 'all' check(audience in ('all','users','admins')),
 created_at timestamptz not null default now()
);
alter table public.app_notifications enable row level security;
drop policy if exists "Users can read public notifications" on public.app_notifications;
create policy "Users can read public notifications" on public.app_notifications for select to authenticated using(audience='all' or (audience='admins' and public.is_admin()) or (audience='users' and not public.is_admin()));
drop policy if exists "Admins can manage notifications" on public.app_notifications;
create policy "Admins can manage notifications" on public.app_notifications for all to authenticated using(public.is_admin()) with check(public.is_admin());

create table if not exists public.learning_articles (
 id bigint generated always as identity primary key, title text not null, body text not null,
 category text not null default 'Basics', published boolean not null default false,
 created_at timestamptz not null default now()
);
alter table public.learning_articles enable row level security;
drop policy if exists "Users can read published learning articles" on public.learning_articles;
create policy "Users can read published learning articles" on public.learning_articles for select to authenticated using(published=true);
drop policy if exists "Admins can manage learning articles" on public.learning_articles;
create policy "Admins can manage learning articles" on public.learning_articles for all to authenticated using(public.is_admin()) with check(public.is_admin());
grant select on public.result_history, public.app_notifications, public.learning_articles to authenticated;
grant insert, update, delete on public.result_history, public.app_notifications, public.learning_articles to authenticated;
grant usage, select on all sequences in schema public to authenticated;
