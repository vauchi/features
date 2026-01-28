# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@platform @edge-cases
Feature: Platform-Specific Edge Cases
  As a Vauchi user on any platform
  I want the app to handle platform quirks gracefully
  So that I don't lose data or have poor experience

  # ============================================================
  # iOS Edge Cases
  # ============================================================

  @ios @background
  Scenario: Sync survives background termination
    Given I am syncing updates on iOS
    When iOS terminates the app in background
    Then pending syncs should be saved to disk
    And when I relaunch the app
    Then syncs should resume automatically
    And no data should be lost

  @ios @background
  Scenario: Background task completes before termination
    Given I started a sync operation on iOS
    When the app moves to background
    Then a background task should be requested
    And the sync should complete if possible
    And state should be saved before termination

  @ios @memory
  Scenario: Handle low memory warning on iOS
    Given the app is using significant memory on iOS
    When iOS sends a memory warning
    Then the app should release cached images
    And the app should release non-essential data
    And core functionality should continue working

  @ios @permissions
  Scenario: Handle camera permission revoked on iOS
    Given I previously granted camera permission on iOS
    When I revoke camera permission in Settings
    And I try to scan a QR code
    Then I should see a clear message about missing permission
    And there should be a button to open Settings
    And the app should not crash

  @ios @permissions
  Scenario: Handle notification permission denied on iOS
    Given I denied notification permission on iOS
    When a contact updates their card
    Then the update should still sync
    And I should see updates when I open the app
    And I should be gently prompted to enable notifications

  @ios @keychain
  Scenario: Keychain access after device restore on iOS
    Given I restored my iPhone from backup
    When I open Vauchi
    Then keychain items should be accessible
    Or I should be prompted to restore from backup
    And I should not be locked out of my identity

  @ios @extension
  Scenario: Share extension works on iOS
    Given I am in another app with contact info
    When I use the iOS share sheet
    Then Vauchi should appear as an option
    And I can share data to Vauchi
    And sharing should work even if main app not running

  @ios @handoff
  Scenario: Handoff between iOS devices
    Given I am editing my card on iPhone
    When I open Vauchi on my iPad
    Then I should see option to continue on iPad
    And my changes should be available
    And I should not lose unsaved work

  # ============================================================
  # Android Edge Cases
  # ============================================================

  @android @memory
  Scenario: Handle onTrimMemory on Android
    Given the Android system is under memory pressure
    When Android calls onTrimMemory(LEVEL_LOW)
    Then the app should release caches
    And images should be released from memory
    And core data should be preserved

  @android @memory
  Scenario: Handle process killed for memory on Android
    Given Android kills the app process
    When I return to the app
    Then the app should restore state
    And unsaved changes should be preserved
    And I should see where I left off

  @android @battery
  Scenario: Handle doze mode on Android
    Given the Android device enters doze mode
    When a sync is scheduled
    Then sync should use WorkManager properly
    And it should respect doze restrictions
    And critical updates should use high-priority FCM

  @android @battery
  Scenario: Handle battery saver on Android
    Given battery saver is enabled on Android
    When background sync is due
    Then sync frequency should be reduced
    And the user should be informed
    And critical functionality should still work

  @android @permissions
  Scenario: Handle runtime permission denied on Android
    Given I denied camera permission on Android
    When I try to scan a QR code
    Then I should see an explanation of why permission is needed
    And there should be an option to request permission again
    And I should not be asked repeatedly if I chose "Don't ask again"

  @android @storage
  Scenario: Handle scoped storage on Android 11+
    Given I am on Android 11 or later
    When I export my data
    Then export should use proper storage APIs
    And files should go to Downloads or app-specific directory
    And I should be able to share the export

  @android @split
  Scenario: Handle split APK installation on Android
    Given the app was installed via split APKs (Play Store)
    When I use native features (camera, crypto)
    Then all required libraries should be present
    And the app should not crash
    And features should work correctly

  @android @backup
  Scenario: Android auto-backup handles sensitive data
    Given Android auto-backup is enabled
    Then encryption keys should be excluded from backup
    And backup should include safe data only
    And restoration should prompt for re-authentication

  # ============================================================
  # Desktop Edge Cases
  # ============================================================

  @desktop @webview
  Scenario: WebView security on desktop
    Given the desktop app uses WebView
    Then JavaScript should not access filesystem directly
    And external links should open in system browser
    And WebView should have secure defaults (no eval, CSP)

  @desktop @multi-window
  Scenario: Handle multiple windows on desktop
    Given the app is open in one window
    When I try to open another instance
    Then the existing window should be focused
    Or windows should sync state in real-time
    And data conflicts should be prevented

  @desktop @crash
  Scenario: Recovery after crash on desktop
    Given the desktop app crashed unexpectedly
    When I relaunch the app
    Then the app should detect the previous crash
    And it should offer to restore last state
    And unsaved changes should be preserved if possible

  @desktop @url-scheme
  Scenario: Handle vauchi:// URL scheme on desktop
    Given I click a vauchi:// link
    When the desktop app is not running
    Then the app should launch
    And the link should be processed
    And the appropriate action should occur

  @desktop @tray
  Scenario: System tray behavior on desktop
    Given the app is minimized to system tray
    When a contact update arrives
    Then a system notification should show
    And clicking the tray icon should restore the app
    And the app should not consume CPU while minimized

  @desktop @theme
  Scenario: Respect system theme on desktop
    Given the system is set to dark mode
    When I open the app
    Then the app should use dark theme
    And changing system theme should update app theme
    And there should be an override option

  # ============================================================
  # TUI Edge Cases
  # ============================================================

  @tui @terminal
  Scenario: Handle terminal resize
    Given I am using the TUI app
    When I resize my terminal window
    Then the UI should reflow correctly
    And no content should be cut off
    And the app should remain usable

  @tui @terminal
  Scenario: Handle SSH disconnection
    Given I am using Vauchi TUI over SSH
    When the SSH connection drops
    Then the app should save state before exit
    And when I reconnect, state should be preserved
    And no data should be lost

  @tui @encoding
  Scenario: Handle non-UTF8 terminal
    Given my terminal has limited character support
    When I view contacts with unicode names
    Then the app should fallback gracefully
    And names should still be readable
    And the app should not crash

  # ============================================================
  # Cross-Platform Edge Cases
  # ============================================================

  @cross-platform @time
  Scenario: Handle clock skew
    Given my device clock is 1 hour behind
    When I sync with contacts
    Then timestamps should be handled correctly
    And message ordering should be correct
    And no sync loops should occur

  @cross-platform @time
  Scenario: Handle timezone change
    Given I change timezone while app is running
    When I view timestamps
    Then they should update to new timezone
    And relative times should be correct
    And no duplicate notifications should occur

  @cross-platform @upgrade
  Scenario: Handle app upgrade
    Given I have data from version 1.0
    When I upgrade to version 2.0
    Then data migration should occur automatically
    And no data should be lost
    And the user should not need to reconfigure

  @cross-platform @downgrade
  Scenario: Prevent data loss on downgrade
    Given I accidentally downgraded to an older version
    When the older version cannot read newer data format
    Then a clear error should be shown
    And I should be told to upgrade
    And data should not be corrupted

  @cross-platform @locale
  Scenario: Handle locale change
    Given I change my device language
    When I open the app
    Then the app should use the new language
    And formatting should follow new locale
    And no restart should be required

  @cross-platform @interrupt
  Scenario: Handle sync interruption
    Given a sync is in progress
    When the app is killed mid-sync
    Then partial sync should be saved
    And sync should resume on next launch
    And no data corruption should occur

  @cross-platform @restore
  Scenario: Handle device migration
    Given I am setting up a new device
    When I restore from backup
    Then my identity should be recoverable
    And contacts should sync from relays
    And the experience should be smooth
