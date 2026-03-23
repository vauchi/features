# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@sync @updates
Feature: Sync and Updates
  As a Vauchi user
  I want my contact card changes to automatically sync to my contacts
  And receive updates when my contacts change their information
  So that contact information stays current without manual effort

  Background:
    Given I have an existing identity as "Alice"
    And I have contacts "Bob", "Carol", and "Dave" in my contact list
    And the sync service is running

  # Update Propagation

  @propagation @implemented
  Scenario: Update propagates to online contacts
    Given Bob is online and connected
    And Bob can see my phone field
    When I change my phone number from "555-1111" to "555-2222"
    Then Bob should receive the update within 30 seconds
    And Bob's view of my contact card should show "555-2222"

  @propagation @implemented
  Scenario: Update queued for offline contacts
    Given Carol is offline
    And Carol can see my email field
    When I change my email to "newemail@example.com"
    Then the update should be queued for Carol
    And my local sync state should show "pending for Carol"

  @propagation @implemented
  Scenario: Queued updates delivered when contact comes online
    Given there is a pending update for Carol
    When Carol comes online
    Then Carol should receive the queued update
    And my sync state should show Carol as "synced"

  @propagation @implemented
  Scenario: Multiple updates coalesced for offline contact
    Given Carol is offline
    When I make 5 changes to my contact card
    And Carol comes online
    Then Carol should receive one combined update
    And all 5 changes should be reflected

  # Receiving Updates

  @receive @implemented
  Scenario: Receive contact card update
    Given Bob has my contact card
    When Bob updates his phone number
    And I am online
    Then I should receive Bob's update
    And my view of Bob's contact should show the new phone number
    And I should see a notification "Bob updated their contact info"

  @receive @implemented
  Scenario: Receive update while offline
    Given I am offline
    And Bob updates his phone number
    When I come back online
    Then I should receive Bob's update
    And my contacts should be current

  @receive @implemented
  Scenario: Update only visible fields
    Given Bob has updated a field I cannot see
    When sync occurs
    Then I should not receive any update from Bob
    And my view of Bob should remain unchanged

  # Relay-Based Sync

  @relay @implemented
  Scenario: Sync via WebSocket relay
    Given Bob and I are both online
    When I update my contact card
    Then the update should be sent via the relay server
    And Bob should receive the update
    And the update should remain end-to-end encrypted

  @relay @implemented
  Scenario: Relay routes by recipient ID
    Given Bob is connected to the relay
    When I send an update for Bob
    Then the relay should route it by Bob's recipient ID
    And Bob should receive the update

  @relay @implemented
  Scenario: Relay stores updates for offline contacts
    Given Bob is offline
    When I update my contact card
    Then the relay should store the encrypted update
    And when Bob comes online Bob should receive the update

  # Conflict Resolution

  @conflict @implemented
  Scenario: Last-write-wins for single field
    Given I have synced my contact card to Device A and Device B
    When I update my phone on Device A at time T1
    And I update my phone on Device B at time T2 (T2 > T1)
    Then the phone value from Device B should win
    And both devices should converge to the same value

  @conflict @implemented
  Scenario: Concurrent updates to different fields
    Given I have synced my contact card to Device A and Device B
    When I update my phone on Device A
    And I update my email on Device B simultaneously
    Then both updates should be preserved
    And both devices should have the new phone and email

  @conflict @implemented
  Scenario: LWW merge for complex changes
    Given I have made offline changes on Device A
    And I have made different offline changes on Device B
    When both devices come online
    Then changes should be merged using last-write-wins with device-id tie-breaking
    And no data should be lost
    And both devices should converge to the same state

  # Sync Status

  @status @implemented
  Scenario: View sync status for all contacts
    When I open the sync status screen
    Then I should see a list of all contacts
    And each contact should show "synced" or "pending"
    And pending contacts should show number of queued updates

  @status @implemented
  Scenario: View detailed sync status for a contact
    Given I have pending updates for Carol
    When I view Carol's sync details
    Then I should see when the last successful sync was
    And I should see how many updates are pending
    And I should see the reason for pending status (offline/unreachable)

  @status @implemented
  Scenario: Manual sync trigger
    Given sync is paused or delayed
    When I tap "Sync Now"
    Then immediate sync attempt should be made
    And sync status should update

  # Sync Reliability

  @reliability @implemented
  Scenario: Retry failed sync with exponential backoff
    Given a sync attempt to Bob fails
    Then retry should be scheduled in 2 seconds
    And if that fails, retry in 4 seconds
    And if that fails, retry in 8 seconds
    And maximum retry interval should be 5 minutes

  @reliability @implemented
  Scenario: Sync survives app restart
    Given I have pending updates to send
    When I restart the application
    Then pending updates should be preserved
    And sync should resume automatically

  @reliability @implemented
  Scenario: Sync survives device reboot
    Given I have pending updates to send
    When my device reboots
    And I launch Vauchi
    Then pending updates should still be queued
    And sync should resume

  # Bandwidth and Efficiency

  @efficiency @implemented
  Scenario: Only changed fields transmitted
    Given I have a contact card with 10 fields
    When I update only my phone number
    Then only the phone field delta should be transmitted
    And the full contact card should not be sent

  @efficiency @implemented
  Scenario: Merkle tree for efficient sync detection
    Given Bob and I have been synced
    When we reconnect after a period offline
    Then Merkle tree comparison should detect changes
    And only changed data should be transmitted

  @efficiency @implemented
  Scenario: Compression of sync payloads
    Given I am sending an update
    Then the payload should be compressed before encryption
    And the encrypted payload should be as small as possible

  # Sync Settings

  @settings @planned
  Scenario: Configure sync over WiFi only
    Given I have enabled "WiFi only" sync
    When I am on cellular data
    Then sync should not run
    And updates should be queued
    And I should see "Sync paused - waiting for WiFi"

  @settings @planned
  Scenario: Disable background sync
    Given I have disabled background sync
    When the app is in the background
    Then no sync should occur
    And sync should only run when app is open

  @settings @planned
  Scenario: Configure sync frequency
    Given I have set sync frequency to "every hour"
    Then sync should run at most once per hour
    And manual sync should always work

  # Security in Sync

  @security @implemented
  Scenario: All sync traffic is encrypted
    Given I am syncing with Bob
    When updates are transmitted
    Then all payloads should be encrypted with our shared key
    And relay nodes should only see encrypted blobs

  @security @implemented
  Scenario: Verify update signatures
    Given I receive an update claiming to be from Bob
    Then I should verify the update signature with Bob's public key
    And unsigned updates should be rejected
    And updates signed by wrong key should be rejected

  @security @implemented
  Scenario: Reject replay attacks
    Given an attacker captures an old update from Bob
    When the attacker replays it to me
    Then I should detect the replay via timestamp/nonce
    And the replayed update should be rejected

  # Multi-device Sync

  @multi-device @implemented
  Scenario: Sync my own contact card across my devices
    Given I have Device A and Device B linked to my identity
    When I update my contact card on Device A
    Then Device B should receive the update
    And my contact card should be identical on both devices

  @multi-device @implemented
  Scenario: Contact updates reach all my devices
    Given I have Device A and Device B linked
    And Bob updates his contact card
    Then both Device A and Device B should receive Bob's update
    And my view of Bob should be consistent across devices

  @multi-device @implemented
  Scenario: New device receives full state
    Given I have an existing contact card and contacts on Device A
    When I link new Device C
    Then Device C should receive my full contact card
    And Device C should receive all my contacts
    And Device C should be fully synced

  # Edge Cases

  @edge-case @implemented
  Scenario: Handle contact deletion during sync
    Given Bob deletes me from his contacts
    When I try to sync an update to Bob
    Then Bob should not receive my updates
    And I should eventually be notified that Bob removed me

  @edge-case @planned
  Scenario: Handle identity key change
    Given Bob has rotated his identity keys
    When I try to sync with Bob
    Then I should detect the key mismatch
    And I should be prompted to re-verify Bob
    And sync should pause until verified

  @edge-case @implemented
  Scenario: Large sync queue handling
    Given I have been offline for a long time
    And 100 contacts have sent updates
    When I come online
    Then updates should be processed in batches
    And UI should remain responsive
    And progress should be shown

  # Clock Skew Handling (Added 2026-01-21)

  @edge-case @clock-skew @implemented
  Scenario: Sync handles clock skew between devices
    Given Device A's clock is 1 hour ahead
    And Device B has the correct time
    When both devices make concurrent updates
    Then version vectors should track causality correctly
    And timestamp-based resolution should not give unfair advantage
    And both devices should converge to the same state

  @edge-case @clock-skew @implemented
  Scenario: Extreme clock skew detection
    Given Device A's clock is set to year 2100
    When Device A sends an update
    Then the system should detect the unrealistic timestamp
    And version vector ordering should still work correctly

  @edge-case @concurrent @implemented
  Scenario: Detect truly concurrent updates
    Given Device A and Device B are offline
    And Device A updates field X at logical time 1
    And Device B updates field X at logical time 1
    When both come online simultaneously
    Then version vectors should detect concurrent updates
    And deterministic tie-breaker should be applied
    And both devices should converge to the same winner

  @edge-case @network @implemented
  Scenario: Network partition during sync
    Given Device A and Device B are syncing
    When network connection drops mid-sync
    Then partial updates should not be committed
    And sync should resume from last checkpoint
    And no data corruption should occur

  # Platform Edge Cases (dissolved from platform_edge_cases.feature 2026-03-17)

  @platform-edge-case @ios @background @planned
  Scenario: Sync survives background termination
    Given I am syncing updates on iOS
    When iOS terminates the app in background
    Then pending syncs should be saved to disk
    And when I relaunch the app
    Then syncs should resume automatically
    And no data should be lost

  @platform-edge-case @ios @background @planned
  Scenario: Background task completes before termination
    Given I started a sync operation on iOS
    When the app moves to background
    Then a background task should be requested
    And the sync should complete if possible
    And state should be saved before termination

  @platform-edge-case @android @battery @planned
  Scenario: Handle doze mode on Android
    Given the Android device enters doze mode
    When a sync is scheduled
    Then sync should use WorkManager properly
    And it should respect doze restrictions
    And critical updates should use high-priority FCM

  @platform-edge-case @android @battery @planned
  Scenario: Handle battery saver on Android
    Given battery saver is enabled on Android
    When background sync is due
    Then sync frequency should be reduced
    And the user should be informed
    And critical functionality should still work

  @platform-edge-case @cross-platform @interrupt @planned
  Scenario: Handle sync interruption
    Given a sync is in progress
    When the app is killed mid-sync
    Then partial sync should be saved
    And sync should resume on next launch
    And no data corruption should occur

  @platform-edge-case @cross-platform @crash-recovery @implemented
  Scenario: Sync state persisted atomically
    Given a batch sync of 50 items is in progress
    When the app crashes after processing 25 items
    Then the checkpoint should record exactly 25 items synced
    And on restart, sync should resume from item 26
    And no items should be duplicated or orphaned

  @platform-edge-case @android @battery @planned
  Scenario: WorkManager respects battery optimization
    Given the Android device is in battery saver mode
    When a background sync is scheduled via WorkManager
    Then sync frequency should be reduced to every 4 hours
    And the sync should respect doze mode constraints
    And critical notifications should still be delivered

  @platform-edge-case @ios @permissions @planned
  Scenario: Handle notification permission denied on iOS
    Given I denied notification permission on iOS
    When a contact updates their card
    Then the update should still sync
    And I should see updates when I open the app
    And I should be gently prompted to enable notifications

  @platform-edge-case @tui @terminal @implemented
  Scenario: Handle SSH disconnection
    Given I am using Vauchi TUI over SSH
    When the SSH connection drops
    Then the app should save state before exit
    And when I reconnect, state should be preserved
    And no data should be lost
