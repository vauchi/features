# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@i18n @internationalization
Feature: Internationalization
  As a user who speaks a language other than English
  I want Vauchi to be available in my language
  So that I can use the app comfortably
  # ============================================================
  # Language Selection
  # ============================================================

  @language @implemented
  Scenario: App uses system language by default
    Given my device is set to German
    When I open the app for the first time
    Then the app should display in German
    And all UI text should be translated
    And the language should not need manual configuration

  @language @planned
  Scenario: App falls back to English for unsupported languages
    Given my device is set to an unsupported language
    When I open the app
    Then the app should display in English
    And a notice should offer to help translate
    And all functionality should remain available

  @language @planned
  Scenario: Override system language in settings
    Given my device is set to English
    When I go to Settings > Language
    And I select French
    Then the app should display in French
    And this preference should persist
    And I should be able to return to system default

  @language @implemented
  Scenario: Language change applies immediately
    Given the app is displaying in English
    When I change the language to Spanish
    Then the UI should update immediately
    And I should not need to restart the app
    And all screens should reflect the new language

  @language @implemented
  Scenario: Available languages are listed
    When I view the language selection screen
    Then I should see a list of available languages
    And each language should be shown in its native script
    And the current language should be indicated
  # ============================================================
  # Supported Languages
  # ============================================================

  @languages @planned
  Scenario Outline: Core languages are supported
    Given my device is set to <language>
    When I open the app
    Then all UI strings should be translated
    And no English fallback text should appear
    And the translation should be complete

    Examples:
      | language   |
      | English    |
      | German     |
      | French     |
      | Spanish    |
      | Italian    |
      | Portuguese |

  @languages @future @planned
  Scenario Outline: Extended language support
    Given my device is set to <language>
    When I open the app
    Then the app should display in <language>
    And translations should be culturally appropriate

    Examples:
      | language              |
      | Japanese              |
      | Chinese (Simplified)  |
      | Chinese (Traditional) |
      | Korean                |
      | Arabic                |
      | Hebrew                |
      | Russian               |
      | Hindi                 |
  # ============================================================
  # Right-to-Left (RTL) Support
  # ============================================================

  @rtl @planned
  Scenario: RTL layout for Arabic
    Given my device is set to Arabic
    When I open the app
    Then the layout should be mirrored (RTL)
    And text should align to the right
    And navigation should flow right-to-left

  @rtl @planned
  Scenario: RTL layout for Hebrew
    Given my device is set to Hebrew
    When I open the app
    Then the layout should be mirrored (RTL)
    And icons that indicate direction should be mirrored
    And the app should feel natural for RTL users

  @rtl @planned
  Scenario: Mixed LTR and RTL content
    Given my device is set to Arabic
    And a contact has an English name and Arabic notes
    When I view the contact
    Then each text block should use appropriate direction
    And the layout should handle mixed content gracefully
    And email addresses should remain LTR

  @rtl @planned
  Scenario: RTL icons are mirrored appropriately
    Given my device is set to Arabic
    When I view the app
    Then directional icons (back, forward) should be mirrored
    And non-directional icons should not be mirrored
    And the visual flow should be consistent
  # ============================================================
  # Locale-Aware Formatting
  # ============================================================

  @locale @dates @planned
  Scenario: Dates formatted according to locale
    Given my device is set to German (Germany)
    When I view a date in the app
    Then it should be formatted as "21. Januar 2026"
    And not as "January 21, 2026"
    And the format should follow German conventions

  @locale @dates @planned
  Scenario: Relative dates are localized
    Given my device is set to French
    When I view "last updated 2 days ago"
    Then it should display as "mis à jour il y a 2 jours"
    And relative time expressions should be natural

  @locale @numbers @planned
  Scenario: Numbers formatted according to locale
    Given my device is set to German
    When I view a number like 1234.56
    Then it should be formatted as "1.234,56"
    And thousand separators should follow locale conventions
    And decimal separators should follow locale conventions

  @locale @phone @planned
  Scenario: Phone numbers respect regional format
    Given I am viewing a contact with a phone number
    When the contact is from Germany
    Then the phone number should display in German format
    And international format should be available
    And the format should be familiar to the user

  @locale @currency @planned
  Scenario: Currency displays correctly
    Given the app displays a donation amount
    When my device is set to German
    Then currency should use Euro symbol and format
    And the format should follow locale conventions
  # ============================================================
  # Contact Card Content
  # ============================================================

  @content @planned
  Scenario: Contact names display in original script
    Given Bob has a contact named "田中太郎" (Japanese)
    When Bob views this contact
    Then the name should display in Japanese characters
    And no transliteration should be forced
    And the name should be searchable

  @content @planned
  Scenario: Mixed-script contact cards
    Given a contact has:
      | Field | Value               |
      | Name  | محمد أحمد           |
      | Email | mohamed@example.com |
      | Notes | Some English notes  |
    When I view this contact
    Then each field should render in the appropriate direction
    And the card should be readable and well-formatted

  @content @planned
  Scenario: Input methods work for all languages
    Given I am editing my contact card
    When I type in Japanese using an IME
    Then the input should be handled correctly
    And character composition should work
    And the text should be saved correctly
  # ============================================================
  # Search and Sorting
  # ============================================================

  @search @planned
  Scenario: Search works across scripts
    Given I have contacts with names in multiple scripts
    When I search for "田中"
    Then contacts with "田中" in their name should appear
    And the search should handle Unicode correctly

  @search @planned
  Scenario: Transliteration search
    Given I have a contact named "Müller"
    When I search for "Muller" (without umlaut)
    Then "Müller" should still be found
    And accented characters should match their base forms

  @sorting @planned
  Scenario: Contacts sorted according to locale
    Given my device is set to Swedish
    And I have contacts: Anders, Öberg, Ångström, Berg
    When I view the contacts list
    Then they should be sorted as: Anders, Berg, Ångström, Öberg
    And the sort order should follow Swedish collation rules

  @sorting @planned
  Scenario: CJK name sorting
    Given my device is set to Japanese
    And I have contacts with Japanese names
    When I view the contacts list
    Then names should be sorted by reading (kana)
    # Or sorted by stroke count if readings unavailable
  # ============================================================
  # Error Messages and Help
  # ============================================================

  @errors @implemented
  Scenario: Error messages are translated
    Given my device is set to Spanish
    When an error occurs
    Then the error message should be in Spanish
    And the message should be culturally appropriate
    And technical terms should be localized

  @help @planned
  Scenario: Help content is translated
    Given my device is set to French
    When I access the Help section
    Then all help articles should be in French
    And screenshots should show French UI
    And links should point to French resources

  @onboarding @planned
  Scenario: Onboarding is fully translated
    Given my device is set to German
    When I go through the onboarding flow
    Then all text should be in German
    And any videos or images should be localized
    And the value proposition should be clear
  # ============================================================
  # Pluralization and Grammar
  # ============================================================

  @pluralization @planned
  Scenario Outline: Correct pluralization
    Given my device is set to <language>
    When I have <count> contacts
    Then the display should show "<expected>"
    And the grammar should be correct for the language

    Examples:
      | language | count | expected        |
      | English  |     0 |      0 contacts |
      | English  |     1 |       1 contact |
      | English  |     5 |      5 contacts |
      | Russian  |     1 |       1 контакт |
      | Russian  |     2 |      2 контакта |
      | Russian  |     5 |     5 контактов |
      | Arabic   |     0 | ٠ جهات اتصال    |
      | Arabic   |     1 | جهة اتصال واحدة |
      | Arabic   |     2 | جهتا اتصال      |
      | Arabic   |    10 | ١٠ جهات اتصال   |

  @grammar @planned
  Scenario: Gender agreement in translations
    Given my device is set to French
    When the app refers to "your card"
    Then it should use correct gender agreement
    And articles should match noun gender
    And adjectives should agree appropriately
  # ============================================================
  # Translation Quality
  # ============================================================

  @quality @implemented
  Scenario: No untranslated strings visible
    Given my device is set to a supported language
    When I navigate through all screens
    Then I should not see any English strings
    And all dynamic content placeholders should be filled
    And the UI should feel native

  @quality @planned
  Scenario: Translations fit the UI
    Given my device is set to German
    When I view buttons and labels
    Then text should not be truncated
    And buttons should not overflow
    And the layout should accommodate longer translations

  @quality @planned
  Scenario: Consistent terminology
    Given I am using the app in French
    Then the same concept should use the same translation throughout
    And "contact card" should always be "fiche de contact"
    And terminology should be consistent with platform conventions
  # ============================================================
  # Translation Contribution
  # ============================================================

  @contribution @planned
  Scenario: Users can suggest translations
    Given I find a mistranslation
    When I long-press on the text (or use a menu option)
    Then I should be able to suggest a correction
    And my suggestion should be submitted for review
    And I should see confirmation that it was received

  @contribution @planned
  Scenario: Community translation portal
    When I visit the translation contribution page
    Then I should see strings that need translation
    And I should be able to contribute translations
    And I should see my contribution statistics
  # ============================================================
  # Technical Requirements
  # ============================================================

  @technical @implemented
  Scenario: Locale files are complete
    Given the app is built
    Then each supported locale should have 100% string coverage
    And missing translations should fail the build
    And locale files should be validated for syntax

  @technical @planned
  Scenario: No hardcoded strings in code
    Given I review the codebase
    Then all user-visible strings should use localization APIs
    And no strings should be hardcoded in code
    And string extraction should capture all text

  @technical @planned
  Scenario: Locale data is bundled with app
    Given the user has no internet connection
    When they change the app language
    Then translations should work offline
    And no network request should be required
    And the language change should be instant
