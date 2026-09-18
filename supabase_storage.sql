-- Ejecuta esto UNA VEZ en Supabase: Dashboard > SQL Editor > New query > Run
-- Crea el "bucket" (carpeta) donde se guardan las fotos del blog como archivos,
-- en lugar de dentro de la base de datos. Así el sitio carga más rápido.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('imagenes', 'imagenes', true, 5242880, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true;

-- Cualquiera puede VER las fotos (necesario para que se muestren en el sitio)
drop policy if exists "imagenes lectura publica" on storage.objects;
create policy "imagenes lectura publica"
  on storage.objects for select
  using (bucket_id = 'imagenes');

-- Solo usuarios con sesión iniciada pueden subir / reemplazar / borrar
drop policy if exists "imagenes subir autenticados" on storage.objects;
create policy "imagenes subir autenticados"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'imagenes');

drop policy if exists "imagenes actualizar autenticados" on storage.objects;
create policy "imagenes actualizar autenticados"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'imagenes');

drop policy if exists "imagenes borrar autenticados" on storage.objects;
create policy "imagenes borrar autenticados"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'imagenes');
