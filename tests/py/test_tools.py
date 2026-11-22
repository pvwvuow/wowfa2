"""Pure-Python tests for tools/wfa (run by CI before the build)."""
import json
import os
import sys
import tempfile

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "tools"))
from wfa import build as B, lint as L, migrate as M          # noqa: E402
from wfa.core import lua_str, name_key, title_hash           # noqa: E402
from wfa.resolve import canon, resolve, shorten              # noqa: E402
from wfa.store import Store                                  # noqa: E402

FA_BLINK_OLD, FA_BLINK = "\u0628\u0631\u0642\u200c\u067e\u0627", "\u062c\u0647\u0634 \u0622\u0646\u06cc"
POL = {"version": "t", "interface": 1, "game_build": "b",
       "ship": {"surfaces": [], "names": ["spell", "zone", "class", "tree"]}, "floors": {}, "ratchet": {}}


def test_name_key():
    assert name_key("  The  Barrens ") == "barrens"
    assert name_key("Light\u2019s Vigil") == "light's vigil"


def test_hash_stable():
    assert title_hash("The Defias Brotherhood") == title_hash("defias  brotherhood")
    assert len(title_hash("x")) == 8


def test_lua_str():
    assert lua_str('a"b\\c\n\x1f') == '"a\\"b\\\\c\\n\\031"'


def test_shorten_resolve_roundtrip():
    names = {"spell": {"blink": FA_BLINK}, "npc": {"hogger": "\u0647\u0627\u06af\u0631"}}
    swaps = {}
    old = "x {{sp:Blink|%s}} y {{npc:Hogger|\u0647\u0627\u06af\u0631}} z {{npc:Bob|\u0628\u0627\u0628}} {{tm:healing|\u0634\u0641\u0627\u06cc}}" % FA_BLINK_OLD
    s = shorten(old, names, swaps, {})
    assert "{{sp:Blink}}" in s and "{{npc:Hogger}}" in s
    assert "{{npc:Bob|" in s and "{{tm:healing|" in s           # unknown npc + terms stay full
    assert list(swaps.values()) == [1]
    r = resolve(s, names)
    assert canon(old, names) == canon(r, names)
    assert ("{{sp:Blink|%s}}" % FA_BLINK) in r


def test_lint_gates():
    s = Store()
    s.tpl["deals # damage over # sec"] = "{0} \u0622\u0633\u06cc\u0628 \u062f\u0631 {1} \u062b\u0627\u0646\u06cc\u0647"
    s.tpl["bad # slot"] = "{3} \u0628\u062f"
    s.names["spell"]["blink"] = FA_BLINK
    s.names["spell"]["blink2"] = FA_BLINK
    s.quests[5] = {"h": "0000abcd", "t": "\u0639\u0646\u0648\u0627\u0646 \ufffd", "obj": "{{zz:broken}}"}
    r = L.run(s, POL)
    gates = {g for g, _, _ in r.errors}
    assert "slot" in gates and "chars" in gates and "marker" in gates, gates
    assert "name_pairs_spell" in r.ratchet
    pol = dict(POL, floors={"quests": 10})
    assert any(g == "floor" for g, _, _ in L.run(s, pol).errors)


def test_migrate_and_verify():
    names = {"spell": {"blink": FA_BLINK}, "zone": {"elwynn forest": "\u0627\u0644\u0648\u06cc\u0646"}}
    rec = "\x1f".join(["Hogger", "\u0647\u0627\u06af\u0631", "kill {{sp:Blink|%s}}" % FA_BLINK_OLD, "", "", "", ""])
    old_q = {"names": names, "quests": {"176": rec}, "qobj": {"176": ["{{zn:Elwynn Forest|\u0627\u0644\u0648\u06cc\u0646}}"]}}
    old_t = {"tpl": {"teleports # yards": "{0} \u06cc\u0627\u0631\u062f {{sp:Blink|%s}}" % FA_BLINK_OLD}}
    store, rep = M.migrate(old_q, old_t, None)
    assert store.quests[176]["h"] == title_hash("Hogger")
    assert store.quests[176]["obj"] == "kill {{sp:Blink}}"
    assert store.quests[176]["o"] == ["{{zn:Elwynn Forest}}"]
    with tempfile.TemporaryDirectory() as d:
        store.save(d)
        again = Store.load(d)
        assert again.quests == store.quests and again.tpl == store.tpl
        assert again.names["spell"] == store.names["spell"]
    new = {"quests": {"176": B.quest_record(store.quests[176], store.names)},
           "qobj": {"176": [resolve(x, store.names) for x in store.quests[176]["o"]]},
           "tpl": {k: resolve(v, store.names) for k, v in store.tpl.items()}}
    st, diffs = M.verify(old_q, old_t, new, store.names)
    assert not diffs, diffs
    assert st["quests_same"] == 1 and st["tpl_same"] == 1


if __name__ == "__main__":
    n = 0
    for k, f in sorted(globals().items()):
        if k.startswith("test_"):
            f()
            n += 1
            print("ok", k)
    print("%d python tests passed" % n)
