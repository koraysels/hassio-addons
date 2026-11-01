# Changelog

## 2.7.1-1

- Fix: add-on stuck in "startup" state; healthcheck now reads the config in `/data`

## 2.7.1

- Initial release, wrapping `cy01/blackhole:v2.7.1`
  - Config stored in `/data` (persistent, part of HA backups)
  - `/share` mapped for optional download/symlink targets
