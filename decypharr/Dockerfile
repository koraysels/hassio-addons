ARG BUILD_FROM
FROM ${BUILD_FROM}

# Run as root so Decypharr can write to the Supervisor-managed /data volume.
# The upstream entrypoint still prepares /app for logs; config lives in /data
# so it survives updates and is included in HA backups.
ENV PUID=0 PGID=0

# Upstream healthcheck reads /app; the Supervisor watchdog covers this instead
HEALTHCHECK NONE

CMD ["/usr/bin/decypharr", "--config", "/data"]
