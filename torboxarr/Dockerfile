ARG BUILD_FROM

# Stage 1: build upstream TorBoxarr with our remote-only patch
FROM golang:1.26.1 AS build
ARG TORBOXARR_COMMIT=72343d0cb9478b57c7bdb879ee34962522842b08
WORKDIR /src
RUN git clone https://github.com/MrJoiny/TorBoxarr.git . \
    && git checkout "${TORBOXARR_COMMIT}"
COPY remote-only.patch /tmp/remote-only.patch
RUN git apply /tmp/remote-only.patch \
    && VERSION="$(tr -d '\r\n' < VERSION)-remoteonly" \
    && CGO_ENABLED=0 go build -ldflags "-X main.version=${VERSION}" -o /out/torboxarr ./cmd/torboxarr

# Stage 2: upstream runtime image with the patched binary
FROM ${BUILD_FROM}

# jq: parse options.json
RUN apk add --no-cache jq

COPY --from=build /out/torboxarr /app/torboxarr
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
