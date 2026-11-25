"""Review of every Persian name in data/: NPC, boss, zone and quest titles.

Per kind it writes plain-text work lists (one 'english = persian' line each) to ci/reports/rev/:
  <kind>_ortho.txt   spelling / typing problems (Arabic yeh and kaf, diacritics, bad half-spaces, spaces,
                     Latin letters, ASCII punctuation, name left in English)
  <kind>_hard.txt    Arabic-only letters inside names that are not Arabic words (usually a mis-heard letter)
  <kind>_vary.txt    English words whose Persian differs from name to name (same word, several translations)
  <kind>_odd.txt     names that miss the usual Persian of one of their English words
  <kind>_all.txt     everything, sorted (only with all=true)
args: kinds (default npc,boss,zone,quest), all (bool), min_n (default 4).
"""
import json
import os
import re
import urllib.request
from collections import Counter, defaultdict

from wfa.store import Store

Z = "\u200c"
DIAC = re.compile("[\u064b-\u0652\u0670]")
ARAB = re.compile("[\u064a\u0643\u0629\u0649\u06c0]")
HARD = set("\u062b\u0630\u062d\u0636\u0635\u0637\u0638\u0639\u0642\u063a")
STOP = {"the", "of", "and", "a", "an", "in", "to", "de", "la", "for", "on", "at", "s"}


def fetch(repo, path, ref="main"):
    url = "https://api.github.com/repos/pvwvuow/%s/contents/%s?ref=%s" % (repo, path, ref)
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""),
                                               "Accept": "application/vnd.github.raw", "User-Agent": "wowfa2-ci"})
    with urllib.request.urlopen(req, timeout=180) as r:
        return r.read().decode("utf-8")


def ortho(en, fa):
    out = []
    if ARAB.search(fa):
        out.append("arab")
    if DIAC.search(fa):
        out.append("diac")
    if "  " in fa or fa != fa.strip():
        out.append("space")
    if fa.startswith(Z) or fa.endswith(Z) or Z + Z in fa or (Z + " ") in fa or (" " + Z) in fa:
        out.append("zwnj")
    if re.search("[A-Za-z]", fa):
        out.append("latin")
    if re.search("[0-9]", fa) and not re.search("[0-9]", en):
        out.append("digit")
    if re.search("(?:^|\\s)(?:\u0646\u0645\u06cc|\u0645\u06cc) \\S", fa):
        out.append("mi")
    if re.search("\\S \u0647\u0627(?:\\s|$)", fa):
        out.append("ha")
    if re.search("[,;?\"%]", fa):
        out.append("punct")
    if fa.strip().lower() == en.strip().lower():
        out.append("same")
    return out


def toks_en(k):
    ws = [w.strip("'") for w in re.findall("[a-z0-9']+", k)]
    return [w for w in ws if len(w) > 2 and w not in STOP]


def toks_fa(fa):
    return [t for t in re.split("\\s+", fa.strip()) if t]


def kind_rows(store, kind):
    if kind == "quest":
        try:
            data = json.loads(fetch("wow-raw", "fdb/latest/quests.json"))
        except Exception:
            return None
        rows = data.get("quests") if isinstance(data, dict) else data
        if isinstance(rows, dict):
            rows = list(rows.values())
        out = []
        for q in rows or []:
            rec = store.quests.get(int(q.get("id") or 0))
            if rec and rec.get("t") and q.get("name"):
                out.append((q["name"].strip(), re.sub("\\{\\{[a-z]+:([^|}]*)\\|?([^}]*)\\}\\}", lambda m: m.group(2) or m.group(1), rec["t"])))
        return out
    return list(store.names.get(kind, {}).items())


def run(args, rep):
    store = Store.load()
    kinds = [k.strip() for k in str(args.get("kinds", "npc,boss,zone,quest")).split(",") if k.strip()]
    min_n = int(args.get("min_n", 4))
    want_all = bool(args.get("all", False))
    d = "ci/reports/rev"
    os.makedirs(d, exist_ok=True)
    paths = []
    summary = []

    def put(name, lines):
        p = "%s/%s.txt" % (d, name)
        with open(p, "w", encoding="utf-8", newline="\n") as fh:
            fh.write("\n".join(lines) + ("\n" if lines else ""))
        paths.append(p)

    for kind in kinds:
        rows = kind_rows(store, kind)
        if rows is None:
            rep.fail("cannot read the ForeverDB quest names")
            continue
        rows = [(en, fa) for en, fa in rows if isinstance(fa, str) and fa]
        # --- spelling
        bad = []
        for en, fa in sorted(rows):
            codes = ortho(en, fa)
            if codes:
                bad.append("%s = %s   [%s]" % (en, fa, ",".join(codes)))
        hard = []
        for en, fa in sorted(rows):
            if any(c in HARD for c in fa):
                hard.append("%s = %s" % (en, fa))
        put("%s_ortho" % kind, bad)
        put("%s_hard" % kind, hard)
        # --- same English word, different Persian
        gfa = Counter()
        for en, fa in rows:
            for t in set(toks_fa(fa)):
                gfa[t] += 1
        by_w = defaultdict(list)
        for en, fa in rows:
            ws = set(toks_en(en.lower()))
            for w in ws:
                by_w[w].append((en, fa))
        vary, odd = [], []
        for w, lst in sorted(by_w.items(), key=lambda kv: (-len(kv[1]), kv[0])):
            n = len(lst)
            if n < min_n:
                continue
            c = Counter()
            for en, fa in lst:
                for t in set(toks_fa(fa)):
                    c[t] += 1
            sc = sorted(((cnt / float(n + gfa[t] - cnt), t, cnt) for t, cnt in c.items() if cnt >= 2), reverse=True)
            if not sc:
                continue
            top = sc[0]
            if top[2] / float(n) < 0.85:
                vary.append("%s (%d): %s" % (w, n, " | ".join("%s %d" % (t, cnt) for _j, t, cnt in sc[:4])))
            elif top[0] > 0.5:
                dom = top[1]
                for en, fa in lst:
                    if len(toks_en(en.lower())) >= 2 and dom not in toks_fa(fa):
                        odd.append("%s = %s   [%s -> %s]" % (en, fa, w, dom))
        put("%s_vary" % kind, vary)
        put("%s_odd" % kind, sorted(set(odd)))
        if want_all:
            put("%s_all" % kind, ["%s = %s" % (en, fa) for en, fa in sorted(rows)])
        summary.append((kind, len(rows), len(bad), len(hard), len(vary), len(set(odd))))
    rep.h("Review lists")
    rep.table(summary, ["kind", "names", "spelling", "hard letters", "varying words", "odd names"])
    rep.ok("%d files in ci/reports/rev" % len(paths))
    return paths
