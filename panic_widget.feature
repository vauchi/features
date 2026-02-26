# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @resistance @emergency @widget
Feature: Panic Button Widget
  As an activist or at-risk user
  I want a home screen widget that triggers immediate data destruction
  So that I can protect my contacts when I have only seconds to act

  This feature extends Emergency Shred (emergency_shred.feature) by providing
  a quick-access widget that triggers Panic Shred without opening the app.

  PRINCIPLES ALIGNMENT:
  - Privacy is a right: Enables privacy through rapid data destruction
  - Simplicity: One tap destruction — maximum simplicity
  - User ownership: User controls when to destroy; no remote trigger
  - No harvesting: Widget action is not logged externally

  Background:
    Given I have an existing identity
    And I have contacts and stored data

  # ============================================================
  # Widget Setup
  # ============================================================

  @setup @ios @planned
  Scenario: Add panic widget on iOS
    Given I am on iOS
    When I add a Vauchi widget to my home screen
    Then I should see a "Quick Action" widget option
    And the widget should have a neutral appearance
    And the widget should not be labeled "Panic" or "Emergency"

  @setup @android @planned
  Scenario: Add panic widget on Android
    Given I am on Android
    When I add a Vauchi widget to my home screen
    Then I should see a "Quick Action" widget option
    And I should also see a Quick Settings tile option
    And widgets should have neutral appearance

  @setup @planned
  Scenario: Widget requires authentication on setup
    Given I am adding a panic widget
    When I configure the widget
    Then I should authenticate with my app PIN or biometric
    And this confirms I have access to the app

  @setup @planned
  Scenario: Configure widget confirmation mode
    Given I am setting up the panic widget
    Then I should be able to choose:
      | mode           | description                              |
      | Tap + Confirm  | Tap widget, then confirm in dialog       |
      | Long Press     | Hold widget for 3 seconds to trigger     |
      | Double Tap     | Tap twice quickly to trigger             |
    And the default should be "Tap + Confirm" for safety

  # ============================================================
  # Panic Trigger
  # ============================================================

  @trigger @planned
  Scenario: Trigger panic via widget with confirmation
    Given I have the panic widget on my home screen
    And confirmation mode is "Tap + Confirm"
    When I tap the widget
    Then a confirmation dialog should appear
    And I should have 5 seconds to confirm or cancel
    And the dialog should have minimal text for speed

  @trigger @planned
  Scenario: Trigger panic via widget with long press
    Given I have the panic widget on my home screen
    And confirmation mode is "Long Press"
    When I hold the widget for 3 seconds
    Then panic shred should trigger immediately
    And no additional confirmation should be required

  @trigger @planned
  Scenario: Trigger panic via widget with double tap
    Given I have the panic widget on my home screen
    And confirmation mode is "Double Tap"
    When I double-tap the widget
    Then panic shred should trigger immediately

  @trigger @android @planned
  Scenario: Trigger panic via Quick Settings tile
    Given I am on Android
    And I have added the Vauchi Quick Settings tile
    When I tap the tile
    Then the same trigger behavior should apply as the widget
    And panic shred should be initiated

  # ============================================================
  # Panic Shred Execution
  # ============================================================

  @shred @planned
  Scenario: Widget triggers full panic shred
    Given I have triggered panic via the widget
    Then the panic shred process should execute per emergency_shred.feature
    And pre-signed messages should be sent first
    And all cryptographic keys should be destroyed
    And all local data should be wiped

  @shred @planned
  Scenario: Widget shred sends pre-signed notifications
    Given I have triggered panic via the widget
    Then pre-signed deletion notices should be sent to contacts
    And pre-signed purge requests should be sent to relays
    And this happens before key destruction

  @shred @planned
  Scenario: Widget shred completes quickly
    Given I have triggered panic via the widget
    Then the shred should complete within 5 seconds
    And visual feedback should show progress
    And completion should be clearly indicated

  # ============================================================
  # Visual Design
  # ============================================================

  @design @planned
  Scenario: Widget has neutral appearance
    Given I have the panic widget on my home screen
    Then the widget should blend with other widgets
    And it should not use red, warning colors, or alarms
    And it should not be labeled "Panic", "Emergency", or "Shred"
    And suggested labels include "V" or app icon only

  @design @planned
  Scenario: Widget does not reveal purpose to observers
    Given someone is looking at my home screen
    When they see the Vauchi widget
    Then they should not be able to determine it triggers data destruction
    And it should look like a normal app shortcut

  @design @planned
  Scenario: Confirmation dialog is minimal
    Given I have tapped the widget with confirmation mode enabled
    When the confirmation dialog appears
    Then it should show only essential UI elements
    And the confirm button should be prominent
    And the dialog should close within 5 seconds if no action

  # ============================================================
  # Authentication
  # ============================================================

  @auth @planned
  Scenario: Widget works without app unlock
    Given the app is locked
    When I trigger the panic widget
    Then the widget should NOT require unlocking the app
    And panic shred should proceed immediately
    And this is intentional for emergency scenarios

  @auth @planned
  Scenario: Widget respects device lock state
    Given my device is locked
    When I trigger the panic widget (if visible on lock screen)
    Then the widget should still function
    And panic shred should proceed

  @auth @planned
  Scenario: Widget setup requires authentication
    Given I want to add or configure the panic widget
    Then I should authenticate first
    And only someone with app access can set up the widget

  # ============================================================
  # Edge Cases
  # ============================================================

  @edge @planned
  Scenario: Accidental widget tap with confirmation
    Given confirmation mode is "Tap + Confirm"
    When I accidentally tap the widget
    Then I should have 5 seconds to cancel
    And if I don't confirm, nothing happens
    And the dialog should auto-dismiss

  @edge @planned
  Scenario: Widget trigger while app is open
    Given the app is currently open
    When I trigger the panic widget
    Then panic shred should still proceed
    And the app should close and data should be destroyed

  @edge @planned
  Scenario: Widget trigger with no network
    Given I have no network connection
    When I trigger the panic widget
    Then local data should still be destroyed
    And pre-signed messages should be queued
    And shred report should note notifications pending

  @edge @planned
  Scenario: Remove panic widget
    Given I have the panic widget on my home screen
    When I remove the widget
    Then the widget should be removed normally
    And this does not affect app functionality
    And I can add it again later

  @edge @planned
  Scenario: Multiple devices with widget
    Given I have the panic widget on multiple devices
    When I trigger panic on one device
    Then only that device's data should be destroyed
    And other devices should receive a revocation notice
    And they continue functioning

  # ============================================================
  # Platform-Specific Behavior
  # ============================================================

  @ios @planned
  Scenario: iOS widget uses App Intents
    Given I am on iOS
    Then the panic widget should use App Intents framework
    And it should work via Widget Extensions
    And it should support lock screen placement (iOS 16+)

  @android @planned
  Scenario: Android widget uses AppWidgetProvider
    Given I am on Android
    Then the panic widget should use AppWidgetProvider
    And Quick Settings tile should use TileService
    And both should support direct action without opening app

  @android @planned
  Scenario: Android widget survives app kill
    Given the app process has been killed
    When I trigger the Android panic widget
    Then the widget should wake the app
    And panic shred should proceed normally
