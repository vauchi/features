// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Fails a features change that unbinds a scenario core runs today.
//
// Core's cucumber gate counts the scenarios whose every step (Background
// included) binds a core step definition, and fails when that count drops.
// Core CI checks out features main unpinned, so a features MR that rewords
// or deletes a wired step turned every core pipeline red after it merged
// (vauchi/private#700: features 9e0bbf8, 'Unknown version byte is
// rejected'). This check runs in the features MR instead: it reads core's
// step definitions, finds the scenarios wired at the base ref and on the
// branch, and reports any wired at the base that are not wired now.
//
//   node scripts/check-wired-scenarios.mjs --steps <core>/vauchi-core/tests/steps --base origin/main
//
// cucumber-rs semantics: #[given("...")] is an exact literal,
// #[given(expr = "...")] a cucumber expression, #[given(regex = r"...")] a
// regex. The model reproduces core's own count (135 of 1440 on 2026-10-18).

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ATTRIBUTE =
  /#\[(?:given|when|then)\(\s*(?:(expr|regex)\s*=\s*)?(?:r#"([\s\S]*?)"#|r"([\s\S]*?)"|"((?:[^"\\]|\\.)*)")\s*\)\]/g;

const escapeRegex = (text) => text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

const PARAMETERS = {
  "{string}": `(?:"[^"]*"|'[^']*')`,
  "{int}": "-?\\d+",
  "{float}": "-?\\d*\\.?\\d+",
  "{word}": "[^\\s]+",
  "{}": ".*",
};

function expressionPart(part) {
  let out = "";
  for (let i = 0; i < part.length; i++) {
    if (part[i] === "\\" && i + 1 < part.length) {
      out += escapeRegex(part[i + 1]);
      i++;
      continue;
    }
    const parameter = Object.keys(PARAMETERS).find((p) => part.startsWith(p, i));
    if (parameter) {
      out += PARAMETERS[parameter];
      i += parameter.length - 1;
      continue;
    }
    if (part[i] === "(") {
      const close = part.indexOf(")", i);
      out += "(?:" + escapeRegex(part.slice(i + 1, close)) + ")?";
      i = close;
      continue;
    }
    out += escapeRegex(part[i]);
  }
  return out;
}

// A cucumber expression: parameters, optional text "(s)" and alternative
// text "a/an" (within one word).
export function expressionRegex(expression) {
  const body = expression
    .split(/(\s+)/)
    .map((word) =>
      /\s/.test(word) || !word.includes("/") || word.includes("{")
        ? expressionPart(word)
        : "(?:" + word.split("/").map(expressionPart).join("|") + ")",
    )
    .join("");
  return new RegExp("^" + body + "$");
}

