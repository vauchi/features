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

const STEP = /^\s*(?:Given|When|Then|And|But|\*)\s+(.+?)\s*$/;

// Scenario ids of one feature file, each with its full step list (Background
// first; one entry per Examples row for an outline).
function scenariosOf(file, text) {
  const out = [];
  const seen = new Map();
  let background = [];
  let inBackground = false;
  let inDocString = false;
  let current = null;
  const flush = () => {
    if (!current) return;
    const count = (seen.get(current.name) ?? 0) + 1;
    seen.set(current.name, count);
    const id = `${file} :: ${current.name}${count > 1 ? ` (${count})` : ""}`;
    const rows = current.tables.flatMap((table) => table.slice(1).map((row) => [table[0], row]));
    if (rows.length === 0) out.push({ id, steps: [...background, ...current.steps] });
    rows.forEach(([header, row], index) =>
      out.push({
        id: `${id} [row ${index + 1}]`,
        steps: [...background, ...current.steps].map((step) =>
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
    if (/^(Feature|Rule):/.test(trimmed)) {
      flush();
      if (trimmed.startsWith("Rule:")) background = [];
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
      current = { name: scenario[1].trim(), steps: [], tables: [], inExamples: false };
      continue;
    }
    if (/^(Examples|Scenarios):/.test(trimmed)) {
      if (current) {
        current.tables.push([]);
        current.inExamples = true;
      }
      continue;
    }
    if (trimmed.startsWith("|")) {
      if (current?.inExamples) {
        current.tables.at(-1).push(trimmed.split("|").slice(1, -1).map((cell) => cell.trim()));
      }
      continue;
    }
    const step = STEP.exec(line);
    if (!step) continue;
    if (inBackground) background.push(step[1]);
    else if (current) current.steps.push(step[1]);
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
  if (lost.length === 0) return 0;
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
