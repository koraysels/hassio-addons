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

The source, documentation and issue tracker live at
https://github.com/koraysels/stocktracker.

## Data

Everything is stored in `/data` (the add-on's persistent volume): the SQLite
database and the generated secret key. Uploaded PDFs are parsed in memory and
never stored. Prices and exchange rates refresh once a day by themselves.
