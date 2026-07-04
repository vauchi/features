// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Reports, per feature, how many Gherkin steps match the wired core step
// vocabulary (STEP-CATALOG.md). Steps outside the catalog are what make a
// scenario skip against vauchi-core. Informational (exit 0) — it surfaces the
// reuse gap so authors compose new scenarios from the catalog and burn the
// gap down. See problems/2026-07-04-cucumber-backgrounds-fail-silently.
//
//   node scripts/check-step-catalog.mjs
import fs from "node:fs";

const CATALOG = "STEP-CATALOG.md";

if (!fs.existsSync(CATALOG)) {
  console.error(`ERROR: ${CATALOG} not found — run scripts/gen-step-catalog.sh`);
  process.exit(1);
}

// Catalog patterns -> anchored regexes ({string}/{int}/{word} are params).
const patterns = fs
  .readFileSync(CATALOG, "utf8")
  .split("\n")
  .filter((l) => l.startsWith("- `"))
  .map((l) => l.slice(3, l.lastIndexOf("`")));

const toRegex = (p) => {
  const esc = p.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const body = esc
    .replace(/\\\{string\\\}/g, '"[^"]*"')
    .replace(/\\\{int\\\}/g, "-?\\d+")
    .replace(/\\\{word\\\}/g, "\\S+");
  return new RegExp("^" + body + "$");
};
const regexes = patterns.map(toRegex);
const bound = (step) => regexes.some((r) => r.test(step));

const stepRe = /^\s*(?:Given|When|Then|And|But)\s+(.+?)\s*$/;
const files = fs.readdirSync(".").filter((f) => f.endsWith(".feature")).sort();

let total = 0;
let covered = 0;
const rows = [];
for (const file of files) {
  let t = 0;
  let c = 0;
  let inDoc = false;
  for (const line of fs.readFileSync(file, "utf8").split("\n")) {
    const trimmed = line.trim();
    if (trimmed.startsWith('"""')) {
      inDoc = !inDoc;
      continue;
    }
    if (inDoc || trimmed.startsWith("|")) continue;
    const m = stepRe.exec(line);
    if (!m) continue;
    t++;
    if (bound(m[1])) c++;
  }
  total += t;
  covered += c;
  if (t > 0) rows.push({ file, c, t });
}

rows.sort((a, b) => b.c / b.t - a.c / a.t);
console.log("Step-catalog coverage (steps matching the wired core vocabulary):\n");
for (const { file, c, t } of rows) {
  const pct = Math.round((100 * c) / t);
  console.log(`  ${String(pct).padStart(3)}%  ${String(c).padStart(4)}/${String(t).padEnd(4)}  ${file}`);
}
const pctT = total ? Math.round((100 * covered) / total) : 0;
console.log(
  `\n  TOTAL: ${covered}/${total} steps (${pctT}%) across ${rows.length} features; ${patterns.length} catalog patterns.`,
);
console.log(
  "\n  Raise this by composing scenarios from STEP-CATALOG.md (add a core step\n" +
    "  def + regenerate when you need a new one). UI / multi-party steps are\n" +
    "  out of scope for the core runner.",
);

// Floor gate: catalog-backed step count must not regress (a wired step being
// rewritten to free-form drops it). Deterministic within this repo — the
// catalog is committed here, so no cross-repo flake. Bump the baseline when
// you wire more; if it drops, investigate the binding, don't just lower it.
const minIdx = process.argv.indexOf("--min");
if (minIdx !== -1) {
  const min = parseInt(process.argv[minIdx + 1], 10);
  if (covered < min) {
    console.error(
      `\n  GATE failed: ${covered} catalog-backed steps < baseline ${min} — a wired\n` +
        "  step was rewritten to free-form (lost its catalog binding).",
    );
    process.exit(1);
  }
}
