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
MARKER="$CATALOG/.fetched-v2"

if [ -f "$MARKER" ]; then
  echo "Figma assets already present - skipping download."
  exit 0
fi

# Clear any partial/corrupt state from earlier runs (this also removes the
# files that caused 'Distill failed' asset-catalog errors).
rm -rf "$CATALOG"
mkdir -p "$CATALOG"

cat > "$CATALOG/Contents.json" <<'EOF'
{
  "info" : { "author" : "xcode", "version" : 1 }
}
EOF

FAILED=0

fetch_png() { # name url scale(2|3)
  local name="$1" url="$2" scale="$3" dir="$CATALOG/$1.imageset"
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
fetch_png NavbarBackground    "$A/8b052295-c80c-4eda-82e3-f8e91af64f10" 3  # 213:8957
fetch_png TabIconHome         "$A/e37003ec-1114-4efe-b6e5-86529893fd90" 2  # 213:8963
fetch_png TabIconTutorials    "$A/c8ec0d1f-a87f-40e9-808a-90c991e4347b" 2  # 213:9004
fetch_png TabIconTracker      "$A/cc0197bd-8adb-4a5c-92f3-804f2aa5ddb4" 2  # 213:9019
fetch_png TabIconSettings     "$A/c28ac03b-9265-4150-baaf-55c86f193e7b" 2  # 213:9041
fetch_png HudCoin             "$A/f53356df-ae7c-4a7b-bfce-2bb6f570a975" 2  # 92:1516
fetch_png HudHeart            "$A/afb5e0bb-79c9-43dd-a3ba-5cafccb0e8de" 2  # 92:1541
fetch_png HudAmphora          "$A/267db80a-5997-4d04-92e7-ef63dc2d0206" 2  # 92:1548
fetch_png HudProfile          "$A/885dd4d7-8a7c-42ce-ac24-9068e4edcfc7" 2  # 191:2445 avatar figure

# ---- Splash (node 479:5053) ----
fetch_png SplashMain          "$A/7edfe3b3-93ed-440f-afa4-f2cd8201e6c7" 2  # 645:18557
fetch_png SplashEllipseOuter  "$A/3cdcbdd0-abc0-4005-be4d-44dcb408e54f" 2  # 585:2794
fetch_png SplashEllipseMid    "$A/ae7096e0-c2e8-4b10-8422-b65771bb1947" 2  # 585:2792
fetch_png SplashEllipseInner  "$A/b70ab9f6-e1d1-4cdb-9c28-8aee21a3c7f3" 2  # 585:2793
fetch_png SplashEllipseCore   "$A/4f44a77e-5975-49b3-92f4-a428ac89219f" 2  # 585:2795
fetch_png SplashLaurel        "$A/3b19d41f-cfb2-4cd3-8101-e0e369b560c1" 2  # 595:4604

# ---- Auth (B000 section) ----
fetch_png AuthIllustrationSignIn "$A/e90c3f3b-98b0-40fa-b550-fca8e6284685" 3  # 607:7549
fetch_png IconGoogle          "$A/bb6ee0a9-cfd9-40b7-96e4-77934955b114" 2
fetch_png IconApple           "$A/921fa7ac-444b-4de2-834d-482c60701f1f" 2
fetch_png IconBack            "$A/3585953e-8f63-4c6d-bdb1-cd44d9be491f" 2
fetch_png IconClose           "$A/53af4f5a-b181-4749-93e8-6bb89875d171" 2

# ---- Contextual tutorial (C000 section) ----
fetch_png TutorialWelcome     "$A/ec5838d0-1723-4732-9ce4-95134da42af0" 3  # 525:1641
fetch_png TutorialCoins       "$A/ebd08120-eb4b-4587-bcc7-4ca3e154c2a5" 3  # 525:1645
fetch_png IconChevronsRight   "$A/e368737d-e8df-4e83-a7a5-1ba0aef903fe" 2
fetch_png IconChevronLeft     "$A/f39d2af1-2bbb-410c-8b2d-50cbb27f61d2" 2
fetch_png IconChevronRight    "$A/b3f2a7de-c8a0-41d0-b35d-c3eddc050929" 2

# ---- Create Avatar ----
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
