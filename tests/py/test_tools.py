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


def test_num_key_vectors():
    """tests/numkey_vectors.txt is shared with tests/run.lua: both sides must key identically."""
    from wfa.core import num_key
    path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "numkey_vectors.txt")
    n = 0
    for line in open(path, encoding="utf-8"):
        if line.startswith("#") or not line.strip():
            continue
        en, key, nums = line.rstrip("\n").split("\t")
        k, ns = num_key(en.replace("\\n", "\n"))
        assert (k, ";".join(ns)) == (key, nums), (en, k, ns)
        n += 1
    assert n >= 10


def test_spells_import():
    from wfa.spells import import_classes
    s = Store()
    s.names["spell"]["volley"] = "\u0631\u06af\u0628\u0627\u0631"
    s.names["spell"]["charge"] = "\u06cc\u0648\u0631\u0634"
    s.tpl["kept #"] = "x {0}"
    w = {"build": "b", "tabs": [{"n": "Arms", "fa": "\u0633\u0644\u0627\u062d"}],
         "spells": [{"n": "Charge", "fa": "OTHER",
                     "d": "Charge an enemy, generate 15 Rage, and Stun it for 1 sec.",
                     "dFa": "\u0628\u0647 {{sp:Charge|\u06cc\u0648\u0631\u0634}} 15 \u062e\u0634\u0645 \u0648 1 \u062b\u0627\u0646\u06cc\u0647",
                     "reqs": ["Requires Battle Stance"], "reqsFa": ["\u0646\u06cc\u0627\u0632"]}],
         "trees": [{"n": "Arms", "fa": "\u0633\u0644\u0627\u062d", "tiers": [[
             {"n": "Spearing Strike", "fa": "\u0646\u06cc\u0632\u0647",
              "d": "Deals 75% weapon damage, 75% more to Giants.", "dFa": "40% \u0648 80%"},
             {"n": "Flurry", "fa": "\u0631\u06af\u0628\u0627\u0631"},
             {"n": "Twin", "fa": "\u062f\u0648", "d": "Gives 2% and 2% more.", "dFa": "2% \u0648 2%"},
             {"n": "Swap", "fa": "\u062c\u0627", "d": "Hits for 5 then 5 over 9 sec.", "dFa": "9 \u062b\u0627\u0646\u06cc\u0647 5 \u0648 5"},
             {"n": "Latin", "fa": "\u0644", "d": "Grants 3 armor.", "dFa": "3 armor"},
             {"n": "Kept", "fa": "\u06a9", "d": "Kept 4.", "dFa": "y 4"}]]}]}
    r = import_classes(s, {"warrior": w}, banned=[])
    key = "charge an enemy, generate # rage, and stun it for # sec"
    assert s.tpl[key] == "\u0628\u0647 {{sp:Charge}} {0} \u062e\u0634\u0645 \u0648 {1} \u062b\u0627\u0646\u06cc\u0647", s.tpl[key]
    assert s.tpl["requires battle stance"] == "\u0646\u06cc\u0627\u0632"
    assert s.names["spell"]["charge"] == "\u06cc\u0648\u0631\u0634"          # fill-only: the table wins
    assert any("Charge" in c for c in r["conflict"])
    assert "flurry" not in s.names["spell"] and r["pair_reject"]             # name_pairs guard
    assert any(x["w"].endswith("Spearing Strike (talent)") for x in r["num_mismatch"])
    assert s.tpl["gives #% and #% more"] == "{0}% \u0648 {1}%"                 # equal values, same order: ok
    assert "hits for # then # over # sec" not in s.tpl                        # equal values reordered: ambiguous
    assert "grants # armor" not in s.tpl and r["gate_reject"]                 # latin_in_fa guard
    assert s.tpl["kept #"] == "x {0}"                                         # existing template untouched
    assert s.names["tree"]["arms"] == "\u0633\u0644\u0627\u062d"


if __name__ == "__main__":
    n = 0
    for k, f in sorted(globals().items()):
        if k.startswith("test_"):
            f()
            n += 1
            print("ok", k)
    print("%d python tests passed" % n)
