# Decypharr

Decypharr exposes a qBittorrent-compatible API. Sonarr and Radarr send releases to it,
and Decypharr adds them to your debrid provider (e.g. TorBox). You can then watch them
from Stremio via the TorBox addon, without storing anything on Home Assistant.

## Installation

1. Add this repository to Home Assistant:
   **Settings → Add-ons → Add-on Store → ⋮ → Repositories**
   Paste `https://github.com/koraysels/hassio-addons` and click **Add**
2. Find **Decypharr** in the store and click **Install**
3. Click **Start**, then **Open Web UI** (port 8282)

## First-time setup (wizard)

1. **Authentication** — create an admin user. Save the API token shown at the end.
2. **Debrid** — add provider `torbox` with your API key from the TorBox dashboard.
3. **Mount** — choose **None**. No FUSE mount is needed when you stream from Stremio.
4. Complete the setup.

Under **Settings → Arrs**, add Sonarr and Radarr (host + API key) and set the
download action to **none**, so files stay in TorBox.

## Connecting Sonarr / Radarr

In Sonarr/Radarr: **Settings → Download Clients → + → qBittorrent**

| Field    | Value                                        |
|----------|----------------------------------------------|
| Host     | your HA IP (e.g. `192.168.1.254`)            |
| Port     | `8282`                                       |
| Username | the Arr URL, e.g. `http://192.168.1.254:8989` |
| Password | the Arr API key (Settings → General)         |
| Category | `sonarr` or `radarr`                         |

Click **Test**, then **Save**.

## Data

Configuration lives in the add-on's `/data` folder and is included in HA backups.
