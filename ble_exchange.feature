# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@ble @exchange @implemented
Feature: BLE Exchange Protocol Internals
  As a Vauchi developer
  I want BLE exchange internals to be thoroughly specified
  So that low-level transport, handshake, chunking, and rollback behaviors are traceable

  Background:
    Given Alice has Vauchi installed with identity "Alice"
    And Bob has Vauchi installed with identity "Bob"
    And both devices support BLE

  # --- BLE Payload ---

  @ble-payload
  Scenario: BLE payload generation contains identity and exchange keys
    When Alice generates a BLE exchange payload
    Then the payload should contain Alice's identity key
    And the payload should contain a fresh ephemeral X25519 exchange key

  @ble-payload
  Scenario: BLE payload serialization roundtrip
    When Alice generates a BLE exchange payload
    And the payload is serialized and deserialized
    Then all fields should be preserved exactly

  @ble-payload
  Scenario: BLE payload has valid signature
    When Alice generates a BLE exchange payload
    Then the payload should have a valid Ed25519 signature
    And verifying the signature with Alice's identity key should succeed

  @ble-payload @security
  Scenario: Tampered BLE payload fails signature verification
    Given Alice has generated a BLE exchange payload
    When the exchange key bytes are tampered with
    Then signature verification should fail

  @ble-payload
  Scenario: BLE payload rejected with invalid magic bytes
    Given a payload with magic bytes other than "VBLE"
    When the payload is parsed
    Then it should be rejected as invalid

  @ble-payload
  Scenario: BLE payload expires after 60 seconds
    Given Alice generated a BLE payload more than 60 seconds ago
    When the payload is checked for expiry
    Then it should be marked as expired

  @ble-payload
  Scenario: BLE payload is exactly 174 bytes
    When Alice generates a BLE exchange payload
    Then the serialized payload should be exactly 174 bytes

  @ble-payload @forward-secrecy
  Scenario: BLE ephemeral keys differ from identity keys
    When Alice generates a BLE exchange payload
    Then the ephemeral exchange key should differ from Alice's identity key

  # --- GATT Service ---

  @gatt
  Scenario: GATT UUIDs have correct format
    When the BLE GATT service is configured
    Then the service UUID should have 8-4-4-4-12 format
    And the characteristic UUID should have 8-4-4-4-12 format

  @gatt
  Scenario: GATT service and characteristic UUIDs match expected values
    When the BLE GATT service is configured
    Then the UUIDs should match the Vauchi BLE specification

  # --- BLE Transport (Mock) ---

  @transport
  Scenario: BLE transport can advertise
    Given a mock BLE transport
    When advertising is started
    Then it should succeed without error

  @transport
  Scenario: BLE transport can scan
    Given a mock BLE transport
    When scanning is started
    Then it should succeed without error

  @transport
  Scenario: BLE transport connect, read, write, disconnect
    Given a mock BLE transport
    When a connection is established
    Then reading a characteristic should return data
    And writing a characteristic should succeed
    And disconnecting should succeed

  @transport @error
  Scenario: BLE transport in failure mode returns errors
    Given a mock BLE transport configured to fail
    When any transport operation is attempted
    Then it should return an error

  # --- BLE Exchange Session States ---

  @session
  Scenario: New BLE session starts in AwaitingBleConnection
    When a new BLE exchange session is created
    Then its state should be AwaitingBleConnection

  @session
  Scenario: Session transitions to AwaitingBleVerification after payload exchange
    Given a BLE session in AwaitingBleConnection state
    When payloads are exchanged between Alice and Bob
    Then the session state should transition to AwaitingBleVerification

  @session
  Scenario: Session transitions to AwaitingKeyAgreement after proximity verification
    Given a BLE session in AwaitingBleVerification state
    When proximity is verified
    Then the session state should transition to AwaitingKeyAgreement

  @session
  Scenario: Full BLE exchange lifecycle
    Given Alice and Bob have BLE sessions
    When payloads are exchanged
    And proximity is verified
    And key agreement completes
    Then both sessions should reach Completed state
    And both should have each other's contact cards

  @session @security
  Scenario: Symmetric DH produces identical shared keys
    When Alice and Bob perform DH key agreement via BLE
    Then both shared secrets should be identical

  @session @security
  Scenario: Expired BLE payload is rejected
    Given Bob's BLE payload has expired
    When Alice attempts to process it
    Then it should fail with BleExpired error

  @session @security
  Scenario: Self-exchange is rejected via BLE
    When Alice's device discovers its own BLE payload
    Then the exchange should fail with SelfExchange error

  @session @error
  Scenario: Invalid BLE payload is rejected
    Given a malformed BLE payload
    When Alice attempts to process it
    Then it should be rejected with an error

  @session @error
  Scenario: BLE events rejected on non-BLE transport
    Given an exchange session using QR transport
    When a BLE-specific event is received
    Then it should be rejected

  @session @error
  Scenario: Proximity verification requires AwaitingBleVerification state
    Given a BLE session in AwaitingBleConnection state
    When proximity verification is attempted
    Then it should fail because the session is not in the correct state

  @session @error
  Scenario: Key agreement blocked without proximity verification
    Given a BLE session that has not completed proximity verification
    When key agreement is attempted
    Then it should be blocked

  @session
  Scenario: Full exchange with mock transport
    Given Alice and Bob use mock BLE transports
    When the full exchange flow is executed
    Then payloads should be read and written via GATT
    And DH key agreement should succeed
    And both should have each other's contact cards

  @session @error
  Scenario: BLE error variants have proper display messages
    When each BLE error variant is formatted
    Then each should produce a human-readable message

  # --- BLE Handshake Protocol ---

  @handshake @crypto
  Scenario: X25519 shared secret symmetry
    Given Alice and Bob generate X25519 key pairs
    When they compute shared secrets
    Then Alice's shared secret with Bob's public key should equal Bob's shared secret with Alice's public key

  @handshake @crypto
  Scenario: HKDF produces deterministic output
    Given identical HKDF inputs
    When HKDF is computed twice
    Then both outputs should be identical

  @handshake @crypto
  Scenario: XChaCha20-Poly1305 encryption roundtrip
    Given a plaintext message and AAD
    When the message is encrypted and then decrypted
    Then the decrypted output should match the original plaintext

  @handshake @crypto @security
  Scenario: Tampered ciphertext fails AEAD decryption
    Given an encrypted message
    When a byte in the ciphertext is flipped
    Then decryption should fail

  @handshake @crypto @security
  Scenario: Wrong AAD fails AEAD decryption
    Given an encrypted message with specific AAD
    When decryption is attempted with different AAD
    Then it should fail

  @handshake @crypto
  Scenario: Symmetric key is zeroized on drop
    Given a symmetric key is created
    When it goes out of scope
    Then the key material should be zeroized

  @handshake
  Scenario: Initiator starts in Idle state
    When a new handshake initiator session is created
    Then its state should be Idle

  @handshake
  Scenario: Responder starts in Idle state
    When a new handshake responder session is created
    Then its state should be Idle

  @handshake
  Scenario: Key offer has correct format
    When the initiator creates a key offer
    Then it should be exactly 89 bytes
    And it should contain the correct version byte
    And the initiator should transition to KeyOfferSent

  @handshake @error
  Scenario: Double key offer is rejected
    Given the initiator has already sent a key offer
    When a second key offer is attempted
    Then it should fail with InvalidState error

  @handshake
  Scenario: Responder processes key offer
    Given the initiator has sent an 89-byte key offer
    When the responder processes it
    Then the responder should produce a 113-byte acknowledgment with commitment
    And the responder should transition to KeyAckSent

  @handshake @error
  Scenario: Responder rejects key offer with invalid version
    Given a key offer with an incorrect version byte
    When the responder attempts to process it
    Then it should be rejected

  @handshake @error
  Scenario: Responder rejects truncated key offer
    Given an incomplete key offer packet
    When the responder attempts to process it
    Then it should be rejected

  @handshake
  Scenario: Initiator processes key acknowledgment
    Given the initiator is in KeyOfferSent state
    When the initiator receives the responder's ack
    Then the initiator should produce a commitment and encrypted card

  @handshake @error
  Scenario: Initiator rejects ack in wrong state
    Given the initiator is in Idle state
    When an ack is received
    Then it should fail with InvalidState error

  @handshake
  Scenario: Responder processes committed payload
    Given the responder is in KeyAckSent state
    When the responder receives the initiator's committed payload
    Then the responder should return a reveal containing its card

  @handshake @security
  Scenario: Commitment mismatch is rejected
    Given a committed payload with wrong commitment
    When the responder verifies the commitment
    Then it should fail with BleCommitmentMismatch error

  @handshake
  Scenario: Full 4-phase handshake happy path
    Given Alice is initiator and Bob is responder
    When the 4-phase handshake completes
    Then both should have each other's contact cards
    And CRC16 verification should pass

  @handshake @security
  Scenario: Expired key offer is rejected
    Given a key offer with an expired timestamp
    When the responder processes it
    Then it should be rejected

  @handshake @security
  Scenario: Self-exchange rejected in handshake
    Given both sides have the same identity key
    When a handshake is attempted
    Then it should fail with SelfExchange error

  @handshake @error
  Scenario: Complete exchange rejected in wrong state
    Given the handshake session is in Idle state
    When complete_exchange is called
    Then it should fail with InvalidState error

  @handshake @error
  Scenario: Process committed payload rejected in wrong state
    Given the handshake session is in Idle state
    When process_committed_payload is called
    Then it should fail with InvalidState error

  # --- BLE Integration (Advertisement & Discovery) ---

  @integration @advertisement
  Scenario: Create BLE advertisement with valid token and signature
    When Alice creates a BLE advertisement
    Then it should contain a valid exchange token
    And it should contain a valid signature

  @integration @advertisement
  Scenario: Advertisement includes correct Vauchi service UUID
    When Alice creates a BLE advertisement
    Then it should include the Vauchi BLE service UUID

  @integration @advertisement
  Scenario: Advertisement payload fits BLE limits
    When Alice creates a BLE advertisement
    Then the payload should fit within BLE extended advertisement limits

  @integration @advertisement
  Scenario: Advertisement serialization roundtrip
    When Alice creates a BLE advertisement
    And it is serialized and deserialized
    Then all fields should be preserved

  @integration @discovery
  Scenario: Discover nearby devices
    Given Bob is advertising via BLE
    When Alice scans for nearby devices
    Then Alice should discover Bob's device

  @integration @discovery
  Scenario: Filter devices by exchange token
    Given multiple devices are advertising
    When Alice filters by exchange token
    Then only matching devices should be returned

  @integration @distance
  Scenario: Distance estimation from RSSI
    Given a BLE signal with known RSSI
    When distance is estimated
    Then the estimate should be reasonable for the RSSI value

  @integration @session
  Scenario: Exchange session creation
    When Alice creates a BLE exchange session
    Then it should start in Idle state with an exchange token

  @integration @session
  Scenario: Session transitions to Advertising
    Given Alice has a BLE session
    When advertising is started
    Then the session should transition to Advertising state

  @integration @session
  Scenario: Session transitions to Scanning
    Given Alice has a BLE session
    When scanning is started
    Then the session should transition to Scanning state

  @integration @session
  Scenario: Connect to discovered device
    Given Alice has discovered Bob's device
    When Alice connects to Bob
    Then the session should transition to Connected state

  @integration @session
  Scenario: Full mock exchange with data transfer
    Given Alice and Bob both have BLE sessions
    When the full advertising, scanning, and exchange flow completes
    Then both should have each other's contact data

  @integration @timeout
  Scenario: Session timeout
    Given Alice has a BLE session
    When the session timeout expires
    Then the session should transition to TimedOut state

  @integration @cancel
  Scenario: Cancel session
    Given Alice has an active BLE session
    When Alice cancels the session
    Then the session should transition to Cancelled state

  @integration @proximity
  Scenario: Proximity verification passes for close devices
    Given Bob's device is within range
    When proximity is verified
    Then verification should succeed

  @integration @proximity
  Scenario: Proximity challenge and response
    Given Alice's device emits a proximity challenge
    When Bob's device responds
    Then the response should be verified successfully

  @integration @proximity @error
  Scenario: Proximity fails when device is too far
    Given Bob's device is beyond the maximum range
    When proximity verification is attempted
    Then it should fail with TooFar error

  @integration @error
  Scenario: Discovery failure handling
    Given BLE discovery encounters an error
    When Alice attempts to scan
    Then the error should be handled gracefully

  @integration @error
  Scenario: Connection requires exchange token
    Given a discovered device without an exchange token
    When Alice attempts to connect
    Then the connection should be refused

  @integration @error
  Scenario: Cannot exchange without connection
    Given Alice has not connected to Bob
    When Alice attempts to read peer data
    Then it should fail because no connection exists

  @integration
  Scenario: Session state serialization roundtrip
    Given a BLE session in a specific state
    When the state is serialized to JSON and deserialized
    Then the state should be preserved

  # --- BLE Property-Based Tests ---

  @proptest @crypto
  Scenario: Encrypt-decrypt roundtrip preserves arbitrary data
    Given arbitrary plaintext data between 0 and 10KB
    When it is encrypted and decrypted
    Then the output should match the original plaintext

  @proptest @crypto @security
  Scenario: Any single byte flip in ciphertext fails decryption
    Given encrypted data
    When any single byte in the ciphertext is flipped
    Then decryption should fail

  @proptest @chunking
  Scenario: Chunking and reassembly preserves data
    Given arbitrary data between 1 and 15KB and a variable MTU
    When the data is chunked and reassembled
    Then the output should match the original data

  @proptest @adversarial
  Scenario: Empty display name roundtrips correctly
    Given a contact card with an empty display name
    When the card is serialized and deserialized
    Then the empty display name should be preserved

  @proptest @adversarial
  Scenario: Unicode display name roundtrips correctly
    Given a contact card with emoji, CJK, Arabic, and combining characters
    When the card is serialized and deserialized
    Then the unicode display name should be preserved exactly

  @proptest @adversarial
  Scenario: Null bytes in fields roundtrip correctly
    Given a contact card with null bytes in field keys and values
    When the card is serialized and deserialized
    Then the fields with null bytes should be preserved

  @proptest @adversarial
  Scenario: Maximum size avatar roundtrips correctly
    Given a contact card with a 16KB avatar
    When the card is serialized and deserialized
    Then the avatar data should be preserved

  @proptest @adversarial @security
  Scenario: Truncated handshake packet is rejected
    Given a truncated 50-byte KeyOffer packet
    When the packet is processed
    Then it should be rejected as invalid

  # --- BLE Rollback ---

  @rollback
  Scenario: Rollback clears pending contact data
    Given a pending contact has been recorded
    When rollback is called for that contact
    Then the pending data should be cleared

  @rollback
  Scenario: Rollback on nonexistent contact is a no-op
    Given no pending contact exists for a given ID
    When rollback is called for that ID
    Then it should succeed without error

  @rollback
  Scenario: Commit returns pending data and removes it
    Given a pending contact has been recorded
    When commit is called
    Then the pending data should be returned
    And the pending entry should be removed

  @rollback @error
  Scenario: Commit on nonexistent contact returns error
    Given no pending contact exists for a given ID
    When commit is called for that ID
    Then it should return an InvalidState error

  @rollback
  Scenario: Rollback all clears everything
    Given multiple pending contacts have been recorded
    When rollback_all is called
    Then all pending data should be cleared

  @rollback
  Scenario: Default rollback manager is empty
    When a new BLE rollback manager is created
    Then it should have no pending data

  # --- BLE Chunking ---

  @chunking
  Scenario: Small payload creates single chunk
    Given a small BLE payload
    When it is chunked
    Then it should produce a single chunk
    And the chunk should contain the correct header and payload

  @chunking
  Scenario: Large payload splits into multiple chunks
    Given a 500-byte BLE payload
    When it is chunked with a limited MTU
    Then it should produce multiple chunks
    And each chunk header should contain the correct total_chunks

  @chunking
  Scenario: Chunking and reassembly roundtrip
    Given a 2000-byte BLE payload
    When it is chunked and reassembled
    Then the reassembled data should match the original

  @chunking
  Scenario: Out-of-order reassembly
    Given chunks received in reverse order
    When they are reassembled
    Then the result should match the original data

  @chunking
  Scenario: Duplicate chunk is idempotent
    Given a chunk has already been received
    When the same chunk is received again
    Then the received count should not increment

  @chunking
  Scenario: Incomplete reassembly returns nothing
    Given not all chunks have been received
    When reassembly is attempted
    Then it should return no result

  @chunking @error
  Scenario: Chunk index out of range returns nothing
    Given a chunked payload
    When a chunk beyond the total is requested
    Then it should return nothing
