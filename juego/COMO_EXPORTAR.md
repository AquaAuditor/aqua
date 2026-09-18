# Cómo poner "Ecos del Abismo" jugable en la web

Esta carpeta (`juego/`) es donde va la exportación web del juego. Cuando aquí exista
`index.html`, el botón **"Jugar en el navegador"** aparece solo en la página del juego.

## Solo la primera vez: instalar las plantillas de exportación

1. Abre Godot 4.7.
2. Menú **Editor → Administrar plantillas de exportación** (Manage Export Templates).
3. Pulsa **Descargar e instalar** (~1 GB, tarda unos minutos).

## Cada vez que quieras subir una versión nueva

1. Abre el proyecto `ecos-del-abismo` en Godot.
2. Menú **Proyecto → Exportar…** (Project → Export).
3. Si no existe, pulsa **Añadir…** y elige **Web**.
4. En el preset Web, pestaña *Opciones* (Options):
   - **Variant → Thread Support: DESACTIVADO** ← imprescindible. GitHub Pages no soporta
     el modo con hilos; si lo dejas activado el juego se queda en pantalla negra.
   - Todo lo demás puede quedarse como está.
5. Pulsa **Exportar proyecto…** (Export Project), NO "Exportar PCK/ZIP".
   - Carpeta: `Escritorio\New folder\juego\`
   - Nombre de archivo: `index.html`
   - Desmarca *Exportar con depuración* (Export With Debug).
6. Deberías ver en esta carpeta: `index.html`, `index.js`, `index.wasm`, `index.pck`,
   `index.audio.worklet.js`, `index.icon.png` y algún archivo más.
7. Súbelo al sitio desde la terminal (dentro de `New folder`):

       git add -A
       git commit -m "Nueva versión jugable"
       git push

   La primera vez el push tarda más (unos 40 MB). En 1–2 minutos el botón aparece en
   https://aquaauditor.github.io/aqua/juego.html

## Notas

- La partida se guarda en el navegador de cada jugador (no en tu servidor).
- Cada versión que subes ocupa ~15–20 MB en el historial de GitHub; sube versiones en hitos
  (nueva zona, nuevo jefe), no cada pequeño cambio.
- Si el juego carga pero se ve borroso, en Godot: Proyecto → Configuración →
  Rendering → Textures → Default Texture Filter = Nearest (ya lo tienes así).
