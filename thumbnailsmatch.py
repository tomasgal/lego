#!/usr/bin/env python3
import os
import html
from urllib.parse import quote

pdf_dir = "/nas/lego"
thumb_dir = "/var/www/lego/thumbs"
out_file = "/var/www/lego/index.html"

files = []
for name in sorted(os.listdir(pdf_dir)):
    if name.lower().endswith(".pdf"):
        stem = name[:-4]
        thumb_path = os.path.join(thumb_dir, stem + ".png")
        if os.path.exists(thumb_path):
            files.append((name, stem))

with open(out_file, "w", encoding="utf-8") as f:
    f.write("""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>LEGO PDF Archive</title>
<style>
body { font-family: sans-serif; margin: 20px; background: #f5f5f5; }
h1 { margin-bottom: 20px; }
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 16px;
}
.card {
  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 10px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}
.card img {
  width: 100%;
  height: auto;
  display: block;
  border-radius: 4px;
  background: #eee;
}
.name {
  margin-top: 8px;
  font-size: 14px;
  word-break: break-word;
}
a {
  color: inherit;
  text-decoration: none;
}
a:hover .name {
  text-decoration: underline;
}
</style>
</head>
<body>
<h1>LEGO PDF Archive</h1>
<div class="grid">
""")
    for name, stem in files:
        q_pdf = quote(name)
        q_png = quote(stem + ".png")
        safe_name = html.escape(name)
        f.write(f'''<div class="card"><a href="/lego/pdf/{q_pdf}"><img src="/lego/thumbs/{q_png}" alt="{safe_name}"><div class="name">{safe_name}</div></a></div>\n''')
    f.write("""</div>
</body>
</html>
""")
