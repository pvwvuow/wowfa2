"""Shared helpers: paths, JSON I/O, name keys, hashes, Lua string escaping."""
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = os.path.join(ROOT, "data")
OUT = os.path.join(ROOT, "out")

# name kinds stored under data/names/<kind>/ and the marker family that points at them
NAME_KINDS = ("zone", "spell", "class", "tree", "npc", "boss", "obj", "itn", "it", "set")
MARKER_KIND = {"sp": "spell", "zn": "zone", "cls": "class", "npc": "npc", "it": "it",
               "ob": "obj", "set": "set"}
# markers we never resolve from a table (their Persian is free text): terms, quest titles
FREE_MARKERS = ("tm", "qs", "fac")
MARKER_RE = re.compile(r"\{\{([a-z]+):([^|{}]*)(?:\|([^{}]*))?\}\}")

_QUOTES = {"\u2018": "'", "\u2019": "'", "\u201c": '"', "\u201d": '"'}


def name_key(s):
    """Same normalisation as the addon's T.NameKey (Text.lua)."""
    for a, b in _QUOTES.items():
        s = s.replace(a, b)
    s = s.lower().strip()
    s = re.sub(r"^the\s+", "", s)
    s = re.sub(r"\s+", " ", s)
    return s.strip()


def title_hash(title):
    """djb2 over the UTF-8 bytes of name_key(title), mod 2^32, 8 hex chars.
    Mirrored in Lua (Core.lua F.TitleHash); h*33 stays < 2^38, exact in doubles."""
    h = 5381
    for b in name_key(title).encode("utf-8"):
        h = (h * 33 + b) % 4294967296
    return "%08x" % h


_UNI_SPACES = re.compile("[\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]")
_ASCII_LOWER = {i: i + 32 for i in range(65, 91)}


def num_key(s):
    """Byte-for-byte twin of the addon's T.NumKey (Text.lua): the template key of a live tooltip
    line + its numbers in order. Lua patterns are ASCII-only (%d, %s, lower), so this is too."""
    s = re.sub(r"\|c[0-9A-Fa-f]{8}", "", s)
    s = s.replace("|r", "")
    s = re.sub(r"\|T.*?\|t", "", s, flags=re.S)
    s = re.sub(r"\|H.*?\|h", "", s, flags=re.S)
    s = s.replace("|h", "")
    s = _UNI_SPACES.sub(" ", s)
    while re.search(r"[0-9],[0-9]{3}", s):
        s = re.sub(r"([0-9]),([0-9]{3})", r"\1\2", s)
    nums, out, pos = [], [], 0
    for m in re.finditer(r"[0-9]+", s):
        if m.start() < pos:
            continue
        a, b = m.start(), m.end()
        if s[b:b + 1] == "." and s[b + 1:b + 2].isdigit() and s[b + 1:b + 2] in "0123456789":
            b = re.match(r"[0-9]+", s[b + 1:]).end() + b + 1
        out.append(s[pos:a])
        out.append("#")
        nums.append(s[a:b])
        pos = b
    out.append(s[pos:])
    key = "".join(out).translate(_ASCII_LOWER)
    key = key.replace(" seconds", " sec").replace(" minutes", " min")
    key = re.sub(r"[ \t\n\v\f\r]+", " ", key)
    if key.startswith(" "):
        key = key[1:]
    if key.endswith(" "):
        key = key[:-1]
    if key.endswith("."):
        key = key[:-1]
    return key, nums


def shard_letter(key):
    c = key[:1]
    return c if ("a" <= c <= "z") else "_"


def read_json(path):
    with open(path, "rb") as f:
        raw = f.read()
    if raw.startswith(b"\xef\xbb\xbf"):
        raise ValueError("%s: UTF-8 BOM" % path)
    return json.loads(raw.decode("utf-8"))


def write_json_map(path, obj, sort_int=False):
    """Canonical form: one entry per line, real UTF-8, sorted keys, one trailing newline."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    keys = sorted(obj, key=(lambda k: int(k)) if sort_int else None)
    lines = [json.dumps(str(k), ensure_ascii=False) + ":" +
             json.dumps(obj[k], ensure_ascii=False, separators=(",", ":")) for k in keys]
    body = "{\n" + ",\n".join(lines) + "\n}\n" if lines else "{}\n"
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(body)


def lua_str(s):
    """Lua 5.1 string literal; raw UTF-8 bytes kept, control chars as decimal escapes."""
    out = ['"']
    for ch in s:
        o = ord(ch)
        if ch == "\\":
            out.append("\\\\")
        elif ch == '"':
            out.append('\\"')
        elif ch == "\n":
            out.append("\\n")
        elif o < 32 or o == 127:
            out.append("\\%03d" % o)
        else:
            out.append(ch)
    out.append('"')
    return "".join(out)
