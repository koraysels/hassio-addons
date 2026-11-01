# TorBoxarr

TorBoxarr accepts torrents and NZBs from Sonarr/Radarr and submits them to TorBox.

With `remote_only` on (the default) that is all it does: once TorBox has finished, the
job is reported as completed and **nothing is downloaded locally**. Watch it from
Stremio via the TorBox addon. Sonarr/Radarr will keep the item as "completed, not
imported" because there are no local files.

With `remote_only` off, TorBoxarr downloads finished files to `data_root` so the *arr
app can import them — keep an eye on free disk space in that mode.

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
