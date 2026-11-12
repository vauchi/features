# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@performance
Feature: Performance Requirements
  As a Vauchi user
  I want the app to be fast and efficient
  So that it doesn't impact my device negatively

  # ============================================================
  # Sync Performance
  # ============================================================

  @sync @implemented
  Scenario: Sync large batch of updates
    Given I was offline for 7 days
    And I have 100 pending updates to receive
    When I come online
    Then all updates should sync within 60 seconds
    And the UI should remain responsive during sync
    And progress should be indicated

  @storage @implemented
  Scenario: Reasonable storage footprint
    Given I have 100 contacts
    Then local storage should be under 50MB
    And deleting data should shrink the database file

  @resources @implemented
  Scenario: Efficient cryptographic operations
    Given I am performing crypto operations
    Then encryption should complete within 100ms
    And decryption should complete within 100ms
    And key operations should not block UI

  # ============================================================
  # Stress Testing
  # ============================================================

  @stress @implemented
  Scenario: Handle many simultaneous operations
    Given I am receiving updates from 10 contacts at once
    When all updates arrive simultaneously
    Then all updates should be processed
    And the UI should remain responsive
    And no updates should be lost

  @contacts @pagination @implemented
  Scenario: Batch contact loading with pagination
    Given I have 500 contacts
    When I load contacts in pages of 50
    Then each page should load within 100ms
    And total memory usage should stay under 100MB
    And I should be able to navigate to any page

  @sync @coalesce @implemented
  Scenario: Coalesce rapid edits before sync
    Given I edit my contact card 20 times in 10 seconds
    When the debounce timer expires
    Then all edits should coalesce into a single sync payload
    And only 1 sync message should be sent
    And the final state should be correct

  @sync @batch-encrypt @implemented
  Scenario: Batch encryption for multi-contact sync
    Given I have 50 pending updates for different contacts
    When batch encryption runs
    Then all 50 updates should be encrypted within 10 seconds
    And each update should use the correct per-contact key
    And the pipeline should not block the UI

  # Platform Edge Cases (dissolved from platform_edge_cases.feature 2026-03-17)
