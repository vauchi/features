# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@contacts
Feature: Contacts Management
  As a Vauchi user
  I want to manage my contacts list
  So that I can organize and interact with people I've exchanged cards with

  Background:
    Given I have an existing identity as "Alice"
    And I am logged into Vauchi

  # Viewing Contacts

  @view @implemented
  Scenario: View contacts list
    Given I have contacts "Bob", "Carol", and "Dave"
    When I open the contacts screen
    Then I should see all three contacts listed
    And contacts should show their display names
    And contacts should show their avatars if available

  @view @implemented
  Scenario: View contact details
    Given I have contact "Bob" with phone "555-1234" and email "bob@test.com"
    When I tap on Bob's contact
    Then I should see Bob's display name
    And I should see Bob's phone number "555-1234"
    And I should see Bob's email "bob@test.com"
    And I should see when we exchanged contacts

  @view @implemented
  Scenario: Contact shows only fields I can see
    Given Bob has hidden his personal phone from me
    When I view Bob's contact details
    Then I should not see Bob's personal phone
    And I should only see fields Bob has made visible to me

  @view @implemented
  Scenario: Empty contacts list
    Given I have no contacts
    When I open the contacts screen
    Then I should see a message "No contacts yet"
    And I should see a prompt to exchange contacts

  # Searching and Filtering

  @search @implemented
  Scenario: Search contacts by name
    Given I have 50 contacts
    When I search for "Bob"
    Then I should see contacts with "Bob" in their name
    And other contacts should be filtered out

  @search @implemented
  Scenario: Search contacts by field value
    Given I have contacts with various phone numbers
    When I search for "555-1234"
    Then I should see contacts with that phone number
    And the matching field should be highlighted

  @filter @implemented
  Scenario: Filter contacts by group
    Given I have contacts in groups "Work" and "Friends"
    When I filter by group "Work"
    Then I should only see contacts in the "Work" group

  @filter @implemented
  Scenario: Sort contacts alphabetically
    Given I have contacts "Zara", "Alice", and "Mike"
    When I sort by name ascending
    Then contacts should appear in order: "Alice", "Mike", "Zara"

  @filter @implemented
  Scenario: Sort contacts by recent interaction
    Given I exchanged with Bob yesterday and Carol today
    When I sort by recent interaction
    Then Carol should appear before Bob

  # Contact Groups

  @groups @implemented
  Scenario: Create a contact group
    When I create a new group named "Family"
    Then the group "Family" should be created
    And the group should be empty initially
    # promoted_to: tui!68, desktop!101

  @groups @implemented
  Scenario: Add contact to group
    Given I have a group "Family"
    And I have contact "Bob"
    When I add Bob to group "Family"
    Then Bob should appear in the "Family" group
    And Bob should still appear in "All Contacts"
    # promoted_to: tui!68, desktop!101

  @groups @implemented
  Scenario: Contact in multiple groups
    Given I have groups "Friends" and "Colleagues"
    And I have contact "Carol"
    When I add Carol to both groups
    Then Carol should appear in "Friends"
    And Carol should appear in "Colleagues"
    # promoted_to: tui!68, desktop!101

  @groups @implemented
  Scenario: Remove contact from group
    Given Bob is in group "Work"
    When I remove Bob from group "Work"
    Then Bob should not appear in the "Work" group
    But Bob should still be in my contacts
    # promoted_to: tui!68, desktop!101

  @groups @implemented
  Scenario: Delete a group
    Given I have a group "Old Friends" with contacts
    When I delete the group "Old Friends"
    Then the group should be removed
    But the contacts should remain in my contact list
    # promoted_to: tui!68, desktop!101

  @groups @implemented
  Scenario: Rename a group
    Given I have a group "Work"
    When I rename it to "Office"
    Then the group should be named "Office"
    And all contacts in it should remain
    # promoted_to: tui!68, desktop!101

  # Removing Contacts

  @remove @implemented
  Scenario: Remove a contact
    Given I have contact "Dave"
    When I remove Dave from my contacts
    And I confirm the removal
    Then Dave should no longer appear in my contacts
    And Dave should no longer receive my updates

  @remove @implemented
  Scenario: Cancel contact removal
    Given I have contact "Dave"
    When I attempt to remove Dave
    And I cancel the removal
    Then Dave should still be in my contacts

  @remove @implemented
  Scenario: Remove contact cleans up visibility rules
    Given I have custom visibility rules for Dave
    When I remove Dave from my contacts
    Then all visibility rules for Dave should be deleted

  # Blocking Contacts

  @block @implemented
  Scenario: Block a contact
    Given I have contact "Eve" who is spamming updates
    When I block Eve
    Then Eve should be added to my blocked list
    And Eve should not receive my updates
    And I should not receive updates from Eve

  @block @implemented
  Scenario: View blocked contacts
    Given I have blocked "Eve" and "Mallory"
    When I view my blocked contacts list
    Then I should see Eve and Mallory
    And I should have option to unblock each

  @block @implemented
  Scenario: Unblock a contact
    Given Eve is blocked
    When I unblock Eve
    Then Eve should be removed from blocked list
    And Eve should be able to receive my updates again
    And I should receive updates from Eve again

  @block @implemented
  Scenario: Blocked contact cannot re-exchange
    Given Eve is blocked
    When Eve tries to exchange contacts with me
    Then the exchange should be rejected
    And Eve should see "Exchange declined"

  # Favorites

  @favorites @implemented
  Scenario: Mark contact as favorite
    Given I have contact "Bob"
    When I mark Bob as favorite
    Then Bob should appear in my favorites section
    And Bob should have a favorite indicator

  @favorites @implemented
  Scenario: Remove favorite
    Given Bob is a favorite contact
    When I remove Bob from favorites
    Then Bob should not appear in favorites section
    But Bob should still be in my contacts

  @favorites @implemented
  Scenario: Favorites appear first in list
    Given I have favorite "Bob" and non-favorite "Alice"
    When I view my contacts
    Then Bob should appear before Alice

  # Contact Notes

  @notes @implemented
  Scenario: Add personal note to contact
    Given I have contact "Carol"
    When I add note "Met at conference 2024"
    Then Carol should have the note attached
    And the note should only be visible to me

  @notes @implemented
  Scenario: Edit contact note
    Given Carol has note "Met at conference 2024"
    When I edit the note to "Met at tech conference, works at Acme"
    Then Carol's note should be updated

  @notes @implemented
  Scenario: Delete contact note
    Given Carol has a note
    When I delete Carol's note
    Then Carol should have no note attached

  @notes @implemented
  Scenario: Notes are not shared with contact
    Given I have a note on Bob's contact
    When Bob views my contact card
    Then Bob should not see my note about him

  # Contact Actions — moved to features/contact_actions.feature (canonical location).
  # Removed duplicate scenarios that were @planned here but @implemented there.
  # See: audit 2026-03-23, finding H9.

  # Sharing Contact Info

  @share @no-message @planned
  Scenario: Share contact info externally
    Given Bob has phone "555-1234"
    When I select to share Bob's phone
    Then I should be able to copy it
    And I should be able to share via system share sheet
    But no in-app messaging should be available

  @share @implemented
  Scenario: Export contact to vCard
    Given I have contact Bob
    When I export Bob as vCard
    Then a .vcf file should be generated
    And it should contain Bob's visible contact info

  # Contact List Limits

  @limits @implemented
  Scenario: Maximum contacts reached
    Given I have 9,999 contacts
    When I exchange with a new contact
    Then the exchange should succeed
    And I should have 10,000 contacts

  @limits @implemented
  Scenario: Exceed maximum contacts
    Given I have 10,000 contacts
    When I try to exchange with a new contact
    Then I should see "Contact limit reached"
    And I should be prompted to remove a contact first

  # Merge Contacts

  @merge @implemented
  Scenario: Detect potential duplicate contacts
    Given I have "Bob Smith" and "Robert Smith" with same email
    When I view my contacts
    Then I should see a suggestion to merge duplicates
    And both contacts should be flagged

  @merge @implemented
  Scenario: Merge duplicate contacts
    Given I have identified duplicates "Bob Smith" and "Robert Smith"
    When I select to merge them
    And I choose "Bob Smith" as primary
    Then only "Bob Smith" should remain
    And all contact info should be preserved

  @merge @implemented
  Scenario: Dismiss duplicate suggestion
    Given I see a duplicate suggestion for Bob and Robert
    When I dismiss the suggestion
    Then both contacts should remain separate
    And the suggestion should not reappear

  # --- Contact Nickname, Custom Avatar & Shared Names ---

  @nickname @planned
  Scenario: Set and display custom nickname
    Given I have an exchanged contact "Bob"
    When I set the nickname "Bobby" for contact "Bob"
    Then the nickname for contact "Bob" is "Bobby"

  @nickname @planned
  Scenario: Choose between shared names and nickname
    Given I have an exchanged contact "Bob"
    And the contact "Bob" has shared names "Bob Smith" and "lissa"
    When I set the nickname "Bobby" for contact "Bob"
    And I set the display name preference to "custom" for contact "Bob"
    Then the resolved display name for contact "Bob" is "Bobby"

  @avatar @planned
  Scenario: Upload custom avatar
    Given I have an exchanged contact "Bob"
    When I set a custom WebP avatar for contact "Bob"
    Then the contact "Bob" has a custom avatar

  @nickname @planned
  Scenario: Select a shared name
    Given I have an exchanged contact "Bob"
    And the contact "Bob" has shared names:
      | name       | is_primary |
      | Bob Smith  | true       |
      | lissa      | false      |
      | Dr. Smith  | false      |
    When I set the display name preference to shared name "lissa" for contact "Bob"
    Then the resolved display name for contact "Bob" is "lissa"

  @nickname @planned
  Scenario: Sync delta adds and removes shared names
    Given I have an exchanged contact "Bob" with shared name "Bob Smith"
    When a sync delta adds shared name "lissa" for contact "Bob"
    And a sync delta removes shared name "Bob Smith" for contact "Bob"
    Then the contact "Bob" has shared names "lissa"

  @nickname @planned
  Scenario: Display follows selected shared name after sync update
    Given I have an exchanged contact "Bob"
    And the contact "Bob" has shared names "Bob Smith" and "lissa"
    And I set the display name preference to shared name "lissa"
    When the shared name "lissa" is removed by a sync delta
    Then the resolved display name for contact "Bob" falls back to primary

  @merge @planned
  Scenario: Cross-kind merge with name and avatar adoption
    Given I have an exchanged contact "Bob"
    And I have an imported contact "Robert" with avatar
    When I merge "Robert" into "Bob" with name and avatar adoption
    Then the nickname for contact "Bob" is "Robert"
    And the contact "Bob" has a custom avatar
    And the imported contact "Robert" no longer exists

  @merge @planned
  Scenario: Cross-kind merge with notes preservation
    Given I have an exchanged contact "Bob"
    And I have an imported contact "Robert" with phone "555-1234"
    When I merge "Robert" into "Bob" with notes preservation
    Then the personal note for "Bob" contains "555-1234"
    And the imported contact "Robert" no longer exists

  @nickname @planned
  Scenario: Smart merge - sync delta stays when preference is nickname
    Given I have an exchanged contact "Bob"
    And I set the nickname "Bobby" and display name preference to "custom"
    When a sync delta changes the primary name to "Robert"
    Then the resolved display name for contact "Bob" is "Bobby"
