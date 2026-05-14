ARG BUILD_FROM
FROM ${BUILD_FROM}

# jq: parse /data/options.json; nginx: HA Ingress proxy layer; sqlite3: patch app.db
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq nginx sqlite3 \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
# patch-library.sh runs synchronously via linuxserver's custom-cont-init.d,
# after cwa-init creates app.db but before CWA services start.
COPY patch-library.sh /custom-cont-init.d/99-ha-library-patch.sh
RUN chmod +x /run.sh /custom-cont-init.d/99-ha-library-patch.sh

ENTRYPOINT ["/run.sh"]
