# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security
Feature: Security
  As a Vauchi user
  I want my sensitive data to be protected
  So that attackers cannot access my information

  Background:
    Given I have an existing identity
    And I have sensitive contact information

  # End-to-End Encryption

  @e2e @implemented
  Scenario: Contact cards are encrypted at rest
    Given I have a contact card stored locally
    Then the contact card should be encrypted with XChaCha20-Poly1305
    And the encryption key should be derived from my master key
    And plaintext contact data should never be written to disk

  @e2e @implemented
  Scenario: Contact cards are encrypted in transit
    Given I am sending an update to Bob
    Then the update should be encrypted with our shared key
    And relay nodes should only see encrypted blobs
    And no plaintext should leave my device

  @e2e @implemented
  Scenario: Shared key derivation via X3DH
    Given I am establishing a connection with Bob
    When X3DH key exchange completes
    Then we should have a shared secret
    And the shared secret should be unique to us
    And the shared secret should be unpredictable to observers

  @e2e @implemented
  Scenario: Forward secrecy via Double Ratchet
    Given Bob and I have an established shared key
    When we exchange multiple updates
    Then keys should ratchet forward after each exchange
    And compromising a future key should not reveal past messages
    And compromising a past key should not reveal future messages

  # Private Key Protection

  @keys @implemented
  Scenario: Private keys stored in secure enclave
    Given my device has a secure enclave
    Then my private keys should be stored in the secure enclave
    And private keys should never be extractable
    And cryptographic operations should happen within the enclave

  @keys @implemented
  Scenario: Private keys on devices without secure enclave
    Given my device has no secure enclave
    Then private keys should be encrypted with device-specific key
    And the encrypted keys should be stored in app-private storage
    And memory containing keys should be locked from swapping

  @keys @implemented
  Scenario: Private key memory protection
    Given cryptographic operations are in progress
    When the operation completes
    Then sensitive key material should be zeroed in memory
    And garbage collection should not leak key material

  @keys @implemented
  Scenario: Private keys never exported in plaintext
    Given I am exporting my identity backup
    Then the backup should be encrypted with my password
    And plaintext private keys should never leave the device
    And the export process should use secure memory

  # Authentication & Verification

  @auth @implemented
  Scenario: Contact card signatures verified
    Given I receive a contact card from Bob
    When I process the contact card
    Then I should verify the signature with Bob's public key
    And unsigned cards should be rejected
    And cards signed by wrong key should be rejected

  @auth @implemented
  Scenario: Update signatures verified
    Given I receive an update from Bob
    When I process the update
    Then I should verify the signature matches Bob's identity
    And updates with invalid signatures should be rejected

  @auth @implemented
  Scenario: Man-in-the-middle detection during exchange
    Given I am exchanging contacts with Bob
    And an attacker is attempting MITM
    When key fingerprints are compared
    Then the mismatch should be detected
    And the exchange should be aborted
    And I should see a security warning

  @auth @implemented
  Scenario: Verify contact fingerprint manually
    Given I have Bob in my contacts
    When I view Bob's security details
    Then I should see Bob's public key fingerprint
    And I should be able to verify it matches Bob's display
    And I should be able to mark Bob as "verified"

  # Attack Prevention

  @attacks @implemented
  Scenario: Replay attack prevention
    Given an attacker captures an encrypted update
    When the attacker replays the update later
    Then I should detect the replay via timestamp/nonce
    And the replayed update should be rejected
    And a security event should be logged

  @attacks @implemented
  Scenario: Relay attack prevention on BLE
    Given an attacker is relaying BLE signals
    When I attempt proximity-verified exchange
    Then the distance-bounding protocol should detect the attack
    And the exchange should be blocked
    And I should see "Possible relay attack detected"

  @attacks @implemented
  Scenario: QR code screenshot attack prevention
    Given someone screenshots my exchange QR code
    When they try to scan it remotely
    Then audio proximity verification should fail
    And the exchange should be blocked
    And my contact should not be shared

  @attacks @implemented
  Scenario: Brute force protection on backup password
    Given an attacker has my encrypted backup
    When they attempt to brute force the password
    Then key derivation should be computationally expensive (Argon2id)
    And each attempt should take significant time
    And a strong password should be practically uncrackable

  @attacks @implemented
  Scenario: Server cannot access plaintext
    Given my data passes through relay nodes
    Then relay nodes should only see encrypted blobs
    And relay nodes should have no access to encryption keys
    And a compromised relay should learn nothing about my data

  # Data Protection

  @data @planned
  Scenario: Sensitive data classification
    Given I have various types of data
    Then private keys should be classified as "highly sensitive"
    And contact information should be classified as "sensitive"
    And public keys should be classified as "semi-public"
    And each classification should have appropriate protections

  @data @implemented
  Scenario: Local database encryption
    Given I have local data storage
    Then the database should be encrypted with XChaCha20-Poly1305
    And the encryption key (SMK) should be stored in platform secure storage
    And database files should be unreadable without the key

  @data @implemented
  Scenario: Memory dump protection
    Given sensitive data is in memory
    Then memory should be protected from dumps
    And crash reports should not contain sensitive data
    And debugging should not expose sensitive data

  @data @implemented
  Scenario: Secure deletion of data
    Given I delete a contact
    When the deletion is processed
    Then data should be securely overwritten
    And deleted data should be unrecoverable
    And file system should not retain deleted content

  # Access Control

  @access @planned
  Scenario: App lock with biometrics
    Given I have enabled app lock
    When I open Vauchi
    Then I should be prompted for biometric authentication
    And only successful authentication should grant access
    And data should remain encrypted until authenticated

  @access @planned
  Scenario: App lock with PIN
    Given I have enabled PIN lock
    When I open Vauchi
    Then I should be prompted for my PIN
    And incorrect PIN should deny access
    And multiple failures should trigger lockout

  @access @planned
  Scenario: Auto-lock on background
    Given I have auto-lock enabled
    When the app goes to background for 5 minutes
    Then the app should lock automatically
    And reopening should require authentication

  @access @planned
  Scenario: Screen capture prevention
    Given Vauchi is displaying sensitive data
    Then screenshots should be blocked
    And screen recording should be blocked
    And the app should appear blank in app switcher

  # Audit & Logging

  @audit @implemented
  Scenario: Security events logged
    Given a security-relevant event occurs
    Then the event should be logged locally
    And the log should include timestamp and event type
    And logs should not contain sensitive data
    And logs should be available for security review

  @audit @planned
  Scenario: View security log
    When I access the security log
    Then I should see recent security events
    And I should see failed exchange attempts
    And I should see blocked contacts
    And I should see signature verification failures

  @audit @implemented
  Scenario: Export security log
    Given I need to investigate a security issue
    When I export the security log
    Then a sanitized log file should be generated
    And no private keys should be in the export
    And no contact details should be in the export

  # Security Notifications

  @notifications @planned
  Scenario: Notification on suspicious activity
    Given suspicious activity is detected
    Then I should receive an in-app notification
    And the notification should describe the activity
    And I should have options to review or dismiss

  @notifications @planned
  Scenario: Notification on contact key change
    Given Bob's identity key has changed
    When I detect the change
    Then I should see "Bob's security key has changed"
    And sync with Bob should pause
    And I should be prompted to re-verify Bob

  @notifications @planned
  Scenario: Notification on blocked exchange attempt
    Given I have blocked Eve
    When Eve attempts to exchange contacts
    Then I should be notified of the attempt
    And I should see when and where it occurred

  # Cryptographic Details

  @crypto @implemented
  Scenario: Correct algorithms used
    Then identity signatures should use Ed25519
    And key exchange should use X25519
    And symmetric encryption should use XChaCha20-Poly1305
    And key derivation should use Argon2id
    And hashing should use SHA-256

  @crypto @implemented
  Scenario: Sufficient key lengths
    Then Ed25519 keys should be 256 bits
    And X25519 keys should be 256 bits
    And symmetric keys should be 256 bits
    And random values should use cryptographically secure RNG

  @crypto @implemented
  Scenario: No weak cryptography
    Then MD5 should not be used anywhere
    And SHA1 should not be used for security
    And DES/3DES should not be used
    And RSA should not be used (prefer Ed25519/X25519)
    And no custom cryptographic algorithms should be implemented

  # Platform Edge Cases (dissolved from platform_edge_cases.feature 2026-03-17)

  # WebView scenario removed — desktop app archived per ADR-027 (2026-03).
  # Native apps (macOS SwiftUI, Linux GTK4, Linux Qt6, Windows WinUI3) do not use WebView.
  # See: audit 2026-03-23, finding H2.

  @platform-edge-case @desktop @planned
  Scenario: Native desktop apps use platform secure storage
    Given a native desktop app (macOS, Linux, Windows)
    Then cryptographic keys should use platform keychain/keyring
    And external links should open in system browser
    And no embedded web content should execute

  @platform-edge-case @android @backup @planned
  Scenario: Android auto-backup handles sensitive data
    Given Android auto-backup is enabled
    Then encryption keys should be excluded from backup
    And backup should include safe data only
    And restoration should prompt for re-authentication
