# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Simplified 2026-03-17: Community trust scoring removed (Principle 1 —
# builds a social graph of who-validated-whom). Replaced with
# self-attestation + optional OAuth verification only.

@validation @trust
Feature: Field Validation
  As a Vauchi user
  I want to mark my own fields as verified and optionally prove ownership
  So that contacts can see which of my fields I stand behind

  Background:
    Given I have an existing identity as "Alice"
    And I have a contact "Bob" in my contacts
    And Bob has the following fields:
      | type    | name     | value                |
      | social  | twitter  | @bob_smith           |
      | email   | work     | bob@example.com      |
      | phone   | mobile   | +1-555-123-4567      |

  # ============================================================
  # Self-Attestation (owner marks their own fields)
  # ============================================================

  @self-attest @planned
  Scenario: Mark my own field as self-attested
    Given I have a phone field "+1-555-000-0000"
    When I tap "Mark as verified" on my phone field
    Then the field should show a self-attested badge
    And contacts who have my card should see the badge

  @self-attest @planned
  Scenario: Self-attestation is per-field
    Given I have self-attested my phone field
    But I have not self-attested my email field
    When Bob views my contact card
    Then my phone should show "self-verified"
    And my email should show "unverified"

  @self-attest @planned
  Scenario: Self-attestation resets when field value changes
    Given I have self-attested my phone field
    When I change my phone number
    Then the self-attestation badge should be removed
    And I should need to re-attest the new value

  @self-attest @planned
  Scenario: Remove self-attestation
    Given I have self-attested my email field
    When I tap "Remove verification" on my email field
    Then the self-attestation badge should be removed

  # ============================================================
  # Viewing Verification Status
  # ============================================================

  @view-status @planned
  Scenario: View unverified field
    Given Bob has not verified any of his fields
    When I view Bob's contact card
    Then all fields should show as "unverified"

  @view-status @planned
  Scenario: View self-attested field
    Given Bob has self-attested his Twitter profile
    When I view Bob's contact card
    Then the Twitter field should show "self-verified"

  @view-status @planned
  Scenario: View OAuth-verified field
    Given Bob has OAuth-verified his GitHub profile
    When I view Bob's contact card
    Then the GitHub field should show "verified by GitHub"
    And this should rank higher than self-attestation

  # ============================================================
  # Validation Propagation
  # ============================================================

  @propagation @planned
  Scenario: Self-attestation syncs to contacts
    Given I self-attest my phone field
    When my card updates sync to Bob
    Then Bob should see my phone field as "self-verified"

  @propagation @planned
  Scenario: Attestation is cryptographically signed
    Given I self-attest my email field
    Then the attestation should be signed with my identity key
    And contacts should be able to verify the signature
    And tampering with the attestation should be detectable

  # ============================================================
  # OAuth 2.0 Verification (optional, stronger than self-attestation)
  # ============================================================

  @oauth @low-priority @planned
  Scenario: View OAuth verification option for supported networks
    Given the social network "github" supports OAuth verification
    When I view my GitHub social field
    Then I should see a "Verify with GitHub" option
    And I should see this provides "cryptographic proof" of ownership

  @oauth @low-priority @planned
  Scenario: Initiate OAuth verification flow
    Given I have a GitHub social field with value "octocat"
    When I tap "Verify with GitHub"
    Then I should be redirected to GitHub's OAuth consent screen
    And the app should request minimal permissions (read-only profile)
    And my Vauchi identity should NOT be shared with GitHub

  @oauth @low-priority @planned
  Scenario: Complete OAuth verification successfully
    Given I initiated OAuth verification for GitHub
    When I authorize the app on GitHub
    And GitHub confirms my username is "octocat"
    Then my GitHub field should be marked as "OAuth verified"
    And the verification should include a cryptographic proof
    And contacts should see a special "verified" badge

  @oauth @low-priority @planned
  Scenario: OAuth verification fails due to username mismatch
    Given I have a GitHub field with value "octocat"
    When I complete OAuth verification
    And GitHub returns username "different_user"
    Then verification should fail
    And I should see "Username does not match your profile"
    And no verification badge should be added

  @oauth @low-priority @planned
  Scenario: OAuth verified profile shows stronger trust indicator
    Given Bob's GitHub is OAuth verified
    And Bob's Twitter is self-attested
    When I view Bob's contact card
    Then GitHub should show "Verified by GitHub" (highest trust)
    And Twitter should show "Self-verified" (basic trust)

  @oauth @low-priority @planned
  Scenario: OAuth verification is privacy-preserving
    Given I complete OAuth verification for Twitter
    Then Twitter should NOT receive my Vauchi identity
    And Twitter should NOT receive my contact list
    And only my username confirmation should be stored
    And the OAuth token should be discarded after verification

  @oauth @low-priority @planned
  Scenario: Supported OAuth providers
    When I view OAuth verification options
    Then I should see support for:
      | provider  | method        |
      | GitHub    | OAuth 2.0     |
      | Twitter   | OAuth 2.0     |
      | Google    | OAuth 2.0     |
      | LinkedIn  | OAuth 2.0     |
      | Discord   | OAuth 2.0     |
      | Mastodon  | OAuth 2.0     |
    And unsupported networks should only offer self-attestation

  @oauth @low-priority @planned
  Scenario: Re-verification required after username change
    Given my GitHub field is OAuth verified
    When I change my GitHub username from "octocat" to "newname"
    Then the OAuth verification should be invalidated
    And I should be prompted to re-verify with the new username

  @oauth @low-priority @planned
  Scenario: OAuth verification without network account
    Given I want to verify a GitHub profile
    But I don't have a GitHub account
    Then I should still be able to use self-attestation
    And OAuth verification should be shown as optional
