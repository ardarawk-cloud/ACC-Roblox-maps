#!/usr/bin/env bash
set -euo pipefail

: "${CONTROL_DIR:?CONTROL_DIR is required}"
: "${SOURCE_DIR:?SOURCE_DIR is required}"
: "${MAP_KEY:?MAP_KEY is required}"

REGISTRY="$CONTROL_DIR/.github/rescue/roblox-public-rescue-registry.json"
[[ -f "$REGISTRY" ]] || { echo "Missing rescue registry: $REGISTRY"; exit 2; }
[[ "$MAP_KEY" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "Invalid map key: $MAP_KEY"; exit 3; }

TARGET=$(jq -c --arg k "$MAP_KEY" '.maps[$k] // empty' "$REGISTRY")
[[ -n "$TARGET" && "$TARGET" != "null" ]] || { echo "Unknown rescue map: $MAP_KEY"; exit 4; }
[[ "$(jq -r '.enabled' <<<"$TARGET")" == "true" ]] || { echo "Rescue map disabled: $MAP_KEY"; exit 5; }

NAME=$(jq -r '.name' <<<"$TARGET")
UNIVERSE_ID=$(jq -r '.universeId' <<<"$TARGET")
PLACE_ID=$(jq -r '.placeId' <<<"$TARGET")
BUILD_MODE=$(jq -r '.buildMode' <<<"$TARGET")
EXT=$(jq -r '.outputExtension' <<<"$TARGET")
SECRET_PROFILE=$(jq -r '.secretProfile' <<<"$TARGET")
[[ "$UNIVERSE_ID" =~ ^[0-9]+$ && "$PLACE_ID" =~ ^[0-9]+$ ]] || { echo "Invalid target IDs for $MAP_KEY"; exit 6; }
[[ "$EXT" == "rbxl" || "$EXT" == "rbxlx" ]] || { echo "Invalid output extension: $EXT"; exit 7; }

# Cross-check targets that already exist in the production registry.
if [[ -f "$CONTROL_DIR/maps/registry.json" ]]; then
  PROD=$(jq -c --arg k "$MAP_KEY" '.maps[$k] // empty' "$CONTROL_DIR/maps/registry.json")
  if [[ -n "$PROD" && "$PROD" != "null" ]]; then
    [[ "$(jq -r '.universeId' <<<"$PROD")" == "$UNIVERSE_ID" ]] || { echo "Universe ID drift vs production registry"; exit 8; }
    [[ "$(jq -r '.placeId' <<<"$PROD")" == "$PLACE_ID" ]] || { echo "Place ID drift vs production registry"; exit 9; }
    [[ "$(jq -r '.enabled' <<<"$PROD")" == "true" ]] || { echo "Production target disabled: $MAP_KEY"; exit 10; }
  fi
fi

ACTUAL_SOURCE=$(git -C "$SOURCE_DIR" rev-parse HEAD)
if [[ -n "${SOURCE_SHA:-}" ]]; then
  [[ "$SOURCE_SHA" =~ ^[0-9a-fA-F]{40}$ ]] || { echo "SOURCE_SHA must be an exact 40-char commit"; exit 11; }
  [[ "$ACTUAL_SOURCE" == "$SOURCE_SHA" ]] || { echo "Source lock mismatch: $ACTUAL_SOURCE != $SOURCE_SHA"; exit 12; }
fi

case "$BUILD_MODE" in
  rojo)
    PROJECT_PATH=$(jq -r '.projectPath' <<<"$TARGET")
    [[ -f "$SOURCE_DIR/$PROJECT_PATH" ]] || { echo "Missing Rojo project: $PROJECT_PATH"; exit 20; }
    TARGET_DIR=$(dirname "$PROJECT_PATH")
    ;;
  bbyavatar-node|becak-node)
    OUTPUT_PATH=$(jq -r '.outputPath' <<<"$TARGET")
    TARGET_DIR=$(dirname "$OUTPUT_PATH")
    ;;
  *)
    echo "Unsupported build mode: $BUILD_MODE"
    exit 21
    ;;
esac

# Fail closed on unresolved merge markers in the target map source.
if git -C "$SOURCE_DIR" grep -nE '^(<<<<<<< |>>>>>>> )' -- "$TARGET_DIR"; then
  echo "Unresolved merge markers found under $TARGET_DIR"
  exit 22
fi

OUT_FILE="${RESCUE_OUT_FILE:-${RUNNER_TEMP:-/tmp}/public-rescue-${MAP_KEY}.${EXT}}"
META_FILE="${RESCUE_METADATA_FILE:-${RUNNER_TEMP:-/tmp}/public-rescue-${MAP_KEY}-build.json}"
mkdir -p "$(dirname "$OUT_FILE")" "$(dirname "$META_FILE")"
rm -f "$OUT_FILE" "$META_FILE"
ROJO_USED=""

