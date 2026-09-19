#!/usr/bin/env bash
# Sets up the official FlutterFlow AI MCP workspace for this repository.
#
#   FF_API_KEY=<your FlutterFlow API key> [FF_PROJECT_ID=<existing project id>] \
#     bash tool/flutterflow_setup.sh
#
# What it does:
#   1. Installs the FlutterFlow CLI (dart pub global activate flutterflow_cli).
#   2. Creates ./flutterflow_workspace bound to FF_PROJECT_ID (or a new app).
#   3. Leaves .cursor/mcp.json pointing at `flutterflow ai mcp` for that
#      workspace so Cursor (and other MCP clients) can drive the FlutterFlow
#      project. The workspace is git-ignored because it stores the API key.
set -euo pipefail

WORKSPACE="${FF_WORKSPACE:-flutterflow_workspace}"
FF_PROJECT_ID="${FF_PROJECT_ID:-game-q04txb}" # FlutterFlow project "game"
export PATH="$HOME/.pub-cache/bin:$PATH"

if ! command -v dart >/dev/null 2>&1; then
  echo "dart not found on PATH (install Flutter 3.47+ first)." >&2
  exit 1
fi
if [ -z "${FF_API_KEY:-}" ]; then
  echo "FF_API_KEY is required (FlutterFlow > Account > API Token)." >&2
  exit 1
fi

dart pub global activate flutterflow_cli >/dev/null
echo "flutterflow_cli installed."

if [ -d "$WORKSPACE" ] && [ -n "$(ls -A "$WORKSPACE")" ]; then
  echo "Workspace $WORKSPACE already exists; refreshing."
  (cd "$WORKSPACE" && FF_API_KEY="$FF_API_KEY" flutterflow ai refresh-workspace --yes)
else
  args=(ai init "$WORKSPACE" --api-key "$FF_API_KEY")
  if [ -n "${FF_PROJECT_ID:-}" ]; then
    args+=(--project "$FF_PROJECT_ID")
  fi
  flutterflow "${args[@]}"
fi

echo
echo "Done. Cursor MCP server 'flutterflow_ai' uses:"
echo "  flutterflow ai mcp --workspace $(pwd)/$WORKSPACE"
echo "Reload MCP servers in Cursor (Settings > MCP) and approve 'flutterflow_ai'."
