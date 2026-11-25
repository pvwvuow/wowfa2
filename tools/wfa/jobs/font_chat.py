"""Build addon/WoWFA/Fonts/WoWFAChat.ttf: ONE font for the chat that looks like the game's chat
(the owner 25 Nov, two screenshots: "with Persian chat on the messages look stretched and low
quality"). The game's English chat font is Arial Narrow and has no Persian letters, so a chat
window that must show Persian needs a font with both:
  - Latin, digits, punctuation: Liberation Sans 2.x (SIL OFL 1.1, metric twin of Arial) narrowed
    to the Arial Narrow width (x * 0.82), keeping its vertical metrics = the game's line height;
  - Persian / Arabic letters and presentation forms (what the addon's shaper writes): Vazirmatn
    (SIL OFL 1.1, already shipped), scaled to the same units per em.
Both are OFL, the result is OFL under its own name (Reserved Font Names are not used).
Hinting is dropped (narrowed outlines break it); WoW renders the outlines smoothly.
args: narrow (0.82), fa_scale (1.0), preview (true). Returns the font, its licence file and a
preview PNG (ci/results/chatfont.png)."""
import os
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
FONTS = os.path.join(ROOT, "addon", "WoWFA", "Fonts")
OUTF = os.path.join(FONTS, "WoWFAChat.ttf")
LIC = os.path.join(FONTS, "WoWFAChat-OFL.txt")
PREVIEW = os.path.join(ROOT, "ci", "results", "chatfont.png")
FA_RANGES = [(0x0600, 0x06FF), (0x0750, 0x077F), (0x08A0, 0x08FF), (0xFB50, 0xFDFF), (0xFE70, 0xFEFF),
             (0x200C, 0x200F), (0x2066, 0x2069), (0x061C, 0x061C)]


def sh(*cmd):
    print("+ " + " ".join(cmd), flush=True)
    return subprocess.run(list(cmd), check=False, capture_output=True, text=True)


def find_liberation2(rep):
    cands = ["/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf",
             "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"]
    from fontTools.ttLib import TTFont

    def ok(p):
        if not os.path.isfile(p):
            return False
        f = TTFont(p)
        ver = str(f["name"].getDebugName(5) or "")
        lic = str(f["name"].getDebugName(13) or "")
        rep.add("- candidate %s: %s / %s" % (p, ver, lic[:80]))
        return "Open Font License" in lic and not ver.startswith("Version 1.")
    for p in cands:
        if ok(p):
            return p
    sh("sudo", "apt-get", "update", "-qq")
    r = sh("sudo", "apt-get", "install", "-y", "-qq", "fonts-liberation2")
    rep.add("- apt fonts-liberation2: rc %d" % r.returncode)
    for p in cands:
        if ok(p):
            return p
    raise SystemExit("no OFL Liberation Sans 2.x found")


def strip_hints(font):
    from fontTools.ttLib.tables import ttProgram
    for t in ("fpgm", "prep", "cvt ", "hdmx", "LTSH", "VDMX", "DSIG", "kern", "GPOS", "GSUB", "GDEF", "morx", "feat"):
        if t in font:
            del font[t]
    for g in font["glyf"].glyphs.values():
        if hasattr(g, "program"):
            g.program = ttProgram.Program()
            g.program.fromBytecode(b"")


