# Koray's HA Add-ons

A Home Assistant addon repository.

## Installation

[![Add repository to HA](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fkoraysels%2Fhassio-addons)

Or go to **Settings → Add-ons → Add-on Store → ⋮ → Repositories** and add:
```
https://github.com/koraysels/hassio-addons
```

## Addons

### [Calibre-Web Automated](calibre_web_automated/)

Automated Calibre-Web with ebook ingestion and a clean web interface. Drop ebooks into
the Samba-accessible ingest folder and they are automatically imported into your Calibre
library with metadata fetched. Books are stored in `/share/calibre/books`, immediately
visible on your network.

Wraps [`crocodilestick/calibre-web-automated`](https://github.com/crocodilestick/Calibre-Web-Automated).
Supports `amd64`, `aarch64`, `armv7` · HA Ingress · Samba-accessible library.

### [Decypharr](decypharr/)

Debrid gateway that acts as a qBittorrent client for Sonarr and Radarr. Every grab goes
straight to your TorBox (or Real-Debrid, ...) account, ready to stream from Stremio.

Wraps [`sirrobot01/decypharr`](https://github.com/sirrobot01/decypharr).
Supports `amd64`, `aarch64`.

## Add-ons

| Add-on | Description |
| --- | --- |
| [Calibre-Web Automated](./calibre_web_automated/) | Ebook library with automatic ingestion |
| [Stocktracker](./stocktracker/) | Personal portfolio tracker — import broker PDFs, live quotes, all data on your own box |
| [Decypharr](./decypharr/) | TorBox/debrid gateway for Sonarr & Radarr (fake qBittorrent) |
| [TorBoxarr](./torboxarr/) | Send torrents and usenet NZBs from Sonarr & Radarr to TorBox |
| [TorBox Ebooks](./torbox_ebooks/) | Copy ebooks from TorBox into Calibre-Web Automated's ingest folder |
