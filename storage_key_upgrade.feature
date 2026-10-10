# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @shred @storage @cross-platform
Feature: Storage keys move into the platform keychain on upgrade
  As a Vauchi user updating from a version that kept its own storage key
  I want Vauchi to move every key that opens my data into the keychain
  So that deleting my data also destroys the keys, without losing anything
  on the way (vauchi/private#580)

  Background:
    Given an install from before #580 with an identity and contacts
    And its storage key kept by the app itself

  @implemented
  Scenario: The upgrade keeps everything and leaves only Core's key
    Given the keychain answers
    When the updated app starts
    Then the identity and every contact are still there
    And the keychain holds only the shredding master key
    And the app's own copy of the old key is gone

  @implemented
  Scenario: A keychain that needs an unlock starts on Core's unlock screen
    Given the keychain reads but refuses writes until the person unlocks
    When the updated app starts
    Then Core's unlock screen is shown
    And the platform's unlock prompt opens by itself
    And nothing has been deleted or rekeyed yet

  @implemented
  Scenario: Unlocking finishes the upgrade
    Given the updated app started on Core's unlock screen
    When the person unlocks with the platform prompt
    Then the identity and every contact are still there
    And the keychain holds only the shredding master key

  @implemented
  Scenario: A keychain that fails for another reason offers Try again
    Given the keychain refuses writes for a reason other than a lock
    When the updated app starts
    Then Core's try-again screen is shown
    And nothing has been deleted or rekeyed yet
