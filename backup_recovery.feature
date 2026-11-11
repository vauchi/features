# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@identity @backup @recovery @guardian
Feature: Guardian Key Shard Backup Recovery
  As a Vauchi user
  I want to back up my data with guardian key shards
  So that I can recover my identity and data even if I lose my device,
     without any single guardian being able to decrypt my backup alone

  Background:
    Given the Vauchi application is installed
    And I have an existing identity
  # ============================================================
  # Guardian backup setup
  # ============================================================

  @v4 @guardian @setup @implemented
  Scenario: A guardian backup may need every guardian
    Given I have 3 exchanged contacts
    When I create a v4 guardian backup with threshold 3 of 3 guardians
    Then the backup key should be split into 3 shards
    And recovery should require all 3 guardians

  @v4 @guardian @setup @implemented
  Scenario: Recover with one guardian from each group
    Given I have guardians in groups {Bob}, {Charlie, Dave} and {Eve}
    When I create a v4 guardian backup for those groups
    Then the backup key should be split into 3 shards, one per group
    And Charlie and Dave should each hold the second group's share
    And Bob, Dave and Eve re-sealing their shares should recover the backup

  @v4 @guardian @recovery @implemented
  Scenario: Two guardians of one group count as one
    Given I have a v4 guardian backup for groups {Bob}, {Charlie, Dave} and {Eve}
    When Bob, Charlie and Dave return their shares
    Then the operation should fail with "Guardian backup recovery failed"
    And when Eve also returns her share, the backup should be recovered

  @v4 @guardian @recovery @implemented
  Scenario: A whole group missing blocks recovery
    Given I have a v4 guardian backup for groups {Bob}, {Charlie, Dave} and {Eve}
    When nobody from Eve's group returns a share
    Then the operation should fail with "Guardian backup recovery failed"
    And the backup key should not be reconstructed
