## task 0047-retag (script)

**RED**

- FAIL: crash: [Errno 2] No such file or directory: '/home/runner/work/wowfa2/wowfa2/tools/wfa/jobs/retag_tpl.py'
```
Traceback (most recent call last):
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/tasks.py", line 487, in run
    paths = HANDLERS[t["kind"]](t, rep)
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/tasks.py", line 447, in task_script
    spec.loader.exec_module(mod)
    ~~~~~~~~~~~~~~~~~~~~~~~^^^^^
  File "<frozen importlib._bootstrap_external>", line 755, in exec_module
  File "<frozen importlib._bootstrap_external>", line 892, in get_code
  File "<frozen importlib._bootstrap_external>", line 950, in get_data
FileNotFoundError: [Errno 2] No such file or directory: '/home/runner/work/wowfa2/wowfa2/tools/wfa/jobs/retag_tpl.py'

```
