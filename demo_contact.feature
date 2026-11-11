# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@demo @onboarding @ux @ui
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

  @demo-content @implemented
  Scenario: Demo contact has rotating tips
    Given the demo contact exists
    Then the contact card should contain helpful content:
      | tip_category    | description                         |
      | getting_started | How to share your card              |
      | privacy         | How your data is protected          |
      | updates         | How updates work                    |
      | recovery        | What happens if you lose your phone |

  @demo-dismiss @implemented
  Scenario: Demo contact can be manually dismissed
    Given the demo contact exists
    When I choose to dismiss the demo contact
    Then the demo contact should be removed
    And I can restore it from Settings if needed

  @demo-dismiss @implemented
  Scenario: Demo contact can be restored from settings
    Given the demo contact was dismissed
    When I go to Settings > Help > Show Demo Contact
    Then the demo contact should reappear
    And updates resume from current content
  # ============================================================
  # Demo Contact Privacy
  # ============================================================

  @demo-privacy @implemented
  Scenario: Demo contact is local only
    Given the demo contact exists
    Then no data is sent to any server for the demo
    And the demo contact is stored locally
    And demo updates are generated locally

  @demo-privacy @implemented
  Scenario: Demo contact does not count as real contact
    Given the demo contact exists
    When I check my contact count
    Then the demo contact should not be counted
    And it should not be listed among my contacts
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

  @demo-edge @implemented
  Scenario: Demo contact handles no network gracefully
    Given the demo contact exists
    And the device is offline
    When a demo update is scheduled
    Then the update should still work
    And no network error should be shown
