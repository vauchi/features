# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later
@security @resistance @emergency @widget @ui
Feature: Panic Button Widget
  As an activist or at-risk user
  I want a home screen widget that triggers immediate data destruction
  So that I can protect my contacts when I have only seconds to act

  This feature extends Emergency Shred (emergency_shred.feature) by providing
  a quick-access widget that triggers Panic Shred without opening the app.

  PRINCIPLES ALIGNMENT:
  - Privacy is a right: Enables privacy through rapid data destruction
  - Simplicity: One tap destruction — maximum simplicity
  - User ownership: User controls when to destroy; no remote trigger
  - No harvesting: Widget action is not logged externally

  Background:
    Given I have an existing identity
    And I have contacts and stored data
  # ============================================================
  # Widget Setup
  # ============================================================

  @shred @implemented
  Scenario: Widget triggers full panic shred
    Given I have triggered panic via the widget
    Then the panic shred process should execute per emergency_shred.feature
    And all cryptographic keys should be destroyed
    And all local data should be wiped

  @auth @implemented
  Scenario: Widget works without app unlock
    Given the app is locked
    When I trigger the panic widget
    Then the widget should NOT require unlocking the app
    And panic shred should proceed immediately
    And this is intentional for emergency scenarios
