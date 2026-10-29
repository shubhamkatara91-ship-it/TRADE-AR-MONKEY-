-- TRADE AR MONEY core schema. Run in Supabase SQL Editor.
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 email text,
 username text,
 mobile text,
 role text not null default 'user' check (role in ('user','admin')),
 created_at timestamptz not null default now()
);
-- Safe migration for projects where profiles already existed before signup fields were added.
alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists mobile text;
create unique index if not exists profiles_username_lower_unique
  on public.profiles (lower(username)) where username is not null and length(trim(username)) > 0;
alter table public.profiles enable row level security;
-- Explicit API privileges; row-level security still limits each user's rows and allowed inserts.
grant select, insert on public.profiles to authenticated;
drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile" on public.profiles for select using (auth.uid()=id);
drop policy if exists "Users can create own user profile" on public.profiles;
create policy "Users can create own user profile" on public.profiles for insert with check (auth.uid()=id and role='user');
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $
begin
  insert into public.profiles(id,email,username,mobile,role)
  values(
    new.id,
    new.email,
    nullif(trim(new.raw_user_meta_data->>'username'),''),
    nullif(trim(new.raw_user_meta_data->>'mobile'),''),
    'user'
  )
  on conflict(id) do update set
    email=excluded.email,
    username=coalesce(public.profiles.username,excluded.username),
    mobile=coalesce(public.profiles.mobile,excluded.mobile);
  return new;
end; $;
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
drop policy if exists "Anyone can read result history" on public.result_history;
create policy "Anyone can read result history" on public.result_history for select to anon, authenticated using(true);
drop policy if exists "Admins can manage result history" on public.result_history;
create policy "Admins can manage result history" on public.result_history for all to authenticated using(public.is_admin()) with check(public.is_admin());

create table if not exists public.app_notifications (
 id bigint generated always as identity primary key, title text not null, body text not null,
 audience text not null default 'all' check(audience in ('all','users','admins')),
 created_at timestamptz not null default now()
);
alter table public.app_notifications enable row level security;
drop policy if exists "Users can read public notifications" on public.app_notifications;
drop policy if exists "Public notifications are readable by anyone" on public.app_notifications;
create policy "Public notifications are readable by anyone" on public.app_notifications for select to anon using(audience='all');
drop policy if exists "Users can read public notifications" on public.app_notifications;
drop policy if exists "Users can read audience notifications" on public.app_notifications;
create policy "Users can read audience notifications" on public.app_notifications for select to authenticated using(audience='all' or (audience='admins' and public.is_admin()) or (audience='users' and not public.is_admin()));
drop policy if exists "Admins can manage notifications" on public.app_notifications;
create policy "Admins can manage notifications" on public.app_notifications for all to authenticated using(public.is_admin()) with check(public.is_admin());

create table if not exists public.learning_articles (
 id bigint generated always as identity primary key, title text not null, body text not null,
 category text not null default 'Basics', published boolean not null default false,
 created_at timestamptz not null default now()
);
alter table public.learning_articles enable row level security;
drop policy if exists "Users can read published learning articles" on public.learning_articles;
drop policy if exists "Anyone can read published learning articles" on public.learning_articles;
create policy "Anyone can read published learning articles" on public.learning_articles for select to anon, authenticated using(published=true);
drop policy if exists "Admins can manage learning articles" on public.learning_articles;
create policy "Admins can manage learning articles" on public.learning_articles for all to authenticated using(public.is_admin()) with check(public.is_admin());
grant select on public.result_history, public.app_notifications, public.learning_articles to anon, authenticated;
grant insert, update, delete on public.result_history, public.app_notifications, public.learning_articles to authenticated;
grant usage, select on sequence public.result_history_id_seq, public.app_notifications_id_seq, public.learning_articles_id_seq to authenticated;

-- Safe starter learning content; re-running this schema does not duplicate these titles.
insert into public.learning_articles(title,body,category,published)
select seed.title,seed.body,seed.category,true
from (values
 ('Probability and uncertainty','A past outcome does not determine the next independent outcome. Be cautious of patterns that claim to guarantee a future result.','Basics'),
 ('Risk management basics','Never borrow money to speculate. Decide what you can afford to lose, understand uncertainty, and avoid guaranteed-profit claims.','Risk'),
 ('Verify information sources','Check the provider, timestamp, and original source before trusting a result. Treat unverified screenshots and forwarded messages as unconfirmed.','Verification')
) as seed(title,body,category)
where not exists (select 1 from public.learning_articles a where a.title=seed.title);

insert into public.app_notifications(title,body,audience)
select 'Welcome to TRADE AR MONEY','This app shares educational material only. Live data and push notifications are not enabled unless separately configured.','all'
where not exists (select 1 from public.app_notifications n where n.title='Welcome to TRADE AR MONEY');


-- Enable live in-app updates for announcements. Safe to rerun.
do $$
begin
  alter publication supabase_realtime add table public.app_notifications;
exception
  when duplicate_object then null;
  when undefined_object then
    raise notice 'supabase_realtime publication is not available; enable Realtime for app_notifications in the Supabase dashboard.';
end $$;

-- Explicit grants for the app's public read surfaces.
grant select on public.result_history, public.learning_articles to anon, authenticated;
grant select on public.app_notifications to anon, authenticated;


-- FCM device-token registry for future server-side push delivery.
-- Tokens are tied to the signed-in user and cannot be listed by other users.
create table if not exists public.device_push_tokens (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text not null check (platform in ('android','ios','web')),
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.device_push_tokens enable row level security;
drop policy if exists "Users manage own push tokens" on public.device_push_tokens;
create policy "Users manage own push tokens" on public.device_push_tokens
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
grant select, insert, update, delete on public.device_push_tokens to authenticated;
grant usage, select on sequence public.device_push_tokens_id_seq to authenticated;
