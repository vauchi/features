# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@relay @infrastructure
Feature: Relay Network
  As a Vauchi user or contributor
  I want a decentralized relay network for message delivery
  So that updates can be delivered even when direct P2P connection fails

  Background:
    Given the relay network is operational
    And there are volunteer-run relay nodes available
  # Relay Usage

  @usage @implemented
  Scenario: Automatic fallback to relay
    Given I am trying to send an update to Bob
    And direct P2P connection to Bob fails
    When the system detects connection failure
    Then it should automatically try relay nodes
    And the update should be delivered via relay
    And I should see "Delivered via relay"

  @usage @implemented
  Scenario: Relay stores messages for offline contacts
    Given Carol is offline
    When I send an update to Carol
    Then the relay should store the encrypted update
    And the update should be delivered when Carol comes online
    And the relay should delete the blob after delivery

  @usage @implemented
  Scenario: Relay blob expiration
    Given I sent an update to Dave via relay
    And Dave has been offline for 30 days
    Then the relay should expire the update blob
    And my client should be notified of failed delivery
    And I should be prompted to retry later
  # Privacy in Relay

  @privacy @implemented
  Scenario: Relay only sees encrypted blobs
    Given I am sending data through a relay
    Then the relay should only receive encrypted blobs
    And the relay should have no decryption keys
    And the relay should learn nothing about content

  @privacy @implemented
  Scenario: Relay cannot identify users
    Given I am using a relay
    Then the relay should not require user accounts
    And the relay should not log user identities
    And routing should use anonymous identifiers

  @privacy @implemented
  Scenario: Relay cannot correlate sender and recipient
    Given I send an update via relay
    Then the relay should not know I am the sender
    And the relay should not know who the recipient is
    And metadata should be minimized

  @contribute @implemented
  Scenario: Deploy relay node with Docker
    Given I want to contribute a relay node
    When I run the Docker image
    Then a relay node should start
    And it should begin accepting connections
    # Joining the relay network is not implemented: a started relay contacts
    # no peer until it offloads.

  @contribute @implemented
  Scenario: Relay node configuration
    Given I am setting up a relay node
    When I configure the node
    Then I should be able to set bandwidth limits
    And I should be able to set storage limits
    And I should be able to set geographic restrictions

  @contribute @implemented
  Scenario: Relay node monitoring
    Given I am running a relay node
    When I view the monitoring dashboard
    Then I should see bandwidth usage
    And I should see number of blobs stored
    And I should see uptime statistics
    And I should NOT see any user data

  @contribute @implemented
  Scenario: Relay node health check
    Given a relay node is running
    Then it should respond to health check probes
    And unhealthy nodes should be removed from network
    And the network should route around failed nodes
  # Contribution Model

  @contribution @implemented
  Scenario: No mailbox gets privileged treatment
    Given I am running a relay node
    Then my own mailbox has the same storage quota as every other mailbox
    And my own mailbox has the same rate limit as every other mailbox
    And no setting exempts any mailbox from either limit
  # Relay Network Health

  @health @implemented
  Scenario: Multiple relay nodes for redundancy
    Given the relay network has 100 nodes
    When 10 nodes go offline
    Then messages should still be deliverable
    And remaining nodes should handle increased load
    And network should remain functional

  @health @implemented
  Scenario: Geographic distribution of relays
    Given users are distributed globally
    Then relay nodes should be distributed globally
    And users should connect to nearby relays
    And latency should be minimized

  @abuse @implemented
  Scenario: Rate limiting on relay nodes
    Given a user is sending excessive traffic
    Then the relay should rate limit them
    And legitimate traffic should not be affected
    And the rate limit should be per mailbox, since the relay never learns who is sending

  @abuse @implemented
  Scenario: Storage limits per blob
    Given a user tries to store a very large blob
    Then the relay should reject oversized blobs
    And the maximum blob size should be enforced
    And storage should be fairly distributed

  @abuse @implemented
  Scenario: Automatic cleanup of stale blobs
    Given blobs have been stored on a relay
    When 30 days pass without retrieval
    Then stale blobs should be automatically deleted
    And storage should be reclaimed
    And the sender should be notified

  @protocol @implemented
  Scenario: Relay node authentication
    Given I am connecting to a relay
    Then the relay's gateway key should chain to the anchor pinned for that relay
    And a key signed under any other anchor should never be installed
  # Signed Operations (originally "Relay Authentication Phase 1",
  # relay!28 + core!88). Connection-level identity authentication was
  # retired with the sealed-mailbox model (SP-33, ADR-029/ADR-037):
  # routing is always by anonymous daily-rotating tokens, and Ed25519
  # signatures authenticate specific signed operations (e.g. purge
  # requests) — never a connection or routing identity.

  @protocol @authentication @implemented
  Scenario: Signed operations verified without a routing identity
    Given I have an identity with an Ed25519 signing key
    When I submit a signed operation to the relay (e.g. a purge request)
    Then the relay should verify the signature before acting on it
    And my routing should use anonymous daily-rotating mailbox tokens
    And my public key should never be used as a connection or routing identifier
    # promoted_to: relay (handler/verify.rs)

  @protocol @authentication @implemented
  Scenario: Invalid signature rejected by relay
    Given an attacker sends a signed operation with a forged signature
    When the relay verifies the operation
    Then the relay should reject the operation
    And the attacker should not receive any routed messages
    # promoted_to: relay (handler/verify.rs)

  @protocol @authentication @implemented
  Scenario: Signature key mismatch rejected
    Given an attacker signs an operation with key A but claims it came from key B
    When the relay verifies the operation
    Then the relay should detect the mismatch
    And the operation should be rejected
    # promoted_to: relay (handler/verify.rs)

  @protocol @authentication @implemented
  Scenario: Nonce replay attack prevented
    Given an attacker captures a valid signed request
    When the attacker replays the exact same request
    Then the relay should detect the nonce was already used
    And the replayed request should be rejected
    # promoted_to: relay (handler/nonce.rs)

  @protocol @authentication @implemented
  Scenario: Expired timestamp rejected
    Given an attacker replays a signed request with a stale timestamp
    When the relay checks the timestamp
    Then the relay should reject requests older than 60 seconds
    And the operation should be rejected
    # promoted_to: relay (handler/verify.rs:45)

  @protocol @authentication @implemented
  Scenario: Plaintext connections are rejected
    Given the relay serves only the HTTPS v2 API
    When a client attempts a plaintext or WebSocket connection
    Then the connection should be rejected
    And the relay should serve no unencrypted client transport
    # promoted_to: relay (main.rs — WS upgrades rejected 426; Noise-era
    # plaintext fallback removed SP-33; see relay_transport_security.feature)

  @protocol @authentication @implemented
  Scenario: Anonymous token routing requires no signature
    Given I am connecting with a daily-rotating mailbox token
    When I fetch or deposit blobs by that token
    Then no signature verification should be required
    And the relay should validate only the token format
    # promoted_to: relay (http_api.rs token validation)

  @protocol @implemented
  Scenario: Relay gossip protocol
    Given relay nodes are in the network
    Then they should gossip routing information
    And network state should converge
    And new nodes should discover the network
  # Fallback Behavior

  @fallback @implemented
  Scenario: No relays available
    Given all relay nodes are unreachable
    When I try to send an update
    Then the update should be queued locally
    And I should be notified "You're offline. Changes will sync when you reconnect."
    And retry should occur periodically

  @preferences @implemented
  Scenario: Prefer specific relay nodes
    Given I have trusted relay nodes
    When I configure preferred relays
    Then those relays should be used first
    And fallback to other relays should occur if needed

  @federation @security @phase1 @implemented
  Scenario: Relay cannot read offloaded blobs
    Given relay A offloads encrypted blobs to relay B
    Then relay B receives the same encrypted data
    And neither relay can decrypt the content
    And the E2E encryption is preserved
    # promoted_to: relay (E2E encryption is client-side, relay stores opaque blobs)

  @federation @phase1 @implemented
  Scenario: Version mismatch between relays is an explicit refusal
    Given relay A and relay B speak different federation protocol versions
    When relay A sends a version handshake to relay B
    Then relay B should answer with its own version and "accepted: false"
    And relay A should not offload any blobs to relay B
    And relay A's blobs should remain in local storage for retry
    And relay B should count the handshake and relay A the refused connection in their metrics
    # promoted_to: relay (tests/it/federation_handshake_tests.rs +
    # federation_connector_tests.rs, 2026-07-04-federation-version-negotiation)

  @federation @phase1 @implemented
  Scenario: Version-skewed control messages are refused, not dropped
    Given relay B receives a federation control message with an unsupported version
    Then relay B should refuse it with an "upgrade required" error naming both versions
    And the refusal should be counted in relay B's metrics
    And no message should ever be silently discarded without a metric
    # promoted_to: relay (tests/it/federation_http_tests.rs,
    # 2026-07-04-federation-version-negotiation)
