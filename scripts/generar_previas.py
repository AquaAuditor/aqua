"""
Genera una mini-página estática por cada entrada del blog en `p/<id>.html`.

Discord, X, WhatsApp, etc. leen la vista previa de un enlace SIN ejecutar JavaScript,
así que necesitan una página que ya traiga el título, la descripción y la imagen
escritos en el HTML. Esta mini-página solo contiene esas etiquetas (Open Graph) y
redirige de inmediato a post.html?id=<id>, que es la página real.

Lo ejecuta GitHub Actions automáticamente (ver .github/workflows/pages.yml).
También se puede correr a mano:  python scripts/generar_previas.py
"""
import html
import json
import os
import re
import shutil
import sys
import urllib.request

SUPABASE_URL = "https://dolhldpxkkkyqfqkerbg.supabase.co"
SUPABASE_ANON_KEY = (
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvbGhsZHB4a2treXFmcWtlcmJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkwODE4ODQsImV4cCI6MjEwNDY1Nzg4NH0."
    "kqVg2n8T1p2smpck1uJLQLW07V5s71pidn4SJGaZbSk"
)
SITE_URL = "https://aquaauditor.github.io/aqua"   # sin barra final
SITE_NAME = "Aqua Auditore"

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "p")


def fetch_posts():
    req = urllib.request.Request(
        f"{SUPABASE_URL}/rest/v1/posts?select=id,section,title,body,date,game,image&order=date.desc",
        headers={"apikey": SUPABASE_ANON_KEY, "Authorization": f"Bearer {SUPABASE_ANON_KEY}"},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


def short_description(body, limit=180):
    text = re.sub(r"\s+", " ", (body or "")).strip()
    if len(text) <= limit:
        return text
    return text[:limit].rsplit(" ", 1)[0] + "…"


def og_image_for(post):
    """Devuelve la URL absoluta de la imagen para la vista previa."""
    img = post.get("image") or ""
    if img.startswith("http"):
        return img                                        # ya está en Supabase Storage
    if img.startswith("data:image/"):
        # Foto antigua guardada dentro de la base de datos: la escribimos como archivo.
        import base64
        header, b64 = img.split(",", 1)
        ext = "png" if "png" in header else "jpg"
        name = f"{post['id']}.{ext}"
        with open(os.path.join(OUT_DIR, name), "wb") as f:
            f.write(base64.b64decode(b64))
        return f"{SITE_URL}/p/{name}"
    return f"{SITE_URL}/og-logo.jpg"


TEMPLATE = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>{title} — {site}</title>
<meta name="description" content="{desc}">
<link rel="icon" type="image/png" href="../favicon.png">
<link rel="canonical" href="{site_url}/post.html?id={id}">
<meta property="og:site_name" content="{site}">
<meta property="og:type" content="article">
<meta property="og:title" content="{title}">
<meta property="og:description" content="{desc}">
<meta property="og:image" content="{image}">
<meta property="og:url" content="{site_url}/p/{id}.html">
<meta name="twitter:card" content="{card}">
<meta name="twitter:title" content="{title}">
<meta name="twitter:description" content="{desc}">
<meta name="twitter:image" content="{image}">
<meta http-equiv="refresh" content="0; url=../post.html?id={id}">
<script>location.replace('../post.html?id={id}');</script>
<style>body{{background:#070C12;color:#7C9AA0;font-family:sans-serif;padding:40px;text-align:center}}a{{color:#4FD9E0}}</style>
</head>
<body>
<p>Abriendo la entrada… <a href="../post.html?id={id}">Pulsa aquí si no carga.</a></p>
</body>
</html>
"""


def main():
    posts = fetch_posts()
    if os.path.isdir(OUT_DIR):
        shutil.rmtree(OUT_DIR)
    os.makedirs(OUT_DIR)

    for p in posts:
        image = og_image_for(p)
        page = TEMPLATE.format(
            id=p["id"],
            site=SITE_NAME,
            site_url=SITE_URL,
            title=html.escape(p.get("title") or "Entrada"),
            desc=html.escape(short_description(p.get("body"))),
            image=html.escape(image),
            card="summary_large_image" if image != f"{SITE_URL}/og-logo.jpg" else "summary",
        )
        with open(os.path.join(OUT_DIR, f"{p['id']}.html"), "w", encoding="utf-8") as f:
            f.write(page)

    print(f"Generadas {len(posts)} vistas previas en {OUT_DIR}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # que el error se vea claro en el log de GitHub
        print("ERROR generando vistas previas:", e, file=sys.stderr)
        sys.exit(1)
