# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@gdpr @privacy @compliance
Feature: Privacy Compliance
  As a Vauchi user
  I want control over my personal data
  So that my privacy rights are respected

  Background:
    Given I have an identity with contacts and settings
  # ============================================================
  # Data Export
  # ============================================================

  @export @implemented
  Scenario: Export all my data
    When I go to Settings > Privacy > Export My Data
    And I confirm the export
    Then I should receive a downloadable file
    And the file should contain all my personal data
    And the file should be in a machine-readable format (JSON)

  @export @implemented
  Scenario: Export includes all data types
    When I export my data
    Then the export should include:
      | Data Type              | Included |
      | My contact card        | Yes      |
      | My contacts list       | Yes      |
      | My settings            | Yes      |
      | My device list         | Yes      |
      | My visibility labels   | Yes      |
      | Update history         | Yes      |
      | Recovery configuration | Yes      |
    And the export should NOT include contacts' private keys
    And the export should be encrypted with my key

  @export @implemented
  Scenario: Export requires authentication
    Given I request a data export
    Then I should be required to authenticate (PIN/biometric)
    And the export file should be encrypted
    And a notification should be sent to all my devices

  @export @implemented
  Scenario: Export works offline
    Given I am offline
    When I export my data
    Then the export should succeed for local data
    And I should be informed that relay data may be incomplete
  # ============================================================
  # Data Deletion
  # ============================================================

  @deletion @implemented
  Scenario: Delete my account
    When I go to Settings > Privacy > Delete Account
    And I confirm deletion by typing "DELETE"
    And I confirm again
    Then my identity should be deleted locally
    And my data should be removed from all relays
    And my contacts should be notified I'm gone
    And I should return to the welcome screen

  @deletion @implemented
  Scenario: Deletion is thorough
    When I delete my account
    Then all local data should be wiped
    And keychain/keystore entries should be removed
    And cached files should be deleted
    And database should be wiped
    And no personal data should remain on device

  @deletion @implemented
  Scenario: Deletion notifies contacts
    Given Alice has my contact
    When I delete my account
    Then Alice should receive a notification
    And my card in Alice's contacts should be marked "Account deleted"
    And Alice should be unable to send me updates

  @deletion @implemented
  Scenario: Grace period before permanent deletion
    When I request account deletion
    Then I should be told there is a 7-day grace period
    And I should be able to cancel during this period
    And after 7 days deletion should be permanent
    And I should receive reminder notifications

  @deletion @implemented
  Scenario: Cancel deletion during grace period
    Given I requested account deletion 3 days ago
    When I go to Settings > Privacy
    Then I should see "Deletion scheduled"
    And I should be able to cancel
    And canceling should restore my account fully

  @deletion @implemented
  Scenario: Delete specific contacts
    Given I have a contact Bob
    When I delete Bob from my contacts
    Then Bob's data should be removed from my device
    And Bob should not be notified (my choice to forget)
    And I should be able to re-exchange later if needed
  # ============================================================
  # Consent
  # ============================================================

  @consent @implemented
  Scenario: Consent collected on first launch
    Given I am launching the app for the first time
    When I reach the terms screen
    Then I should see a clear privacy policy summary
    And I should explicitly agree to the terms
    And my consent should be recorded with timestamp
    And I cannot proceed without agreeing

  @consent @implemented
  Scenario: View what I consented to
    When I go to Settings > Privacy > Consent
    Then I should see what I consented to
    And I should see when I consented
    And I should see the version of terms I agreed to
  # Telemetry scenarios removed — Principle 1 states "No tracking, analytics,
  # or telemetry" (principles.md). Vauchi does not collect usage telemetry.
  # See: audit 2026-03-23, finding C1.

  @consent @implemented
  Scenario: Re-consent required for major changes
    Given I consented to version 1.0 of privacy policy
    When version 2.0 introduces new data collection
    Then I should be prompted to re-consent
    And I should see what changed
    And I can continue to decline new collection
  # ============================================================
  # Privacy Information
  # ============================================================

  @transparency @implemented
  Scenario: View privacy policy in app
    When I go to Settings > Privacy Policy
    Then I should see the full privacy policy
    And it should be in my language if available
    And it should be understandable (no legal jargon)

  @transparency @implemented
  Scenario: View what data is stored locally
    When I go to Settings > Privacy > My Data
    Then I should see a summary of stored data:
      | Category | Description                           |
      | Identity | Your contact card and encryption keys |
      | Contacts | People you've exchanged with          |
      | Devices  | Your linked devices                   |
      | Settings | Your preferences                      |
    And I should see that data is E2E encrypted

  @transparency @implemented
  Scenario: View what data is on relays
    When I go to Settings > Privacy > Relay Data
    Then I should see pending messages on relays
    And I should see their expiration dates
    And I should be able to delete them early

  @transparency @implemented
  Scenario: Understand E2E encryption
    When I go to Settings > Privacy > How Your Data Is Protected
    Then I should see an explanation of E2E encryption
    And it should explain that Vauchi cannot read my data
    And it should explain that only my contacts can read updates
  # ============================================================
  # Data Retention
  # ============================================================

  @retention @implemented
  Scenario: Relay data expires automatically
    Given I sent an update via relay
    When 30 days pass without delivery
    Then the update should be automatically deleted from the relay
    And no personal data should persist on relays beyond TTL

  @retention @implemented
  Scenario: Local data persists until deleted
    Given I have contacts and settings
    Then local data should persist indefinitely
    # Until I explicitly delete it
    And no automatic purging should occur without my consent

  @retention @implemented
  Scenario: View data retention settings
    When I go to Settings > Privacy > Data Retention
    Then I should see:
      | Setting              | Value                      |
      | Relay message TTL    |                    30 days |
      | Local data retention | Forever (until you delete) |
      | Backup retention     | Your control               |
    And I should understand each setting
  # ============================================================
  # Third-Party Sharing
  # ============================================================

  @sharing @planned
  Scenario: No data sold to third parties
    Then Vauchi should never sell personal data
    And no advertising profiles should be created
    And no data should be shared for marketing
    And this should be stated in the privacy policy

  @sharing @planned
  Scenario: No tracking across apps
    Then Vauchi should not track users across apps
    And no device fingerprinting should occur
    And no advertising IDs should be used
    And no third-party analytics at all

  @sharing @planned
  Scenario: Relay operators cannot access content
    Given I use a third-party relay
    Then the relay operator should not be able to read my data
    And only encrypted blobs should be visible to relays
    And metadata should be minimized
  # ============================================================
  # Privacy Controls
  # ============================================================

  @controls @planned
  Scenario: Control visibility of my data
    When I go to Settings > Privacy > Visibility
    Then I should be able to configure who sees what
    And I should have granular control per field
    And I should be able to hide from specific contacts

  @controls @planned
  Scenario: Disable read receipts
    When I go to Settings > Privacy > Read Receipts
    And I disable read receipts
    Then contacts should not know when I read their updates
    And I should not see when they read mine
    And this preference should be respected

  @controls @planned
  Scenario: Limit metadata exposure
    When I go to Settings > Privacy > Minimize Metadata
    Then I should be able to enable enhanced privacy
    And this may include padding messages, random delays
    And I should understand the tradeoffs
  # ============================================================
  # Audit & Verification
  # ============================================================

  @audit @planned
  Scenario: View access log
    When I go to Settings > Privacy > Access Log
    Then I should see when my data was accessed
    And I should see which devices accessed it
    And I should see export/deletion events

  @audit @planned
  Scenario: Verify no unexpected data access
    Given I have one device
    When I view the access log
    Then I should only see access from my device
    And no unexpected access should appear
    And I should be able to report suspicious activity

  @audit @planned
  Scenario: Open source verification
    Then Vauchi's source code should be publicly available
    And users should be able to verify privacy claims
    And cryptographic implementations should be auditable
  # ============================================================
  # Enhanced GDPR Compliance (P16)
  # ============================================================

  @deletion @relay @implemented
  Scenario: Relay notified on account deletion
    Given I have pending messages on a relay
    When I delete my account
    Then the relay should receive a deletion request
    And all my mailbox data should be purged within 24 hours
    And the relay should return a confirmation receipt

  @consent @versioning @implemented
  Scenario: Consent records include policy version
    Given I consented to privacy policy version "1.0"
    When I view my consent records
    Then each record should show the policy version
    And re-consent should be triggered on version change

  @export @enhanced @implemented
  Scenario: Export includes device list and recovery config
    Given I have 2 linked devices and recovery configured
    When I export my data
    Then the export should include my device list
    And the export should include my recovery configuration
    And the export should include all consent records with versions
    And the export should NOT include private keys
  # ============================================================
  # Crypto-Shredding
  # ============================================================

  @crypto-shredding @deletion @implemented
  Scenario: Card updates use per-contact content encryption key
    Given Alice has exchanged cards with Bob
    When Alice updates her contact card
    Then the update is encrypted with a new content encryption key
    And the previous content encryption key is no longer valid

  @crypto-shredding @deletion @implemented
  Scenario: Account deletion destroys all content encryption keys
    Given Alice has exchanged cards with Bob and Carol
    When Alice deletes her account
    Then Alice's content encryption keys for Bob and Carol are destroyed
    And Bob's copy of Alice's card becomes permanently unreadable
    And Carol's copy of Alice's card becomes permanently unreadable

  @crypto-shredding @deletion @implemented
  Scenario: Crypto-shredding renders card unreadable without key
    Given Bob has Alice's card encrypted with a content encryption key
    When Alice's content encryption key is destroyed
    Then Bob cannot decrypt Alice's card
    And the encrypted card data is computationally irrecoverable

  @crypto-shredding @deletion @implemented
  Scenario: Contact display name is protected by crypto-shredding
    Given Bob has Alice's card with display name "Alice Smith"
    When Alice's content encryption key is destroyed
    Then Bob cannot recover Alice's display name from storage
    And no plaintext personal data remains in the database
  # ============================================================
  # Revocation Protocol
  # ============================================================

  @revocation @deletion @implemented
  Scenario: Account deletion sends revocation signal to all contacts
    Given Alice has exchanged cards with Bob and Carol
    When Alice deletes her account
    Then Bob receives an authenticated revocation signal from Alice
    And Carol receives an authenticated revocation signal from Alice

  @revocation @deletion @security @implemented
  Scenario: Revocation signal is cryptographically authenticated
    Given Bob receives a revocation signal claiming to be from Alice
    When Bob verifies the signal's Ed25519 signature
    Then the signature matches Alice's stored public key
    And Bob removes Alice's card and encryption keys

  @revocation @deletion @security @implemented
  Scenario: Spoofed revocation signal is rejected
    Given Bob receives a revocation signal claiming to be from Alice
    When the signature does not match Alice's public key
    Then Bob rejects the revocation signal
    And Alice's card remains unchanged

  @revocation @deletion @relay @implemented
  Scenario: Offline contact receives revocation on reconnect
    Given Alice deleted her account while Bob was offline
    When Bob reconnects to the relay within 30 days
    Then Bob receives the revocation signal
    And Alice's card is removed from Bob's device

  @revocation @security @planned
  Scenario: Card update arriving after revocation is discarded
    Given Bob has processed a revocation signal from Alice
    When a card update from Alice arrives on the relay
    Then Bob discards the update
    And no data for Alice is re-created

  @revocation @security @planned
  Scenario: Replayed revocation for re-established contact is rejected
    Given Alice previously revoked her account
    And Alice created a new account and re-exchanged cards with Bob
    When an attacker replays Alice's old revocation signal
    Then Bob rejects the stale revocation
    And Alice's new card remains intact
  # ============================================================
  # Multi-Device Deletion
  # ============================================================

  @deletion @sync @implemented
  Scenario: Account deletion propagates across all user devices
    Given Alice has devices A, B, and C
    When Alice schedules account deletion from device A
    Then device B receives the deletion schedule via device sync
    And device C receives the deletion schedule via device sync
    And all devices execute deletion after the grace period
  # ============================================================
  # Relay Purge
  # ============================================================

  @deletion @relay @implemented
  Scenario: Account deletion purges all relay data including recovery proofs
    Given Alice has stored blobs and recovery proofs on the relay
    When Alice deletes her account
    Then all blobs for Alice are deleted from the relay
    And all device sync messages for Alice are deleted
    And Alice's recovery proof is deleted

  @deletion @relay @command @implemented
  Scenario: Execute deletion after grace period sends revocations and purge
    Given I scheduled account deletion 8 days ago
    And I have contacts Alice and Bob
    When I execute the account deletion
    Then Alice should receive an authenticated revocation signal
    And Bob should receive an authenticated revocation signal
    And the relay should receive a purge request
    And all local keys and data should be destroyed

  @deletion @relay @command @implemented
  Scenario: Execute deletion requires grace period to have elapsed
    Given I scheduled account deletion 2 days ago
    When I try to execute the account deletion
    Then the execution should fail with a grace period error
    And no data should be destroyed

  @deletion @relay @command @emergency @implemented
  Scenario: Panic shred immediately destroys all data and notifies contacts
    Given I have contacts Alice and Bob
    When I execute a panic shred
    Then Alice should receive an authenticated revocation signal
    And Bob should receive an authenticated revocation signal
    And the relay should receive a purge request
    And all local keys and data should be destroyed immediately
