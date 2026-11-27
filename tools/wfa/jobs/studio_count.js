const fs = require('fs');
const vm = require('vm');
const ctx = {};
ctx.window = ctx;
vm.createContext(ctx);
vm.runInContext(fs.readFileSync(process.argv[2], 'utf8'), ctx);
vm.runInContext(fs.readFileSync(process.argv[3], 'utf8'), ctx);
const R = ctx.VO_RAW;
const D = ctx.WfaBuild.build(R.L, R.G);
const out = { cats: D.cats, rows: {}, groups: D.groups.length, lines: D.lines.length, old: 0, h_groups: 0 };
D.groups.forEach(function (g) { if (g[1] === 'h') out.h_groups++; });
D.lines.forEach(function (l) {
  const k = (D.groups[l[1]][1] === 'h' ? 'p' : 'n') + l[2];
  out.rows[k] = (out.rows[k] || 0) + 1;
  if (l[6] === 'old') out.old++;
});
process.stdout.write(JSON.stringify(out));
