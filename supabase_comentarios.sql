-- ==========================================
-- AUVIX - COMENTARIOS E INTERACAO SOCIAL
-- ==========================================

-- 1. PERFIS PUBLICOS DOS USUARIOS
create table if not exists public.auvix_video_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Investidor AUVIX',
  avatar_index integer not null default 0
    check (avatar_index between 0 and 11),
  updated_at timestamptz not null default now()
);

alter table public.auvix_video_profiles enable row level security;

drop policy if exists "Perfis visiveis para usuarios autenticados"
on public.auvix_video_profiles;

create policy "Perfis visiveis para usuarios autenticados"
on public.auvix_video_profiles
for select to authenticated
using (true);

drop policy if exists "Usuario cria proprio perfil"
on public.auvix_video_profiles;

create policy "Usuario cria proprio perfil"
on public.auvix_video_profiles
for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Usuario atualiza proprio perfil"
on public.auvix_video_profiles;

create policy "Usuario atualiza proprio perfil"
on public.auvix_video_profiles
for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

grant select, insert, update
on public.auvix_video_profiles to authenticated;

-- Sincronizar o nome do cadastro com o perfil publico
create or replace function public.auvix_sync_video_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.auvix_video_profiles (
    user_id,
    display_name,
    avatar_index,
    updated_at
  )
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data->>'full_name'), ''),
      'Investidor AUVIX'
    ),
    0,
    now()
  )
  on conflict (user_id) do update
  set display_name = excluded.display_name,
      updated_at = now();

  return new;
end;
$$;

drop trigger if exists auvix_sync_video_profile_trigger
on auth.users;

create trigger auvix_sync_video_profile_trigger
after insert or update of raw_user_meta_data
on auth.users
for each row
execute function public.auvix_sync_video_profile();

-- Criar perfis para contas existentes
insert into public.auvix_video_profiles (
  user_id,
  display_name,
  avatar_index
)
select
  id,
  coalesce(
    nullif(trim(raw_user_meta_data->>'full_name'), ''),
    'Investidor AUVIX'
  ),
  0
from auth.users
on conflict (user_id) do nothing;

-- 2. COMENTARIOS E RESPOSTAS
create table if not exists public.auvix_video_comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  video_id text not null
    check (char_length(video_id) between 1 and 100),
  parent_comment_id uuid
    references public.auvix_video_comments(id) on delete cascade,
  content text not null
    check (char_length(trim(content)) between 1 and 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists auvix_video_comments_video_idx
on public.auvix_video_comments(video_id, created_at);

create index if not exists auvix_video_comments_parent_idx
on public.auvix_video_comments(parent_comment_id);

alter table public.auvix_video_comments
enable row level security;

drop policy if exists "Usuarios autenticados leem comentarios"
on public.auvix_video_comments;

create policy "Usuarios autenticados leem comentarios"
on public.auvix_video_comments
for select to authenticated
using (true);

drop policy if exists "Usuario cria proprio comentario"
on public.auvix_video_comments;

create policy "Usuario cria proprio comentario"
on public.auvix_video_comments
for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Usuario edita proprio comentario"
on public.auvix_video_comments;

create policy "Usuario edita proprio comentario"
on public.auvix_video_comments
for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Usuario exclui proprio comentario"
on public.auvix_video_comments;

create policy "Usuario exclui proprio comentario"
on public.auvix_video_comments
for delete to authenticated
using (auth.uid() = user_id);

grant select, insert, update, delete
on public.auvix_video_comments to authenticated;

-- Impedir respostas vinculadas a outro video
create or replace function public.auvix_validate_video_comment_parent()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  parent_video_id text;
begin
  if new.parent_comment_id is not null then
    if new.parent_comment_id = new.id then
      raise exception 'Um comentario nao pode responder a si mesmo.';
    end if;

    select video_id
    into parent_video_id
    from public.auvix_video_comments
    where id = new.parent_comment_id;

    if parent_video_id is null or parent_video_id <> new.video_id then
      raise exception 'A resposta precisa pertencer ao mesmo video do comentario original.';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists auvix_validate_video_comment_parent_trigger
on public.auvix_video_comments;

create trigger auvix_validate_video_comment_parent_trigger
before insert or update of parent_comment_id, video_id
on public.auvix_video_comments
for each row
execute function public.auvix_validate_video_comment_parent();

-- 3. CURTIDAS NOS COMENTARIOS
create table if not exists public.auvix_video_comment_likes (
  user_id uuid not null references auth.users(id) on delete cascade,
  comment_id uuid not null
    references public.auvix_video_comments(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, comment_id)
);

alter table public.auvix_video_comment_likes
enable row level security;

drop policy if exists "Usuarios leem curtidas de comentarios"
on public.auvix_video_comment_likes;

create policy "Usuarios leem curtidas de comentarios"
on public.auvix_video_comment_likes
for select to authenticated
using (true);

drop policy if exists "Usuario curte comentarios"
on public.auvix_video_comment_likes;

create policy "Usuario curte comentarios"
on public.auvix_video_comment_likes
for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Usuario remove curtida de comentario"
on public.auvix_video_comment_likes;

create policy "Usuario remove curtida de comentario"
on public.auvix_video_comment_likes
for delete to authenticated
using (auth.uid() = user_id);

grant select, insert, delete
on public.auvix_video_comment_likes to authenticated;

-- 4. DENUNCIAS DE COMENTARIOS
create table if not exists public.auvix_video_comment_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_user_id uuid not null
    references auth.users(id) on delete cascade,
  comment_id uuid not null
    references public.auvix_video_comments(id) on delete cascade,
  reason text not null
    check (char_length(trim(reason)) between 3 and 500),
  created_at timestamptz not null default now(),
  status text not null default 'pending'
    check (status in ('pending', 'reviewed', 'resolved'))
);

alter table public.auvix_video_comment_reports
enable row level security;

drop policy if exists "Usuario registra propria denuncia"
on public.auvix_video_comment_reports;

create policy "Usuario registra propria denuncia"
on public.auvix_video_comment_reports
for insert to authenticated
with check (auth.uid() = reporter_user_id);

drop policy if exists "Usuario consulta proprias denuncias"
on public.auvix_video_comment_reports;

create policy "Usuario consulta proprias denuncias"
on public.auvix_video_comment_reports
for select to authenticated
using (auth.uid() = reporter_user_id);

grant select, insert
on public.auvix_video_comment_reports to authenticated;

-- ==========================================
-- FIM DA CONFIGURACAO
-- ==========================================
