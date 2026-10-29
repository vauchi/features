# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @privacy @shred
Feature: Emergency Shred
  As a Vauchi user
  I want multiple levels of identity destruction
  So that I can choose between graceful deletion and emergency wipe
  depending on the threat level

  Background:
    Given I have an existing identity
    And I have contacts and stored data

  # ============================================================
  # Soft Shred (Phase 1) — Scheduled Deletion
  # ============================================================

  @soft @implemented
  Scenario: Soft shred schedules deletion with grace period
    When I initiate a soft shred
    Then identity deletion should be scheduled
    And a 7-day grace period should begin
    And I should receive a shred token
    And my data should remain accessible during the grace period

  @soft @implemented
  Scenario: Cancel soft shred during grace period
    Given I have initiated a soft shred
    And the grace period has not expired
    When I cancel the deletion
    Then the scheduled deletion should be cancelled
    And my identity should continue functioning normally

  @soft @implemented
  Scenario: Soft shred cannot proceed before grace period expires
    Given I have initiated a soft shred
    And the grace period has not expired
    When I try to execute hard shred
    Then the operation should be rejected
    And the app should not offer to delete now until the grace period ends

  # ============================================================
  # Hard Shred (Phase 2) — Irreversible Destruction
  # ============================================================

  @hard @implemented
  Scenario: Hard shred after grace period
    Given I have initiated a soft shred
    And the 7-day grace period has expired
    When I execute hard shred with the shred token
    Then contacts should be notified via network
    And the Shredding Master Key (SMK) should be destroyed
    And the identity file should be securely overwritten with zeros
    And the SQLite database should be deleted
    And WAL and SHM files should be deleted
    And key files should be securely overwritten and removed

  @hard @implemented
  Scenario: Hard shred requires valid shred token
    Given I have initiated a soft shred
    And the grace period has expired
    When I try to execute hard shred with an invalid token
    Then the operation should be rejected

  @hard @implemented
  Scenario: Hard shred attempts network notifications before destruction
    Given I execute a hard shred
    Then relay purge requests should be attempted before key destruction
    And contact deletion notices should be attempted before key destruction
    And notification failures should be recorded in the shred report
    And keys and local data should be destroyed regardless of network outcome

  # ============================================================
  # Panic Shred (Phase 3) — Immediate Emergency Wipe
  # ============================================================

  @panic @implemented
  Scenario: Panic shred destroys this device's data and sends nothing
    When I trigger a panic shred
    Then there should be NO grace period
    And all cryptographic keys on this device should be destroyed immediately
    And all local data on this device should be wiped
    And nothing should be sent to the relay or to my contacts
    And the shred report should show no notifications

  # An emergency wipe concerns one of the identity's devices; telling the
  # contacts or the relay would end the identity on the others too, and a
  # message at the moment of a coerced wipe tells an observer it happened
  # (ADR-033 amendment 2026-10-29, vauchi/private#910).

  # ============================================================
  # Shred Report
  # ============================================================

  @report @implemented
  Scenario: Shred report tracks what was destroyed
    When a shred operation completes
    Then I should receive a shred report listing:
      | Item              | Status    |
      | SMK               | Destroyed |
      | Identity file     | Destroyed |
      | Database          | Destroyed |
      | Key files         | Destroyed |
    And each item should show whether destruction succeeded

  @report @implemented
  Scenario: Shred verification audits completeness
    When a shred operation completes
    Then a verification pass should confirm:
      | Check                              |
      | No identity file remains on disk   |
      | No database file remains on disk   |
      | No key material remains in storage |
      | SMK is no longer accessible        |

  # ============================================================
  # Secure Overwrite
  # ============================================================

  @secure @implemented
  Scenario: Files are overwritten with zeros before deletion
    When a shred destroys the identity file
    Then the file should be overwritten with zero bytes
    And only then should the file be deleted from the filesystem
    And this prevents recovery via disk forensics

  @secure @implemented
  Scenario: Database WAL and SHM files are cleaned up
    Given the SQLite database has WAL and SHM journal files
    When a shred destroys the database
    Then the WAL file should be deleted
    And the SHM file should be deleted
    And the main database file should be deleted

  # ============================================================
  # Edge Cases
  # ============================================================

  @edge @implemented
  Scenario: Shred with no contacts
    Given I have no contacts
    When I trigger a hard shred
    Then local data should be destroyed
    And no contact notifications need to be sent
    And the operation should succeed

  @edge @planned
  Scenario: Shred on device with multiple linked devices
    Given I have 3 linked devices
    When I trigger a panic shred on one device
    Then only the current device's data should be destroyed
    And the other devices should keep working
    And I can revoke the wiped device from one of the other devices
