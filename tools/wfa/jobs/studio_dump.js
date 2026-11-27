const fs = require('fs');
const vm = require('vm');
const ctx = {};
ctx.window = ctx;
vm.createContext(ctx);
vm.runInContext(fs.readFileSync(process.argv[2], 'utf8'), ctx);
vm.runInContext(fs.readFileSync(process.argv[3], 'utf8'), ctx);
const want = JSON.parse(process.argv[4]);
const R = ctx.VO_RAW;
const D = ctx.WfaBuild.build(R.L, R.G);
const idx = {};
D.groups.forEach(function (g, i) { if (want.indexOf(g[0]) >= 0) idx[i] = g; });
const out = { groups: [], lines: [] };
Object.keys(idx).forEach(function (i) { const g = idx[i]; out.groups.push([g[0], g[1], g[2], g[3]]); });
D.lines.forEach(function (l) {
  if (idx[l[1]]) out.lines.push([l[0], idx[l[1]][0], D.cats[l[2]], l[3]]);
});
process.stdout.write(JSON.stringify(out));
