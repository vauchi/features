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

  The duress credential is a six-digit PIN, separate from the app
  password, which must be set first. The claims chapter states the PIN's
  limit: someone who images the device and also holds the storage master
  key can guess it offline. (The API still calls it a duress password;
  it accepts six ASCII digits and nothing else.)

  PRINCIPLES ALIGNMENT:
  - Privacy is a right: Protects contacts under coercion
  - Trust earned in person: a duress unlock tells no one, so nothing can
    give it away; the emergency broadcast is the way to alert contacts
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
    And my device has biometric unlock
    When I navigate to Privacy settings
    And I enable "Duress PIN"
    Then I should be prompted to create a 6-digit duress PIN
    And I should be prompted to set up a decoy profile

  @setup @implemented
  Scenario: Duress PIN must differ from normal PIN
    Given I am setting up a duress PIN
    And my normal PIN is "123456"
    When I try to set duress PIN to "123456"
    Then the PIN should be rejected
    And I should see "Duress PIN must be different from your unlock PIN"

  @setup @implemented
  # ADR-032 amendment 2026-11-10: without biometric unlock in front of it,
  # a 6-digit duress PIN falls to an offline guess in minutes.
  Scenario: Enable duress password (requires app password)
    Given app password is enabled
    And my device has no biometric unlock
    When I navigate to Security settings
    And I enable "Duress password"
    And I authenticate with my real password
    Then I should be prompted to create a duress password
    And the duress password must be different from my real password

  @setup @implemented
  Scenario: Duress PIN requires an app password
    Given app password is not enabled
    When I try to set up a duress PIN
    Then the setup should be refused
    And I should be told an app password is needed first

  @setup @implemented
  Scenario: Duress credential is six digits
    Given my device has biometric unlock
    And I am setting up a duress PIN
    When I enter anything but six ASCII digits
    Then the PIN should be rejected
    And six ASCII digits should be accepted
    # Rewritten 2026-11-10 (vauchi/private#1196): the credential is a
    # six-digit PIN, not an alphanumeric password. Without biometric
    # unlock it is a password instead (ADR-032 amendment 2026-11-10).

  @setup @planned
  Scenario: Duress password strength requirements
    Given my device has no biometric unlock
    And I am setting up a duress password
    Then the app password and the duress password should each meet:
      | requirement        | description                                   |
      | Minimum length     | At least 8 characters                         |
      | Hard to guess      | The same strength rule as a backup password   |
      | Different from app | The duress password must not match it         |
    And a weak app password should be named, with an offer to change it
    And while duress is set, the app password should not change to a weak one

  @setup @implemented
  Scenario: Configure decoy contacts
    Given I have enabled duress mode
    When I configure the decoy profile
    Then I should be able to add fake contacts
    And the decoy contacts should be stored separately
    # Importing from the system contacts is "Import decoy contacts from
    # phone" below, still planned (vauchi/private#1196).

  # ============================================================
  # Decoy Profile Setup
  # ============================================================

  @decoy @implemented
  Scenario: Decoy contacts are static (no sync)
    Given I have decoy contacts configured
    Then decoy contacts should not sync
    And decoy contacts should not receive updates
    And decoy contacts are just display data

  @decoy @planned
  Scenario: Make decoy profile believable
    Given I am configuring the decoy profile
    Then I should consider:
      | aspect        | recommendation                        |
      | Contact count | Have a realistic number (5-20)        |
      | Names         | Use common, believable names          |
      | Recency       | Some should have recent "activity"    |
      | Variety       | Mix of friends, family, work contacts |

  @decoy @planned
  Scenario: Import decoy contacts from phone
    Given I am configuring the decoy profile
    When I choose "Import from phone contacts"
    Then I should be able to select contacts to copy
    And selected contacts become static decoy entries
    And they are disconnected from real phone contacts

  @decoy @planned
  Scenario: Pre-populate decoy contacts
    Given I am setting up duress mode
    When I choose to auto-populate decoy contacts
    Then a small handful of contacts should be created (roughly 3 to 8)
    And their cards should be sparse, a phone or an email, rarely both
    And their timestamps should spread plausibly over months
    And no two generated profiles should be identical
    # ADR-032 addendum 2026-07-04: decoys read as an almost unused app.

  @decoy @planned
  Scenario: Auto-generated decoys read as an almost unused app
    Given my decoy profile was auto-populated
    Then the decoy profile should resemble a lightly used app, not a template:
      | aspect         | requirement                                   |
      | Contact count  | small (roughly 3-8), not a full address book  |
      | Card detail    | sparse — a phone or an email, rarely both     |
      | Timestamps     | plausible, spread over months, none identical |
      | Update history | little to none — an almost unused app         |
      | Names          | locale-plausible, no repeating patterns       |
    And no two auto-generated decoy profiles should be identical
    # A sparse profile is the credible cover: heavy curated-looking decoys
    # are hard to fake convincingly; "barely uses the app" is common and
    # explains away every gap a coercer might probe (ADR-032 addendum
    # 2026-07-04).
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

  @behavior @implemented
  Scenario: Duress mode sync is real but carries nothing real
    Given I am in duress mode
    When the app syncs
    Then the sync should run as it does in normal mode
    And no real contact data should be synced
    And what it sends should be cover items of the real items' lengths
    And the other device should treat a cover item as nothing
    # Rewritten 2026-11-10 (vauchi/private#1196): the sync is not faked.
    # The mask profile syncs for real; a duress edit journals cover of the
    # real item's length (ADR-032 addendum, ADR-080), and a duress unlock
    # sends nothing (see "A duress unlock sends nothing").
  # Removed: "Exchange in duress mode is fake" — contradicted line 216
  # ("Exchanges add to decoy profile"). For plausible deniability, the
  # exchange must APPEAR to work. A coercer watching would notice a
  # non-functional QR code. The correct behavior is at line 216: exchange
  # works but adds to decoy profile only.
  # See: audit 2026-03-23, finding H4.

  @behavior @implemented
  Scenario: Edits in duress mode stay in the decoy profile
    Given I am in duress mode
    When I edit my decoy contact card
    And I save the changes
    Then the changes should be saved in the decoy profile
    And they should still be there after a lock and a second duress unlock
    And the real card should be untouched
    And disabling duress mode should discard them
    # Rewritten 2026-11-10 (vauchi/private#1196): discarding edits on
    # logout would give the mode away (see "What a duress session makes
    # survives a lock"). They live in the mask profile until duress is
    # disabled.

  @behavior @implemented
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
  # No Alerts (ADR-032 amendment 2026-10-11)
  # ============================================================

  @alert @implemented
  Scenario: A duress unlock sends nothing
    Given I have exchanged contacts
    When I unlock the app with the duress credential
    Then nothing should be queued for any contact
    And an alert claiming to be a duress alert should be rejected
  # ============================================================
  # Security Properties
  # ============================================================

  @security @implemented
  Scenario: Decoy profile has separate database
    Given I have configured duress mode
    Then the decoy contacts should be stored in a separate encrypted database
    And the decoy database should use the duress credential for encryption
    And the real database should not be accessible with the duress credential

  @security @implemented
  Scenario: Real database cryptographically inaccessible in duress mode
    Given I have unlocked with the duress credential
    Then the real database key should not be derivable from the duress credential
    And the foreground should hold no real key, seed or emergency message
    And the duress content should open under the mask key only
    # Narrowed 2026-11-10 (ADR-080, vauchi/private#1196): the real profile
    # runs as a background worker, so process memory does hold its key;
    # what is promised is that nothing reachable from the foreground does.

  @security @implemented
  Scenario: Real keys never loaded in duress mode
    Given I am in duress mode
    Then no real encryption key should be reachable from the foreground
    And the real identity seed should not be accessible
    And the real contacts should not be readable
    # Narrowed to the foreground, as ADR-080 says: the real profile's
    # background worker holds its keys and exposes nothing to the UI.

  @security @implemented
  Scenario: Both databases use strong encryption
    Given I have configured duress mode
    Then the real database should use normal encryption
    And the decoy database should use separate encryption
    And each database key derived from respective credential

  @security @implemented
  Scenario: The storage file does not reveal whether a duress PIN exists
    Given two installations with an app password, one also with a duress PIN
    When someone reads both storage files without the storage key
    Then the identity rows should have the same columns set and blob lengths
    And both should have a duress copy of the own card
    And a duress session or disabling the PIN should leave them so

  @security @planned
  Scenario: Duress detection should be impossible
    Given an attacker is examining the app
    When they compare duress mode to real mode
    Then behavior should be indistinguishable
    And storage patterns should look similar
    And network timing should be similar

  @security @planned
  Scenario: Credential entry logged (accessible from real mode only)
    Given I have configured duress mode
    When I unlock with the duress credential
    Then the duress entry should be logged locally
    And the log should be accessible only from real mode
    And I can review when duress mode was used

  @security @implemented
  Scenario: Credentials processed identically at UI level
    Given duress mode is enabled
    When observing the login process
    Then entering either credential should look the same
    And both credentials should be checked every time, in constant time
    And with biometric unlock the lock screen should look as it does without duress
    And a PIN typed before the biometric check should be refused as a wrong one
    And no visual difference should reveal which was entered
  # ============================================================
  # Believability
  # ============================================================

  @believability @planned
  Scenario: Decoy app has full functionality appearance
    Given I am in duress mode
    Then all app features should appear to work:
      | feature         | behavior                    |
      | Sync            | Runs, carries only cover    |
      | Exchange        | Works, adds to the decoys   |
      | Settings        | Fake settings that "save"   |
      | Contact details | Shows decoy contact info    |
      | Edit card       | Appears to save (discarded) |

  @believability @implemented
  Scenario: Decoy profile has realistic timestamps
    Given I have decoy contacts
    Then decoy contacts should show:
      | field        | behavior                                  |
      | Added date   | Past dates inside a documented window     |
      | Last updated | At least a week old, after the added date |
    And no two decoys should share the same dates

  @believability @implemented
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
    And the duress credential should no longer work

  @edge @implemented
  Scenario: Cannot disable duress mode from duress mode
    Given I am in duress mode
    When I navigate to Privacy or Security settings
    Then I should not see the option to disable duress
    And I should not be able to access real settings

  @edge @implemented
  Scenario: The duress setup is invisible in duress mode
    Given I am in duress mode
    When I read the duress settings, the decoy list or the emergency status
    Then the duress PIN should read as not set up
    And the decoy contacts should not be named
    And the emergency status should show no duress protection and no trusted contacts
    And no screen should show a real contact, group, tag or place

  @edge @implemented
  Scenario: The duress setup cannot be changed in duress mode
    Given I am in duress mode
    When I set a new duress PIN, add or remove decoys, or disable duress
    Then the real duress setup should be unchanged
    And the real duress PIN should still work
    And the PIN set in duress mode should never have been stored

  @edge @implemented
  Scenario: Changes made in duress mode look like they worked
    Given I am in duress mode
    When I change the duress setup or the decoys
    Then the changes should read back as done for the rest of the session
    And a decoy added in duress mode should stay out of the contact list

  @edge @implemented
  Scenario: Wrong credential handling
    Given I have configured duress mode
    When I enter an incorrect credential
    Then normal lockout behavior should apply
    And no indication of duress mode existence should be shown

  @edge @implemented
  Scenario: Biometric unlock with duress
    Given I have configured duress mode
    And I have biometric unlock enabled
    When biometric authentication succeeds on the lock screen
    Then the lock screen should ask for my PIN without offering biometrics
    And my normal PIN should open my real profile
    And my duress PIN should open the decoy profile the same way
    But a PIN typed before biometric authentication should open nothing

  @edge @implemented
  Scenario: Biometric unlock without duress
    Given I have an app password but no duress PIN
    And I have biometric unlock enabled
    When biometric authentication succeeds on the lock screen
    Then the app should open my real profile

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

  # A group that vanishes after a lock gives the mode away (vauchi/private#813,
  # the own card in #811): the duress session's groups, tags and places live
  # in twin tables of the real database, never in the real ones.
  @edge @implemented
  Scenario: What a duress session makes survives a lock
    Given I am in duress mode
    And I have created a group, a tag and a named place
    When the app locks
    And I unlock with the duress credential again
    Then the group, the tag and the place should still be there
    And the real groups, tags and places should be unchanged
    And disabling duress mode should discard them

  @edge @planned
  Scenario: Duress mode timeout
    Given I am in duress mode
    And the app has been inactive for 5 minutes
    When the app locks due to timeout
    Then I should see the normal login screen
    And either credential will work
    And no indication of previous duress mode

  @edge @implemented
  Scenario: Duress mode with notification
    Given I am in duress mode
    And a real update arrives in the background
    Then no notification should be shown
    And the update should be processed silently
    And it will be visible in real mode later

  @edge @implemented
  Scenario: Backup includes duress profile
    Given duress mode is enabled
    When I create an encrypted backup
    Then the backup should include duress settings
    And decoy profile should be included
    And restore should preserve duress configuration
    And restore should keep whether duress needs biometrics or two passwords

  # ADR-080 point 7: the second payload is the same size whether it holds a
  # decoy or nothing, so the file does not show that duress is set.
  @edge @planned
  Scenario: A decoy backup password opens only the decoy profile
    Given duress mode is enabled on my real profile
    When I create a backup with a backup password and a decoy backup password
    Then restoring with the decoy backup password should give the decoy profile only
    And it should lock with the duress credential and have no duress of its own
    And a restore should not tell which payload opened from its error or timing

  # ADR-080: a wipe sent from another device runs in the coercer's hands, who
  # sees the app wipe itself. Accepted (owner, 2026-11-07).
  @edge @planned
  Scenario: A remote wipe applies during duress
    Given I am in duress mode on this device
    When I wipe this device from another of my devices
    Then the real profile running in the background should apply the wipe
    And every profile on this device should be destroyed

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
