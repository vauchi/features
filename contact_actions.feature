# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@contact-actions
Feature: Open Contact Info in External Applications
  As a Vauchi user
  I want to tap on contact information to open it in the appropriate app
  So that I can quickly call, email, or navigate to my contacts

  Background:
    Given I have an existing identity as "Alice"
    And I am logged into Vauchi
    And I have a contact "Bob" in my contacts list

  # ============================================================
  # Phone Number Actions
  # ============================================================

  @phone @tel @implemented
  Scenario: Tap phone number opens dialer
    Given Bob has a phone field "Mobile" with value "+1-555-123-4567"
    When I view Bob's contact details
    And I tap on the phone number "+1-555-123-4567"
    Then the system dialer should open
    And the number "+1-555-123-4567" should be pre-filled

  @phone @tel @implemented
  Scenario: Phone number with international format
    Given Bob has a phone field "International" with value "+44 20 7946 0958"
    When I tap on the phone number
    Then the system dialer should open with "tel:+442079460958"

  @phone @tel @implemented
  Scenario Outline: Various phone number formats are normalized for dialer
    Given Bob has a phone field with value "<display_value>"
    When I tap on the phone number
    Then the dialer should receive URI "<expected_uri>"

    Examples:
      | display_value     | expected_uri          |
      | +1-555-123-4567   | tel:+1-555-123-4567   |
      | (555) 123-4567    | tel:(555)123-4567     |
      | 555.123.4567      | tel:555.123.4567      |
      | +44 20 7946 0958  | tel:+442079460958     |

  @phone @sms @implemented
  Scenario: Long press phone number shows action menu
    Given Bob has a phone field "Mobile" with value "+1-555-123-4567"
    When I long-press on the phone number
    Then I should see an action menu with options:
      | option           |
      | Call             |
      | Send SMS         |
      | Copy to Clipboard|

  @phone @sms @implemented
  Scenario: Send SMS to phone number
    Given Bob has a phone field "Mobile" with value "+1-555-123-4567"
    When I long-press on the phone number
    And I select "Send SMS"
    Then the system messaging app should open
    And the recipient should be "+1-555-123-4567"

  # ============================================================
  # Email Actions
  # ============================================================

  @email @mailto @implemented
  Scenario: Tap email opens mail client
    Given Bob has an email field "Work" with value "bob@company.com"
    When I view Bob's contact details
    And I tap on the email "bob@company.com"
    Then the default mail application should open
    And the "To" field should be "bob@company.com"

  @email @mailto @implemented
  Scenario: Email with special characters
    Given Bob has an email field with value "bob+work@company.com"
    When I tap on the email
    Then the mail client should open with properly encoded URI "mailto:bob+work@company.com"

  @email @mailto @implemented
  Scenario: Long press email shows action menu
    Given Bob has an email field "Work" with value "bob@company.com"
    When I long-press on the email
    Then I should see an action menu with options:
      | option           |
      | Compose Email    |
      | Copy to Clipboard|

  # ============================================================
  # Website Actions
  # ============================================================

  @website @https @implemented
  Scenario: Tap website opens browser
    Given Bob has a website field "Personal" with value "https://bobsmith.com"
    When I tap on the website
    Then the default web browser should open
    And it should navigate to "https://bobsmith.com"

  @website @https @implemented
  Scenario: Website without protocol prefix
    Given Bob has a website field with value "bobsmith.com"
    When I tap on the website
    Then the browser should open with "https://bobsmith.com"

  @website @http @implemented
  Scenario: HTTP website preserves protocol
    Given Bob has a website field with value "http://legacy-site.com"
    When I tap on the website
    Then the browser should open with "http://legacy-site.com"

  @website @implemented
  Scenario: Long press website shows action menu
    Given Bob has a website field with value "https://bobsmith.com"
    When I long-press on the website
    Then I should see an action menu with options:
      | option             |
      | Open in Browser    |
      | Copy URL           |
      | Share              |

  # ============================================================
  # Social Media Actions
  # ============================================================

  @social @profile-url @implemented
  Scenario Outline: Tap social media opens profile
    Given Bob has a social field "<network>" with value "<username>"
    And the social network registry provides profile URL template "<url_template>"
    When I tap on the social field
    Then the browser or app should open with "<expected_url>"

    Examples:
      | network   | username    | url_template                        | expected_url                         |
      | twitter   | @bobsmith   | https://twitter.com/{username}      | https://twitter.com/bobsmith         |
      | github    | bobsmith    | https://github.com/{username}       | https://github.com/bobsmith          |
      | linkedin  | in/bobsmith | https://linkedin.com/{username}     | https://linkedin.com/in/bobsmith     |
      | instagram | bob.smith   | https://instagram.com/{username}    | https://instagram.com/bob.smith      |
      | mastodon  | @bob@mas.to | https://{instance}/@{user}          | https://mas.to/@bob                  |

  @social @implemented
  Scenario: Long press social field shows action menu
    Given Bob has a social field "github" with value "bobsmith"
    When I long-press on the social field
    Then I should see an action menu with options:
      | option             |
      | Open Profile       |
      | Copy Username      |
      | Copy Profile URL   |
      | Share              |

  # ============================================================
  # Address Actions
  # ============================================================

  @address @maps @implemented
  Scenario: Tap address opens maps application
    Given Bob has an address field "Home" with value "123 Main St, San Francisco, CA 94102"
    When I tap on the address
    Then the default maps application should open
    And it should show the location "123 Main St, San Francisco, CA 94102"

  @address @maps @android @implemented
  Scenario: Address opens Google Maps on Android
    Given I am using the Android app
    And Bob has an address field with value "123 Main St, City, ST 12345"
    When I tap on the address
    Then the intent should use "geo:0,0?q=123+Main+St%2C+City%2C+ST+12345"
    And the address should also offer:
      | option                |
      | Open in Google Maps   |
      | Open in OpenStreetMap |
      | Open in Organic Maps  |

  @address @maps @ios @implemented
  Scenario: Address opens Apple Maps on iOS
    Given I am using the iOS app
    And Bob has an address field with value "123 Main St, City, ST 12345"
    When I tap on the address
    Then Apple Maps should open with the address query
    And the address should also offer:
      | option                |
      | Open in OpenStreetMap |
      | Open in Organic Maps  |

  @address @maps @desktop @implemented
  Scenario: Address opens web maps on desktop
    Given I am using the desktop app
    And Bob has an address field with value "123 Main St, City, ST 12345"
    When I tap on the address
    Then the browser should open with a maps URL
    And the address should be URL-encoded in the query

  @address @implemented
  Scenario: Long press address shows action menu
    Given Bob has an address field with value "123 Main St, City"
    When I long-press on the address
    Then I should see an action menu with options:
      | option             |
      | Open in Maps       |
      | Get Directions     |
      | Copy Address       |
      | Share              |

  @address @directions @implemented
  Scenario: Get directions to address
    Given Bob has an address field with value "123 Main St, City"
    When I long-press on the address
    And I select "Get Directions"
    Then the maps app should open in directions mode
    And the destination should be "123 Main St, City"

  # ============================================================
  # Custom Field Actions
  # ============================================================

  @custom @heuristic @implemented
  Scenario: Custom field with phone-like value offers call
    Given Bob has a custom field "Signal" with value "+1-555-987-6543"
    When I tap on the custom field
    Then the system should detect it as a phone number
    And the dialer should open with the number

  @custom @heuristic @implemented
  Scenario: Custom field with URL-like value offers browser
    Given Bob has a custom field "Portfolio" with value "https://portfolio.bob.com"
    When I tap on the custom field
    Then the browser should open with the URL

  @custom @no-action @implemented
  Scenario: Custom field with plain text shows copy option
    Given Bob has a custom field "Notes" with value "Met at conference"
    When I tap on the custom field
    Then only the copy to clipboard action should be available

  @custom @implemented
  Scenario: Long press custom field shows contextual menu
    Given Bob has a custom field "Signal" with value "+1-555-987-6543"
    When I long-press on the custom field
    Then I should see an action menu with options:
      | option            |
      | Call              |
      | Send SMS          |
      | Copy to Clipboard |

  # ============================================================
  # Error Handling
  # ============================================================

  @error @malformed @implemented
  Scenario: Malformed phone number shows error
    Given Bob has a phone field with value "not-a-valid-number"
    When I tap on the phone field
    Then I should see "Invalid phone number format"
    And the value should be copied to clipboard as fallback

  @platform @cli @implemented
  Scenario: CLI hands each field's link to the system handler
    Given I am using the CLI
    And I view Bob's contact details
    When I select to open a contact field
    Then the CLI should hand its tel, sms, mailto, web or map link to the system handler

  @security @implemented
  Scenario: URLs are validated before opening
    Given Bob has a website field with value "javascript:alert(1)"
    When I tap on the website
    Then the URL should be rejected as invalid
    And the browser should not open
    And I should see "Invalid URL"

  @security @implemented
  Scenario: Only safe URI schemes are allowed
    Given Bob has a custom field with value "file:///etc/passwd"
    When I tap on the field
    Then the file: scheme should be blocked
    And I should see "This action is not supported"

  @security @implemented
  Scenario: Allowed URI schemes whitelist
    Then the following URI schemes should be allowed:
      | scheme  | purpose              |
      | tel     | Phone calls          |
      | mailto  | Email composition    |
      | sms     | Text messages        |
      | https   | Secure websites      |
      | http    | Websites             |
      | geo     | Map coordinates      |
    And all other schemes should be blocked by default
