window.wfaStart = function () {
  'use strict';
  var D = window.VO_DATA, CATS = D.cats, G = D.groups, L = D.lines;
  var CDN = 'https://wow.zamimg.com/wowsounds/';
  var ICON = 'https://wow.zamimg.com/images/wow/icons/large/';
  var CAT_FA = { greeting: 'سلام', farewell: 'خداحافظی', pissed: 'عصبانی (کلیک زیاد)', aggro: 'شروع نبرد', speech: 'دیالوگ / فریاد' };
  var RACE_FA = { human: 'انسان', dwarf: 'دورف', gnome: 'گنوم', nightelf: 'نایت\u200cالف', orc: 'اورک', troll: 'ترول', tauren: 'تائورن', scourge: 'آندد', bloodelf: 'بلادالف', draenei: 'درنای', goblin: 'گابلین', worgen: 'ورگن', pandaren: 'پانداران' };
  var ERA_FA = { old: 'قدیمی', new: 'جدید', WoD: 'WoD', Legion: 'Legion', BfA: 'BfA', SL: 'Shadowlands', DF: 'Dragonflight', TWW: 'War Within' };
  var CREATURE_ICON = [[/dragon|drake|whelp|wyrm|onyx|nefar|deathwing|alexstr|malygos|sindragosa/, 'inv_misc_head_dragon_01'], [/elemental|ragnaros|golem|geode|earth|fire|water|air|wind/, 'spell_fire_elemental_totem'], [/lich|ghoul|zombie|skelet|banshee|ghost|wraith|abomin|scourge|undead|kelthuzad|arthas/, 'spell_shadow_raisedead'], [/demon|dreadlord|doomguard|felhound|imp|succubus|archimonde|kazzak|eredar|pitlord|mannoroth|illidan/, 'spell_shadow_summonfelguard'], [/wolf|worg|hound/, 'ability_mount_whitedirewolf'], [/bear/, 'ability_racial_bearform'], [/cat|tiger|lion|panther/, 'ability_druid_catform'], [/spider|crawler|nerub|anub/, 'inv_misc_monsterspidercarapace_01'], [/murloc/, 'inv_misc_head_murloc_01'], [/gnoll/, 'inv_misc_head_gnoll_01'], [/kobold/, 'inv_misc_head_kobold_01'], [/ogre|ettin|gronn|giant/, 'inv_misc_head_ogre_01'], [/centaur/, 'inv_misc_head_centaur_01'], [/naga|vashj/, 'inv_misc_head_naga_01'], [/tauren|cairne|baine/, 'race_tauren_male'], [/orc|thrall|garrosh|grom|durotan/, 'race_orc_male'], [/troll|zul|voljin/, 'race_troll_male'], [/dwarf|bronzebeard|muradin|magni/, 'race_dwarf_male'], [/gnome|mekkatorque/, 'race_gnome_male'], [/elf|tyrande|malfurion|sylvanas|kael/, 'race_nightelf_male'], [/human|king|varian|anduin|jaina|bolvar|guard|soldier|peasant/, 'race_human_male']];

  // ---------------------------------------------------------------- state
  function load(k, d) { try { var v = localStorage.getItem(k); return v ? JSON.parse(v) : d; } catch (e) { return d; } }
  function save(k, v) { try { localStorage.setItem(k, JSON.stringify(v)); } catch (e) {} }
  var done = load('wfadub_done', {});
  var st = { q: '', cat: -1, sex: 'all', era: 'old', kind: 'all', status: 'all', sort: 'name', page: 60 };
  var root = null, rootOk = false;
  var $ = function (id) { return document.getElementById(id); };
  var FD = '۰۱۲۳۴۵۶۷۸۹';
  function fa(n) { return String(n).replace(/\d/g, function (d) { return FD[+d]; }); }
  function esc(s) { return String(s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); }
  function safe(s) { return String(s).replace(/[\\\/:*?"<>|]+/g, '_').trim() || 'group'; }

  var byG = G.map(function () { return []; });
  L.forEach(function (l, i) { byG[l[1]].push(i); });
  var nat = (window.Intl && Intl.Collator) ? new Intl.Collator('en', { numeric: true, sensitivity: 'base' }) : { compare: function (a, b) { return a < b ? -1 : a > b ? 1 : 0; } };
  byG.forEach(function (a) { a.sort(function (x, y) { return L[x][2] - L[y][2] || nat.compare(L[x][3], L[y][3]); }); });

  var PK = 'wfadub_f';
  (function () { var p = load(PK, null); if (p) ['cat', 'sex', 'era', 'kind', 'status', 'sort'].forEach(function (k) { if (p[k] !== undefined) st[k] = p[k]; }); })();
  function savePrefs() { save(PK, { cat: st.cat, sex: st.sex, era: st.era, kind: st.kind, status: st.status, sort: st.sort }); }
  // scope = what the numbers count (era, kind, sex); lineOk adds category and recorded-state
  function inScope(i) {
    var l = L[i], g = G[l[1]];
    if (st.era === 'old' && l[6] !== 'old') return false;
    if (st.kind !== 'all' && g[1] !== st.kind) return false;
    if (st.sex !== 'all') { var sx = l[5] || g[2] || 'u'; if (sx !== st.sex) return false; }
    return true;
  }
  function lineOk(i) {
    var l = L[i];
    if (!inScope(i)) return false;
    if (st.cat >= 0 && l[2] !== st.cat) return false;
    if (st.status === 'todo' && done[l[0]]) return false;
    if (st.status === 'done' && !done[l[0]]) return false;
    return true;
  }
  var TX = D.T || {}, CR = D.C || {}, THUMB = D.thumb || '', crText = {};
  Object.keys(CR).forEach(function (k) { crText[k] = CR[k].map(function (c) { return (c[1] + ' ' + (c[2] || '')).toLowerCase(); }).join(' | '); });
  function textOf(fid) { return TX[String(fid)] || null; }
  function qOk(gi, i) {
    if (!st.q) return true;
    var t = st.q, l = L[i], x = textOf(l[0]);
    return G[gi][0].toLowerCase().indexOf(t) >= 0 || l[3].toLowerCase().indexOf(t) >= 0 || String(l[0]) === t ||
      (crText[gi] || '').indexOf(t) >= 0 || (x && ((x[0] || '').toLowerCase().indexOf(t) >= 0 || (x[1] || '').indexOf(t) >= 0));
  }
  function crNames(gi, n) {
    var c = CR[gi] || [], seen = {}, out = [];
    for (var k = 0; k < c.length && out.length < n; k++) { var s = c[k][2] || c[k][1]; if (!seen[s]) { seen[s] = 1; out.push(s); } }
    return { list: out, more: Math.max(0, c.length - out.length) };
  }
  function txHTML(fid) {
    var x = textOf(fid); if (!x) return '';
    return '<span class="en">' + esc(x[0]) + '</span>' + (x[1] ? '<span class="fa">' + esc(x[1]) + '</span>' : '<span class="fa no">\u062a\u0631\u062c\u0645\u0647 \u0647\u0646\u0648\u0632 \u0646\u06cc\u0633\u062a</span>');
  }

  // ---------------------------------------------------------------- avatars
  function avatar(g) {
    var src = '', fb = '', gi0 = G.indexOf(g), cr0 = CR[gi0] || [];
    if (THUMB) for (var q = 0; q < cr0.length; q++) if (cr0[q][3]) { fb = THUMB.split('{m}').join(String(cr0[q][3] & 255)).split('{d}').join(String(cr0[q][3])); break; }
    if (g[3]) src = ICON + 'race_' + g[3] + '_' + (g[2] === 'f' ? 'female' : 'male') + '.jpg';
    else {
      var n = g[0].toLowerCase();
      for (var k = 0; k < CREATURE_ICON.length; k++) if (CREATURE_ICON[k][0].test(n)) { src = ICON + CREATURE_ICON[k][1] + '.jpg'; break; }
    }
    var ch = esc((g[0].match(/[A-Za-z0-9]/) || ['?'])[0].toUpperCase());
    var hue = 0; for (var i = 0; i < g[0].length; i++) hue = (hue * 31 + g[0].charCodeAt(i)) % 360;
    var np = !!fb;
    if (fb) { var s2 = src; src = fb; fb = s2; }
    return '<div class="av' + (np ? ' np' : '') + '" style="--h:' + hue + '"><span>' + ch + '</span>' + (src ? '<img loading="lazy" alt="" src="' + src + '"' + (fb ? ' data-fb="' + fb + '"' : '') + ' onerror="if(this.dataset.fb){this.src=this.dataset.fb;this.removeAttribute(\'data-fb\');this.parentNode.classList.remove(\'np\')}else this.remove()">' : '') + '</div>';
  }

  // ---------------------------------------------------------------- list
  var list = $('list'), view = [];
  function compute() {
    view = [];
    G.forEach(function (g, gi) {
      var a = byG[gi].filter(function (i) { return lineOk(i) && qOk(gi, i); });
      if (a.length) view.push([gi, a]);
    });
    if (st.sort === 'count') view.sort(function (a, b) { return b[1].length - a[1].length || nat.compare(G[a[0]][0], G[b[0]][0]); });
    else if (st.sort === 'sex') view.sort(function (a, b) { var o = { f: 0, m: 1, '': 2 }; return o[G[a[0]][2]] - o[G[b[0]][2]] || nat.compare(G[a[0]][0], G[b[0]][0]); });
    else view.sort(function (a, b) { return nat.compare(G[a[0]][0], G[b[0]][0]); });
  }
  function cardHTML(v) {
    var gi = v[0], g = G[gi], t = 0, d = 0;
    byG[gi].forEach(function (i) { if (inScope(i)) { t++; if (done[L[i][0]]) d++; } });
    var sx = g[2] === 'f' ? '<span class="f">زن</span>' : g[2] === 'm' ? '<span class="m">مرد</span>' : '';
    var meta = [sx, g[3] ? (RACE_FA[g[3]] || g[3]) : '', g[1] === 'h' ? 'نژاد بازیکن' : '', fa(v[1].length) + ' خط'].filter(Boolean).join(' \u00b7 ');
    var full = t && d === t;
    var cn = crNames(gi, 3), cnh = cn.list.length ? '<div class="gc">' + cn.list.map(esc).join('\u060c ') + (cn.more ? ' \u0648 ' + fa(cn.more) + ' \u062a\u0627\u06cc \u062f\u06cc\u06af\u0631' : '') + '</div>' : '';
    return '<details class="g" data-g="' + gi + '"><summary>' + avatar(g) + '<div class="gi"><div class="gn">' + esc(g[0]) + '</div>' + cnh + '<div class="gm">' + meta + '</div></div>' +
      '<button class="ic" data-act="gplay" title="پخش اولین خط این گروه">\u25b6</button><span class="gp' + (full ? ' full' : '') + '">' + (full ? '\u2713' : fa(d) + '/' + fa(t)) + '</span></summary><div class="rows"></div></details>';
  }
  function rowHTML(i) {
    var l = L[i];
    return '<div class="row' + (done[l[0]] ? ' ok' : '') + '" data-i="' + i + '"><span class="st">' + (done[l[0]] ? '\u2713' : '') + '</span>' +
      '<button class="ic" data-act="play" title="پخش صدای اصلی">\u25b6</button><span class="tx"><span class="nm" title="' + esc(l[3]) + '">' + esc(l[3]) + '</span>' + txHTML(l[0]) + '</span>' +
      (l[6] !== 'old' ? '<span class="era">' + (ERA_FA[l[6]] || l[6]) + '</span>' : '') +
      '<span class="ct c' + l[2] + '">' + CAT_FA[CATS[l[2]]] + '</span>' +
      '<button class="ic" data-act="dl" title="دانلود صدای اصلی">\u2b07</button><button class="ic mine" data-act="mine" title="پخش ضبط خودم">\u25b6</button><button class="ic rc" data-act="rec" title="ضبط دوبله برای همین خط">\u25cf</button></div>';
  }
  function render() {
    compute();
    var tot = 0; view.forEach(function (v) { tot += v[1].length; });
    $('count').textContent = fa(view.length) + ' گروه \u00b7 ' + fa(tot) + ' خط';
    var h = '';
    for (var k = 0; k < Math.min(view.length, st.page); k++) h += cardHTML(view[k]);
    if (!view.length) h = '<p class="empty">چیزی با این فیلترها پیدا نشد.</p>';
    if (view.length > st.page) h += '<div class="more"><button class="btn" id="more">' + fa(Math.min(60, view.length - st.page)) + ' گروه دیگر</button></div>';
    list.innerHTML = h;
    if (st.q && view.length <= 3) [].forEach.call(list.querySelectorAll('details.g'), function (d) { d.open = true; fill(d); });
    progress();
  }
  function fill(d) {
    var gi = +d.dataset.g, v = null;
    for (var k = 0; k < view.length; k++) if (view[k][0] === gi) { v = view[k]; break; }
    var arr = v ? v[1] : byG[gi];
    d.querySelector('.rows').innerHTML = '<div class="gh"><button class="btn" data-act="gdl" data-g="' + gi + '">\u2b07 دانلود همه\u0654 صداهای اصلی (' + fa(arr.length) + ')</button><button class="btn" data-act="glinks" data-g="' + gi + '" title="برای IDM، wget یا هر دانلودر">فهرست لینک\u200cها</button></div>' + arr.map(rowHTML).join('');
    if (cur >= 0) mark();
  }
  // top numbers, category tabs and every group's "3/12" or tick
  var nums = $('nums');
  function progress() {
    var tot = 0, rec = 0, pc = CATS.map(function () { return [0, 0]; }), gs = {};
    for (var i = 0; i < L.length; i++) {
      if (!inScope(i)) continue;
      var l = L[i], d = done[l[0]] ? 1 : 0;
      tot++; rec += d; pc[l[2]][0]++; pc[l[2]][1] += d;
      var c = gs[l[1]] || (gs[l[1]] = [0, 0]); c[0]++; c[1] += d;
    }
    var gt = 0, gd = 0; for (var k in gs) { gt++; if (gs[k][0] === gs[k][1]) gd++; }
    nums.innerHTML = '<div><b>' + fa(tot) + '</b><span>خط صدا</span></div><div class="ok"><b>' + fa(rec) + '</b><span>ضبط\u200cشده \u2713</span></div><div><b>' + fa(tot - rec) + '</b><span>مانده</span></div><div><b>' + fa(gd) + ' / ' + fa(gt) + '</b><span>گروه کامل</span></div><div><b>' + fa(tot ? Math.round(rec * 100 / tot) : 0) + '\u066a</b><span>پیشرفت</span></div>';
    $('pbar').style.width = (tot ? rec * 100 / tot : 0) + '%';
    var h = '<button data-v="-1" aria-selected="' + (st.cat < 0) + '">همه<small>' + fa(rec) + '/' + fa(tot) + '</small></button>';
    CATS.forEach(function (c, i) { h += '<button data-v="' + i + '" aria-selected="' + (st.cat === i) + '">' + CAT_FA[c] + '<small>' + fa(pc[i][1]) + '/' + fa(pc[i][0]) + '</small></button>'; });
    $('fcat').innerHTML = h;
    [].forEach.call(list.querySelectorAll('details.g'), function (el) {
      var gi = +el.dataset.g, t = 0, dd = 0;
      byG[gi].forEach(function (j) { if (inScope(j)) { t++; if (done[L[j][0]]) dd++; } });
      var p = el.querySelector('.gp'), full = t && dd === t;
      p.className = 'gp' + (full ? ' full' : ''); p.textContent = full ? '\u2713' : fa(dd) + '/' + fa(t);
    });
  }
  list.addEventListener('toggle', function (e) { var d = e.target; if (d.classList && d.classList.contains('g') && d.open) fill(d); }, true);
  list.addEventListener('click', function (e) {
    if (e.target.id === 'more') { st.page += 60; render(); return; }
    var b = e.target.closest('[data-act]'); if (!b) return;
    var act = b.dataset.act;
    if (act === 'gplay') {
      e.preventDefault(); e.stopPropagation();
      var gi = +b.closest('.g').dataset.g, v = null;
      for (var k = 0; k < view.length; k++) if (view[k][0] === gi) { v = view[k]; break; }
      var arr = v ? v[1] : byG[gi]; if (arr.length) playOrig(arr[0]); return;
    }
    if (act === 'gdl') { dlGroup(+b.dataset.g, b); return; }
    if (act === 'glinks') { linkList(+b.dataset.g); return; }
    var i = +b.closest('.row').dataset.i;
    if (act === 'play') playOrig(i);
    else if (act === 'dl') dlOrig(i, b);
    else if (act === 'mine') playMine(i);
    else openStudio(i);
  });

  // ---------------------------------------------------------------- filters
  function bindSel(id, key) {
    var el = $(id); el.value = st[key]; if (el.value !== st[key]) { st[key] = el.options[0].value; el.value = st[key]; }
    el.addEventListener('change', function () { st[key] = el.value; st.page = 60; savePrefs(); render(); });
  }
  bindSel('fsex', 'sex'); bindSel('fkind', 'kind'); bindSel('fera', 'era'); bindSel('fsort', 'sort'); bindSel('fstatus', 'status');
  $('fcat').addEventListener('click', function (e) { var b = e.target.closest('button'); if (!b) return; st.cat = +b.dataset.v; st.page = 60; savePrefs(); render(); });
  var tq; $('q').addEventListener('input', function () { var v = this.value; clearTimeout(tq); tq = setTimeout(function () { st.q = v.trim().toLowerCase().replace(/[۰-۹]/g, function (d) { return FD.indexOf(d); }); st.page = 60; render(); }, 180); });
  // jump to the first line that is not recorded yet (inside the current filters)
  $('resume').addEventListener('click', function () {
    compute();
    for (var k = 0; k < view.length; k++) {
      var a = view[k][1].filter(function (i) { return !done[L[i][0]]; });
      if (!a.length) continue;
      if (k >= st.page) { st.page = k + 1; render(); }
      var d = list.querySelector('details.g[data-g="' + view[k][0] + '"]'); if (!d) return;
      d.open = true; fill(d); cur = a[0]; mark();
      var r = d.querySelector('.row[data-i="' + a[0] + '"]'); if (r) r.scrollIntoView({ block: 'center' });
      return;
    }
    toast('همه\u0654 خط\u200cهای این فیلتر ضبط شده\u200cاند \u2713');
  });

  // ---------------------------------------------------------------- original playback
  var au = $('au'), cur = -1, origDur = 0;
  function mark() {
    [].forEach.call(list.querySelectorAll('.row.cur'), function (r) { r.classList.remove('cur'); });
    var r = list.querySelector('.row[data-i="' + cur + '"]'); if (r) r.classList.add('cur');
  }
  var blobCache = {};
  function ostate(m, bad) { var s = $('ostate'); if (!s) return; s.textContent = m; s.className = bad ? 'bad' : ''; }
  function fetchOrig(i) {
    var l = L[i];
    if (blobCache[l[0]]) return Promise.resolve(blobCache[l[0]]);
    return fetch(CDN + l[0]).then(function (r) {
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.arrayBuffer();
    }).then(function (buf) {
      if (buf.byteLength < 200) throw new Error('empty');
      var u = new Uint8Array(buf.slice(0, 4)), ext = 'ogg', mime = 'audio/ogg';
      if (u[0] === 0x4F && u[1] === 0x67) { ext = 'ogg'; mime = 'audio/ogg'; }
      else if ((u[0] === 0x49 && u[1] === 0x44) || u[0] === 0xFF) { ext = 'mp3'; mime = 'audio/mpeg'; }
      else if (u[0] === 0x52 && u[1] === 0x49) { ext = 'wav'; mime = 'audio/wav'; }
      var o = { blob: new Blob([buf], { type: mime }), ext: ext };
      blobCache[l[0]] = o; return o;
    });
  }
  function badRow(i, msg) {
    var r = list.querySelector('.row[data-i="' + i + '"]'); if (r) r.classList.add('bad');
    ostate(msg, true); toast(msg);
  }
  function playOrig(i, then) {
    cur = i; mark();
    var l = L[i], tried = false;
    au.onended = then || null;
    au.onloadedmetadata = function () { origDur = au.duration || 0; showDur(); };
    au.onplaying = function () { ostate('در حال پخش: ' + l[3]); };
    au.onerror = function () {
      if (!tried) {
        tried = true; ostate('در حال بارگذاری از راه دوم\u2026');
        fetchOrig(i).then(function (o) {
          au.src = URL.createObjectURL(o.blob); var p = au.play(); if (p && p.catch) p.catch(function () {});
        }).catch(function () {
          badRow(i, 'این صدا روی سرور صدا نیست (کد فایل ' + l[0] + ')');
          if (then) then();
        });
        return;
      }
      badRow(i, 'این صدا پخش نشد (کد فایل ' + l[0] + ')');
      if (then) then();
    };
    ostate('در حال بارگذاری\u2026');
    au.src = CDN + l[0];
    var p = au.play(); if (p && p.catch) p.catch(function () {});
  }
  function putBlob(blob, name, sub) {
    if (root && rootOk) {
      return root.getDirectoryHandle('original', { create: true }).then(function (d) { return d.getDirectoryHandle(sub, { create: true }); })
        .then(function (d) { return d.getFileHandle(name, { create: true }); })
        .then(function (fh) { return fh.createWritable(); })
        .then(function (w) { return w.write(blob).then(function () { return w.close(); }); }).then(function () { return 'folder'; });
    }
    var a2 = document.createElement('a'); a2.href = URL.createObjectURL(blob); a2.download = sub + '__' + name;
    document.body.appendChild(a2); a2.click(); setTimeout(function () { URL.revokeObjectURL(a2.href); a2.remove(); }, 3000);
    return Promise.resolve('download');
  }
  function openTab(i) {
    var a2 = document.createElement('a'); a2.href = CDN + L[i][0]; a2.target = '_blank'; a2.rel = 'noopener';
    document.body.appendChild(a2); a2.click(); a2.remove();
  }
  function dlOrig(i, btn) {
    var l = L[i], g = G[l[1]];
    if (btn) btn.disabled = true;
    return fetchOrig(i).then(function (o) {
      return putBlob(o.blob, l[3] + '.' + o.ext, safe(g[0])).then(function (how) {
        toast(how === 'folder' ? 'ذخیره شد: original/' + safe(g[0]) + '/' + l[3] + '.' + o.ext : 'دانلود شد: ' + l[3] + '.' + o.ext); return true;
      });
    }).catch(function () {
      toast('دانلود مستقیم ممکن نشد: صدا در تب جدید باز شد، راست\u200cکلیک و «ذخیره» بزن');
      openTab(i); return false;
    }).then(function (r) { if (btn) btn.disabled = false; return r; });
  }
  function linkList(gi) {
    var v = null; for (var k = 0; k < view.length; k++) if (view[k][0] === gi) { v = view[k]; break; }
    var arr = v ? v[1] : byG[gi], txt = arr.map(function (i) { return CDN + L[i][0] + '\t' + L[i][3]; }).join('\n') + '\n';
    var a2 = document.createElement('a'); a2.href = URL.createObjectURL(new Blob([txt], { type: 'text/plain' })); a2.download = safe(G[gi][0]) + '_links.txt';
    document.body.appendChild(a2); a2.click(); setTimeout(function () { URL.revokeObjectURL(a2.href); a2.remove(); }, 2000);
  }
  function dlGroup(gi, btn) {
    var v = null; for (var k = 0; k < view.length; k++) if (view[k][0] === gi) { v = view[k]; break; }
    var arr = (v ? v[1] : byG[gi]).slice(), n = 0, fail = 0, txt = btn.textContent;
    btn.disabled = true;
    (function next() {
      if (!arr.length) { btn.disabled = false; btn.textContent = txt; toast(n || !fail ? 'تمام شد: ' + fa(n) + ' صدا' + (fail ? '، ' + fa(fail) + ' تا روی سرور نبود' : '') : 'مرورگر دانلود مستقیم را نداد یا صدا روی سرور نیست؛ «فهرست لینک\u200cها» یا \u2b07 هر خط را امتحان کن'); return; }
      var i = arr.shift(); btn.textContent = '\u2b07 ' + fa(n + fail + 1) + '\u2026';
      var l = L[i], g = G[l[1]];
      fetchOrig(i).then(function (o) { return putBlob(o.blob, l[3] + '.' + o.ext, safe(g[0])); })
        .then(function () { n++; }, function () { fail++; }).then(function () { setTimeout(next, 120); });
    })();
  }

  // ---------------------------------------------------------------- folder (File System Access)
  var canFS = !!window.showDirectoryPicker;
  function idb() { return new Promise(function (res, rej) { var r = indexedDB.open('wfadub', 1); r.onupgradeneeded = function () { r.result.createObjectStore('kv'); }; r.onsuccess = function () { res(r.result); }; r.onerror = function () { rej(r.error); }; }); }
  function idbSet(k, v) { return idb().then(function (db) { return new Promise(function (res) { var t = db.transaction('kv', 'readwrite'); t.objectStore('kv').put(v, k); t.oncomplete = res; t.onerror = res; }); }); }
  function idbGet(k) { return idb().then(function (db) { return new Promise(function (res) { var t = db.transaction('kv'); var r = t.objectStore('kv').get(k); r.onsuccess = function () { res(r.result); }; r.onerror = function () { res(null); }; }); }); }
  function folderUI() {
    var b = $('folder'), s = $('fstate');
    if (!canFS) { b.textContent = '\u2913 بدون پوشه: فایل\u200cها دانلود می\u200cشوند'; b.disabled = true; s.textContent = 'ذخیره\u0654 مستقیم در پوشه فقط در Chrome یا Edge کار می\u200cکند.'; return; }
    if (root && rootOk) { b.textContent = '' + root.name; s.textContent = 'ذخیره در: ' + root.name + '/fa/<گروه>/<اسم خط>.wav'; }
    else if (root) { b.textContent = 'اجازه\u0654 دوباره برای «' + root.name + '»'; s.textContent = 'مرورگر برای نوشتن در پوشه دوباره اجازه می\u200cخواهد.'; }
    else { b.textContent = 'انتخاب پوشه\u0654 دوبله'; s.textContent = 'یک بار پوشه را انتخاب کن؛ هر ضبط تأییدشده همان\u200cجا ذخیره می\u200cشود.'; }
  }
  $('folder').addEventListener('click', function () {
    if (root && !rootOk) { root.requestPermission({ mode: 'readwrite' }).then(function (p) { rootOk = p === 'granted'; folderUI(); if (rootOk) scan(); }); return; }
    window.showDirectoryPicker({ mode: 'readwrite' }).then(function (h) { root = h; rootOk = true; idbSet('root', h); folderUI(); scan(); }).catch(function () {});
  });
  function scan() {
    if (!root) return;
    var map = {}; L.forEach(function (l) { map[safe(G[l[1]][0]) + '/' + l[3] + '.wav'] = l[0]; });
    root.getDirectoryHandle('fa', { create: true }).then(function (fad) {
      var jobs = [];
      return (async function () {
        for await (var e of fad.values()) {
          if (e.kind !== 'directory') continue;
          for await (var f of e.values()) { var fid = map[e.name + '/' + f.name]; if (fid) done[fid] = 1; }
        }
      })();
    }).then(function () { save('wfadub_done', done); render(); toast('پوشه بررسی شد: ضبط\u200cهای قبلی علامت خوردند'); }).catch(function () {});
  }
  if (canFS) idbGet('root').then(function (h) {
    if (!h) { folderUI(); return; }
    root = h;
    h.queryPermission({ mode: 'readwrite' }).then(function (p) { rootOk = p === 'granted'; folderUI(); if (rootOk) scan(); });
  }).catch(folderUI); else folderUI();

  // ---------------------------------------------------------------- studio (record + effects)
  var S = $('studio'), sline = -1, media = null, rec = null, chunks = [], raw = null, sr = 48000, proc = null, ac = null, srcNode = null, meterRAF = 0, recT0 = 0;
  var prm = DSP.full({}), preset = 'none', opt = { trim: true, norm: true };
  var SL = [['pitch', 'زیر و بمی (نیم\u200cپرده)', -12, 12, 1], ['rev', 'ریورب', 0, 1, 0.05], ['revTime', 'طول ریورب (ثانیه)', 0.3, 6, 0.1], ['echo', 'پژواک', 0, 1, 0.05], ['echoTime', 'فاصله\u0654 پژواک', 0.05, 1, 0.01], ['dist', 'خش / زبری', 0, 1, 0.05], ['chorus', 'ک\u064fر (چندصدایی)', 0, 1, 0.05], ['trem', 'لرزش صدا', 0, 1, 0.05], ['hp', 'حذف بم (Hz)', 0, 1500, 10], ['lp', 'حذف زیر (Hz، ۰ = خاموش)', 0, 12000, 100], ['gain', 'بلندی', 0.2, 1.5, 0.05]];
  (function buildFx() {
    var h = '';
    Object.keys(DSP.PRESETS).forEach(function (k) { h += '<button data-p="' + k + '" aria-pressed="' + (k === 'none') + '">' + DSP.PRESETS[k].label + '</button>'; });
    $('presets').innerHTML = h;
    var s = '';
    SL.forEach(function (x) { s += '<label class="sl"><span>' + x[1] + '</span><input type="range" data-k="' + x[0] + '" min="' + x[2] + '" max="' + x[3] + '" step="' + x[4] + '"><output></output></label>'; });
    $('sliders').innerHTML = s;
    syncSliders();
  })();
  function syncSliders() {
    [].forEach.call($('sliders').querySelectorAll('input'), function (el) { el.value = prm[el.dataset.k]; el.nextElementSibling.textContent = fmtP(el.dataset.k, prm[el.dataset.k]); });
  }
  function fmtP(k, v) { v = +v; if (k === 'pitch') return (v > 0 ? '+' : '') + fa(v); if (k === 'hp' || k === 'lp') return v ? fa(Math.round(v)) : 'خاموش'; if (k === 'revTime' || k === 'echoTime') return fa(v.toFixed(2)); return fa(Math.round(v * 100)) + '\u066a'; }
  $('presets').addEventListener('click', function (e) {
    var b = e.target.closest('button'); if (!b) return;
    preset = b.dataset.p; prm = DSP.full(DSP.PRESETS[preset].p);
    [].forEach.call(this.querySelectorAll('button'), function (x) { x.setAttribute('aria-pressed', x === b ? 'true' : 'false'); });
    syncSliders(); reprocess(true);
  });
  $('sliders').addEventListener('input', function (e) {
    var el = e.target; if (!el.dataset.k) return;
    prm[el.dataset.k] = +el.value; el.nextElementSibling.textContent = fmtP(el.dataset.k, el.value);
    [].forEach.call($('presets').querySelectorAll('button'), function (x) { x.setAttribute('aria-pressed', 'false'); });
    reprocess(false);
  });
  $('otrim').addEventListener('change', function () { opt.trim = this.checked; reprocess(false); });
  $('onorm').addEventListener('change', function () { opt.norm = this.checked; reprocess(false); });

  function openStudio(i) {
    sline = i; cur = i; mark();
    var l = L[i], g = G[l[1]];
    $('sname').textContent = l[3];
    $('sgroup').innerHTML = esc(g[0]) + ' \u00b7 ' + CAT_FA[CATS[l[2]]] + (done[l[0]] ? ' \u00b7 <b class="okc">قبلا\u064b ضبط شده (ذخیره\u0654 دوباره جایگزین می\u200cشود)</b>' : '');
    $('sav').innerHTML = avatar(g);
    var cn2 = crNames(l[1], 6);
    $('stext').innerHTML = (cn2.list.length ? '<div class="gc">' + cn2.list.map(esc).join('\u060c ') + (cn2.more ? ' \u0648 ' + fa(cn2.more) + ' \u062a\u0627\u06cc \u062f\u06cc\u06af\u0631' : '') + '</div>' : '') +
      (textOf(l[0]) ? '<div class="say">' + txHTML(l[0]) + '</div>' : '<div class="say none">\u0628\u0631\u0627\u06cc \u0627\u06cc\u0646 \u0635\u062f\u0627 \u0645\u062a\u0646\u06cc \u062f\u0631 \u0628\u0627\u0632\u06cc \u0646\u06cc\u0633\u062a\u061b \u0635\u062f\u0627\u06cc \u0627\u0635\u0644\u06cc \u0631\u0627 \u06af\u0648\u0634 \u0628\u062f\u0647</div>');
    raw = null; proc = null; origDur = 0; drawWave(); showDur(); setRecUI('idle');
    crop = { a: 0, b: 1 }; prepOld(i);
    S.classList.add('open'); document.body.classList.add('studio');
    playOrig(i);
  }
  function closeStudio() { stopRec(true); stopTake(); S.classList.remove('open'); document.body.classList.remove('studio'); }
  $('sclose').addEventListener('click', closeStudio);
  $('sorig').addEventListener('click', function () { if (sline >= 0) playOrig(sline); });
  $('sdl').addEventListener('click', function () { if (sline >= 0) dlOrig(sline, this); });
  $('srec').addEventListener('click', function () { if (rec && rec.state === 'recording') stopRec(false); else startRec(); });
  $('stake').addEventListener('click', function () { playTake(); });
  $('sab').addEventListener('click', function () { if (sline < 0 || !proc) return; playOrig(sline, function () { setTimeout(playTake, 250); }); });
  $('ssave').addEventListener('click', saveTake);
  $('sredo').addEventListener('click', function () { crop = { a: 0, b: 1 }; raw = null; proc = null; drawWave(); showDur(); setRecUI('idle'); });
  $('snext').addEventListener('click', nextLine);

  // ---------------------------------------------------------------- earlier takes: play, edit, crop
  var crop = { a: 0, b: 1 }, oldTake = null;
  function readTake(i) {
    var l = L[i], g = G[l[1]];
    if (!(root && rootOk)) return Promise.reject(new Error('nofolder'));
    return root.getDirectoryHandle('fa').then(function (d) { return d.getDirectoryHandle(safe(g[0])); })
      .then(function (d) { return d.getFileHandle(l[3] + '.wav'); })
      .then(function (fh) { return fh.getFile(); })
      .then(function (f) { return f.arrayBuffer(); })
      .then(function (ab) { return getAC().decodeAudioData(ab); })
      .then(function (buf) {
        var n = buf.length, x = new Float32Array(n);
        for (var c = 0; c < buf.numberOfChannels; c++) { var d = buf.getChannelData(c); for (var k = 0; k < n; k++) x[k] += d[k] / buf.numberOfChannels; }
        return { x: x, sr: buf.sampleRate };
      });
  }
  function playPCM(x, rate) {
    stopTake();
    var a = getAC(), b = a.createBuffer(1, x.length, rate); b.getChannelData(0).set(x);
    srcNode = a.createBufferSource(); srcNode.buffer = b; srcNode.connect(a.destination); srcNode.start();
  }
  function playMine(i) {
    readTake(i).then(function (t) { playPCM(t.x, t.sr); })
      .catch(function (e) { toast(e && e.message === 'nofolder' ? 'برای شنیدن ضبط‌های قبلی، پوشهٔ دوبله باید انتخاب و اجازه داده شده باشد' : 'فایل این خط توی پوشه پیدا نشد'); });
  }
  function prepOld(i) {
    oldTake = null; $('sold').classList.remove('on'); $('sedit').classList.remove('on');
    if (!done[L[i][0]] || !(root && rootOk)) return;
    readTake(i).then(function (t) { if (sline !== i) return; oldTake = t; $('sold').classList.add('on'); $('sedit').classList.add('on'); }).catch(function () {});
  }
  $('sold').addEventListener('click', function () { if (oldTake) playPCM(oldTake.x, oldTake.sr); });
  $('sedit').addEventListener('click', function () {
    if (!oldTake) return;
    stopTake(); opt.trim = false; opt.norm = false; $('otrim').checked = false; $('onorm').checked = false;
    sr = oldTake.sr; crop = { a: 0, b: 1 }; raw = oldTake.x;
    var nb = $('presets').querySelector('[data-p="none"]'); if (nb) nb.click(); else reprocess(true);
    toast('ضبط قبلی بارگذاری شد: با دستگیره‌های دو طرف موج برش بزن و ذخیره کن');
  });
  function outSamples() {
    if (!proc) return null;
    var n = proc.length, s = Math.floor(crop.a * n), e = Math.max(s + 1, Math.floor(crop.b * n));
    if (s === 0 && e >= n) return proc;
    var y = proc.slice(s, e), f = Math.min(Math.floor(sr * 0.006), y.length >> 1);
    for (var k = 0; k < f; k++) { var g = k / f; y[k] *= g; y[y.length - 1 - k] *= g; }
    return y;
  }
  function drawCrop() {
    var cv = $('wave'), w = cv.width, h = cv.height, c = cv.getContext('2d'), info = $('scrop');
    if (!proc) { info.textContent = ''; return; }
    var xa = crop.a * w, xb = crop.b * w, p = window.devicePixelRatio || 1;
    c.fillStyle = 'rgba(8,11,16,.65)'; c.fillRect(0, 0, xa, h); c.fillRect(xb, 0, w - xb, h);
    c.fillStyle = '#e9c46a'; c.fillRect(xa - p, 0, 2 * p, h); c.fillRect(xb - p, 0, 2 * p, h);
    c.fillRect(xa - 4 * p, h / 2 - 14 * p, 8 * p, 28 * p); c.fillRect(xb - 4 * p, h / 2 - 14 * p, 8 * p, 28 * p);
    var t = proc.length / sr;
    info.textContent = 'برش: از ' + fa((crop.a * t).toFixed(2)) + ' تا ' + fa((crop.b * t).toFixed(2)) + ' ثانیه (دابل‌کلیک = برگرداندن)';
  }
  (function () {
    var cv = $('wave'), drag = 0;
    function fx(e) { var r = cv.getBoundingClientRect(); return Math.min(1, Math.max(0, (e.clientX - r.left) / r.width)); }
    function move(e) {
      if (!drag || !proc) return;
      var x = fx(e), min = Math.min(0.5, 0.05 / Math.max(0.05, proc.length / sr));
      if (drag === 1) crop.a = Math.min(x, crop.b - min); else crop.b = Math.max(x, crop.a + min);
      drawWave(); showDur();
    }
    cv.addEventListener('pointerdown', function (e) {
      if (!proc) return; var x = fx(e);
      drag = Math.abs(x - crop.a) <= Math.abs(x - crop.b) ? 1 : 2;
      try { cv.setPointerCapture(e.pointerId); } catch (x2) {} move(e);
    });
    cv.addEventListener('pointermove', move);
    cv.addEventListener('pointerup', function (e) { drag = 0; try { cv.releasePointerCapture(e.pointerId); } catch (x2) {} });
    cv.addEventListener('dblclick', function () { crop = { a: 0, b: 1 }; drawWave(); showDur(); });
  })();
  function setRecUI(s) {
    var b = $('srec');
    b.classList.toggle('on', s === 'rec');
    b.innerHTML = s === 'rec' ? '\u25a0 توقف' : '\u25cf ضبط';
    $('ssave').disabled = !proc; $('stake').disabled = !proc; $('sab').disabled = !proc; $('sredo').disabled = !raw;
    $('sstate').textContent = s === 'rec' ? 'در حال ضبط\u2026' : s === 'proc' ? 'در حال اعمال افکت\u2026' : proc ? 'آماده: گوش بده، افکت بزن، بعد ذخیره کن' : 'دکمه\u0654 ضبط یا کلید R';
  }
  function getAC() { if (!ac) ac = new (window.AudioContext || window.webkitAudioContext)(); if (ac.state === 'suspended') ac.resume(); return ac; }
  // the mic is asked for once and kept for the page: on a file:// page Chrome forgets the answer, so
  // reopening the stream for every take asked for permission every time. Between takes it is muted.
  var micStream = null, micSrc = null;
  function getMic() {
    if (micStream && micStream.getTracks().every(function (t) { return t.readyState === 'live'; })) {
      micStream.getTracks().forEach(function (t) { t.enabled = true; });
      return Promise.resolve(micStream);
    }
    return navigator.mediaDevices.getUserMedia({ audio: { echoCancellation: false, noiseSuppression: true, autoGainControl: false, channelCount: 1 } }).then(function (m) { micStream = m; return m; });
  }
  function startRec() {
    stopTake();
    if (!navigator.mediaDevices || !window.MediaRecorder) { toast('این مرورگر ضبط صدا را پشتیبانی نمی\u200cکند'); return; }
    getMic().then(function (m) {
      media = m; chunks = [];
      rec = new MediaRecorder(m);
      rec.ondataavailable = function (e) { if (e.data && e.data.size) chunks.push(e.data); };
      rec.onstop = function () {
        var blob = new Blob(chunks, { type: rec.mimeType || 'audio/webm' });
        media.getTracks().forEach(function (t) { t.enabled = false; }); media = null;
        if (rec.wfaCancel) return;
        setRecUI('proc');
        blob.arrayBuffer().then(function (ab) { return getAC().decodeAudioData(ab); }).then(function (buf) {
          sr = buf.sampleRate; var n = buf.length, x = new Float32Array(n);
          for (var c = 0; c < buf.numberOfChannels; c++) { var d = buf.getChannelData(c); for (var k = 0; k < n; k++) x[k] += d[k] / buf.numberOfChannels; }
          crop = { a: 0, b: 1 }; raw = x; reprocess(false);
        }).catch(function () { toast('خواندن ضبط نشد؛ دوباره امتحان کن'); setRecUI('idle'); });
      };
      if (micSrc) { try { micSrc.disconnect(); } catch (e) {} }
      var a = getAC(), s = a.createMediaStreamSource(m), an = a.createAnalyser(); an.fftSize = 1024; s.connect(an); micSrc = s;
      var buf = new Float32Array(an.fftSize);
      (function meter() {
        an.getFloatTimeDomainData(buf); var p = 0; for (var k = 0; k < buf.length; k++) p = Math.max(p, Math.abs(buf[k]));
        $('meter').style.width = Math.min(100, p * 110) + '%'; $('meter').classList.toggle('clip', p > 0.98);
        $('stime').textContent = fa(((performance.now() - recT0) / 1000).toFixed(1)) + ' ث';
        meterRAF = requestAnimationFrame(meter);
      })();
      recT0 = performance.now(); rec.start(); setRecUI('rec');
    }).catch(function () { toast('اجازه\u0654 میکروفون داده نشد'); });
  }
  function stopRec(cancel) {
    cancelAnimationFrame(meterRAF); $('meter').style.width = '0';
    if (rec && rec.state === 'recording') { rec.wfaCancel = !!cancel; rec.stop(); }
  }
  var rpT = 0, rpN = 0;
  function reprocess(now) {
    if (!raw) return;
    clearTimeout(rpT);
    rpT = setTimeout(function () {
      var my = ++rpN; setRecUI('proc');
      var x = opt.trim ? DSP.trimSilence(raw, sr, -45) : raw;
      DSP.render(x, sr, prm).then(function (y) {
        if (my !== rpN) return;
        proc = opt.norm ? DSP.normalize(y, -1) : y;
        drawWave(); showDur(); setRecUI('idle');
      });
    }, now ? 0 : 180);
  }
  function playTake() {
    if (!proc) return; stopTake();
    playPCM(outSamples(), sr);
  }
  function stopTake() { if (srcNode) { try { srcNode.stop(); } catch (e) {} srcNode = null; } }
  function showDur() {
    var t = proc ? (crop.b - crop.a) * proc.length / sr : 0;
    $('sdur').innerHTML = 'اصلی: <b>' + (origDur ? fa(origDur.toFixed(1)) + ' ث' : '\u2014') + '</b> \u00b7 تو: <b>' + (t ? fa(t.toFixed(1)) + ' ث' : '\u2014') + '</b>' +
      (t && origDur && t > origDur * 1.6 ? ' <span class="warn">خیلی بلندتر از اصلی است</span>' : '');
  }
  function drawWave() { drawWave0(); drawCrop(); }
  function drawWave0() {
    var cv = $('wave'), w = cv.width = cv.clientWidth * (window.devicePixelRatio || 1), h = cv.height = cv.clientHeight * (window.devicePixelRatio || 1), c = cv.getContext('2d');
    c.clearRect(0, 0, w, h); c.fillStyle = '#2a3440'; c.fillRect(0, h / 2, w, 1);
    var x = proc; if (!x) return;
    c.fillStyle = '#f0c454';
    var step = Math.max(1, Math.floor(x.length / w));
    for (var i = 0; i < w; i++) { var mn = 1, mx = -1; for (var k = i * step; k < (i + 1) * step && k < x.length; k++) { var v = x[k]; if (v < mn) mn = v; if (v > mx) mx = v; } if (mx < mn) continue; c.fillRect(i, (1 - mx) * h / 2, 1, Math.max(1, (mx - mn) * h / 2)); }
  }
  function saveTake() {
    if (!proc || sline < 0) return;
    var l = L[sline], g = G[l[1]], wav = new Blob([DSP.encodeWav(outSamples(), sr)], { type: 'audio/wav' }), name = l[3] + '.wav';
    function ok() { done[l[0]] = 1; save('wfadub_done', done); toast('ذخیره شد: ' + name); var r = list.querySelector('.row[data-i="' + sline + '"]'); if (r) { r.classList.add('ok'); r.querySelector('.st').textContent = '\u2713'; } progress(); nextLine(); }
    if (root && rootOk) {
      root.getDirectoryHandle('fa', { create: true }).then(function (d) { return d.getDirectoryHandle(safe(g[0]), { create: true }); })
        .then(function (d) { return d.getFileHandle(name, { create: true }); })
        .then(function (fh) { return fh.createWritable(); })
        .then(function (w) { return w.write(wav).then(function () { return w.close(); }); })
        .then(ok).catch(function (e) { toast('ذخیره نشد: ' + (e && e.message || e)); });
    } else {
      var a = document.createElement('a'); a.href = URL.createObjectURL(wav); a.download = safe(g[0]) + '__' + name; document.body.appendChild(a); a.click(); setTimeout(function () { URL.revokeObjectURL(a.href); a.remove(); }, 2000); ok();
    }
  }
  function nextLine() {
    if (sline < 0) return;
    var gi = L[sline][1], a = byG[gi].filter(lineOk), k = a.indexOf(sline);
    for (var j = k + 1; j < a.length; j++) if (!done[L[a[j]][0]]) { openStudio(a[j]); return; }
    toast('همه\u0654 خط\u200cهای این گروه ضبط شده\u200cاند'); raw = null; proc = null; drawWave(); setRecUI('idle');
  }
  $('export').addEventListener('click', function () {
    var rows = ['fid,group,line,file'];
    L.forEach(function (l) { if (done[l[0]]) rows.push([l[0], '"' + G[l[1]][0] + '"', l[3], 'fa/' + safe(G[l[1]][0]) + '/' + l[3] + '.wav'].join(',')); });
    var a = document.createElement('a'); a.href = URL.createObjectURL(new Blob(['\ufeff' + rows.join('\n')], { type: 'text/csv' })); a.download = 'wowfa-dub-list.csv'; a.click();
  });
  document.addEventListener('keydown', function (e) {
    if (!S.classList.contains('open') || e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT') return;
    var k = e.key.toLowerCase();
    if (k === 'r' || k === 'ق') { e.preventDefault(); $('srec').click(); }
    else if (k === ' ') { e.preventDefault(); playTake(); }
    else if (k === 'o' || k === 'خ') { e.preventDefault(); $('sorig').click(); }
    else if (k === 'enter') { e.preventDefault(); saveTake(); }
    else if (k === 'n' || k === 'د') { e.preventDefault(); nextLine(); }
    else if (k === 'escape') closeStudio();
  });
  var tt; function toast(m) { var t = $('toast'); t.textContent = m; t.classList.add('on'); clearTimeout(tt); tt = setTimeout(function () { t.classList.remove('on'); }, 2600); }
  render();
};
