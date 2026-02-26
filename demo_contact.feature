# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@demo @onboarding @ux
Feature: Demo Contact
  As a new Vauchi user with no contacts
  I want to see how updates work through a demo contact
  So that I understand the value proposition before finding a real user

  Background:
    Given the Vauchi app is installed
    And the user has completed onboarding
    And the user has created their identity

  # ============================================================
  # Demo Contact Appearance
  # ============================================================

  @demo-appear @implemented
  Scenario: Demo contact appears for users with no contacts
    Given I have no real contacts
    When I complete the onboarding process
    Then a demo contact named "Vauchi Tips" should appear
    And the contact should be marked as "Demo"
    And the contact card should contain helpful tips

  @demo-appear @implemented
  Scenario: Demo contact does not appear if user has contacts
    Given I already have real contacts
    When I complete the onboarding process
    Then no demo contact should be created

  @demo-appear @implemented
  Scenario: Demo contact is visually distinct
    Given the demo contact exists
    When I view my contacts list
    Then the demo contact should have a special indicator
    And it should be clear this is not a real person

  # ============================================================
  # Demo Updates
  # ============================================================

  @demo-updates @implemented
  Scenario: Demo contact sends periodic updates
    Given the demo contact exists
    And I have been using the app for some time
    When a demo update is scheduled
    Then I should receive an update notification
    And the update should contain a new tip or feature explanation

  @demo-updates @implemented
  Scenario: Demo updates demonstrate the update flow
    Given the demo contact exists
    When I receive a demo update
    Then I should see the update notification
    And the contact card should show updated content
    And this demonstrates how real updates work

  @demo-updates @implemented
  Scenario: Demo update shows before/after diff
    Given the demo contact exists
    And I view a demo update for the first time
    Then I should see a before/after comparison
    And this should trigger the first-update-received aha moment

  # ============================================================
  # Demo Contact Content
  # ============================================================

  @demo-content @implemented
  Scenario: Demo contact has rotating tips
    Given the demo contact exists
    Then the contact card should contain helpful content:
      | tip_category | description |
      | getting_started | How to share your card |
      | privacy | How your data is protected |
      | updates | How updates work |
      | recovery | What happens if you lose your phone |

  @demo-content @implemented
  Scenario: Demo tips change over time
    Given the demo contact exists
    When I check the demo contact later
    Then the tips may have rotated to new content
    And the update appears as a normal card update

  # ============================================================
  # Demo Contact Dismissal
  # ============================================================

  @demo-dismiss @implemented
  Scenario: Demo contact can be manually dismissed
    Given the demo contact exists
    When I choose to dismiss the demo contact
    Then the demo contact should be removed
    And I can restore it from Settings if needed

  @demo-dismiss @implemented
  Scenario: Demo contact auto-removes after first real exchange
    Given the demo contact exists
    When I complete an exchange with a real contact
    Then the demo contact should be automatically removed
    And a message should explain the demo has ended

  @demo-dismiss @implemented
  Scenario: Demo contact can be restored from settings
    Given the demo contact was dismissed
    When I go to Settings > Help > Show Demo Contact
    Then the demo contact should reappear
    And updates resume from current content

  # ============================================================
  # Demo Contact Privacy
  # ============================================================

  @demo-privacy @planned
  Scenario: Demo contact is local only
    Given the demo contact exists
    Then no data is sent to any server for the demo
    And the demo contact is stored locally
    And demo updates are generated locally

  @demo-privacy @planned
  Scenario: Demo contact does not count as real contact
    Given the demo contact exists
    When I check my contact count
    Then the demo contact should not be counted
    And sharing stats should exclude the demo

  # ============================================================
  # Persistence
  # ============================================================

  @demo-persistence @implemented
  Scenario: Demo contact state persists across app restarts
    Given the demo contact exists
    When I force quit and relaunch the app
    Then the demo contact should still be present
    And update history should be preserved

  @demo-persistence @implemented
  Scenario: Dismissal persists across app restarts
    Given I have dismissed the demo contact
    When I force quit and relaunch the app
    Then the demo contact should remain dismissed

  # ============================================================
  # Edge Cases
  # ============================================================

  @demo-edge @planned
  Scenario: Demo contact handles no network gracefully
    Given the demo contact exists
    And the device is offline
    When a demo update is scheduled
    Then the update should still work
    And no network error should be shown

  @demo-edge @planned
  Scenario: Demo contact does not interfere with real contacts
    Given I have the demo contact
    And I add a real contact
    Then both should appear in the contacts list
    And they should function independently
