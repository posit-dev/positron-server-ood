#!/bin/bash
# The tutorial image ships a localhost certificate that expires after a year.
# Reissue it from the image's own CA before the portal and Dex start.
set -e
openssl x509 -req -CA /etc/pki/tls/ca.crt -CAkey /etc/pki/tls/ca.key -CAcreateserial \
  -in /etc/pki/tls/certs/localhost.csr -out /etc/pki/tls/certs/localhost.crt \
  -days 365 -sha256 -extfile /etc/pki/tls/localhost.ext 2>/dev/null
exec /usr/local/bin/entrypoint.sh "$@"
