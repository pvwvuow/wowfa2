"""npc_unify with the rules of an earlier task file, plus fixes found in its dry run (the owner 25 Nov).

args: base (path of the earlier task json, its npc_unify rules and sets are used), apply, show
"""
import importlib.util
import json
import pathlib


def run(args, rep):
    root = pathlib.Path(__file__).resolve().parents[3]
    base = json.loads((root / args["base"]).read_text(encoding="utf-8"))["args"]["args"]
    spec = importlib.util.spec_from_file_location("wfa_npc_unify", pathlib.Path(__file__).with_name("npc_unify.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    rules = [list(r) for r in base["rules"]]
    out = []
    for r in rules:
        if r[0] == "worg":
            r[0] = r"\bworg\b"
        elif r[0] == "elemental":
            r[0] = r"^(?!.*trainer).*elemental"
        if r[0] == "reaver" and not any(x[0] == "reaver" for x in out):
            out.append(["reaver", "\u062f\u0631\u0646\u062f\u0647\u0654", "\u063a\u0627\u0631\u062a\u06af\u0631"])
        out.append(r)
    # fatha and damma go with the kasra
    out.insert(1, [".*", "\u064e", ""])
    out.insert(2, [".*", "\u064f", ""])
    out.append(["gnoll", "\u06af\u0646\u0648\u0644\u0644", "\u06af\u0646\u0648\u0644"])
    base["rules"] = out
    base["apply"] = bool(args.get("apply"))
    base["show"] = int(args.get("show", 60))
    return mod.run(base, rep)
