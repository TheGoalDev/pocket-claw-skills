#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DESTINATIONS=(
  "/root/.openclaw/workspace/skills"
  "$HOME/.nvm/versions/node/v22.22.2/lib/node_modules/openclaw/skills"
)

echo "=== pocket-claw-skills sync ==="
echo "Source: $SCRIPT_DIR"
echo ""

for dest in "${DESTINATIONS[@]}"; do
  echo "--- Destination: $dest ---"

  if [ ! -d "$dest" ]; then
    echo "  [WARN] Destination does not exist, creating: $dest"
    mkdir -p "$dest"
  fi

  for skill_dir in "$SCRIPT_DIR"/*/; do
    [ -d "$skill_dir" ] || continue

    skill_name="$(basename "$skill_dir")"
    target="$dest/$skill_name"

    if [ -d "$target" ]; then
      echo "  [DEL]  $target"
      rm -rf "$target"
    fi

    echo "  [COPY] $skill_name -> $target"
    cp -r "$skill_dir" "$target"
  done

  echo ""
done

echo "=== Sync complete ==="
