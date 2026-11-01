#!/bin/sh
set -eu

CONFIG_PATH=/data/options.json

TORBOXARR_TORBOX_API_TOKEN=$(jq --raw-output '.torbox_api_token // ""'               "${CONFIG_PATH}")
TORBOXARR_QBIT_PASSWORD=$(jq --raw-output    '.qbit_password    // ""'               "${CONFIG_PATH}")
TORBOXARR_SAB_API_KEY=$(jq --raw-output      '.sab_api_key      // ""'               "${CONFIG_PATH}")
TORBOXARR_DATA_ROOT=$(jq --raw-output        '.data_root        // "/share/torboxarr"' "${CONFIG_PATH}")
TORBOXARR_LOG_LEVEL=$(jq --raw-output        '.log_level        // "INFO"'           "${CONFIG_PATH}")

for v in TORBOXARR_TORBOX_API_TOKEN TORBOXARR_QBIT_PASSWORD TORBOXARR_SAB_API_KEY; do
    eval "val=\${$v}"
    if [ -z "${val}" ]; then
        echo "[TorBoxarr-HA] ${v} is empty — fill in all three secrets in the Configuration tab." >&2
        exit 1
    fi
done

# SQLite state lives in /data so it survives updates and is part of HA backups
TORBOXARR_DATABASE_PATH=/data/torboxarr.db

export TORBOXARR_TORBOX_API_TOKEN TORBOXARR_QBIT_PASSWORD TORBOXARR_SAB_API_KEY \
       TORBOXARR_DATA_ROOT TORBOXARR_LOG_LEVEL TORBOXARR_DATABASE_PATH

# SAB clients only use categories whose folder already exists
mkdir -p "${TORBOXARR_DATA_ROOT}/completed/sonarr" "${TORBOXARR_DATA_ROOT}/completed/radarr"

echo "[TorBoxarr-HA] Data root: ${TORBOXARR_DATA_ROOT}"
exec /app/torboxarr
