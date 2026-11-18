-- Controle para distinguir avatar padrão de escolha confirmada.
alter table public.auvix_video_profiles
  add column if not exists avatar_customized boolean not null default false;

create table if not exists public.auvix_community_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null check (char_length(trim(content)) between 1 and 3000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.auvix_community_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.auvix_community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null check (char_length(trim(content)) between 1 and 2000),
  created_at timestamptz not null default now()
);

create table if not exists public.auvix_community_follows (
  follower_id uuid not null references auth.users(id) on delete cascade,
  following_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, following_id),
  check (follower_id <> following_id)
);

create table if not exists public.auvix_community_likes (
  post_id uuid not null references public.auvix_community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create index if not exists idx_auvix_community_likes_user
  on public.auvix_community_likes (user_id);

create index if not exists idx_auvix_community_posts_created
  on public.auvix_community_posts (created_at desc);

create index if not exists idx_auvix_community_posts_user
  on public.auvix_community_posts (user_id, created_at desc);

create index if not exists idx_auvix_community_comments_post
  on public.auvix_community_comments (post_id, created_at);

create index if not exists idx_auvix_community_follows_following
  on public.auvix_community_follows (following_id);

alter table public.auvix_community_posts enable row level security;
alter table public.auvix_community_comments enable row level security;
alter table public.auvix_community_follows enable row level security;
alter table public.auvix_community_likes enable row level security;

drop policy if exists "Comunidade leitura autenticada" on public.auvix_community_posts;
create policy "Comunidade leitura autenticada"
  on public.auvix_community_posts for select
  to authenticated using (true);

drop policy if exists "Usuario cria propria publicacao" on public.auvix_community_posts;
create policy "Usuario cria propria publicacao"
  on public.auvix_community_posts for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "Usuario edita propria publicacao" on public.auvix_community_posts;
create policy "Usuario edita propria publicacao"
  on public.auvix_community_posts for update
  to authenticated using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Usuario exclui propria publicacao" on public.auvix_community_posts;
create policy "Usuario exclui propria publicacao"
  on public.auvix_community_posts for delete
  to authenticated using (auth.uid() = user_id);

drop policy if exists "Comunidade comentarios leitura" on public.auvix_community_comments;
create policy "Comunidade comentarios leitura"
  on public.auvix_community_comments for select
  to authenticated using (true);

drop policy if exists "Usuario cria proprio comentario" on public.auvix_community_comments;
create policy "Usuario cria proprio comentario"
  on public.auvix_community_comments for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "Usuario exclui proprio comentario" on public.auvix_community_comments;
create policy "Usuario exclui proprio comentario"
  on public.auvix_community_comments for delete
  to authenticated using (auth.uid() = user_id);

drop policy if exists "Comunidade seguidores leitura" on public.auvix_community_follows;
create policy "Comunidade seguidores leitura"
  on public.auvix_community_follows for select
  to authenticated using (true);

drop policy if exists "Usuario segue por conta propria" on public.auvix_community_follows;
create policy "Usuario segue por conta propria"
  on public.auvix_community_follows for insert
  to authenticated with check (auth.uid() = follower_id);

drop policy if exists "Usuario deixa de seguir por conta propria" on public.auvix_community_follows;
create policy "Usuario deixa de seguir por conta propria"
  on public.auvix_community_follows for delete
  to authenticated using (auth.uid() = follower_id);

drop policy if exists "Curtidas leitura autenticada" on public.auvix_community_likes;
create policy "Curtidas leitura autenticada"
  on public.auvix_community_likes for select
  to authenticated using (true);

drop policy if exists "Usuario curte por conta propria" on public.auvix_community_likes;
create policy "Usuario curte por conta propria"
  on public.auvix_community_likes for insert
  to authenticated with check (auth.uid() = user_id);

drop policy if exists "Usuario remove propria curtida" on public.auvix_community_likes;
create policy "Usuario remove propria curtida"
  on public.auvix_community_likes for delete
  to authenticated using (auth.uid() = user_id);

-- Atualiza automaticamente a data de edição das publicações.

create or replace function public.auvix_set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_auvix_community_posts_updated_at
  on public.auvix_community_posts;

create trigger trg_auvix_community_posts_updated_at
before update on public.auvix_community_posts
for each row
execute function public.auvix_set_updated_at();

grant select, insert, update, delete
  on public.auvix_community_posts to authenticated;

grant select, insert, delete
  on public.auvix_community_comments to authenticated;

grant select, insert, delete
  on public.auvix_community_follows to authenticated;

grant select, insert, delete
  on public.auvix_community_likes to authenticated;
