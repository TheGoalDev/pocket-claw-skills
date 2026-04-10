#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== pocket-claw-skills setup ==="

echo "Configuring git hooks path -> .githooks"
git -C "$REPO_ROOT" config core.hooksPath .githooks

chmod +x "$REPO_ROOT/.githooks/post-merge"
chmod +x "$REPO_ROOT/sync.sh"

echo "Running initial sync..."
bash "$REPO_ROOT/sync.sh"

echo ""
echo "=== Setup complete ==="
echo "sync.sh will now run automatically after every git pull."
