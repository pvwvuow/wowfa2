## task 0409-vshow (script)

**RED**


### Groups

Dwarfmalegrimnpc: group index [269]
- FAIL: crash: list index out of range
```
Traceback (most recent call last):
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/tasks.py", line 487, in run
    paths = HANDLERS[t["kind"]](t, rep)
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/tasks.py", line 448, in task_script
    return mod.run(t["args"].get("args", {}), rep) or []
           ~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/jobs/voice_show.py", line 25, in run
    rows.append((l[0], cats[l[2]], l[3], l[6], (t[0] or "")[:50]))
                                         ~^^^
IndexError: list index out of range

```
