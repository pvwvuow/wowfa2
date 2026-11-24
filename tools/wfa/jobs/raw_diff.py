"""Word diff old -> new of the Spell descriptions a build changed, for the ones our data knows. Report only."""
import difflib
import json
import os
import re
import urllib.request

from wfa.jobs_shared import words_of  # noqa: F401  (placeholder, replaced below)
