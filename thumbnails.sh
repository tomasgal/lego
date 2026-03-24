#!/bin/bash
set -euo pipefail

src="/nas/lego"
dst="/var/www/lego/thumbs"
mkdir -p "$dst"

find "$src" -maxdepth 1 -type f -iname '*.pdf' -print0 |
while IFS= read -r -d '' pdf; do
name="$(basename "$pdf")"
stem="${name%.*}"
out="$dst/$stem.png"

if [ -f "$out" ]; then
echo "SKIP $name"
continue
fi

tmpdir="$(mktemp -d)"
echo "MAKE $name"

pdftoppm -png -f 1 -l 4 -r 60 "$pdf" "$tmpdir/page">/dev/null 2>&1

if ls "$tmpdir"/page-*.png>/dev/null 2>&1; then
montage "$tmpdir"/page-*.png \
-tile 2x2 \
-geometry 220x220+2+2 \
"$out"
else
echo "FAIL $name (no rendered pages)"
fi

rm -rf "$tmpdir"
done