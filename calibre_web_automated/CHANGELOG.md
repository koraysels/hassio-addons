# Changelog

## 4.0.6.1

- Fix: books now land in the configured Samba-accessible books_dir instead of an internal Docker volume
  - Added `/custom-cont-init.d/99-ha-library-patch.sh` so CWA's library path is patched synchronously before its services start
  - Explicitly install `sqlite3` in Dockerfile to guarantee the patch tool is available

## 4.0.6

- Initial release, tracking CWA upstream v4.0.6
- Wraps `crocodilestick/calibre-web-automated:latest`
- Supports amd64, aarch64, armv7
- HA Ingress support on port 8083
- Configurable paths for books, ingest, and config directories via addon options
