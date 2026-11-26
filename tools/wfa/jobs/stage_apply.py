"""Apply a staged change set: first the patch_src ops (all-or-nothing), then copy whole staged
files (ci/stage/<id>/...) over their targets. args: ops [...] (patch_src format), files
[[staged path, target path], ...]. Nothing is copied when an op fails. Returns the changed paths."""
import importlib.util
import pathlib
import shutil

ROOT = pathlib.Path(__file__).resolve().parents[3]


def _patch():
    spec = importlib.util.spec_from_file_location("wfa_patch_src", pathlib.Path(__file__).with_name("patch_src.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run(args, rep):
    changed = []
    ops = args.get("ops") or []
    if ops:
        changed = _patch().run({"ops": ops}, rep)
        if not changed:
            rep.fail("ops failed: no file copied")
            return []
    rep.h("files")
    for src, dst in args.get("files") or []:
        s, d = ROOT / src, ROOT / dst
        if not s.is_file():
            rep.fail("staged file missing: %s" % src)
            return []
        if not str(dst).startswith(("addon/", "tests/", "tools/")):
            rep.fail("target outside addon/ tests/ tools/: %s" % dst)
            return []
        d.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(s, d)
        rep.ok("%s -> %s (%d bytes)" % (src, dst, d.stat().st_size))
        changed.append(dst)
    return sorted(set(changed))
