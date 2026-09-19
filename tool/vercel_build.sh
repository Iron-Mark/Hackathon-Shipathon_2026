#!/usr/bin/env bash
# Vercel build: the build image has no Flutter SDK, so install the pinned
# stable release, then produce the static web bundle in build/web.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.2}"
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "Installing Flutter $FLUTTER_VERSION..."
  mkdir -p "$(dirname "$FLUTTER_HOME")"
  curl -sSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ -C "$(dirname "$FLUTTER_HOME")"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"
git config --global --add safe.directory "$FLUTTER_HOME" || true
flutter config --no-analytics >/dev/null 2>&1 || true
flutter --version
flutter pub get
flutter build web --release

# Publish the demo deck next to the game at /demo/.
mkdir -p build/web/demo
cp -r docs/demo/. build/web/demo/
