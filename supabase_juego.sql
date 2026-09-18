-- Ejecuta esto UNA VEZ en Supabase: Dashboard > SQL Editor > New query > Run
-- Permite la categoría "juego" (avances del Videojuego en Desarrollo) en la tabla de entradas.
-- Incluye también "ia" por si aún no habías corrido supabase_ia.sql.

alter table public.posts drop constraint if exists posts_section_check;

alter table public.posts
  add constraint posts_section_check
  check (section in ('diario', 'pensamiento', 'ia', 'juego'));
