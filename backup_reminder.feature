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
    And I have a linked device
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
    And I have a linked device
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
  # Loss prevention: a user with no safeguard (vauchi/private#796)
  # ============================================================
  # Without a linked device, guardians or a recent backup, a lost phone
  # loses the contact list. Such a user is told how to avoid that in
  # place of the backup reminder; any one safeguard is enough.

  @planned @issue-796
  Scenario: A user with no safeguard is told how to avoid losing their contacts
    Given I created my identity 8 days ago
    And I have never backed up
    And I have no linked device
    And I have designated no guardians
    And my reminder frequency is "Weekly"
    When I open the app
    Then I should see a safeguard prompt instead of a backup reminder toast
    And the prompt should suggest linking a device, choosing guardians or backing up
    And the toast should expose a "protect_now" action that opens Settings

  @planned @issue-796
  Scenario Outline: One safeguard is enough to remove the safeguard prompt
    Given I created my identity 40 days ago
    And my reminder frequency is "Weekly"
    And <safeguard>
    When I open the app
    Then I should not see a safeguard prompt

    Examples:
      | safeguard                     |
      | I have a linked device        |
      | I have designated a guardian  |
      | I backed up 10 days ago       |

  @planned @issue-796
  Scenario: A backup older than 30 days no longer counts as a safeguard
    Given I backed up 31 days ago
    And I have no linked device
    And I have designated no guardians
    And my reminder frequency is "Weekly"
    When I open the app
    Then I should see a safeguard prompt instead of a backup reminder toast

  @planned @issue-796
  Scenario: Reminders set to "Never" also silence the safeguard prompt
    Given I created my identity 40 days ago
    And I have never backed up
    And I have no linked device
    And I have designated no guardians
    And my reminder frequency is "Never"
    When I open the app
    Then I should not see a safeguard prompt

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
