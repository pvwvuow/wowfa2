# WoWFA NPC dub studio

Static page, no build step. Needs Chrome or Edge (folder saving + microphone).

1. Download this folder: open the repo on GitHub, Code > Download ZIP, unzip, open `tools/dub-studio/index.html`.
   The four files (`index.html`, `dsp.js`, `loader.js`, `app.js`) must stay together.
2. First run only: pick `wow-forever-npc-voice-lines.html` when asked. The list is built in the browser and cached in IndexedDB (nothing is uploaded).
3. Play or download the original sound of any line, record your own take, apply an effect, save as `fa/<group>/<line>.wav`.

Original sounds stream from `wow.zamimg.com/wowsounds/<fileid>`; about a third of the files are not hosted there.
Downloads of originals go to `original/<group>/` in the chosen folder, or to the browser download folder.
