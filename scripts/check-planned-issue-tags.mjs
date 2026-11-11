// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// A planned scenario is public only while someone works on it
// (vauchi/private#1237): every scenario tagged @planned, or @future without
// @implemented, carries @issue-<N>, on itself or on its Feature. This job
// checks the tag's form only; whether issue N is open is checked by a
// scheduled job in the private repository, so this public pipeline never
// reads the private tracker.
//
//   node scripts/check-planned-issue-tags.mjs [dir]
//
// Exit 0 clean, 1 an untagged planned scenario, 2 no feature files found.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const SCENARIO = /^\s*Scenario(?: Outline)?:\s*(.+?)\s*$/;
const FEATURE = /^\s*Feature:/;
const ISSUE_TAG = /(^|\s)@issue-[1-9][0-9]*(?=\s|$)/;

const hasTag = (tags, tag) => tags.split(/\s+/).includes(tag);

export function untaggedPlanned(file, text) {
  const found = [];
  let pending = "";
  let featureTags = "";
  for (const line of text.split("\n")) {
    const trimmed = line.trim();
    if (trimmed.startsWith("@")) {
      pending += ` ${trimmed}`;
      continue;
    }
    if (FEATURE.test(line)) {
      featureTags = pending;
      pending = "";
      continue;
    }
    const scenario = line.match(SCENARIO);
    if (scenario) {
      const tags = `${featureTags} ${pending}`;
      pending = "";
      const planned = hasTag(tags, "@planned") || hasTag(tags, "@future");
      if (planned && !hasTag(tags, "@implemented") && !ISSUE_TAG.test(tags)) {
        found.push({ file, scenario: scenario[1] });
      }
      continue;
    }
    if (trimmed && !trimmed.startsWith("#")) pending = "";
  }
  return found;
}

function main() {
  const dir = process.argv[2] ?? ".";
  const files = fs.readdirSync(dir).filter((name) => name.endsWith(".feature")).sort();
  if (files.length === 0) {
    console.error(`No .feature files in ${dir}: the check cannot decide.`);
    process.exit(2);
  }
  const found = files.flatMap((name) => untaggedPlanned(name, fs.readFileSync(path.join(dir, name), "utf8")));
  if (found.length > 0) {
    console.error(`${found.length} planned scenario(s) name no issue:`);
    for (const { file, scenario } of found) console.error(`  ${file} :: ${scenario}`);
    console.error(
      "\nFix: tag each with @issue-<N> of the open issue its work runs under, or move it to its " +
        "problem record until work starts (vauchi/private#1237).",
    );
    process.exit(1);
  }
  console.log(`OK: ${files.length} feature files, every planned scenario names its issue.`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();
