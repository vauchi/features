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
    Given the app has not checked for updates today
    When the app launches
    Then the app should fetch the manifest from the content server
    And the manifest should be cached locally

  @manifest @offline @implemented
  Scenario: Use cached manifest when offline
    Given the app has a cached manifest from a previous session
    And the device is offline
    When the app launches
    Then the app should use the cached manifest
    And no network requests should be made for content

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
    And a warning should be logged about version incompatibility

  @version @compatibility @implemented
  Scenario: Apply updates compatible with current app version
    Given the app version is "1.2.0"
    And the remote manifest has locales version "1.5.0" requiring app version "1.0.0"
    When the app checks for updates
    Then locales should be listed as updateable

  # ===========================================
  # Content Download
  # ===========================================

  @download @planned
  Scenario: Download updated content file
    Given the remote manifest has networks version "1.1.0"
    And the cached networks version is "1.0.0"
    When the app applies updates
    Then the app should download the networks file
    And the networks file should be saved to the cache
    And the cached manifest should be updated

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

  @download @size @planned
  Scenario: Reject content exceeding size limit
    Given the maximum content size is 5 MB
    And the remote networks file is 10 MB
    When the app attempts to download the networks file
    Then the download should be aborted
    And a size limit error should be reported

  # ===========================================
  # Fallback Behavior
  # ===========================================

  @fallback @offline @planned
  Scenario: Use bundled content when cache is empty and offline
    Given the content cache is empty
    And the device is offline
    When the app requests the social networks list
    Then the app should return bundled networks
    And the networks list should not be empty

  @fallback @planned
  Scenario: Use cached content when download fails
    Given the app has cached networks version "1.0.0"
    And the content server returns an error
    When the app attempts to update
    Then the app should continue using cached networks
    And no data should be lost

  @fallback @planned
  Scenario: Content resolution order
    Given the cache has networks version "1.1.0"
    And bundled networks is version "1.0.0"
    When the app requests the social networks list
    Then the app should return cached networks version "1.1.0"

  # ===========================================
  # User Settings
  # ===========================================

  @settings @planned
  Scenario: Disable remote updates via settings
    Given the user has disabled remote content updates
    When the app launches
    Then no manifest fetch should be attempted
    And the app should use bundled content only

  @settings @planned
  Scenario: Enable remote updates via settings
    Given the user has enabled remote content updates
    And the device is online
    When the app launches
    Then the app should check for updates according to the interval

  @settings @planned
  Scenario: Manual update check
    Given the user is on the settings page
    When the user triggers a manual update check
    Then the app should immediately check for updates
    And the update status should be displayed to the user

  @settings @planned
  Scenario: Apply updates manually
    Given updates are available for networks and locales
    When the user triggers apply updates
    Then both networks and locales should be downloaded
    And the user should see a success message

  # ===========================================
  # Networks Content
  # ===========================================

  @networks @planned
  Scenario: New social network appears after update
    Given the cached networks does not include "threads"
    And the remote networks includes "threads" social network
    When the app applies updates
    Then "threads" should appear in the social networks list
    And users should be able to add Threads profiles

  @networks @planned
  Scenario: Updated network URL template
    Given the cached networks has Twitter URL "https://twitter.com/{handle}"
    And the remote networks has Twitter URL "https://x.com/{handle}"
    When the app applies updates
    Then Twitter profile URLs should use "https://x.com/{handle}"

  # ===========================================
  # Locales Content
  # ===========================================

  @locales @planned
  Scenario: Download locale for user's language
    Given the user's language is "de"
    And the remote manifest has German locale version "1.1.0"
    When the app applies updates
    Then only the German locale file should be downloaded
    And other locale files should not be downloaded

  @locales @planned
  Scenario: Fallback to English when locale unavailable
    Given the user's language is "ja"
    And the remote manifest does not include Japanese locale
    When the app requests locale strings
    Then the app should return English locale strings

  @locales @planned
  Scenario: New translation string after update
    Given the cached English locale is version "1.0.0"
    And the remote English locale version "1.1.0" includes new string "settings.theme"
    When the app applies updates
    Then the "settings.theme" string should be available

  # ===========================================
  # Help Content
  # ===========================================

  @help @planned
  Scenario: Updated FAQ content
    Given the cached help has 5 FAQ entries
    And the remote help has 7 FAQ entries
    When the app applies updates
    Then the help section should show 7 FAQ entries

  @help @planned
  Scenario: Help content in user's language
    Given the user's language is "fr"
    And the remote manifest has French help content
    When the app applies updates
    Then French help content should be downloaded
    And help should display in French

  # ===========================================
  # Themes Content
  # ===========================================

  @themes @planned
  Scenario: New theme available after update
    Given the cached themes only includes "default"
    And the remote themes includes "catppuccin-mocha"
    When the app applies updates
    Then "catppuccin-mocha" should appear in theme selection

  @themes @planned
  Scenario: Apply downloaded theme
    Given the user has downloaded the "catppuccin-mocha" theme
    When the user selects "catppuccin-mocha" theme
    Then the app colors should change to Catppuccin Mocha palette

  # ===========================================
  # Privacy
  # ===========================================

  @privacy @planned
  Scenario: No user identification in requests
    When the app fetches the manifest
    Then the request should not include user identifiers
    And the request should not include device identifiers
    And only the app version should be sent in user-agent

  @privacy @tor @planned
  Scenario: Content fetched via Tor when configured
    Given the user has configured Tor proxy
    When the app fetches content updates
    Then all requests should route through the Tor proxy

  @privacy @planned
  Scenario: HTTPS only
    Given the content URL is "http://vauchi.app/app-files"
    When the app attempts to fetch content
    Then the request should be upgraded to HTTPS
    Or the request should fail with security error

  # ===========================================
  # Error Handling
  # ===========================================

  @error @planned
  Scenario: Network timeout during manifest fetch
    Given the content server takes longer than 30 seconds to respond
    When the app attempts to fetch the manifest
    Then the request should timeout
    And the app should use cached content
    And the error should be logged

  @error @planned
  Scenario: Invalid manifest JSON
    Given the content server returns malformed JSON
    When the app attempts to parse the manifest
    Then a parse error should be reported
    And the app should use cached content

  @error @planned
  Scenario: Exponential backoff on repeated failures
    Given the content server has failed 3 times
    When the app attempts to check for updates
    Then the next check should be delayed
    And the delay should increase exponentially

  # ===========================================
  # Atomic Updates
  # ===========================================

  @atomic @planned
  Scenario: Atomic cache writes
    Given the app is downloading a large content file
    When the download is interrupted at 50%
    Then the cache should not contain partial data
    And the previous cached version should remain intact

  @atomic @planned
  Scenario: Rollback on update failure
    Given updates are available for networks and locales
    And networks download succeeds
    And locales download fails
    When the app applies updates
    Then networks should be updated in cache
    And the partial update should be reported to the user

  # ===========================================
  # Selective Downloads (Bandwidth Optimization)
  # ===========================================

  @selective @locale @planned
  Scenario: Download only selected language
    Given the user's language is set to English
    And German, French, Spanish locales are available remotely
    When the user changes language to German
    Then German locale should be downloaded
    And French locale should not be downloaded
    And Spanish locale should not be downloaded

  @selective @theme @planned
  Scenario: Download only selected theme
    Given the user has default dark theme
    And Catppuccin, Dracula, Nord themes are available remotely
    When the user selects "Catppuccin Mocha"
    Then Catppuccin Mocha theme file should be downloaded
    And Dracula theme should not be downloaded
    And Nord theme should not be downloaded

  @selective @bundled @planned
  Scenario: Bundled content available without download
    Given the device is offline
    And no content has been downloaded
    When the user opens the app
    Then English locale should be available
    And default dark theme should be available
    And default light theme should be available
    And the app should function normally

  @selective @indicator @planned
  Scenario: Show download indicator for unavailable content
    Given German locale is not downloaded
    And Catppuccin Mocha theme is not downloaded
    When the user views language settings
    Then German should show a download indicator
    And English should show as available (bundled)
    When the user views theme settings
    Then Catppuccin Mocha should show a download indicator
    And default themes should show as available (bundled)

  @selective @background @planned
  Scenario: Only update actively used content in background
    Given the user has German locale selected and downloaded
    And the user has Catppuccin Mocha theme selected and downloaded
    And new versions are available for all content types
    When the app performs background update check
    Then only German locale should be updated
    And only Catppuccin Mocha theme should be updated
    And French, Spanish locales should not be downloaded
    And Dracula, Nord themes should not be downloaded

  @selective @size @planned
  Scenario: Show download size before downloading
    Given Catppuccin Mocha theme is 1.5 KB
    When the user taps on Catppuccin Mocha theme
    Then the app should show "Download ~1.5 KB?"
    And the user should see Download and Cancel options

  @selective @offline-pack @planned
  Scenario: Download content pack for offline use
    Given the user wants to use the app offline
    When the user selects "Download for offline" in settings
    Then the user should see options to download all languages
    And the user should see options to download all themes
    And the user should see current download size

  @selective @cleanup @planned
  Scenario: Clean up unused downloaded content
    Given the user downloaded German locale 45 days ago
    And the user's current language is English
    And the cleanup threshold is 30 days
    When the app performs storage cleanup
    Then German locale should be removed from cache
    And English locale should remain (actively used)

  @selective @cancel @planned
  Scenario: Cancel download in progress
    Given the user initiated download of Japanese locale
    And the download is 50% complete
    When the user taps Cancel
    Then the download should stop
    And no partial file should remain in cache
    And the previous locale should remain active
