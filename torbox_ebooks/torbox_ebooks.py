"""Copy finished ebooks from TorBox into the Calibre-Web Automated ingest folder.

Only files whose extension is listed in `extensions` are downloaded; video and
everything else stays in TorBox. Each copied file is remembered in /data/state.json
so it is fetched once, even after CWA has moved it out of the ingest folder.
"""
import json
import os
import re
import time
import urllib.parse
import urllib.request

OPTIONS_PATH = "/data/options.json"
STATE_PATH = "/data/state.json"
API = "https://api.torbox.app/v1/api"
USER_AGENT = "hassio-torbox-ebooks/1.0"

# (list endpoint, requestdl id parameter)
SOURCES = {
    "usenet": ("usenet/mylist", "usenet_id"),
    "torrents": ("torrents/mylist", "torrent_id"),
}


def log(msg):
    print(f"[TorBox-Ebooks] {msg}", flush=True)


def load_json(path, default):
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, ValueError):
        return default


def save_state(state):
    tmp = STATE_PATH + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f)
    os.replace(tmp, STATE_PATH)


def api_get(path, token, params=None, auth_header=True):
    url = f"{API}/{path}"
    if params:
        url += "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    if auth_header:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=60) as resp:
        body = json.load(resp)
    if not body.get("success"):
        raise RuntimeError(body.get("error") or body.get("detail") or "TorBox API error")
    return body.get("data")


def safe_name(name):
    name = os.path.basename(name)
    name = re.sub(r'[\\/:*?"<>|\x00-\x1f]', "_", name).strip(" .")
    return name or "ebook"


def unique_path(directory, name):
    stem, ext = os.path.splitext(name)
    path, n = os.path.join(directory, name), 1
    while os.path.exists(path):
        path = os.path.join(directory, f"{stem} ({n}){ext}")
        n += 1
    return path


def download(url, tmp_dir, ingest_dir, name):
    os.makedirs(tmp_dir, exist_ok=True)
    tmp_path = os.path.join(tmp_dir, name + ".part")
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=300) as resp, open(tmp_path, "wb") as out:
        while chunk := resp.read(1 << 16):
            out.write(chunk)
    # Same filesystem as the ingest dir, so CWA never sees a half-written file
    final = unique_path(ingest_dir, name)
    os.replace(tmp_path, final)
    return final


def ebook_files(items, extensions):
    for item in items or []:
        if not item.get("download_present"):
            continue
        for f in item.get("files") or []:
            name = f.get("short_name") or f.get("name") or ""
            if os.path.splitext(name)[1].lower().lstrip(".") in extensions:
                yield item, f, name


def run_once(opts, state, extensions, tmp_dir):
    token = opts["torbox_api_token"]
    seen = set(state["seen"])
    sources = ["usenet"] + (["torrents"] if opts.get("include_torrents", True) else [])
    copied = 0

    for kind in sources:
        list_path, id_param = SOURCES[kind]
        try:
            items = api_get(list_path, token, {"bypass_cache": "true"})
        except Exception as e:  # network/API hiccup: retry next round
            log(f"could not list {kind}: {e}")
            continue

        for item, f, name in ebook_files(items, extensions):
            key = f"{kind}:{item['id']}:{f['id']}"
            if key in seen:
                continue
            if not state["initialized"] and not opts.get("import_existing", True):
                seen.add(key)
                continue
            try:
                url = api_get(f"{kind}/requestdl", token,
                              {"token": token, id_param: item["id"], "file_id": f["id"]},
                              auth_header=False)
                path = download(url, tmp_dir, opts["ingest_dir"], safe_name(name))
                log(f"copied {os.path.basename(path)}")
                seen.add(key)
                copied += 1
            except Exception as e:
                log(f"failed {name}: {e}")

    if not state["initialized"] and not opts.get("import_existing", True):
        log(f"first run: skipped {len(seen)} existing ebook(s) (import_existing is off)")
    state["seen"] = sorted(seen)
    state["initialized"] = True
    save_state(state)
    return copied


def main():
    opts = load_json(OPTIONS_PATH, {})
    if not opts.get("torbox_api_token"):
        log("torbox_api_token is empty — fill it in on the Configuration tab.")
        raise SystemExit(1)

    ingest_dir = opts.get("ingest_dir") or "/share/calibre/ingest"
    opts["ingest_dir"] = ingest_dir
    os.makedirs(ingest_dir, exist_ok=True)
    # Sibling of the ingest dir: same filesystem, outside CWA's watch
    tmp_dir = os.path.join(os.path.dirname(ingest_dir.rstrip("/")), ".torbox_ebooks_tmp")

    extensions = {e.strip().lower().lstrip(".") for e in opts.get("extensions", "").split(",") if e.strip()}
    interval = max(1, int(opts.get("interval_minutes", 5))) * 60
    state = load_json(STATE_PATH, {"seen": [], "initialized": False})

    log(f"watching TorBox every {interval // 60} min for: {', '.join(sorted(extensions))}")
    log(f"ingest folder: {ingest_dir}")
    while True:
        copied = run_once(opts, state, extensions, tmp_dir)
        if copied:
            log(f"{copied} new ebook(s) handed to Calibre-Web Automated")
        time.sleep(interval)


if __name__ == "__main__":
    main()
