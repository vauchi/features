// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Seeded-violation tests for check-planned-issue-tags.mjs (vauchi/private#1237).
// Run: node --test scripts/check-planned-issue-tags.test.mjs

import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { untaggedPlanned } from "./check-planned-issue-tags.mjs";

const feature = (body) => `Feature: Example\n\n${body}`;

test("a planned scenario without an issue tag is reported", () => {
  const found = untaggedPlanned("x.feature", feature("  @planned\n  Scenario: Later\n    Given a thing\n"));
  assert.deepEqual(found, [{ file: "x.feature", scenario: "Later" }]);
});

test("a planned scenario with an issue tag passes", () => {
  assert.deepEqual(untaggedPlanned("x.feature", feature("  @planned @issue-1237\n  Scenario: Later\n")), []);
});

test("the issue tag may sit on its own tag line", () => {
  assert.deepEqual(untaggedPlanned("x.feature", feature("  @planned\n  @issue-55\n  Scenario: Later\n")), []);
});

test("a feature-level issue tag covers its scenarios", () => {
  const text = "@issue-55\nFeature: Mesh\n\n  @planned\n  Scenario: Later\n";
  assert.deepEqual(untaggedPlanned("x.feature", text), []);
});

test("a future scenario that is not implemented needs one too", () => {
  const found = untaggedPlanned("x.feature", feature("  @future\n  Scenario: Someday\n"));
  assert.equal(found.length, 1);
});

test("an implemented scenario needs no issue tag, even with @future on it", () => {
  assert.deepEqual(untaggedPlanned("x.feature", feature("  @accent @future @implemented\n  Scenario: Now\n")), []);
});

test("a scenario outline is checked like a scenario", () => {
  const found = untaggedPlanned("x.feature", feature("  @planned\n  Scenario Outline: Many <n>\n"));
  assert.deepEqual(found, [{ file: "x.feature", scenario: "Many <n>" }]);
});

test("a malformed tag like @issue-x does not count", () => {
  assert.equal(untaggedPlanned("x.feature", feature("  @planned @issue-x\n  Scenario: Later\n")).length, 1);
});

test("the command fails on an untagged planned scenario and passes on a clean tree", async () => {
  const { execFileSync } = await import("node:child_process");
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "planned-tags-"));
  const script = path.join(path.dirname(new URL(import.meta.url).pathname), "check-planned-issue-tags.mjs");
  fs.writeFileSync(path.join(dir, "a.feature"), feature("  @implemented\n  Scenario: Now\n"));
  execFileSync("node", [script, dir]);
  fs.writeFileSync(path.join(dir, "b.feature"), feature("  @planned\n  Scenario: Later\n"));
  assert.throws(() => execFileSync("node", [script, dir], { stdio: "pipe" }));
});

test("an empty directory is an error, not a pass", async () => {
  const { execFileSync } = await import("node:child_process");
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "planned-tags-empty-"));
  const script = path.join(path.dirname(new URL(import.meta.url).pathname), "check-planned-issue-tags.mjs");
  assert.throws(() => execFileSync("node", [script, dir], { stdio: "pipe" }));
});
