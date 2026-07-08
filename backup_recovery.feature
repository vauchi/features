# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@identity @backup @recovery @guardian
Feature: Guardian Key Shard Backup Recovery
  As a Vauchi user
  I want to back up my data with guardian key shards
  So that I can recover my identity and data even if I lose my device,
     without any single guardian being able to decrypt my backup alone

  Background:
    Given the Vauchi application is installed
    And I have an existing identity
  # ============================================================
  # Guardian backup setup
  # ============================================================

  @v4 @guardian @setup @planned
  Scenario: Create a v4 guardian backup with default threshold
    Given I have 3 exchanged contacts: Bob, Charlie, and Dave
    When I create a v4 guardian backup with my 3 contacts
    Then the backup should use format version 0x04
    And the backup key should be split into 3 shards
    And the default threshold should be 2 guardians
    And each shard should be sealed to one guardian's X25519 public key
    And I should receive one sealed share per guardian

  @v4 @guardian @setup @planned
  Scenario: Create a v4 guardian backup with a custom threshold
    Given I have 5 exchanged contacts
    When I create a v4 guardian backup with threshold 3 of 5 guardians
    Then the backup key should be split into 5 shards
    And the threshold should be 3 guardians
    And recovery should require at least 3 of the 5 guardians

  @v4 @guardian @setup @planned
  Scenario: Reject guardian backup with threshold below 2
    Given I have 3 exchanged contacts
    When I try to create a v4 guardian backup with threshold 1 of 3 guardians
    Then the operation should fail with "Guardian threshold must be at least 2"
    And no backup should be created

  @v4 @guardian @setup @planned
  Scenario: Reject guardian backup with threshold greater than guardian count
    Given I have 3 exchanged contacts
    When I try to create a v4 guardian backup with threshold 4 of 3 guardians
    Then the operation should fail with "Threshold cannot exceed guardian count"
    And no backup should be created

  @v4 @guardian @setup @planned
  Scenario: Reject guardian backup with more than 10 guardians
    Given I have 11 exchanged contacts
    When I try to create a v4 guardian backup with threshold 2 of 11 guardians
    Then the operation should fail with "Guardian count cannot exceed 10"
    And no backup should be created

  @v4 @guardian @setup @planned
  Scenario: Only exchanged contacts can be guardians
    Given I have 1 imported contact: Mallory
    And I have 1 exchanged contact: Bob
    When I try to create a v4 guardian backup with Mallory and Bob as guardians
    Then the operation should fail with "Guardians must be exchanged contacts"
    And no backup should be created
  # ============================================================
  # Guardian backup recovery
  # ============================================================

  @v4 @guardian @recovery @planned
  Scenario: Recover v4 guardian backup with threshold shares
    Given I have a v4 guardian backup with 3 guardians and threshold 2
    When 2 guardians decrypt and return their sealed shares
    And I reconstruct the backup key from the 2 shares
    And I decrypt the v4 guardian backup
    Then my identity should be fully restored
    And my contacts should be restored
    And my labels should be restored

  @v4 @guardian @recovery @planned
  Scenario: Recovery fails with fewer than threshold shares
    Given I have a v4 guardian backup with 3 guardians and threshold 2
    When only 1 guardian decrypts and returns their sealed share
    And I try to reconstruct the backup key
    Then the operation should fail with "Insufficient shares for threshold"
    And the backup key should not be reconstructed

  @v4 @guardian @recovery @planned
  Scenario: Recovery fails with a wrong guardian share
    Given I have a v4 guardian backup with 3 guardians and threshold 2
    When 1 valid guardian returns their sealed share
    And 1 attacker substitutes an unrelated sealed share
    And I try to reconstruct the backup key
    Then the operation should fail with "Share verification failed"
    And the backup key should not be reconstructed

  @v4 @guardian @recovery @planned
  Scenario: Recovery fails with corrupted backup blob
    Given I have a v4 guardian backup with 3 guardians and threshold 2
    When 2 guardians decrypt and return their sealed shares
    And I corrupt the backup blob
    And I try to decrypt the v4 guardian backup
    Then the AEAD authentication should fail
    And no partial data should be returned
  # ============================================================
  # Guardian revocation and re-keying
  # ============================================================

  @v4 @guardian @revocation @planned
  Scenario: Replacing a guardian re-keys the backup
    Given I have a v4 guardian backup with guardians Bob, Charlie, and Dave
    When I revoke Dave and add Eve as a new guardian
    Then a new backup key should be generated
    And the backup should be re-encrypted with the new key
    And old sealed shares should be invalidated
    And Eve should receive a sealed share for the new key
    And Dave's old sealed share should not decrypt the new backup

  @v4 @guardian @revocation @planned
  Scenario: Adding a guardian increases shard count and re-keys
    Given I have a v4 guardian backup with 3 guardians and threshold 2
    When I add a 4th guardian, Eve
    Then the backup key should be regenerated
    And the backup should be re-encrypted with the new key
    And 4 new sealed shares should be distributed
    And the threshold should remain 2 unless explicitly changed

  @v4 @guardian @revocation @planned
  Scenario: Removing a guardian below threshold is rejected
    Given I have a v4 guardian backup with 3 guardians and threshold 3
    When I try to remove one guardian without changing the threshold
    Then the operation should fail with "Guardian count below threshold"
    And the existing backup key and shares should remain valid
