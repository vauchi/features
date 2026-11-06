# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@recovery
Feature: Contact Recovery
  As a user who lost their device
  I want to recover my contact relationships through social vouching by trusted contacts
  So that I can reconnect with my contacts securely using only contacts I explicitly trust

  Background:
    Given the Vauchi app is installed
    And the user has an identity
  # ============================================================
  # Configuration
  # ============================================================

  @recovery @configuration @implemented
  Scenario: Default recovery threshold
    When a new identity is created
    Then the default recovery threshold should be 3 vouchers
    And the default verification threshold should be 2 mutual contacts

  @recovery @configuration @implemented
  Scenario: Configure recovery threshold
    Given I have an identity
    When I set my recovery threshold to 5 vouchers
    Then my recovery threshold should be 5
    And contacts will need 5 vouchers to verify my recovery

  @recovery @configuration @implemented
  Scenario: Configure verification threshold
    Given I have an identity
    When I set my verification threshold to 3 mutual contacts
    Then recoveries I receive will require 3 mutual contact vouchers
    And recoveries with fewer mutual vouchers will show a warning

  @recovery @configuration @implemented
  Scenario: Recovery threshold limits
    Given I have an identity
    When I try to set my recovery threshold to 0
    Then the operation should fail with "Recovery threshold must be at least 1"
    When I try to set my recovery threshold to 10
    Then the operation should fail with "Recovery threshold cannot exceed 9"
  # ============================================================
  # Trusted Contacts for Recovery
  # ============================================================

  @recovery @trust @implemented
  Scenario: New contacts are not recovery-trusted by default
    Given Alice has exchanged contacts with Bob
    Then Bob should not be marked as recovery-trusted
    And Alice should have 0 recovery-trusted contacts

  @recovery @trust @implemented
  Scenario: Mark contact as trusted for recovery
    Given Alice has exchanged contacts with Bob
    When Alice marks Bob as trusted for recovery
    Then Bob should appear as recovery-trusted in Alice's contact list
    And Alice should have 1 recovery-trusted contact

  @recovery @trust @implemented
  Scenario: Remove recovery trust from contact
    Given Alice has marked Bob as recovery-trusted
    When Alice removes recovery trust from Bob
    Then Bob should not be marked as recovery-trusted
    And Alice should have 0 recovery-trusted contacts

  @recovery @trust @security @implemented
  Scenario: A tenth recovery-trusted contact is refused, not dropped
    Given Alice has marked nine contacts as recovery-trusted
    When Alice marks a tenth contact as trusted for recovery
    Then the operation should fail with "at most 9"
    And Alice still has 9 recovery-trusted contacts and the tenth is not one
    And releasing one guardian frees the place for another
    And a guardian backup for more guardians than one byte counts is refused, not split for the wrapped count

  @recovery @trust @implemented
  Scenario: Trust state syncs across linked devices
    Given Alice has two linked devices
    And Alice has exchanged contacts with Bob
    When Alice marks Bob as recovery-trusted on device 1
    And device 1 syncs with device 2
    Then Bob should be recovery-trusted on device 2

  @recovery @trust @implemented
  Scenario: Trust state is private to the user
    Given Alice has marked Bob as recovery-trusted
    Then Bob should not know he is marked as recovery-trusted
    And no trust information is shared during contact exchange
    And no trust information is included in sync updates to contacts

  @recovery @trust @implemented
  Scenario: Only trusted contacts can provide valid vouchers
    Given Alice has 5 contacts: Bob, Charlie, Dave, Eve, and Frank
    And Alice has marked Bob, Charlie, and Dave as recovery-trusted
    And Alice's recovery threshold is 3
    When Alice loses her device and creates a recovery claim
    And Eve vouches for Alice's recovery
    And Alice tries to add Eve's voucher to her recovery proof
    Then the voucher should be rejected because Eve is not recovery-trusted

  @recovery @trust @implemented
  Scenario: Recovery succeeds with trusted vouchers only
    Given Alice has marked Bob, Charlie, and Dave as recovery-trusted
    And Alice's recovery threshold is 3
    When Alice loses her device and creates a recovery claim
    And Bob vouches for Alice
    And Charlie vouches for Alice
    And Dave vouches for Alice
    And Alice adds all three vouchers
    Then Alice's recovery proof should be valid
    And the proof contains 3 trusted vouchers

  @recovery @trust @implemented
  Scenario: Insufficient trusted vouchers even with untrusted vouchers available
    Given Alice has 5 contacts
    And Alice has marked only Bob and Charlie as recovery-trusted
    And Alice's recovery threshold is 3
    When Alice loses her device and creates a recovery claim
    And Bob, Charlie, Dave, Eve, and Frank all vouch for Alice
    Then Alice can only add Bob's and Charlie's vouchers
    And the recovery proof has 2 of 3 required vouchers
    And the recovery threshold is not met

  @recovery @trust @implemented
  Scenario: Warning when trusted contacts below threshold
    Given Alice's recovery threshold is 3
    And Alice has only 2 recovery-trusted contacts
    When Alice views her recovery settings
    Then she should see a warning:
      """
      ⚠️ You have 2 trusted contacts but need at least 3 for recovery.
      Mark 1 more contact as trusted to enable social recovery.
      """

  @recovery @trust @implemented
  Scenario: Warning when removing trust drops below threshold
    Given Alice has recovery threshold of 3
    And Alice has exactly 3 recovery-trusted contacts: Bob, Charlie, Dave
    When Alice removes recovery trust from Dave
    Then Alice should see a warning:
      """
      ⚠️ You now have 2 trusted contacts, below your recovery threshold of 3.
      If you lose your device, you may not be able to recover.
      """

  @recovery @trust @implemented
  Scenario: Blocked contact cannot be recovery-trusted
    Given Alice has blocked Bob
    When Alice tries to mark Bob as recovery-trusted
    Then the operation should fail
    And Alice should see "Blocked contacts cannot be trusted for recovery"

  @recovery @trust @implemented
  Scenario: Removing trust does not affect other contact properties
    Given Alice has marked Bob as recovery-trusted
    And Alice has verified Bob's fingerprint
    And Alice has set visibility rules for Bob
    When Alice removes recovery trust from Bob
    Then Bob's fingerprint verification should remain unchanged
    And Bob's visibility rules should remain unchanged
    And only the recovery trust flag should change
  # ============================================================
  # Identity Loss and New Identity Creation
  # Today's path. Planned to be replaced by "Social recovery restores
  # the same identity" below (vauchi/private#796, P28, P32).
  # ============================================================

  @recovery @identity @implemented
  Scenario: Create new identity after device loss
    Given Alice had an identity with public key "pk_old"
    And Alice had contacts Bob, Charlie, John, Betty, and David
    When Alice loses her device
    And Alice installs the app on a new device
    And Alice creates a new identity
    Then Alice has a new public key "pk_new"
    And Alice has no contacts on the new device
    And Alice can initiate recovery claiming "pk_old"

  @recovery @identity @implemented
  Scenario: Remember old identity fingerprint
    Given Alice had an identity with public key "pk_old"
    When Alice creates a new identity on a new device
    Then Alice can enter her old public key manually
    And the app stores the recovery claim for "pk_old"
  # ============================================================
  # In-Person Vouching Process
  # ============================================================

  @recovery @vouching @implemented
  Scenario: Generate recovery claim QR code
    Given Alice has a new identity with public key "pk_new"
    And Alice claims her old identity was "pk_old"
    When Alice generates a recovery QR code
    Then the QR code contains:
      | field     | value          |
      | type      | recovery_claim |
      | old_pk    | pk_old         |
      | new_pk    | pk_new         |
      | timestamp | current_time   |

  @recovery @vouching @planned
  Scenario: Voucher recognizes old contact
    Given Bob has Alice as a contact with public key "pk_old"
    When Bob scans Alice's recovery QR code claiming "pk_old"
    Then Bob's app shows "Alice claims to have lost their device"
    And Bob's app shows Alice's stored display name and photo
    And Bob is prompted to verify this is really Alice in person

  @recovery @vouching @implemented
  Scenario: Voucher does not recognize the claimed identity
    Given Bob does not have "pk_old" as a contact
    When Bob scans a recovery QR code claiming "pk_old"
    Then Bob's app shows "Unknown identity - you have no contact with this public key"
    And Bob cannot create a voucher

  @recovery @vouching @security @implemented
  Scenario: A revoked contact can still vouch for the real recovery
    Given Bob had Alice as a contact with public key "pk_old"
    And Alice's old device, in a thief's hands, revoked her identity at Bob
    And Bob's app destroyed Alice's card and keys and kept a tombstone with her key and name
    When Bob scans Alice's real recovery claim for "pk_old" -> "pk_new"
    Then Bob's app names Alice as the former contact the claim is for
    And Bob can create a voucher
    And a claim for a key Bob never met is still refused

  @recovery @vouching @implemented
  Scenario: Create voucher after in-person verification
    Given Bob has Alice as a contact with public key "pk_old"
    And Bob scans Alice's recovery QR code for "pk_old" -> "pk_new"
    When Bob confirms he has verified Alice in person
    And Bob taps "Vouch for Recovery"
    Then a voucher is created containing:
      | field      | value                             |
      | old_pk     | pk_old                            |
      | new_pk     | pk_new                            |
      | voucher_pk | Bob's public key                  |
      | timestamp  | current_time                      |
      | signature  | Ed25519 signature of above fields |
    And the voucher is sent to Alice's new identity

  @recovery @vouching @planned
  Scenario: Voucher establishes contact with new identity
    Given Bob vouches for Alice's recovery from "pk_old" to "pk_new"
    Then Bob's contact record for Alice is updated to "pk_new"
    And a new key exchange is initiated between Bob and Alice
    And Bob and Alice can communicate using the new shared key

  @recovery @vouching @implemented
  Scenario: Collect multiple vouchers from trusted contacts
    Given Alice has recovery threshold of 3
    And Alice has marked Bob, Charlie, and Betty as recovery-trusted
    And Alice has collected vouchers from:
      | voucher |
      | Bob     |
      | Charlie |
    When Alice meets Betty in person
    And Betty vouches for Alice's recovery
    Then Alice has 3 trusted vouchers
    And the recovery threshold is met
  # ============================================================
  # Recovery Proof Creation and Distribution
  # ============================================================

  @recovery @proof @implemented
  Scenario: Create recovery proof when threshold met
    Given Alice has recovery threshold of 3
    And Alice has marked Bob, Charlie, and Betty as recovery-trusted
    And Alice has collected 3 trusted vouchers from Bob, Charlie, and Betty
    When the recovery threshold is met
    Then a recovery proof is automatically created containing:
      | field     | value                                               |
      | old_pk    | Alice's old public key                              |
      | new_pk    | Alice's new public key                              |
      | threshold |                                                   3 |
      | vouchers  | [Bob's voucher, Charlie's voucher, Betty's voucher] |

  @recovery @proof @implemented
  Scenario: Upload recovery proof to relay
    Given Alice has a valid recovery proof
    When Alice uploads the recovery proof
    Then the relay stores the proof under key hash(old_pk)
    And the relay does not learn Alice's identity
    And only someone who holds old_pk, a contact of Alice's, can open the proof

  @recovery @proof @implemented
  Scenario: Recovery proof expiration
    Given Alice uploads a recovery proof whose first voucher is 193 hours old
    When a contact verifies the proof
    Then the contact refuses it as expired
    And a proof whose first voucher is 191 hours old is still verified
    And Alice must start a fresh recovery claim

  @recovery @proof @implemented
  Scenario: Continue collecting vouchers after threshold
    Given Alice has recovery threshold of 3
    And Alice has created a recovery proof with 3 vouchers
    When Alice meets David and David vouches
    Then the recovery proof is updated with 4 vouchers
    And the updated proof is uploaded to the relay
    And more contacts may be able to verify via mutual contacts
  # ============================================================
  # Discovery by Other Contacts
  # ============================================================

  @recovery @discovery @planned
  Scenario: Contact discovers recovery proof via relay
    Given Alice has uploaded a recovery proof
    And John has Alice as a contact with public key "pk_old"
    When John's app syncs with the relay
    Then John's app queries for recovery proofs for all contacts
    And John's app finds the recovery proof for "pk_old"
    And John is notified about Alice's recovery claim

  @recovery @discovery @planned
  Scenario: Batch query for recovery proofs
    Given John has 50 contacts
    When John's app checks for recovery proofs
    Then John's app sends a single batch query with 50 hashes
    And the relay cannot determine which specific contact John is checking
    And John receives any matching recovery proofs

  @recovery @discovery @planned
  Scenario: No recovery proof found
    Given John has Alice as a contact
    And Alice has not uploaded a recovery proof
    When John's app checks for recovery proofs
    Then no recovery notification is shown for Alice
  # ============================================================
  # Verification - Mutual Contacts
  # ============================================================

  @recovery @verification @mutual @implemented
  Scenario: Verify recovery with mutual contacts
    Given John has verification threshold of 2 mutual contacts
    And John has Alice as a contact
    And John also has Betty as a contact
    When John receives Alice's recovery proof vouched by Bob, Charlie, and Betty
    Then John's app identifies Betty as a mutual contact
    And John's app shows:
      """
      Alice has recovered their identity.
      
      Vouched by:
        - Bob (unknown to you)
        - Charlie (unknown to you)
        - Betty (contact of yours) ✓
      
      Mutual contacts vouching: 1 of 2 required
      """
    And John is warned that verification threshold is not met

  @recovery @verification @mutual @implemented
  Scenario: Automatic verification with sufficient mutual contacts
    Given John has verification threshold of 2 mutual contacts
    And John has Alice, Bob, and Charlie as contacts
    When John receives Alice's recovery proof vouched by Bob, Charlie, and Betty
    Then John's app identifies Bob and Charlie as mutual contacts
    And John's app shows:
      """
      Alice has recovered their identity.
      
      Vouched by:
        - Bob (contact of yours) ✓
        - Charlie (contact of yours) ✓
        - Betty (unknown to you)
      
      Mutual contacts vouching: 2 of 2 required ✓
      """
    And John's contact for Alice does not move until the policy guardians' certificate for the rotation exists

  @recovery @verification @mutual @implemented
  Scenario: High trust with many mutual contacts
    Given Eve has verification threshold of 2 mutual contacts
    And Eve knows Alice, Bob, Charlie, Betty, and David
    When Eve receives Alice's recovery proof vouched by Bob, Charlie, Betty, and David
    Then Eve's app shows all 4 vouchers are mutual contacts
    And the recovery is marked as "High confidence"
  # ============================================================
  # Verification - Isolated Contacts (David's Case)
  # ============================================================

  @recovery @verification @isolated @implemented
  Scenario: Isolated contact receives recovery proof
    Given David has verification threshold of 2 mutual contacts
    And David has Alice as his only contact
    And David does not know Bob, Charlie, or Betty
    When David receives Alice's recovery proof vouched by Bob, Charlie, and Betty
    Then David's app shows:
      """
      ⚠️ Recovery Request
      
      Alice claims to have recovered their identity.
      
      Vouched by:
        - Bob (unknown to you)
        - Charlie (unknown to you)
        - Betty (unknown to you)
      
      ⚠️ Warning: You don't know any of the vouchers
      
      This could be legitimate - Alice may have friend groups
      you're not part of. But it could also be an impersonator.
      """

  @recovery @verification @isolated @planned
  Scenario: Isolated contact options
    Given David receives a recovery proof with no mutual contact vouchers
    Then David is presented with options:
      | option               | security | description                          |
      | Meet Alice in Person | Highest  | Verify directly and become a voucher |
      | Verify Another Way   | High     | Call or text Alice to confirm        |
      | Accept Anyway        | Lower    | Trust the unknown vouchers           |
      | Reject               | Safe     | Decline the recovery                 |
      | Remind Me Later      | Neutral  | Check again in 7 days                |

  @recovery @verification @isolated @security @implemented
  Scenario: No contact accepts a recovery without the certificate
    Given David has no mutual contacts with the vouchers
    When David receives Alice's rekey offer
    Then David's app drops the offer
    And David's contact for Alice keeps its key and shared key
    And neither vouchers nor the old key's signatures move it

  @recovery @verification @isolated @implemented
  Scenario: Isolated contact verifies out of band
    Given David has no mutual contacts with the vouchers
    When David chooses "Verify Another Way"
    Then David's app shows:
      """
      Contact Alice through another channel to verify:
      
      Ask Alice to confirm their new identity fingerprint:
      WXYZ-5678-ABCD-1234
      
      If Alice confirms this fingerprint, tap "Verified"
      """
    And David can mark as verified after out-of-band confirmation

  @recovery @verification @isolated @implemented
  Scenario: Isolated contact meets in person and vouches
    Given David has no mutual contacts with the vouchers
    When David chooses "Meet Alice in Person"
    And David meets Alice and scans her recovery QR code
    And David vouches for Alice
    Then David becomes a voucher
    And Alice's recovery proof is updated with David's voucher
    And other isolated contacts who know David can now verify
  # ============================================================
  # Acceptance and Reconnection
  # ============================================================

  @recovery @acceptance @planned
  Scenario: Accept recovery and reconnect
    Given the policy guardians' certificate rotates Alice to her registered next identity
    And John receives Alice's rekey offer signed by that identity with the certificate
    Then John's contact record for Alice is updated:
      | field      | old_value | new_value |
      | public_key | pk_old    | pk_new    |
    And a new X3DH key exchange is initiated
    And John and Alice establish a new shared secret
    And the old shared secret is discarded

  @recovery @acceptance @planned
  Scenario: Contact card is refreshed after recovery
    Given John accepted Alice's certified rotation
    And the new key exchange completes
    When Alice sends her current contact card
    Then John receives Alice's updated contact card
    And John's stored card for Alice is refreshed

  @recovery @acceptance @implemented
  Scenario: Reject recovery
    Given John receives Alice's recovery proof
    When John rejects the recovery
    Then John's contact for Alice remains unchanged
    And John is not notified again for this recovery proof
    And John can manually reconsider later in settings

  @recovery @acceptance @implemented
  Scenario: Remind me later
    Given John receives Alice's recovery proof
    When John chooses "Remind Me Later"
    Then the notification is dismissed
    And John is reminded after 7 days
    And John can adjust the reminder period
  # ============================================================
  # Edge Cases and Security
  # ============================================================

  @recovery @security @planned
  Scenario: Reject recovery from unknown identity
    Given John receives a recovery proof for "pk_unknown"
    And John does not have "pk_unknown" as a contact
    Then the recovery proof is ignored
    And no notification is shown

  @recovery @security @implemented
  Scenario: Reject recovery with insufficient vouchers
    Given Alice has recovery threshold of 3
    And Alice has only collected 2 vouchers
    When Alice tries to create a recovery proof
    Then the operation fails with "Insufficient vouchers (2 of 3 required)"

  @recovery @security @implemented
  Scenario: Reject duplicate vouchers
    Given Alice is collecting vouchers
    And Bob has already vouched for Alice
    When Bob tries to vouch again
    Then the duplicate voucher is rejected
    And Alice still has 1 voucher from Bob

  @recovery @security @implemented
  Scenario: Voucher timestamp validation
    Given Alice generates a recovery claim at time T
    When Bob vouches 193 hours later
    Then the voucher is rejected as expired
    And Alice must generate a fresh recovery claim

  @recovery @security @planned
  Scenario: Vouchers of one recovery are given within 96 hours
    Given Alice assembles a recovery proof from two vouchers
    When the two voucher timestamps are 97 hours apart
    Then the proof is refused as outside the voucher window
    And a proof whose vouchers are 95 hours apart is accepted

  @recovery @security @implemented
  Scenario: Detect conflicting recovery claims
    Given Alice uploads a recovery proof for "pk_old" -> "pk_new_1"
    When an attacker uploads a recovery proof for "pk_old" -> "pk_new_2"
    Then contacts see a conflict warning:
      """
      ⚠️ Multiple recovery claims detected for Alice
      
      Claim 1: pk_new_1 (3 vouchers)
      Claim 2: pk_new_2 (2 vouchers)
      
      This may indicate an attack. Verify with Alice directly.
      """

  @recovery @security @implemented
  Scenario: Revoke recovery proof
    Given Alice has uploaded a recovery proof
    And Alice later recovers her old device
    When Alice signs a revocation with her old private key
    Then the recovery proof is invalidated
    And contacts are notified the recovery was revoked

  @recovery @security @implemented
  Scenario: Cannot vouch for own recovery
    Given Alice claims recovery from "pk_old" to "pk_new"
    When Alice tries to vouch for herself (using pk_new)
    Then the self-voucher is rejected

  @recovery @security @implemented
  Scenario: Voucher must have existing relationship
    Given Eve does not have Alice as a contact
    When Eve tries to scan Alice's recovery QR code
    Then Eve cannot vouch
    And Eve sees "You must be an existing contact to vouch"
  # ============================================================
  # Data Recovery Limitations
  # ============================================================

  @recovery @limitations @implemented
  Scenario: What is recovered
    Given John accepts Alice's recovery
    Then the following is recovered:
      | data                   | recovered              |
      | Contact relationship   | Yes                    |
      | Ability to communicate | Yes                    |
      | Alice's contact card   | Yes (re-sent by Alice) |

  @recovery @limitations @implemented
  Scenario: What is NOT recovered
    Given John accepts Alice's recovery
    Then the following is NOT recovered:
      | data                       | reason                      |
      | Old encryption keys        | Lost with device            |
      | Old message history        | Cannot decrypt without keys |
      | Visibility rules Alice set | Lost with device            |
      | Notes Alice wrote          | Lost with device            |
      | Old shared secret          | Replaced with new exchange  |
  # ============================================================
  # Multi-Device Considerations
  # ============================================================

  @recovery @multi-device @implemented
  Scenario: Recovery when user has multiple devices
    Given Alice has 2 devices linked
    And Alice loses device 1 but still has device 2
    Then Alice does not need recovery
    And Alice can revoke device 1 from device 2
    And contacts are notified of device revocation

  @recovery @multi-device @implemented
  Scenario: Recovery after losing all devices
    Given Alice had 2 linked devices
    And Alice loses both devices
    Then Alice must use social recovery
    And Alice creates new identity on new device
    And the old linked devices are implicitly revoked
  # ============================================================
  # Relay Behavior
  # ============================================================

  @recovery @security @implemented
  Scenario: Recovery parsers take exactly their bytes
    Given a recovery claim, a voucher and a proof as Core serializes them
    When a byte trails any of them or a proof carries another version
    Then the claim parser takes exactly 73 bytes
    And the proof parser takes exactly its postcard bytes at version 2
    And a voucher is exactly its header, or its header and one token of the declared length

  @recovery @security @implemented
  Scenario: A recovery proof outside the threshold bounds is refused
    Given a recovery proof whose threshold is 0 or 10
    When a contact validates it
    Then it is refused as outside 1 to 9, even with no vouchers to count

  @recovery @security @trust @implemented
  Scenario: A guardian token travels under the voucher signature
    Given Bob vouches as a guardian with the token Alice designated him with
    When the token is stripped, swapped for another or the voucher is rewritten as the unsigned format 2
    Then the voucher does not verify or does not parse
    And a proof carrying a voucher whose token was forged by another key fails validation

  @recovery @security @implemented
  Scenario: A future-dated recovery claim is refused
    Given a recovery claim stamped more than 10 minutes ahead of the helper's clock
    When a helper tries to vouch for it, now or a year later
    Then the voucher is refused as from the future
    And a contact refuses a proof with a voucher stamped more than 10 minutes ahead

  @recovery @security @implemented
  Scenario: An old-key voucher is refused while collecting
    Given Alice is collecting vouchers for her recovery claim
    When a voucher signed by her old key, which a thief may hold, arrives
    Then it is refused as self-vouching before anything is uploaded

  @recovery @security @trust @implemented
  Scenario: A guardian vouches only with a token naming the claim and itself
    Given Bob is asked to vouch for Alice's recovery claim
    When the relay hands him an entry that opens but names another designator or another guardian
    Then Bob does not vouch with it
    And he vouches with the entry Alice designated him with

  @recovery @relay @implemented
  Scenario: Relay stores recovery proof privately
    Given Alice uploads a recovery proof
    Then the relay stores the proof under hash(pk_old)
    And the relay reads only the proof's version byte and Alice's new key
    And the rest, the old key and every helper's key, is sealed to the old key
    And a reader who does not hold the old key cannot open it
    And the relay refuses a plain, unsealed proof

  @recovery @relay @implemented
  Scenario: Relay returns recovery proof on query
    Given Alice has uploaded a recovery proof
    When any client queries for hash(pk_old)
    Then the relay returns the recovery proof
    And the relay does not log who queried

  @recovery @relay @implemented
  Scenario: Relay handles proof expiration
    Given Alice uploaded a recovery proof 10 days ago
    And the proof expiration is 9 days
    When John's app queries for the proof
    Then the relay returns "not found"
    And Alice must create a new recovery proof if needed

  @recovery @relay @implemented
  Scenario: Relay keeps recovery proofs for nine days
    Given Alice uploads a recovery proof
    Then the relay keeps it for 9 days after the upload
    And a contact accepts its vouchers for at most 192 hours, so nothing useful outlives the slot

  @recovery @relay @security @implemented
  Scenario: Relay refuses a recovery proof upload the new key did not sign
    Given Mallory knows Alice's old public key, as every contact does
    When Mallory uploads a proof for Alice's old key signed with Mallory's own key
    Then the relay refuses it because the signer is not the proof's new key
    And an unsigned upload is refused as well
    And a proof shorter than its header or of a version the relay does not know is refused

  @recovery @relay @security @implemented
  Scenario: Relay keeps a second recovery proof beside the first
    Given Mallory has stored a proof under hash(Alice's old key)
    When Alice uploads her real recovery proof under the same hash
    Then the relay stores Alice's proof beside Mallory's
    And a contact who queries the hash receives both and can tell them apart
    And at most four owners hold a proof under one hash, each replacing only its own

  @recovery @relay @implemented
  Scenario: Relay rate limits recovery queries
    Given a client makes 1000 recovery proof queries in 1 minute
    Then the relay rate limits the client
    And returns "too many requests" error

  @recovery @implemented
  Scenario: Reviewing a recovery claim
    Given a contact has fetched a recovery proof and Core has verified it
    When the review screen is built from that proof and its verdict
    Then the confidence shown follows the verified count of mutual vouchers against the threshold
    And enough mutual vouchers review as high confidence, one as medium, none as low
    And the fingerprint shown is the proof's new key, not a value the screen was handed
    # promoted_to: core (tests/it/recovery_claim_review_tests.rs, core!2051)

  # ============================================================
  # Social recovery restores the same identity (planned,
  # vauchi/private#796, P28, P32)
  # ============================================================

  @recovery @same-identity @implemented
  Scenario: Social recovery restores the same identity on a new device
    Given Alice's guardians keep pieces of her backup in three groups
    And Alice's phone is lost
    When Alice's new phone begins a recovery naming her old identity
    And a guardian of each group recognizes Alice and hands back its piece in person
    Then the new phone becomes Alice's identity as a new device
    And the lost device is listed as revoked in Alice's signed registry
    And Alice's contacts keep their shared keys
    And no contact waits for a rekey

  @recovery @same-identity @security @planned
  Scenario: A backup of another identity is refused
    Given Alice's new phone began a recovery naming her old identity
    When someone seals another identity's backup to the phone's recovery key
    Then the phone refuses to restore it
    And the phone still has no identity

  @recovery @same-identity @planned
  Scenario: Retried hand-backs count once
    Given Alice's new phone began a recovery
    When the same guardian hands back its piece many times
    Then the phone keeps that piece once
    And the restore still succeeds with the other groups' pieces

  @recovery @same-identity @planned
  Scenario: An interrupted restore keeps its recovery key and pieces
    Given Alice's new phone began a recovery and took two guardians' pieces
    When the phone restarts
    Then it still holds the recovery key and the two pieces
    And the third guardian's piece completes the restore

  @recovery @same-identity @security @planned
  Scenario: The recovery key is discarded after the restore
    Given Alice's new phone restored her identity
    Then the temporary recovery key and the pieces are gone

  @recovery @same-identity @security @planned
  Scenario: The recovery passphrase is still needed
    Given Alice set a recovery passphrase on her guardian backup
    When a guardian of each group hands back its piece
    Then the backup opens only with the passphrase as well

  # ============================================================
  # Recovery backup transfer (planned, vauchi/private#796, P33)
  # ============================================================

  @recovery @same-identity @implemented
  Scenario: A recovery backup crosses a connection that accepts small parts
    Given Alice's new phone has accepted her guardian's recovery share
    And their Bluetooth connection accepts only small parts at a time
    When the guardian sends Alice's encrypted backup in person
    Then the phone receives the complete backup without exceeding the connection's limits
    And the backup matches the one named by the accepted share

  @recovery @same-identity @implemented
  Scenario: A busy recovery connection reports an incomplete transfer
    Given Alice's new phone has accepted her guardian's recovery share
    And her guardian is sending the encrypted backup in person
    When the guardian's phone cannot accept another part to send
    Then Alice is told that the backup transfer could not finish
    And recovery stays incomplete
    And the accepted shares remain available for another attempt

  @recovery @same-identity @implemented
  Scenario: An interrupted backup transfer resumes after a restart
    Given Alice's new phone has accepted her guardian's recovery share
    And it has received some parts of the named backup
    When the phone restarts and meets the guardian again
    Then it keeps the accepted share and the parts already received
    And receiving the remaining parts completes the same backup

  @recovery @same-identity @security @implemented
  Scenario: Cancelling a backup transfer ignores late parts
    Given Alice's new phone is receiving a guardian's backup
    When Alice cancels the transfer
    Then the Bluetooth transfer stops
    And parts arriving from that cancelled transfer cannot complete a restore

  # ============================================================
  # Compromise rotation (planned, vauchi/private#796, P25 to P31)
  # ============================================================

  @recovery @compromise @security @planned
  Scenario: Revoking a phone stolen unlocked does not take back its keys
    Given Alice's phone was stolen unlocked
    When Alice revokes it from another device
    Then it stops syncing with her other devices
    And it still holds the identity's keys
    And moving contacts needs a rotation to Alice's registered next identity

  @recovery @compromise @security @planned
  Scenario: A contact met in person rotates to the registered next identity
    Given John pinned the hash of Alice's registered next identity
    When John meets Alice in person and recognizes her
    And her phone shows the identity matching that hash
    Then John rotates to it without a certificate
    And John marks Alice's old identity compromised

  @recovery @compromise @security @planned
  Scenario: Meeting in person does not rotate to an unregistered identity
    Given John pinned the hash of Alice's registered next identity
    When someone John recognizes as Alice shows an identity not matching that hash
    Then John makes a separate contact for it
    And John's contact for Alice's old identity does not move
