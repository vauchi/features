# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@accessibility @a11y @ui
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

  @screen-reader @desktop @implemented
  Scenario: Screen reader announces app structure on desktop
    Given I am using a screen reader on desktop
    When I open the app
    Then the screen reader should announce the window title
    And the app's destinations should appear in the platform accessibility tree

  @screen-reader @implemented
  Scenario: Contact list is navigable with screen reader
    Given I have 5 contacts
    When I navigate to the contacts list with a screen reader
    Then each contact should be announced with their name
    And the list count should be announced
    And I should be able to navigate between contacts

  @screen-reader @implemented
  Scenario: Contact details are fully announced
    Given I am viewing Bob's contact card
    When a screen reader reads the card
    Then each field label should be announced before its value
    And actionable fields should indicate available actions
    And the card structure should be logical

  @screen-reader @implemented
  Scenario: Notifications are announced
    Given I receive a contact update
    Then the notification should be announced as a live region
    And the announcement should not interrupt current reading
    And the notification content should be clear

  # ============================================================
  # Keyboard Navigation (Desktop/TUI)
  # ============================================================

  @keyboard @desktop @implemented
  Scenario: Full keyboard navigation on desktop
    Given I am using the desktop app without a mouse
    When I press Tab repeatedly
    Then I should be able to reach all interactive elements
    And focus should be visible at all times
    And the tab order should be logical

  @keyboard @implemented
  Scenario: Keyboard shortcuts for common actions
    Given a dialog or menu is open
    When I press Escape
    Then it should close

  @keyboard @desktop @implemented
  Scenario: Arrow key navigation in lists
    Given I am focused on the contacts list
    When I press Up or Down arrow keys
    Then I should move between contacts
    And pressing Enter should open the selected contact
    And pressing Escape should clear selection

  @keyboard @desktop @implemented
  Scenario: Focus management during navigation
    Given I am on the contacts list
    When I open a contact detail view
    Then focus should move to the detail view
    And when I close the detail view
    Then focus should return to the previously focused contact

  @keyboard @tui @implemented
  Scenario: TUI is fully keyboard navigable
    Given I am using the TUI app
    Then all actions should be accessible via keyboard
    And choices should show the key that selects them
    And navigation should follow terminal conventions

  # ============================================================
  # Visual Accessibility
  # ============================================================

  @visual @contrast @implemented
  Scenario: Sufficient color contrast
    Given the app uses the default theme
    Then all text should have at least 4.5:1 contrast ratio
    And large text should have at least 3:1 contrast ratio
    And interactive elements should be distinguishable

  @visual @contrast @implemented
  Scenario: High contrast mode support
    Given I have enabled high contrast mode in system settings
    When I open the app
    Then the app should respect high contrast settings
    And text should remain readable
    And UI elements should have clear boundaries

  @visual @color @implemented
  Scenario: Information not conveyed by color alone
    Given I have contacts with different statuses
    Then status should be indicated by more than just color
    And icons or text should accompany color indicators
    And the app should be usable by colorblind users

  @visual @text-size @implemented
  Scenario: Dynamic type support on iOS
    Given I have increased text size in iOS settings
    When I open the app
    Then text should scale according to my preference
    And layout should adapt without truncation
    And the app should remain usable at largest sizes

  @visual @text-size @implemented
  Scenario: Font scaling support on Android
    Given I have increased font size in Android settings
    When I open the app
    Then text should scale according to my preference
    And layout should adapt without overlap
    And critical information should remain visible

  @visual @text-size @implemented
  Scenario: Text zoom support on desktop
    Given I zoom to 200% in the desktop app
    Then all content should remain accessible
    And no horizontal scrolling should be required
    And interactive elements should remain usable

  # ============================================================
  # Motor Accessibility
  # ============================================================

  @motor @touch-target @implemented
  Scenario: Touch targets are large enough
    Given I am using the mobile app
    Then all touch targets should be at least 44x44 points (iOS) or 48x48 dp (Android)
    And targets should have adequate spacing
    And small icons should have expanded hit areas

  @cognitive @errors @implemented
  Scenario: Helpful error messages
    Given an error occurs
    Then the error message should explain what happened
    And it should suggest how to fix the problem
    And it should not use technical error codes only

  @settings @implemented
  Scenario: In-app accessibility settings
    Given I open the Settings screen
    When I navigate to Accessibility settings
    Then I should see options for:
      | Option                     |
      | Reduce animations          |
      | Increase touch target size |
    And changes should apply immediately

  @ios @requirement @implemented
  Scenario: iOS Accessibility requirements met
    Given I run Accessibility Inspector on the iOS app
    Then there should be no critical accessibility issues
    And all images should have alternative text
    And all controls should have accessibility labels

  @android @requirement @implemented
  Scenario: Android Accessibility requirements met
    Given I run Accessibility Scanner on the Android app
    Then there should be no critical accessibility issues
    And all images should have content descriptions
    And all controls should have accessibility labels

  @desktop @requirement @implemented
  Scenario: WCAG 2.1 AA compliance on desktop
    Given I run an accessibility audit on the desktop app
    Then all WCAG 2.1 Level A criteria should pass
    And all WCAG 2.1 Level AA criteria should pass
    And focus indicators should always be visible
