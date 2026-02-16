# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@identity @backup
Feature: Backup Format Versioning
  As a Vauchi user
  I want backup files to use versioned formats
  So that new backups use stronger cryptography while old backups remain restorable

  Background:
    Given the Vauchi application is installed

  # ============================================================
  # Current Format (v2)
  # ============================================================

  @v2
  Scenario: New backups use v2 format
    Given I have an existing identity
    When I create an identity backup with password "SecureP@ssw0rd!"
    Then the backup should use format version 0x02
    And the key should be derived using Argon2id
    And the data should be encrypted with XChaCha20-Poly1305

  @v2
  Scenario: V2 backup uses OWASP-recommended Argon2id parameters
    When I create a v2 backup
    Then Argon2id should use memory cost 64 MB
    And Argon2id should use time cost 3 iterations
    And Argon2id should use parallelism 4
    And the derived key should be 32 bytes

  @v2
  Scenario: V2 backup includes salt
    When I create a v2 backup
    Then a random salt should be generated
    And the salt should follow the version tag byte and precede the ciphertext
    And the salt should be used for Argon2id key derivation

  @v2
  Scenario: Restore v2 backup with correct password
    Given I have a v2 backup file
    When I restore the backup with the correct password
    Then my identity should be fully restored
    And my master seed should be recovered
    And my display name should match the original

  @v2
  Scenario: Restore v2 backup with wrong password
    Given I have a v2 backup file
    When I try to restore the backup with the wrong password
    Then decryption should fail
    And I should see an authentication error
    And no partial data should be exposed

  # ============================================================
  # Legacy Format (v1)
  # ============================================================

  @v1 @legacy
  Scenario: Legacy backups are still restorable
    Given I have a legacy (v1) backup file
    When I restore the backup with the correct password
    Then my identity should be fully restored
    And the legacy format should be auto-detected

  @v1 @legacy
  Scenario: Legacy backup uses PBKDF2 key derivation
    Given I have a legacy backup file
    When the system decrypts it
    Then key derivation should use PBKDF2-HMAC-SHA256
    And PBKDF2 should use 100,000 iterations
    And decryption should use AES-256-GCM

  @v1 @legacy
  Scenario: Legacy backup format auto-detection
    Given I have a backup file without a v2 version byte
    When I attempt to restore it
    Then the system should detect it as a legacy format
    And fall back to PBKDF2 + AES-256-GCM decryption

  # ============================================================
  # Version Detection
  # ============================================================

  @detection
  Scenario: Version byte identifies backup format
    Given I have a backup file
    When the first byte is 0x02
    Then the backup should be treated as v2 format

  @detection
  Scenario: Unknown version byte falls back to legacy
    Given I have a backup file
    When the first byte is not 0x02
    Then the backup should be treated as legacy format
    And PBKDF2 + AES-256-GCM decryption should be attempted

  # ============================================================
  # Migration
  # ============================================================

  @migration
  Scenario: Restoring legacy backup and re-exporting creates v2
    Given I restore a legacy (v1) backup successfully
    When I create a new backup of the restored identity
    Then the new backup should use v2 format
    And the new backup should use Argon2id + XChaCha20-Poly1305
    And the original legacy backup should remain valid

  # ============================================================
  # Security Properties
  # ============================================================

  @security
  Scenario: V2 provides stronger protection than v1
    Given v2 uses Argon2id (memory-hard, timing-resistant)
    And v1 uses PBKDF2 (CPU-only, parallelizable)
    Then v2 should be more resistant to GPU-based brute force attacks
    And v2 should be more resistant to ASIC-based attacks

  @security
  Scenario: Backup contains only the master seed
    When I create a backup
    Then the backup should contain the encrypted master seed
    And all keypairs should be re-derivable from the seed
    And no plaintext key material should appear in the backup file

  @security
  Scenario: Corrupted backup is detected
    Given I have a valid v2 backup file
    When the backup data is corrupted
    And I try to restore it
    Then the AEAD authentication should fail
    And no partial data should be returned
