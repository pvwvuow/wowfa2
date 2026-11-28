"""Spoken texts for the dub studio (tools/dub-studio/voice_db.js, field T = {file id: [english, persian, heard]}).

Two things, both kept in ci/data so every rebuild of voice_db.js keeps them:
  ci/data/vo_fa.json   {english text: persian}  hand translations, meaning-first (matched loosely: case and punctuation)
  ci/data/vo_stt.json  {file id: [english or "", avg_logprob, no_speech_prob]}  what whisper heard in the audio
                       (empty results are kept too, so a file is never heard twice)
and writes ci/data/vo_todo.json: [[english, files, group], ...] every text still without Persian (for the translator).

args:
  stt      true to hear the lines that have no text yet (faster-whisper on the CPU, audio from the Wowhead CDN)
  model    whisper model (default base.en)
  limit    max files to hear in this run (default 1500)
  minutes  time budget for hearing (default 35); progress is saved, the next run goes on from there
  cats     raw categories to hear (default [0, 1, 2, 3] = greeting, farewell, pissed, aggro)
"""
import concurrent.futures
import hashlib
import importlib
import json
import os
import re
import site
import subprocess
import sys
import tempfile
import time
import traceback
import urllib.error
import urllib.request

DB = "tools/dub-studio/voice_db.js"
FA = "ci/data/vo_fa.json"
STT = "ci/data/vo_stt.json"
TODO = "ci/data/vo_todo.json"
CDN = "https://wow.zamimg.com/wowsounds/%d"
# what whisper says on noise; never a real line on its own
NOWORDS = re.compile(r"wound|attack|death|dying|footstep|foot|loop|fidget|stand|idle|breath|jump|land|crit|swim|mount|exert|effort|grunt|growl|roar|snarl|hiss|howl|precast|channel|stun|parry|dodge|block|knock|wing")
JUNK = {"", "you", "thank you", "thanks for watching", "bye", "oh", "ah", "uh", "hmm", "huh", "mm", "um", "so", "okay"}


def key(s):
    return re.sub(r"[^a-z0-9'$]+", " ", str(s or "").lower()).strip()


def _load(p, default):
    try:
        return json.load(open(p, encoding="utf-8"))
    except (OSError, ValueError):
        return default


def heard_ok(v):
    if not isinstance(v, list) or not v or not isinstance(v[0], str):
        return ""
    en = re.sub(r"\s+", " ", v[0]).strip()
    lp = v[1] if len(v) > 1 and isinstance(v[1], (int, float)) else -9
    ns = v[2] if len(v) > 2 and isinstance(v[2], (int, float)) else 1
    if key(en) in JUNK or not re.search(r"[A-Za-z]{2}", en):
        return ""
    if lp < -0.9 or ns > 0.6:
        return ""
    return en


def merge(L, T, rep=None):
    """T gets every heard text (marked 1) and every Persian translation; returns T."""
    fa_map = {key(k): v for k, v in _load(FA, {}).items() if isinstance(v, str) and v.strip()}
    stt = _load(STT, {})
    added = 0
    for x in L:
        f = str(x[0])
        if f in T:
            continue
        en = heard_ok(stt.get(f))
        if en:
            T[f] = [en, "", 1]
            added += 1
    nfa = 0
    for f, v in T.items():
        if not v[1]:
            fa = fa_map.get(key(v[0]), "")
            if fa:
                v[1] = fa
                nfa += 1
    if rep:
        rep.ok("%d heard texts added, %d lines got Persian from %s (%d entries)" % (added, nfa, FA, len(fa_map)))
    return T


def read_db():
    s = open(DB, encoding="ascii").read()
    a = s.index("=") + 1
    return json.loads(s[a:s.rindex(";")])


def write_db(out):
    out["v"] = 0
    body = json.dumps(out, ensure_ascii=True, separators=(",", ":"))
    out["v"] = int(hashlib.sha1(body.encode()).hexdigest()[:8], 16)
    js = "window.VO_RAW=" + json.dumps(out, ensure_ascii=True, separators=(",", ":")) + ";\n"
    open(DB, "w", encoding="ascii", newline="\n").write(js)
    return len(js)


