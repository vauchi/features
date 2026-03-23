# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Merged 2026-03-17: duress_pin.feature + duress_password.feature → duress_mode.feature
# PIN scenarios from duress_pin.feature preserve their @implemented tags.
# Password-specific scenarios from duress_password.feature added as @planned.

@security @resistance @coercion @opt-in
Feature: Duress Mode
  As an activist or at-risk user
  I want a secondary PIN or password that shows a decoy contact list
  So that I can protect my real contacts when coerced to unlock my device

  This feature provides plausible deniability under coercion. When a user
  is forced to unlock their device (border crossing, arrest, etc.), entering
  the duress PIN or password reveals a decoy contact list while optionally
  alerting trusted contacts.

  Duress mode supports two entry methods:
  - **Duress PIN**: 6-digit numeric code (separate from unlock PIN)
  - **Duress password**: Alphanumeric password (requires app password enabled first)

  Both entry methods provide identical duress behavior. The choice depends
  on the user's app lock configuration (PIN vs password).

  PRINCIPLES ALIGNMENT:
  - Privacy is a right: Protects contacts under coercion
  - Trust earned in person: Duress alerts go to in-person contacts
  - Simplicity: Simple concept (different credential = different view)
  - User ownership: All data remains local; no central authority

  Background:
    Given I have an existing identity
    And I have contacts in my real contact list

  # ============================================================
  # Setup and Configuration
  # ============================================================

  @setup @implemented
  Scenario: Duress mode is opt-in and disabled by default
    Given I have just installed the app
    When I check Privacy settings
    Then duress mode should be disabled
    And no decoy profile should exist

  @setup @implemented
  Scenario: Enable duress PIN in settings
    Given duress mode is disabled
    When I navigate to Privacy settings
    And I enable "Duress PIN"
    Then I should be prompted to create a duress PIN
    And I should be prompted to set up a decoy profile

  @setup @implemented
  Scenario: Duress PIN must differ from normal PIN
    Given I am setting up a duress PIN
    And my normal PIN is "123456"
    When I try to set duress PIN to "123456"
    Then the PIN should be rejected
    And I should see "Duress PIN must be different from your unlock PIN"

  @setup @implemented
  Scenario: Enable duress password (requires app password)
    Given app password is enabled
    When I navigate to Security settings
    And I enable "Duress password"
    And I authenticate with my real password
    Then I should be prompted to create a duress password
    And the duress password must be different from my real password

  @setup @implemented
  Scenario: Duress password option hidden until app password enabled
    Given app password is not enabled
    When I view Security settings
    Then "Duress password" option should not be visible
    And only duress PIN option should be available

  @setup @planned
  Scenario: Duress password strength requirements
    Given I am setting up a duress password
    Then the duress password should meet requirements:
      | requirement        | description                    |
      | Minimum length     | At least 8 characters          |
      | Different from app | Must not match app password    |
      | Memorable          | User should be able to recall it under stress |

  @setup @implemented
  Scenario: Configure decoy contacts
    Given I have enabled duress mode
    When I configure the decoy profile
    Then I should be able to add fake contacts
    And I should be able to import from system contacts
    And the decoy contacts should be stored separately

  @setup @implemented
  Scenario: Configure trusted contacts for duress alerts
    Given I have enabled duress mode
    When I configure duress alert recipients
    Then I should see my real contacts list
    And I should be able to select up to 5 trusted contacts
    And selected contacts will receive silent alerts on duress unlock

  # ============================================================
  # Decoy Profile Setup
  # ============================================================

  @decoy @planned
  Scenario: Decoy contacts are static (no sync)
    Given I have decoy contacts configured
    Then decoy contacts should not sync
    And decoy contacts should not receive updates
    And decoy contacts are just display data

  @decoy @planned
  Scenario: Make decoy profile believable
    Given I am configuring the decoy profile
    Then I should consider:
      | aspect           | recommendation                           |
      | Contact count    | Have a realistic number (5-20)           |
      | Names            | Use common, believable names             |
      | Recency          | Some should have recent "activity"       |
      | Variety          | Mix of friends, family, work contacts    |

  @decoy @planned
  Scenario: Import decoy contacts from phone
    Given I am configuring the decoy profile
    When I choose "Import from phone contacts"
    Then I should be able to select contacts to copy
    And selected contacts become static decoy entries
    And they are disconnected from real phone contacts

  @decoy @implemented
  Scenario: Pre-populate decoy contacts
    Given I am setting up duress mode
    When I choose to auto-populate decoy contacts
    Then contacts should be created with realistic names
    And cards should contain plausible fake data
    And the list should look like a normal contact list

  # ============================================================
  # Duress Unlock Behavior
  # ============================================================

  @unlock @implemented
  Scenario: Duress credential shows decoy contacts
    Given I have configured duress mode
    And I have configured decoy contacts
    When I unlock the app with the duress PIN or password
    Then I should see the decoy contact list
    And the real contacts should not be accessible
    And no visual indication of duress mode should be visible

  @unlock @implemented
  Scenario: Normal credential shows real contacts
    Given I have configured duress mode
    When I unlock the app with the normal PIN or password
    Then I should see my real contact list
    And the app should function normally

  @unlock @implemented
  Scenario: Duress mode looks identical to normal mode
    Given I have configured duress mode with decoy contacts
    When I unlock with the duress credential
    Then the UI should look identical to normal mode
    And all features should appear to work normally
    And no "duress mode" indicator should be visible anywhere

  @unlock @implemented
  Scenario: Cannot access real contacts from duress mode
    Given I have unlocked with the duress credential
    When I try to access hidden settings or contacts
    Then I should not be able to reach real contacts
    And attempting secret gestures should do nothing

  # ============================================================
  # Duress Mode Behavior
  # ============================================================

  @behavior @planned
  Scenario: Duress mode actions are fake
    Given I am in duress mode
    When I try to sync
    Then a fake sync animation should play
    And no real network activity should occur
    And "Sync complete" should be shown

  # Removed: "Exchange in duress mode is fake" — contradicted line 216
  # ("Exchanges add to decoy profile"). For plausible deniability, the
  # exchange must APPEAR to work. A coercer watching would notice a
  # non-functional QR code. The correct behavior is at line 216: exchange
  # works but adds to decoy profile only.
  # See: audit 2026-03-23, finding H4.

  @behavior @planned
  Scenario: Edits in duress mode are discarded
    Given I am in duress mode
    When I edit my decoy contact card
    And I save the changes
    Then changes should appear saved
    But they should be discarded on logout
    And real data should be unaffected

  @behavior @planned
  Scenario: No trace of duress mode after logout
    Given I was in duress mode
    When I logout or close the app
    And I login with my real credential
    Then I should see my real contacts
    And there should be no trace of duress activity
    And real data should be intact

  @behavior @planned
  Scenario: Exchanges in duress mode add to decoy profile
    Given I am in duress mode
    When I exchange contacts with someone
    Then the new contact should be added to the decoy profile
    And they should NOT be added to the real profile
    And they should receive my decoy card (if configured)

  # ============================================================
  # Silent Alerts
  # ============================================================

  @alert @implemented
  Scenario: Duress unlock sends silent alert to trusted contacts
    Given I have configured trusted contacts for duress alerts
    When I unlock the app with the duress credential
    Then a silent alert should be queued for trusted contacts
    And the alert should be sent via normal sync channel
    And no confirmation should be visible on my device

  @alert @implemented
  Scenario: Duress alert looks like normal sync traffic
    Given I have configured duress alerts
    When I unlock with the duress credential
    Then the alert message should be encrypted
    And to the relay it should look like a normal card update
    And network observers cannot distinguish it from regular traffic

  @alert @implemented
  Scenario: Duress alert content
    Given I have configured trusted contacts for duress alerts
    When a duress alert is sent
    Then the recipient should see "Duress alert from [Name]"
    And the alert should include timestamp
    And the alert should NOT include location unless explicitly enabled

  @alert @planned
  Scenario: Receiving a duress alert
    Given Bob has configured me as a duress alert recipient
    When Bob unlocks with his duress credential
    Then I should receive a duress alert notification
    And the notification should be clearly marked as urgent
    And I should see when the alert was triggered

  @alert @implemented
  Scenario: Duress alerts work offline
    Given I have configured duress alerts
    And I have no network connection
    When I unlock with the duress credential
    Then the alert should be queued locally
    And the alert should be sent when connectivity returns

  # ============================================================
  # Security Properties
  # ============================================================

  @security @implemented
  Scenario: Decoy profile has separate database
    Given I have configured duress mode
    Then the decoy contacts should be stored in a separate encrypted database
    And the decoy database should use the duress credential for encryption
    And the real database should not be accessible with the duress credential

  @security @planned
  Scenario: Real database cryptographically inaccessible in duress mode
    Given I have unlocked with the duress credential
    Then the real database key should not be derivable
    And memory should not contain real database key
    And forensic analysis should not reveal real contacts

  @security @planned
  Scenario: Real keys never loaded in duress mode
    Given I am in duress mode
    Then real encryption keys should not be in memory
    And real identity seed should not be accessed
    And real contacts database should not be decrypted

  @security @implemented
  Scenario: Both databases use strong encryption
    Given I have configured duress mode
    Then the real database should use normal encryption
    And the decoy database should use separate encryption
    And each database key derived from respective credential

  @security @planned
  Scenario: Duress detection should be impossible
    Given an attacker is examining the app
    When they compare duress mode to real mode
    Then behavior should be indistinguishable
    And storage patterns should look similar
    And network timing should be similar

  @security @planned
  Scenario: Credential entry logged (accessible from real mode only)
    Given I have configured duress alerts
    When I unlock with the duress credential
    Then the duress entry should be logged locally
    And the log should be accessible only from real mode
    And I can review when duress mode was used

  @security @planned
  Scenario: Credentials processed identically at UI level
    Given duress mode is enabled
    When observing the login process
    Then entering either credential should look the same
    And timing should be similar
    And no visual difference should reveal which was entered

  # ============================================================
  # Believability
  # ============================================================

  @believability @planned
  Scenario: Decoy app has full functionality appearance
    Given I am in duress mode
    Then all app features should appear to work:
      | feature          | behavior                         |
      | Sync             | Fake animation, "success"        |
      | Exchange         | Shows QR (non-functional)        |
      | Settings         | Fake settings that "save"        |
      | Contact details  | Shows decoy contact info         |
      | Edit card        | Appears to save (discarded)      |

  @believability @planned
  Scenario: Decoy profile has realistic timestamps
    Given I have decoy contacts
    Then decoy contacts should show:
      | field            | behavior                         |
      | Added date       | Realistic past dates             |
      | Last updated     | Staggered, believable dates      |
      | Last seen        | Some recent, some older          |

  @believability @planned
  Scenario: Settings reflect decoy state
    Given I am in duress mode
    When I view settings
    Then settings should show decoy identity name
    And "contacts count" should match decoy count
    And storage usage should be plausible

  # ============================================================
  # Edge Cases
  # ============================================================

  @edge @implemented
  Scenario: Disable duress mode from settings
    Given I have configured duress mode
    When I navigate to Privacy settings in normal mode
    And I disable duress mode
    Then the decoy database should be deleted
    And duress alerts should be disabled
    And the duress credential should no longer work

  @edge @implemented
  Scenario: Cannot disable duress mode from duress mode
    Given I am in duress mode
    When I navigate to Privacy or Security settings
    Then I should not see the option to disable duress
    And I should not be able to access real settings

  @edge @implemented
  Scenario: Wrong credential handling
    Given I have configured duress mode
    When I enter an incorrect credential
    Then normal lockout behavior should apply
    And no indication of duress mode existence should be shown

  @edge @planned
  Scenario: Biometric unlock with duress
    Given I have configured duress mode
    And I have biometric unlock enabled
    Then biometric should unlock to real profile
    And duress mode requires entering the duress credential manually
    And this is by design (coercion typically involves credential demand)

  @edge @implemented
  Scenario: App update preserves duress configuration
    Given I have configured duress mode and decoy profile
    When the app is updated
    Then duress mode should remain configured
    And decoy contacts should be preserved
    And trusted alert contacts should remain set

  @edge @implemented
  Scenario: Decoy profile functions normally
    Given I am in duress mode
    When I view a decoy contact
    Then I should see their card details
    And I should be able to "edit" their visibility
    And changes should persist in the decoy database

  @edge @planned
  Scenario: Duress mode timeout
    Given I am in duress mode
    And the app has been inactive for 5 minutes
    When the app locks due to timeout
    Then I should see the normal login screen
    And either credential will work
    And no indication of previous duress mode

  @edge @planned
  Scenario: Duress mode with notification
    Given I am in duress mode
    And a real update arrives in the background
    Then no notification should be shown
    And the update should be processed silently
    And it will be visible in real mode later

  @edge @planned
  Scenario: Backup includes duress profile
    Given duress mode is enabled
    When I create an encrypted backup
    Then the backup should include duress settings
    And decoy profile should be included
    And restore should preserve duress configuration

  @edge @planned
  Scenario: Multiple duress credentials not supported
    Given duress mode is enabled
    When I try to add another duress credential
    Then this should not be possible
    And only one duress credential is supported
    And this prevents complexity attacks

  @edge @planned
  Scenario: Change duress credential
    Given duress mode is enabled
    When I go to Security settings
    And I authenticate with my real credential
    And I select "Change duress credential"
    Then I should be able to set a new duress credential
    And the old duress credential should stop working

  @edge @planned
  Scenario: Forgot duress credential
    Given I cannot remember my duress credential
    When I login with real credential
    Then I can access duress settings
    And I can reset the duress credential
    And no data is lost

  # ============================================================
  # Decoy Profile Management
  # ============================================================

  @decoy-management @planned
  Scenario: Edit decoy profile from real mode
    Given I am logged in with real credential
    When I go to Security > Duress settings
    And I select "Edit decoy profile"
    Then I should be able to modify decoy contacts
    And I should be able to update decoy card

  @decoy-management @planned
  Scenario: Preview decoy profile
    Given duress mode is enabled
    When I select "Preview decoy profile"
    Then I should see what the decoy profile looks like
    And I should be able to verify it looks realistic
    And I should be clearly in preview mode (not duress)

  @decoy-management @planned
  Scenario: Reset decoy data
    Given duress mode is enabled
    When I choose to reset decoy profile
    And I confirm the action
    Then all decoy contacts should be deleted
    And the decoy card should be reset
    And I should be prompted to set up again
