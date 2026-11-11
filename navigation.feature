# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@navigation @ux @ui
Feature: Navigation Architecture
  As a Vauchi user
  I want one simple, consistent list of destinations
  So that I can reach any part of the app without hunting through a
  second menu

  Background:
    Given I have an existing identity as "Alice"
    And I have contacts "Bob", "Carol", and "Dave"
  # Navigation Bar

  @navigation @implemented
  Scenario: Navigation shows 5 tabs
    When I view the main screen
    Then I should see a navigation bar with 5 tabs:
      | screen   | position |
      | Contacts |        1 |
      | My Card  |        2 |
      | Exchange |        3 |
      | Devices  |        4 |
      | Settings |        5 |
    And every other screen should be reachable from a Settings row

  @navigation @implemented
  Scenario: Dynamic default screen with no contacts
    Given I have 0 contacts
    When I unlock the app
    Then the "MyInfo" screen should be active
    And I should see my contact card fields

  @navigation @implemented
  Scenario: Dynamic default screen with contacts
    Given I have 1 or more contacts
    When I unlock the app
    Then the "Contacts" screen should be active

  @navigation @preview-as @implemented
  Scenario: Preview my card as a specific contact
    Given I am on the "MyInfo" screen
    When I tap "Preview as..."
    And I select contact "Bob"
    Then I should see my card as Bob would see it
    And fields hidden from Bob should show as "Hidden" placeholders
    And I should see a banner "Viewing as Bob"
    And I should see an "Exit Preview" button

  @navigation @preview-as @implemented
  Scenario: Exit preview returns to edit mode
    Given I am previewing my card as "Bob"
    When I tap "Exit Preview"
    Then I should see my full editable card
    And the preview banner should be gone
  # MyInfo — Visibility Management

  @navigation @notes @implemented
  Scenario: View and edit private note on own field
    Given I am on the "MyInfo" screen
    And I have a "Work" email field with a note "Check spam folder weekly"
    When I edit the "Work" email field
    Then I should see the note "Check spam folder weekly" in the edit dialog
    And I can update the note
    And the note should be saved inside my encrypted card data
    And contacts should never see the note
  # Contacts — Actions

  @navigation @contact-actions @implemented
  Scenario: Tap phone number to call
    Given I am viewing Bob's contact details on the "Contacts" screen
    And Bob has shared a phone number with me
    When I tap the call action on Bob's phone number
    Then the phone dialer should open with Bob's number

  @navigation @contact-actions @implemented
  Scenario: Tap email to compose
    Given I am viewing Carol's contact details
    And Carol has shared an email with me
    When I tap the compose action on Carol's email
    Then the email client should open with Carol's address

  @navigation @contact-actions @implemented
  Scenario: Tap social handle to open in app
    Given I am viewing Bob's contact details
    And Bob has shared a Twitter handle with me
    When I tap the open action on Bob's Twitter handle
    Then Bob's Twitter profile should open

  @navigation @contact-actions @implemented
  Scenario: Tap address to open in maps
    Given I am viewing Carol's contact details
    And Carol has shared an address with me
    When I tap the maps action on Carol's address
    Then the maps app should open with Carol's address

  @navigation @contact-actions @implemented
  Scenario: Tap URL to open in browser
    Given I am viewing Dave's contact details
    And Dave has shared a website URL with me
    When I tap the browser action on Dave's URL
    Then the browser should open to Dave's website
  # Contacts — Trust Indicators

  @navigation @trust @implemented
  Scenario: Contact shows trust level badge
    Given I am viewing Bob's contact details
    Then I should see a trust level badge derived from exchange facts
    And the trust level should not be user-editable

  # "Validate a contact's field" was removed: ADR-040 derives a field's
  # confidence from the exchange and fingerprint verification, and core
  # 1664bdc3c (2026-03-27) dropped cross-user field validation.
  # Contacts — Private Notes

  @navigation @notes @implemented
  Scenario: Add private note to a contact
    Given I am viewing Bob's contact details
    When I type "Met at FOSDEM 2026" in the notes field
    Then the note should be saved
    And the note should sync to my other linked devices
    And Bob should not see my note about him

  @navigation @notes @implemented
  Scenario: Add private note to a contact's shared field
    Given I am viewing Bob's contact details
    And Bob has shared a phone number with me
    When I tap the note area on Bob's phone number
    And I type "Call before 5pm"
    Then the note should be saved
    And Bob should not see my note on his field
  # Contacts — "What do they see?": the contact screen's button was removed
  # (core 7cc1888e1, 2026-06-05) because its inline "They see me as" section
  # answers the question; the full preview starts from My Card or a group.
  # Contacts — Proposal Trust

  @navigation @trust @implemented
  Scenario: Toggle proposal trust on a contact
    Given I am viewing Bob's contact details
    When I toggle "Can propose contacts" to on
    Then Bob should be marked as proposal-trusted
    And proposal trust should be independent from recovery trust
  # Exchange — Post-Exchange Flow

  @navigation @exchange @implemented
  Scenario: Exchange is accessible from navigation
    When I switch to the "Exchange" screen
    Then I should see the exchange interface
    And I should be able to share my card or receive a card
  # Groups

  @navigation @groups @implemented
  Scenario: Groups screen shows group list
    When I switch to the "Groups" screen
    Then I should see a list of my visibility groups
    And each group should show its name and member count

  @navigation @groups @implemented
  Scenario: Preview as group member
    Given I am viewing the "Family" group detail
    And "Bob" is a member of "Family"
    When I tap "Preview as Bob"
    Then I should navigate to the "MyInfo" screen in preview-as mode for Bob

  @navigation @groups @implemented
  Scenario: Group detail shows member list
    Given I have a group "Family" with "Bob" and "Carol"
    When I view the "Family" group detail
    Then I should see "Bob" and "Carol" in the member list
    And I should see the group's visible field count
  # The More menu was retired 2026-08-20: it was a second navigation
  # surface reached from the first, and listed itself. Every destination
  # it carried is offered directly by the overlay now, covered by
  # `nav_destination_self_reference_tests` in vauchi-app.
  # Platform Edge Cases (dissolved from platform_edge_cases.feature 2026-03-17)
