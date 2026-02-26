# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@aha @onboarding @ux
Feature: Aha Moments
  As a new Vauchi user
  I want to see helpful feedback and celebrations at key moments
  So that I understand the value of the app before finding a second user

  Background:
    Given the Vauchi app is installed
    And the user has completed onboarding

  # ============================================================
  # Card Creation Celebration
  # ============================================================

  @card-creation @planned
  Scenario: Card creation shows completion message
    Given I have just created my identity
    And my contact card is ready
    When the card creation completes
    Then I should see an aha moment overlay
    And the message should say "Your card is ready"
    And there should be a brief explanation about auto-updates
    And the overlay should be dismissible

  @card-creation @planned
  Scenario: Card creation celebration is shown once
    Given I have seen the card creation aha moment
    When I navigate away and return to my card
    Then I should not see the aha moment again

  # ============================================================
  # First Edit Feedback
  # ============================================================

  @first-edit @planned
  Scenario: First edit shows would-update feedback
    Given I have created my contact card
    And I have not yet added any contacts
    When I edit a field on my card for the first time
    Then I should see a subtle feedback message
    And the message should say "If anyone had your card, they'd see this change instantly"
    And there may be a brief ripple animation

  @first-edit @planned
  Scenario: First edit feedback shown only once
    Given I have seen the first edit feedback
    When I edit my card again
    Then I should not see the first edit feedback
    But the edit should still succeed

  @first-edit @planned
  Scenario: Edit with contacts shows delivery feedback
    Given I have contacts Bob and Alice
    When I edit my contact card
    Then I should see "Update sent to 2 contacts"
    And this is different from the first-edit aha moment

  # ============================================================
  # First Contact Celebration
  # ============================================================

  @first-contact @planned
  Scenario: First contact added celebration
    Given I have no contacts
    When I complete an exchange with Bob
    Then I should see a celebration overlay
    And the message should mention Bob's name
    And explain that I'll see Bob's updates automatically

  @first-contact @planned
  Scenario: Subsequent contacts do not show celebration
    Given I have already added my first contact
    When I complete an exchange with Alice
    Then I should not see the first-contact celebration
    But I should see a normal success message

  # ============================================================
  # First Received Update
  # ============================================================

  @first-update @planned
  Scenario: First received update shows diff view
    Given Bob is my contact
    And Bob has updated his phone number
    When I sync and receive Bob's update
    And this is the first update I've ever received
    Then I should see a special aha moment
    And it should show a before/after diff
    And explain "This is the magic - Bob updated, you see it"

  @first-update @planned
  Scenario: Subsequent updates do not show aha moment
    Given I have received updates before
    When I receive another update from a contact
    Then I should see a normal update notification
    But not the first-update aha moment

  # ============================================================
  # First Outbound Update (with contacts)
  # ============================================================

  @first-outbound @planned
  Scenario: First outbound update shows delivery confirmation
    Given I have contacts
    And I have never sent an update before
    When I edit my card
    And the update is delivered
    Then I should see "Your update was delivered to X contacts"
    And this confirms the core value proposition

  # ============================================================
  # Aha Moment Persistence
  # ============================================================

  @persistence @planned
  Scenario: Aha moments are tracked per milestone
    Given I have seen the card-creation aha moment
    But I have not seen the first-edit aha moment
    When I edit my card for the first time
    Then I should see the first-edit aha moment
    And the card-creation moment should not repeat

  @persistence @planned
  Scenario: Aha moments persist across app restarts
    Given I have seen the card-creation aha moment
    When I force quit and relaunch the app
    Then I should not see the card-creation aha moment again

  # ============================================================
  # Dismissal and Accessibility
  # ============================================================

  @dismissal @planned
  Scenario: Aha moments can be dismissed
    When an aha moment overlay is shown
    Then I should be able to tap outside to dismiss
    Or tap a close button
    Or swipe down to dismiss

  @accessibility @planned
  Scenario: Aha moments are accessible
    Given VoiceOver or TalkBack is enabled
    When an aha moment overlay is shown
    Then the screen reader should announce the message
    And the dismiss action should be accessible
    And focus should be managed appropriately

  @accessibility @planned
  Scenario: Reduce motion respects system setting
    Given the user has enabled "Reduce Motion" in system settings
    When an aha moment with animation is triggered
    Then animations should be minimal or absent
    And the message content should still display
