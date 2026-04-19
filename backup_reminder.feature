# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@identity @backup @backup-reminder
Feature: Backup Reminder
  As a Vauchi user
  I want periodic reminders to back up my identity
  So that I don't lose my data if my device is lost or broken

  Background:
    Given the Vauchi application is installed

  # ============================================================
  # Weekly frequency (default)
  # ============================================================

  @implemented
  Scenario: First reminder fires 7 days after identity creation
    Given I created my identity 8 days ago
    And I have never backed up
    And my reminder frequency is "Weekly"
    When I open the app
    Then I should see a backup reminder toast
    And the toast message should mention backing up to protect my identity
    And the toast should expose a "backup_now" action

  @implemented
  Scenario: No reminder before the weekly threshold
    Given I created my identity 5 days ago
    And I have never backed up
    And my reminder frequency is "Weekly"
    When I open the app
    Then I should not see a backup reminder toast

  # ============================================================
  # Monthly frequency
  # ============================================================

  @implemented
  Scenario: Monthly frequency fires at 30 days
    Given I have not backed up for 31 days
    And my reminder frequency is "Monthly"
    When I open the app
    Then I should see a backup reminder toast

  @implemented
  Scenario: Monthly frequency suppresses reminder at 7 days
    Given I created my identity 8 days ago
    And I have never backed up
    And my reminder frequency is "Monthly"
    When I open the app
    Then I should not see a backup reminder toast

  # ============================================================
  # State transitions
  # ============================================================

  @implemented
  Scenario: Successful backup resets the reminder timer
    Given I have a pending backup reminder
    When I export a backup successfully
    Then my last backup timestamp should be updated to now
    And my reminder count should reset to zero
    And I should not see a backup reminder toast on next launch

  @implemented
  Scenario: Showing a reminder increments the reminder count
    Given my reminder count is 0
    When a backup reminder is drained
    Then my reminder count should become 1

  # ============================================================
  # User control
  # ============================================================

  @implemented
  Scenario: User disables backup reminders via frequency "Never"
    Given my reminder frequency is "Never"
    And I have not backed up for 90 days
    When I open the app
    Then I should not see a backup reminder toast

  @implemented
  Scenario: Settings exposes a cycling frequency control
    Given I am viewing the Settings screen
    Then the "Backup & Recovery" group should contain a "backup_reminders" item
    And the item value should cycle Weekly -> Monthly -> Never -> Weekly
