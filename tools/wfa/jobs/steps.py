"""Run several job steps in one task, one after the other, so tasks that touch the same files do not race.
args: steps = [{"from": "ci/tasks/<id>.json"} (runs that task's module with its args) | {"module": name, "args": {...}}].
Returns every changed path of all steps."""
import importlib.util
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))


def _load(name):
    spec = importlib.util.spec_from_file_location("wfa_step_" + name, os.path.join(HERE, name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run(args, rep):
    changed = []
    for i, st in enumerate(args.get("steps") or [], 1):
        if st.get("from"):
            t = json.load(open(st["from"], encoding="utf-8"))
            name, a = t["args"]["module"], t["args"].get("args") or {}
            label = "%s (%s)" % (name, st["from"])
        else:
            name, a = st["module"], st.get("args") or {}
            label = name
        rep.h("step %d: %s" % (i, label))
        for p in _load(name).run(a, rep) or []:
            if p not in changed:
                changed.append(p)
    return changed
