#!/usr/bin/env bash
# Downloads the Figma design exports for Tiber into Assets.xcassets.
# Runs automatically as an Xcode build phase (or manually from the repo root).
#
# Every URL below is a tokenized export produced by the Figma MCP server from
# tiber-design-files (lAFwqzz4aSzXLvXrkG6AZF). They expire ~7 days after
# generation (2026-07-09). Each download is verified to be a real PNG before
# it is installed, so a bad response can never break the Xcode build.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CATALOG="$REPO_ROOT/ios/Tiber/Assets.xcassets/Figma"
MARKER="$CATALOG/.fetched-v3"

if [ -f "$MARKER" ]; then
  echo "Figma assets already present - skipping download."
  exit 0
fi

mkdir -p "$CATALOG"

if [ ! -f "$CATALOG/Contents.json" ]; then
  cat > "$CATALOG/Contents.json" <<'EOF'
{
  "info" : { "author" : "xcode", "version" : 1 }
}
EOF
fi

FAILED=0

fetch_png() { # name url scale(2|3)
  local name="$1" url="$2" scale="$3" dir="$CATALOG/$1.imageset"
  # Assets committed to the repo (or already downloaded) always win.
  if [ -f "$dir/Contents.json" ]; then
    echo "$name already present - skipping"
    return 0
  fi
  mkdir -p "$dir"
  local file="$dir/$name@${scale}x.png"
  if ! curl -fsSL --retry 2 -o "$file" "$url"; then
    echo "warning: could not download $name" >&2
    FAILED=1; rm -rf "$dir"; return 0
  fi
  # Verify PNG magic bytes; anything else (JSON error page, HTML) is discarded.
  if [ "$(head -c 4 "$file" | od -An -tx1 | tr -d ' \n')" != "89504e47" ]; then
    echo "warning: $name is not a valid PNG - discarded" >&2
    FAILED=1; rm -rf "$dir"; return 0
  fi
  local other="2x"; [ "$scale" = "2" ] && other="3x"
  cat > "$dir/Contents.json" <<EOF
{
  "images" : [
    { "idiom" : "universal", "scale" : "1x" },
    { "idiom" : "universal", "scale" : "$other" },
    { "filename" : "$name@${scale}x.png", "idiom" : "universal", "scale" : "${scale}x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
EOF
}

A="https://www.figma.com/api/mcp/asset"

# ---- Home (color option 01, node 92:1510) ----
fetch_png HomeMapIllustration "$A/74e33e85-c77a-4981-80e6-304556302cc5" 3  # 192:5343 full map
fetch_png HomeKnight          "$A/3b7c2d58-f3a3-43a3-aa92-16a5b2f7d5f9" 3  # 264:1148
fetch_png HomeColosseum      "$A/1f5cc97c-6f77-462d-92eb-45ff2fc881bd" 3  # 250:25579
fetch_png LevelBadgeBeginner "$A/dffb4add-ce51-4dc2-a973-2d1e605d3431" 3  # 192:43
fetch_png NavbarBackground    "$A/8b052295-c80c-4eda-82e3-f8e91af64f10" 3  # 213:8957
fetch_png TabIconHome          "$A/5c2c23fc-34e7-40e9-9e07-6843ea4f3031" 3
fetch_png TabIconLeaderboard "$A/d62eaf1b-f370-435b-9319-c2d304ff2ac8" 3  # 213:8987
fetch_png TabIconTutorials     "$A/9b95a703-ad87-48a6-9b8f-6598fb87588f" 3
fetch_png TabIconTracker       "$A/6df59373-c5fb-4baf-b485-9da66bca48b8" 3
fetch_png TabIconSettings      "$A/37674c12-91b9-4a86-a941-5c397828eac5" 3
fetch_png HudCoin              "$A/c6b3bc66-3e5b-4418-9b33-25674b142c0b" 3
fetch_png HudHeart             "$A/f5571337-e917-4c20-b714-f75c42a3971a" 3
fetch_png HudAmphora           "$A/6d0a018c-7824-4a00-b7ea-08b529abe2d6" 3
fetch_png HudProfile           "$A/87dad771-22f0-41cd-9048-23ce57f0fdc9" 3

# ---- Splash (node 479:5053) ----
fetch_png SplashMain          "$A/7edfe3b3-93ed-440f-afa4-f2cd8201e6c7" 2  # 645:18557
fetch_png SplashEllipseOuter   "$A/abeefa3d-10ab-4c3b-94ad-ff44d9145f6d" 3
fetch_png SplashEllipseMid     "$A/e5dc00fc-48c1-4e52-a496-43157438c9e0" 3
fetch_png SplashEllipseInner   "$A/f2c75373-b0c1-425b-8b01-2f4957b30d1d" 3
fetch_png SplashEllipseCore    "$A/0b0936db-07c0-4bd6-b9f9-d53c36dbf07d" 3

# ---- Auth (B000 section) ----
fetch_png AuthIllustrationSignIn "$A/e90c3f3b-98b0-40fa-b550-fca8e6284685" 3  # 607:7549
fetch_png AuthIllustrationSignUp  "$A/4f096334-42b0-4c36-933c-c428bdf94871" 3  # 479:5541
fetch_png AuthIllustrationConfirm "$A/0c9ddec9-5405-4a43-ab17-7f4e3f2a0cf0" 3  # 479:5539
fetch_png IconGoogle          "$A/bb6ee0a9-cfd9-40b7-96e4-77934955b114" 2
fetch_png IconApple           "$A/921fa7ac-444b-4de2-834d-482c60701f1f" 2

# ---- Contextual tutorial (C000 section) ----
fetch_png TutorialWelcome     "$A/ec5838d0-1723-4732-9ce4-95134da42af0" 3  # 525:1641
fetch_png TutorialCoins       "$A/ebd08120-eb4b-4587-bcc7-4ca3e154c2a5" 3  # 525:1645

fetch_png TutorialTribes     "$A/28521d24-7dc5-4772-b708-0fe1e068cd59" 3  # 673:13365
fetch_png TutorialOnline     "$A/2d313663-0841-4174-961a-3f84586c712c" 3  # 525:1649

# ---- Create Avatar ----
fetch_png ChipAppearance     "$A/b7c222b8-2e2f-46ee-8b81-bff6d915ef23" 3  # 128:144
fetch_png ChipClothing       "$A/1067f95e-0a81-4ac3-a69e-29d4767edc81" 3  # 128:184
fetch_png ChipInteractions   "$A/274d14f3-48b0-4fbf-848a-7cf9460abc1e" 3  # 128:206
fetch_png ChipUndo           "$A/97eb0032-4e0b-4c93-a250-bae18b87fa42" 3  # 128:260
fetch_png ChipRedo           "$A/bb0bc1d4-3d1c-48c2-bca0-0009cb897e8a" 3  # 128:264
fetch_png Hair01             "$A/10615c87-ac28-4f76-aeee-4c02bc177dd2" 3  # 232:10851
fetch_png Hair04             "$A/b5c57b70-ff9d-40d3-8366-6a57ef143728" 3  # 194:1981
fetch_png Hair05             "$A/edd9e308-6b5a-4b41-be93-50060419ab1b" 3  # 128:360
fetch_png Hair07             "$A/4401ebde-d9cf-49fe-9ba3-65c313315b85" 3  # 128:365
fetch_png Hair09             "$A/cc0bffa6-673d-4b5e-a41a-c7e32e6acd5b" 3  # 128:367
fetch_png Top02              "$A/e688e11f-2cf6-4c2c-93eb-0b62fc8ffbf8" 3  # 213:8325
fetch_png Top06              "$A/1ba77725-5bcf-4350-9b8a-100df3151cee" 3  # 213:8594
fetch_png Top08              "$A/f53039a3-1cba-44f5-9c46-a5bf7445ff24" 3  # 213:8598
fetch_png AvatarPreviewBust   "$A/12d44418-4c03-4317-b4f1-9a0b399e06fd" 3  # 213:6424
fetch_png AvatarPreviewBody   "$A/d5d03bf7-72bb-4bb0-b483-54e08db38622" 3  # 213:7578
fetch_png Hair02              "$A/7ef69d41-30ba-4723-972a-9493ea5b16bd" 3  # 232:10717
fetch_png Hair03              "$A/4a973f93-1b06-4205-b7ef-d11b00b63689" 3  # 128:355
fetch_png Hair06              "$A/971e3a84-eaed-4d1b-9404-f91f4f5a3f25" 3  # 128:362
fetch_png Hair08              "$A/a4277b66-7635-4ecc-beb8-0c97541238d0" 3  # 128:366
fetch_png Top01               "$A/bb98b05d-d19a-4346-a51b-af33398ed7b8" 3  # 213:8191
fetch_png Top03               "$A/528a62d9-7365-4c5a-85e2-f8fc97852a32" 3  # 213:8455
fetch_png Top04               "$A/483bc59f-a0b9-40b6-8a9a-309e41dfd646" 3  # 213:8590
fetch_png Top05               "$A/1c8da4f5-6c96-4807-8765-70364cc02772" 3  # 213:8592
fetch_png Top07               "$A/36265993-f810-4365-9830-5bb724d766b6" 3  # 213:8597
fetch_png Top09               "$A/8baf7d45-cd39-42eb-a357-a9c0e59c9a2c" 3  # 213:8599

echo
if [ "$FAILED" -eq 0 ]; then
  touch "$MARKER"
  echo "All Figma assets downloaded into $CATALOG"
else
  echo "warning: some assets failed to download (offline, or the export URLs" >&2
  echo "expired). The app falls back to built-in stand-ins for those." >&2
fi
exit 0
