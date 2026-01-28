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

  @first-launch
  Scenario: Welcome screen on first launch
    Given I have never used Vauchi before
    When I launch the app
    Then I should see a welcome screen
    And it should briefly explain Vauchi's value proposition
    And there should be a "Get Started" button

  @first-launch
  Scenario: Value proposition is clear
    Given I am on the welcome screen
    Then I should understand:
      | Point | Message |
      | What | Contact cards that update automatically |
      | How | Exchange QR codes in person |
      | Why | Your contacts always have your current info |
    And the explanation should take less than 30 seconds to read

  @first-launch
  Scenario: Skip to restore for existing users
    Given I am on the welcome screen
    And I have a backup from another device
    When I tap "I have a backup"
    Then I should be guided to restore my identity
    And I should not go through new user onboarding

  @first-launch
  Scenario: Link to existing device
    Given I am on the welcome screen
    And I have Vauchi on another device
    When I tap "Link to existing device"
    Then I should be guided through device linking
    And my identity should transfer
    And onboarding should skip card creation

  # ============================================================
  # Card Creation
  # ============================================================

  @card-creation
  Scenario: Guided card creation wizard
    Given I tapped "Get Started"
    When I reach the card creation step
    Then I should see a friendly wizard
    And it should ask for my name first
    And it should suggest common fields to add
    And I should be able to skip optional fields

  @card-creation
  Scenario: Minimum viable card
    Given I am creating my card
    When I enter just my name
    Then I should be able to proceed
    And I should see "You can add more later"
    And I should not feel pressured to complete everything

  @card-creation
  Scenario: Quick add phone and email
    Given I am creating my card
    When I enter my name
    Then I should see quick-add buttons for phone and email
    And adding them should take one tap each
    And I should be able to skip

  @card-creation
  Scenario: Card preview before finishing
    Given I have entered my card information
    When I reach the preview step
    Then I should see how my card will look to others
    And I should be able to go back and edit
    And I should see a "Looks good!" button

  @card-creation
  Scenario: Suggest display name variations
    Given I entered my full name "Alexandra Johnson"
    When I reach the display name step
    Then I should see suggestions: "Alexandra", "Alex", "A. Johnson"
    And I should be able to pick one or type custom
    And I should understand this is what contacts see first

  # ============================================================
  # Security Explanation
  # ============================================================

  @security
  Scenario: Simple security explanation
    Given I am in the onboarding flow
    When I reach the security step
    Then I should see a simple explanation of E2E encryption
    And it should NOT use technical jargon
    And it should convey "Only you and your contacts can see your info"

  @security
  Scenario: Visual encryption explanation
    Given I am on the security step
    Then I should see a visual diagram
    And it should show: your phone ↔ their phone (no cloud in middle)
    And the message should be clear without reading text

  @security
  Scenario: Backup prompt
    Given I have created my identity
    When onboarding continues
    Then I should be prompted to set up backup
    And I should understand why backup matters
    And I should be able to "Remind me later"

  @security
  Scenario: Recovery setup prompt
    Given I completed basic onboarding
    When I am prompted about recovery
    Then I should understand the social recovery concept simply
    And I should be able to "Set up later"
    And the explanation should not be intimidating

  # ============================================================
  # First Exchange
  # ============================================================

  @first-exchange
  Scenario: Prompt for first exchange
    Given I completed card creation
    When I reach the main screen for the first time
    Then I should see a prominent invitation to exchange
    And it should say "Ready to exchange? Find someone nearby"
    And there should be a large QR code button

  @first-exchange
  Scenario: First exchange tutorial
    Given I tap the exchange button for the first time
    When the exchange screen opens
    Then I should see brief instructions overlay
    And it should explain "Show your code, scan theirs"
    And it should mention this is an in-person thing

  @first-exchange
  Scenario: Exchange success celebration
    Given I complete my first exchange
    Then I should see a celebration moment
    And it should explain "You'll see their updates automatically"
    And I should feel accomplished

  @first-exchange
  Scenario: Empty state with guidance
    Given I have no contacts yet
    When I view the contacts list
    Then I should see friendly empty state
    And it should invite me to exchange
    And there should be a button to start exchange

  # ============================================================
  # Demo Contact
  # ============================================================

  @demo
  Scenario: Demo contact for solo users
    Given I completed onboarding
    And I have no contacts yet
    When I view my contacts
    Then I should see a "Vauchi Tips" demo contact
    And it should be clearly marked as demo
    And I can delete it anytime

  @demo
  Scenario: Demo contact updates demonstrate value
    Given I have the demo contact
    When I open the app later
    And the demo contact has "updated"
    Then I should see an update indicator
    And tapping should show the changed field
    And I should understand this is how real updates work

  @demo
  Scenario: Demo contact is dismissible
    Given I have the demo contact
    When I delete it
    Then it should not reappear
    And I should not be pestered about it
    And I should still see onboarding tips elsewhere

  @demo
  Scenario: Demo contact removed after first real contact
    Given I have the demo contact
    When I complete my first real exchange
    Then the demo contact should be automatically removed
    Or I should be prompted to remove it
    And focus should shift to real contacts

  # ============================================================
  # Progress & Navigation
  # ============================================================

  @progress
  Scenario: Onboarding progress indicator
    Given I am in the onboarding flow
    Then I should see my progress (step 2 of 4)
    And I should know how much is left
    And completed steps should be checkmarked

  @progress
  Scenario: Can go back to previous steps
    Given I am on step 3 of onboarding
    When I tap the back button
    Then I should return to step 2
    And my entered data should be preserved
    And I should be able to change it

  @progress
  Scenario: Can skip optional steps
    Given I am on an optional onboarding step
    Then there should be a "Skip" or "Later" option
    And skipping should not break the flow
    And I should be reminded later in settings

  @progress
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

  @completion
  Scenario: Onboarding completion
    Given I finish all onboarding steps
    Then I should see a completion message
    And I should be taken to the main app
    And the onboarding should not repeat on next launch

  @completion
  Scenario: What's next guidance
    Given I completed onboarding
    When I see the main screen
    Then I should see contextual hints for next steps
    And hints should be dismissible
    And they should not be overwhelming

  @completion
  Scenario: Replay onboarding from settings
    Given I completed onboarding previously
    When I go to Settings > Help > Show Onboarding
    Then I should be able to replay the onboarding
    And my data should be preserved
    And it should be educational, not destructive

  # ============================================================
  # Time to Value
  # ============================================================

  @ttv
  Scenario: Complete onboarding in under 2 minutes
    Given I am a new user
    When I go through the minimal onboarding path
    Then I should be done in under 2 minutes
    And I should have a functional card
    And I should be ready to exchange

  @ttv
  Scenario: First exchange possible immediately
    Given I just completed onboarding
    When I find another Vauchi user
    Then I should be able to exchange immediately
    And no further setup should be required
    And the value should be apparent

  @ttv
  Scenario: Value clear even without exchange
    Given I completed onboarding alone
    Then I should still understand the value proposition
    And I should be motivated to find someone to exchange with
    And the app should not feel useless until then
