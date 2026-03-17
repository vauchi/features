# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@theming @appearance
Feature: App Theming
  As a Vauchi user
  I want to customize the app's appearance with different color themes
  So that I can personalize my experience and reduce eye strain

  Background:
    Given the app is installed and configured

  # ===========================================
  # Theme Selection
  # ===========================================

  @selection @implemented
  Scenario: Default theme on fresh install
    Given this is a fresh app installation
    When the app launches
    Then the "default" dark theme should be applied
    And the theme should respect system dark/light mode preference

  @selection @planned
  Scenario: Select theme from settings
    Given the user is on the settings page
    When the user navigates to "Appearance"
    Then the user should see a list of available themes
    And the current theme should be indicated

  @selection @planned
  Scenario: Preview theme before applying
    Given the user is viewing theme options
    When the user taps on "Catppuccin Mocha"
    Then the app should preview the theme colors
    And the user should see "Apply" and "Cancel" options

  @selection @planned
  Scenario: Apply selected theme
    Given the user has previewed "Catppuccin Mocha" theme
    When the user confirms the theme selection
    Then the theme should be saved to settings
    And the theme should persist after app restart

  @selection @planned
  Scenario: Theme persists across sessions
    Given the user has selected "Nord" theme
    When the user closes and reopens the app
    Then the "Nord" theme should still be applied

  # ===========================================
  # Catppuccin Themes
  # ===========================================

  @catppuccin @implemented
  Scenario Outline: Catppuccin flavor themes available
    Given themes have been downloaded from remote content
    When the user views available themes
    Then "<flavor>" should be listed as an option
    And the theme should be labeled as "Catppuccin <flavor>"

    Examples:
      | flavor     |
      | Latte      |
      | Frappé     |
      | Macchiato  |
      | Mocha      |

  @catppuccin @dark @implemented
  Scenario: Apply Catppuccin Mocha (dark)
    When the user applies "Catppuccin Mocha" theme
    Then the background primary color should be "#1e1e2e"
    And the text primary color should be "#cdd6f4"
    And the accent color should be "#89b4fa"

  @catppuccin @dark @implemented
  Scenario: Apply Catppuccin Macchiato (dark)
    When the user applies "Catppuccin Macchiato" theme
    Then the background primary color should be "#24273a"
    And the text primary color should be "#cad3f5"
    And the accent color should be "#8aadf4"

  @catppuccin @dark @implemented
  Scenario: Apply Catppuccin Frappé (dark)
    When the user applies "Catppuccin Frappé" theme
    Then the background primary color should be "#303446"
    And the text primary color should be "#c6d0f5"
    And the accent color should be "#8caaee"

  @catppuccin @light @implemented
  Scenario: Apply Catppuccin Latte (light)
    When the user applies "Catppuccin Latte" theme
    Then the background primary color should be "#eff1f5"
    And the text primary color should be "#4c4f69"
    And the accent color should be "#1e66f5"

  @catppuccin @accent @planned
  Scenario: Catppuccin themes use consistent semantic colors
    When the user applies any Catppuccin theme
    Then the success color should use the "green" palette color
    And the error color should use the "red" palette color
    And the warning color should use the "peach" palette color

  # ===========================================
  # Other Open Source Themes
  # ===========================================

  @dracula @planned
  Scenario: Dracula theme available
    Given themes have been downloaded from remote content
    When the user views available themes
    Then "Dracula" should be listed as an option

  @dracula @planned
  Scenario: Apply Dracula theme
    When the user applies "Dracula" theme
    Then the background primary color should be "#282a36"
    And the text primary color should be "#f8f8f2"
    And the accent color should be "#bd93f9"

  @nord @planned
  Scenario: Nord theme available
    Given themes have been downloaded from remote content
    When the user views available themes
    Then "Nord" should be listed as an option

  @nord @planned
  Scenario: Apply Nord theme
    When the user applies "Nord" theme
    Then the background primary color should be "#2e3440"
    And the text primary color should be "#eceff4"
    And the accent color should be "#88c0d0"

  @solarized @planned
  Scenario Outline: Solarized themes available
    Given themes have been downloaded from remote content
    When the user views available themes
    Then "Solarized <variant>" should be listed as an option

    Examples:
      | variant |
      | Dark    |
      | Light   |

  @solarized @dark @planned
  Scenario: Apply Solarized Dark theme
    When the user applies "Solarized Dark" theme
    Then the background primary color should be "#002b36"
    And the text primary color should be "#839496"
    And the accent color should be "#268bd2"

  @solarized @light @planned
  Scenario: Apply Solarized Light theme
    When the user applies "Solarized Light" theme
    Then the background primary color should be "#fdf6e3"
    And the text primary color should be "#657b83"
    And the accent color should be "#268bd2"

  @gruvbox @planned
  Scenario Outline: Gruvbox themes available
    Given themes have been downloaded from remote content
    When the user views available themes
    Then "Gruvbox <variant>" should be listed as an option

    Examples:
      | variant |
      | Dark    |
      | Light   |

  @gruvbox @dark @planned
  Scenario: Apply Gruvbox Dark theme
    When the user applies "Gruvbox Dark" theme
    Then the background primary color should be "#282828"
    And the text primary color should be "#ebdbb2"
    And the accent color should be "#83a598"

  # ===========================================
  # System Integration
  # ===========================================

  @system @planned
  Scenario: Follow system dark/light mode
    Given the user has selected "System" theme preference
    When the system switches to light mode
    Then the app should apply the light variant of the selected theme

  @system @planned
  Scenario: Override system preference
    Given the system is in light mode
    And the user has explicitly selected "Catppuccin Mocha" (dark)
    Then the app should use dark theme regardless of system setting

  @system @auto @planned
  Scenario: Auto theme with Catppuccin
    Given the user has selected "Catppuccin (Auto)" theme
    When the system is in dark mode
    Then the app should apply "Catppuccin Mocha"
    When the system switches to light mode
    Then the app should apply "Catppuccin Latte"

  # ===========================================
  # Accessibility
  # ===========================================

  @accessibility @contrast @planned
  Scenario: High contrast mode overrides theme
    Given the user has enabled high contrast mode
    When any theme is applied
    Then contrast ratios should meet WCAG AAA standards
    And focus indicators should be more prominent

  @accessibility @contrast @planned
  Scenario: Theme colors meet minimum contrast
    When any theme is applied
    Then text on background should have at least 4.5:1 contrast ratio
    And large text should have at least 3:1 contrast ratio

  @accessibility @planned
  Scenario: Theme respects reduced motion setting
    Given the user has enabled reduced motion
    When a theme is applied
    Then theme transitions should be instant
    And no animations should play during theme change

  # ===========================================
  # Cross-Platform Consistency
  # ===========================================

  @platform @ios @planned
  Scenario: Theme applies on iOS
    Given the user is on iOS
    When the user applies "Catppuccin Mocha" theme
    Then navigation bar should use theme colors
    And status bar should adapt to theme brightness
    And system UI elements should harmonize with theme

  @platform @android @planned
  Scenario: Theme applies on Android
    Given the user is on Android
    When the user applies "Catppuccin Mocha" theme
    Then status bar color should match theme
    And navigation bar should use theme colors
    And Material components should use theme colors

  @platform @desktop @planned
  Scenario: Theme applies on Desktop
    Given the user is on Desktop
    When the user applies "Catppuccin Mocha" theme
    Then CSS custom properties should be updated
    And window frame should adapt to theme if supported

  # ===========================================
  # Theme Schema
  # ===========================================

  @schema @planned
  Scenario: Theme file contains required colors
    Given a valid theme file
    Then the theme should define "bg-primary" color
    And the theme should define "bg-secondary" color
    And the theme should define "bg-tertiary" color
    And the theme should define "text-primary" color
    And the theme should define "text-secondary" color
    And the theme should define "accent" color
    And the theme should define "accent-dark" color
    And the theme should define "success" color
    And the theme should define "error" color
    And the theme should define "warning" color
    And the theme should define "border" color

  @schema @planned
  Scenario: Theme file specifies light/dark mode
    Given a valid theme file
    Then the theme should specify whether it is "light" or "dark"

  @schema @planned
  Scenario: Invalid theme file rejected
    Given a theme file missing required "accent" color
    When the app attempts to load the theme
    Then a validation error should be reported
    And the current theme should remain unchanged

  # ===========================================
  # Remote Theme Updates
  # ===========================================

  @remote @planned
  Scenario: New theme available after content update
    Given the user has not previously seen "Tokyo Night" theme
    And the remote themes include "Tokyo Night"
    When the app applies content updates
    Then "Tokyo Night" should appear in theme selection

  @remote @planned
  Scenario: Theme update with existing selection
    Given the user has selected "Catppuccin Mocha"
    And a new version of Catppuccin themes is available
    When the app applies content updates
    Then the updated theme colors should be applied
    And the user's theme selection should be preserved

  @remote @fallback @planned
  Scenario: Bundled themes always available
    Given the content cache is empty
    And the device is offline
    When the user views available themes
    Then "Default Dark" should be available
    And "Default Light" should be available

  # ===========================================
  # Accent Color Customization
  # ===========================================

  @accent @future @planned
  Scenario: Choose accent color within theme
    Given the user has selected "Catppuccin Mocha" theme
    When the user opens accent color options
    Then the user should see Catppuccin accent colors:
      | rosewater | flamingo | pink   | mauve    |
      | red       | maroon   | peach  | yellow   |
      | green     | teal     | sky    | sapphire |
      | blue      | lavender |        |          |

  @accent @future @planned
  Scenario: Custom accent color persists
    Given the user has selected "Catppuccin Mocha" with "mauve" accent
    When the user closes and reopens the app
    Then the "mauve" accent color should still be applied

  # ===========================================
  # QR Code Theming
  # ===========================================

  @qr @planned
  Scenario: QR code remains readable in any theme
    When any theme is applied
    Then QR codes should display with high contrast
    And QR code background should be white or near-white
    And QR code foreground should be black or near-black

  @qr @planned
  Scenario: QR code container matches theme
    When the user views their QR code
    Then the QR code container should use theme background
    And the QR code itself should remain standard black-on-white

  # Platform Edge Cases (dissolved from platform_edge_cases.feature 2026-03-17)

  @platform-edge-case @desktop @theme @planned
  Scenario: Respect system theme on desktop
    Given the system is set to dark mode
    When I open the app
    Then the app should use dark theme
    And changing system theme should update app theme
    And there should be an override option
