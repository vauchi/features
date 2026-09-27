# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
# SPDX-License-Identifier: GPL-3.0-or-later

@architecture @presentation @command-event
Feature: Generic presentation command/event protocol

  @implemented
  Scenario: Every shell renders the same prepared presentation
    Given Core has prepared a generic presentation command
    When each supported shell receives that command
    Then each shell renders the supplied content without domain interpretation

  @planned
  Scenario: User interaction returns as an opaque event
    Given a rendered action with an opaque binding identifier
    When the user activates that action
    Then the shell returns the identifier and raw value unchanged
    And Core interprets the event and decides the next commands

  @planned
  Scenario: Core chooses a capability-compatible presentation
    Given a shell reports its generic capabilities
    When Core prepares the next presentation
    Then Core emits only commands supported by those capabilities
    And the shell does not know which domain feature requested them

  @implemented
  Scenario: Invalid boundary input fails safely
    Given a malformed or oversized command or event payload
    When the boundary decoder receives it
    Then the payload is rejected without exposing internal state

  @implemented
  Scenario: Contextual controls expose four stable roles
    Given Core has prepared controls for the active surface
    When a shell renders the contextual control surface
    Then supplied roles define Back, navigation, primary, and secondary actions

  @implemented
  Scenario Outline: Available window drives structural composition
    Given the available logical window width is <width>
    When Core recomposes the presentation
    Then Core emits the <composition> structural composition

    Examples:
      | width | composition |
      | 599   | compact     |
      | 600   | medium      |
      | 839   | medium      |
      | 840   | expanded    |

  @implemented
  Scenario Outline: Class boundaries are damped on collapse
    Given the presentation is <from> at an available width of <start>
    When the available width shrinks to <width>
    Then Core emits the <composition> structural composition

    Examples:
      | from     | start | width | composition |
      | medium   | 600   | 568   | medium      |
      | medium   | 600   | 567   | compact     |
      | expanded | 840   | 808   | expanded    |
      | expanded | 840   | 807   | medium      |
      | expanded | 1200  | 580   | medium      |

  @implemented
  Scenario: Interaction activates its visible pane first
    Given two visible panes have stable opaque surface identifiers
    And the secondary pane is inactive
    When the user activates an action in the secondary pane
    Then Core activates the secondary surface before interpreting the action

  @implemented
  Scenario: Responsive transitions preserve interaction state
    Given an expanded two-pane presentation with a selected detail
    And a reversible primary action is available
    When the available window collapses and expands again
    Then the detail remains reachable with its selection and Undo state

  @implemented
  Scenario: Primary action becomes causal Undo
    Given the primary action causes a reversible mutation
    When Core prepares the next contextual controls
    Then Undo occupies the primary role for that mutation
    And invoking Undo restores the previous primary role

  @implemented
  Scenario: Overlay kinds remain distinct with reduced motion
    Given navigation and secondary-action overlays are available
    When the shell uses full or reduced motion
    Then the two overlay kinds remain structurally distinguishable

  @implemented
  Scenario: Release contains only the generic action system
    Given all supported shells consume the generic command/event protocol
    When release validation runs
    Then no ScreenModel action channel or shell-selected navigation remains
