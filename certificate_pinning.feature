# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@security @network
Feature: Certificate Pinning
  As a Vauchi user
  I want relay connections to verify server certificate fingerprints
  So that man-in-the-middle attacks on TLS are detected and blocked

  Background:
    Given I have an existing identity
    And I have a relay configured with a pinned certificate

  # ============================================================
  # Pin Verification
  # ============================================================

  @pin @planned
  Scenario: Connection succeeds with matching certificate pin
    Given the relay presents a certificate matching the pinned fingerprint
    When I connect to the relay
    Then the connection should succeed
    And sync should proceed normally

  @pin @planned
  Scenario: Connection rejected with mismatched certificate
    Given the relay presents a certificate NOT matching the pinned fingerprint
    When I try to connect to the relay
    Then the connection should be rejected
    And I should see a security warning about certificate mismatch
    And no data should be sent to the relay

  @pin @planned
  Scenario: Multiple pins allow certificate rotation
    Given the relay has two pinned certificate fingerprints
    And the relay presents a certificate matching the second pin
    When I connect to the relay
    Then the connection should succeed
    And the matching pin should be identified

  @pin @planned
  Scenario: Empty pin list rejects all certificates
    Given the relay has no pinned certificates configured
    When I try to connect to the relay
    Then the connection should be rejected
    And I should see a configuration error

  # ============================================================
  # Pin Format
  # ============================================================

  @format @planned
  Scenario: Pin is SHA-256 hash of DER certificate
    Given I have a relay's DER-encoded certificate
    When I compute the certificate pin
    Then the pin should be the SHA-256 hash of the DER bytes
    And the pin should be exactly 32 bytes

  @format @planned
  Scenario: Pin computation is deterministic
    Given I compute the pin for the same certificate twice
    Then both pins should be identical

  # ============================================================
  # Security Properties
  # ============================================================

  @mitm @planned
  Scenario: Detect MITM with forged certificate
    Given an attacker intercepts my relay connection
    And the attacker presents a valid but different TLS certificate
    When my client verifies the certificate pin
    Then the pin check should fail
    And the connection should be terminated immediately
    And a security event should be logged

  @mitm @planned
  Scenario: Pin verification happens before sending data
    Given the relay presents a mismatched certificate
    When the TLS handshake completes
    Then pin verification should occur before any application data is sent
    And my identity should not be revealed to the impersonating server

  @rotation @planned
  Scenario: Graceful certificate rotation
    Given the relay operator is rotating certificates
    And both old and new certificate fingerprints are pinned
    When the relay switches to the new certificate
    Then connections should continue to succeed
    And the old pin can be removed after transition
