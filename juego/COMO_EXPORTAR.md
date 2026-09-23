# Cómo poner un juego jugable en la web

Cada juego tiene su propia carpeta aquí dentro, con el mismo nombre que la
"carpeta de la versión jugable" que pusiste en el panel (Ajustes → Mis videojuegos).

    juego/
      ecos-del-abismo/    ← Ecos del Abismo
      mahou-shoujo/       ← Mahou Shoujo Stars Bullet

Cuando una carpeta tiene su `index.html`, el botón **"Jugar en el navegador"**
aparece solo en la página de ese juego.

## Solo la primera vez (por instalación de Godot): plantillas de exportación

1. Abre Godot.
2. **Editor → Administrar plantillas de exportación** (Manage Export Templates).
3. Marca **Web** (y **Common → ICU Data**) y pulsa **Install Selected Templates**.

Ojo: las plantillas son por versión de Godot. Si un juego usa 4.3 y otro 4.7,
cada versión necesita las suyas.

## Cada vez que quieras subir una versión nueva

1. Abre el proyecto en Godot.
2. **Proyecto → Exportar…**; si no existe, **Añadir… → Web**.
3. En el preset Web, pestaña *Opciones*:
   - **Variant → Thread Support: DESACTIVADO** ← imprescindible. GitHub Pages no
     soporta el modo con hilos; si lo dejas activado el juego se queda en negro.
4. **Exportar proyecto…** (NO "Exportar PCK/ZIP"):
   - Carpeta: `Escritorio\New folder\juego\<carpeta-del-juego>\`
   - Nombre de archivo: `index.html`
   - Desmarca *Exportar con depuración*.
5. Súbelo desde la terminal, dentro de `New folder`:

       git add -A
       git commit -m "Nueva version jugable de <juego>"
       git push

## Notas

- La partida de cada jugador se guarda en su propio navegador.
- Cada versión ocupa espacio en el historial de GitHub; sube versiones en hitos
  (nueva zona, nuevo jefe), no cada cambio pequeño.
- `juego/index.html` es solo una redirección para que sigan funcionando los
  enlaces antiguos de Ecos del Abismo. No lo borres.
