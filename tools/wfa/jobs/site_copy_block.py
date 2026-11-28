"""Copy one block of a page from the source site repo (pvwvuow/wow) into the public one (pvwvuow/wowfarsiir),
straight on main with BOT_TOKEN (the publish run does not push every page, see the earlier site commits).
args: path (report.html), begin (text the block starts with in the source), before (text of the public page the
block is put in front of), msg. Does nothing when the public page already has the begin text.
Only .html files. Nothing in this repo changes."""
import base64
import json
import os
import urllib.error
import urllib.request

OWNER = "pvwvuow"


def api(method, path, body=None):
    req = urllib.request.Request("https://api.github.com" + path, method=method,
                                 data=json.dumps(body).encode() if body is not None else None,
                                 headers={"Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""),
                                          "Accept": "application/vnd.github+json", "User-Agent": "wowfa2-ci"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, json.loads(r.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        return e.code, {}


def get(repo, path):
    st, cur = api("GET", "/repos/%s/%s/contents/%s?ref=main" % (OWNER, repo, path))
    if st != 200 or not isinstance(cur, dict) or not cur.get("content"):
        return None, None
    return base64.b64decode(cur["content"]).decode("utf-8"), cur["sha"]


def run(args, rep):
    path = str(args.get("path") or "")
    begin = str(args.get("begin") or "")
    before = str(args.get("before") or "")
    if not path.endswith(".html") or ".." in path or path.startswith(".github") or not begin or not before:
        rep.fail("path (.html), begin and before are needed")
        return []
    src, _ = get("wow", path)
    pub, sha = get("wowfarsiir", path)
    if src is None or pub is None:
        rep.fail("could not read %s from one of the repos" % path)
        return []
    if begin in pub:
        rep.ok("the public page already has it, nothing to do")
        return []
    a = src.find(begin)
    b = src.find(before, a + 1)
    if a < 0 or b < 0:
        rep.fail("block not found in the source page (begin %s, end %s)" % (a, b))
        return []
    block = src[a:b]
    if pub.count(before) != 1:
        rep.fail("the public page has %d places for the block, wanted 1" % pub.count(before))
        return []
    new = pub.replace(before, block + before)
    st, res = api("PUT", "/repos/%s/wowfarsiir/contents/%s" % (OWNER, path),
                  {"message": args.get("msg") or "site: copy a block", "content": base64.b64encode(new.encode("utf-8")).decode(),
                   "sha": sha, "branch": "main"})
    (rep.ok if st in (200, 201) else rep.fail)("%s: HTTP %s, block of %d bytes put in front of the note" % (path, st, len(block.encode())))
    return []
