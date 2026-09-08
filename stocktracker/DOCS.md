# Stocktracker

Personal portfolio tracker. Import your MeDirect or Bolero contract-note PDFs
and it derives everything else: positions, value history, live quotes, realised
earnings, fees. All data stays in the add-on's own database on your box.

## Setup

1. Set **admin_username** and **admin_password** in the configuration tab —
   this creates (or updates) your login on the next start.
2. If you reach Home Assistant on something other than
   `http://homeassistant.local`, set **trusted_origin** to that address with
   port 8000, e.g. `http://192.168.1.10:8000`.
3. Start the add-on and open `http://<your-ha-host>:8000`.

## Options

| Option | What it does |
| --- | --- |
| `admin_username` / `admin_password` | Your login. Created on first start, password re-applied on every restart — change it here, restart, done. |
| `trusted_origin` | The address you browse to, e.g. `http://192.168.1.10:8000`. Needed so uploads and forms pass Django's CSRF check. |
| `allow_registration` | Off by default: only your admin account exists. Turn on to let household members create their own (each account sees only its own portfolio). |
| `price_refresh_hour` | Local hour (0–23) for the daily price and FX refresh. Default 19: European closes are in; the US close lands the next evening. |
| `log_level` | `info` unless debugging. |
| `TZ` | Timezone for the refresh hour and dates. |

The web port is remapped on the add-on's **Network** card like any add-on —
update `trusted_origin` to match if you change it. The add-on restarts itself
if the app stops responding (watchdog), and `/data` — your database — is
included in Home Assistant backups automatically.

The source, documentation and issue tracker live at
https://github.com/koraysels/stocktracker.

## Data

Everything is stored in `/data` (the add-on's persistent volume): the SQLite
database and the generated secret key. Uploaded PDFs are parsed in memory and
never stored. Prices and exchange rates refresh once a day by themselves.
