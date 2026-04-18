#!/bin/bash
set -uo pipefail

src="/nas/lego"
dst="/var/www/lego/thumbs"
mkdir -p "$dst"

find "$src" -maxdepth 1 -type f -iname '*.pdf' -print0 | sort -z |
while IFS= read -r -d '' pdf; do
    name="$(basename "$pdf")"
    stem="${name%.*}"
    out="$dst/$stem.png"

    # Preskoè iba vtedy, ak thumbnail existuje a je novší než PDF.
    if [ -f "$out" ] && [ "$out" -nt "$pdf" ]; then
        continue
    fi

    tmpdir="$(mktemp -d)"
    echo "MAKE  $name"

    if ! pdftoppm -png -f 1 -l 4 -r 60 "$pdf" "$tmpdir/page" >/dev/null 2>&1; then
        echo "FAIL  $name (pdftoppm error)" >&2
        rm -rf "$tmpdir"
        continue
    fi

    if ! ls "$tmpdir"/page-*.png >/dev/null 2>&1; then
        echo "FAIL  $name (no rendered pages)" >&2
        rm -rf "$tmpdir"
        continue
    fi

    if ! montage "$tmpdir"/page-*.png \
        -tile 2x2 \
        -geometry 220x220+2+2 \
        "$out" >/dev/null 2>&1; then
        echo "FAIL  $name (montage error)" >&2
        rm -rf "$tmpdir"
        continue
    fi

    rm -rf "$tmpdir"
done
