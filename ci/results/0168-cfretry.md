## task 0168-cfretry (script)

**RED**

- FAIL: crash: No module named 'tools'
```
Traceback (most recent call last):
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/tasks.py", line 487, in run
    paths = HANDLERS[t["kind"]](t, rep)
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/tasks.py", line 447, in task_script
    spec.loader.exec_module(mod)
    ~~~~~~~~~~~~~~~~~~~~~~~^^^^^
  File "<frozen importlib._bootstrap_external>", line 759, in exec_module
  File "<frozen importlib._bootstrap>", line 491, in _call_with_frames_removed
  File "/home/runner/work/wowfa2/wowfa2/tools/wfa/jobs/cf_retry.py", line 9, in <module>
    from tools.wfa.jobs import cf_log, publish_release
ModuleNotFoundError: No module named 'tools'

```