def run(args, rep):
    deps = "/tmp/wfa-pydeps"
    r = sh(sys.executable, "-m", "pip", "install", "-q", "--target", deps, "fonttools>=4.40", "pillow")
    rep.add("- pip fonttools pillow: rc %d %s" % (r.returncode, (r.stderr or "")[-300:]))
    if deps not in sys.path:
        sys.path.insert(0, deps)
    import importlib
    importlib.invalidate_caches()
    from fontTools.ttLib import TTFont, newTable
    from fontTools.ttLib.scaleUpem import scale_upem
    sx = float(args.get("narrow", 0.82))
    fa_scale = float(args.get("fa_scale", 1.0))
    rep.h("sources")
    lib = find_liberation2(rep)
    vaz_path = os.path.join(FONTS, "Vazirmatn.ttf")
    base = TTFont(lib)
    vaz = TTFont(vaz_path)
    upm = base["head"].unitsPerEm
    rep.ok("Latin: %s (upm %d), Persian: Vazirmatn (upm %d)" % (os.path.basename(lib), upm, vaz["head"].unitsPerEm))
    if vaz["head"].unitsPerEm != upm:
        scale_upem(vaz, upm)
    # 1. the Latin: narrowed to the Arial Narrow width
    vaz.ensureDecompiled() if hasattr(vaz, "ensureDecompiled") else None
    strip_hints(base)
    glyf, hmtx = base["glyf"], base["hmtx"]
    order = list(base.getGlyphOrder())
    for name in order:
        g = glyf[name]
        if g.isComposite():
            for c in g.components:
                c.x = int(round(c.x * sx))
        elif g.numberOfContours > 0:
            co = g.coordinates
            for i in range(len(co)):
                x, y = co[i]
                co[i] = (int(round(x * sx)), y)
        w, l = hmtx.metrics[name]
        hmtx.metrics[name] = (int(round(w * sx)), int(round(l * sx)))
    # 2. the Persian glyphs (+ their components) from Vazirmatn
    strip_hints(vaz)
    vg, vm = vaz["glyf"], vaz["hmtx"]
    vcmap = vaz.getBestCmap()
    want = {cp: gn for cp, gn in vcmap.items() if any(a <= cp <= b for a, b in FA_RANGES)}
    newname = {}

    def add(gn):
        if gn in newname:
            return newname[gn]
        nn = "fa." + gn
        newname[gn] = nn
        g = vg[gn]
        if g.isComposite():
            for c in g.components:
                c.glyphName = add(c.glyphName)
                c.x, c.y = int(round(c.x * fa_scale)), int(round(c.y * fa_scale))
        elif g.numberOfContours > 0 and fa_scale != 1.0:
            co = g.coordinates
            for i in range(len(co)):
                x, y = co[i]
                co[i] = (int(round(x * fa_scale)), int(round(y * fa_scale)))
        w, l = vm.metrics[gn]
        glyf.glyphs[nn] = g
        hmtx.metrics[nn] = (int(round(w * fa_scale)), int(round(l * fa_scale)))
        order.append(nn)
        return nn
    for cp, gn in sorted(want.items()):
        add(gn)
    base.setGlyphOrder(order)
    glyf.glyphOrder = order
    n_cmap = 0
    for t in base["cmap"].tables:
        if t.isUnicode() or (t.platformID == 3 and t.platEncID in (1, 10)):
            for cp, gn in want.items():
                if t.format == 4 and cp > 0xFFFF:
                    continue
                t.cmap[cp] = newname[gn]
            n_cmap += 1
    rep.ok("Persian code points %d, glyphs added %d, cmap tables %d" % (len(want), len(newname), n_cmap))
    # 3. tables that must follow
    if "post" in base:
        base["post"].formatType = 3.0
        base["post"].extraNames, base["post"].mapping = [], {}
    if "gasp" not in base:
        base["gasp"] = newTable("gasp")
    base["gasp"].gaspRange = {0xFFFF: 0x000A}  # smooth at every size, no grid fitting
    base["head"].flags &= ~(1 << 4)
    os2 = base["OS/2"]
    os2.ulUnicodeRange1 |= (1 << 13)  # Arabic
    os2.ulUnicodeRange2 |= (1 << 31)  # Arabic presentation forms A (bit 63)
    os2.ulUnicodeRange3 |= (1 << 0)   # Arabic presentation forms B (bit 64)
    if hasattr(os2, "ulCodePageRange1"):
        os2.ulCodePageRange1 |= (1 << 6)  # 1256 Arabic
    os2.xAvgCharWidth = int(round(os2.xAvgCharWidth * sx))
    # 4. names: a new family (no reserved names), both copyrights, the OFL
    cp_lib = str(TTFont(lib)["name"].getDebugName(0) or "Liberation Sans: Copyright (c) 2012 Red Hat, Inc.")
    cp_vaz = str(TTFont(vaz_path)["name"].getDebugName(0) or "Vazirmatn: Copyright (c) Saber Rastikerdar")
    cpy = "Latin: %s Persian: %s Merged and narrowed for WoWFA (wowfarsi.ir)." % (cp_lib, cp_vaz)
    nt = base["name"]
    nt.names = []
    for nid, s in ((0, cpy), (1, "WoWFA Chat"), (2, "Regular"), (3, "WoWFA Chat Regular 1.0"),
                   (4, "WoWFA Chat Regular"), (5, "Version 1.000"), (6, "WoWFAChat-Regular"),
                   (13, "This Font Software is licensed under the SIL Open Font License, Version 1.1."),
                   (14, "https://openfontlicense.org")):
        nt.setName(s, nid, 3, 1, 0x409)
        nt.setName(s, nid, 1, 0, 0)
    base.save(OUTF)
    chk = TTFont(OUTF)
    bc = chk.getBestCmap()
    miss = [hex(c) for c in (0x41, 0x61, 0x30, 0x628, 0x6CC, 0xFEB3, 0xFEFC, 0xFB8B, 0x200C) if c not in bc]
    (rep.fail if miss else rep.ok)("reload check, missing code points: %s" % (miss or "none"))
    rep.ok("WoWFAChat.ttf %d bytes, %d glyphs, ascender %d descender %d (upm %d)" % (
        os.path.getsize(OUTF), len(chk.getGlyphOrder()), chk["hhea"].ascent, chk["hhea"].descent, upm))
    # 5. the licence file shipped next to it
    with open(os.path.join(FONTS, "OFL.txt"), encoding="utf-8") as f:
        ofl = f.read()
    with open(LIC, "w", encoding="utf-8", newline="\n") as f:
        f.write("WoWFA Chat (WoWFAChat.ttf)\n%s\n\nLatin glyphs from Liberation Sans 2.x (SIL OFL 1.1), "
                "Persian glyphs from Vazirmatn (SIL OFL 1.1).\nThe full licence text follows.\n\n%s"
                % (cpy, ofl if ofl.endswith("\n") else ofl + "\n"))
    paths = [os.path.relpath(OUTF, ROOT), os.path.relpath(LIC, ROOT)]
    # 6. a preview: the game-like reference (Liberation Sans Narrow 1.07 if the runner has it,
    # only for this picture), the new font, and the old Vazirmatn
    if args.get("preview", True):
        try:
            from PIL import Image, ImageDraw, ImageFont
            ref = None
            for p in ("/usr/share/fonts/truetype/liberation/LiberationSansNarrow-Regular.ttf",):
                if os.path.isfile(p):
                    ref = p
            if not ref:
                sh("sudo", "apt-get", "install", "-y", "-qq", "fonts-liberation")
                p = "/usr/share/fonts/truetype/liberation/LiberationSansNarrow-Regular.ttf"
                ref = p if os.path.isfile(p) else None
            line = "02:49 [Party Leader] [Lux Belator]: ah thought we would snipe it 1234"
            fa = "\ufeb3\ufefc\ufee1 \ufe91\ufeae \ufead\ufeee\ufeb1\ufe98\ufe8e\ufee5"[::-1]
            rows = [("reference (Arial Narrow twin)", ref, line), ("NEW WoWFA Chat", OUTF, line),
                    ("NEW WoWFA Chat Persian", OUTF, fa + "  " + line[:20]), ("OLD Vazirmatn", vaz_path, line)]
            img = Image.new("RGB", (1300, 60 + 70 * len(rows)), (40, 22, 10))
            d = ImageDraw.Draw(img)
            y = 16
            for label, path, txt in rows:
                d.text((10, y), label, fill=(200, 200, 120), font=ImageFont.load_default())
                if path:
                    d.text((10, y + 18), txt, fill=(150, 180, 255), font=ImageFont.truetype(path, 28))
                y += 70
            os.makedirs(os.path.dirname(PREVIEW), exist_ok=True)
            img.save(PREVIEW)
            paths.append(os.path.relpath(PREVIEW, ROOT))
            rep.ok("preview: ci/results/chatfont.png")
        except Exception as e:  # the picture is a help, never a reason to fail
            rep.add("- preview skipped: %s" % e)
    return paths
