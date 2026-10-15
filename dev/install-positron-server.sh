#!/usr/bin/env bash
# Runs once inside the installer container. Installs Positron Server into
# /opt/positron-server and places the dev wrapper and any secrets.
set -euo pipefail

version="${POSITRON_VERSION:?POSITRON_VERSION is not set}"
dest=/opt/positron-server
cdn=https://cdn.posit.co/positron/releases/server

case "$(uname -m)" in
  x86_64)  url="$cdn/x86_64/positron-server-linux-x64-$version.tar.gz"; arch=x86_64 ;;
  aarch64) url="$cdn/arm64/positron-server-linux-arm64-$version.tar.gz"; arch=aarch64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

tarball="/cache/$(basename "$url")"
if [[ ! -f "$tarball" ]]; then
  echo "Downloading $url"
  curl -fL -o "$tarball.part" "$url"
  mv "$tarball.part" "$tarball"
fi

if [[ "$(cat "$dest/.version" 2>/dev/null)" != "$version" ]]; then
  echo "Unpacking Positron Server $version into $dest"
  find "$dest" -mindepth 1 -delete
  tar -xzf "$tarball" -C "$dest" --strip-components=1
  echo "$version" > "$dest/.version"
fi

if [[ ! -f "$dest/bin/positron-server.real" ]]; then
  mv "$dest/bin/positron-server" "$dest/bin/positron-server.real"
fi
install -m 755 /positron-server-wrapper.sh "$dest/bin/positron-server"

activation="$dest/resources/activation/linux/$arch"
if [[ -f /secrets/license.lic ]]; then
  echo "Installing license.lic into $activation"
  install -m 644 /secrets/license.lic "$activation/license.lic"
else
  rm -f "$activation/license.lic"
fi

mkdir -p "$dest/dev"
if [[ -f /secrets/signing-key.pem ]]; then
  echo "Installing the dev signing key"
  install -m 644 /secrets/signing-key.pem "$dest/dev/signing-key.pem"
else
  rm -f "$dest/dev/signing-key.pem"
fi

echo "Positron Server $version is installed in $dest"
