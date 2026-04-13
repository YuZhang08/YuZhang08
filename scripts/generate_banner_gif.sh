#!/bin/zsh
set -euo pipefail

ROOT="/Users/yuzhang/YuZhang08"
ASSETS="$ROOT/assets"
SOURCE="$ASSETS/banner.svg"
TMPDIR="$(mktemp -d /tmp/yuzhang-banner.XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT

typeset -a title_top=("#6D28D9" "#6D28D9" "#7C3AED" "#7C3AED" "#7C3AED" "#7C3AED" "#7C3AED" "#7C3AED" "#7C3AED" "#7C3AED" "#6D28D9" "#6D28D9" "#6D28D9" "#7C3AED" "#6D28D9" "#7C3AED")
typeset -a title_bottom=("#E9D5FF" "#F3E8FF" "#F5EFFF" "#F3E8FF" "#E9D5FF" "#F3E8FF" "#F5EFFF" "#F3E8FF" "#E9D5FF" "#F3E8FF" "#F5EFFF" "#F3E8FF" "#E9D5FF" "#F3E8FF" "#F5EFFF" "#F3E8FF")
typeset -a subtitle_top=("#7C3AED" "#7C3AED" "#8B5CF6" "#8B5CF6" "#7C3AED" "#7C3AED" "#8B5CF6" "#8B5CF6" "#7C3AED" "#7C3AED" "#8B5CF6" "#8B5CF6" "#7C3AED" "#7C3AED" "#8B5CF6" "#8B5CF6")
typeset -a subtitle_bottom=("#F5EFFF" "#F3E8FF" "#E9D5FF" "#F3E8FF" "#F5EFFF" "#F3E8FF" "#E9D5FF" "#F3E8FF" "#F5EFFF" "#F3E8FF" "#E9D5FF" "#F3E8FF" "#F5EFFF" "#F3E8FF" "#E9D5FF" "#F3E8FF")
typeset -a title_glow=("0.08" "0.16" "0.24" "0.34" "0.46" "0.56" "0.66" "0.74" "0.82" "0.88" "0.92" "0.88" "0.82" "0.86" "0.92" "0.88")
typeset -a title_body=("0.05" "0.10" "0.18" "0.28" "0.40" "0.52" "0.66" "0.78" "0.88" "0.95" "1.00" "0.98" "0.96" "0.98" "1.00" "0.98")
typeset -a subtitle_glow=("0.00" "0.00" "0.00" "0.08" "0.14" "0.22" "0.32" "0.42" "0.54" "0.64" "0.72" "0.68" "0.62" "0.66" "0.72" "0.68")
typeset -a subtitle_body=("0.00" "0.00" "0.00" "0.06" "0.12" "0.20" "0.30" "0.42" "0.58" "0.74" "0.90" "0.96" "1.00" "0.98" "1.00" "0.98")
typeset -a title_w=("0" "90" "170" "250" "330" "420" "520" "610" "700" "780" "820" "820" "820" "820" "820" "820")
typeset -a subtitle_w=("0" "0" "0" "0" "80" "140" "210" "280" "350" "410" "450" "450" "450" "450" "450" "450")
typeset -a caption_w=("0" "0" "0" "0" "0" "0" "110" "190" "270" "340" "420" "420" "420" "420" "420" "420")

bg_prefix="$TMPDIR/banner_bg_prefix.svg"
sed '/<text x="600" y="150"/,$d' "$SOURCE" > "$bg_prefix"

for i in {1..16}; do
  idx=$((i - 1))
  frame_svg="$TMPDIR/frame_$(printf '%02d' "$idx").svg"
  frame_png="$TMPDIR/frame_$(printf '%02d' "$idx").png"

  cat "$bg_prefix" > "$frame_svg"
  cat >> "$frame_svg" <<EOF
  <defs>
    <linearGradient id="frameTitleGradient" x1="0" y1="110" x2="0" y2="162" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="${title_top[$i]}"/>
      <stop offset="100%" stop-color="${title_bottom[$i]}"/>
    </linearGradient>
    <linearGradient id="frameSubtitleGradient" x1="0" y1="183" x2="0" y2="212" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="${subtitle_top[$i]}"/>
      <stop offset="100%" stop-color="${subtitle_bottom[$i]}"/>
    </linearGradient>
    <clipPath id="titleReveal">
      <rect x="190" y="96" width="${title_w[$i]}" height="72" rx="2"/>
    </clipPath>
    <clipPath id="subtitleReveal">
      <rect x="404" y="176" width="${subtitle_w[$i]}" height="36" rx="2"/>
    </clipPath>
    <clipPath id="captionReveal">
      <rect x="408" y="221" width="${caption_w[$i]}" height="24" rx="2"/>
    </clipPath>
  </defs>

  <g clip-path="url(#titleReveal)">
    <text x="600" y="150" text-anchor="middle" class="title-glow" opacity="${title_glow[$i]}" fill="url(#frameTitleGradient)" filter="url(#textGlowStrong)">Hey there, I'm Yu Zhang</text>
    <text x="600" y="150" text-anchor="middle" class="title" opacity="${title_body[$i]}" fill="url(#frameTitleGradient)" stroke="rgba(245, 239, 255, 0.35)" stroke-width="0.7">Hey there, I'm Yu Zhang</text>
  </g>

  <g clip-path="url(#subtitleReveal)">
    <text x="600" y="202" text-anchor="middle" class="subtitle-glow" opacity="${subtitle_glow[$i]}" fill="url(#frameSubtitleGradient)" filter="url(#textGlow)">CS &amp; Linguistics @ UCLA</text>
    <text x="600" y="202" text-anchor="middle" class="subtitle" opacity="${subtitle_body[$i]}" fill="url(#frameSubtitleGradient)" stroke="rgba(243, 232, 255, 0.28)" stroke-width="0.45">CS &amp; Linguistics @ UCLA</text>
  </g>

  <g clip-path="url(#captionReveal)" opacity="${subtitle_body[$i]}">
    <text x="600" y="238" text-anchor="middle" class="caption">Exploring AI &amp; building real-world apps</text>
  </g>
</svg>
EOF

  rsvg-convert -w 1200 -h 320 "$frame_svg" -o "$frame_png" >/dev/null
done

magick -delay 7 -loop 0 "$TMPDIR"/frame_*.png -layers Optimize "$ASSETS/banner.gif"
echo "Generated $ASSETS/banner.gif"
