# Changelog

## 4.0.6.4

- Fix: books now reliably appear in Samba share within ~30 seconds of being added
  - Added rsync background job that mirrors /calibre-library → books_dir every 30s
  - Bind mount is still attempted first (zero overhead when it works); rsync is the
    guaranteed fallback that requires no elevated privileges
  - Added rsync to Dockerfile dependencies

## 4.0.6.3

- Fix: remove 16 MB upload size cap
  - CWA's config_upload_size defaults to 16 MB and is not exposed in the UI
  - Background job patches it to 2048 MB in app.db on every start
  - auto_library.py does not reset this field so the patch survives

## 4.0.6.2

- Fix: books now reliably land in Samba-accessible books_dir
  - Bind-mount books_dir over /calibre-library before CWA starts so books are
    physically stored on the share even though CWA writes to /calibre-library
  - The previous sqlite3 patch approach was always reverted by CWA's own
    auto_library.py service, which unconditionally overwrites config_calibre_dir
  - Requires full_access: true (added to config.yaml) for the bind mount syscall
  - Removed patch-library.sh and sqlite3 dep from Dockerfile (no longer needed)

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
