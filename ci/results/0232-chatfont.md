## task 0232-chatfont (script)

**RED**

- pip fonttools pillow: rc 0
- FAIL: crash: No module named 'fontTools'
```
Traceback (most recent call last):
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/tasks.py", line 487, in run
    paths = HANDLERS[t["kind"]](t, rep)
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/tasks.py", line 448, in task_script
    return mod.run(t["args"].get("args", {}), rep) or []
           ~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/jobs/font_chat.py", line 70, in run
    from fontTools.ttLib import TTFont, newTable
ModuleNotFoundError: No module named 'fontTools'

```
