ARG BUILD_FROM
FROM ${BUILD_FROM}

# jq: parse /data/options.json; nginx: HA Ingress proxy; sqlite3: patch app.db upload limit
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq nginx sqlite3 \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