def todo(out):
    L, G, T = out["L"], out["G"], out["T"]
    gi = {str(x[0]): x[1] for x in L}
    seen = {}
    for f, v in T.items():
        if v[1]:
            continue
        k = key(v[0])
        if k not in seen:
            g = gi.get(f)
            seen[k] = [v[0], 0, G[g][0] if g is not None and g < len(G) else ""]
        seen[k][1] += 1
    return sorted(seen.values(), key=lambda r: (r[2].lower(), r[0].lower()))


def _whisper(rep):
    try:
        import faster_whisper  # noqa: F401
        return True
    except ImportError:
        pass
    for extra in (["--break-system-packages"], []):
        r = subprocess.run([sys.executable, "-m", "pip", "install", "--quiet", "--user"] + extra + ["faster-whisper"],
                           capture_output=True, text=True)
        if r.returncode == 0:
            break
    else:
        rep.fail("pip install faster-whisper failed: %s" % (r.stderr or r.stdout)[-400:])
        return False
    site.addsitedir(site.getusersitepackages())
    importlib.invalidate_caches()
    try:
        import faster_whisper  # noqa: F401
        return True
    except ImportError as e:
        rep.fail("faster-whisper not importable: %s" % e)
        return False


def _fetch(fid, d):
    p = os.path.join(d, str(fid))
    req = urllib.request.Request(CDN % fid, headers={"User-Agent": "Mozilla/5.0 wowfa-dub"})
    err = "fail"
    for i in range(3):
        try:
            b = urllib.request.urlopen(req, timeout=30).read()
            if len(b) < 200:
                return fid, None, "tiny"
            open(p, "wb").write(b)
            return fid, p, ""
        except urllib.error.HTTPError as e:
            if e.code in (403, 404):
                return fid, None, "http %d" % e.code
            time.sleep(1 + i)
        except Exception as e:  # noqa: BLE001
            err = type(e).__name__
            time.sleep(1 + i)
    return fid, None, err


def _pcm(p):
    """16 kHz mono float32 decoded here with PyAV (any version; faster-whisper's own decoder breaks on
    PyAV 15+), with ffmpeg as the fallback when it exists."""
    import numpy
    first = None
    try:
        import av
        out = []
        with av.open(p) as c:
            rs = av.AudioResampler(format="flt", layout="mono", rate=16000)
            for fr in c.decode(audio=0):
                for f2 in rs.resample(fr) or []:
                    out.append(f2.to_ndarray().reshape(-1))
            for f2 in rs.resample(None) or []:
                out.append(f2.to_ndarray().reshape(-1))
        if out:
            return numpy.concatenate(out).astype(numpy.float32)
        first = ValueError("PyAV decoded no audio")
    except Exception as e:  # noqa: BLE001 - try ffmpeg next
        first = e
    try:
        r = subprocess.run(["ffmpeg", "-v", "error", "-i", p, "-ac", "1", "-ar", "16000", "-f", "f32le", "-"],
                           capture_output=True, check=True)
    except FileNotFoundError:
        raise first from None
    return numpy.frombuffer(r.stdout, dtype=numpy.float32)


