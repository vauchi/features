# SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

@ble @exchange @modes
Feature: BLE Exchange Modes (Magic, Bump, Shake)
  As a Vauchi user
  I want to exchange contact cards via BLE with different proximity verification
  So that I can choose the most natural exchange gesture for the situation

  Background:
    Given Alice has Vauchi installed with identity "Alice"
    And Bob has Vauchi installed with identity "Bob"
    And both devices support BLE

  # --- Magic Mode (BLE + Audio) ---

  @magic @implemented
  Scenario: Magic mode discovery emits BLE commands
    When Alice starts a Magic exchange
    Then the engine emits BleStartAdvertising and BleStartScanning commands
    And the step is "Discovering"

  @magic @implemented
  Scenario: Magic mode connects on device discovery
    Given Alice is in Magic mode Discovering step
    When a BLE device is discovered
    Then the engine emits a BleConnect command
    And the step advances to "Handshaking"

  @magic @implemented
  Scenario: Magic mode starts audio proximity on connection
    Given Alice is in Magic mode Handshaking step
    When BLE connection succeeds
    Then the engine emits AudioEmitChallenge and AudioListenForResponse commands
    And the step advances to "Exchanging"

  @magic @implemented
  Scenario: Magic mode completes with audio verification
    Given Alice is in Magic mode Exchanging step
    And card data has been received
    When an audio response is received
    Then the proximity confidence is approximately 0.85
    And the exchange completes successfully

  @magic @implemented
  Scenario: Magic mode completes even if audio times out
    Given Alice is in Magic mode Exchanging step
    And audio proximity has timed out
    When card data is received
    Then the exchange completes with degraded trust
    And the proximity confidence is 0.0

  # --- Bump Mode (BLE + Impact) ---

  @bump @implemented
  Scenario: Bump mode starts accelerometer on connection
    Given Alice is in Bump mode Handshaking step
    When BLE connection succeeds
    Then the engine emits an AccelerometerStart command
    And the step advances to "Exchanging"

  @bump @implemented
  Scenario: Bump mode completes with strong impact
    Given Alice is in Bump mode Exchanging step
    And card data has been received
    When an impact of 3g is detected
    Then the proximity is verified
    And the confidence is capped at 0.6

  @bump @implemented
  Scenario: Bump mode completes with weak impact (unverified)
    Given Alice is in Bump mode Exchanging step
    And card data has been received
    When an impact of 1g is detected
    Then the proximity is not verified
    And the exchange still completes

  # --- Shake Mode (BLE + Accelerometer Correlation) ---

  @shake @implemented
  Scenario: Shake mode records and exchanges envelopes
    Given Alice is in Shake mode Exchanging step
    And accelerometer samples have been recorded
    When the recording finishes
    Then the engine sends an encoded magnitude envelope via BLE
    And an AccelerometerStop command is emitted

  @shake @implemented
  Scenario: Shake mode completes with peer envelope correlation
    Given Alice is in Shake mode Exchanging step
    And recording is done and envelope sent
    And card data has been received
    When the peer's magnitude envelope arrives
    Then cross-correlation produces a proximity result
    And the confidence is capped at 0.5

  # --- Fallback Degradation ---

  @fallback @implemented
  Scenario: BLE failure offers relay fallback
    Given Alice is in a BLE exchange mode
    When BLE disconnects during exchange
    Then the failed screen shows a "Switch to encrypted relay" option
    And retry and cancel are also available

  @fallback @implemented
  Scenario: Accepting relay fallback switches to Link mode
    Given Alice's BLE exchange has failed with fallback available
    When Alice accepts the relay fallback
    Then the exchange switches to Link mode
    And relay escrow commands are emitted

  @fallback @implemented
  Scenario: BLE timeout during discovery triggers fallback
    Given Alice is in Magic mode Discovering step
    When the BLE discovery timer expires
    Then a fallback is offered
    And the step is "Failed"

  @fallback @implemented
  Scenario: BLE timeout after connection is ignored
    Given Alice is in Magic mode Exchanging step
    When the BLE timer fires
    Then the timeout is ignored
    And the exchange continues normally
