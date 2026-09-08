# Stocktracker

[![Add repository to my Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fkoraysels%2Fhassio-addons)

Personal portfolio tracker that runs entirely on your own box. Drop in the
contract-note PDFs your broker already sends you (MeDirect, Bolero) and it
derives everything else — no broker login, no cloud, no subscriptions.

## What it does

- **Import contract notes in bulk** — duplicates are detected and skipped, so
  re-uploading a folder is always safe. PDFs are parsed in memory and never
  stored.
- **Live prices** while the page is open (US real-time, Europe ~15 min), with
  daily history built automatically every evening.
- **The whole picture** — positions, value over time (24H to All), realised
  earnings from sales, fees paid, sector exposure, a watchlist, break-even per
  holding, market open/closed per exchange.
- **Multi-currency done honestly** — holdings in USD/CHF/EUR, reported in EUR
  at real daily rates, with one click to the native currency.
- **Multi-user** — optional open registration; every account sees only its own
  portfolio.

## Quick start

1. Install the add-on, set **Admin username** and **Admin password** in
   Configuration, start it.
2. Open `http://<your-ha-host>:8000` and sign in.
3. Go to **Import** and drop in your contract-note PDFs — prices, exchange
   rates and company data fetch themselves.

Your database lives in `/data`, is included in Home Assistant backups, and
survives updates. The add-on restarts itself if the app ever stops responding.

App source and issue tracker: [koraysels/stocktracker](https://github.com/koraysels/stocktracker).
