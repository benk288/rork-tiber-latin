#!/usr/bin/env bash
# Downloads the Figma design exports for Tiber into Assets.xcassets.
#
# Run from the repo root on any machine with access to figma.com:
#   ./scripts/fetch-figma-assets.sh
#
# The URLs are tokenized exports produced by the Figma MCP server from
# tiber-design-files (lAFwqzz4aSzXLvXrkG6AZF). They expire ~7 days after
# generation (2026-07-09); re-export from Figma if they have gone stale.

set -uo pipefail

# Resolve the repo root from this script's location so it works both from a
# terminal and as an Xcode build phase.
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CATALOG="$REPO_ROOT/ios/Tiber/Assets.xcassets/Figma"

# Already fetched? Skip so incremental builds stay fast.
if [ -f "$CATALOG/.fetched" ]; then
  echo "Figma assets already present - skipping download."
  exit 0
fi

FAILED=0
mkdir -p "$CATALOG"

# Contents.json for the Figma group folder
cat > "$CATALOG/Contents.json" <<'EOF'
{
  "info" : { "author" : "xcode", "version" : 1 },
  "properties" : { "provides-namespace" : false }
}
EOF

png3x() { # name url  -> single 3x PNG imageset
  local name="$1" url="$2" dir="$CATALOG/$1.imageset"
  mkdir -p "$dir"
  echo "fetching $name (png @3x)"
  if ! curl -fsSL -o "$dir/$name@3x.png" "$url"; then
    echo "warning: could not download $name" >&2
    FAILED=1
    rm -rf "$dir"
    return 0
  fi
  cat > "$dir/Contents.json" <<EOF
{
  "images" : [
    { "idiom" : "universal", "scale" : "1x" },
    { "idiom" : "universal", "scale" : "2x" },
    { "filename" : "$name@3x.png", "idiom" : "universal", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
EOF
}

png2x() { # name url -> single 2x PNG imageset
  local name="$1" url="$2" dir="$CATALOG/$1.imageset"
  mkdir -p "$dir"
  echo "fetching $name (png @2x)"
  if ! curl -fsSL -o "$dir/$name@2x.png" "$url"; then
    echo "warning: could not download $name" >&2
    FAILED=1
    rm -rf "$dir"
    return 0
  fi
  cat > "$dir/Contents.json" <<EOF
{
  "images" : [
    { "idiom" : "universal", "scale" : "1x" },
    { "filename" : "$name@2x.png", "idiom" : "universal", "scale" : "2x" },
    { "idiom" : "universal", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
EOF
}

svg() { # name url -> vector imageset
  local name="$1" url="$2" dir="$CATALOG/$1.imageset"
  mkdir -p "$dir"
  echo "fetching $name (svg)"
  if ! curl -fsSL -o "$dir/$name.svg" "$url"; then
    echo "warning: could not download $name" >&2
    FAILED=1
    rm -rf "$dir"
    return 0
  fi
  cat > "$dir/Contents.json" <<EOF
{
  "images" : [
    { "filename" : "$name.svg", "idiom" : "universal" }
  ],
  "info" : { "author" : "xcode", "version" : 1 },
  "properties" : { "preserves-vector-representation" : true }
}
EOF
}

A="https://www.figma.com/api/mcp/asset"

# ---- Home (color option 01, node 92:1510) ----
png3x HomeMapIllustration       "$A/74e33e85-c77a-4981-80e6-304556302cc5"   # 192:5343, 375x875
png3x HomeColosseum             "$A/9c9a2689-f2bc-4319-aa9a-5fdc05c393da"   # 250:25579
png3x HomeKnight                "$A/3b7c2d58-f3a3-43a3-aa92-16a5b2f7d5f9"   # 264:1148
png3x LevelBadgeBeginner        "$A/63ededa5-d80b-43bb-8605-9f78a0b3e33d"   # 192:43, 68x68
png3x NavbarBackground          "$A/8b052295-c80c-4eda-82e3-f8e91af64f10"   # 213:8957, 375x100
svg   TabIconHome               "$A/7fce3813-679b-4cc2-982a-39a3e63fa040"   # 213:8962
svg   TabIconLeaderboard        "$A/687ee0c6-68ca-44dc-af00-fc7fa53cdfbf"   # 213:8987
svg   TabIconTutorials          "$A/4fa36f3d-d737-47d5-8e4b-9cb6231afef6"   # 213:9002
svg   TabIconTracker            "$A/3ace9ca0-83bc-47a0-861d-b33d5bf41605"   # 213:9017
svg   TabIconSettings           "$A/8d58027c-0fa2-47eb-8e86-d5c227e294d7"   # 213:9039
svg   HudCoin                   "$A/8a7df223-56ee-40b0-897e-b74772cc84d0"   # 92:1515
svg   HudHeart                  "$A/b5702011-b204-41d5-8c71-7e6717d81f53"   # 92:1540
svg   HudAmphora                "$A/8f938c6d-74df-47fe-b60e-6eae56cca2ff"   # 92:1547
png3x HudProfile                "$A/9cb74d28-d7e8-476e-85ad-21fce4df3e64"   # 176:4901, 44x44

# ---- Splash (node 479:5053) ----
png2x SplashMain                "$A/7edfe3b3-93ed-440f-afa4-f2cd8201e6c7"   # 645:18557, 948x927
png3x SplashEllipseOuter        "$A/9b142a68-48aa-4ed7-93bf-f709a4db879b"   # 585:2794
png3x SplashEllipseMid          "$A/ae7096e0-c2e8-4b10-8422-b65771bb1947"   # 585:2792
png3x SplashEllipseInner        "$A/b70ab9f6-e1d1-4cdb-9c28-8aee21a3c7f3"   # 585:2793
png3x SplashEllipseCore         "$A/4f44a77e-5975-49b3-92f4-a428ac89219f"   # 585:2795
png3x SplashLaurel              "$A/3b19d41f-cfb2-4cd3-8101-e0e369b560c1"   # 595:4604, 160x72.85

# ---- Auth (B000 section) ----
png3x AuthIllustrationSignIn    "$A/e90c3f3b-98b0-40fa-b550-fca8e6284685"   # 607:7549, 375x302
png3x AuthIllustrationSignUp    "$A/32bb3dc1-e90d-4f76-a5f5-b9d8e3d04da0"   # 479:5541, 375x302
png3x AuthIllustrationConfirm   "$A/73098cd9-cca7-4df2-9390-92e4cb074d14"   # 479:5539, 375x302
png3x IconGoogle                "$A/bb6ee0a9-cfd9-40b7-96e4-77934955b114"   # google logo, 17x17
png3x IconApple                 "$A/921fa7ac-444b-4de2-834d-482c60701f1f"   # apple logo, 18x18
svg   IconBack                  "$A/3585953e-8f63-4c6d-bdb1-cd44d9be491f"   # header back arrow, 24
svg   IconClose                 "$A/53af4f5a-b181-4749-93e8-6bb89875d171"   # header close X, 24

# ---- Contextual tutorial (C000 section) ----
png3x TutorialWelcome           "$A/ec5838d0-1723-4732-9ce4-95134da42af0"   # 525:1641, 375x302
png3x TutorialCoins             "$A/ebd08120-eb4b-4587-bcc7-4ca3e154c2a5"   # 525:1645
png3x TutorialTribes            "$A/60820d97-fe39-423a-833d-0825cfa6a530"   # 673:13365
png3x TutorialOnline            "$A/ee1316dd-1f91-4f11-bd77-b62defad8963"   # 525:1649
svg   IconChevronsRight         "$A/e368737d-e8df-4e83-a7a5-1ba0aef903fe"   # skip >> icon, 20
svg   IconChevronLeft           "$A/f39d2af1-2bbb-410c-8b2d-50cbb27f61d2"   # prev chevron, 20
svg   IconChevronRight          "$A/b3f2a7de-c8a0-41d0-b35d-c3eddc050929"   # next chevron, 20

# ---- Create Avatar ----
png3x AvatarPreviewBust         "$A/12d44418-4c03-4317-b4f1-9a0b399e06fd"   # 213:6424
png3x AvatarPreviewBody         "$A/d5d03bf7-72bb-4bb0-b483-54e08db38622"   # 213:7578
svg   ChipAppearance            "$A/07a59712-7454-4923-a8ca-3ba64173ff36"   # 128:144
svg   ChipClothing              "$A/7f911d75-4250-4f23-9e94-9de3c3e59a42"   # 128:184
svg   ChipInteractions          "$A/8a44f49f-02f9-449d-aca0-afa59c5d9be4"   # 128:206
svg   ChipUndo                  "$A/bbe749c5-5482-4301-82f3-9020e00f59dc"   # 128:260
svg   ChipRedo                  "$A/a5b734b0-3a94-47b8-a75a-4d7950ec5674"   # 128:264
png3x Hair01                    "$A/3137cce4-e49e-4b91-8270-d798b7939834"   # 232:10851
png3x Hair02                    "$A/7ef69d41-30ba-4723-972a-9493ea5b16bd"   # 232:10717
png3x Hair03                    "$A/4a973f93-1b06-4205-b7ef-d11b00b63689"   # 128:355
png3x Hair04                    "$A/2e13a875-8656-40bc-bdd1-cc7390d54796"   # 194:1981
png3x Hair05                    "$A/0d4f8f60-4426-41f4-bc67-d2586edd08d6"   # 128:360
png3x Hair06                    "$A/971e3a84-eaed-4d1b-9404-f91f4f5a3f25"   # 128:362
png3x Hair07                    "$A/fabd24cf-e262-4485-8dd7-cd9704775ac5"   # 128:365
png3x Hair08                    "$A/a4277b66-7635-4ecc-beb8-0c97541238d0"   # 128:366
png3x Hair09                    "$A/2531d94c-fb3c-472b-b646-4e24d82d647f"   # 128:367
png3x Top01                     "$A/bb98b05d-d19a-4346-a51b-af33398ed7b8"   # 213:8191
png3x Top02                     "$A/a6cd5cea-2259-479a-8e31-5746cfd8c0b9"   # 213:8325
png3x Top03                     "$A/528a62d9-7365-4c5a-85e2-f8fc97852a32"   # 213:8455
png3x Top04                     "$A/483bc59f-a0b9-40b6-8a9a-309e41dfd646"   # 213:8590
png3x Top05                     "$A/1c8da4f5-6c96-4807-8765-70364cc02772"   # 213:8592
png3x Top06                     "$A/f9b3f762-e16e-4350-95a0-309c44aed132"   # 213:8594
png3x Top07                     "$A/36265993-f810-4365-9830-5bb724d766b6"   # 213:8597
png3x Top08                     "$A/2485a062-2dc9-4965-81d0-0a5641f620e9"   # 213:8598
png3x Top09                     "$A/8baf7d45-cd39-42eb-a357-a9c0e59c9a2c"   # 213:8599

echo
if [ "$FAILED" -eq 0 ]; then
  touch "$CATALOG/.fetched"
  echo "All Figma assets downloaded into $CATALOG"
  echo "The asset catalog picks them up automatically on the next build."
else
  echo "warning: some assets failed to download (offline, or the export URLs" >&2
  echo "expired ~7 days after generation). Re-run this script with network" >&2
  echo "access, or ask Claude to re-export the assets from Figma." >&2
fi
exit 0
