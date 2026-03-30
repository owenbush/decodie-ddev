#!/bin/bash
# Generates Traefik routing config for the decodie subdomain.
# Routes https://decodie.SITENAME.ddev.site to Decodie on port 8081

set -e

if [ -z "$DDEV_SITENAME" ]; then
  echo "Error: DDEV_SITENAME is not set" >&2
  exit 1
fi

mkdir -p "$HOME/.ddev/traefik/custom-global-config"

cat > "$HOME/.ddev/traefik/custom-global-config/decodie-${DDEV_SITENAME}.yaml" << EOF
#ddev-generated
# Routes https://decodie.${DDEV_SITENAME}.ddev.site to Decodie on port 8081
http:
  routers:
    ${DDEV_SITENAME}-decodie-https:
      rule: "Host(\`decodie.${DDEV_SITENAME}.ddev.site\`)"
      service: ${DDEV_SITENAME}-decodie
      entryPoints:
        - http-443
      tls: true
      priority: 10000
    ${DDEV_SITENAME}-decodie-http:
      rule: "Host(\`decodie.${DDEV_SITENAME}.ddev.site\`)"
      service: ${DDEV_SITENAME}-decodie
      entryPoints:
        - http-80
      priority: 10000
  services:
    ${DDEV_SITENAME}-decodie:
      loadBalancer:
        servers:
          - url: "http://ddev-${DDEV_SITENAME}-web:8081"
EOF
