# Changelog

## 1.0.5-1

- New `remote_only` option (default on): content stays in TorBox, nothing is
  downloaded to Home Assistant
  - Built from upstream source at a pinned commit with `remote-only.patch`

## 1.0.5

- Initial release, wrapping `mrjoiny/torboxarr:1.0.5`
  - Secrets set via the Configuration tab
  - SQLite state in `/data` (part of HA backups), downloads in `/share/torboxarr`
