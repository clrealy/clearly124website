#!/bin/sh
# JLack installer 🔥
# usage: curl -fsSL https://clearly124.com/jlack/install.sh | sh
set -e

# where the JLack downloads live
BASE_URL="${JLACK_URL:-https://clearly124.com/jlack}"

say() { printf '%s\n' "$*"; }
die() { say "JLack install error: $*" >&2; exit 1; }

# only Linux for now 🐧
[ "$(uname -s)" = "Linux" ] || die "this installer is Linux only (Windows ppl grab the .zip) 🤷"

case "$(uname -m)" in
  x86_64|amd64)  ARCH="x64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) die "your CPU ($(uname -m)) isn't supported yet 😭" ;;
esac

command -v curl >/dev/null 2>&1 || die "u need curl installed"
command -v tar  >/dev/null 2>&1 || die "u need tar installed"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

say "📦 downloading JLack ($ARCH)..."
curl -fsSL "$BASE_URL/jlack-linux-$ARCH.tar.gz" -o "$TMP/jlack.tar.gz" || die "download failed, is the release up?"
tar -xzf "$TMP/jlack.tar.gz" -C "$TMP" || die "couldn't unpack it 💀"
chmod +x "$TMP/jlack"

# install to /usr/local/bin if we can, otherwise ~/.local/bin (no sudo needed)
if [ -w /usr/local/bin ]; then
  DEST="/usr/local/bin"; mv "$TMP/jlack" "$DEST/jlack"
elif command -v sudo >/dev/null 2>&1 && [ -z "$JLACK_NO_SUDO" ]; then
  DEST="/usr/local/bin"; say "🔑 need sudo to put it in $DEST"
  sudo mv "$TMP/jlack" "$DEST/jlack"
else
  DEST="$HOME/.local/bin"; mkdir -p "$DEST"; mv "$TMP/jlack" "$DEST/jlack"
  case ":$PATH:" in *":$DEST:"*) ;; *) say "⚠️  add this to your ~/.bashrc:  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;; esac
fi

say "✅ JLack installed to $DEST/jlack"
say "try it:  echo 'say \"marrow\"' > egg.JLa && jlack egg.JLa 🦴"
