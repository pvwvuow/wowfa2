"""add_tpl with the rows sent as gzip + base64 inside the task (a long Persian batch pasted as
plain ASCII; the sha256 of the unpacked JSON is checked, a wrong copy writes nothing).
args: b64 (one string or a list of lines), sha256 (of the unpacked JSON object {key: persian})"""
import base64
import gzip
import hashlib
import importlib.util
import json
import pathlib


def run(args, rep):
    b64 = args.get("b64") or ""
    if isinstance(b64, list):
        b64 = "".join(b64)
    want = str(args.get("sha256") or "").lower()
    rep.h("unpack")
    try:
        body = gzip.decompress(base64.b64decode(b64))
    except Exception as e:  # noqa: BLE001 - the report must say why
        rep.fail("unpack failed: %s" % type(e).__name__)
        return []
    if hashlib.sha256(body).hexdigest() != want:
        rep.fail("sha256 differs: the pasted text is not the one that was packed")
        return []
    rows = json.loads(body.decode("utf-8"))
    rep.ok("%d rows unpacked" % len(rows))
    p = pathlib.Path(__file__).with_name("add_tpl.py")
    spec = importlib.util.spec_from_file_location("wfa_job_add_tpl_b", p)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.run({"rows": rows}, rep)