export function patternsFrom(stepsDir) {
  const patterns = [];
  for (const file of fs.readdirSync(stepsDir).filter((f) => f.endsWith(".rs")).sort()) {
    const source = fs.readFileSync(path.join(stepsDir, file), "utf8");
    for (const match of source.matchAll(ATTRIBUTE)) {
      const [, kind, rawHash, raw, quoted] = match;
      const text = rawHash ?? raw ?? quoted.replace(/\\(["\\])/g, "$1");
      if (kind === "regex") patterns.push(new RegExp(text));
      else if (kind === "expr") patterns.push(expressionRegex(text));
      else patterns.push(new RegExp("^" + escapeRegex(text) + "$"));
    }
  }
  return patterns;
}

// A step definition with the pattern(s) it binds and whether its body does
// anything. Empty, `let _ = world;`, `assert!(true)` and a lone log line do
// not: a Then bound only to those checks nothing (vauchi/private#1237).
const STEP_FN =
  /((?:#\[(?:given|when|then)\((?:[^()]|\([^()]*\))*\)\]\s*)+)(?:async\s+)?fn\s+\w+\s*\([^)]*\)\s*(?:->[^{]*)?\{/g;
const TRIVIAL_BODY = /^(?:(?:let _ = \w+;\s*)*|assert!\(true\);?|(?:tracing::|log::|println!|eprintln!)[^;]*;?)$/;

function patternOf(kind, rawHash, raw, quoted) {
  const text = rawHash ?? raw ?? quoted.replace(/\\(["\\])/g, "$1");
  if (kind === "regex") return new RegExp(text);
  if (kind === "expr") return expressionRegex(text);
  return new RegExp("^" + escapeRegex(text) + "$");
}

export function stepDefinitionsFrom(stepsDir) {
  const definitions = [];
  for (const file of fs.readdirSync(stepsDir).filter((f) => f.endsWith(".rs")).sort()) {
    const source = fs.readFileSync(path.join(stepsDir, file), "utf8");
    for (const head of source.matchAll(STEP_FN)) {
      let i = head.index + head[0].length;
      let depth = 1;
      while (depth > 0 && i < source.length) {
        if (source[i] === "{") depth += 1;
        else if (source[i] === "}") depth -= 1;
        i += 1;
      }
      const body = source.slice(head.index + head[0].length, i - 1).replace(/\/\/[^\n]*/g, "").replace(/\s+/g, " ").trim();
      const trivial = TRIVIAL_BODY.test(body);
      for (const [, kind, rawHash, raw, quoted] of head[1].matchAll(ATTRIBUTE)) {
        definitions.push({ pattern: patternOf(kind, rawHash, raw, quoted), trivial });
      }
    }
  }
  return definitions;
}

const STEP = /^\s*(Given|When|Then|And|But|\*)\s+(.+?)\s*$/;

// Core's cucumber job runs `--tags "not @wip and not @ui"`.
const EXCLUDED_BY_CORE_RUN = ["@wip", "@ui"];

// Scenario ids of one feature file, each with its full step list (Background
// first; one entry per Examples row for an outline) and every tag it inherits.
function scenariosOf(file, text) {
  const out = [];
  const seen = new Map();
  let background = [];
  let inBackground = false;
  let inDocString = false;
  let current = null;
  let phase = null;
  let pendingTags = [];
  let featureTags = [];
  let ruleTags = [];
  const flush = () => {
    if (!current) return;
    const count = (seen.get(current.name) ?? 0) + 1;
    seen.set(current.name, count);
    const id = `${file} :: ${current.name}${count > 1 ? ` (${count})` : ""}`;
    const tags = [...featureTags, ...ruleTags, ...current.tags];
    const rows = current.tables.flatMap((table) => table.rows.slice(1).map((row) => [table.rows[0], row, table.tags]));
    if (rows.length === 0) out.push({ id, tags, steps: [...background, ...current.steps], thens: current.thens });
    rows.forEach(([header, row, tableTags], index) =>
      out.push({
        id: `${id} [row ${index + 1}]`,
        tags: [...tags, ...tableTags],
        steps: [...background, ...current.steps].map((step) =>
          step.replace(/<([^>]+)>/g, (whole, key) => (header.includes(key) ? row[header.indexOf(key)] : whole)),
        ),
        thens: current.thens.map((step) =>
          step.replace(/<([^>]+)>/g, (whole, key) => (header.includes(key) ? row[header.indexOf(key)] : whole)),
        ),
      }),
    );
    current = null;
  };
  for (const line of text.split("\n")) {
    const trimmed = line.trim();
    if (trimmed.startsWith('"""') || trimmed.startsWith("```")) {
      inDocString = !inDocString;
      continue;
    }
    if (inDocString || trimmed.startsWith("#")) continue;
    if (trimmed.startsWith("@")) {
      pendingTags.push(...trimmed.split(/\s+/).filter((tag) => tag.startsWith("@")));
      continue;
    }
    if (/^(Feature|Rule):/.test(trimmed)) {
      flush();
      if (trimmed.startsWith("Rule:")) {
        background = [];
        ruleTags = pendingTags;
      } else {
        featureTags = pendingTags;
        ruleTags = [];
      }
      pendingTags = [];
      inBackground = false;
      continue;
    }
    if (/^Background:/.test(trimmed)) {
      flush();
      inBackground = true;
      continue;
    }
    const scenario = /^(?:Scenario(?: Outline| Template)?|Example):\s*(.*)$/.exec(trimmed);
    if (scenario) {
      flush();
      inBackground = false;
      current = { name: scenario[1].trim(), tags: pendingTags, steps: [], thens: [], tables: [], inExamples: false };
      pendingTags = [];
      phase = null;
      continue;
    }
    if (/^(Examples|Scenarios):/.test(trimmed)) {
      if (current) {
        current.tables.push({ tags: pendingTags, rows: [] });
        current.inExamples = true;
      }
      pendingTags = [];
      continue;
    }
    if (trimmed.startsWith("|")) {
      if (current?.inExamples) {
        current.tables.at(-1).rows.push(trimmed.split("|").slice(1, -1).map((cell) => cell.trim()));
      }
      continue;
    }
    const step = STEP.exec(line);
    if (!step) continue;
    if (step[1] !== "And" && step[1] !== "But" && step[1] !== "*") phase = step[1];
    if (inBackground) background.push(step[2]);
    else if (current) {
      current.steps.push(step[2]);
      if (phase === "Then") current.thens.push(step[2]);
    }
  }
  flush();
  return out;
}

export function wiredScenarios(features, patterns) {
  const bound = (step) => patterns.some((pattern) => pattern.test(step));
  const wired = new Set();
  for (const [file, text] of Object.entries(features)) {
    for (const { id, steps } of scenariosOf(file, text)) {
      if (steps.length > 0 && steps.every(bound)) wired.add(id);
    }
  }
  return wired;
}

export function uncheckedScenarios(features, definitions) {
  const bound = (step) => definitions.some((d) => d.pattern.test(step));
  const checks = (step) => definitions.some((d) => !d.trivial && d.pattern.test(step));
  const unchecked = [];
  for (const [file, text] of Object.entries(features)) {
    for (const { id, tags, steps, thens } of scenariosOf(file, text)) {
      if (tags.some((tag) => EXCLUDED_BY_CORE_RUN.includes(tag))) continue;
      if (steps.length > 0 && steps.every(bound) && !thens.some(checks)) unchecked.push(id);
    }
  }
  return unchecked.sort();
}

export function newUnchecked(features, definitions, baseline) {
  return uncheckedScenarios(features, definitions).filter((id) => !baseline.has(id));
}

export function lostScenarios(baseFeatures, headFeatures, patterns) {
  const head = wiredScenarios(headFeatures, patterns);
  return [...wiredScenarios(baseFeatures, patterns)].filter((id) => !head.has(id)).sort();
}

function featuresAt(ref) {
  const names = execFileSync("git", ["ls-tree", "--name-only", ref], { encoding: "utf8" })
    .split("\n")
    .filter((name) => name.endsWith(".feature"));
  return Object.fromEntries(
    names.map((name) => [name, execFileSync("git", ["show", `${ref}:${name}`], { encoding: "utf8" })]),
  );
}

function featuresInWorkingTree() {
  return Object.fromEntries(
    fs.readdirSync(".").filter((name) => name.endsWith(".feature")).map((name) => [name, fs.readFileSync(name, "utf8")]),
  );
}

function main(argv) {
  const option = (name) => {
    const index = argv.indexOf(name);
    return index === -1 ? undefined : argv[index + 1];
  };
  const steps = option("--steps");
  const base = option("--base") ?? "origin/main";
  if (!steps || !fs.existsSync(steps)) {
    console.error("Usage: check-wired-scenarios.mjs --steps <core>/vauchi-core/tests/steps [--base <ref>]");
    return 2;
  }
  const patterns = patternsFrom(steps);
  const baseFeatures = featuresAt(base);
  const headFeatures = featuresInWorkingTree();
  const lost = lostScenarios(baseFeatures, headFeatures, patterns);
  console.log(
    `Wired scenarios: ${wiredScenarios(baseFeatures, patterns).size} at ${base}, ` +
      `${wiredScenarios(headFeatures, patterns).size} here (${patterns.length} core step patterns).`,
  );
  let status = 0;
  const baselineFile = option("--unchecked-baseline");
  if (baselineFile) {
    const baseline = new Set(
      fs.readFileSync(baselineFile, "utf8").split("\n").map((l) => l.trim()).filter((l) => l && !l.startsWith("#")),
    );
    const definitions = stepDefinitionsFrom(steps);
    const unchecked = uncheckedScenarios(headFeatures, definitions);
    const added = unchecked.filter((id) => !baseline.has(id));
    const gone = [...baseline].filter((id) => !unchecked.includes(id));
    console.log(`Wired but checked by no Then step that does something: ${unchecked.length} (baseline ${baseline.size}).`);
    if (gone.length > 0) {
      console.log("\nNow checked or gone, remove from the baseline:");
      for (const id of gone) console.log(`  - ${id}`);
    }
    if (added.length > 0) {
      console.log("\nGATE failed: these wired scenarios check nothing (every Then binds to an empty or log-only body):");
      for (const id of added) console.log(`  - ${id}`);
      console.log("\nFix: give one Then step a body that asserts the outcome (core step definition), or tag the scenario @planned.");
      status = 1;
    }
  }
  if (lost.length === 0) return status;
  console.log("\nGATE failed: these scenarios run in core today and would stop binding:");
  for (const id of lost) console.log(`  - ${id}`);
  console.log(
    "\nFix: keep the wired step text, or land the core step change first (core MR\n" +
      "accepting the new wording), then this MR. Deleting one: lower core's\n" +
      "cucumber floor in the same release.",
  );
  return 1;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  process.exit(main(process.argv.slice(2)));
}
