-- Ejecuta esto UNA VEZ en Supabase: Dashboard > SQL Editor > New query > Run
-- Permite tener VARIOS videojuegos en el blog, cada uno con su ficha, su versión
-- jugable y su propio devlog. Migra la ficha de "Ecos del Abismo" automáticamente.

-- 1) Tabla de juegos
create table if not exists public.juegos (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null,
  slug        text unique not null,          -- carpeta de la versión jugable: juego/<slug>/
  portada     text,
  motor       text,
  estado      text default 'Prototipo',
  progreso    int  default 0 check (progreso between 0 and 100),
  descripcion text,
  hecho       text,                          -- una cosa por línea
  pendiente   text,                          -- una cosa por línea
  url_jugar   text,                          -- si está vacío se usa juego/<slug>/index.html
  orden       int  default 0,                -- para ordenar las tarjetas
  created_at  timestamptz not null default now()
);

alter table public.juegos enable row level security;

drop policy if exists "juegos lectura publica" on public.juegos;
create policy "juegos lectura publica"
  on public.juegos for select using (true);

drop policy if exists "juegos escritura autenticados" on public.juegos;
create policy "juegos escritura autenticados"
  on public.juegos for all to authenticated using (true) with check (true);

-- 2) Cada avance del devlog pertenece a un juego
alter table public.posts add column if not exists juego_id uuid references public.juegos(id) on delete cascade;

-- 3) Migrar la ficha que ya tenías (guardada en site_content) al primer juego
insert into public.juegos (nombre, slug, portada, motor, estado, progreso, descripcion, hecho, pendiente, url_jugar, orden)
select
  coalesce(nullif((select value from public.site_content where key = 'juego_nombre'), ''), 'Ecos del Abismo'),
  'ecos-del-abismo',
  (select value from public.site_content where key = 'juego_portada'),
  coalesce(nullif((select value from public.site_content where key = 'juego_motor'), ''), 'Hecho en Godot 4'),
  coalesce(nullif((select value from public.site_content where key = 'juego_estado'), ''), 'Prototipo'),
  coalesce((select value from public.site_content where key = 'juego_progreso')::int, 0),
  (select value from public.site_content where key = 'juego_descripcion'),
  (select value from public.site_content where key = 'juego_hecho'),
  (select value from public.site_content where key = 'juego_pendiente'),
  null,                 -- usa juego/ecos-del-abismo/index.html
  0
where not exists (select 1 from public.juegos where slug = 'ecos-del-abismo');

-- 4) Los avances que ya existían pasan a ser de ese juego
update public.posts
   set juego_id = (select id from public.juegos where slug = 'ecos-del-abismo')
 where section = 'juego' and juego_id is null;

-- 5) Crear la ficha del segundo juego (se edita después desde el panel)
insert into public.juegos (nombre, slug, motor, estado, progreso, descripcion, orden)
select 'Mahou Shoujo Stars Bullet', 'mahou-shoujo', 'Hecho en Godot 4', 'Prototipo', 0,
       'Bullet-hell roguelite de 24 pisos: elige a tu chica mágica, esquiva, dispara y baja por la Grieta.', 1
where not exists (select 1 from public.juegos where slug = 'mahou-shoujo');
