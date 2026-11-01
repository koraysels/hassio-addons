# TorBox Ebooks

Every few minutes this add-on lists your finished TorBox downloads (usenet and,
optionally, torrents). Any file with an ebook extension is downloaded into the
Calibre-Web Automated ingest folder, where CWA imports it into your library.

- Only ebook files are downloaded; video stays in TorBox.
- Each file is copied once. The add-on remembers what it copied in `/data/state.json`,
  so deleting a book from Calibre does not bring it back.
- Files are written to a temporary folder next to the ingest folder first, so CWA
  never sees a half-downloaded file.

## Installation

1. Add this repository: `https://github.com/koraysels/hassio-addons`
2. Install **TorBox Ebooks**
3. **Configuration** tab: paste your TorBox API token
4. Start the add-on and check the **Log** tab

Requires the **Calibre-Web Automated** add-on from this repository (or any app that
watches the same ingest folder).
