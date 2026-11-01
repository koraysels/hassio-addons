# TorBoxarr

TorBoxarr accepts torrents and NZBs from Sonarr/Radarr, submits them to TorBox, waits
until TorBox has finished, then **downloads the files locally** to `data_root` so the
*arr app can import them.

> Every grab ends up on your Home Assistant disk as well as in TorBox. Keep an eye on
> free space, or point `data_root` at a network share.

## Installation

1. Add this repository: `https://github.com/koraysels/hassio-addons`
2. Install **TorBoxarr**
3. **Configuration** tab: fill in `torbox_api_token`, and pick a `qbit_password`
   and `sab_api_key`
4. Start the add-on

## Connecting Sonarr / Radarr

**Usenet (NZB)** — Settings → Download Clients → + → **SABnzbd**

| Field    | Value                         |
|----------|-------------------------------|
| Host     | your HA IP                    |
| Port     | `8085`                        |
| API Key  | your `sab_api_key`            |
| Category | `sonarr` or `radarr`          |

**Torrents** (optional, if you don't use Decypharr) — **qBittorrent**, port `8085`,
username `admin`, password `qbit_password`.

Completed downloads appear in `/share/torboxarr/completed/<category>`. Sonarr and Radarr
see `/share` at the same path, so no remote path mapping is needed.
