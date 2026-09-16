-- Ejecuta esto UNA VEZ en Supabase: Dashboard > SQL Editor > New query > Run
-- Crea la tabla donde se guarda el contenido editable de Inicio, Sobre mí, logo y redes.

create table if not exists public.site_content (
  key        text primary key,
  value      text,
  updated_at timestamptz not null default now()
);

alter table public.site_content enable row level security;

-- Cualquiera puede LEER (así index.html muestra el contenido sin iniciar sesión)
drop policy if exists "site_content lectura publica" on public.site_content;
create policy "site_content lectura publica"
  on public.site_content for select
  using (true);

-- Solo usuarios con sesión iniciada pueden crear / editar / borrar
drop policy if exists "site_content escritura autenticados" on public.site_content;
create policy "site_content escritura autenticados"
  on public.site_content for all
  to authenticated
  using (true)
  with check (true);

-- Mantiene updated_at al día automáticamente
create or replace function public.site_content_touch()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists site_content_touch on public.site_content;
create trigger site_content_touch
  before update on public.site_content
  for each row execute function public.site_content_touch();
