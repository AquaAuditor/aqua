-- Ejecuta esto UNA VEZ en Supabase: Dashboard > SQL Editor > New query > Run
-- Permite la categoría "ia" (Desarrollo IA) en la tabla de entradas.

alter table public.posts drop constraint if exists posts_section_check;

alter table public.posts
  add constraint posts_section_check
  check (section in ('diario', 'pensamiento', 'ia'));
