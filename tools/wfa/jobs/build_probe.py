"""Report only: run the release build the way the release task does and show WHY it stops
(a gate that exits instead of raising never reaches the report)."""
import os
import traceback

from wfa import build as B
from wfa.core import ROOT, read_json
from wfa.store import Store


def run(args, rep):
    pol = read_json(os.path.join(ROOT, "policy.json"))
    rep.h("Build probe")
    rep.add("- version %s, game_build %s" % (pol.get("version"), pol.get("game_build")))
    try:
        counts, zpath, notes = B.build(Store.load(), pol)
        rep.ok("build ok: %s" % os.path.basename(str(zpath)))
        rep.add("- notes: %s" % str(notes)[:1500])
    except BaseException as e:  # noqa: BLE001 (SystemExit too)
        rep.fail("build stopped: %r" % (e,))
        rep.add("```\n" + traceback.format_exc()[-3500:] + "\n```")
    return []
