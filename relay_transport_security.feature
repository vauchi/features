# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@transport @security
Feature: Relay Transport Security
  As a Vauchi user
  I want every byte between my device and any relay to be encrypted
  So that no network position can read my data or link my traffic

  This file replaced noise_protocol.feature (2026-07-04). The
  Noise-NK-over-WebSocket client transport it specified was retired:
  ADR-004 is superseded, vauchi-core dropped its Noise and WebSocket
  modules, and the relay dropped the Noise transport and its snow
  dependency entirely. The client speaks the HTTPS-only v2 API with
  OHTTP encapsulation (ADR-037); "no plaintext, ever" is enforced at
  the URL parse boundary rather than by a handshake.

  Background:
    Given I have an existing identity as "Alice"
  # ============================================================
  # Scheme Boundary — https only
  # ============================================================

  @scheme @implemented
  Scenario: Relay URLs must use https
    When I configure a relay URL "https://relay.example.com"
    Then the relay URL should be accepted

  @scheme @implemented
  Scenario Outline: Non-https relay URLs are rejected at the parse boundary
    When I configure a relay URL "<url>"
    Then the relay URL should be rejected
    And no connection attempt should be made

    Examples:
      | url                      |
      | http://relay.example.com |
      | ws://relay.example.com   |
      | wss://relay.example.com  |
      | relay.example.com        |

  @scheme @implemented
  Scenario: No plaintext fallback exists
    Given a relay URL failed https validation
    Then the client should not retry over plain HTTP
    And there should be no downgrade path to an unencrypted transport
  # ============================================================
  # Layering — TLS + OHTTP + E2E
  # ============================================================

  @layering @implemented
  Scenario: Sensitive requests are OHTTP-encapsulated when configured
    Given an OHTTP relay is configured
    When I send a sensitive relay request (fetch, register, purge)
    Then the request should be HPKE-encapsulated (OHTTP)
    And it should reach the vauchi relay via the OHTTP relay
    And the vauchi relay should not learn my IP address
    And the OHTTP relay should not see the request content

  @layering @planned
  Scenario: OHTTP is on by default
    Given a fresh install with a default relay configuration
    When I sync for the first time
    Then sensitive relay requests should route via OHTTP without manual setup

  @layering @implemented
  Scenario: Defense in depth
    When I send an update through the relay
    Then TLS should protect every hop
    And the update payload should be end-to-end encrypted for the recipient
    And a compromised relay should still see only encrypted blobs
    And with OHTTP configured, no single operator should see both my IP and my traffic pattern
    # Operator separation is mandatory: the vauchi relay and the OHTTP
    # relay must be run by distinct entities (ADR-037).
  # ============================================================
  # Relay Side — no unencrypted client transport
  # ============================================================

  @relay-side @implemented
  Scenario: WebSocket upgrades are rejected
    When a client attempts a WebSocket upgrade against the relay
    Then the relay should reject it with HTTP 426
    And the only client API should be HTTP v2
    # promoted_to: relay (main.rs — client WS handler removed 2026-04;
    # Noise-era plaintext fallback removed SP-33)

  @relay-side @implemented
  Scenario: Relay identity survives the Noise retirement
    Given the relay persisted its identity keypair before the migration
    When the relay loads the keypair with the current build
    Then the public key should be identical
    And the federation signing key derived from it should be identical
    # promoted_to: relay (noise_key.rs — keygen migrated snow -> x25519-dalek
    # without rotating the relay identity federation peers trust)
  # Certificate pinning for the TLS layer: certificate_pinning.feature.
  # Relay-to-relay federation transport (mutual TLS): relay_network.feature.
