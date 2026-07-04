# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@visibility @privacy
Feature: Visibility Control
  As a Vauchi user
  I want to control which contacts can see which of my contact fields
  So that I can share different information with different people

  Background:
    Given I have an existing identity as "Alice"
    And I have the following fields on my contact card:
      | type  | label          | value              |
      | phone | Personal Phone | +1-555-111-1111    |
      | phone | Work Phone     | +1-555-222-2222    |
      | email | Personal Email | alice@personal.com |
      | email | Work Email     | alice@work.com     |
    And I have a contact "Bob"
    And I have a contact "Carol"
    And I have a contact "Dave"

  # Default Visibility

  @default @implemented
  Scenario: New fields default to hidden
    When I add a phone field "Mobile" with value "+1-555-333-3333"
    Then no contact can see my "Mobile" field
    And the field stays hidden until I explicitly grant visibility

  @default @implemented
  Scenario: New contacts see fields I made visible to all
    Given all my fields are set to "visible to all"
    When I exchange contacts with "Eve"
    Then Eve should see all four of my contact fields

  # Setting Individual Visibility

  @individual @implemented
  Scenario: Hide a field from a specific contact
    When I hide field "Personal Phone" from contact "Dave"
    Then contact "Bob" can see my "Personal Phone" field
    And contact "Carol" can see my "Personal Phone" field
    But contact "Dave" cannot see my "Personal Phone" field

  @individual @implemented
  Scenario: Show a field only to specific contacts
    When I make field "Work Phone" visible only to contacts "Bob, Carol"
    Then contact "Bob" can see my "Work Phone" field
    And contact "Carol" can see my "Work Phone" field
    But contact "Dave" cannot see my "Work Phone" field

  @individual @implemented
  Scenario: Make a field private (visible to none)
    When I make field "Personal Email" private
    Then contact "Bob" cannot see my "Personal Email" field
    And contact "Carol" cannot see my "Personal Email" field
    And contact "Dave" cannot see my "Personal Email" field

  # Group Visibility

  @groups @implemented
  Scenario: Create a visibility group
    Given I have a visibility group "Close Friends"
    When I add contact "Bob" to group "Close Friends"
    And I add contact "Carol" to group "Close Friends"
    Then group "Close Friends" contains contact "Bob"
    And group "Close Friends" contains contact "Carol"
    But group "Close Friends" does not contain contact "Dave"

  @groups @implemented
  Scenario: Apply visibility group to a field
    Given I have a visibility group "Work Contacts"
    And contact "Carol" is in group "Work Contacts"
    And contact "Dave" is in group "Work Contacts"
    When I make field "Work Email" visible only to group "Work Contacts"
    Then contact "Carol" can see my "Work Email" field
    And contact "Dave" can see my "Work Email" field
    But contact "Bob" cannot see my "Work Email" field

  @groups @implemented
  Scenario: Add contact to group updates their visibility
    Given I have a visibility group "Work Contacts"
    And contact "Carol" is in group "Work Contacts"
    And I make field "Work Email" visible only to group "Work Contacts"
    When I add contact "Bob" to group "Work Contacts"
    Then contact "Bob" can see my "Work Email" field
    And contact "Carol" can see my "Work Email" field

  @groups @implemented
  Scenario: Remove contact from group updates their visibility
    Given I have a visibility group "Work Contacts"
    And contact "Carol" is in group "Work Contacts"
    And I make field "Work Email" visible only to group "Work Contacts"
    When I remove contact "Carol" from group "Work Contacts"
    Then contact "Carol" cannot see my "Work Email" field

  # Visibility Changes Propagation

  @propagation @implemented
  Scenario: Granting visibility sends update to contact
    Given my "Personal" phone is hidden from Dave
    And Dave is online
    When I make "Personal" phone visible to Dave
    Then Dave should receive an encrypted update
    And Dave should now see my "Personal" phone number

  @propagation @implemented
  Scenario: Revoking visibility sends update to contact
    Given my "Personal" phone is visible to Dave
    And Dave is online
    When I hide "Personal" phone from Dave
    Then Dave should receive an encrypted update
    And my "Personal" phone should be removed from Dave's view
    And Dave should see the updated contact card

  @propagation @implemented
  Scenario: Visibility change when contact is offline
    Given my "Personal" phone is visible to Dave
    And Dave is offline
    When I hide "Personal" phone from Dave
    Then the update should be queued for Dave
    And when Dave comes online
    Then Dave should receive the update
    And my "Personal" phone should be removed from Dave's view

  # Visibility and New Contacts

  @new-contact @planned
  Scenario: Set visibility before exchange
    Given I have marked "Personal" phone as "exchange with explicit consent only"
    When I exchange contacts with "Eve"
    Then I should be prompted to choose visibility for Eve
    And Eve should only see fields I approve

  @new-contact @implemented
  Scenario: Apply template visibility to new contact
    Given I have a visibility template "Professional"
    And "Professional" template shows only work fields
    When I exchange with Eve and apply "Professional" template
    Then Eve should see my "Work" phone
    And Eve should see my "Work" email
    But Eve should not see my "Personal" phone
    But Eve should not see my "Personal" email

  # Visibility Rules Persistence

  @persistence @implemented
  Scenario: Visibility settings persist after app restart
    Given I have set custom visibility for multiple fields
    When I restart the application
    Then all visibility settings should be preserved
    And Bob, Carol, and Dave should see the same fields as before

  @persistence @planned
  Scenario: Visibility settings sync across my devices
    Given I have custom visibility settings on Device A
    When I link Device B to my identity
    Then Device B should have the same visibility settings
    And changes on either device should sync to the other

  # Visibility Verification

  @verification @implemented
  Scenario: View what a specific contact can see
    Given I have various visibility settings
    When I select "View as Bob"
    Then I should see my contact card as Bob sees it
    And hidden fields should not be displayed

  @verification @implemented
  Scenario: Visibility audit shows all contacts for a field
    Given my "Personal" phone has custom visibility
    When I view visibility details for "Personal" phone
    Then I should see a list of contacts who can see it
    And I should see a list of contacts who cannot see it

  # Edge Cases

  @edge-cases @implemented
  Scenario: Delete contact removes their visibility rules
    Given I have custom visibility rules for Dave
    When I delete Dave from my contacts
    Then all visibility rules for Dave should be removed
    And if I later re-add Dave, default visibility should apply

  @edge-cases @implemented
  Scenario: Block contact removes all their visibility
    Given Dave can see all my fields
    When I block Dave
    Then Dave should not be able to see any of my fields
    And Dave should not receive future updates

  @edge-cases @planned
  Scenario: Blocking offers a final wipe of my info
    Given Dave can see all my fields
    When I block Dave
    Then I should be asked whether to remove my info from Dave's device
    And if I confirm, Dave should receive one final update with an empty contact card
    And no further updates should ever be sent to Dave

  @edge-cases @planned
  Scenario: Unblock contact restores previous visibility
    Given I have blocked Dave
    And Dave previously could see my "Work" fields
    When I unblock Dave
    Then Dave should be able to see my "Work" fields again
    And Dave should receive an update with the restored fields

  # Privacy Protection

  @privacy @implemented
  Scenario: Contact cannot determine hidden field existence
    Given I have a "Personal" phone hidden from Dave
    When Dave views my contact card
    Then Dave should not see the "Personal" phone field
    And Dave should have no indication that the field exists
    And the data sent to Dave should not contain the hidden field

  @privacy @implemented
  Scenario: Encrypted updates reveal nothing about hidden fields
    Given I have fields hidden from Dave
    When I update a field that Dave cannot see
    Then Dave should not receive any update
    And no network traffic should go to Dave for this update

  @privacy @implemented
  Scenario: Visibility changes are atomic
    Given I am making multiple visibility changes
    When I save the changes
    Then all changes should be applied atomically
    And contacts should receive a single update
    And there should be no intermediate inconsistent state visible

  # Bulk Operations

  @bulk @implemented
  Scenario: Set visibility for all fields at once
    Given I have 10 contact fields
    When I select "Set all to visible for Bob only"
    Then all 10 fields should be visible only to Bob
    And other contacts should not see any fields

  @bulk @implemented
  Scenario: Reset all visibility to default
    Given I have various custom visibility settings
    When I select "Reset all to default"
    And I confirm the action
    Then all fields should revert to hidden (the default)
    And contacts who could see fields should receive updates removing them
