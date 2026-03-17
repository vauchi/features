# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @resistance @emergency @alert
Feature: Emergency Broadcast
  As an activist or at-risk user
  I want to send a one-tap alert to trusted contacts
  So that they know I may be in danger and can take action

  This feature enables users to quickly notify trusted contacts of potential
  danger without requiring them to compose a message or take multiple actions.

  PRINCIPLES ALIGNMENT:
  - Privacy is a right: Alerts are E2E encrypted
  - Trust earned in person: Alerts go only to contacts met in person
  - Zero knowledge: Alert looks like normal sync to relay
  - Simplicity: One tap to alert — simple mental model
  - No harvesting: No location unless user explicitly enables

  Background:
    Given I have an existing identity
    And I have exchanged contacts with trusted people

  # ============================================================
  # Setup and Configuration
  # ============================================================

  @setup @implemented
  Scenario: Configure emergency broadcast contacts
    Given I am in the app settings
    When I navigate to "Emergency Broadcast"
    Then I should see my contacts list
    And I should be able to select up to 10 trusted contacts
    And selected contacts will receive alerts when triggered

  @setup @implemented
  Scenario: Configure alert message
    Given I am configuring emergency broadcast
    When I set up my alert message
    Then I can use the default: "I may be in danger. Please check on me."
    Or I can write a custom message (max 500 chars)
    And the message is stored encrypted locally

  @setup @implemented
  Scenario: Configure location sharing for alerts
    Given I am configuring emergency broadcast
    When I configure location settings
    Then location sharing should be OFF by default
    And I can enable "Include last known location in alerts"
    And I understand this reduces privacy for safety

  @setup @implemented
  Scenario: Emergency broadcast is opt-in
    Given I have just installed the app
    When I check settings
    Then emergency broadcast should not be configured
    And no trusted contacts should be selected by default

  # ============================================================
  # Triggering Alerts
  # ============================================================

  @trigger @implemented
  Scenario: Send emergency broadcast from app
    Given I have configured emergency broadcast contacts
    When I navigate to the emergency broadcast screen
    And I trigger the alert
    Then a confirmation should appear briefly
    And the alert should be sent to all trusted contacts

  @trigger @planned
  Scenario: Quick access to emergency broadcast
    Given I have configured emergency broadcast
    When I use the quick access gesture (e.g., triple-tap header)
    Then the emergency broadcast screen should open immediately
    And I can trigger the alert within 2 taps

  @trigger @planned
  Scenario: Emergency broadcast from widget
    Given I have the emergency broadcast widget on my home screen
    When I trigger the widget
    Then the alert should be sent to trusted contacts
    And this should work without opening the full app

  @trigger @implemented
  # promoted_to: tui!67, desktop!99
  Scenario: Emergency broadcast with confirmation
    Given I am about to send an emergency broadcast
    When I tap the send button
    Then I should see a brief confirmation: "Send alert to 5 contacts?"
    And I can confirm or cancel
    And the timeout should be 5 seconds

  # ============================================================
  # Alert Content and Delivery
  # ============================================================

  @delivery @implemented
  Scenario: Alert message content
    Given I have triggered an emergency broadcast
    Then each trusted contact should receive:
      | field      | value                                  |
      | type       | EMERGENCY_ALERT                        |
      | message    | My configured message                  |
      | timestamp  | Current time                           |
      | sender_id  | My contact ID                          |
    And location should only be included if enabled

  @delivery @implemented
  Scenario: Alert is encrypted end-to-end
    Given I send an emergency broadcast
    Then the alert should be encrypted with each contact's shared key
    And the relay should only see encrypted blobs
    And only intended recipients can read the alert

  @delivery @implemented
  Scenario: Alert looks like normal sync traffic
    Given I send an emergency broadcast
    Then to the relay it should look like a card update
    And the message size should be padded to standard sizes
    And network observers cannot distinguish it from normal sync

  @delivery @implemented
  Scenario: Alert delivery to multiple contacts
    Given I have 5 trusted contacts configured
    When I send an emergency broadcast
    Then alerts should be sent to all 5 contacts
    And each gets individually encrypted message
    And delivery is attempted in parallel

  @delivery @planned
  Scenario: Alert delivery when offline
    Given I have no network connection
    When I send an emergency broadcast
    Then alerts should be queued locally
    And alerts should be sent when connectivity returns
    And I should see "Alert queued - will send when online"

  # ============================================================
  # Receiving Alerts
  # ============================================================

  @receive @planned
  Scenario: Receive emergency alert notification
    Given Bob has me as a trusted contact for emergency broadcast
    When Bob sends an emergency broadcast
    Then I should receive a high-priority notification
    And the notification should show "Emergency alert from Bob"
    And tapping should open the alert details

  @receive @planned
  Scenario: Emergency alert displayed prominently
    Given I receive an emergency alert from Bob
    When I view the alert
    Then I should see Bob's message
    And I should see when the alert was sent
    And if location was included, I should see a map link
    And the UI should clearly indicate this is an emergency

  @receive @planned
  Scenario: Emergency alert sound and vibration
    Given I receive an emergency alert
    Then it should use emergency notification settings
    And it should override Do Not Disturb (if system allows)
    And it should use distinct sound/vibration pattern

  @receive @planned
  Scenario: Emergency alert history
    Given I have received emergency alerts in the past
    When I view my contact with that person
    Then I should see a history of emergency alerts received
    And I should see timestamps for each alert

  # ============================================================
  # Location Handling
  # ============================================================

  @location @planned
  Scenario: Location disabled by default
    Given I am configuring emergency broadcast
    Then location sharing should be OFF by default
    And I should see a privacy notice about location
    And enabling requires explicit confirmation

  @location @planned
  Scenario: Include location when enabled
    Given I have enabled location sharing for alerts
    When I send an emergency broadcast
    Then my current location should be included
    And location should be approximate (city-level) not exact
    And location should be encrypted with the message

  @location @planned
  Scenario: Location unavailable
    Given I have enabled location sharing
    But location services are disabled or unavailable
    When I send an emergency broadcast
    Then the alert should still be sent
    And location field should indicate "unavailable"
    And this should not block the alert

  # ============================================================
  # Integration with Other Features
  # ============================================================

  @integration @planned
  Scenario: Emergency broadcast before panic shred
    Given I have configured both emergency broadcast and panic widget
    When I trigger panic shred
    Then emergency broadcasts should NOT be automatically sent
    And panic shred has its own notification mechanism (pre-signed)
    And these are separate features for different scenarios

  @integration @planned
  Scenario: Emergency broadcast from duress mode
    Given I am in duress mode (unlocked with duress PIN)
    When I try to send an emergency broadcast
    Then I should be able to trigger a broadcast
    But it should go to contacts in the decoy profile
    And real trusted contacts should not receive alerts from duress mode

  @integration @planned
  Scenario: Emergency broadcast works in Tor mode
    Given Tor mode is enabled
    When I send an emergency broadcast
    Then the alert should be routed through Tor
    And delivery may be slower but should still work

  # ============================================================
  # Edge Cases
  # ============================================================

  @edge @implemented
  Scenario: No trusted contacts configured
    Given I have not configured any trusted contacts
    When I try to send an emergency broadcast
    Then I should be prompted to configure contacts first
    And no alert should be sent

  @edge @planned
  Scenario: All trusted contacts offline
    Given all my trusted contacts are offline
    When I send an emergency broadcast
    Then alerts should be queued on the relay
    And contacts will receive when they come online
    And I should see "Alerts sent - delivery pending"

  @edge @planned
  Scenario: Accidental alert cancellation
    Given I triggered an emergency broadcast by mistake
    And alerts are queued but not yet sent
    When I cancel within 5 seconds
    Then queued alerts should be cancelled
    And I should see confirmation of cancellation

  @edge @implemented
  Scenario: Blocked contact in trusted list
    Given I have blocked a contact who was in my trusted list
    Then they should be automatically removed from trusted list
    And they should not receive emergency broadcasts

  @edge @implemented
  # promoted_to: tui!67
  Scenario: Rate limiting emergency broadcasts
    Given I have sent an emergency broadcast
    When I try to send another within 1 minute
    Then I should see a warning "Alert recently sent"
    And I should be asked to confirm
    And this prevents accidental repeated alerts
