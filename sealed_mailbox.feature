# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@privacy @network @sp-33
Feature: Sealed Mailbox Tokens (SP-33)
  As a Vauchi user
  I want the relay to not know who receives my messages
  So that no one can build a social graph from message routing metadata

  PRINCIPLES ALIGNMENT:
  - Privacy is a right: Relay sees neither sender (SP-32) nor recipient (SP-33)
  - Zero Knowledge: Relay routes by opaque daily-rotating tokens, not identity
  - Trust earned in person: Tokens derived from shared keys established in person
  - Audited crypto only: HKDF-SHA256 derivation, same pattern as anonymous sender

  Design: _private/docs/plans/2026-03-22-sealed-mailbox-tokens-design.md

  Background:
    Given I have an existing identity
    And I have exchanged contacts with Bob

  # ============================================================
  # Token Derivation
  # ============================================================

  @derivation @planned
  Scenario: Contact mailbox token derived from shared key
    Given Bob and I share a key from our exchange
    When I compute Bob's mailbox token for today
    Then the token should be derived via HKDF-SHA256
    And the derivation should use "Vauchi_Mailbox_v1" as domain separator
    And the token should include the daily epoch (unix_timestamp / 86400)
    And the token should be exactly 32 bytes

  @derivation @planned
  Scenario: Self mailbox token derived from master seed
    Given I have a master seed on my device
    When I compute my self-mailbox token for device sync
    Then the token should be derived via HKDF-SHA256
    And the derivation should use "Vauchi_DeviceSync_v1" as domain separator
    And all my linked devices should derive the same token

  @derivation @planned
  Scenario: Tokens rotate daily
    Given I compute Bob's mailbox token on day N
    When day N+1 begins
    And I compute Bob's mailbox token again
    Then the two tokens should be different
    And the relay cannot link messages across days

  @derivation @planned
  Scenario: Different contacts produce different tokens
    Given I have contacts Bob and Carol
    When I compute mailbox tokens for both
    Then Bob's token and Carol's token should differ
    And the relay cannot determine they belong to the same sender

  # ============================================================
  # Registration and Routing
  # ============================================================

  @registration @planned
  Scenario: Register mailbox tokens on connect
    Given I connect to the relay
    Then I should register mailbox tokens for current and previous day
    And the registration should be padded to 256 tokens
    And the relay should not know how many real contacts I have

  @registration @planned
  Scenario: Historical token registration after offline period
    Given I was offline for 5 days
    When I reconnect to the relay
    Then I should register tokens for all 5 days plus today
    And the relay should deliver stored blobs matching any registered token
    And I should deregister historical tokens after catching up

  @routing @planned
  Scenario: Messages routed by mailbox token
    Given I send a card update to Bob
    Then the EncryptedUpdate.recipient_id should be Bob's daily mailbox token
    And the relay should store the blob under that token
    And the relay should not see Bob's identity

  @routing @planned
  Scenario: Device sync routed by self-token
    Given I have 2 linked devices
    When device A sends a sync message
    Then the message should be routed via the self-mailbox token
    And device B should receive it via the same token
    And the relay should not see my identity

  # ============================================================
  # Privacy Properties
  # ============================================================

  @privacy @planned
  Scenario: Relay cannot link recipient across days
    Given the relay observes token T1 on day N
    And the relay observes token T2 on day N+1
    Then the relay should not be able to determine they belong to the same recipient

  @privacy @planned
  Scenario: Token set padded to hide contact count
    Given I have 50 contacts
    When I register tokens on connect
    Then 256 tokens should be registered (50 real + 206 padding)
    And the relay cannot distinguish real tokens from padding

  @privacy @planned
  Scenario: Combined with SP-32 — relay sees neither sender nor recipient
    Given Alice sends a card update to Bob
    Then the sender_id is an anonymous hourly token (SP-32)
    And the recipient_id is a daily mailbox token (SP-33)
    And the relay sees only opaque tokens and encrypted ciphertext

  # ============================================================
  # Backward-Compat Cleanup (v0.1 alpha)
  # ============================================================

  @cleanup @planned
  Scenario: Noise NK v2 is mandatory
    Given a client connects to the relay
    Then the Noise NK handshake must complete before any messages
    And plaintext (v1) connections should be rejected

  @cleanup @planned
  Scenario: AccountRevoked verified client-side
    Given Bob revokes his account
    When Alice receives the revocation via her mailbox token
    Then Alice should verify the Ed25519 signature client-side
    And the relay should not perform signature verification
