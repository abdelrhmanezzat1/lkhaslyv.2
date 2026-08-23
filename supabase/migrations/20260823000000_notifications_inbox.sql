-- Notifications inbox: persisted copy of every push a user should see.
--
-- The push-notification-listener edge function inserts one row per target
-- user when it fans out a notification (userIds / role targeting). The app
-- reads this table for the in-app notification center and unread badge.
--
-- Apply with: supabase db push  (or run in the SQL editor)

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null,
  title text not null,
  body text not null,
  data jsonb not null default '{}'::jsonb,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_created_idx
  on public.notifications (user_id, created_at desc);

create index if not exists notifications_user_unread_idx
  on public.notifications (user_id)
  where read = false;

alter table public.notifications enable row level security;

drop policy if exists "Users can view own notifications"
  on public.notifications;
create policy "Users can view own notifications"
  on public.notifications
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can update own notifications"
  on public.notifications;
create policy "Users can update own notifications"
  on public.notifications
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Inserts happen only from the edge function via the service-role key,
-- so no insert/delete policy is granted to clients.
