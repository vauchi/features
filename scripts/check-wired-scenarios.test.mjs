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

import { lostScenarios, newUnchecked, patternsFrom, stepDefinitionsFrom, uncheckedScenarios, wiredScenarios } from "./check-wired-scenarios.mjs";

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


// "Wired" counted a scenario as run by core when every step bound, even when
// every Then bound to an empty body (vauchi/private#1237): seven planned
// scenarios passed on `{}`. A scenario is checked only if a Then-phase step
// binds to a body that does something.
const CHECK_STEPS = `
#[given("a contact")]
fn contact(world: &mut World) { world.add_contact(); }
#[then("nothing is checked")]
fn noop(_world: &mut World) {}
#[then("a log line is all")]
fn log_only(_world: &mut World) { tracing::info!("checked"); }
#[then("the contact is saved")]
fn saved(world: &mut World) { assert_eq!(world.count(), 1); }
`;
const CHECK_FEATURE = `Feature: Check

  Scenario: Vacuous
    Given a contact
    Then nothing is checked
    And a log line is all

  Scenario: Real
    Given a contact
    Then nothing is checked
    And the contact is saved

  Scenario: Unwired
    Given a contact
    Then core binds no such step
`;

function definitions() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "steps-check-"));
  fs.writeFileSync(path.join(dir, "check.rs"), CHECK_STEPS);
  return stepDefinitionsFrom(dir);
}

test("a wired scenario whose Then steps all have empty or log-only bodies is unchecked", () => {
  assert.deepEqual(uncheckedScenarios({ "check.feature": CHECK_FEATURE }, definitions()), ["check.feature :: Vacuous"]);
});

test("one asserting Then makes a scenario checked; an unwired one is not counted at all", () => {
  const unchecked = uncheckedScenarios({ "check.feature": CHECK_FEATURE }, definitions());
  assert.equal(unchecked.includes("check.feature :: Real"), false);
  assert.equal(unchecked.includes("check.feature :: Unwired"), false);
});

test("the gate reports only unchecked scenarios the baseline does not list", () => {
  const features = { "check.feature": CHECK_FEATURE };
  assert.deepEqual(newUnchecked(features, definitions(), new Set(["check.feature :: Vacuous"])), []);
  assert.deepEqual(newUnchecked(features, definitions(), new Set()), ["check.feature :: Vacuous"]);
});
