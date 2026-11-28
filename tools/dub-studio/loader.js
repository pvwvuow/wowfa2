(function () {
  'use strict';
  // ------------------------------------------------------------ builder (port of the data pipeline)
  // 1.3 (the owner 28 Nov: the studio missed a lot): nothing is dropped any more except sounds that are not a voice
  // (footsteps, loops, mounts). New categories at the end, so saved filters keep their numbers:
  // 7 emote, 8 NPC body sounds (wound, attack, death), 9 beasts and monsters, 10 everything else.
  var CATS = ['greeting', 'farewell', 'pissed', 'aggro', 'speech', 'player', 'combat', 'emote', 'exert', 'beast', 'other'];
  var NONVOICE = /footstep|footfall|(^|_)m?foot|swim|wingflap|(^|_)loop|jingle|(^|_)knock|(^|_)mount(?!ain)|horse|hoof/;
  var EMOTE = /laugh|cheer|chuckle|sigh|yawn|cough|sneeze|whistle|snore|choochoo|clap|kiss|giggle|flirt|emote|dance|applau/;
  var EXERT = /wound|attack|death|(^|_)dies?(_|\d|$)|dying|pain|hurt|injur|grunt|roar|crit|windup|(^|_)cast|precast|channel|spell|effort|exert|battleshout|battlecry|warcry|stun|knockdown|parry|dodge|block|jump|(^|_)land|(^|_)fall|breath|drown|yell_?pain|growl|snarl|howl|hiss|bark|screech|shriek|gasp/;
  var BEAST = /wolf|worg|bear(?!d)|raven|crow(?!n)|owl|moose|eagle|hawk|lion|tiger|panther|saber|sabre|boar|crab|spider|tarantula|scorpi|basilisk|hydra|lasher|wasp|snake|serpent|turtle|tortoise|croc|raptor|devilsaur|triceratops|gorilla|monkey|kodo|deer|goat|sheep|chicken|frog|toad|shark|fox|hyena|worm|beetle|cricket|moth|insect|carrion|vulture|gryphon|griffon|wyvern|hippogryph|moonkin|corgi|puppy|strider|lizard|silithid|ooze|slime|crawler|bird|parrot|rabbit|squirrel|mammoth|rhino|^cat|cat$|kitten|^bat|bat$|^rat|rat$|^dog|dog$|hound|elemental|golem|construct|revenant|treant|ancientprotector|spidertank|whelp|wyrm|bogbeast|owlcat/;
  function lineRace(n, gr) { for (var i = 0; i < RACES.length; i++) if (n.indexOf(RACES[i][0]) >= 0) return RACES[i][1]; return gr; }
  var GRUNT = /wound|attack|death|(^|_)dies?(_|\d|$)|dying|pain|hurt|injur|grunt|roar|breath|footstep|windup|(^|_)cast|jump|(^|_)land|effort|exert|battleshout|battlecry|warcry|emote|laugh|cheer|chuckle|sigh|yawn|cough|sneeze|whistle|snore|knock|choochoo|clap|kiss|giggle|flirt|fidget|loop|idle|stand|bored|footfall|swim|fall|parry|dodge|block|crit|spell|precast|channel|mount|growl|snarl|howl|bark|hiss|chirp|squawk|purr|whine|moo|oink|neigh|bleat|screech|shriek|scream|gasp|stun|knockdown|sleep|yell_?pain/;
  var SPEECH = /slay|kill|intro|yell|(^|_)say|speech|speak|taunt|summon|berserk|engage|event|quest|(^|_)line|vo_qe|vo_quest|order|command|special|phase|talk|whisper|warn|alert|chat|greet|bye|farewell|(^|_)\d{2,3}_[mf]$|(^|_)[mf]$|response|reply|story|lore|intro|outro|victory|defeat|win|lose|thank|help|question|vendor|trainer|flight|innkeeper|guard/;
  var RACES = [['bloodelf', 'bloodelf'], ['nightelf', 'nightelf'], ['highelf', 'bloodelf'], ['dwarf', 'dwarf'], ['darkiron', 'dwarf'], ['gnome', 'gnome'], ['human', 'human'], ['kultiran', 'human'], ['orc', 'orc'], ['troll', 'troll'], ['tauren', 'tauren'], ['undead', 'scourge'], ['scourge', 'scourge'], ['forsaken', 'scourge'], ['draenei', 'draenei'], ['goblin', 'goblin'], ['worgen', 'worgen'], ['gilnean', 'worgen'], ['pandaren', 'pandaren']];
  var RLAB = { human: 'Human', dwarf: 'Dwarf', gnome: 'Gnome', nightelf: 'Night Elf', orc: 'Orc', troll: 'Troll', tauren: 'Tauren', scourge: 'Undead', bloodelf: 'Blood Elf', draenei: 'Draenei', goblin: 'Goblin', worgen: 'Worgen', pandaren: 'Pandaren' };
  // player-race voices (kind h): the lines the game says for the player's own character - errors (not enough mana),
  // commands, vocal emotes - are category 5; pain, attack, death and battle shouts are category 6
  var NOISE_H = /footstep|footfall|swim|breath|loop|(^|_)jump|(^|_)land|(^|_)fall|drown|knock|choochoo|mount|giant|horse|snore|sleep|idle|fidget|whistle|bored/;
  var CMD_H = /(^|_)err|attackmytarget|attacktarget|incomingdanger|openfire|help|healme|followme|waithere|flee|outofmana|congratulat|thank|welcome|hello|(^|_)(yes|no|nod|cry|laugh|cheer|kiss|flirt|silly|chicken|beg|raspberry|sigh|yawn|train|follow|rude|joke)/;
  var COMBAT_H = /wound|attack|death|(^|_)dies?(_|\d|$)|dying|pain|hurt|crit|windup|casterrelease|battleshout|battlecry|warcry|(^|_)charge|(^|_)cast|exert|effort|grunt|roar|stun|parry|dodge|block/;
  function rep(s, a, b) { return s.split(a).join(b); }
  function clean(name, gname) {
    var n = name.toLowerCase(), g = rep(gname.toLowerCase(), ' ', '');
    var vs = [g, rep(g, 'the', ''), rep(gname.toLowerCase(), ' ', '_')];
    for (var i = 0; i < vs.length; i++) if (vs[i].length >= 4) n = rep(n, vs[i], '_');
    return n;
  }
  function catOf(name, gname, vo, kind, beast) {
    var n = clean(name, gname);
    if (NONVOICE.test(n)) return null;
    if (beast) return 9;
    if (/greet/.test(n)) return 0;
    if (/farewell|goodbye|(^|_)bye/.test(n)) return 1;
    if (/pissed|annoy/.test(n)) return 2;
    if (/aggro/.test(n)) return 3;
    if (kind === 'h') {
      // the player's own character: every reaction counts (the owner: one full pack per race)
      var hn = n.replace(/(fe)?male/g, '_');
      if (CMD_H.test(hn) || EMOTE.test(hn)) return 5;
      if (COMBAT_H.test(hn) || EXERT.test(hn)) return 6;
      return 5;
    }
    if (EMOTE.test(n)) return 7;
    if (EXERT.test(n)) return 8;
    if (SPEECH.test(n) || vo) return 4;
    return 10;
  }
  function gender(gname, names) {
    var g = gname.toLowerCase();
    if (g.indexOf('female') >= 0 || /(civ|guard|ven|vendor|npc|pc)f$/.test(g)) return 'f';
    if (/male/.test(g) || /(civ|guard|ven|vendor|npc|pc)m$/.test(g)) return 'm';
    var fe = 0, ma = 0;
    names.forEach(function (n) { n = n.toLowerCase(); if (n.indexOf('female') >= 0) fe++; if (/(?<!fe)male/.test(n)) ma++; });
    if (fe > ma && fe) return 'f';
    if (ma > fe && ma) return 'm';
    return '';
  }
  function race(gname) {
    var g = rep(gname.toLowerCase(), ' ', '');
    for (var i = 0; i < RACES.length; i++) if (g.indexOf(RACES[i][0]) >= 0) return RACES[i][1];
    return '';
  }
  function era(name, fid) {
    var m = /^vo_(\d{2,3})/.exec(name.toLowerCase());
    if (m) {
      var v = m[1], n = v.length === 3 ? parseInt(v.slice(0, 2), 10) : parseInt(v, 10);
      if (n === 60 || n === 61 || n === 62) return 'WoD';
      if (n >= 70 && n <= 73) return 'Legion';
      if (n >= 80 && n <= 83) return 'BfA';
      if (n >= 90 && n <= 92) return 'SL';
      if (n === 10) return 'DF';
      if (n === 11) return 'TWW';
    }
    return fid < 600000 ? 'old' : 'new';
  }
  function build(L0, G0) {
    var byg = {}, out = [], groups = [], gidx = {};
    L0.forEach(function (x) { (byg[x[1]] = byg[x[1]] || []).push(x); });
    G0.forEach(function (gk, gi) {
      var gname = gk[0], kind = gk[1], rows = byg[gi] || [], keep = [];
      var beast = kind === 'c' && BEAST.test(gname.toLowerCase().replace(/[^a-z]/g, ''));
      rows.forEach(function (r) { var c = catOf(r[3], gname, r[4], kind, beast); if (c !== null) keep.push([r[0], c, r[3], r[4]]); });
      if (!keep.length) return;
      var sex = gender(gname, keep.map(function (r) { return r[2]; }));
      var mn = Infinity; keep.forEach(function (r) { if (r[0] < mn) mn = r[0]; });
      gidx[gi] = groups.length;
      groups.push([gname, kind, sex, race(gname), mn, gi]);
      keep.forEach(function (r) { out.push([r[0], gidx[gi], r[1], r[2], r[3]]); });
    });
    var cnt = {}; groups.forEach(function (g) { cnt[g[0]] = (cnt[g[0]] || 0) + 1; });
    var seen = {};
    groups.forEach(function (g, gi) {
      if (cnt[g[0]] > 1) {
        var names = []; out.forEach(function (r) { if (r[1] === gi) names.push(r[3].toLowerCase()); });
        var rr = '';
        for (var i = 0; i < RACES.length && !rr; i++) { var k = RACES[i][0]; if (names.some(function (n) { return n.indexOf(k) >= 0; })) rr = RACES[i][1]; }
        if (rr && !g[3]) g[3] = rr;
        seen[g[0]] = (seen[g[0]] || 0) + 1;
        var lab = RLAB[g[3]] || '';
        if (!lab || rep(lab, ' ', '').toLowerCase() === g[0].toLowerCase()) lab = String(seen[g[0]]);
        g[0] = g[0] + ' (' + lab + ')';
      }
    });
    out.forEach(function (r) {
      var n = r[3].toLowerCase();
      r.push(/female|_f$|_f_|woman/.test(n) ? 'f' : (/(?<!fe)male|_m$|_m_/.test(n) ? 'm' : ''));
      r.push(era(r[3], r[0]));
      var gg = groups[r[1]];
      r.push(gg[1] === 'h' ? lineRace(n, gg[3]) : gg[3]);
    });
    groups.forEach(function (g, gi) {
      if (!g[2]) {
        var c = {}; out.forEach(function (r) { if (r[1] === gi && r[5]) c[r[5]] = (c[r[5]] || 0) + 1; });
        var best = '', bn = 0; Object.keys(c).forEach(function (k) { if (c[k] > bn) { bn = c[k]; best = k; } });
        if (best) g[2] = best;
      }
    });
    return { cats: CATS, groups: groups, lines: out, v: 1 };
  }
  function parsePage(html) {
    var gi = html.indexOf('GROUPS=['), li = html.indexOf('LINES=[');
    if (gi < 0 || li < 0) throw new Error('GROUPS/LINES not found');
    var gEnd = html.indexOf(',LINES=[', gi), lEnd = html.indexOf('];', li);
    if (gEnd < 0 || lEnd < 0) throw new Error('bad layout');
    var G0 = JSON.parse(html.slice(gi + 7, gEnd)), L0 = JSON.parse(html.slice(li + 6, lEnd + 1));
    return build(L0, G0);
  }
  window.WfaBuild = { parsePage: parsePage, build: build };
  if (typeof document === 'undefined') return;

  // ------------------------------------------------------------ boot: cached data or one-time import
  function idb() { return new Promise(function (res, rej) { var r = indexedDB.open('wfadub', 1); r.onupgradeneeded = function () { r.result.createObjectStore('kv'); }; r.onsuccess = function () { res(r.result); }; r.onerror = function () { rej(r.error); }; }); }
  function kvGet(k) { return idb().then(function (db) { return new Promise(function (res) { var q = db.transaction('kv').objectStore('kv').get(k); q.onsuccess = function () { res(q.result); }; q.onerror = function () { res(null); }; }); }).catch(function () { return null; }); }
  function kvSet(k, v) { return idb().then(function (db) { return new Promise(function (res, rej) { var t = db.transaction('kv', 'readwrite'); t.objectStore('kv').put(v, k); t.oncomplete = res; t.onerror = function () { rej(t.error); }; }); }); }
  function start(D) {
    var ov = document.getElementById('import'); if (ov) ov.style.display = 'none';
    window.VO_DATA = D;
    var fa = function (n) { return String(n).replace(/\d/g, function (d) { return '\u06f0\u06f1\u06f2\u06f3\u06f4\u06f5\u06f6\u06f7\u06f8\u06f9'[+d]; }); };
    var old = D.lines.filter(function (l) { return l[0] < 600000; }).length;
    var s = document.getElementById('stats'); if (s) s.textContent = '\u0627\u0632 ' + fa(D.lines.length) + ' \u062e\u0637 \u062d\u0631\u0641 NPC (' + fa(old) + ' \u062e\u0637 \u0642\u062f\u06cc\u0645\u06cc)\u060c';
    if (D.fv && s) { var fn = D.lines.filter(function (l) { return D.fv[l[0]]; }).length; s.textContent += ' \u0627\u0632 \u0627\u06cc\u0646\u200c\u0647\u0627 ' + fa(fn) + ' \u062e\u0637 \u062f\u0631 \u06a9\u0644\u0627\u06cc\u0646\u062a Forever ' + (D.fvBuild || '') + ' \u0647\u0633\u062a\u061b'; }
    window.wfaStart();
  }
  function showImport(msg) {
    var ov = document.getElementById('import'); ov.style.display = 'flex';
    var m = document.getElementById('imsg'); if (msg) m.textContent = msg;
  }
  function onFile(f) {
    var m = document.getElementById('imsg'); m.textContent = '\u062f\u0631 \u062d\u0627\u0644 \u062e\u0648\u0627\u0646\u062f\u0646\u2026';
    f.text().then(function (t) {
      var D = parsePage(t);
      if (!D.lines.length) throw new Error('empty');
      return kvSet('vo', D).catch(function () {}).then(function () { start(D); });
    }).catch(function (e) { showImport('\u0627\u06cc\u0646 \u0641\u0627\u06cc\u0644 \u0646\u0647 \u062e\u0648\u0627\u0646\u062f\u0647 \u0634\u062f (' + (e && e.message) + '). \u0641\u0627\u06cc\u0644 wow-forever-npc-voice-lines.html \u0631\u0627 \u0627\u0646\u062a\u062e\u0627\u0628 \u06a9\u0646.'); });
  }
  document.addEventListener('DOMContentLoaded', function () {
    var inp = document.getElementById('ifile');
    inp.addEventListener('change', function () { if (inp.files[0]) onFile(inp.files[0]); });
    var again = document.getElementById('reimport');
    if (again) again.addEventListener('click', function (e) { e.preventDefault(); showImport(); });
    if (window.VO_RAW && window.VO_RAW.L) {
      // full database shipped with the studio (voice_db.js): no import needed
      var R = window.VO_RAW, D = build(R.L, R.G);
      D.T = R.T || {}; D.C = {}; D.thumb = R.thumb || '';
      D.fv = null; if (R.FV && R.FV.length) { D.fv = {}; R.FV.forEach(function (f) { D.fv[f] = 1; }); D.fvBuild = R.FB || ''; }
      D.groups.forEach(function (g, i) { var c = R.C && R.C[String(g[5])]; if (c) D.C[i] = c; });
      D.M = {}; D.groups.forEach(function (g, i) { var m = R.M && R.M[String(g[5])]; if (m) D.M[i] = m; });
      start(D);
      return;
    }
    kvGet('vo').then(function (D) { if (D && D.lines && D.lines.length && D.v === 1) start(D); else showImport(); });
  });
})();
