"""Read a player's SavedVariables file (WTF/Account/<acc>/SavedVariables/WoWFA.lua) that was
pushed to ci/inbox/ and turn what the addon harvested into ONE translation worklist:
  - x: NPC talk / speech / books (Modules/Dialog.lua) whose key has no template yet,
  - q: quest parts with no Persian (Modules/Harvest.lua), n: NPC names with no Persian,
  - miss: the update-watch list (F:Miss) of the saved settings.
Only English game text is read; player / realm / account data is never kept (the file itself
is deleted from the inbox by this job). args: path (ci/inbox/WoWFA.lua), keep (false).
Writes ci/results/harvest-<build>.json; returns it (and the deleted inbox file)."""
import json
import os
import re

from wfa.store import Store

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


class P:
    """a small parser for the SavedVariables subset of Lua (tables, strings, numbers, bools, nil)"""

    def __init__(self, s):
        self.s, self.i = s, 0

    def ws(self):
        s = self.s
        while self.i < len(s):
            if s[self.i] in " \t\r\n,;":
                self.i += 1
            elif s.startswith("--", self.i):
                j = s.find("\n", self.i)
                self.i = len(s) if j < 0 else j + 1
            else:
                break

    def val(self):
        self.ws()
        s, i = self.s, self.i
        c = s[i]
        if c == "{":
            return self.table()
        if c in "\"'":
            return self.string()
        m = re.compile(r"-?\d+(\.\d+)?([eE][-+]?\d+)?").match(s, i)
        if m:
            self.i = m.end()
            t = m.group(0)
            return float(t) if ("." in t or "e" in t.lower()) else int(t)
        for w, v in (("true", True), ("false", False), ("nil", None)):
            if s.startswith(w, i):
                self.i += len(w)
                return v
        raise ValueError("unexpected %r at %d" % (s[i:i + 20], i))

    def string(self):
        s, q = self.s, self.s[self.i]
        self.i += 1
        out = bytearray()
        while True:
            c = s[self.i]
            if c == q:
                self.i += 1
                return out.decode("utf-8", "replace")
            if c == "\\":
                self.i += 1
                e = s[self.i]
                m = re.compile(r"\d{1,3}").match(s, self.i)
                if m:
                    out.append(int(m.group(0)) & 255)
                    self.i = m.end()
                    continue
                out += {"n": b"\n", "t": b"\t", "r": b"\r", "\n": b"\n"}.get(e, e.encode("utf-8"))
                self.i += 1
                continue
            out += c.encode("utf-8")
            self.i += 1

    def table(self):
        self.i += 1
        d, arr = {}, []
        while True:
            self.ws()
            if self.s[self.i] == "}":
                self.i += 1
                return d if d or not arr else arr
            if self.s[self.i] == "[":
                self.i += 1
                k = self.val()
                self.ws()
                assert self.s[self.i] == "]"
                self.i += 1
                self.ws()
                assert self.s[self.i] == "="
                self.i += 1
                d[k] = self.val()
            else:
                m = re.compile(r"[A-Za-z_]\w*\s*=").match(self.s, self.i)
                if m:
                    self.i = m.end()
                    d[m.group(0)[:-1].strip()] = self.val()
                else:
                    arr.append(self.val())


def parse(text):
    out = {}
    for m in re.finditer(r"^([A-Za-z_]\w*)\s*=\s*", text, re.M):
        p = P(text)
        p.i = m.end()
        try:
            out[m.group(1)] = p.val()
        except Exception as e:  # one broken variable never hides the others
            out[m.group(1)] = {"_error": str(e)}
    return out


def run(args, rep):
    rel = args.get("path", "ci/inbox/WoWFA.lua")
    path = os.path.join(ROOT, rel)
    if not os.path.isfile(path):
        rep.fail("no file %s (push the player's WoWFA.lua there first)" % rel)
        return []
    with open(path, encoding="utf-8", errors="replace") as f:
        sv = parse(f.read())
    store = Store.load()
    h = sv.get("WoWFA_Harvest") or {}
    fdb = sv.get("WoWFA_FDB") or {}
    build = str(h.get("b") or "?")
    x = h.get("x") or {}
    work = {"build": build, "addon": h.get("v"), "x": [], "q": [], "n": [], "miss": []}
    have_tpl = 0
    for _, e in sorted(x.items(), key=lambda kv: -int((kv[1] or {}).get("n") or 1)):
        if not isinstance(e, dict) or not e.get("key"):
            continue
        if e["key"] in store.tpl:
            have_tpl += 1
            continue
        work["x"].append({"kind": e.get("k"), "key": e["key"], "en": e.get("t"), "ctx": e.get("c"),
                          "zone": e.get("z"), "seen": e.get("n", 1)})
    for qid, e in sorted((h.get("q") or {}).items(), key=lambda kv: str(kv[0])):
        if isinstance(e, dict):
            work["q"].append(dict({"id": qid}, **{k: v for k, v in e.items() if k in ("t", "obj", "det", "pro", "com", "o", "lv", "z")}))
    npcs = store.names.get("npc", {})
    for en, e in sorted((h.get("n") or {}).items(), key=lambda kv: str(kv[0])):
        if str(en).lower() not in npcs:
            work["n"].append({"en": en, "lv": (e or {}).get("lv"), "zone": (e or {}).get("z")})
    for _, e in sorted(((fdb.get("miss") or {}) if isinstance(fdb.get("miss"), dict) else {}).items(),
                       key=lambda kv: -int((kv[1] or {}).get("n") or 1)):
        if isinstance(e, dict):
            work["miss"].append({"kind": e.get("k"), "en": e.get("t"), "ctx": e.get("c"), "seen": e.get("n", 1)})
    rep.h("harvest of build %s (addon %s)" % (build, work["addon"]))
    rep.table([("NPC talk / speech / books without Persian", len(work["x"])),
               ("  already translated since (skipped)", have_tpl),
               ("quests with missing parts", len(work["q"])), ("NPC names without Persian", len(work["n"])),
               ("update-watch misses", len(work["miss"]))], ["list", "rows"])
    kinds = {}
    for r in work["x"]:
        kinds[r["kind"]] = kinds.get(r["kind"], 0) + 1
    rep.ok("talk kinds: %s" % json.dumps(kinds))
    for r in work["x"][:25]:
        rep.add("- %s (%sx) %s: %s" % (r["kind"], r["seen"], r.get("ctx") or "", str(r["en"])[:160]))
    out = os.path.join(ROOT, "ci", "results", "harvest-%s.json" % re.sub(r"[^\w.]", "_", build))
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8") as f:
        json.dump(work, f, ensure_ascii=False, indent=1)
        f.write("\n")
    paths = [os.path.relpath(out, ROOT)]
    if not args.get("keep"):
        os.remove(path)  # the player's own file never stays in the repo
        paths.append(rel)
    rep.ok("worklist written: %s" % paths[0])
    return paths
