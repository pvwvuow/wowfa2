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
FREE_MARKERS = ("tm", "qs")
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
