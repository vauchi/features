# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@remote_content @content-updates
Feature: Remote Content Updates
  As a Vauchi user
  I want the app to automatically update content like themes, translations, and social networks
  So that I get improvements without waiting for app store updates

  Background:
    Given the app is configured with remote updates enabled
    And the content server is "https://vauchi.app/app-files"
  # ===========================================
  # Manifest Fetching
  # ===========================================

  @manifest @implemented
  Scenario: Fetch content manifest on app launch
    Given the app has never checked for content updates
    When the app launches
    Then the app should fetch the manifest from the content server
    And the manifest should be cached locally

  @manifest @offline @implemented
  Scenario: Use cached manifest when offline
    Given the app has a cached manifest from a previous session
    And the content server cannot be reached
    When the app checks for updates
    Then the check should fail without changing the cache
    And the cached content should stay in use

  @manifest @interval @implemented
  Scenario: Respect update check interval
    Given the app checked for updates 30 minutes ago
    And the update check interval is 1 hour
    When the app launches
    Then the app should not fetch the manifest
    And the app should use cached content

  @manifest @interval @implemented
  Scenario: Check for updates when interval elapsed
    Given the app checked for updates 2 hours ago
    And the update check interval is 1 hour
    When the app launches
    Then the app should fetch the manifest from the content server

  @manifest @signature @security @implemented
  Scenario: Reject a manifest without a publisher signature
    Given the content server returns an unsigned manifest
    When the app checks for updates
    Then the manifest should be rejected
    And no remote content should be applied

  @manifest @signature @security @implemented
  Scenario: Reject a manifest signed by an untrusted publisher
    Given the content server returns a manifest signed by an untrusted key
    When the app checks for updates
    Then the manifest should be rejected
    And no remote content should be applied
  # ===========================================
  # Version Comparison
  # ===========================================

  @version @implemented
  Scenario: Detect available updates
    Given the cached manifest has networks version "1.0.0"
    And the remote manifest has networks version "1.1.0"
    When the app checks for updates
    Then the update status should indicate updates are available
    And networks should be listed as updateable

  @version @implemented
  Scenario: No updates when versions match
    Given the cached manifest has networks version "1.0.0"
    And the remote manifest has networks version "1.0.0"
    When the app checks for updates
    Then the update status should indicate no updates available

  @version @compatibility @implemented
  Scenario: Skip updates requiring newer app version
    Given the app version is "1.0.0"
    And the remote manifest has networks version "2.0.0" requiring app version "1.5.0"
    When the app checks for updates
    Then networks should not be listed as updateable

  @version @compatibility @implemented
  Scenario: Apply updates compatible with current app version
    Given the app version is "1.2.0"
    And the remote manifest has locales version "1.5.0" requiring app version "1.0.0"
    When the app checks for updates
    Then locales should be listed as updateable

  @version @rollback @security @implemented
  Scenario: Reject a signed content downgrade
    Given the cached manifest has networks version "1.1.0"
    And the remote manifest has networks version "1.0.0" signed by the trusted publisher
    When the app checks for updates
    Then the update status should indicate no updates available
    And networks should not be listed as updateable
  # ===========================================
  # Content Download
  # ===========================================

  @download @checksum @implemented
  Scenario: Verify content checksum before saving
    Given the remote manifest specifies checksum "sha256:abc123" for networks
    When the app downloads the networks file
    And the downloaded file has checksum "sha256:abc123"
    Then the file should be saved to cache successfully

  @download @checksum @security @implemented
  Scenario: Reject content with mismatched checksum
    Given the remote manifest specifies checksum "sha256:abc123" for networks
    When the app downloads the networks file
    And the downloaded file has checksum "sha256:xyz789"
    Then the file should not be saved to cache
    And an integrity error should be reported
    And the app should continue using cached content

  @download @retry @security @implemented
  Scenario: Preserve the cached version when a content download fails
    Given the cached manifest has networks version "1.0.0"
    And the remote manifest has networks version "1.1.0" signed by the trusted publisher
    And the networks download fails
    When the app applies updates
    Then the cached manifest should keep networks version "1.0.0"
    And networks version "1.1.0" should remain updateable

  @themes @implemented
  Scenario: Apply downloaded theme
    Given the user has downloaded the "catppuccin-mocha" theme
    When the user selects "catppuccin-mocha" theme
    Then the app colors should change to Catppuccin Mocha palette
  # ===========================================
  # Privacy
  # ===========================================