case "$BUILD_MODE" in
  rojo)
    ROJO_VERSION=$(jq -r '.rojoVersion' "$REGISTRY")
    [[ "$ROJO_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Invalid Rojo version in registry"; exit 30; }
    ROJO_BIN="${ROJO_EXE:-}"
    if [[ -z "$ROJO_BIN" ]]; then
      TOOL_DIR=$(mktemp -d "${RUNNER_TEMP:-/tmp}/public-rescue-rojo.XXXXXX")
      curl -fsSL "https://github.com/rojo-rbx/rojo/releases/download/v${ROJO_VERSION}/rojo-${ROJO_VERSION}-linux-x86_64.zip" -o "$TOOL_DIR/rojo.zip"
      unzip -q -o "$TOOL_DIR/rojo.zip" -d "$TOOL_DIR/unpacked"
      ROJO_BIN=$(find "$TOOL_DIR/unpacked" -type f -name rojo | head -n1)
      [[ -n "$ROJO_BIN" ]] || { echo "Rojo binary not found"; exit 31; }
      chmod +x "$ROJO_BIN"
    fi
    VERSION_TEXT=$("$ROJO_BIN" --version)
    [[ "$VERSION_TEXT" == *"$ROJO_VERSION"* ]] || { echo "Wrong Rojo: $VERSION_TEXT"; exit 32; }
    "$ROJO_BIN" build "$SOURCE_DIR/$PROJECT_PATH" -o "$OUT_FILE"
    ROJO_USED="$ROJO_VERSION"
    ;;

  bbyavatar-node)
    (
      cd "$SOURCE_DIR"
      [[ -f scripts/build-bbyavatar.js ]] || { echo "Missing BBYAVATAR builder"; exit 40; }
      [[ -f scripts/validate-bbyavatar-build.js ]] || { echo "Missing BBYAVATAR validator"; exit 41; }
      node scripts/build-bbyavatar.js
      node scripts/validate-bbyavatar-build.js
    )
    [[ -s "$SOURCE_DIR/$OUTPUT_PATH" ]] || { echo "BBYAVATAR output missing"; exit 42; }
    cp "$SOURCE_DIR/$OUTPUT_PATH" "$OUT_FILE"
    ;;

  becak-node)
    (
      cd "$SOURCE_DIR"
      [[ -f scripts/patch-becak-v3-place.js ]] || { echo "Missing BECAK builder"; exit 50; }
      node scripts/patch-becak-v3-place.js
      FILE="$OUTPUT_PATH"
      [[ -s "$FILE" ]] || { echo "BECAK output missing"; exit 51; }
      [[ "$(wc -c < "$FILE")" -gt 100000 ]] || { echo "BECAK output too small"; exit 52; }
      for token in \
        BecakEBike_Runtime \
        BecakEBike_Client \
        BecakEBike_DriverPhone \
        ACC_BecakWorldV3 \
        BecakWorldV3VisualAuthority \
        BecakWorldV3LegacyVisibleShells \
        BecakEBike_VehicleRealism \
        BecakEBike_VehicleGeometryRealism; do
        grep -q "$token" "$FILE" || { echo "BECAK validation token missing: $token"; exit 53; }
      done
    )
    cp "$SOURCE_DIR/$OUTPUT_PATH" "$OUT_FILE"
    ;;
esac

[[ -s "$OUT_FILE" ]] || { echo "Rescue build produced an empty place"; exit 60; }
BYTES=$(stat -c%s "$OUT_FILE")
SHA256=$(sha256sum "$OUT_FILE" | awk '{print $1}')

jq -n \
  --arg mapKey "$MAP_KEY" \
  --arg name "$NAME" \
  --arg universeId "$UNIVERSE_ID" \
  --arg placeId "$PLACE_ID" \
  --arg buildMode "$BUILD_MODE" \
  --arg secretProfile "$SECRET_PROFILE" \
  --arg sourceCommit "$ACTUAL_SOURCE" \
  --arg outputFile "$OUT_FILE" \
  --arg rojoVersion "$ROJO_USED" \
  --arg placeBytes "$BYTES" \
  --arg placeSha256 "$SHA256" \
  '{mapKey:$mapKey,name:$name,universeId:$universeId,placeId:$placeId,buildMode:$buildMode,secretProfile:$secretProfile,sourceCommit:$sourceCommit,outputFile:$outputFile,rojoVersion:$rojoVersion,placeBytes:($placeBytes|tonumber),placeSha256:$placeSha256}' \
  > "$META_FILE"

cat "$META_FILE"
echo "PUBLIC RESCUE BUILD PASS map=$MAP_KEY source=$ACTUAL_SOURCE bytes=$BYTES sha256=$SHA256"
