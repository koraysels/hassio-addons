ARG BUILD_FROM

# Stage 1: install our tools on top of the CWA base
FROM ${BUILD_FROM} AS build

# jq: parse options.json; nginx: HA Ingress proxy; sqlite3: patch upload limit
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq nginx sqlite3 \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Stage 2: copy the full filesystem WITHOUT inheriting the VOLUME declarations
# from the upstream CWA image (/calibre-library, /cwa-book-ingest, /config).
# Those paths become plain directories that run.sh can symlink at startup.
FROM scratch
COPY --from=build / /
ENTRYPOINT ["/run.sh"]
