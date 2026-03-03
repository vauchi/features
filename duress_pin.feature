# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @resistance @coercion @opt-in
Feature: Duress PIN System
  As an activist or at-risk user
  I want a secondary PIN that shows a decoy contact list
  So that I can protect my real contacts when coerced to unlock my device

  This feature provides plausible deniability under coercion. When a user
  is forced to unlock their device (border crossing, arrest, etc.), entering
  the duress PIN reveals a decoy contact list while optionally alerting
  trusted contacts.

  PRINCIPLES ALIGNMENT:
  - Privacy is a right: Protects contacts under coercion
  - Trust earned in person: Duress alerts go to in-person contacts
  - Simplicity: Simple concept (different PIN = different view)
  - User ownership: All data remains local; no central authority

  Background:
    Given I have an existing identity
    And I have contacts in my real contact list

  # ============================================================
  # Setup and Configuration
  # ============================================================

  @setup @implemented
  Scenario: Duress PIN is opt-in and disabled by default
    Given I have just installed the app
    When I check Privacy settings
    Then duress PIN should be disabled
    And no decoy profile should exist

  @setup @implemented
  Scenario: Enable duress PIN in settings
    Given duress PIN is disabled
    When I navigate to Privacy settings
    And I enable "Duress PIN"
    Then I should be prompted to create a duress PIN
    And I should be prompted to set up a decoy profile

  @setup @implemented
  Scenario: Duress PIN must differ from normal PIN
    Given I am setting up a duress PIN
    And my normal PIN is "123456"
    When I try to set duress PIN to "123456"
    Then the PIN should be rejected
    And I should see "Duress PIN must be different from your unlock PIN"

  @setup @implemented
  Scenario: Configure decoy contacts
    Given I have enabled duress PIN
    When I configure the decoy profile
    Then I should be able to add fake contacts
    And I should be able to import from system contacts
    And the decoy contacts should be stored separately

  @setup @implemented
  Scenario: Configure trusted contacts for duress alerts
    Given I have enabled duress PIN
    When I configure duress alert recipients
    Then I should see my real contacts list
    And I should be able to select up to 5 trusted contacts
    And selected contacts will receive silent alerts on duress unlock

  # ============================================================
  # Duress Unlock Behavior
  # ============================================================

  @unlock @planned
  Scenario: Duress PIN shows decoy contacts
    Given I have configured a duress PIN
    And I have configured decoy contacts
    When I unlock the app with the duress PIN
    Then I should see the decoy contact list
    And the real contacts should not be accessible
    And no visual indication of duress mode should be visible

  @unlock @planned
  Scenario: Normal PIN shows real contacts
    Given I have configured a duress PIN
    When I unlock the app with the normal PIN
    Then I should see my real contact list
    And the app should function normally

  @unlock @planned
  Scenario: Duress mode looks identical to normal mode
    Given I have configured a duress PIN with decoy contacts
    When I unlock with the duress PIN
    Then the UI should look identical to normal mode
    And all features should appear to work normally
    And no "duress mode" indicator should be visible anywhere

  @unlock @planned
  Scenario: Cannot access real contacts from duress mode
    Given I have unlocked with the duress PIN
    When I try to access hidden settings or contacts
    Then I should not be able to reach real contacts
    And attempting secret gestures should do nothing

  # ============================================================
  # Silent Alerts
  # ============================================================

  @alert @planned
  Scenario: Duress unlock sends silent alert to trusted contacts
    Given I have configured trusted contacts for duress alerts
    When I unlock the app with the duress PIN
    Then a silent alert should be queued for trusted contacts
    And the alert should be sent via normal sync channel
    And no confirmation should be visible on my device

  @alert @planned
  Scenario: Duress alert looks like normal sync traffic
    Given I have configured duress alerts
    When I unlock with the duress PIN
    Then the alert message should be encrypted
    And to the relay it should look like a normal card update
    And network observers cannot distinguish it from regular traffic

  @alert @planned
  Scenario: Duress alert content
    Given I have configured trusted contacts for duress alerts
    When a duress alert is sent
    Then the recipient should see "Duress alert from [Name]"
    And the alert should include timestamp
    And the alert should NOT include location unless explicitly enabled

  @alert @planned
  Scenario: Receiving a duress alert
    Given Bob has configured me as a duress alert recipient
    When Bob unlocks with his duress PIN
    Then I should receive a duress alert notification
    And the notification should be clearly marked as urgent
    And I should see when the alert was triggered

  @alert @planned
  Scenario: Duress alerts work offline
    Given I have configured duress alerts
    And I have no network connection
    When I unlock with the duress PIN
    Then the alert should be queued locally
    And the alert should be sent when connectivity returns

  # ============================================================
  # Decoy Profile Behavior
  # ============================================================

  @decoy @planned
  Scenario: Decoy profile has separate database
    Given I have configured a duress PIN
    Then the decoy contacts should be stored in a separate encrypted database
    And the decoy database should use the duress PIN for encryption
    And the real database should not be accessible with the duress PIN

  @decoy @planned
  Scenario: Decoy profile functions normally
    Given I am in duress mode
    When I view a decoy contact
    Then I should see their card details
    And I should be able to "edit" their visibility
    And changes should persist in the decoy database

  @decoy @planned
  Scenario: Exchanges in duress mode add to decoy profile
    Given I am in duress mode
    When I exchange contacts with someone
    Then the new contact should be added to the decoy profile
    And they should NOT be added to the real profile
    And they should receive my decoy card (if configured)

  @decoy @planned
  Scenario: Pre-populate decoy contacts
    Given I am setting up a duress PIN
    When I choose to auto-populate decoy contacts
    Then contacts should be created with realistic names
    And cards should contain plausible fake data
    And the list should look like a normal contact list

  # ============================================================
  # Security Properties
  # ============================================================

  @security @planned
  Scenario: Real database cryptographically inaccessible in duress mode
    Given I have unlocked with the duress PIN
    Then the real database key should not be derivable
    And memory should not contain real database key
    And forensic analysis should not reveal real contacts

  @security @planned
  Scenario: Both databases use strong encryption
    Given I have configured a duress PIN
    Then the real database should use normal encryption
    And the decoy database should use separate encryption
    And each database key derived from respective PIN

  @security @planned
  Scenario: Duress PIN entry logged
    Given I have configured duress alerts
    When I unlock with the duress PIN
    Then the duress entry should be logged locally
    And the log should be accessible only from real mode
    And I can review when duress mode was used

  # ============================================================
  # Edge Cases
  # ============================================================

  @edge @implemented
  Scenario: Disable duress PIN from settings
    Given I have configured a duress PIN
    When I navigate to Privacy settings in normal mode
    And I disable duress PIN
    Then the decoy database should be deleted
    And duress alerts should be disabled
    And the duress PIN should no longer work

  @edge @planned
  Scenario: Cannot disable duress PIN from duress mode
    Given I am in duress mode
    When I navigate to Privacy settings
    Then I should not see the option to disable duress PIN
    And I should not be able to access real settings

  @edge @planned
  Scenario: Wrong PIN handling
    Given I have configured a duress PIN
    When I enter an incorrect PIN
    Then normal lockout behavior should apply
    And no indication of duress PIN existence should be shown

  @edge @planned
  Scenario: Biometric unlock with duress
    Given I have configured a duress PIN
    And I have biometric unlock enabled
    Then biometric should unlock to real profile
    And duress mode requires entering the duress PIN manually
    And this is by design (coercion typically involves PIN demand)

  @edge @planned
  Scenario: App update preserves duress configuration
    Given I have configured a duress PIN and decoy profile
    When the app is updated
    Then duress PIN should remain configured
    And decoy contacts should be preserved
    And trusted alert contacts should remain set
