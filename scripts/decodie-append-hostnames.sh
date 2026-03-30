#!/bin/bash
# Appends additional_hostnames to config.decodie.yaml for DNS resolution.
# Requires: DDEV_SITENAME env var

set -e

if [ -z "$DDEV_SITENAME" ]; then
  echo "Error: DDEV_SITENAME is not set" >&2
  exit 1
fi

cat >> config.decodie.yaml << EOF

# Register decodie subdomain with DDEV for /etc/hosts and TLS cert
additional_hostnames:
  - decodie.${DDEV_SITENAME}
EOF
