#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH=/data/options.json

# Read HA options with sane defaults
BOOKS_DIR=$(jq --raw-output  '.books_dir  // "/share/calibre/books"'  "${CONFIG_PATH}")
INGEST_DIR=$(jq --raw-output '.ingest_dir // "/share/calibre/ingest"' "${CONFIG_PATH}")
CONFIG_DIR=$(jq --raw-output '.config_dir // "/share/calibre/config"' "${CONFIG_PATH}")
PUID=$(jq --raw-output       '.PUID       // 1000'                    "${CONFIG_PATH}")
PGID=$(jq --raw-output       '.PGID       // 1000'                    "${CONFIG_PATH}")
TZ=$(jq --raw-output         '.TZ         // "UTC"'                   "${CONFIG_PATH}")

# Export env vars that CWA reads at startup
export PUID PGID TZ
export TRUSTED_PROXY_COUNT=1   # required for HA Ingress reverse-proxy header handling

# Ensure configured directories exist (first-run safe)
mkdir -p "${BOOKS_DIR}" "${INGEST_DIR}" "${CONFIG_DIR}"

# /calibre-library → books_dir
rm -rf /calibre-library
ln -sfn "${BOOKS_DIR}" /calibre-library

# /cwa-book-ingest → ingest_dir
rm -rf /cwa-book-ingest
ln -sfn "${INGEST_DIR}" /cwa-book-ingest

# /config → config_dir
# If /config exists as a real directory with content and the target is empty,
# migrate the image-layer defaults on first run so no config is lost.
if [ -d /config ] && [ ! -L /config ]; then
    if [ -n "$(ls -A /config 2>/dev/null)" ] && [ -z "$(ls -A "${CONFIG_DIR}" 2>/dev/null)" ]; then
        cp -rp /config/. "${CONFIG_DIR}/"
    fi
    rm -rf /config
fi
ln -sfn "${CONFIG_DIR}" /config

# Hand control to CWA's S6 supervisor unchanged
exec /init
