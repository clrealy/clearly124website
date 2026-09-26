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

# pick where jlack goes: JLACK_DEST (used by `jlack upd`), else /usr/local/bin, else ~/.local/bin
put() { # put <dir>
  if [ -w "$1" ] || { [ ! -e "$1" ] && mkdir -p "$1" 2>/dev/null; }; then mv "$TMP/jlack" "$1/jlack"
  elif command -v sudo >/dev/null 2>&1 && [ -z "$JLACK_NO_SUDO" ]; then say "🔑 need sudo to put it in $1"; sudo mv "$TMP/jlack" "$1/jlack"
  else return 1; fi
}
if [ -n "$JLACK_DEST" ]; then
  DEST="$JLACK_DEST"; put "$DEST" || die "can't write to $DEST"
elif put /usr/local/bin; then
  DEST="/usr/local/bin"
else
  DEST="$HOME/.local/bin"; mkdir -p "$DEST"; mv "$TMP/jlack" "$DEST/jlack"
  case ":$PATH:" in *":$DEST:"*) ;; *) say "⚠️  add this to your ~/.bashrc:  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;; esac
fi

# .JLa file icons 🎨 (per-user, no sudo)
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
if [ -f "$TMP/jlack-mime.xml" ]; then
  mkdir -p "$DATA/mime/packages"
  cp "$TMP/jlack-mime.xml" "$DATA/mime/packages/jlack.xml"
  for s in 16 24 32 48 64 128 256 512; do
    if [ -f "$TMP/icons/jlack-$s.png" ]; then
      mkdir -p "$DATA/icons/hicolor/${s}x${s}/mimetypes"
      cp "$TMP/icons/jlack-$s.png" "$DATA/icons/hicolor/${s}x${s}/mimetypes/text-x-jlack.png"
    fi
  done
  command -v update-mime-database >/dev/null 2>&1 && update-mime-database "$DATA/mime" >/dev/null 2>&1 || true
  command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -f -t "$DATA/icons/hicolor" >/dev/null 2>&1 || true
  command -v xdg-icon-resource >/dev/null 2>&1 && xdg-icon-resource forceupdate >/dev/null 2>&1 || true
  say "🎨 .JLa files got their custom icon (might need to reopen your file manager)"
fi

say "✅ JLack installed to $DEST/jlack"
say "try it:  echo 'say \"marrow\"' > egg.JLa && jlack egg.JLa 🦴"
