"""English source for what data/ still lacks, from the open CMaNGOS classic database
(github.com/cmangos/classic-db, Full_DB/*.sql.gz, GPL): quest_template texts and creature_template names.

For every quest whose Persian record lacks a field that has English text (t Title, obj Objectives,
det Details, pro RequestItemsText, com OfferRewardText) or that has no record at all, and for every
creature name without a Persian row in names/npc|boss, work files are written for the translators:
  ci/work/qtext/NNN.json   [{id, level, en:{field: English}, fa:{field: Persian already there}}]  (25 quests)
  ci/work/npcnew/NNN.json  [{en, sub, lv}]  (200 names, highest level first)
args: url (the .sql.gz; default: the newest in Full_DB), per_q, per_n.
"""
import gzip
import io
import json
import os
import re
import shutil
import urllib.request

from wfa.core import name_key
from wfa.store import Store

API = "https://api.github.com/repos/cmangos/classic-db/contents/Full_DB"
QF = (("t", "title"), ("obj", "objectives"), ("det", "details"), ("pro", "requestitemstext"), ("com", "offerrewardtext"))
SKIP = re.compile(r"\[ph\]|unused|\bdnd\b|trigger|dummy|\btest\b|\(|zzold|deprecated|placeholder", re.I)


def _get(url, accept=None):
    h = {"User-Agent": "wowfa2-ci"}
    if accept:
        h["Accept"] = accept
    with urllib.request.urlopen(urllib.request.Request(url, headers=h), timeout=300) as r:
        return r.read()


def tuples(s, i):
    """yield value lists of a VALUES (...),(...); statement starting at s[i]"""
    n = len(s)
    while i < n:
        while i < n and s[i] != "(":
            if s[i] == ";":
                return
            i += 1
        if i >= n:
            return
        i += 1
        row, cur, q = [], [], False
        while i < n:
            c = s[i]
            if q:
                if c == "\\" and i + 1 < n:
                    nx = s[i + 1]
                    cur.append({"n": "\n", "r": "\r", "t": "\t", "0": ""}.get(nx, nx))
                    i += 2
                    continue
                if c == "'":
                    if i + 1 < n and s[i + 1] == "'":
                        cur.append("'")
                        i += 2
                        continue
                    q = False
                    i += 1
                    continue
                cur.append(c)
                i += 1
                continue
            if c == "'":
                q = True
            elif c == ",":
                row.append("".join(cur).strip())
                cur = []
            elif c == ")":
                row.append("".join(cur).strip())
                i += 1
                break
            else:
                cur.append(c)
            i += 1
        yield row


def parse(sql, table):
    cols = []
    m = re.search(r"CREATE TABLE `%s` \((.*?)\n\)" % table, sql, re.S)
    if m:
        for line in m.group(1).split("\n"):
            mm = re.match(r"\s*`([^`]+)`", line)
            if mm:
                cols.append(mm.group(1).lower())
    rows = []
    for m in re.finditer(r"INSERT INTO `%s`(?: \([^)]*\))? VALUES" % table, sql):
        for r in tuples(sql, m.end()):
            if len(r) == len(cols):
                rows.append(dict(zip(cols, r)))
    return cols, rows


def clean(v):
    v = (v or "").strip()
    return "" if v.upper() == "NULL" else v


def write_shards(d, items, per):
    if os.path.isdir(d):
        shutil.rmtree(d)
    os.makedirs(d)
    out = []
    for k in range(0, len(items), per):
        p = os.path.join(d, "%03d.json" % (k // per))
        with open(p, "w", encoding="utf-8", newline="\n") as fh:
            json.dump(items[k:k + per], fh, ensure_ascii=False, indent=1)
            fh.write("\n")
        out.append(p)
    return out


def run(args, rep):
    store = Store.load()
    url = args.get("url")
    rep.h("Source")
    try:
        if not url:
            lst = json.loads(_get(API))
            gz = [x for x in lst if x.get("name", "").endswith(".sql.gz")]
            url = sorted(gz, key=lambda x: x["name"])[-1]["download_url"]
        raw = _get(url)
        sql = gzip.GzipFile(fileobj=io.BytesIO(raw)).read().decode("utf-8", "replace")
    except Exception as e:
        rep.fail("cannot read the CMaNGOS dump: %s" % e)
        return []
    rep.ok("%s (%d MB sql)" % (url.rsplit("/", 1)[-1], len(sql) // 1048576))
    qcols, qrows = parse(sql, "quest_template")
    ccols, crows = parse(sql, "creature_template")
    rep.ok("quest_template: %d columns, %d rows; creature_template: %d columns, %d rows" % (len(qcols), len(qrows), len(ccols), len(crows)))
    if not qrows or not crows:
        rep.fail("a table did not parse")
        return []
    qwork, fields_missing, no_rec = [], {f: 0 for f, _c in QF}, 0
    for r in qrows:
        try:
            qid = int(r.get("entry"))
        except Exception:
            continue
        en = {f: clean(r.get(c)) for f, c in QF}
        en = {f: v for f, v in en.items() if v}
        if not en:
            continue
        rec = store.quests.get(qid)
        if rec is None:
            no_rec += 1
            need = dict(en)
        else:
            need = {f: v for f, v in en.items() if not rec.get(f)}
        if not need:
            continue
        for f in need:
            fields_missing[f] += 1
        try:
            lv = int(r.get("questlevel") or 0)
        except Exception:
            lv = 0
        have = {f: rec.get(f) for f, _c in QF if rec and rec.get(f)} if rec else {}
        qwork.append({"id": qid, "level": lv, "en": need, "title_en": en.get("t", ""), "fa": have})
    qwork.sort(key=lambda x: (-x["level"], x["id"]))
    npc = store.names.get("npc", {})
    boss = store.names.get("boss", {})
    seen, nwork = set(), []
    for r in crows:
        en = clean(r.get("name"))
        if not en or SKIP.search(en):
            continue
        k = name_key(en)
        if k in npc or k in boss or k in seen:
            continue
        seen.add(k)
        try:
            lv = int(r.get("maxlevel") or r.get("minlevel") or 0)
        except Exception:
            lv = 0
        nwork.append({"en": en, "sub": clean(r.get("subname")), "lv": lv})
    nwork.sort(key=lambda x: (-x["lv"], x["en"]))
    per_q = int(args.get("per_q", 25))
    per_n = int(args.get("per_n", 200))
    paths = write_shards("ci/work/qtext", qwork, per_q) + write_shards("ci/work/npcnew", nwork, per_n)
    rep.h("Quests")
    rep.ok("%d quests need text (%d have no record); missing fields: %s" % (len(qwork), no_rec, ", ".join("%s %d" % kv for kv in fields_missing.items())))
    bands = {}
    for q in qwork:
        b = "%02d+" % ((max(q["level"], 1) - 1) // 10 * 10 + 1)
        bands[b] = bands.get(b, 0) + 1
    rep.table(sorted(bands.items()), ["level from", "quests needing text"])
    rep.h("Creature names")
    rep.ok("%d creature names have no Persian row" % len(nwork))
    nb = {}
    for x in nwork:
        b = "%02d+" % ((max(x["lv"], 1) - 1) // 10 * 10 + 1)
        nb[b] = nb.get(b, 0) + 1
    rep.table(sorted(nb.items()), ["level from", "names"])
    rep.add("top: " + "; ".join("%s (L%d)" % (x["en"], x["lv"]) for x in nwork[:40]))
    rep.ok("%d work files" % len(paths))
    return ["ci/work/qtext", "ci/work/npcnew"]
