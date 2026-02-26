# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@exchange @proximity
Feature: Contact Card Exchange
  As a Vauchi user
  I want to exchange contact cards with people I meet in person
  So that I can build my contact list through real-world interactions

  Background:
    Given Alice has Vauchi installed with identity "Alice"
    And Bob has Vauchi installed with identity "Bob"
    And both devices are operational

  # QR Code Exchange

  @qr-code @implemented
  Scenario: Generate exchange QR code
    Given Alice wants to share her contact card
    When Alice selects "Share Contact"
    Then a QR code should be displayed
    And the QR code should contain Alice's public key
    And the QR code should contain a fresh ephemeral X25519 exchange key
    And the QR code should contain a one-time exchange token
    And the QR code should contain an audio challenge seed

  @qr-code @implemented
  Scenario: QR code expiration
    Given Alice has generated an exchange QR code
    When 5 minutes have passed
    Then the QR code should expire
    And Alice should be prompted to generate a new one
    And scanning the expired QR code should fail

  @qr-code @qr-mutual @implemented
  Scenario: Successful QR code exchange with proximity
    Given Alice is displaying her exchange QR code
    And Bob is displaying his exchange QR code
    And both are physically present
    When Alice scans Bob's QR code
    And Bob scans Alice's QR code
    Then symmetric key agreement should succeed
    And Bob should receive Alice's contact card
    And Alice should receive Bob's contact card
    And both should see "Exchange Successful"

  @qr-code @proximity-fail @implemented
  Scenario: QR code exchange blocked without proximity
    Given Alice is displaying her exchange QR code
    And Bob is scanning remotely via screenshot
    When Bob scans Alice's QR code
    Then ultrasonic audio verification should fail
    And the exchange should be blocked
    And both should see "Proximity verification failed"
    And no contact cards should be exchanged

  # Mutual QR Code Exchange

  @qr-mutual @implemented
  Scenario: Mutual QR exchange with bidirectional scanning
    Given Alice and Bob both want to exchange contact cards
    When Alice initiates a mutual QR exchange
    And Bob initiates a mutual QR exchange
    Then both devices should display QR codes simultaneously
    And each QR code should contain a fresh ephemeral X25519 key
    When Alice scans Bob's QR code
    And Bob scans Alice's QR code
    Then symmetric key agreement should succeed
    And both should receive each other's contact cards
    And both should see "Exchange Successful"

  @qr-mutual @forward-secrecy @implemented
  Scenario: Mutual QR uses fresh ephemeral keys for forward secrecy
    Given Alice initiates a mutual QR exchange
    When Alice's QR code is generated
    Then the exchange key in the QR should be a fresh ephemeral key
    And the ephemeral key should differ from Alice's identity exchange key
    And a new exchange generates a different ephemeral key each time

  @qr-mutual @implemented
  Scenario: Mutual QR rejects expired peer QR code
    Given Alice has initiated a mutual QR exchange
    And Bob's QR code was generated more than 5 minutes ago
    When Alice scans Bob's expired QR code
    Then the exchange should fail with "QRExpired" error
    And Alice should see "QR code has expired"

  @qr-mutual @self-exchange @implemented
  Scenario: Mutual QR prevents self-exchange
    Given Alice has initiated a mutual QR exchange
    When Alice scans her own QR code
    Then the exchange should fail with "SelfExchange" error
    And Alice should see "Cannot exchange with yourself"

  @qr-mutual @implemented
  Scenario: Default QR exchange uses mutual flow
    Given Alice initiates a QR exchange
    Then the exchange should use the mutual QR flow
    And Alice's QR code should contain a fresh ephemeral X25519 key
    And Alice should see her QR code and a scanner simultaneously

  # Bluetooth Low Energy (BLE) Exchange

  @ble @mobile @planned
  Scenario: Discover nearby Vauchi users via BLE
    Given Alice has BLE enabled
    And Bob has BLE enabled and is within 2 meters
    When Alice opens the "Nearby" screen
    Then Alice should see Bob in the nearby users list
    And the signal strength should indicate close proximity

  @ble @mobile @planned
  Scenario: Initiate BLE exchange
    Given Alice sees Bob in the nearby users list
    And Bob is within 2 meters (verified by RSSI)
    When Alice taps on Bob to exchange
    And Bob accepts the exchange request
    Then contact cards should be exchanged over BLE
    And both should see "Exchange Successful"

  @ble @mobile @proximity-fail @planned
  Scenario: BLE exchange blocked when too far
    Given Alice sees Bob in the nearby users list
    But Bob is more than 2 meters away
    When Alice attempts to exchange with Bob
    Then the exchange should be blocked
    And Alice should see "Move closer to exchange"

  @ble @mobile @planned
  Scenario: BLE exchange with relay attack prevention
    Given an attacker is relaying BLE signals
    And Alice attempts to exchange with what appears to be Bob
    When the challenge-response verification runs
    Then the relay attack should be detected
    And the exchange should be blocked
    And Alice should see "Security verification failed"

  @ble @forward-secrecy @planned
  Scenario: BLE exchange uses fresh ephemeral keys
    Given Alice and Bob are exchanging via BLE
    When both devices generate BLE exchange payloads
    Then each payload should contain a fresh ephemeral X25519 key
    And the ephemeral keys should differ from identity exchange keys
    And symmetric DH key agreement should produce matching shared secrets
    And forward secrecy should be established

  @ble @mobile @planned
  Scenario: BLE exchange rejects expired payload
    Given Alice has initiated a BLE exchange
    And Bob's BLE payload was generated more than 60 seconds ago
    When Alice receives Bob's expired BLE payload
    Then the exchange should fail with "BleExpired" error

  @ble @mobile @self-exchange @planned
  Scenario: BLE exchange prevents self-exchange
    Given Alice has initiated a BLE exchange
    When Alice's device discovers its own BLE advertisement
    Then the exchange should fail with "SelfExchange" error

  # NFC Active Exchange (phone-to-phone tap)

  @nfc @active @mobile @implemented
  Scenario: NFC active exchange between two phones
    Given Alice and Bob both have NFC-capable devices
    When Alice initiates an NFC exchange
    And Bob initiates an NFC exchange
    And Alice and Bob tap their phones together
    Then both devices should exchange 174-byte NFC payloads via APDU
    And symmetric key agreement should succeed
    And both should receive each other's contact cards
    And both should see "Exchange Successful"

  @nfc @active @forward-secrecy @implemented
  Scenario: NFC active uses fresh ephemeral keys for forward secrecy
    Given Alice initiates an NFC exchange
    When the NFC payload is generated
    Then the payload should contain a fresh ephemeral X25519 key
    And the ephemeral key should differ from Alice's identity exchange key
    And the payload should be exactly 174 bytes with "VNFC" magic

  @nfc @active @implemented
  Scenario: NFC payload expires after 60 seconds
    Given Alice has generated an NFC exchange payload
    When 60 seconds have passed since generation
    Then the NFC payload should be expired
    And scanning the expired payload should fail
    And Alice should need to regenerate the payload

  @nfc @active @self-exchange @implemented
  Scenario: NFC exchange prevents self-exchange
    Given Alice has initiated an NFC exchange
    When Alice's device receives its own NFC payload
    Then the exchange should fail with "SelfExchange" error

  @nfc @active @cross-platform @implemented
  Scenario Outline: NFC active exchange platform compatibility
    Given Alice is using <platform_a>
    And Bob is using <platform_b>
    When they perform an NFC active exchange
    Then the exchange should <result>

    Examples:
      | platform_a | platform_b | result                              |
      | Android    | Android    | succeed                             |
      | iOS        | Android    | succeed (iOS as reader)             |
      | iOS        | iOS        | fail — both cannot do HCE, use QR   |

  @nfc @active @implemented
  Scenario: NFC tap too brief to complete exchange
    Given Alice and Bob are attempting an NFC exchange
    When the devices are tapped together too briefly
    And the APDU exchange does not complete
    Then both should see "Tap again — exchange incomplete"
    And no partial state should be stored

  # Exchange Protocol Security

  @security @exchange @implemented
  Scenario: X3DH key agreement during exchange
    Given Alice and Bob are performing an exchange
    When the exchange is initiated
    Then X3DH key agreement should establish a shared secret
    And the shared secret should be unique to Alice and Bob
    And the contact cards should be encrypted with the shared secret

  @security @exchange @implemented
  Scenario: Exchange creates mutual keys
    Given Alice and Bob have completed an exchange
    Then Alice should have an encryption key for communicating with Bob
    And Bob should have an encryption key for communicating with Alice
    And these keys should be derived from the same shared secret
    And forward secrecy should be established via ratcheting

  @security @exchange @implemented
  Scenario: Exchange verifies identity
    Given Alice and Bob are completing an exchange
    When contact cards are received
    Then Alice should verify Bob's card is signed by Bob's public key
    And Bob should verify Alice's card is signed by Alice's public key
    And unsigned or incorrectly signed cards should be rejected

  # Exchange States and Errors

  @exchange-state @implemented
  Scenario: Incomplete exchange recovery
    Given Alice and Bob are mid-exchange
    When Alice's device loses connectivity
    Then the exchange should pause
    And both should see "Exchange interrupted"
    And the exchange should be resumable for 60 seconds

  @exchange-state @implemented
  Scenario: Resume interrupted exchange
    Given an exchange between Alice and Bob was interrupted
    And less than 60 seconds have passed
    When Alice's device reconnects
    Then the exchange should automatically resume
    And complete successfully

  @exchange-state @implemented
  Scenario: Exchange timeout after interruption
    Given an exchange between Alice and Bob was interrupted
    And 60 seconds have passed
    Then the exchange session should expire
    And both should need to start a new exchange

  @exchange-error @implemented
  Scenario: Handle malformed QR code
    Given Alice is scanning a QR code
    When the QR code contains invalid data
    Then Alice should see "Invalid QR code"
    And no exchange should be attempted

  @exchange-error @implemented
  Scenario: Handle non-Vauchi QR code
    Given Alice is scanning a QR code
    When the QR code is not from Vauchi
    Then Alice should see "Not a Vauchi contact code"
    And no exchange should be attempted

  # Duplicate and Existing Contacts

  @duplicate @implemented
  Scenario: Exchange with existing contact
    Given Alice already has Bob in her contacts
    When Alice and Bob perform another exchange
    Then Alice should see "Bob is already in your contacts"
    And Alice should be asked "Update contact?"
    And the existing contact should not be duplicated

  @duplicate @implemented
  Scenario: Update existing contact via exchange
    Given Alice has Bob in her contacts with phone "555-1111"
    And Bob has updated his phone to "555-2222"
    When Alice and Bob perform an exchange
    And Alice chooses to update the contact
    Then Alice's contact for Bob should show phone "555-2222"

  @duplicate @implemented
  Scenario: Keep existing contact without update
    Given Alice has Bob in her contacts with phone "555-1111"
    And Bob has updated his phone to "555-2222"
    When Alice and Bob perform an exchange
    And Alice chooses not to update
    Then Alice's contact for Bob should still show phone "555-1111"

  # Audio Proximity Verification Details

  @audio @proximity @planned
  Scenario: Ultrasonic audio handshake process
    Given Alice is displaying a QR code
    And Bob has scanned the QR code
    When proximity verification begins
    Then Alice's device should emit an ultrasonic challenge
    And Bob's device should detect the challenge
    And Bob's device should emit a signed response
    And Alice's device should verify the response
    And both devices should confirm proximity

  @audio @proximity @planned
  Scenario: Audio verification works in noisy environment
    Given there is ambient noise in the environment
    When Alice and Bob perform audio proximity verification
    Then the ultrasonic frequencies should not be affected
    And verification should succeed

  @audio @proximity @planned
  Scenario: Audio verification on devices without ultrasonic support
    Given Bob's device cannot emit ultrasonic audio
    When Bob scans Alice's QR code
    Then fallback verification should be offered
    And Alice should manually confirm Bob's presence
    And a warning about reduced security should be shown

  # Cross-Platform Exchange

  @cross-platform @planned
  Scenario Outline: Exchange between different platforms
    Given Alice is using <platform_a>
    And Bob is using <platform_b>
    When they perform a QR code exchange with proximity verification
    Then the exchange should succeed
    And both should have each other's contact cards

    Examples:
      | platform_a | platform_b |
      | iOS        | Android    |
      | iOS        | Desktop    |
      | Android    | Desktop    |
      | Desktop    | iOS        |
      | Desktop    | Android    |

  @cross-platform @desktop @planned
  Scenario: Desktop exchange without audio (requires confirmation)
    Given Alice is using desktop without microphone
    And Bob is using mobile
    When Alice displays QR code on desktop
    And Bob scans it
    Then Bob should be asked to confirm Alice is present
    And Alice should be asked to confirm Bob is present
    And the exchange should complete after both confirmations

  # Edge Cases (Added 2026-01-21)

  @edge-case @self-exchange @planned
  Scenario: Cannot exchange with yourself
    Given Alice has generated an exchange QR code
    When Alice scans her own QR code
    Then the exchange should fail with "SelfExchange" error
    And Alice should see "Cannot exchange with yourself"

  @edge-case @duplicate @implemented
  Scenario: Same QR scanned twice by same person
    Given Alice has generated an exchange QR code
    And Bob has scanned it and completed exchange
    When Bob attempts to scan the same QR again
    Then Bob should see "Already connected with Alice"
    And no duplicate contact should be created

  @edge-case @network @planned
  Scenario: Network failure during key exchange
    Given Alice and Bob are mid-exchange
    When the network drops during X3DH handshake
    Then ephemeral keys should be discarded
    And no partial state should be stored
    And exchange should require a fresh start

  @edge-case @prekey @planned
  Scenario: Exchange with stale prekey
    Given Alice's prekey bundle is cached by Bob
    When Alice has rotated her prekeys since Bob cached them
    And Bob uses the cached stale prekey
    Then the exchange should fail gracefully
    And Bob should fetch fresh prekeys
    And the exchange should be retried


  @privacy @consent @planned
  Scenario: Deny exchange request
    Given Alice sees Bob in the nearby list
    When Alice sends an exchange request to Bob
    And Bob selects "Decline"
    Then Alice should see "Exchange declined"
    And no contact cards or keys should be shared

  @privacy @consent @planned
  Scenario: Blocked user attempts exchange
    Given Alice has previously blocked "Eve"
    When Eve scans Alice's exchange QR code
    Then the exchange should be automatically rejected
    And Alice should not receive any notification
    And Eve should see "Exchange failed"

  # Hardware & Resource Constraints

  @hardware @battery @planned
  Scenario: Exchange blocked on low battery
    Given Alice's device battery is below 5%
    When Alice attempts to initiate an exchange
    Then Alice should see "Battery too low for secure exchange"
    And the QR code should not be generated

  @hardware @storage @planned
  Scenario: Exchange fails due to full storage
    Given Bob's device has zero available storage
    When Bob scans Alice's QR code
    Then the exchange should fail
    And Bob should see "Storage full: cannot save contact"

  # Multi-User / Group Dynamics

  @multi-user @proximity @planned
  Scenario: Simultaneous QR scans (Group mode)
    Given Alice is displaying a "Group Exchange" QR code
    And Bob and Charlie are both scanning it simultaneously
    When both verify proximity via audio
    Then Alice should receive contact cards from both Bob and Charlie
    And Bob and Charlie should both receive Alice's card
    But Bob and Charlie should NOT receive each other's cards

  # Identity & Spoofing

  @security @spoofing @implemented
  Scenario: Identity mismatch detection
    Given Alice's QR code contains Public Key A
    When Alice's device attempts to sign the exchange with Private Key B
    Then the exchange should be aborted
    And Bob should see "Identity verification error"

  # Time & Synchronization

  @edge-case @clock-drift @planned
  Scenario: Exchange fails with significant clock drift
    Given Alice's system clock is 1 hour behind real time
    And Bob's clock is accurate
    When Alice and Bob attempt an exchange
    Then the timestamped exchange token should be rejected
    And Alice should see "Check your device time settings"

