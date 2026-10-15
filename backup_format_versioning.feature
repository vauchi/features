# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@identity @backup
Feature: Backup Format Versioning
  As a Vauchi user
  I want backup files to use versioned formats
  So that backup files use strong, versioned cryptography with clear format detection

  Background:
    Given the Vauchi application is installed
  # ============================================================
  # Current Format (v2)
  # ============================================================

  @v2 @implemented
  Scenario: New backups use v2 format
    Given I have an existing identity
    When I create an identity backup with password "SecureP@ssw0rd!"
    Then the backup should use format version 0x02
    And the key should be derived using Argon2id
    And the data should be encrypted with XChaCha20-Poly1305

  @v2 @implemented
  Scenario: V2 backup uses OWASP-recommended Argon2id parameters
    When I create a v2 backup
    Then Argon2id should use memory cost 64 MB
    And Argon2id should use time cost 3 iterations
    And Argon2id should use parallelism 4
    And the derived key should be 32 bytes

  @v2 @implemented
  Scenario: V2 backup includes salt
    When I create a v2 backup
    Then a random salt should be generated
    And the salt should follow the version tag byte and precede the ciphertext
    And the salt should be used for Argon2id key derivation

  @v2 @implemented
  Scenario: Restore v2 backup with correct password
    Given I have a v2 backup file
    When I restore the backup with the correct password
    Then my identity should be fully restored
    And my master seed should be recovered
    And my display name should match the original

  @v2 @implemented
  Scenario: Restore v2 backup with wrong password
    Given I have a v2 backup file
    When I try to restore the backup with the wrong password
    Then decryption should fail
    And I should see an authentication error
    And no partial data should be exposed
  # ============================================================
  # Version Detection
  # ============================================================

  @detection @implemented
  Scenario: Version byte identifies backup format
    Given I have a backup file
    When the first byte is 0x02
    Then the backup should be treated as v2 format

  @detection @implemented
  Scenario: Unknown version byte is rejected
    Given I have a backup file
    When the first byte is not a known version (0x02 identity, 0x03 legacy full, 0x06 password snapshot)
    Then restoration should fail with RestoreFailed

  @security @implemented
  Scenario: Identity backup carries no plaintext key material
    When I create an identity backup
    Then the backup should contain the encrypted master seed
    And all keypairs should be re-derivable from the seed
    And no plaintext key material should appear in the backup file

  @security @implemented
  Scenario: Corrupted backup is detected
    Given I have a valid v2 backup file
    When the backup data is corrupted
    And I try to restore it
    Then the AEAD authentication should fail
    And no partial data should be returned
  # ============================================================
  # Legacy low-level full backup (v3)
  # ============================================================

  @v3 @implemented
  Scenario: Full backup includes identity, contacts, own card, and labels
    Given I have an existing identity with contacts and labels
    When I create a legacy full backup with the low-level v3 API and a password
    Then the backup should use format version 0x03
    And it should include my identity and display name
    And it should include my contacts (imported and exchanged)
    And it should include my own contact card and labels
    And nothing should be readable without the password

  @v6 @implemented
  Scenario: Password backup preserves sharing and contact state
    Given I have contacts, groups and explicit per-contact sharing choices
    And some contacts are archived, blocked or ignored
    When I export a password full backup
    Then its outer format version should be 0x06
    When I restore it onto a fresh installation and restart the application
    Then my identity, own card and contacts should match the snapshot
    And all group metadata and explicit allow and deny choices should match
    And archived, blocked and ignored contact state should match
    And old v3 readers should reject the richer backup

  @v6 @implemented
  Scenario: Full backup import is atomic
    Given I have a fresh installation
    When a password full backup contains invalid state or cannot be committed
    Then no restored identity, card, contacts or groups should remain
    And a later valid restore should succeed

  @v6 @implemented
  Scenario: Restored contacts continue exchanging updates
    Given two CLI installations have exchanged contacts
    And one has a password full backup with sharing choices
    When that installation is removed and restored from the backup
    And both people update their contact cards without a new exchange
    Then both should receive the exact updated shared values
    And explicitly hidden fields should remain absent

  @v3 @planned
  Scenario: Full backup is opt-in
    Given I have never opted in to full backup
    Then no contact or card data should be written to any backup file
    And only the identity backup should be offered by default

  @v3 @planned
  Scenario: Full backup can be unlocked via social recovery
    Given I have a full backup but lost my password
    When I complete social recovery with my trusted contacts
    Then I should be able to unlock the full backup
    # Alternative under consideration: back up only identity + connection
    # identities and re-fetch card data from contacts after recovery —
    # more private, but harder (needs contacts online).
