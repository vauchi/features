# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@accessibility @a11y
Feature: Accessibility
  As a user with disabilities
  I want Vauchi to be fully accessible
  So that I can use the app with assistive technologies

  Background:
    Given I have created my identity
    And I have at least one contact

  # ============================================================
  # Screen Reader Support
  # ============================================================

  @screen-reader @ios @planned
  Scenario: VoiceOver announces app structure on iOS
    Given I am using VoiceOver on iOS
    When I open the app
    Then VoiceOver should announce the current screen title
    And navigation elements should be labeled
    And I should be able to navigate by headings

  @screen-reader @android @planned
  Scenario: TalkBack announces app structure on Android
    Given I am using TalkBack on Android
    When I open the app
    Then TalkBack should announce the current screen title
    And navigation elements should be labeled
    And I should be able to explore by touch

  @screen-reader @desktop @planned
  Scenario: Screen reader announces app structure on desktop
    Given I am using a screen reader on desktop
    When I open the app
    Then the screen reader should announce the window title
    And ARIA landmarks should identify regions
    And I should be able to navigate by landmarks

  @screen-reader @planned
  Scenario: Contact list is navigable with screen reader
    Given I have 5 contacts
    When I navigate to the contacts list with a screen reader
    Then each contact should be announced with their name
    And the list count should be announced
    And I should be able to navigate between contacts

  @screen-reader @planned
  Scenario: Contact details are fully announced
    Given I am viewing Bob's contact card
    When a screen reader reads the card
    Then each field label should be announced before its value
    And actionable fields should indicate available actions
    And the card structure should be logical

  @screen-reader @planned
  Scenario: QR code exchange is accessible
    Given I am on the exchange screen
    When a screen reader is active
    Then the QR code should have an accessible description
    And the "Scan QR" button should be clearly labeled
    And instructions should be announced

  @screen-reader @planned
  Scenario: Form fields announce validation errors
    Given I am editing my contact card
    When I leave a required field empty
    And I try to save
    Then the error should be announced immediately
    And focus should move to the first error field
    And the error message should be associated with the field

  @screen-reader @planned
  Scenario: Dialogs and modals are announced
    Given a confirmation dialog appears
    Then the dialog title should be announced
    And the dialog content should be read
    And focus should be trapped within the dialog
    And available actions should be announced

  @screen-reader @planned
  Scenario: Loading states are announced
    Given I trigger a sync operation
    When the sync is in progress
    Then the loading state should be announced
    And progress updates should be announced if lengthy
    And completion should be announced

  @screen-reader @planned
  Scenario: Notifications are announced
    Given I receive a contact update
    Then the notification should be announced as a live region
    And the announcement should not interrupt current reading
    And the notification content should be clear

  # ============================================================
  # Keyboard Navigation (Desktop/TUI)
  # ============================================================

  @keyboard @desktop @planned
  Scenario: Full keyboard navigation on desktop
    Given I am using the desktop app without a mouse
    When I press Tab repeatedly
    Then I should be able to reach all interactive elements
    And focus should be visible at all times
    And the tab order should be logical

  @keyboard @desktop @planned
  Scenario: Keyboard shortcuts for common actions
    Given I am on the main screen
    When I press Ctrl+N (or Cmd+N on Mac)
    Then the new contact exchange screen should open
    And pressing Escape should close dialogs
    And shortcuts should be documented in help

  @keyboard @desktop @planned
  Scenario: Arrow key navigation in lists
    Given I am focused on the contacts list
    When I press Up or Down arrow keys
    Then I should move between contacts
    And pressing Enter should open the selected contact
    And pressing Escape should clear selection

  @keyboard @desktop @planned
  Scenario: Focus management during navigation
    Given I am on the contacts list
    When I open a contact detail view
    Then focus should move to the detail view
    And when I close the detail view
    Then focus should return to the previously focused contact

  @keyboard @tui @planned
  Scenario: TUI is fully keyboard navigable
    Given I am using the TUI app
    Then all actions should be accessible via keyboard
    And key bindings should be shown on screen
    And navigation should follow terminal conventions

  # ============================================================
  # Visual Accessibility
  # ============================================================

  @visual @contrast @planned
  Scenario: Sufficient color contrast
    Given the app uses the default theme
    Then all text should have at least 4.5:1 contrast ratio
    And large text should have at least 3:1 contrast ratio
    And interactive elements should be distinguishable

  @visual @contrast @planned
  Scenario: High contrast mode support
    Given I have enabled high contrast mode in system settings
    When I open the app
    Then the app should respect high contrast settings
    And text should remain readable
    And UI elements should have clear boundaries

  @visual @color @planned
  Scenario: Information not conveyed by color alone
    Given I have contacts with different statuses
    Then status should be indicated by more than just color
    And icons or text should accompany color indicators
    And the app should be usable by colorblind users

  @visual @text-size @planned
  Scenario: Dynamic type support on iOS
    Given I have increased text size in iOS settings
    When I open the app
    Then text should scale according to my preference
    And layout should adapt without truncation
    And the app should remain usable at largest sizes

  @visual @text-size @planned
  Scenario: Font scaling support on Android
    Given I have increased font size in Android settings
    When I open the app
    Then text should scale according to my preference
    And layout should adapt without overlap
    And critical information should remain visible

  @visual @text-size @planned
  Scenario: Text zoom support on desktop
    Given I zoom to 200% in the desktop app
    Then all content should remain accessible
    And no horizontal scrolling should be required
    And interactive elements should remain usable

  # ============================================================
  # Motor Accessibility
  # ============================================================

  @motor @touch-target @planned
  Scenario: Touch targets are large enough
    Given I am using the mobile app
    Then all touch targets should be at least 44x44 points (iOS) or 48x48 dp (Android)
    And targets should have adequate spacing
    And small icons should have expanded hit areas

  @motor @timing @planned
  Scenario: No time-limited interactions
    Given I am performing any action in the app
    Then there should be no time limits on user input
    And session timeouts should warn before expiring
    And I should be able to extend any timeout

  @motor @gestures @planned
  Scenario: Complex gestures have alternatives
    Given the app uses swipe gestures
    Then each gesture should have a button alternative
    And long-press actions should have menu alternatives
    And multi-finger gestures should not be required

  @motor @switch-control @planned
  Scenario: Switch control compatibility on iOS
    Given I am using Switch Control on iOS
    When I navigate the app
    Then all elements should be reachable
    And scanning should follow logical order
    And actions should be performable with switches

  @motor @switch-access @planned
  Scenario: Switch Access compatibility on Android
    Given I am using Switch Access on Android
    When I navigate the app
    Then all elements should be reachable
    And scanning should follow logical order
    And actions should be performable with switches

  # ============================================================
  # Cognitive Accessibility
  # ============================================================

  @cognitive @clarity @planned
  Scenario: Clear and simple language
    Given I am reading any text in the app
    Then language should be clear and concise
    And technical jargon should be avoided or explained
    And instructions should be step-by-step

  @cognitive @consistency @planned
  Scenario: Consistent navigation and layout
    Given I navigate through different screens
    Then navigation elements should be in consistent positions
    And similar actions should look similar
    And the mental model should be predictable

  @cognitive @errors @planned
  Scenario: Helpful error messages
    Given an error occurs
    Then the error message should explain what happened
    And it should suggest how to fix the problem
    And it should not use technical error codes only

  @cognitive @confirmation @planned
  Scenario: Confirmation for destructive actions
    Given I try to delete a contact
    Then I should see a confirmation dialog
    And the dialog should clearly state what will happen
    And I should be able to undo or cancel

  @cognitive @focus @planned
  Scenario: Reduced motion support
    Given I have enabled reduced motion in system settings
    When I use the app
    Then animations should be minimized or disabled
    And transitions should be instant or very brief
    And no content should auto-scroll or auto-play

  # ============================================================
  # Assistive Technology Integration
  # ============================================================

  @assistive @voice-control @planned
  Scenario: Voice Control compatibility on iOS
    Given I am using Voice Control on iOS
    When I say "tap Contacts"
    Then the Contacts button should be activated
    And all interactive elements should have speakable names
    And overlay numbers should work for unlabeled elements

  @assistive @voice-access @planned
  Scenario: Voice Access compatibility on Android
    Given I am using Voice Access on Android
    When I speak commands
    Then I should be able to navigate and interact
    And numbered overlays should identify elements
    And common actions should have voice commands

  # ============================================================
  # Accessibility Settings
  # ============================================================

  @settings @planned
  Scenario: In-app accessibility settings
    Given I open the Settings screen
    When I navigate to Accessibility settings
    Then I should see options for:
      | Option                    |
      | Reduce animations         |
      | Increase touch target size|
      | High contrast mode        |
      | Screen reader hints       |
    And changes should apply immediately

  @settings @planned
  Scenario: Accessibility preferences persist
    Given I have enabled "Reduce animations" in settings
    When I close and reopen the app
    Then my accessibility preferences should be preserved
    And they should apply on app launch

  # ============================================================
  # Platform-Specific Requirements
  # ============================================================

  @ios @requirement @planned
  Scenario: iOS Accessibility requirements met
    Given I run Accessibility Inspector on the iOS app
    Then there should be no critical accessibility issues
    And all images should have alternative text
    And all controls should have accessibility labels

  @android @requirement @planned
  Scenario: Android Accessibility requirements met
    Given I run Accessibility Scanner on the Android app
    Then there should be no critical accessibility issues
    And all images should have content descriptions
    And all controls should have accessibility labels

  @desktop @requirement @planned
  Scenario: WCAG 2.1 AA compliance on desktop
    Given I run an accessibility audit on the desktop app
    Then all WCAG 2.1 Level A criteria should pass
    And all WCAG 2.1 Level AA criteria should pass
    And focus indicators should always be visible
