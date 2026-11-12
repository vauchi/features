# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@performance
Feature: Performance Requirements
  As a Vauchi user
  I want the app to be fast and efficient
  So that it doesn't impact my device negatively

  @storage @implemented
  Scenario: Reasonable storage footprint
    Given I have 100 contacts
    Then local storage should be under 50MB
    And deleting data should shrink the database file
