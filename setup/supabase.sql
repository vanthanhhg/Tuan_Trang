-- RUN THIS IN SUPABASE SQL EDITOR AFTER CREATING AN AUTH USER.
-- Then replace UUID in the final INSERT and execute that statement separately.
-- No service_role / secret key should ever appear in browser code.

create table if not exists public.wedding_admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.wedding_admins enable row level security;
revoke all on public.wedding_admins from anon, authenticated;
grant select on public.wedding_admins to authenticated;
drop policy if exists "admin reads own membership" on public.wedding_admins;
create policy "admin reads own membership" on public.wedding_admins for select to authenticated
  using (user_id = (select auth.uid()));

create table if not exists public.wedding_content (
  id text primary key check (id = 'main'),
  content jsonb not null,
  updated_at timestamptz default now()
);
alter table public.wedding_content enable row level security;
revoke all on public.wedding_content from anon, authenticated;
grant select on public.wedding_content to anon, authenticated;
grant insert, update on public.wedding_content to authenticated;
drop policy if exists "public reads invitation" on public.wedding_content;
create policy "public reads invitation" on public.wedding_content for select to anon, authenticated using (true);
drop policy if exists "admin publishes invitation" on public.wedding_content;
create policy "admin publishes invitation" on public.wedding_content for insert to authenticated
  with check (exists (select 1 from public.wedding_admins a where a.user_id=(select auth.uid())));
drop policy if exists "admin updates invitation" on public.wedding_content;
create policy "admin updates invitation" on public.wedding_content for update to authenticated
  using (exists (select 1 from public.wedding_admins a where a.user_id=(select auth.uid())))
  with check (exists (select 1 from public.wedding_admins a where a.user_id=(select auth.uid())));

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('wedding-media','wedding-media',true,52428800, ARRAY['image/jpeg','image/png','image/webp','image/gif','audio/mpeg','audio/mp3','audio/wav','audio/ogg'])
on conflict (id) do update set public = true, file_size_limit = 52428800;

drop policy if exists "admin uploads wedding assets" on storage.objects;
create policy "admin uploads wedding assets" on storage.objects for insert to authenticated
  with check (bucket_id='wedding-media' and exists(select 1 from public.wedding_admins a where a.user_id=(select auth.uid())));
drop policy if exists "admin updates wedding assets" on storage.objects;
create policy "admin updates wedding assets" on storage.objects for update to authenticated
  using (bucket_id='wedding-media' and exists(select 1 from public.wedding_admins a where a.user_id=(select auth.uid()))))
  with check (bucket_id='wedding-media' and exists(select 1 from public.wedding_admins a where a.user_id=(select auth.uid()))));
drop policy if exists "admin deletes wedding assets" on storage.objects;
create policy "admin deletes wedding assets" on storage.objects for delete to authenticated
  using (bucket_id='wedding-media' and exists(select 1 from public.wedding_admins a where a.user_id=(select auth.uid()))));

-- EXAMPLE: Replace with your user's actual UUID from Authentication > Users:
-- insert into public.wedding_admins (user_id) values ('REPLACE-WITH-YOUR-USER-UUID');
