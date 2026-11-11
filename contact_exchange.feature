# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@exchange @proximity
Feature: Contact Card Exchange
  As a Vauchi user
  I want to exchange contact cards with people I meet in person
  So that I can build my contact list through real-world interactions

  Background:
    Given a user "Alice"
    And a user "Bob"

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
    When "Alice" and "Bob" complete a QR exchange
    Then "Alice" has "Bob" as a contact
    And "Bob" has "Alice" as a contact

  @qr-code @sync @implemented
  Scenario: Card update propagates after exchange
    Given "Alice" has an email field "Work Email" with value "alice@old.com"
    When "Alice" and "Bob" complete a QR exchange
    And "Alice" updates their "Work Email" field to "alice@new.com"
    And "Alice" makes their "Work Email" field visible to all
    And "Alice" syncs their card with "Bob"
    Then "Bob" sees "Alice" field "Work Email" with value "alice@new.com"

  @qr-code @proximity-fail @implemented
  Scenario: QR code exchange blocked without proximity
    Given Alice is displaying her exchange QR code
    And Bob is scanning remotely via screenshot
    When Bob scans Alice's QR code
    Then ultrasonic audio verification should fail
    And the exchange should be blocked
    And both should see "Proximity verification failed"
    And no contact cards should be exchanged

  @qr-code @glance @implemented
  Scenario: Glance scans with the rear camera and can switch to the front camera
    Given Alice's device has a camera
    When Alice starts a Glance exchange
    Then the scanner should use the rear camera
    And Alice should be offered "Use Front Camera"
    When Alice chooses "Use Front Camera"
    Then the scanner should switch to the front camera
    And Alice should be offered "Use Rear Camera"

  @qr-code @glance @implemented
  Scenario: Glance keeps the chosen camera when retrying
    Given Alice switched her Glance scanner to the front camera
    When the Glance exchange fails and Alice retries
    Then the scanner should use the front camera

  @qr-code @glance @implemented
  Scenario: Glance shows its QR at a camera-readable brightness
    Given Alice's screen brightness is at its maximum
    When Alice starts a Glance exchange
    Then Alice's screen should dim while her Glance QR is shown
    When Alice leaves the Glance exchange
    Then Alice's screen brightness should be restored

  @exchange @implemented
  Scenario: A QR contact carries its real exchange timestamp
    Given Alice and Bob complete a mutual QR exchange at a known clock time
    Then each contact's exchange timestamp is that time, not zero
    And the same completion path stamps Bluetooth, NFC and USB contacts

  @exchange @audio @implemented
  Scenario: In a mutual QR exchange one side emits the audio challenge first
    Given Alice and Bob have scanned each other's QR and agreed keys
    When both sessions emit their audio proximity commands
    Then exactly one side emits the challenge first and the other listens first
    And the identity-key order decides which, as it does for the escrow role

  @exchange @implemented
  Scenario: A confirmed proximity is not lowered by the automatic check
    Given the shell confirmed medium proximity before key agreement
    When the automatic proximity baseline after key agreement fails
    Then the session and the contact keep medium confidence

  @exchange @glance @security @implemented
  Scenario: A Glance displayer closes its QR window after sixty seconds
    Given Alice shows a Glance QR
    When a connector sends a KeyOffer with a fresh timestamp more than sixty seconds later
    Then Alice's displayer refuses it as expired, whatever timestamp the connector chose
    And a Bluetooth responder that required no nonce keeps waiting for an offer

  @exchange @implemented
  Scenario: A QR contact is named after the peer's QR until their card arrives
    Given Alice scans Bob's QR in the app
    When the exchange auto-advances to completion
    Then the new contact is a placeholder named "Bob", not a copy of Alice's own card

  @exchange @glance @security @implemented
  Scenario: A Glance displayer accepts one KeyOffer per nonce
    Given Alice shows a Glance QR and Bob scans it and connects
    When Bob's KeyOffer echoing the QR's nonce is accepted
    Then a replay of that offer after the displayer resets is refused as a spent nonce
    And a second scanner of the same QR, echoing the same nonce, is refused as well
    And a Bluetooth responder that required no nonce still takes a fresh offer after a reset

  @ble @glance @implemented
  Scenario: Glance redials a connection that never established
    Given Bob scanned Alice's Glance QR
    And Bob's device is connecting to Alice's device
    When the connection fails before it is established
    Then Bob's device should connect to Alice's device again
    And the Glance exchange should continue
    But after two failed redials the exchange should fail

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

  @ble @mobile @implemented
  Scenario: Discover nearby Vauchi users via BLE
    Given Alice has BLE enabled
    And Bob has BLE enabled and is nearby
    When Alice opens the "Nearby" screen
    Then Alice should see Bob in the nearby users list

  @ble @mobile @implemented
  Scenario: Initiate BLE exchange
    Given Alice sees Bob in the nearby users list
    When Alice taps on Bob to exchange
    And Bob accepts the exchange request
    Then contact cards should be exchanged over BLE
    And both should see "Exchange Successful"

  @ble @forward-secrecy @implemented
  Scenario: BLE exchange uses fresh ephemeral keys
    Given Alice and Bob are exchanging via BLE
    When both devices generate BLE exchange payloads
    Then each payload should contain a fresh ephemeral X25519 key
    And the ephemeral keys should differ from identity exchange keys
    And symmetric DH key agreement should produce matching shared secrets
    And forward secrecy should be established

  @ble @mobile @implemented
  Scenario: BLE exchange rejects expired payload
    Given Alice has initiated a BLE exchange
    And Bob's BLE payload was generated more than 60 seconds ago
    When Alice receives Bob's expired BLE payload
    Then the exchange should fail with "BleExpired" error

  @ble @mobile @self-exchange @implemented
  Scenario: BLE exchange prevents self-exchange
    Given Alice has initiated a BLE exchange
    When Alice's device discovers its own BLE advertisement
    Then the exchange should fail with "SelfExchange" error

  # The phones put the first bytes of the advertised token on the air; a
  # value derived from the identity key let a bystander recognise the same
  # user across two exchange screens (vauchi/private#726).
  @ble @privacy @implemented
  Scenario: A BLE advertisement does not identify the user across sessions
    Given Alice opens a BLE exchange screen twice
    Then the token advertised each time is different
    And neither is her identity key or its prefix

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

  @cross-platform @desktop @implemented
  Scenario: Desktop exchange without audio (requires confirmation)
    Given Alice is using desktop without microphone
    And Bob is using mobile
    When Alice displays QR code on desktop
    And Bob scans it
    Then Bob should be asked to confirm Alice is present
    And Alice should be asked to confirm Bob is present
    And the exchange should complete after both confirmations

  # Edge Cases (Added 2026-01-21)

  @edge-case @self-exchange @implemented
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

  @edge-case @network @implemented
  Scenario: Network failure during key exchange
    Given Alice and Bob are mid-exchange
    When the network drops during X3DH handshake
    Then ephemeral keys should be discarded
    And no partial state should be stored
    And exchange should require a fresh start

  @privacy @consent @implemented
  Scenario: Blocked user attempts exchange
    Given Alice has previously blocked "Eve"
    When Eve scans Alice's exchange QR code
    Then the exchange should be automatically rejected
    And Alice should not receive any notification
    And Eve should see "Exchange failed"

  # Hardware & Resource Constraints

  @security @spoofing @implemented
  Scenario: Identity mismatch detection
    Given Alice's QR code contains Public Key A
    When Alice's device attempts to sign the exchange with Private Key B
    Then the exchange should be aborted
    And Bob should see "Identity verification error"

  # Time & Synchronization
