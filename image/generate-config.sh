#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

config="/usr/local/etc/haproxy/haproxy.cfg"

cat > $config <<EOF
listen stats
  bind 127.0.0.1:1936
  mode http
  stats enable
  stats uri /
  timeout client 10s
  timeout server 10s
  timeout connect 5s

frontend localhost
  bind 127.0.0.1:6443
  mode tcp
  default_backend apiservers
  timeout client 10s

backend apiservers
  mode tcp
  option tcp-check
  balance roundrobin
  timeout server 10s
  timeout connect 5s
EOF

IFS=',' read -ra ENDPOINTS <<< "$BACKEND_ENDPOINTS"
for endpoint in "${ENDPOINTS[@]}"; do
  echo "  server $endpoint $endpoint check inter 2000 on-marked-down shutdown-sessions" >> $config
done

echo
echo "-----BEGIN GENERATED CONFIG-----"
cat $config
echo "-----END GENERATED CONFIG-----"
echo
echo "Starting haproxy..."

exec /docker-entrypoint.sh "$@"
