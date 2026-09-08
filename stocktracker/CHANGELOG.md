# 1.0.1

- New options: `allow_registration` (default off), `price_refresh_hour`,
  `log_level`.
- Daily refresh now runs at the configured local hour instead of a rolling
  24-hour timer.
- Watchdog: Home Assistant restarts the add-on if the app stops responding.
- Fixed: `allow_registration: false` was silently read as true (jq treats
  `false` as absent with the `//` operator).

# 1.0.0

First release: PDF import with dedup, derived positions and history, live
quotes, intraday and daily charts, realised earnings, fees, sectors, watchlist,
market hours, multi-currency with EUR reporting.
