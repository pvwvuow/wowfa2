/* WoWFA dub studio - audio engine (pure functions + Web Audio offline chain) */
var DSP = (function () {
  'use strict';
  function hann(n) { var w = new Float32Array(n); for (var i = 0; i < n; i++) w[i] = 0.5 - 0.5 * Math.cos(2 * Math.PI * i / n); return w; }
  // granular pitch shift: same length, pitch moved by `semis` semitones
  function pitchShift(x, sr, semis) {
    if (!semis) return x;
    var r = Math.pow(2, semis / 12), G = Math.max(256, Math.round(sr * 0.05)), H = G >> 1, w = hann(G);
    var y = new Float32Array(x.length);
    for (var s = -H; s < x.length; s += H) {
      for (var i = 0; i < G; i++) {
        var o = s + i; if (o < 0 || o >= y.length) continue;
        var src = s + i * r; if (src < 0) continue;
        var k = src | 0; if (k + 1 >= x.length) break;
        var f = src - k; y[o] += (x[k] * (1 - f) + x[k + 1] * f) * w[i];
      }
    }
    return y;
  }
  function trimSilence(x, sr, db) {
    var th = Math.pow(10, (db || -45) / 20), pad = Math.round(sr * 0.06), a = 0, b = x.length - 1;
    while (a < x.length && Math.abs(x[a]) < th) a++;
    while (b > a && Math.abs(x[b]) < th) b--;
    if (a >= b) return x;
    return x.slice(Math.max(0, a - pad), Math.min(x.length, b + pad));
  }
  function normalize(x, peakDb) {
    var m = 0; for (var i = 0; i < x.length; i++) { var v = Math.abs(x[i]); if (v > m) m = v; }
    if (m < 1e-6) return x;
    var g = Math.pow(10, (peakDb == null ? -1 : peakDb) / 20) / m, y = new Float32Array(x.length);
    for (i = 0; i < x.length; i++) y[i] = x[i] * g;
    return y;
  }
  function encodeWav(x, sr) {
    var n = x.length, buf = new ArrayBuffer(44 + n * 2), v = new DataView(buf);
    function str(o, s) { for (var i = 0; i < s.length; i++) v.setUint8(o + i, s.charCodeAt(i)); }
    str(0, 'RIFF'); v.setUint32(4, 36 + n * 2, true); str(8, 'WAVE'); str(12, 'fmt ');
    v.setUint32(16, 16, true); v.setUint16(20, 1, true); v.setUint16(22, 1, true);
    v.setUint32(24, sr, true); v.setUint32(28, sr * 2, true); v.setUint16(32, 2, true); v.setUint16(34, 16, true);
    str(36, 'data'); v.setUint32(40, n * 2, true);
    for (var i = 0, o = 44; i < n; i++, o += 2) { var s = Math.max(-1, Math.min(1, x[i])); v.setInt16(o, s < 0 ? s * 0x8000 : s * 0x7fff, true); }
    return buf;
  }
  function makeIR(ctx, sec, decay) {
    var len = Math.max(1, Math.round(ctx.sampleRate * sec)), ir = ctx.createBuffer(2, len, ctx.sampleRate);
    for (var c = 0; c < 2; c++) { var d = ir.getChannelData(c); for (var i = 0; i < len; i++) d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, decay || 3); }
    return ir;
  }
  function curve(amount) {
    var k = amount * 100, n = 2048, c = new Float32Array(n);
    for (var i = 0; i < n; i++) { var x = i * 2 / n - 1; c[i] = (3 + k) * x * 20 * Math.PI / 180 / (Math.PI + k * Math.abs(x)); }
    return c;
  }
  var PRESETS = {
    none:     { label: 'بدون افکت', p: {} },
    hall:     { label: 'سالن / دانجن', p: { rev: 0.45, revTime: 3 } },
    ghost:    { label: 'روح / آندد', p: { pitch: -1, rev: 0.45, revTime: 2.6, lp: 5000, trem: 0.3, tremHz: 6, chorus: 0.3 } },
    demon:    { label: 'شیطان / دیو', p: { pitch: -5, dist: 0.35, rev: 0.25, revTime: 1.8, lp: 6500 } },
    giant:    { label: 'غول / موجود بزرگ', p: { pitch: -4, rev: 0.2, revTime: 1.5, lp: 7000 } },
    dragon:   { label: 'اژدها', p: { pitch: -6, dist: 0.15, rev: 0.35, revTime: 2.5 } },
    small:    { label: 'گنوم / گابلین', p: { pitch: 4, hp: 180 } },
    elemental:{ label: 'المنتال / جادویی', p: { pitch: -2, chorus: 0.6, rev: 0.35, revTime: 2, dist: 0.08 } },
    echo:     { label: 'پژواک', p: { echo: 0.4, echoTime: 0.28, echoFb: 0.35 } },
    radio:    { label: 'مکانیکی / رادیو', p: { hp: 600, lp: 3200, dist: 0.25 } },
    whisper:  { label: 'زمزمه / رؤیا', p: { hp: 300, rev: 0.5, revTime: 4, gain: 0.85 } }
  };
  var DEF = { pitch: 0, rev: 0, revTime: 2, echo: 0, echoTime: 0.3, echoFb: 0.3, dist: 0, chorus: 0, trem: 0, tremHz: 5, hp: 0, lp: 0, gain: 1 };
  function full(p) { var o = {}, k; for (k in DEF) o[k] = DEF[k]; for (k in (p || {})) o[k] = p[k]; return o; }
  // x: Float32Array mono, returns Promise<Float32Array>
  function render(x, sr, p0) {
    var p = full(p0);
    var dry = pitchShift(x, sr, p.pitch);
    var tail = Math.round(sr * Math.max(p.rev ? p.revTime : 0, p.echo ? p.echoTime * 6 : 0, 0.05));
    var OAC = (typeof OfflineAudioContext !== 'undefined') ? OfflineAudioContext : (typeof webkitOfflineAudioContext !== 'undefined' ? webkitOfflineAudioContext : null);
    if (!OAC) return Promise.resolve(dry);
    var ctx = new OAC(1, dry.length + tail, sr);
    var b = ctx.createBuffer(1, dry.length, sr); b.getChannelData(0).set(dry);
    var src = ctx.createBufferSource(); src.buffer = b;
    var node = src;
    function chain(n) { node.connect(n); node = n; }
    if (p.hp > 0) { var hp = ctx.createBiquadFilter(); hp.type = 'highpass'; hp.frequency.value = p.hp; chain(hp); }
    if (p.lp > 0) { var lp = ctx.createBiquadFilter(); lp.type = 'lowpass'; lp.frequency.value = p.lp; chain(lp); }
    if (p.dist > 0) { var ws = ctx.createWaveShaper(); ws.curve = curve(p.dist); ws.oversample = '4x'; chain(ws); }
    if (p.chorus > 0) {
      var cd = ctx.createDelay(0.1), cg = ctx.createGain(), lfo = ctx.createOscillator(), lg = ctx.createGain(), mix = ctx.createGain();
      cd.delayTime.value = 0.018; lfo.frequency.value = 0.9; lg.gain.value = 0.006; lfo.connect(lg); lg.connect(cd.delayTime); lfo.start();
      cg.gain.value = p.chorus; node.connect(mix); node.connect(cd); cd.connect(cg); cg.connect(mix); node = mix;
    }
    if (p.trem > 0) {
      var tg = ctx.createGain(), tl = ctx.createOscillator(), td = ctx.createGain();
      tg.gain.value = 1 - p.trem / 2; tl.frequency.value = p.tremHz; td.gain.value = p.trem / 2; tl.connect(td); td.connect(tg.gain); tl.start();
      chain(tg);
    }
    var out = ctx.createGain(); out.gain.value = p.gain;
    var dg = ctx.createGain(); dg.gain.value = 1; node.connect(dg); dg.connect(out);
    if (p.rev > 0) { var cv = ctx.createConvolver(); cv.buffer = makeIR(ctx, p.revTime, 3); var rg = ctx.createGain(); rg.gain.value = p.rev; node.connect(cv); cv.connect(rg); rg.connect(out); dg.gain.value = 1 - p.rev * 0.4; }
    if (p.echo > 0) { var ed = ctx.createDelay(2), ef = ctx.createGain(), eg = ctx.createGain(); ed.delayTime.value = p.echoTime; ef.gain.value = p.echoFb; eg.gain.value = p.echo; node.connect(ed); ed.connect(ef); ef.connect(ed); ed.connect(eg); eg.connect(out); }
    out.connect(ctx.destination);
    src.start();
    return ctx.startRendering().then(function (buf) { return buf.getChannelData(0).slice(); });
  }
  return { pitchShift: pitchShift, trimSilence: trimSilence, normalize: normalize, encodeWav: encodeWav, render: render, PRESETS: PRESETS, DEF: DEF, full: full };
})();
if (typeof module !== 'undefined') module.exports = DSP;
