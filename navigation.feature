# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@navigation @ux
Feature: 5-Tab Navigation Architecture
  As a Vauchi user
  I want a simple, consistent navigation with 5 tabs
  So that I can quickly access my card, contacts, exchange, groups, and more

  Background:
    Given I have an existing identity as "Alice"
    And I have contacts "Bob", "Carol", and "Dave"
  # Navigation Bar

  @navigation @implemented
  Scenario: Navigation shows 5 tabs
    When I view the main screen
    Then I should see a navigation bar with 5 tabs:
      | screen   | position |
      | MyInfo   |        1 |
      | Contacts |        2 |
      | Exchange |        3 |
      | Groups   |        4 |
      | More     |        5 |

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

  @navigation @implemented
  Scenario: Switching screens preserves state
    Given I am on the "Contacts" screen viewing Bob's details
    When I switch to the "MyInfo" screen
    And I switch back to the "Contacts" screen
    Then I should still see Bob's details
  # MyInfo — Preview As

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

  @navigation @visibility @planned
  Scenario: Add individual contact visibility to a field
    Given I am on the "MyInfo" screen
    And I have a "Work" email field
    When I tap the visibility chips on "Work" email
    And I add contact "Dave"
    Then "Dave" should appear as a visibility chip on that field
    And Dave should see my work email

  @navigation @visibility @planned
  Scenario: Remove visibility from a field
    Given my "Personal" phone is visible to "Bob"
    When I remove "Bob" from the visibility chips on "Personal" phone
    Then Bob should no longer see my personal phone
  # MyInfo — Per-field Private Notes

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
    And Bob has shared a Signal handle with me
    When I tap the open action on Bob's Signal handle
    Then Signal should open to Bob's profile

  @navigation @contact-actions @implemented
  Scenario: Tap address to open in maps
    Given I am viewing Carol's contact details
    And Carol has shared an address with me
    When I tap the maps action on Carol's address
    Then the maps app should open with Carol's address

  @navigation @contact-actions @planned
  Scenario: Tap birthday to add to calendar
    Given I am viewing Bob's contact details
    And Bob has shared a birthday with me
    When I tap the calendar action on Bob's birthday
    Then the calendar app should open to add the event

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

  @navigation @trust @implemented
  Scenario: Validate a contact's field
    Given I am viewing Bob's contact details
    And Bob has shared a phone number with me
    When I tap the validation indicator on Bob's phone number
    Then the field should be marked as personally validated
    And the validation confidence should increase
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
  # Contacts — "What do they see?"

  @navigation @what-they-see @implemented
  Scenario: Navigate from contact to preview-as
    Given I am viewing Bob's contact details on the "Contacts" screen
    When I tap "What do they see?"
    Then I should navigate to the "MyInfo" screen
    And I should see my card in preview-as mode for Bob
    And the banner should say "Viewing as Bob"
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
  Scenario: Groups tab shows group list
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
  # More Menu

  @navigation @more @implemented
  Scenario: More tab shows sub-screens
    When I switch to the "More" screen
    Then I should see a list of sub-screens:
      | item     |
      | Sync     |
      | Devices  |
      | Settings |
      | Backup   |
      | Privacy  |
      | Help     |

  @navigation @more @implemented
  Scenario: Navigate to Settings via More
    Given I am on the "More" screen
    When I tap "Settings"
    Then I should see the Settings screen
    And I should be able to navigate back to "More"

  @navigation @more @implemented
  Scenario: Navigate to Help via More
    Given I am on the "More" screen
    When I tap "Help"
    Then I should see the Help screen
    And I should be able to navigate back to "More"
  # Platform Edge Cases (dissolved from platform_edge_cases.feature 2026-03-17)

  @platform-edge-case @desktop @multi-window @planned
  Scenario: Handle multiple windows on desktop
    Given the app is open in one window
    When I try to open another instance
    Then the existing window should be focused
    # Or windows should sync state in real-time
    And data conflicts should be prevented

  @platform-edge-case @desktop @url-scheme @planned
  Scenario: Handle vauchi:// URL scheme on desktop
    Given I click a vauchi:// link
    When the desktop app is not running
    Then the app should launch
    And the link should be processed
    And the appropriate action should occur

  @platform-edge-case @desktop @tray @planned
  Scenario: System tray behavior on desktop
    Given the app is minimized to system tray
    When a contact update arrives
    Then the update should be applied silently in the background
    # No system notification — Principle 4: "no notifications designed to pull you back"
    And clicking the tray icon should restore the app
    And the app should not consume CPU while minimized

  @platform-edge-case @tui @terminal @planned
  Scenario: Handle terminal resize
    Given I am using the TUI app
    When I resize my terminal window
    Then the UI should reflow correctly
    And no content should be cut off
    And the app should remain usable

  @platform-edge-case @tui @encoding @planned
  Scenario: Handle non-UTF8 terminal
    Given my terminal has limited character support
    When I view contacts with unicode names
    Then the app should fallback gracefully
    And names should still be readable
    And the app should not crash

  @platform-edge-case @ios @permissions @planned
  Scenario: Handle camera permission revoked on iOS
    Given I previously granted camera permission on iOS
    When I revoke camera permission in Settings
    And I try to scan a QR code
    Then I should see a clear message about missing permission
    And there should be a button to open Settings
    And the app should not crash

  @platform-edge-case @ios @extension @planned
  Scenario: Share extension works on iOS
    Given I am in another app with contact info
    When I use the iOS share sheet
    Then Vauchi should appear as an option
    And I can share data to Vauchi
    And sharing should work even if main app not running

  @platform-edge-case @android @permissions @planned
  Scenario: Handle runtime permission denied on Android
    Given I denied camera permission on Android
    When I try to scan a QR code
    Then I should see an explanation of why permission is needed
    And there should be an option to request permission again
    And I should not be asked repeatedly if I chose "Don't ask again"

  @platform-edge-case @cross-platform @locale @planned
  Scenario: Handle locale change
    Given I change my device language
    When I open the app
    Then the app should use the new language
    And formatting should follow new locale
    And no restart should be required
