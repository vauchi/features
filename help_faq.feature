# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@help @faq
Feature: Help & FAQ System
  As a Vauchi user
  I want to access help content and frequently asked questions
  So that I can understand the app without external resources

  Background:
    Given the Vauchi application is running

  # ============================================================
  # FAQ Categories
  # ============================================================

  @categories @planned
  Scenario: View FAQ categories
    When I open the Help section
    Then I should see the following categories:
      | Category        |
      | Getting Started |
      | Privacy         |
      | Recovery        |
      | Contacts        |
      | Updates         |
      | Features        |
    And each category should show its FAQ count

  @categories @planned
  Scenario: Browse FAQs in a category
    When I select the "Privacy" category
    Then I should see only FAQs related to privacy and security
    And each FAQ should show its question
    And I should be able to expand any FAQ to see the answer

  @categories @planned
  Scenario: Category aliases are accepted
    When I search for category "security"
    Then I should see the same FAQs as the "Privacy" category
    And "sync" should show the same FAQs as "Updates"
    And "start" should show the same FAQs as "Getting Started"

  # ============================================================
  # FAQ Content
  # ============================================================

  @content @planned
  Scenario: View a specific FAQ
    When I open FAQ "faq-phone-lost"
    Then I should see the question about losing my phone
    And I should see the detailed answer
    And I should see related FAQs if any exist

  @content @planned
  Scenario: Related FAQs are linked
    Given I am viewing FAQ "faq-tracking"
    Then I should see related FAQs suggested
    And tapping a related FAQ should navigate to it

  @content @planned
  Scenario: All categories have at least one FAQ
    When I list all FAQ categories
    Then every category should have at least one FAQ entry
    And no FAQ should be uncategorized

  @content @planned
  Scenario: FAQ content covers core topics
    When I list all FAQs
    Then there should be FAQs covering:
      | Topic                      |
      | What happens if I lose my phone |
      | How to set up recovery     |
      | Does Vauchi track me       |
      | Where is my data stored    |
      | How is my data encrypted   |
      | How to remove a contact    |
      | How to block a contact     |
      | How updates work           |
      | What happens when I'm offline |
      | How to add my first contact |
      | Why exchange is in-person  |
      | What are visibility labels |
      | Default visibility rules   |
      | Using multiple devices     |

  # ============================================================
  # Search
  # ============================================================

  @search @planned
  Scenario: Search FAQs by keyword
    When I search for "encryption"
    Then I should see FAQs mentioning encryption
    And the results should be ranked by relevance

  @search @planned
  Scenario: Search with no results
    When I search for "xyznonexistent"
    Then I should see an empty result set
    And I should see a message indicating no FAQs matched

  @search @planned
  Scenario: Search is case-insensitive
    When I search for "RECOVERY"
    Then I should see the same results as searching for "recovery"

  # ============================================================
  # Localization
  # ============================================================

  @i18n @planned
  Scenario: FAQs are shown in the user's language
    Given my locale is set to "de"
    When I view the FAQ list
    Then questions and answers should be displayed in German

  @i18n @planned
  Scenario Outline: FAQ localization for supported languages
    Given my locale is set to "<locale>"
    When I view FAQ "faq-tracking"
    Then the question should be in "<language>"
    And the answer should be in "<language>"

    Examples:
      | locale | language |
      | en     | English  |
      | de     | German   |
      | fr     | French   |
      | es     | Spanish  |

  @i18n @planned
  Scenario: FAQ falls back to English for unsupported locale
    Given my locale is set to "xx"
    When I view the FAQ list
    Then FAQs should be displayed in English

  # ============================================================
  # Platform Access
  # ============================================================

  @platform @planned
  Scenario: Access FAQs from CLI
    When I run "vauchi faq list"
    Then I should see all FAQs formatted for the terminal

  @platform @planned
  Scenario: Search FAQs from CLI
    When I run "vauchi faq list --query encryption"
    Then I should see only FAQs matching "encryption"

  @platform @planned
  Scenario: View FAQ categories from CLI
    When I run "vauchi faq categories"
    Then I should see all categories with their FAQ counts

  @platform @planned
  Scenario: View specific FAQ from CLI
    When I run "vauchi faq show faq-phone-lost"
    Then I should see the full question and answer
    And I should see related FAQ IDs if any exist

  @platform @planned
  Scenario: Access FAQs from desktop app
    When I navigate to the Help page
    Then I should see a searchable FAQ interface
    And I should be able to browse by category

  @platform @planned
  Scenario: Access FAQs from TUI
    When I navigate to the Help screen
    Then I should see FAQ content navigable with keyboard

  # ============================================================
  # Offline & Updates
  # ============================================================

  @offline @planned
  Scenario: FAQs are available offline
    Given I have no network connection
    When I open the Help section
    Then I should see all bundled FAQ content
    And no error should be shown

  @updates @planned
  Scenario: FAQ content updated via remote content
    Given a new FAQ has been published remotely
    When the app fetches content updates
    Then the new FAQ should appear in the Help section
    And existing FAQs should be preserved
