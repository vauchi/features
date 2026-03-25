# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@contacts @import
Feature: External Contact Import
  As a Vauchi user
  I want to import contacts from external sources (vCard files)
  So that Vauchi becomes my single contact app for all contacts

  Background:
    Given I have an existing identity as "Alice"
    And I am logged into Vauchi

  # Import from vCard

  @import @implemented
  Scenario: Import contacts from a vCard file
    Given I have a vCard file with contacts "Bob" and "Carol"
    When I import the vCard file
    Then I should see "Bob" and "Carol" in my contacts list
    And they should be marked as imported contacts
    And the import result should show 2 imported, 0 skipped

  @import @implemented
  Scenario: Import vCard 2.1 with QUOTED-PRINTABLE encoding
    Given I have a vCard 2.1 file with name "Hans Mueller" encoded as QUOTED-PRINTABLE
    When I import the vCard file
    Then I should see "Hans Mueller" with correctly decoded characters

  @import @implemented
  Scenario: Import vCard 3.0 from Google Contacts
    Given I have a vCard 3.0 file exported from Google Contacts
    When I import the vCard file
    Then I should see contacts with phone numbers, emails, and addresses

  @import @implemented
  Scenario: Import non-UTF-8 vCard file
    Given I have a vCard file with Latin-1 encoded names
    When I import the vCard file
    Then names should be decoded correctly via Latin-1 fallback

  @import @implemented
  Scenario: Re-import same vCard file does not create duplicates
    Given I have imported a vCard file with contact "Bob" (UID: "uid-123")
    When I import the same vCard file again
    Then I should still have only one "Bob" contact
    And the import result should show 0 imported, 1 skipped

  @import @implemented
  Scenario: Import respects contact limit
    Given I have reached the maximum contact limit
    When I try to import a vCard file with 5 contacts
    Then the import result should show 0 imported, 5 skipped
    And a warning should mention the contact limit

  # Trust boundary

  @trust @implemented
  Scenario: Imported contacts cannot be trusted for recovery
    Given I have an imported contact "Bob"
    When I try to mark Bob as trusted for recovery
    Then I should get an error
    And the error should indicate this requires an exchanged contact

  @trust @implemented
  Scenario: Imported contacts cannot have fingerprint verified
    Given I have an imported contact "Bob"
    When I try to verify Bob's fingerprint
    Then I should get an error

  @trust @implemented
  Scenario: Imported contacts cannot be trusted for proposals
    Given I have an imported contact "Bob"
    When I try to mark Bob as trusted for proposals
    Then I should get an error

  # Editing

  @edit @implemented
  Scenario: Edit imported contact fields
    Given I have an imported contact "Bob" with phone "555-0001"
    When I update Bob's phone to "555-9999"
    Then Bob's phone should show "555-9999"

  @edit @implemented
  Scenario: Cannot edit exchanged contact fields
    Given I have an exchanged contact "Carol"
    When I try to edit Carol's phone number
    Then I should get an error
    And the error should indicate exchanged contacts are read-only

  @edit @implemented
  Scenario: Add field to imported contact
    Given I have an imported contact "Bob" with no email
    When I add an email "bob@example.com" to Bob
    Then Bob should have email "bob@example.com"

  # Visual distinction

  @display @implemented
  Scenario: Imported contacts are visually distinct
    Given I have exchanged contact "Carol" and imported contact "Bob"
    When I view the contacts list
    Then Bob should have an "Imported" indicator
    And Carol should have a "Vauchi contact" indicator

  # Merge prevention

  @merge @implemented
  Scenario: Cannot merge exchanged and imported contacts
    Given I have exchanged contact "Carol" and imported contact "Carol Smith"
    When I try to merge them
    Then I should get an error
    And the error should indicate cross-kind merge is not allowed

  # Phone normalization for dedup

  @dedup @implemented
  Scenario: Phone normalization detects duplicates across formatting
    Given I have exchanged contact "Bob" with phone "+1 (555) 123-4567"
    And I have imported contact "Robert" with phone "15551234567"
    When I check for duplicates
    Then Bob and Robert should be flagged as potential duplicates

  # Encrypted backup

  @backup @implemented
  Scenario: Export and import contact backup
    Given I have exchanged contact "Carol" and imported contact "Bob"
    When I export a contact backup with password "test-pass-123"
    And I import the backup with password "test-pass-123"
    Then I should see both "Carol" and "Bob" with all their data

  @backup @implemented
  Scenario: Contact backup with wrong password fails
    Given I have exported a contact backup with password "correct"
    When I try to import with password "wrong"
    Then the import should fail with a decryption error

  # Device sync

  @sync @implemented
  Scenario: Imported contacts sync to linked device
    Given I have imported contact "Bob" on device A
    When device B links to device A via full sync
    Then device B should have imported contact "Bob"
    And Bob's hidden/blocked/favorite flags should be preserved

  # Local groups

  @groups @implemented
  Scenario: Create local organization group
    Given I create a local group called "Family"
    And I add imported contact "Bob" to "Family"
    When I view the "Family" group
    Then I should see "Bob" in the group

  @groups @implemented
  Scenario: Local groups have no visibility semantics
    Given I have a local group "Friends" with imported contact "Bob"
    Then the group should NOT control what Bob sees of my card
    And the group should have no "visible_fields" property
