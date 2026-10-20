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
    When Alice starts a BLE exchange
    Then the step is "Discovering"
    And the engine emits BleStartAdvertising and then BleStartScanning
    And it does not emit them again on the next render

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
  Scenario: Magic mode verifies proximity with an audio response
    Given Alice is in Magic mode Exchanging step
    When an audio response is received
    Then the proximity is verified with confidence approximately 0.85
    And audio stops
    And the step advances to "Verifying", where the handshake completes the exchange

  @magic @implemented
  Scenario: Magic mode is not blocked by an audio timeout
    Given Alice is in Magic mode Exchanging step
    When audio proximity times out
    Then the proximity is not verified and its confidence is 0.0
    And card data arriving afterwards is still accepted

  # --- Bump Mode (BLE + Impact) ---

  @bump @implemented
  Scenario: Bump mode starts accelerometer on connection
    Given Alice is in Bump mode Handshaking step
    When BLE connection succeeds
    Then the engine emits an AccelerometerStart command
    And the step advances to "Exchanging"

  @bump @implemented
  Scenario: Bump mode verifies proximity with a strong impact
    Given Alice is in Bump mode Exchanging step
    When an impact of 10g is detected
    Then the proximity is verified
    And the confidence is capped at 0.6

  @bump @implemented
  Scenario: Bump mode leaves proximity unverified on a weak impact
    Given Alice is in Bump mode Exchanging step
    When an impact of 1g is detected
    Then the proximity is not verified
    And the step still advances to "Verifying", where the handshake completes the exchange

  # --- Shake Mode (BLE + Accelerometer Correlation) ---

  @shake @implemented
  Scenario: Shake mode records and exchanges envelopes
    Given Alice is in Shake mode Exchanging step
    And accelerometer samples have been recorded
    When the recording finishes
    Then the engine sends an encoded magnitude envelope via BLE
    And an AccelerometerStop command is emitted

  @shake @implemented
  Scenario: Shake mode verifies proximity by correlating the peer's envelope
    Given Alice is in Shake mode Exchanging step
    And recording is done and envelope sent
    When the peer's magnitude envelope arrives
    Then cross-correlation verifies the proximity
    And the confidence is at most 0.5
    And the step advances to "Verifying", where the handshake completes the exchange

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
  Scenario: BLE discovery that finds no one offers Retry and QR
    Given Alice is in Magic mode Discovering step on a device with a camera
    When the discovery budget passes without finding a peer
    Then the "nothing found" screen is shown
    And it offers Retry and "Switch to QR"

  @fallback @implemented
  Scenario: A stalled BLE exchange fails after its step budget
    Given Alice is in Magic mode Exchanging step
    When the step budget passes without progress
    Then the exchange fails
