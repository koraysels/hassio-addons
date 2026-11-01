ARG BUILD_FROM
FROM ${BUILD_FROM}

# jq: parse options.json
RUN apk add --no-cache jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
