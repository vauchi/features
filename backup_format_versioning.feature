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
    When the first byte is not 0x02
    Then restoration should fail with RestoreFailed

  @security @implemented
  Scenario: Backup contains only the master seed
    When I create a backup
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
