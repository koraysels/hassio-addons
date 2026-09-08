# Stocktracker add-on

Home Assistant packaging for [Stocktracker](https://github.com/koraysels/stocktracker),
a personal portfolio tracker. The app source lives in its own repository; this
directory only holds the add-on manifest. Images are prebuilt by that repo's
release workflow and pulled from GHCR.

Releasing a new version: tag `vX.Y.Z` in the app repo, wait for the publish
workflow, then bump `version:` in `config.yaml` here.
