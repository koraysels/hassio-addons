# Calibre-Web Automated

Calibre-Web Automated (CWA) extends the popular Calibre-Web interface with automated book
ingestion, metadata fetching, and library management.

## How it works

1. Drop ebook files (epub, mobi, pdf, etc.) into the **Ingest Directory**
2. CWA automatically imports them into your Calibre library and fetches metadata
3. Browse and read your library via the web interface in the HA sidebar

## First-time setup

1. Install and start the addon
2. Open the Web UI via the HA sidebar or `http://<ha-ip>:8083`
3. Default credentials: **admin / admin123** — change these immediately
4. In the Calibre-Web settings, set the Calibre library path to `/calibre-library`

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `books_dir` | `/share/calibre/books` | Calibre library folder (must contain `metadata.db` after first init) |
| `ingest_dir` | `/share/calibre/ingest` | Drop new ebooks here — imported and removed automatically |
| `config_dir` | `/share/calibre/config` | App config, SQLite database, and logs |
| `PUID` | `1000` | Unix user ID the app runs as |
| `PGID` | `1000` | Unix group ID the app runs as |
| `TZ` | `UTC` | IANA timezone string, e.g. `Europe/London` |

## Network access

- **HA Ingress** (recommended) — click the sidebar panel, no extra ports needed
- **Direct** — `http://<ha-ip>:8083`

## Migrating an existing Calibre library

Point `books_dir` to the folder containing your existing `metadata.db`. CWA will detect
and use it automatically on next startup.

## Notes

- The ingest folder is **destructive by design** — files are moved into the library, not copied
- All data lives under `/share/calibre/` and persists across addon restarts and updates
- `armv7` support depends on the upstream CWA image; `amd64` and `aarch64` are fully tested
