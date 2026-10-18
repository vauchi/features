// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Seeded-violation tests for check-wired-scenarios.mjs (vauchi/private#700).
// Run: node --test scripts/check-wired-scenarios.test.mjs

import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { lostScenarios, patternsFrom, wiredScenarios } from "./check-wired-scenarios.mjs";

const STEPS = `
#[given("I have a backup file")]
fn backup() {}
#[when("the first byte is not a known version (0x02 identity, 0x03 full)")]
fn unknown_version() {}
#[then(
    "restoration should fail with RestoreFailed"
)]
fn restore_fails() {}
#[given(expr = "{string} has a/an {word} field {string} with value {string}")]
fn field() {}
#[then(expr = "I should see {int} contact(s)")]
fn count() {}
#[then(regex = r"^(.+?)'s visibility should fall back to defaults$")]
fn fallback() {}
`;

const BACKUP = (when) => `Feature: Backup Format Versioning

  Scenario: Unknown version byte is rejected
    Given I have a backup file
    When ${when}
    Then restoration should fail with RestoreFailed
`;

const OTHER = `Feature: Other

  Background:
    Given "Alice" has an email field "Work" with value "a@b.c"

  Scenario: Counts
    Then I should see 1 contact

  Scenario Outline: Plural
    Then I should see <n> contacts

    Examples:
      | n |
      | 2 |
      | 3 |

  Scenario: Regex
    Then Bob's visibility should fall back to defaults

  Scenario: Unwired
    Then something core never binds
`;

function patterns() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "steps-"));
  fs.writeFileSync(path.join(dir, "backup.rs"), STEPS);
  return patternsFrom(dir);
}

test("a wired scenario whose step is reworded is reported as lost", () => {
  const base = { "backup.feature": BACKUP("the first byte is not a known version (0x02 identity, 0x03 full)") };
  const head = { "backup.feature": BACKUP("the first byte is not a known version (0x02 identity, 0x03 legacy full, 0x06 password snapshot)") };
  assert.deepEqual(lostScenarios(base, head, patterns()), [
    "backup.feature :: Unknown version byte is rejected",
  ]);
});

test("an unchanged suite loses nothing", () => {
  const base = { "backup.feature": BACKUP("the first byte is not a known version (0x02 identity, 0x03 full)"), "other.feature": OTHER };
  assert.deepEqual(lostScenarios(base, { ...base }, patterns()), []);
});

test("a deleted wired scenario is reported, since core's floor counts it", () => {
  const base = { "backup.feature": BACKUP("the first byte is not a known version (0x02 identity, 0x03 full)") };
  assert.deepEqual(lostScenarios(base, {}, patterns()), [
    "backup.feature :: Unknown version byte is rejected",
  ]);
});

test("literal, expression, alternation, optional text, outlines and regex steps bind", () => {
  const wired = wiredScenarios({ "other.feature": OTHER }, patterns());
  assert.deepEqual([...wired].sort(), [
    "other.feature :: Counts",
    "other.feature :: Plural [row 1]",
    "other.feature :: Plural [row 2]",
    "other.feature :: Regex",
  ]);
});

test("a plain literal step is an exact match, not an expression", () => {
  const head = { "backup.feature": BACKUP("the first byte is not a known version") };
  assert.deepEqual([...wiredScenarios(head, patterns())], []);
});
