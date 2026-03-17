# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @shred
Feature: Pre-signed Operations
  As a Vauchi user
  I want critical messages to be pre-signed at identity creation
  So that emergency account deletion can notify contacts and relays
  even after my signing keys have been destroyed

  Background:
    Given I have an existing identity

  # ============================================================
  # Pre-signed Message Generation
  # ============================================================

  @generation @implemented
  Scenario: Pre-signed messages created at identity setup
    When I create a new identity
    Then pre-signed shred messages should be generated
    And the messages should include a relay purge request
    And the messages should include an account deletion notice
    And the messages should be stored locally

  @generation @implemented
  Scenario: Pre-signed purge request contains required fields
    Given pre-signed messages have been generated
    When I inspect the purge request
    Then it should contain my public key
    And it should contain an Ed25519 signature
    And it should contain a one-time purge token (32 bytes)
    And it should contain a timestamp

  @generation @implemented
  Scenario: Pre-signed deletion notice contains required fields
    Given pre-signed messages have been generated
    When I inspect the deletion notice
    Then it should contain my public key
    And it should contain an Ed25519 signature
    And it should contain the deletion stage
    And it should contain a timestamp

  @generation @implemented
  Scenario: Deletion notice stages
    Given pre-signed messages have been generated
    Then the deletion notice should support stages:
      | Stage     |
      | Pending   |
      | Confirmed |
      | Cancelled |

  # ============================================================
  # Storage
  # ============================================================

  @storage @implemented
  Scenario: Pre-signed messages stored unencrypted
    Given pre-signed messages have been generated
    Then the messages should be stored without encryption
    And this ensures they remain accessible after SMK destruction
    And the storage file should be in the data directory

  @storage @implemented
  Scenario: Pre-signed messages survive app restarts
    Given pre-signed messages have been generated
    When I restart the application
    Then the pre-signed messages should still be loadable
    And their signatures should still be valid

  # ============================================================
  # Refresh
  # ============================================================

  @refresh @implemented
  Scenario: Refresh pre-signed messages periodically
    Given pre-signed messages were generated a week ago
    When the refresh mechanism runs
    Then new pre-signed messages should be generated
    And the purge token should be different from the previous one
    And the old messages should be replaced

  @refresh @implemented
  Scenario: Refresh generates new purge token for replay prevention
    Given I have existing pre-signed messages with purge token A
    When I refresh the pre-signed messages
    Then the new purge token should differ from token A
    And the relay should only accept the latest token

  # ============================================================
  # Cryptographic Verification
  # ============================================================

  @crypto @implemented
  Scenario: Relay can verify purge request signature
    Given I have a pre-signed purge request
    Then the signature should be valid over (public_key || purge_token || timestamp)
    And the relay should accept the signature using my public key

  @crypto @implemented
  Scenario: Contact can verify deletion notice signature
    Given I have a pre-signed deletion notice
    Then the signature should be valid over the serialized notice
    And contacts should accept the signature using my public key

  @crypto @implemented
  Scenario: Tampered pre-signed message is rejected
    Given I have a pre-signed purge request
    When the purge token is modified
    Then the signature verification should fail
    And the relay should reject the request

  # ============================================================
  # Integration with Panic Shred
  # ============================================================

  @panic @implemented
  Scenario: Pre-signed messages used during panic shred
    Given I trigger a panic shred
    Then the pre-signed purge request should be sent to the relay
    And the pre-signed deletion notice should be broadcast to contacts
    And these messages should be sent BEFORE keys are destroyed

  @panic @implemented
  Scenario: Pre-signed messages remain valid after key destruction
    Given panic shred has destroyed my signing keys
    Then contacts who received the deletion notice can still verify it
    And the relay can still verify the purge request
    # Because the signatures were created before destruction
