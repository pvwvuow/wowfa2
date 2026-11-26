## task 0402-vt-stt (script)

**GREEN**


### Database

- ok: 68178 files, 327 texts

### Hearing

- ok: 14454 lines without a text in categories [0, 1, 2, 3]; hearing up to 2500
model base.en loaded in 2 s
every file fails to decode; stopping
- ok: heard 40 files in 2 s: 0 usable texts; not on the CDN or unreadable: {'error': 39, 'http 404': 1}
error: 539160 TypeError: open() got an unexpected keyword argument 'metadata_errors' | ['  File "av/container/core.py", line 479, in av.container.core.open', '    def open(', "TypeError: open() got an unexpected keyword argument 'metadata_errors'"]
error: 539160 TypeError: open() got an unexpected keyword argument 'metadata_errors' | ['  File "av/container/core.py", line 479, in av.container.core.open', '    def open(', "TypeError: open() got an unexpected keyword argument 'metadata_errors'"]
error: 539160 FileNotFoundError: [Errno 2] No such file or directory: 'ffmpeg' | ['  File "/usr/lib/python3.14/subprocess.py", line 1990, in _execute_child', '    raise child_exception_type(errno_num, err_msg, err_filename)', "FileNotFoundError: [Errno 2] No such file or directory: 'ffmpeg'"]
error: 539162 TypeError: open() got an unexpected keyword argument 'metadata_errors' | ['  File "av/container/core.py", line 479, in av.container.core.open', '    def open(', "TypeError: open() got an unexpected keyword argument 'metadata_errors'"]
still to hear in these categories (before the aggro filter): 16499

### Merge

- ok: 0 heard texts added, 0 lines got Persian from ci/data/vo_fa.json (0 entries)

### To translate

- ok: 327 texts in all, 0 with Persian; 318 distinct texts still to translate (ci/data/vo_todo.json)
