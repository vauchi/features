# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@navigation @ux
Feature: 5-Screen Navigation Architecture
  As a Vauchi user
  I want a simple, consistent navigation with 5 screens
  So that I can quickly access exchange, my info, contacts, settings, and help

  Background:
    Given I have an existing identity as "Alice"
    And I have contacts "Bob", "Carol", and "Dave"

  # Navigation Bar

  @navigation @planned
  Scenario: Navigation shows 5 screens
    When I view the main screen
    Then I should see a navigation bar with 5 screens:
      | screen    | position |
      | Exchange  | 1        |
      | MyInfo    | 2        |
      | Contacts  | 3        |
      | Settings  | 4        |
      | Help      | 5        |

  @navigation @planned
  Scenario: Dynamic default screen with no contacts
    Given I have 0 contacts
    When I unlock the app
    Then the "MyInfo" screen should be active
    And I should see my contact card fields

  @navigation @planned
  Scenario: Dynamic default screen with contacts
    Given I have 1 or more contacts
    When I unlock the app
    Then the "Contacts" screen should be active

  @navigation @planned
  Scenario: Switching screens preserves state
    Given I am on the "Contacts" screen viewing Bob's details
    When I switch to the "MyInfo" screen
    And I switch back to the "Contacts" screen
    Then I should still see Bob's details

  # MyInfo — Preview As

  @navigation @preview-as @planned
  Scenario: Preview my card as a specific contact
    Given I am on the "MyInfo" screen
    When I tap "Preview as..."
    And I select contact "Bob"
    Then I should see my card as Bob would see it
    And fields hidden from Bob should not be visible
    And I should see a banner "Viewing as Bob"
    And I should see an "Exit Preview" button

  @navigation @preview-as @planned
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

  # Contacts — Actions

  @navigation @contact-actions @planned
  Scenario: Tap phone number to call
    Given I am viewing Bob's contact details on the "Contacts" screen
    And Bob has shared a phone number with me
    When I tap the call action on Bob's phone number
    Then the phone dialer should open with Bob's number

  @navigation @contact-actions @planned
  Scenario: Tap email to compose
    Given I am viewing Carol's contact details
    And Carol has shared an email with me
    When I tap the compose action on Carol's email
    Then the email client should open with Carol's address

  @navigation @contact-actions @planned
  Scenario: Tap social handle to open in app
    Given I am viewing Bob's contact details
    And Bob has shared a Signal handle with me
    When I tap the open action on Bob's Signal handle
    Then Signal should open to Bob's profile

  @navigation @contact-actions @planned
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

  @navigation @contact-actions @planned
  Scenario: Tap URL to open in browser
    Given I am viewing Dave's contact details
    And Dave has shared a website URL with me
    When I tap the browser action on Dave's URL
    Then the browser should open to Dave's website

  # Contacts — Trust

  @navigation @trust @planned
  Scenario: Upvote trust on a contact field
    Given I am viewing Bob's contact details
    And Bob has shared a phone number with me
    When I tap the trust indicator on Bob's phone number
    Then the field should be marked as personally verified
    And the trust indicator should show as active

  # Contacts — Private Notes

  @navigation @notes @planned
  Scenario: Add private note to a contact
    Given I am viewing Bob's contact details
    When I type "Met at FOSDEM 2026" in the notes field
    Then the note should be saved
    And the note should sync to my other linked devices
    And Bob should not see my note about him

  # Contacts — "What do they see?"

  @navigation @what-they-see @planned
  Scenario: Navigate from contact to preview-as
    Given I am viewing Bob's contact details on the "Contacts" screen
    When I tap "What do they see?"
    Then I should navigate to the "MyInfo" screen
    And I should see my card in preview-as mode for Bob
    And the banner should say "Viewing as Bob"

  # Exchange — Post-Exchange Flow

  @navigation @exchange @planned
  Scenario: Exchange is accessible from navigation
    When I switch to the "Exchange" screen
    Then I should see the exchange interface
    And I should be able to share my card or receive a card

  # Settings

  @navigation @settings @planned
  Scenario: Settings screen shows configuration items
    When I switch to the "Settings" screen
    Then I should see settings categories:
      | category        |
      | General         |
      | Security        |
      | Privacy         |
      | Appearance      |
      | Linked Devices  |
      | Sync Status     |
      | Backup          |

  # Help

  @navigation @help @planned
  Scenario: Help screen shows support items
    When I switch to the "Help" screen
    Then I should see items:
      | item            |
      | FAQ             |
      | About           |
      | Support Us      |

  # Platform Edge Cases (dissolved from platform_edge_cases.feature 2026-03-17)

  @platform-edge-case @desktop @multi-window @planned
  Scenario: Handle multiple windows on desktop
    Given the app is open in one window
    When I try to open another instance
    Then the existing window should be focused
    Or windows should sync state in real-time
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
    Then a system notification should show
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
