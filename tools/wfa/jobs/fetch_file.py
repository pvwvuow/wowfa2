"""Download one data file (a short-lived HTTPS relay URL) into ci/data/ and check its sha256.

Used when a data set is too big to paste into a task file (thousands of rows). The task
carries the url, the target path and the expected sha256; a wrong hash writes nothing.

args: url (https), path (must start with ci/data/ and end with .json), sha256, max_bytes (3000000)
"""
import hashlib
import json
import pathlib
import urllib.request

_P = pathlib.Path(__file__).resolve().parents
ROOT = _P[3] if len(_P) > 3 else pathlib.Path.cwd()


def run(args, rep):
    url = str(args.get('url') or '')
    path = str(args.get('path') or '')
    want = str(args.get('sha256') or '').lower()
    limit = int(args.get('max_bytes', 3000000))
    rep.h('Fetch')
    if not url.startswith('https://'):
        rep.fail('the url must be https')
        return []
    if not path.startswith('ci/data/') or not path.endswith('.json') or '..' in path:
        rep.fail('the path must be ci/data/<name>.json')
        return []
    if len(want) != 64:
        rep.fail('sha256 missing')
        return []
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'wowfa2-ci'})
        with urllib.request.urlopen(req, timeout=90) as r:
            body = r.read(limit + 1)
    except Exception as e:  # noqa: BLE001 - the report must say why
        rep.fail('download failed: %s' % type(e).__name__)
        return []
    if len(body) > limit:
        rep.fail('file larger than %d bytes' % limit)
        return []
    got = hashlib.sha256(body).hexdigest()
    if got != want:
        rep.fail('sha256 differs: got %s, want %s' % (got[:12], want[:12]))
        return []
    try:
        data = json.loads(body.decode('utf-8'))
    except ValueError:
        rep.fail('the file is not valid JSON')
        return []
    out = ROOT / path
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(body)
    rep.ok('%s written: %d bytes, %d entries, sha256 %s' % (path, len(body), len(data), got[:12]))
    return ['data']
