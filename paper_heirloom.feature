# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@heirloom @privacy @export
Feature: Paper Heirloom Export
  As a Vauchi user
  I want a printable, human-readable record of my contacts
  So that my relationships outlive any app, company or server

  Background:
    Given I have an identity with contacts

  @planned
  Scenario: Export my contacts as a printable document
    When I go to Settings > Privacy > Paper Heirloom
    And I confirm the plaintext warning
    Then I should receive a downloadable HTML document
    And it should list every contact by name with their shared card fields
    And it should show the date we exchanged cards
    And it should show the name of the place we met, when I named it

  @planned
  Scenario: The export is plaintext and leaves the encryption envelope
    When I start a paper heirloom export
    Then I should be warned that the document is not encrypted
    And nothing should be exported until I confirm

  @implemented
  Scenario: The document carries no app-internal identifiers
    When I export a paper heirloom
    Then it should contain no public keys, key fingerprints or contact ids
    And it should contain no exchange coordinates

  @implemented
  Scenario: Contact-provided text cannot inject markup
    Given a contact whose name contains HTML markup
    When I export a paper heirloom
    Then the markup should appear as literal text in the document

  @implemented
  Scenario: Duress mode exports only decoy contacts
    Given I have unlocked the app with my duress PIN
    When I export a paper heirloom
    Then the document should contain only decoy contacts

  @implemented
  Scenario: The same contacts always produce the same document
    When I export a paper heirloom twice without changing anything
    Then both documents should be byte-for-byte identical
