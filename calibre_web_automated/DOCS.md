# Calibre-Web Automated

Calibre-Web Automated (CWA) extends Calibre-Web with automated ebook ingestion,
metadata fetching, and library management — wrapped as a native HA addon with
Ingress support and Samba integration.

## Installation

1. Add this repository to Home Assistant:
   **Settings → Add-ons → Add-on Store → ⋮ → Repositories**
   Paste `https://github.com/koraysels/hassio-addons` and click **Add**
2. Find **Calibre-Web Automated** in the store and click **Install**
3. Adjust paths in the **Configuration** tab if needed (defaults work for most setups)
4. Click **Start** — all directories are created automatically
5. Open the web UI from the sidebar panel

## First-time setup

1. Log in with **admin / admin123**
2. **Change the password immediately** — Admin → Edit User
3. Done. The library is configured automatically.

> The CWA admin panel will always show the library path as `/calibre-library`.
> This is a symlink that points to your `books_dir`. Books physically live in
> `/share/calibre/books` and are accessible via Samba — no further configuration needed.

## Adding books

**Via Samba (recommended)**

Drop ebook files (epub, mobi, pdf, azw3, etc.) into `share/calibre/ingest` on your
network share. CWA detects them within seconds, processes and imports them, fetches
metadata, and moves them into `share/calibre/books`. No size limit applies.

**Via web upload**

Use the **Upload** button in the CWA interface. Files up to 2 GB are accepted.

## Configuration options

| Option | Default | Description |
|--------|---------|-------------|
| `books_dir` | `/share/calibre/books` | Calibre library location. Accessible via Samba. Created on first start. |
| `ingest_dir` | `/share/calibre/ingest` | Drop ebooks here to trigger automatic import. Files are moved, not copied. |
| `PUID` | `1000` | User ID the process runs as. Check with `id` on a terminal. |
| `PGID` | `1000` | Group ID the process runs as. |
| `TZ` | `UTC` | IANA timezone string — e.g. `America/New_York`, `Europe/London`. |

## Network access

| Method | Details |
|--------|---------|
| HA Ingress | Sidebar panel — proxied through HA, no port forwarding needed |
| Direct | `http://<ha-ip>:8083` |

## Migrating an existing Calibre library

Point `books_dir` at the folder containing your existing `metadata.db`.
Restart the addon — CWA will detect and use your existing library.

## Notes

- Library data is in `books_dir` and survives addon restarts and updates
- The ingest folder is destructive: files are moved into the library, not copied
- `armv7` support follows the upstream CWA Docker image availability
- Upstream: [crocodilestick/Calibre-Web-Automated](https://github.com/crocodilestick/Calibre-Web-Automated)
