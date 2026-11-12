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

  @language @implemented
  Scenario: App falls back to English for unsupported languages
    Given my device is set to an unsupported language
    When I open the app
    Then the app should display in English
    And all functionality should remain available

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

  @languages @implemented
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

  @errors @implemented
  Scenario: Error messages are translated
    Given my device is set to Spanish
    When an error occurs
    Then the error message should be in Spanish
    And the message should be culturally appropriate
    And technical terms should be localized

  @quality @implemented
  Scenario: No untranslated strings visible
    Given my device is set to a supported language
    When I navigate through all screens
    Then I should not see any English strings
    And all dynamic content placeholders should be filled
    And the UI should feel native

  @technical @implemented
  Scenario: Locale files are complete
    Given the app is built
    Then each supported locale should have 100% string coverage
    And missing translations should fail the build
    And locale files should be validated for syntax
