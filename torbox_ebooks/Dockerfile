ARG BUILD_FROM
FROM ${BUILD_FROM}

# python3 stdlib only: urllib for the TorBox API, json for state
RUN apk add --no-cache python3 ca-certificates

COPY torbox_ebooks.py /torbox_ebooks.py

CMD ["python3", "-u", "/torbox_ebooks.py"]
