# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @exchange @network
Feature: Relay Exchange Authentication
  As a Vauchi user exchanging cards through a relay
  I want to compare an authentication fingerprint with my contact
  So that a relay that substitutes its own keys is caught

  # The relay chooses both transcripts adaptively, so a short comparison
  # code would let it search for a collision (vauchi/private#925, claim S9).

  @implemented
  Scenario: Authentication comparison preserves the full tag
    Given Alice and Bob share a relay exchange secret
    When each derives the authentication fingerprint from it and both identity keys
    Then the fingerprint is the full 32-byte HMAC-SHA256 tag
    And it is shown as 8 groups of 8 hexadecimal digits

  @implemented
  Scenario: Adaptive relay transcripts remain distinguishable
    Given a relay answers Alice's offer and Bob's response with keys of its own
    When Alice and Bob each derive the authentication fingerprint
    Then their shared secrets differ
    And their fingerprints differ, so comparing them exposes the relay
