# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @shred
Feature: Relay purge signing
  As a Vauchi user who deletes my identity
  I want the relay purge signed at the moment it is sent
  So that the relay accepts it and erases what it holds for me

  The relay accepts a purge only within 60 seconds of its timestamp, so a
  purge signed in advance would be refused (vauchi/private#899), and an
  emergency wipe sends nothing (#910). Earlier versions stored pre-signed
  messages on the device; they are retired (#911), and any shred removes
  what an older version left.

  Background:
    Given I have an existing identity

  @deletion @implemented
  Scenario: Identity deletion signs its purge when it sends it
    Given I scheduled my identity's deletion a week ago
    When the deletion runs
    Then the purge it sends is signed at that moment
    And the relay accepts it

  @deletion @implemented
  Scenario: Scheduling a deletion stores no pre-signed messages
    When I schedule my identity's deletion
    Then no pre-signed message is stored on the device

  @storage @implemented
  Scenario: A shred removes pre-signed messages an older version stored
    Given an older version left pre-signed messages on the device
    When any shred runs on the device
    Then the pre-signed messages are gone
    And the shred report says so

  @crypto @implemented
  Scenario: Relay can verify purge request signature
    Given I have a purge request signed now
    Then the signature should be valid over (public_key || purge_token || timestamp)
    And the relay should accept the signature using my public key

  @crypto @implemented
  Scenario: Tampered pre-signed message is rejected
    Given I have a purge request signed now
    When the purge token is modified
    Then the signature verification should fail
    And the relay should reject the request

  @crypto @implemented
  Scenario: Each purge carries its own one-time token
    When I sign two purge requests
    Then their purge tokens differ

  @deletion @implemented
  Scenario: Contacts verify the revocation a deletion sends
    Given I have contacts Alice and Bob
    When my identity's deletion runs
    Then each contact receives a revocation signed by my identity key
