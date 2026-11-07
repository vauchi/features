# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
# SPDX-License-Identifier: GPL-3.0-or-later

@exchange @link
Feature: Link contact exchange
  People exchange contact cards remotely using a shared link and a code sent
  another way.

  Background:
    Given a user "Alice"
    And a user "Bob"

  @feature-driver @implemented
  Scenario: Two users exchange contact cards using a link
    When "Alice" shares an exchange link with "Bob"
    Then "Alice" has "Bob" as a contact
    And "Bob" has "Alice" as a contact

  @feature-driver @planned
  Scenario: A user exchanges contact cards with two people in succession
    Given a user "Carol"
    When "Alice" shares an exchange link with "Bob"
    Then "Alice" has "Bob" as a contact
    And "Bob" has "Alice" as a contact
    When "Alice" shares an exchange link with "Carol"
    Then "Alice" has "Bob" and "Carol" as contacts
    And "Bob" has "Alice" as a contact
    And "Carol" has "Alice" as a contact

  @feature-driver @implemented
  Scenario: A malformed exchange link is rejected without adding contacts
    When "Bob" opens a malformed exchange link
    Then "Bob" is told the exchange link is invalid
    And "Alice" has no contacts
    And "Bob" has no contacts

  @feature-driver @implemented
  Scenario: Users exchange contact cards after a malformed link is rejected
    When "Bob" opens a malformed exchange link
    Then "Bob" is told the exchange link is invalid
    And "Alice" has no contacts
    And "Bob" has no contacts
    When "Alice" shares an exchange link with "Bob"
    Then "Alice" has "Bob" as a contact
    And "Bob" has "Alice" as a contact

  @planned
  Scenario: A wrong code makes no contact
    When "Alice" shares an exchange link
    And "Bob" opens the exchange link with a wrong code
    Then "Alice" has no contacts
    And "Bob" has no contacts

  @planned
  Scenario: Opening a link without a code sends nothing
    When "Alice" shares an exchange link
    And "Bob" opens the exchange link without typing a code
    Then nothing from "Bob" reaches the relay
