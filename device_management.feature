# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@device @multi-device
Feature: Device Management
  As a Vauchi user
  I want to use Vauchi on multiple devices
  So that I can access and manage my contacts from any device

  Background:
    Given I have an existing identity on my primary device (Device A)
    And my identity has been set up with display name "Alice"
  # Device Linking

  @link @implemented
  Scenario: Generate device linking code
    Given I am on Device A
    When I go to Settings > Link New Device
    Then a QR code should be displayed
    And the QR code should contain encrypted linking data
    And a numeric code should be shown as fallback
    And the code should expire after 5 minutes

  @link @implemented
  Scenario: Link new device via QR code
    Given Device A is showing a linking QR code
    And I have Vauchi installed on Device B (new)
    When I select "Link to Existing Identity" on Device B
    And I scan the QR code from Device A
    And Device A and B are in proximity
    Then Device B should receive my identity
    And Device B should sync all my data
    And Device B should appear in my linked devices list

  @link @implemented
  Scenario: Linking requires proximity verification
    Given Device A is showing a linking QR code
    When someone scans it from a remote location
    Then proximity verification should fail
    And the device should not be linked
    And a security warning should be shown on Device A

  @link @implemented
  Scenario: Maximum devices reached
    Given I have 10 linked devices
    When I try to link an 11th device
    Then I should see "Maximum devices reached"
    And I should be prompted to unlink a device first
  # Device Synchronization

  @sync @implemented
  Scenario: New device receives full state
    Given I have contacts and a contact card on Device A
    When Device B is newly linked
    Then Device B should receive my complete contact card
    And Device B should receive all my contacts
    And Device B should receive all visibility settings

  @sync @implemented
  Scenario: Changes sync between devices
    Given Device A and Device B are linked
    When I update my phone number on Device A
    Then Device B should receive the update
    And both devices should show the same phone number

  @sync @implemented
  Scenario: Bidirectional sync
    Given Device A and Device B are linked
    When I add a field on Device A
    And I add a different field on Device B
    Then both fields should appear on both devices

  @sync @implemented
  Scenario: Offline changes sync when reconnected
    Given Device B is offline
    When I make changes on Device A
    And Device B comes back online
    Then changes should sync to Device B
    And both devices should be in sync

  @sync @implemented
  Scenario: Conflict resolution between devices
    Given Device A and Device B are both offline
    When I update my email to "a@test.com" on Device A
    And I update my email to "b@test.com" on Device B
    And both come online
    Then the later change should win
    And both devices should converge to the same value
  # Viewing Linked Devices

  @view @implemented
  Scenario: View list of linked devices
    Given I have 3 linked devices
    When I go to Settings > Linked Devices
    Then I should see all 3 devices listed
    And each should show device name and type
    And each should show last sync time
    And the current device should be marked

  @view @implemented
  Scenario: View device details
    Given I have linked "iPhone 15 Pro" as Device B
    When I view details for Device B
    Then I should see the device name "iPhone 15 Pro"
    And I should see the device type "iOS"
    And I should see when it was linked
    And I should see last activity time

  @view @implemented
  Scenario: Rename a device
    Given Device B is named "iPhone 15 Pro"
    When I rename Device B to "Work Phone"
    Then Device B should appear as "Work Phone"
    And the name should sync to other devices
  # Unlinking Devices

  @unlink @implemented
  Scenario: Unlink a device remotely
    Given Device B is linked
    When I select "Remove Device" for Device B on Device A
    And I confirm the removal
    Then Device B should be unlinked
    And Device B should no longer receive updates
    And Device B should be notified of removal

  @unlink @implemented
  Scenario: Unlink current device
    Given Device A and Device B are linked
    And I am on Device B
    When I select "Remove from This Device" on the Devices screen
    And I type WIPE to confirm
    Then Device B revokes itself and tells Device A
    And my data should be removed from Device B
    And Device B should return to initial setup
    And neither my contacts nor the relay are told

  @unlink @implemented
  Scenario: Removing the only device offers identity deletion instead
    Given Device A is my only active device
    When I select "Remove from This Device"
    Then I am told that removing it would end my identity
    And I am pointed to identity deletion or Emergency Shred
    And nothing is revoked or wiped

  @unlink @implemented
  Scenario: Removing a device while offline stops before wiping
    Given Device B cannot reach the relay
    When I confirm "Remove from This Device" on Device B
    Then I am told my other devices were not told
    And nothing is wiped yet
    And I can try again or erase anyway

  @unlink @duress @implemented
  Scenario: Removing a device in duress mode is the emergency wipe
    Given Vauchi is in duress mode
    When I confirm "Remove from This Device"
    Then my real data is wiped as Emergency Shred would
    And nothing is sent and the real device registry is not revoked

  @unlink @implemented
  Scenario: Unlinked device data wiped
    Given Device B has been unlinked
    Then all identity data should be deleted from Device B
    And all contact data should be deleted
    And Device B should show the welcome screen

  @unlink @implemented
  Scenario: Cannot unlink last device
    Given Device A is my only linked device
    When I try to unlink Device A
    Then I should see "Cannot unlink your only device"
    And unlinking should be prevented
  # Device Security

  @security @implemented
  Scenario: Device-specific keys
    Given Device A and Device B are linked
    Then each device should have its own encryption key
    And the device key should be derived from master seed
    And a device holding the master seed can derive every other device's key

  @security @implemented
  Scenario: Lost device revocation
    Given Device B has been lost or stolen
    When I mark Device B as "Lost" on Device A
    Then Device B should stop syncing with Device A
    And Device B's device key should be revoked in the signed registry
    And Device B should still hold the identity's keys it had

  @security @implemented
  Scenario: Verify device during linking
    Given I am linking Device B
    Then Device A should display Device B's fingerprint
    And Device B should display Device A's fingerprint
    And I should confirm they match before completing

  @security @implemented
  Scenario: Prevent unauthorized device linking
    Given an attacker has access to a linking QR code
    But the attacker is not physically present
    Then proximity verification should block the attack
    And the device should not be linked
  # Platform Support

  @settings @implemented
  Scenario: Some settings sync across devices
    Given I update my display name on Device A
    Then the display name should sync to Device B
    And visibility rules should sync to Device B
    And contact groups should sync to Device B
  # Activity Monitoring

  @edge-case @race-condition @implemented
  Scenario: Concurrent device linking attempts
    Given Device A is showing a linking code
    And Device B and Device C both scan it simultaneously
    When both attempt to link at the same time
    Then only one device should successfully link
    And the other should receive "Linking code already used"
    And no duplicate devices should be created

  @edge-case @race-condition @implemented
  Scenario: Concurrent link and revoke
    Given Device B is linked
    And Device A initiates revocation of Device B
    And Device C attempts to link simultaneously
    When both operations race
    Then both operations should complete correctly
    And device registry should remain consistent
    And version should be incremented for each change

  @edge-case @duplicate @implemented
  Scenario: Link same device twice
    Given Device B is already linked to my identity
    When I attempt to link Device B again
    Then I should see "Device already linked"
    And no duplicate entry should be created
    And no duplicate entry should be created in the device registry
    And the existing sync session for Device B should be refreshed

  @edge-case @version @implemented
  Scenario: Device registry version tracking
    Given I have linked devices
    When I add a new device
    Then the registry version should increment
    When I revoke a device
    Then the registry version should increment again
    And version should enable sync conflict detection

  @edge-case @identity-collision @implemented
  Scenario: Linking to a device that already has a different identity
    Given Device B is already set up with identity "Bob"
    When I try to link Device B to identity "Alice"
    Then Device B should refuse with "This device already has an identity."
    And "Bob's" data should be left untouched

  @edge-case @timezone @implemented
  Scenario: Timezone change during sync
    Given Device A is in London (UTC+0) and Device B is linked
    When I travel to New York (UTC-5) and Device A updates its wall clock
    And I edit a contact on Device A in New York
    Then Device A should use a UTC-based timestamp for the sync
    And Device B should correctly identify the New York edit as the "latest"
    And the change should sync to Device B despite the 5-hour local time jump

  @edge-case @clock-skew @implemented
  Scenario: Backward clock jump (Clock Skew)
    Given Device A's system clock is manually moved back by 1 hour
    When I make a change to my profile
    Then the sync engine should detect the backward jump
    And it should increment the Logical Counter instead of using the regressed wall-clock time
    And the change must still propagate as the "most recent" version to other devices

  @edge-case @expiry @implemented
  Scenario: Linking code ignores timezone
    Given Device A generates a linking code in Tokyo (UTC+9)
    And Device B is in Los Angeles (UTC-8)
    When Device B scans the code within 5 minutes of real-world time
    Then the linking should succeed
    And the 5-minute expiry should be calculated using absolute UTC time, not local time
  # Platform Edge Cases (dissolved from platform_edge_cases.feature 2026-03-17)
