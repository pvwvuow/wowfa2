"""Create the release DRAFT exactly like the release task, but catch everything (SystemExit too)
so the report shows why a release run stops. args.notes = the notes text."""
import traceback

from wfa import tasks as T


def run(args, rep):
    rep.h("Release probe")
    try:
        T.task_release({"args": {"notes": args.get("notes", "")}}, rep)
    except BaseException as e:  # noqa: BLE001
        rep.fail("release stopped: %r" % (e,))
        rep.add("```\n" + traceback.format_exc()[-3500:] + "\n```")
    return []
