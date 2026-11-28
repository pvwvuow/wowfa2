"""Report only: the dub studio scripts parse (node --check) and the loader builds the shipped database.
Counts the Forever lines per category and the player race packs (race x sex), as the page shows them."""
import json
import subprocess

FILES = ["tools/dub-studio/" + f for f in ("voice_db.js", "dsp.js", "loader.js", "app.js")]
JS = r"""
global.window = global;
require(process.cwd() + '/tools/dub-studio/voice_db.js');
require(process.cwd() + '/tools/dub-studio/loader.js');
const R = window.VO_RAW, D = window.WfaBuild.build(R.L, R.G), fv = new Set(R.FV || []);
const PLAY = {human:1, dwarf:1, gnome:1, nightelf:1, orc:1, troll:1, tauren:1, scourge:1};
const cat = {}, packs = {}, kinds = {};
let shown = 0, fvAll = 0;
for (const l of D.lines) {
  if (!fv.has(l[0])) continue;
  const g = D.groups[l[1]]; shown++;
  const k = g[1] + ':' + D.cats[l[2]]; cat[k] = (cat[k] || 0) + 1;
  if (g[1] === 'h') { const r = l[7] || g[3]; if (PLAY[r]) { const p = r + ' ' + (l[5] || g[2] || 'u'); const a = packs[p] || (packs[p] = [0, 0, 0]); a[0]++; if (l[2] === 6) a[2]++; else a[1]++; } else { kinds['h-norace'] = (kinds['h-norace'] || 0) + 1; } }
}
for (const x of R.L) if (fv.has(x[0])) fvAll++;
console.log(JSON.stringify({groups: D.groups.length, lines: D.lines.length, fvAll, shown, cat, packs, kinds}));
"""


def run(args, rep):
    rep.h("Syntax")
    for f in FILES:
        r = subprocess.run(["node", "--check", f], capture_output=True, text=True)
        if r.returncode:
            rep.fail("%s: %s" % (f, (r.stderr or r.stdout)[-600:]))
        else:
            rep.ok("%s parses" % f)
    rep.h("Loader on the shipped database")
    r = subprocess.run(["node", "-e", JS], capture_output=True, text=True)
    if r.returncode:
        rep.fail("loader failed: %s" % (r.stderr or r.stdout)[-1200:])
        return []
    d = json.loads(r.stdout.strip().splitlines()[-1])
    rep.ok("%d groups, %d lines shown; Forever lines: %d in the database, %d shown (the rest are footsteps and other non-voice)" % (d["groups"], d["lines"], d["fvAll"], d["shown"]))
    for k, n in sorted(d["cat"].items()):
        rep.add("- %s: %d" % (k, n))
    rep.add("player race packs (lines, spoken+emote, body reactions):")
    for k, a in sorted(d["packs"].items()):
        rep.add("- %s: %d (%d, %d)" % (k, a[0], a[1], a[2]))
    rep.add("player lines without a playable race: %s" % d["kinds"])
    return []
