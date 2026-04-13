#!/bin/zsh
set -euo pipefail

ROOT="/Users/yuzhang/YuZhang08"
ASSETS="$ROOT/assets"
SOURCE="$ASSETS/banner.svg"
TMPDIR="$(mktemp -d /tmp/yuzhang-banner.XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT

typeset -a title_c1=("#FFF4FF" "#F7D9FF" "#F3C4FF" "#F7D9FF" "#FFF4FF" "#F7D9FF" "#F3C4FF" "#F7D9FF" "#FFF4FF" "#F7D9FF" "#F3C4FF" "#F7D9FF")
typeset -a title_c2=("#D8B4FE" "#C084FC" "#A855F7" "#C084FC" "#D8B4FE" "#C084FC" "#A855F7" "#C084FC" "#D8B4FE" "#C084FC" "#A855F7" "#C084FC")
typeset -a title_c3=("#9333EA" "#A855F7" "#7C3AED" "#A855F7" "#9333EA" "#A855F7" "#7C3AED" "#A855F7" "#9333EA" "#A855F7" "#7C3AED" "#A855F7")
typeset -a subtitle_c1=("#F7EEFF" "#EEDCFF" "#E9D5FF" "#F3E8FF" "#F7EEFF" "#EEDCFF" "#E9D5FF" "#F3E8FF" "#F7EEFF" "#EEDCFF" "#E9D5FF" "#F3E8FF")
typeset -a subtitle_c2=("#C084FC" "#A855F7" "#9333EA" "#A855F7" "#C084FC" "#A855F7" "#9333EA" "#A855F7" "#C084FC" "#A855F7" "#9333EA" "#A855F7")
typeset -a title_glow=("0.58" "0.72" "0.86" "0.68" "0.56" "0.7" "0.84" "0.66" "0.58" "0.72" "0.88" "0.7")
typeset -a subtitle_glow=("0.50" "0.63" "0.72" "0.6" "0.5" "0.63" "0.72" "0.6" "0.5" "0.63" "0.72" "0.6")
typeset -a title_body=("0.96" "0.99" "1.00" "0.98" "0.96" "0.99" "1.00" "0.98" "0.96" "0.99" "1.00" "0.98")
typeset -a subtitle_body=("0.95" "0.98" "1.00" "0.97" "0.95" "0.98" "1.00" "0.97" "0.95" "0.98" "1.00" "0.97")

for i in {1..12}; do
  idx=$((i - 1))
  frame_svg="$TMPDIR/frame_$(printf '%02d' "$idx").svg"
  frame_png="$TMPDIR/frame_$(printf '%02d' "$idx").png"

  perl -0pe '
    s/<animate[^>]*\/>\s*//g;
    s/#F5EFFF/'"${title_c1[$i]}"'/g;
    s/#C084FC/'"${title_c2[$i]}"'/g;
    s/#7C3AED/'"${title_c3[$i]}"'/g;
    s/#F3E8FF/'"${subtitle_c1[$i]}"'/g;
    s/#A855F7/'"${subtitle_c2[$i]}"'/g;
    s/opacity: 0\.72;/opacity: '"${title_glow[$i]}"';/;
    s/opacity: 0\.7;/opacity: '"${subtitle_glow[$i]}"';/;
    s/<text x="600" y="150" text-anchor="middle" class="title">Hey there, I'\''m Yu Zhang\s*<\/text>/<text x="600" y="150" text-anchor="middle" class="title" opacity="'"${title_body[$i]}"'">Hey there, I'\''m Yu Zhang<\/text>/s;
    s/<text x="600" y="202" text-anchor="middle" class="subtitle">CS &amp; Linguistics @ UCLA\s*<\/text>/<text x="600" y="202" text-anchor="middle" class="subtitle" opacity="'"${subtitle_body[$i]}"'">CS &amp; Linguistics @ UCLA<\/text>/s;
  ' "$SOURCE" > "$frame_svg"

  rsvg-convert -w 1200 -h 320 "$frame_svg" -o "$frame_png" >/dev/null
done

magick -delay 9 -loop 0 "$TMPDIR"/frame_*.png -layers Optimize "$ASSETS/banner.gif"
echo "Generated $ASSETS/banner.gif"
