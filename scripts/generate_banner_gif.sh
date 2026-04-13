#!/bin/zsh
set -euo pipefail

ROOT="/Users/yuzhang/YuZhang08"
ASSETS="$ROOT/assets"
SOURCE="$ASSETS/banner.svg"
TMPDIR="$(mktemp -d /tmp/yuzhang-banner.XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT

FPS=10
REVEAL_FRAMES=30
DELAY_FRAMES=20
HOLD_FRAMES=30
TOTAL_FRAMES=160

title_max_w=820
subtitle_max_w=450
caption_max_w=420

title_start=0
subtitle_start=$((REVEAL_FRAMES + DELAY_FRAMES))
caption_start=$((subtitle_start + REVEAL_FRAMES + DELAY_FRAMES))

calc_progress() {
  local frame=$1
  local start=$2
  local reveal=$3
  if (( frame < start )); then
    echo 0
  elif (( frame >= start + reveal )); then
    echo "$reveal"
  else
    echo $((frame - start + 1))
  fi
}

calc_width() {
  local progress=$1
  local maxw=$2
  local reveal=$3
  if (( progress <= 0 )); then
    echo 0
  elif (( progress >= reveal )); then
    echo "$maxw"
  else
    echo $((maxw * progress / reveal))
  fi
}

calc_opacity() {
  local progress=$1
  local reveal=$2
  local min=$3
  local max=$4
  if (( progress <= 0 )); then
    printf "0"
  elif (( progress >= reveal )); then
    printf "%s" "$max"
  else
    awk "BEGIN { printf \"%.2f\", $min + ($max - $min) * ($progress / $reveal) }"
  fi
}

bg_prefix="$TMPDIR/banner_bg_prefix.svg"
sed '/<text x="600" y="150"/,$d' "$SOURCE" > "$bg_prefix"

for ((idx = 0; idx < TOTAL_FRAMES; idx++)); do
  frame_svg="$TMPDIR/frame_$(printf '%02d' "$idx").svg"
  frame_png="$TMPDIR/frame_$(printf '%02d' "$idx").png"

  title_progress=$(calc_progress "$idx" "$title_start" "$REVEAL_FRAMES")
  subtitle_progress=$(calc_progress "$idx" "$subtitle_start" "$REVEAL_FRAMES")
  caption_progress=$(calc_progress "$idx" "$caption_start" "$REVEAL_FRAMES")

  title_w=$(calc_width "$title_progress" "$title_max_w" "$REVEAL_FRAMES")
  subtitle_w=$(calc_width "$subtitle_progress" "$subtitle_max_w" "$REVEAL_FRAMES")
  caption_w=$(calc_width "$caption_progress" "$caption_max_w" "$REVEAL_FRAMES")

  title_glow=$(calc_opacity "$title_progress" "$REVEAL_FRAMES" 0.00 0.72)
  title_body=$(calc_opacity "$title_progress" "$REVEAL_FRAMES" 0.00 1.00)
  subtitle_glow=$(calc_opacity "$subtitle_progress" "$REVEAL_FRAMES" 0.00 0.58)
  subtitle_body=$(calc_opacity "$subtitle_progress" "$REVEAL_FRAMES" 0.00 1.00)
  caption_body=$(calc_opacity "$caption_progress" "$REVEAL_FRAMES" 0.00 1.00)

  cat "$bg_prefix" > "$frame_svg"
  cat >> "$frame_svg" <<EOF
  <defs>
    <linearGradient id="frameTitleGradient" x1="0" y1="110" x2="0" y2="162" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#6D28D9"/>
      <stop offset="100%" stop-color="#F3E8FF"/>
    </linearGradient>
    <linearGradient id="frameSubtitleGradient" x1="0" y1="183" x2="0" y2="212" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#7C3AED"/>
      <stop offset="100%" stop-color="#F3E8FF"/>
    </linearGradient>
    <clipPath id="titleReveal">
      <rect x="190" y="96" width="$title_w" height="72" rx="2"/>
    </clipPath>
    <clipPath id="subtitleReveal">
      <rect x="404" y="176" width="$subtitle_w" height="36" rx="2"/>
    </clipPath>
    <clipPath id="captionReveal">
      <rect x="408" y="221" width="$caption_w" height="24" rx="2"/>
    </clipPath>
  </defs>

  <g clip-path="url(#titleReveal)">
    <text x="600" y="150" text-anchor="middle" class="title-glow" opacity="$title_glow" fill="url(#frameTitleGradient)" filter="url(#textGlowStrong)">Hey there, I'm Yu Zhang</text>
    <text x="600" y="150" text-anchor="middle" class="title" opacity="$title_body" fill="url(#frameTitleGradient)" stroke="rgba(245, 239, 255, 0.35)" stroke-width="0.7">Hey there, I'm Yu Zhang</text>
  </g>

  <g clip-path="url(#subtitleReveal)">
    <text x="600" y="202" text-anchor="middle" class="subtitle-glow" opacity="$subtitle_glow" fill="url(#frameSubtitleGradient)" filter="url(#textGlow)">CS &amp; Linguistics @ UCLA</text>
    <text x="600" y="202" text-anchor="middle" class="subtitle" opacity="$subtitle_body" fill="url(#frameSubtitleGradient)" stroke="rgba(243, 232, 255, 0.28)" stroke-width="0.45">CS &amp; Linguistics @ UCLA</text>
  </g>

  <g clip-path="url(#captionReveal)" opacity="$caption_body">
    <text x="600" y="238" text-anchor="middle" class="caption">Exploring AI &amp; building real-world apps</text>
  </g>
</svg>
EOF

  rsvg-convert -w 1200 -h 320 "$frame_svg" -o "$frame_png" >/dev/null
done

magick -delay 10 -loop 0 "$TMPDIR"/frame_*.png -layers Optimize "$ASSETS/banner.gif"
echo "Generated $ASSETS/banner.gif"
