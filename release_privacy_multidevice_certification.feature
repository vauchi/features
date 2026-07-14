# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@release-gate @privacy @multi-device
Feature: Release privacy and multi-device certification
  As the release owner
  I want one production-topology certification result
  So that component tests cannot hide broken convergence or privacy

  Background:
    Given Alice has linked active devices A1, A2, and A3
    And Bob has linked active devices B1, B2, and B3
    And the OHTTP relay and application relay have distinct operators
    And ordinary relay traffic must traverse the OHTTP relay

  @rg-2 @rg-3 @ohttp @implemented
  Scenario: Exact two-user update propagates through both privacy hops
    Given Alice and Bob completed a mutual exchange
    When Alice changes her email to "alice-release@example.test"
    And Alice synchronizes through the OHTTP relay and application relay
    Then Bob's contact for Alice has email "alice-release@example.test"
    And neither relay observation contains that email

  @rg-4 @rg-5 @adr-064 @planned
  Scenario Outline: Every active device can exchange and update
    When <alice_device> completes an exchange with <bob_device>
    And <alice_device> changes Alice's phone to <phone>
    And all six devices synchronize through both relays
    Then A1, A2, and A3 converge on Alice's phone <phone>
    And B1, B2, and B3 converge on Alice's permitted phone <phone>
    And every active device pair uses an independent ratchet session

    Examples:
      | alice_device | bob_device | phone    |
      | A1           | B1         | +410001  |
      | A2           | B2         | +410002  |
      | A3           | B3         | +410003  |

  @rg-10 @adr-020 @adr-051 @adr-054 @planned
  Scenario: Complete owner-private state converges across linked devices
    When Alice changes MyInfo fields including a removal on A2
    And Alice changes group identity, membership, visibility, and overrides
    And Alice changes and deletes tags on A3
    And Alice changes contacts and private notes on A1
    And all six devices synchronize
    Then A1, A2, and A3 have the same canonical owner-private state
    And Bob receives only the presentation state permitted to each device
    And no group name, membership, tag, or private note reaches Bob or a relay

  @rg-4 @rg-10 @faults @planned
  Scenario: Faulted delivery still converges deterministically
    Given one device for each user is offline
    When updates are simultaneous with bounded clock skew
    And delivery is retried, duplicated, reordered, and interrupted by restart
    And the offline devices return
    Then all active devices converge on the ADR-020 winner
    And no accepted update is silently lost

  @rg-4 @rg-5 @rg-15 @device-lifecycle @planned
  Scenario: Revocation and replacement preserve continuity
    Given Alice and Bob exchanged before a device was lost
    When Alice revokes A2 and replaces it with A4 while updates are pending
    And all active devices synchronize
    Then A1, A3, and A4 converge with Bob's active devices
    And A2 cannot send, receive, or resume a valid session
    And Alice and Bob do not need to exchange again

  @rg-6 @privacy @adversarial @planned
  Scenario: Neither relay can decrypt or identify application users
    When the complete six-device scenario runs
    Then neither relay storage, logs, metrics, traces, or errors contain data
    And no service-held secret can decrypt a user update
    And relay observations contain no stable user or device identifier
    And rotating mailbox observations cannot be joined into a stable user

  @rg-7 @adr-037 @deployment @planned
  Scenario: Application relay sees the gateway under a distinct operator
    When Alice synchronizes from a representative end-user network
    Then the application relay observes the OHTTP gateway address
    And it does not observe Alice's end-user address
    And the two relays have different operator identities and hosts

  @rg-8 @fail-closed @planned
  Scenario Outline: Weaker transport cannot bypass OHTTP
    Given the production consumer is <consumer>
    When <failure> prevents valid OHTTP transport
    Then the operation fails closed before reaching the application relay
    And no direct, plaintext, or TLS-only fallback is attempted

    Examples:
      | consumer | failure                    |
      | CLI      | the outer relay is down    |
      | TUI      | the outer key is malformed |
      | native   | direct mode is injected    |
      | E2E      | same-operator config loads |

  @rg-15 @pending-decision @planned
  Scenario: Undefined ignore behavior keeps longitudinal release blocked
    Given no accepted product meaning for ignoring a relationship exists
    When long-lived contact continuity is evaluated
    Then RG-15 remains blocked
    And no partial lifecycle scenario is accepted as continuity evidence
