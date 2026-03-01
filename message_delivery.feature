# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@relay @delivery @infrastructure
Feature: Message Delivery Guarantees
  As a Vauchi user
  I want reliable message delivery with clear guarantees
  So that I know my updates reach my contacts

  Background:
    Given I have created my identity
    And I have contacts who use Vauchi

  # ============================================================
  # Delivery Confirmation
  # ============================================================

  @confirmation @implemented
  Scenario: See delivery status for updates
    Given I updated my phone number
    When I view my update history
    Then I should see delivery status for each contact
    And statuses should include: Delivered, Pending, Failed
    And I should see when each delivery occurred

  @confirmation @implemented
  Scenario: Receive acknowledgment when update is delivered
    Given Bob is online
    When I update my email address
    And the update is delivered to Bob
    Then I should receive a delivery acknowledgment
    And my app should show "Delivered to Bob"
    And the acknowledgment should include a timestamp

  @confirmation @implemented
  Scenario: Pending status for offline contacts
    Given Carol is offline
    When I update my contact card
    Then the update to Carol should show "Pending"
    And the update should be queued on the relay
    And I should see "Will deliver when Carol is online"

  @confirmation @implemented
  Scenario: Delivery status updates in real-time
    Given I sent an update to Dave while he was offline
    And the status shows "Pending"
    When Dave comes online and receives the update
    Then my status should update to "Delivered"
    And the update should happen without manual refresh
    And a subtle notification should confirm delivery

  # ============================================================
  # Relay Persistence
  # ============================================================

  @persistence @implemented
  Scenario: Messages survive relay restart
    Given I sent an update that is pending on the relay
    When the relay server restarts
    Then the pending update should still be stored
    And delivery should occur when the recipient connects
    And no data should be lost

  @persistence @implemented
  Scenario: Message stored with TTL
    Given I send an update via relay
    Then the relay should store it for at least 30 days
    And the TTL should be visible in delivery status
    And I should be able to resend if TTL expires

  @persistence @implemented
  Scenario: Storage quota per user
    Given I have many pending updates
    When I exceed my storage quota on the relay
    Then I should be notified about the quota
    And oldest acknowledged messages may be removed
    And pending deliveries should be prioritized

  @persistence @implemented
  Scenario: Relay provides storage confirmation
    Given I send an update via relay
    Then I should receive confirmation that the relay stored it
    And the confirmation should include a message ID
    And I can use this ID to track delivery

  # ============================================================
  # Message Expiration
  # ============================================================

  @expiration @implemented
  Scenario: Notification before message expires
    Given I sent an update to an offline contact 29 days ago
    When the message is approaching expiration
    Then I should receive a warning notification
    And the notification should say "Update to X will expire in 1 day"
    And I should have the option to extend or resend

  @expiration @implemented
  Scenario: Message expires after TTL
    Given I sent an update 31 days ago
    And the recipient never came online
    When the TTL (30 days) expires
    Then the message should be removed from the relay
    And my delivery status should update to "Expired"
    And I should be prompted to try again

  @expiration @implemented
  Scenario: Extend message TTL
    Given I have a pending message approaching expiration
    When I choose to extend the TTL
    Then the message should get additional time
    And the new expiration should be shown
    And I should be able to extend multiple times

  @expiration @implemented
  Scenario: Expired messages can be resent
    Given an update expired without delivery
    When I view the delivery status
    Then I should see an option to "Resend"
    And resending should create a new message with fresh TTL
    And the original failure should be logged

  # ============================================================
  # Retry and Recovery
  # ============================================================

  @retry @implemented
  Scenario: Automatic retry on transient failure
    Given I send an update
    And the relay is temporarily unreachable
    When the network becomes available
    Then my app should automatically retry
    And retries should use exponential backoff
    And I should not need to manually intervene

  @retry @implemented
  Scenario: Manual retry option
    Given an update failed to send
    When I view the failed update
    Then I should see a "Retry" button
    And tapping retry should attempt redelivery
    And I should see the attempt status

  @retry @implemented
  Scenario: Retry queue persists across app restarts
    Given I have updates queued for retry
    When I close and reopen the app
    Then the retry queue should be preserved
    And retries should resume automatically
    And no updates should be lost

  @retry @implemented
  Scenario: Give up after maximum retries
    Given an update has failed repeatedly
    When maximum retry attempts are exhausted
    Then the update should be marked as "Failed"
    And I should be notified
    And I should see options: Retry Now, Cancel, or Contact Support

  # ============================================================
  # Offline Behavior
  # ============================================================

  @offline @implemented
  Scenario: Queue updates while offline
    Given I am offline
    When I update my contact card
    Then the update should be queued locally
    And I should see "Will send when online"
    And my local card should reflect the change

  @offline @implemented
  Scenario: Sync queue when coming online
    Given I made 3 updates while offline
    When I come back online
    Then all queued updates should be sent
    And they should be sent in order
    And I should see confirmation for each

  @offline @implemented
  Scenario: Receive pending updates when coming online
    Given contacts updated their cards while I was offline
    When I come online
    Then I should receive all pending updates
    And updates should be applied in order
    And I should see a summary of changes

  @offline @implemented
  Scenario: Offline indicator
    Given I am offline
    Then the app should show an offline indicator
    And I should understand that updates are queued
    And the indicator should clear when online

  # ============================================================
  # Multi-Device Delivery
  # ============================================================

  @multi-device @implemented
  Scenario: Update delivered to all linked devices
    Given Bob has 3 linked devices
    When I update my contact card
    Then the update should be delivered to all Bob's devices
    And each device should acknowledge receipt
    And my delivery status should show "Delivered to all devices"

  @multi-device @implemented
  Scenario: Partial delivery to devices
    Given Bob has a phone and tablet
    And Bob's tablet is offline
    When I send an update
    Then the update should be delivered to Bob's phone
    And remain pending for Bob's tablet
    And status should show "Delivered to 1 of 2 devices"

  @multi-device @implemented
  Scenario: Device comes online later
    Given I sent an update to Bob
    And Bob's phone received it but his tablet was offline
    When Bob's tablet comes online
    Then the tablet should receive the update
    And my status should update to "Delivered to all devices"

  # ============================================================
  # Delivery Order
  # ============================================================

  @ordering @implemented
  Scenario: Updates applied in order
    Given I update my phone number to A
    And then I update it to B
    When Bob receives both updates
    Then they should be applied in order
    And Bob should see the final value B
    And intermediate state A may flash briefly or not at all

  @ordering @implemented
  Scenario: Out-of-order delivery handled gracefully
    Given network conditions cause out-of-order delivery
    When updates arrive out of order
    Then the app should reorder them by timestamp
    And the final state should be consistent
    And no update should be lost

  # ============================================================
  # Delivery Transparency
  # ============================================================

  @transparency @implemented
  Scenario: View delivery history
    When I open Settings > Delivery Status
    Then I should see a history of sent updates
    And each entry should show: recipient, time, status
    And I should be able to see details for each

  @transparency @implemented
  Scenario: Debug connectivity issues
    Given deliveries are failing
    When I view diagnostics
    Then I should see relay connection status
    And I should see network quality indicators
    And I should see suggested actions

  @transparency @implemented
  Scenario: Understand why delivery failed
    Given an update failed to deliver
    When I view the failure details
    Then I should see a human-readable reason
    And not just an error code
    And I should see what I can do about it

  # ============================================================
  # Privacy in Delivery
  # ============================================================

  @privacy @implemented
  Scenario: Delivery receipts are optional
    Given I value privacy over delivery confirmation
    When I disable delivery receipts in settings
    Then I should not receive delivery acknowledgments
    And contacts should not know when I received updates
    And the relay should not track my online status

  @privacy @implemented
  Scenario: Read receipts are never sent
    Given I receive an update from Alice
    Then Alice should not know when I read the update
    And there should be no "seen" indicators
    And only delivery (not read) status is tracked

  @privacy @implemented
  Scenario: Delivery metadata is minimal
    Given an update is delivered via relay
    Then the relay should log minimal metadata
    And logs should be automatically purged
    And no long-term tracking should occur

  # ============================================================
  # Error Handling
  # ============================================================

  @errors @implemented
  Scenario: Handle relay unavailable gracefully
    Given all relays are unreachable
    When I try to send an update
    Then I should see a clear error message
    And the update should be queued for retry
    And I should not lose my changes

  @errors @implemented
  Scenario: Handle recipient key rotation
    Given Bob rotated his keys (got a new device)
    When I try to send an update
    Then I should be notified of the key change
    And I should be prompted to verify Bob's new key
    And delivery should proceed after verification

  @errors @implemented
  Scenario: Handle quota exceeded
    Given the relay storage quota is exceeded
    When I try to send an update
    Then I should see a clear error message
    And I should be told how to free up space
    And critical updates should be prioritized
