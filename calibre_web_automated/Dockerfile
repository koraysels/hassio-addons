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
#
# FROM scratch strips Docker image metadata (VOLUME, ENV, ENTRYPOINT).
# We must re-declare the linuxserver.io ENV vars that S6 and Python depend on,
# otherwise PATH won't include /lsiopy/bin and python3 won't be found.
FROM scratch
COPY --from=build / /
ENV HOME="/root" \
    LANGUAGE="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    TERM="xterm" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="0" \
    S6_VERBOSITY=1 \
    S6_STAGE2_HOOK=/docker-mods \
    VIRTUAL_ENV=/lsiopy \
    PATH="/lsiopy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENTRYPOINT ["/run.sh"]
