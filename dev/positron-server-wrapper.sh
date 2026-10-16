#!/usr/bin/env bash
# Dev-only launcher installed as bin/positron-server. When a signing key is
# present and no license.lic is installed, it mints a signed license key for
# this session's connection token, then starts the real server.
set -euo pipefail

bin="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
root="$(dirname "$bin")"
real="$bin/positron-server.real"
key="$root/dev/signing-key.pem"
activation="$root/resources/activation/linux/$(uname -m)"

if [[ ! -f "$key" ]] || compgen -G "$activation/*.lic" > /dev/null; then
  exec "$real" "$@"
fi

token_file=""
args=("$@")
for ((i = 0; i < ${#args[@]}; i++)); do
  case "${args[i]}" in
    --connection-token-file) token_file="${args[i + 1]}" ;;
    --connection-token-file=*) token_file="${args[i]#*=}" ;;
  esac
done
if [[ -z "$token_file" ]]; then
  exec "$real" "$@"
fi

token="$(< "$token_file")"
issuer="Positron Department of Licensing"
licensee="positron-server-ood local validation"
timestamp="$(date +%s%3N)"
signature="$(printf '%s%s%s%s' "$token" "$issuer" "$licensee" "$timestamp" \
  | openssl dgst -sha256 -sign "$key" | base64 | tr -d '\n')"

key_file="$(mktemp)"
printf '{"connection_token":"%s","issuer":"%s","licensee":"%s","timestamp":"%s","signature":"%s"}\n' \
  "$token" "$issuer" "$licensee" "$timestamp" "$signature" > "$key_file"
echo "dev wrapper: minted a signed license key for this session"
exec "$real" "$@" --license-key-file "$key_file"
