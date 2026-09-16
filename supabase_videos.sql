-- Ejecuta esto UNA VEZ en Supabase: Dashboard > SQL Editor > New query > Run
-- Crea la tabla donde se guardan los videos de YouTube de la página videos.html.

create table if not exists public.videos (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  url         text not null,          -- link completo que pegaste
  video_id    text not null,          -- ID de YouTube (11 caracteres), se calcula solo
  game        text,                   -- destiny / minecraft / genshin / zzz / hsr
  date        date not null default current_date,
  description text,
  created_at  timestamptz not null default now()
);

alter table public.videos enable row level security;

-- Cualquiera puede VER los videos
drop policy if exists "videos lectura publica" on public.videos;
create policy "videos lectura publica"
  on public.videos for select
  using (true);

-- Solo usuarios con sesión iniciada pueden crear / editar / borrar
drop policy if exists "videos escritura autenticados" on public.videos;
create policy "videos escritura autenticados"
  on public.videos for all
  to authenticated
  using (true)
  with check (true);
