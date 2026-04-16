# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@onboarding
Feature: Onboarding Experience
  As a new Vauchi user
  I want a guided first experience
  So that I understand the app and create my identity easily
  # ============================================================
  # First Launch
  # ============================================================

  @first-launch @implemented
  Scenario: Identity check on first launch
    Given I have never used Vauchi before
    When I launch the app
    Then I should see an identity check screen
    And I should be able to create a new identity
    And I should be able to restore an existing identity

  @first-launch @implemented
  Scenario: Skip to restore for existing users
    Given I am on the identity check screen
    And I have a backup from another device
    When I tap "I already have an identity"
    Then I should be guided to restore my identity
    And I should not go through new user onboarding

  @first-launch @implemented
  Scenario: Link to existing device
    Given I am on the identity check screen
    And I have Vauchi on another device
    When I tap "I already have an identity"
    Then I should be guided through device linking
    And my identity should transfer
    And onboarding should skip card creation
  # ============================================================
  # Card Creation
  # ============================================================

  @card-creation @implemented
  Scenario: Guided card creation
    Given I tapped "Create new identity"
    When I reach the card creation step
    Then it should ask for my name first
    And I should be able to set up groups
    And I should be able to add contact fields
    And I should be able to skip optional steps

  @card-creation @implemented
  Scenario: Minimum viable card
    Given I am creating my card
    When I enter just my name
    Then I should be able to proceed
    And I should be able to skip groups and contact info
    And I should not feel pressured to complete everything

  @card-creation @planned
  Scenario: Quick add phone and email
    Given I am creating my card
    When I enter my name
    Then I should see quick-add buttons for phone and email
    And adding them should take one tap each
    And I should be able to skip

  @card-creation @implemented
  Scenario: Suggest display name variations
    Given I entered my full name "Alexandra Johnson"
    When I reach the display name step
    Then I should see suggestions: "Alexandra", "Alex", "A. Johnson"
    And I should be able to pick one or type custom
    And I should understand this is what contacts see first
  # ============================================================
  # What Next (post-onboarding choices)
  # ============================================================

  @what-next @implemented
  Scenario: User chooses next action after onboarding
    Given I completed card setup
    When I reach the "What would you like to do?" screen
    Then I should see options to:
      | option                    |
      | Exchange cards            |
      | Import existing contacts  |
      | Read about security       |
      | Read about backup         |
      | Start using the app       |
    And all options should complete onboarding
    And I should be taken to the chosen destination

  @what-next @implemented
  Scenario: Security info accessible from WhatNext
    Given I am on the WhatNext screen
    When I choose "Read about security"
    Then I should see information about E2E encryption
    And it should convey "Only you and your contacts can see your info"

  @what-next @implemented
  Scenario: Backup accessible from WhatNext
    Given I am on the WhatNext screen
    When I choose "Read about backup"
    Then I should be taken to the backup setup screen
    And I should understand why backup matters
  # ============================================================
  # First Exchange
  # ============================================================

  @first-exchange @implemented
  Scenario: Prompt for first exchange
    Given I completed card creation
    When I reach the main screen for the first time
    Then I should see a prominent invitation to exchange
    And it should say "Ready to exchange? Find someone nearby"
    And there should be a large QR code button

  @first-exchange @implemented
  Scenario: First exchange tutorial
    Given I tap the exchange button for the first time
    When the exchange screen opens
    Then I should see brief instructions overlay
    And it should explain "Show your code, scan theirs"
    And it should mention this is an in-person thing

  @first-exchange @implemented
  Scenario: Exchange success celebration
    Given I complete my first exchange
    Then I should see a celebration moment
    And it should explain "You'll see their updates automatically"
    And I should feel accomplished

  @first-exchange @implemented
  Scenario: Empty state with guidance
    Given I have no contacts yet
    When I view the contacts list
    Then I should see friendly empty state
    And it should invite me to exchange
    And there should be a button to start exchange
  # ============================================================
  # Demo Contact
  # ============================================================

  @demo @implemented
  Scenario: Demo contact for solo users
    Given I completed onboarding
    And I have no contacts yet
    When I view my contacts
    Then I should see a "Vauchi Tips" demo contact
    And it should be clearly marked as demo
    And I can delete it anytime

  @demo @implemented
  Scenario: Demo contact updates demonstrate value
    Given I have the demo contact
    When I open the app later
    And the demo contact has "updated"
    Then I should see an update indicator
    And tapping should show the changed field
    And I should understand this is how real updates work

  @demo @implemented
  Scenario: Demo contact is dismissible
    Given I have the demo contact
    When I delete it
    Then it should not reappear
    And I should not be pestered about it
    And I should still see onboarding tips elsewhere

  @demo @implemented
  Scenario: Demo contact removed after first real contact
    Given I have the demo contact
    When I complete my first real exchange
    Then the demo contact should be automatically removed
    # Or I should be prompted to remove it
    And focus should shift to real contacts
  # ============================================================
  # 4-Step Onboarding Flow
  # ============================================================

  @default-name @implemented
  Scenario: User enters default name during onboarding
    Given I am on the default name step
    When I enter "Alice Johnson"
    Then my identity should be created with display name "Alice Johnson"
    And I should see name suggestions
      | suggestion |
      | Alice      |
      | Ali        |
      | A. Johnson |

  @groups-setup @implemented
  Scenario: User creates groups during onboarding
    Given I am on the groups setup step
    Then I should see suggested groups
      | group     |
      | Family    |
      | Friends   |
      | Coworkers |
      | Business  |
    When I select "Family" and "Friends"
    And I set the name for "Friends" to "Matt"
    And I advance to the next step
    Then I should have 2 groups
    And the "Friends" group should have name override "Matt"

  @contact-info @implemented
  Scenario: User adds contact info with no-group visibility
    Given I have no groups
    And I am on the contact info step
    When I add an email field "work@example.com" with label "Work"
    Then the field should be hidden by default
    When I toggle the field to shown
    Then the field should be visible to all contacts

  @contact-info @groups @implemented
  Scenario: User adds contact info with per-group visibility
    Given I have groups "Family" and "Friends"
    And I am on the contact info step
    When I add a phone field "+1234567890" with label "Mobile"
    Then the field should be hidden by default
    When I assign the field to group "Family"
    Then the field should be visible to Family contacts
    And the field should not be visible to Friends contacts
  # ============================================================
  # Progress & Navigation
  # ============================================================

  @progress @implemented
  Scenario: Onboarding progress indicator
    Given I am in the onboarding flow
    Then I should see my progress (step N of 4)
    And I should know how much is left

  @progress @implemented
  Scenario: Can go back to previous steps
    Given I am on step 3 of onboarding
    When I tap the back button
    Then I should return to step 2
    And my entered data should be preserved
    And I should be able to change it

  @progress @implemented
  Scenario: Can skip optional steps
    Given I am on an optional onboarding step
    Then there should be a "Skip" or "Later" option
    And skipping should not break the flow
    And I should be reminded later in settings

  @progress @implemented
  Scenario: Exit and resume onboarding
    Given I am halfway through onboarding
    When I close the app
    And I reopen it later
    Then I should resume where I left off
    And entered data should be preserved
    And I should not start over
  # ============================================================
  # Completion
  # ============================================================

  @completion @implemented
  Scenario: Onboarding completion via WhatNext
    Given I finish all onboarding steps
    Then I should see "What would you like to do?"
    And I should choose my next action
    And the onboarding should not repeat on next launch

  @completion @implemented
  Scenario: Replay onboarding from settings
    Given I completed onboarding previously
    When I go to Settings > Help > Show Onboarding
    Then I should be able to replay the onboarding
    And my data should be preserved
    And it should be educational, not destructive
  # ============================================================
  # Time to Value
  # ============================================================

  @ttv @implemented
  Scenario: Complete onboarding in under 30 seconds
    Given I am a new user
    When I go through the minimal onboarding path
    Then I should be done in under 30 seconds
    And I should have a functional card
    And I should be ready to exchange

  @ttv @implemented
  Scenario: First exchange possible immediately
    Given I just completed onboarding
    When I find another Vauchi user
    Then I should be able to exchange immediately
    And no further setup should be required
    And the value should be apparent

  @ttv @implemented
  Scenario: Value clear even without exchange
    Given I completed onboarding alone
    Then I should still understand the value proposition
    And I should be motivated to find someone to exchange with
    And the app should not feel useless until then
