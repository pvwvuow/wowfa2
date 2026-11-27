"""The community ledger: what the players' reports got fixed (docs/community.json, public: the site reads it).

rows: {"d": "YYYY-MM-DD", "src": "where it came from", "c": {"npc": 4, "buff": 3, ...}}
groups: npc quest buff spell ui sys dlg other
"""
import datetime
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[2]
PATH = ROOT / "docs" / "community.json"
GROUPS = ("npc", "quest", "buff", "spell", "ui", "sys", "dlg", "other")


def load():
    if PATH.exists():
        return json.loads(PATH.read_text(encoding="utf-8"))
    return {"v": 1, "since": datetime.date.today().isoformat(), "rows": []}


def add(date, counts, src=""):
    """Append one row; returns True when something was written."""
    doc = load()
    c = {k: int(v) for k, v in (counts or {}).items() if k in GROUPS and int(v) > 0}
    if not c:
        return False
    doc["rows"].append({"d": date or datetime.date.today().isoformat(), "src": src, "c": c})
    PATH.parent.mkdir(parents=True, exist_ok=True)
    PATH.write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return True