def hear(out, args, rep):
    L, G, T = out["L"], out["G"], out["T"]
    stt = _load(STT, {})
    # fv: hear every line of the Forever client (voice_forever FV) that has no text and may hold words, player races first
    fvo = set(out.get("FV") or []) if args.get("fv") else None
    cats = None if (fvo is not None or args.get("cats") == "all") else [int(c) for c in args.get("cats", [0, 1, 2, 3])]
    limit = int(args.get("limit", 1500))
    budget = float(args.get("minutes", 35)) * 60
    cand = []
    for x in L:
        f = str(x[0])
        if (cats is not None and x[2] not in cats) or f in T or f in stt:
            continue
        g = G[x[1]] if x[1] < len(G) else ["", ""]
        if fvo is not None:
            if x[0] not in fvo or NOWORDS.search(x[3].lower()):
                continue
        elif x[2] == 3 and not (x[4] or "npc" in x[3] or g[1] == "h"):
            continue  # creature aggro noises: nothing to hear
        cand.append(x)
    cand.sort(key=lambda x: (G[x[1]][1] != "h" if x[1] < len(G) else True, x[0] >= 600000, cats.index(x[2]) if cats else 0, x[1], x[0]))
    rep.ok("%d lines without a text in categories %s; hearing up to %d" % (len(cand), cats, limit))
    cand = cand[:limit]
    if not cand or not _whisper(rep):
        return 0
    from faster_whisper import WhisperModel
    t0 = time.time()
    model = WhisperModel(str(args.get("model", "base.en")), device="cpu", compute_type="int8",
                         cpu_threads=os.cpu_count() or 2)
    rep.add("model %s loaded in %.0f s" % (args.get("model", "base.en"), time.time() - t0))
    heard, miss, n, samples, errs = 0, {}, 0, [], []
    opts = {"language": "en", "beam_size": 5, "vad_filter": True, "condition_on_previous_text": False}
    grp = {x[0]: G[x[1]][0] for x in cand}
    with tempfile.TemporaryDirectory() as d, concurrent.futures.ThreadPoolExecutor(8) as ex:
        futs = [ex.submit(_fetch, x[0], d) for x in cand]
        for fu in futs:
            if time.time() - t0 > budget:
                rep.add("time budget reached; the next run goes on")
                break
            if n >= 40 and miss.get("error", 0) >= n - 5:
                rep.add("every file fails to decode; stopping")
                break
            fid, p, err = fu.result()
            n += 1
            if not p:
                miss[err] = miss.get(err, 0) + 1
                stt[str(fid)] = ["", 0, 1, err]
                continue
            try:
                segs = None
                for src, kw in ((None, opts), (None, {"language": "en", "beam_size": 5}), (p, opts)):
                    try:
                        if src is None:
                            src = _pcm(p)
                        segs = list(model.transcribe(src, **kw)[0])
                        break
                    except Exception as e:  # noqa: BLE001 - try the plain call, then report
                        if len(errs) < 4:
                            errs.append("%d %s: %s | %s" % (fid, type(e).__name__, e,
                                        traceback.format_exc().strip().splitlines()[-3:]))
                if segs is None:
                    miss["error"] = miss.get("error", 0) + 1
                    continue  # not saved: a later run hears it again
            finally:
                try:
                    os.remove(p)
                except OSError:
                    pass
            txt = re.sub(r"\s+", " ", " ".join(s.text.strip() for s in segs)).strip()
            lp = round(sum(s.avg_logprob for s in segs) / len(segs), 3) if segs else 0
            ns = round(max(s.no_speech_prob for s in segs), 3) if segs else 1
            stt[str(fid)] = [txt, lp, ns]
            if heard_ok(stt[str(fid)]):
                heard += 1
                if len(samples) < 25:
                    samples.append("%d %s: %s (%.2f)" % (fid, grp.get(fid, ""), txt, lp))
        for fu in futs:
            fu.cancel()
    os.makedirs("ci/data", exist_ok=True)
    json.dump(stt, open(STT, "w", encoding="utf-8"), ensure_ascii=True, separators=(",", ":"), sort_keys=True)
    open(STT, "a").write("\n")
    rep.ok("heard %d files in %.0f s: %d usable texts; not on the CDN or unreadable: %s" %
           (n, time.time() - t0, heard, miss or "none"))
    for s in errs:
        rep.add("error: " + s)
    for s in samples:
        rep.add(s)
    left = len([x for x in L if (cats is None or x[2] in cats) and str(x[0]) not in T and str(x[0]) not in stt])
    rep.add("still to hear in these categories (before the aggro filter): %d" % left)
    return n


def run(args, rep):
    rep.h("Database")
    out = read_db()
    T0 = json.dumps(out["T"], sort_keys=True)
    rep.ok("%d files, %d texts" % (len(out["L"]), len(out["T"])))
    changed = []
    if args.get("stt"):
        rep.h("Hearing")
        if hear(out, args, rep):
            changed.append(STT)
    rep.h("Merge")
    merge(out["L"], out["T"], rep)
    if json.dumps(out["T"], sort_keys=True) != T0:
        n = write_db(out)
        changed.append(DB)
        rep.ok("%s rewritten: %d bytes, %d texts" % (DB, n, len(out["T"])))
    rep.h("To translate")
    td = todo(out)
    os.makedirs("ci/data", exist_ok=True)
    s = json.dumps(td, ensure_ascii=True, indent=0) + "\n"
    if not os.path.exists(TODO) or open(TODO, encoding="utf-8").read() != s:
        open(TODO, "w", encoding="utf-8", newline="\n").write(s)
        changed.append(TODO)
    done = len([v for v in out["T"].values() if v[1]])
    rep.ok("%d texts in all, %d with Persian; %d distinct texts still to translate (%s)" %
           (len(out["T"]), done, len(td), TODO))
    return changed
