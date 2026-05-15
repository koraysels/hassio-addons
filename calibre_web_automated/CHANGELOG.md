# Changelog

## 4.0.6.9

- Fix: editing book metadata (title, author rename) now works
  - chown -R PUID:PGID books_dir on every startup so CWA can rename/delete
    any directories created by root in earlier runs

## 4.0.6.8

- Fix: upload size limit now actually takes effect without a manual addon restart
  - Patch the DB after CWA starts (settings table fully populated)
  - Immediately restart the CWA web process via ss+kill so S6 brings it back up
    with the new 2048 MB value — no second addon restart needed
  - Skip the patch if DB already has 2048 MB (survives restarts)

## 4.0.6.7

- Fix: upload size patch now waits for CWA web server to be ready before patching
  - Previous approach ran immediately when app.db appeared, before settings table was populated
  - Now polls /dev/tcp/127.0.0.1/8083 until CWA is accepting connections, then patches
  - On failure, logs the actual settings column names so the issue can be diagnosed

## 4.0.6.6

- Fix: restore linuxserver.io ENV vars stripped by FROM scratch
  - FROM scratch removes all Docker image metadata including ENV PATH=/lsiopy/bin:...
  - Without that PATH, python3 was not found and CWA's web server failed to start
  - Re-declare all critical linuxserver.io ENV vars (PATH, VIRTUAL_ENV, S6 settings)
  - Symlink approach intact; this makes it actually work

## 4.0.6.5

- Fix: books stored directly in Samba share with zero duplication
  - Multi-stage Dockerfile (FROM scratch final stage) strips the Docker VOLUME
    declarations from the upstream CWA image; /calibre-library becomes a plain dir
  - run.sh replaces /calibre-library with a symlink to books_dir at startup — CWA
    writes directly to /share/calibre/books, Samba sees files immediately
  - No rsync, no bind mount, no elevated privileges needed
  - Removed full_access: true and rsync from Dockerfile

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
