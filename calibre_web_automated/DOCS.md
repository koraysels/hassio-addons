# Calibre-Web Automated

Calibre-Web Automated (CWA) extends the popular Calibre-Web interface with automated book
ingestion, metadata fetching, and library management.

## Installation

1. Add this repository to Home Assistant:
   **Settings → Add-ons → Add-on Store → ⋮ → Repositories**
   Paste `https://github.com/koraysels/hassio-addons` and click **Add**
2. Find **Calibre-Web Automated** in the store and click **Install**
3. After installation, go to the **Configuration** tab and adjust paths if needed
4. Click **Start** — the addon will create all directories automatically on first run
5. Open the Web UI from the **Open Web UI** button or the sidebar panel

## First-time setup in Calibre-Web

1. Log in with the default credentials: **admin / admin123**
2. **Change the password immediately** (top-right menu → Admin → Edit User)
3. Go to **Admin → Edit Basic Configuration → Calibre Library Location**
   and set it to `/calibre-library`
4. Save and restart if prompted — your library is ready

## How it works

1. Drop ebook files (epub, mobi, pdf, etc.) into the **Ingest Directory**
2. CWA automatically imports them into your Calibre library and fetches metadata
3. Browse and read your library via the web interface in the HA sidebar

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
