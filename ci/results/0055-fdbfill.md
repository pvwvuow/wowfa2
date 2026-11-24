## task 0055-fdbfill (script)

**GREEN**


### Input

- ok: 157 names and 24 descriptions given, 179 entries ready, 2 problems
- PROBLEM Metamorphosis : Demon Charge: {demon charge} is not in the table
- PROBLEM Metamorphosis : Demonic Howl: {demonic howl} is not in the table

### Result

- ok: added: {'tree': 0, 'spell': 152, 'tpl': 23}; already identical: {'tree': 0, 'spell': 0, 'tpl': 0}
- ok: conflict: 0
- ok: gate_reject: 0
- ok: pair_reject: 3
  - spell Carve = برش, already cut (warrior/Carve)
  - spell Sacred Shield = سپر مقدس, already holy shield (warrior/Sacred Shield)
  - spell Devastate = ویران‌سازی, already wrack (warrior/Devastate)
- ok: number mismatch: 1
  - Reduces the Energy cost of your Expose Armor ability by 5, and refunds 1 Combo P
