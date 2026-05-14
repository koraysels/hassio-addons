# Home Assistant Add-on: Calibre-Web Automated

![logo](https://raw.githubusercontent.com/koraysels/hassio-addons/main/calibre_web_automated/logo.png)

![Version](https://img.shields.io/badge/dynamic/yaml?label=Version&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fkoraysels%2Fhassio-addons%2Fmain%2Fcalibre_web_automated%2Fconfig.yaml)
![Ingress](https://img.shields.io/badge/dynamic/yaml?label=Ingress&query=%24.ingress&url=https%3A%2F%2Fraw.githubusercontent.com%2Fkoraysels%2Fhassio-addons%2Fmain%2Fcalibre_web_automated%2Fconfig.yaml)
![Arch](https://img.shields.io/badge/dynamic/yaml?color=success&label=Arch&query=%24.arch&url=https%3A%2F%2Fraw.githubusercontent.com%2Fkoraysels%2Fhassio-addons%2Fmain%2Fcalibre_web_automated%2Fconfig.yaml)

## About

[Calibre-Web Automated](https://github.com/crocodilestick/Calibre-Web-Automated) extends
Calibre-Web with automated ebook ingestion, metadata fetching, and library management.

Drop an ebook into the ingest folder — CWA imports it, fetches metadata, and makes it
available in the web UI. Books are stored in `/share/calibre/books`, immediately visible
on your network via Samba. Browse and read through the HA sidebar panel.

## Installation

1. Add this repository to Home Assistant:

   [![Add repository to HA](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fkoraysels%2Fhassio-addons)

   Or go to **Settings → Add-ons → Add-on Store → ⋮ → Repositories** and add:
   ```
   https://github.com/koraysels/hassio-addons
   ```

2. Find **Calibre-Web Automated** in the store and click **Install**
3. Review the **Configuration** tab and adjust paths if needed
4. Click **Start** — directories are created automatically
5. Open the web UI via the sidebar panel

## First-time setup

1. Log in with **admin / admin123**
2. **Change the password immediately** — top-right menu → Admin → Edit User

That's it. The library path is configured automatically — no manual steps needed.

> **Note:** The CWA admin panel shows the library path as `/calibre-library`. This is
> normal — it is a symlink that points to your configured `books_dir`. Books physically
> land in `/share/calibre/books` and are accessible via Samba.

## Adding books

**Via Samba (recommended):** Drop ebook files into `share/calibre/ingest` on your network
share. CWA picks them up within a few seconds, imports them, fetches metadata, and moves
them into the library.

**Via web upload:** Use the **Upload** button in the CWA interface (up to 2 GB per file).

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `books_dir` | `/share/calibre/books` | Where CWA stores your Calibre library. Accessible via Samba. |
| `ingest_dir` | `/share/calibre/ingest` | Drop ebooks here to import automatically. Files are moved, not copied. |
| `PUID` | `1000` | Unix user ID the app runs as. Run `id` in a terminal to find yours. |
| `PGID` | `1000` | Unix group ID the app runs as. |
| `TZ` | `UTC` | IANA timezone string, e.g. `Europe/Amsterdam`. |

## Network access

| Method | URL |
|--------|-----|
| HA Ingress (recommended) | Sidebar panel — no port forwarding needed |
| Direct | `http://<ha-ip>:8083` |

## Notes

- All library data lives in `books_dir` and persists across restarts and updates
- The ingest folder is **destructive by design** — files are moved into the library
- `armv7` support depends on the upstream CWA image; `amd64` and `aarch64` are fully tested
- Upstream project: [crocodilestick/Calibre-Web-Automated](https://github.com/crocodilestick/Calibre-Web-Automated)
