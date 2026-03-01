# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @network
Feature: Noise Protocol Inner Encryption
  As a Vauchi user
  I want an additional encryption layer between my client and the relay
  So that my routing metadata is protected even if TLS is compromised

  Background:
    Given I have an existing identity
    And the relay supports Noise protocol (v2)

  # ============================================================
  # Handshake
  # ============================================================

  @handshake @implemented
  Scenario: Noise NK handshake with relay
    Given I know the relay's static X25519 public key
    When I initiate a Noise NK handshake
    Then I should send a 48-byte handshake message (-> e, es)
    And the relay should respond with its handshake reply
    And a shared transport session should be established

  @handshake @implemented
  Scenario: V2 connection uses magic bytes prefix
    When I initiate a v2 connection to the relay
    Then the first message should start with bytes [0x00, 'V', '2']
    And the handshake message should follow the magic prefix

  @handshake @implemented
  Scenario: Handshake fails with wrong relay key
    Given I have an incorrect public key for the relay
    When I attempt the Noise NK handshake
    Then the handshake should fail
    And no transport session should be established
    And I should see a security error

  @handshake @implemented
  Scenario: Relay public key parsed from URL fragment
    Given the relay URL is "wss://relay.example.com#<base64url-encoded-32-byte-key>"
    When I parse the relay's Noise public key
    Then I should extract the 32-byte X25519 public key from the URL fragment
    And the key should be base64url-decoded

  @handshake @implemented
  Scenario: URL without fragment has no Noise key
    Given the relay URL is "wss://relay.example.com"
    When I try to parse a Noise public key
    Then parsing should return None
    And the connection should proceed without Noise encryption

  @handshake @implemented
  Scenario: Invalid Noise key in URL fragment is rejected
    Given the relay URL has an invalid base64 fragment
    When I try to parse a Noise public key
    Then parsing should fail
    And I should see a key format error

  @handshake @implemented
  Scenario: Wrong-length key in URL fragment is rejected
    Given the relay URL fragment decodes to fewer than 32 bytes
    When I try to parse a Noise public key
    Then parsing should fail
    And I should see a key length error

  # ============================================================
  # Transport Encryption
  # ============================================================

  @transport @implemented
  Scenario: Messages encrypted after handshake
    Given a Noise transport session is established
    When I send a message through the transport
    Then the message should be encrypted with ChaCha20-Poly1305
    And a 16-byte MAC should be appended
    And the ciphertext should be different from the plaintext

  @transport @planned
  Scenario: Messages decrypted by recipient
    Given a Noise transport session is established
    When the relay sends me an encrypted message
    Then I should decrypt it successfully
    And the plaintext should match what the relay sent

  @transport @implemented
  Scenario: Corrupted ciphertext is detected
    Given a Noise transport session is established
    When I receive a message with corrupted ciphertext
    Then decryption should fail
    And I should see an integrity error
    And the message should be discarded

  @transport @implemented
  Scenario: Sequential messages use advancing nonces
    Given a Noise transport session is established
    When I send multiple messages
    Then each message should use a unique nonce
    And replaying an earlier message should fail decryption

  # ============================================================
  # Noise Pattern Properties
  # ============================================================

  @pattern @planned
  Scenario: Noise NK provides initiator anonymity
    Given the Noise pattern is "Noise_NK_25519_ChaChaPoly_BLAKE2s"
    Then the initiator (client) should remain anonymous to passive observers
    And only the relay's static key is authenticated
    And the client does not reveal its static key

  @pattern @planned
  Scenario: Defense-in-depth layering
    Given TLS is the outer transport encryption
    And Noise is the inner transport encryption
    Then compromising TLS alone should not reveal routing metadata
    And compromising the Noise layer alone should not reveal data in transit
    And both layers must be compromised to observe plaintext

  # ============================================================
  # Backward Compatibility
  # ============================================================

  @compat @implemented
  Scenario: Client connects to relay without Noise support
    Given the relay does not support v2 protocol
    When I connect to the relay
    Then the connection should fall back to TLS-only
    And sync should proceed normally
    And I should be informed that inner encryption is not active

  @compat @implemented
  Scenario: Relay optionally requires Noise for v2+ clients
    Given the relay is configured to require Noise encryption
    When a client connects without the v2 magic prefix
    Then the relay may reject the connection
    And the client should retry with Noise enabled
