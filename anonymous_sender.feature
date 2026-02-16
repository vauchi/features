# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@privacy @network
Feature: Anonymous Sender Protocol
  As a Vauchi user
  I want my messages to use rotating anonymous sender identifiers
  So that relays cannot correlate my messages to my real identity over time

  Background:
    Given I have an existing identity
    And I have exchanged contacts with Bob

  # ============================================================
  # Anonymous ID Generation
  # ============================================================

  @generation
  Scenario: Sender ID derived from shared key and epoch
    When I send an update to Bob
    Then the sender identifier should be derived from our shared key
    And the derivation should include the current epoch
    And the relay should not see my real identity

  @generation
  Scenario: Anonymous ID is deterministic for same epoch
    Given the current epoch has not changed
    When I compute my anonymous sender ID for Bob twice
    Then both IDs should be identical

  @generation
  Scenario: Anonymous ID changes every epoch
    Given I compute my anonymous sender ID for Bob
    When the epoch rotates (after 1 hour)
    And I compute my anonymous sender ID again
    Then the two IDs should be different

  @generation
  Scenario: Different contacts produce different anonymous IDs
    When I compute my anonymous sender ID for Bob
    And I compute my anonymous sender ID for Carol
    Then the two IDs should be different
    And the relay cannot determine they come from the same sender

  @generation
  Scenario: Anonymous ID is 32 bytes
    When I compute my anonymous sender ID
    Then the ID should be exactly 32 bytes
    And it should be derived via HKDF

  # ============================================================
  # Epoch Rotation
  # ============================================================

  @epoch
  Scenario: Epoch duration is one hour
    Given the current Unix timestamp is T
    Then the current epoch should be T / 3600
    And the epoch should change every 3600 seconds

  @epoch
  Scenario: Epoch boundary handling
    Given the current time is 1 second before an epoch boundary
    When 2 seconds pass
    Then the epoch should have incremented by 1
    And my anonymous sender ID should have changed

  # ============================================================
  # Sender Resolution
  # ============================================================

  @resolution
  Scenario: Recipient resolves anonymous sender to contact
    Given Bob sends me an update with an anonymous sender ID
    When I receive the update
    Then I should try each contact's shared key to resolve the sender
    And I should identify the sender as Bob

  @resolution
  Scenario: Resolution tolerates previous epoch for clock skew
    Given Bob's clock is slightly behind mine
    And Bob sends an update using the previous epoch's ID
    When I receive the update
    Then I should try both current and previous epoch
    And I should still identify the sender as Bob

  @resolution
  Scenario: Resolution fails for unknown sender
    Given I receive an update with an unrecognizable anonymous ID
    When I try all contact shared keys for current and previous epochs
    Then resolution should fail
    And the update should be discarded

  # ============================================================
  # Privacy Properties
  # ============================================================

  @privacy
  Scenario: Relay cannot link sender across epochs
    Given the relay observes my anonymous ID in epoch N
    And the relay observes my anonymous ID in epoch N+1
    Then the relay should not be able to determine they are the same sender

  @privacy
  Scenario: Relay cannot link sender across recipients
    Given the relay observes my anonymous ID when sending to Bob
    And the relay observes my anonymous ID when sending to Carol
    Then the relay should not be able to correlate the two senders

  @privacy
  Scenario: Derivation context prevents cross-protocol confusion
    Given the HKDF context string is "Vauchi_AnonymousSender_v2"
    Then anonymous IDs should not collide with other HKDF-derived values
    And the context should be fixed and non-configurable
