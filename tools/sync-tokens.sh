#!/usr/bin/env bash
# tools/sync-tokens.sh — fails if tokens diverge between Flutter app and tokens.css
# Usage: ./tools/sync-tokens.sh [/path/to/app_colors.dart]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_PATH="${1:-/e/pixel_quest/lib/theme/app_colors.dart}"
CSS_PATH="$SCRIPT_DIR/../public/assets/css/tokens.css"

# Convert Windows path if needed (e.g. E:\... to /e/...)
if [[ "$FLUTTER_PATH" =~ ^[A-Za-z]:\\ ]]; then
  DRIVE="${FLUTTER_PATH:0:1}"
  DRIVE_LOWER=$(echo "$DRIVE" | tr '[:upper:]' '[:lower:]')
  REST="${FLUTTER_PATH:3}"
  FLUTTER_PATH="/$DRIVE_LOWER/${REST//\\//}"
fi

if [[ ! -f "$FLUTTER_PATH" ]]; then
  echo -e "\033[0;31m❌ Error: Could not find app_colors.dart at $FLUTTER_PATH\033[0m"
  echo -e "\033[0;33mPass the path as an argument: ./tools/sync-tokens.sh /path/to/app_colors.dart\033[0m"
  exit 1
fi

if [[ ! -f "$CSS_PATH" ]]; then
  echo -e "\033[0;31m❌ Error: Could not find tokens.css at $CSS_PATH\033[0m"
  exit 1
fi

echo -e "\n\033[0;36m--- Pixel Quest Token Sync Check (Bash) ---\033[0m\n"

# Flutter color -> CSS token name mappings
declare -A MAPPINGS=(
  ["primary"]="mint"
  ["primaryDark"]="mint-dark"
  ["accentGold"]="gold"
  ["background"]="ink-0"
  ["cardBg"]="ink-1"
  ["surfaceHigh"]="ink-2"
  ["border"]="ink-3"
  ["textPrimary"]="ink-fg"
  ["textSecondary"]="ink-fg2"
  ["textMuted"]="ink-fg3"
  ["error"]="state-error"
  ["badgeBlue"]="cat-health"
  ["badgePink"]="cat-fitness"
  ["badgePurple"]="cat-skills"
)

MISMATCH=0

for DART_NAME in "${!MAPPINGS[@]}"; do
  CSS_NAME="${MAPPINGS[$DART_NAME]}"

  # Extract hex from Flutter: static const Color NAME = Color(0xFFHEX);
  DART_HEX=$(grep -E "static[[:space:]]+const[[:space:]]+Color[[:space:]]+$DART_NAME[[:space:]]*=" "$FLUTTER_PATH" | grep -oE "0xFF[0-9A-Fa-f]{6}" | sed 's/0xFF/#/' | tr '[:lower:]' '[:upper:]' || true)

  # Extract hex from CSS: --TOKEN: #HEX;
  CSS_HEX=$(grep -E "^[[:space:]]*--$CSS_NAME:[[:space:]]*#[0-9A-Fa-f]{6}" "$CSS_PATH" | grep -oE "#[0-9A-Fa-f]{6}" | tr '[:lower:]' '[:upper:]' || true)

  if [[ -z "$DART_HEX" ]]; then
    echo -e "\033[0;33m⚠️  Warning: Flutter color '$DART_NAME' not found in app_colors.dart\033[0m"
    continue
  fi

  if [[ -z "$CSS_HEX" ]]; then
    echo -e "\033[0;33m⚠️  Warning: CSS token '--$CSS_NAME' not found in tokens.css\033[0m"
    continue
  fi

  if [[ "$DART_HEX" == "$CSS_HEX" ]]; then
    echo -e "\033[0;32m✅ Match: $DART_NAME ($DART_HEX) == --$CSS_NAME\033[0m"
  else
    echo -e "\033[0;31m❌ MISMATCH: $DART_NAME is $DART_HEX (Flutter) but --$CSS_NAME is $CSS_HEX (Web)\033[0m"
    MISMATCH=1
  fi
done

echo -e "\n\033[0;36m-------------------------------------------\033[0m\n"

if [[ $MISMATCH -ne 0 ]]; then
  echo -e "\033[0;31mPlease update tokens.css to match the Flutter app.\033[0m"
  exit 1
else
  echo -e "\033[0;32mAll tokens perfectly match the Flutter app!\033[0m"
  exit 0
fi
