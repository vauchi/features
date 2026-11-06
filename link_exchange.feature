# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
# SPDX-License-Identifier: GPL-3.0-or-later

@exchange @link
Feature: Link contact exchange
  People exchange contact cards remotely using a shared link.

  Background:
    Given a user "Alice"
    And a user "Bob"

  @feature-driver @implemented
  Scenario: Two users exchange contact cards using a link
    When "Alice" shares an exchange link with "Bob"
    Then "Alice" has "Bob" as a contact
    And "Bob" has "Alice" as a contact

  @feature-driver @implemented
  Scenario: A malformed exchange link is rejected without adding contacts
    When "Bob" opens a malformed exchange link
    Then "Bob" is told the exchange link is invalid
    And "Alice" has no contacts
    And "Bob" has no contacts
