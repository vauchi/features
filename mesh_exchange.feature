# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@exchange @resistance @offline @p2p
Feature: Mesh Exchange Mode
  As an activist or user in a network-constrained environment
  I want to exchange contacts via Bluetooth without internet
  So that I can build trusted connections when networks are unavailable or hostile

  This feature enables contact exchange during internet blackouts, at protests
  where networks are jammed, or in areas with no connectivity. It uses
  Bluetooth Low Energy (BLE) to discover and exchange with nearby users.

  PRINCIPLES ALIGNMENT:
  - Trust earned in person: Maintains physical proximity requirement
  - Offline-first: Extends offline capability to exchange
  - Audited crypto only: Uses same X3DH crypto as normal exchange (ed25519-dalek, x25519-dalek)
  - Privacy is a right: No network means no network surveillance
  - Simplicity: Same UX as normal exchange; works offline

  Background:
    Given I have an existing identity
    And I have created my contact card

  # ============================================================
  # Enabling Mesh Mode
  # ============================================================

  @enable @planned
  Scenario: Enable mesh exchange mode
    Given I am in the exchange screen
    When I enable "Event Mode" (mesh exchange)
    Then my phone should start advertising via BLE
    And I should see nearby Vauchi users appear
    And a status indicator should show "Event Mode: Active"

  @enable @planned
  Scenario: Mesh mode requires Bluetooth permission
    Given Bluetooth is not enabled or permitted
    When I try to enable mesh exchange
    Then I should be prompted to enable Bluetooth
    And I should be asked for necessary permissions
    And mesh mode should only activate after permissions granted

  @enable @planned
  Scenario: Mesh mode does not require internet
    Given I have no internet connection
    When I enable mesh exchange mode
    Then mesh mode should work normally
    And I can discover and exchange with nearby users
    And no network errors should occur

  @enable @planned
  Scenario: Mesh mode indicator
    Given mesh exchange mode is enabled
    Then I should see a visible indicator
    And the indicator should show:
      | info             | value              |
      | Mode status      | Active/Searching   |
      | Nearby users     | Count of discovered|
      | Battery warning  | If battery low     |

  # ============================================================
  # Discovery
  # ============================================================

  @discovery @implemented
  Scenario: Discover nearby Vauchi users
    Given mesh exchange mode is enabled
    And Bob also has mesh exchange enabled within BLE range
    When my phone scans for peers
    Then I should see Bob's device appear in the list
    And I should see a privacy-preserving identifier (not real name)
    And the list should update as users come and go

  @discovery @planned
  Scenario: Privacy-preserving discovery
    Given mesh exchange mode is enabled
    Then my BLE advertisement should not contain:
      | field          | reason                           |
      | Real name      | Privacy before exchange          |
      | Public key     | Prevents correlation attacks     |
      | Contact count  | Metadata protection              |
    And advertisement should contain only:
      | field                | purpose                    |
      | Vauchi service UUID  | Identify as Vauchi user    |
      | Random session ID    | Enable connection          |

  @discovery @planned
  Scenario: Discovery range limit
    Given mesh exchange mode is enabled
    Then only devices within BLE range (~10-30m) should be discoverable
    And this provides physical proximity verification
    And remote parties cannot participate in mesh exchange

  @discovery @planned
  Scenario: Multiple nearby users
    Given mesh exchange mode is enabled
    And 5 other users have mesh mode enabled nearby
    Then I should see all 5 users in my discovery list
    And I can select which user to exchange with
    And each exchange is handled separately

  # ============================================================
  # Exchange Process
  # ============================================================

  @exchange @planned
  Scenario: Initiate mesh exchange
    Given I see Bob in my nearby users list
    When I tap on Bob's entry to exchange
    Then a BLE connection should be established
    And the X3DH key exchange should proceed
    And both parties should see exchange progress

  @exchange @planned
  Scenario: Mesh exchange uses same crypto as QR exchange
    Given I am exchanging with Bob via mesh mode
    Then the cryptographic protocol should be identical to QR exchange
    And X3DH should establish the shared secret
    And the shared key should be derived the same way

  @exchange @planned
  Scenario: Mutual card exchange via mesh
    Given I have initiated mesh exchange with Bob
    When the exchange completes
    Then I should have Bob's contact card
    And Bob should have my contact card
    And both cards should be encrypted with our shared key

  @exchange @planned
  Scenario: Exchange confirmation
    Given mesh exchange with Bob completes
    Then I should see Bob's display name and card preview
    And I should be asked to confirm adding Bob
    And Bob should see the same confirmation for me

  @exchange @implemented
  Scenario: Exchange timeout
    Given I have initiated mesh exchange with Bob
    And Bob's phone becomes unreachable (moved away, turned off)
    When 30 seconds pass without completion
    Then the exchange should timeout
    And I should see "Exchange timed out - stay close to complete"
    And I can retry the exchange

  # ============================================================
  # Proximity Verification
  # ============================================================

  @proximity @planned
  Scenario: BLE range provides proximity verification
    Given I am exchanging via mesh mode
    Then BLE's limited range (~10-30m) provides physical proximity verification
    And this replaces the ultrasonic proximity check used in QR mode
    And both parties must be genuinely nearby

  @proximity @planned
  Scenario: Signal strength indicator
    Given I see Bob in my nearby users list
    Then I should see a signal strength indicator
    And stronger signal suggests closer proximity
    And this helps identify the correct person in crowded spaces

  @proximity @planned
  Scenario: Exchange fails if moved out of range
    Given I am mid-exchange with Bob
    When Bob moves out of BLE range
    Then the exchange should fail
    And I should see "Lost connection - move closer to retry"
    And no partial contact should be saved

  # ============================================================
  # Event/Protest Scenarios
  # ============================================================

  @event @planned
  Scenario: Mass exchange at protest
    Given 50 people at a protest have mesh mode enabled
    When I look at my nearby users list
    Then I should see up to 50 users
    And I can scroll through and select who to exchange with
    And the list should handle large numbers gracefully

  @event @planned
  Scenario: Quick successive exchanges
    Given I am at an event and want to exchange with many people
    When I complete an exchange with Bob
    Then I should immediately be able to exchange with Carol
    And the discovery should continue running
    And I should see a running count of exchanges completed

  @event @planned
  Scenario: Battery conservation
    Given mesh mode is enabled
    And my battery is below 20%
    Then I should see a battery warning
    And I should be offered "Low Power Mode" with reduced scan frequency
    And mesh mode should remain functional but scan less often

  @event @planned
  Scenario: Exchange without verbal communication
    Given I am at a protest where speaking is risky
    When I initiate exchange with someone
    Then the exchange should complete without voice communication
    And visual confirmations should be sufficient
    And both parties see same confirmation code for verification

  # ============================================================
  # Security Properties
  # ============================================================

  @security @planned
  Scenario: No relay or server involved
    Given I exchange with Bob via mesh mode
    Then no network requests should be made
    And no relay should be contacted
    And the exchange is purely peer-to-peer

  @security @planned
  Scenario: Mesh exchange provides deniability
    Given I exchange with Bob via mesh mode
    Then no server has a record of our exchange
    And only our two devices know we exchanged
    And this provides better metadata protection

  @security @planned
  Scenario: Session IDs prevent correlation
    Given I enable mesh mode at time T1
    And I disable and re-enable at time T2
    Then my BLE session ID should be different
    And observers cannot correlate my presence across sessions

  @security @implemented
  Scenario: Replay attack prevention
    Given I completed an exchange with Bob
    When an attacker replays the BLE packets
    Then the replay should be detected
    And no duplicate contact should be created
    And the attack should be logged

  # ============================================================
  # Integration with Existing Features
  # ============================================================

  @integration @planned
  Scenario: Mesh-exchanged contacts sync normally later
    Given I exchanged with Bob via mesh mode while offline
    When I later connect to the internet
    Then Bob's contact should sync normally
    And future updates should work via relay
    And the mesh exchange doesn't affect ongoing sync

  @integration @planned
  Scenario: Visibility rules apply to mesh exchanges
    Given I have configured visibility rules
    When I exchange with Bob via mesh mode
    Then Bob should receive my card filtered by visibility
    And the same rules apply as QR exchange

  @integration @planned
  Scenario: Hidden contacts from mesh exchange
    Given I exchange with Bob via mesh mode
    When I later hide Bob's contact
    Then normal hidden contact behavior applies
    And the mesh exchange doesn't affect this

  # ============================================================
  # Edge Cases
  # ============================================================

  @edge @implemented
  Scenario: Exchange with user already in contacts
    Given I already have Bob as a contact
    When I try to exchange with Bob via mesh mode
    Then I should see "Bob is already in your contacts"
    And I should be offered to update or cancel
    And duplicate handling should work normally

  @edge @planned
  Scenario: Self-discovery prevention
    Given mesh exchange mode is enabled
    Then my own device should not appear in my discovery list
    And I cannot exchange with myself

  @edge @planned
  Scenario: Mesh mode on desktop
    Given I am using the desktop app
    When I try to enable mesh exchange
    Then I should see "Mesh exchange requires mobile device"
    And mesh mode should not be available
    And desktop should continue using QR exchange

  @edge @planned
  Scenario: Airplane mode with Bluetooth
    Given my phone is in airplane mode
    But Bluetooth is enabled
    When I enable mesh exchange mode
    Then mesh mode should work normally
    And I can exchange without any network connectivity

  @edge @planned
  Scenario: Mesh mode battery drain
    Given mesh exchange mode has been active for 1 hour
    Then the app should show a reminder "Event Mode still active"
    And I should be offered to disable it
    And this prevents accidental battery drain
