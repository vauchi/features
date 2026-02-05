<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# Feature Scenarios

Gherkin scenarios defining Vauchi behavior. Each scenario should have corresponding tests.

## Status Overview

| Feature | Scenarios | Implemented | Priority | Notes |
|---------|-----------|-------------|----------|-------|
| identity_management | 15 | 15 | P0 | Core |
| contact_card_management | 34 | 34 | P0 | Core |
| contact_exchange | 50 | 18 | P0 | QR done, NFC Active done, BLE stubbed |
| contacts_management | 40 | 40 | P0 | Core |
| device_management | 40 | 30 | P0 | Core |
| sync_updates | 38 | 34 | P0 | WebSocket relay |
| onboarding | 31 | 0 | P0 | First-run experience |
| demo_contact | 17 | 0 | P0 | Demo contact flow |
| security | 34 | 34 | P1 | Crypto, signatures |
| visibility_control | 26 | 26 | P1 | Per-contact rules |
| field_validation | 42 | 0 | P1 | Crowd-sourced trust validation, OAuth |
| privacy_compliance | 46 | 0 | P1 | GDPR, data export/deletion |
| visibility_labels | 41 | 26 | P2 | Core implemented (labels.rs, storage, API) |
| relay_network | 43 | 20 | P2 | Basic relay done |
| message_delivery | 34 | 0 | P2 | Delivery receipts, retry |
| contact_actions | 47 | 0 | P2 | Contact interactions |
| contact_recovery | 59 | 0 | P2 | Recovery flows |
| remote_content | 45 | 0 | P2 | Remote content updates |
| tor_mode | 29 | 0 | P2 | Tor routing, bridges, .onion support |
| performance | 35 | 0 | P3 | Performance benchmarks |
| accessibility | 38 | 0 | P3 | A11y compliance |
| internationalization | 36 | 0 | P3 | i18n/l10n |
| theming | 39 | 0 | P3 | Visual theming |
| platform_edge_cases | 34 | 0 | P3 | Platform-specific edge cases |
| aha_moments | 15 | 0 | P3 | User delight moments |

**Total**: 908 scenarios | **Implemented**: ~277 (~31%)

## Priority Definitions

- **P0 (Core)**: Required for MVP. Must work before any release.
- **P1 (Security)**: Security-critical features. Required for public launch.
- **P2 (Infrastructure)**: Relay, federation, labels. Enhances reliability.
- **P3 (Post-launch)**: Advanced privacy features. Opt-in, can ship later.

## Feature Descriptions

### P0: Core Features

**identity_management.feature**
- Identity creation, backup, recovery
- Master seed and key derivation
- Code: `vauchi-core/src/identity/`

**contact_card_management.feature**
- Create/edit own contact card
- Field types: phone, email, social, address, website, custom
- Social network registry (35+ networks)
- Code: `vauchi-core/src/contact_card/`

**contact_exchange.feature**
- QR code generation and scanning (implemented)
- X3DH key exchange (implemented)
- BLE proximity exchange (stubbed)
- NFC Active exchange (implemented — 174-byte APDU, VNFC magic)
- Code: `vauchi-core/src/exchange/`

**contacts_management.feature**
- Contact list CRUD operations
- Search, filter, favorites
- Blocking and notes
- Code: `vauchi-core/src/contact/`

**device_management.feature**
- Multi-device linking via QR
- Device registry with signatures
- Device revocation
- Code: `vauchi-core/src/identity/device.rs`, `vauchi-core/src/exchange/device_link.rs`

**sync_updates.feature**
- Card update propagation
- Double Ratchet forward secrecy
- Offline queuing and retry
- Code: `vauchi-core/src/sync/`, `vauchi-core/src/network/`

**onboarding.feature**
- First-run experience and setup flow

**demo_contact.feature**
- Demo contact for new users to explore features

### P1: Security Features

**security.feature**
- E2E encryption (XChaCha20-Poly1305)
- Signature verification (Ed25519)
- MITM detection, replay prevention
- Code: `vauchi-core/src/crypto/`

**visibility_control.feature**
- Per-contact field visibility
- View-as-contact preview
- Code: `vauchi-core/src/contact/visibility.rs`

**field_validation.feature**
- Input validation rules for contact fields

**privacy_compliance.feature**
- GDPR compliance, data export, data deletion

### P2: Infrastructure

**visibility_labels.feature**
- Group contacts by label (Family, Work, etc.)
- Bulk visibility rules
- Code: `vauchi-core/src/contact/labels.rs`, `vauchi-core/src/storage/labels.rs`

**relay_network.feature**
- Store-and-forward relay
- Rate limiting, blob expiration
- Federation (planned)
- Code: `vauchi-relay/`

**message_delivery.feature**
- Delivery receipts, retry logic

**contact_actions.feature**
- Contact interactions (share, export, etc.)

**contact_recovery.feature**
- Contact recovery flows

**remote_content.feature**
- Remote content updates

**tor_mode.feature**
- Tor routing for relay connections
- Bridge support for censored networks
- .onion address support

### P3: Advanced Features (Post-Launch)

**performance.feature**
- Performance benchmarks and targets

**accessibility.feature**
- Accessibility compliance

**internationalization.feature**
- Internationalization and localization

**theming.feature**
- Visual theming support

**platform_edge_cases.feature**
- Platform-specific edge cases

**aha_moments.feature**
- User delight moments

## Running Scenario Tests

```bash
# Run all tests (includes scenario coverage)
cargo test

# Run tests for specific feature area
cargo test identity
cargo test exchange
cargo test sync
```

## Adding New Scenarios

1. Write scenario in appropriate `.feature` file
2. Write failing test referencing the scenario
3. Implement minimal code to pass
4. Refactor while green

See `docs/2026-01-22-TDD_RULES.md` for methodology.
