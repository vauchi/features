<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# Feature Scenarios

> **Mirror:** This repo is a read-only mirror of
> [gitlab.com/vauchi/features](https://gitlab.com/vauchi/features).
> Please open issues and merge requests there.

[![Pipeline](https://img.shields.io/endpoint?url=https://vauchi.gitlab.io/features/badges/pipeline.json&label=pipeline)](https://gitlab.com/vauchi/features/-/pipelines)
[![REUSE](https://api.reuse.software/badge/gitlab.com/vauchi/features)](https://api.reuse.software/info/gitlab.com/vauchi/features)

Gherkin scenarios defining Vauchi behavior.
Each scenario should have corresponding tests.

## Lifecycle Tags

Every scenario is tagged with its implementation status:

- `@implemented` — has passing tests in the test suite
- `@planned` — specced but not yet implemented
- `@wip` — actively being implemented (temporary, feature branches only)

Use `grep -c '@implemented' *.feature` to get live implementation counts.
Ideas and brainstorming live in `_private/features/ideas/` (not in this repo).

## Status Overview

| Feature | Scenarios | Implemented | Priority | Notes |
| ------- | --------- | ----------- | -------- | ----- |
| identity_management | 15 | 12 | P0 | Core, backup, password done; QR linking gaps |
| contact_card_management | 34 | 34 | P0 | Core |
| contact_exchange | 50 | 30 | P0 | QR, Mutual QR, BLE, NFC Active, X3DH done |
| contacts_management | 40 | 19 | P0 | CRUD, search, blocking, merge; groups missing |
| device_management | 40 | 18 | P0 | Linking, registry, revocation; UI/settings gaps |
| sync_updates | 38 | 22 | P0 | Relay, conflict, security done; settings gaps |
| onboarding | 31 | 0 | P0 | First-run experience |
| demo_contact | 17 | 12 | P0 | Core flow, persistence, dismissal done |
| security | 34 | 19 | P1 | Crypto, signatures, replay; access/notifs platform-specific |
| visibility_control | 26 | 10 | P1 | Core rules done; groups, propagation, preview gaps |
| field_validation | 42 | 15 | P1 | Trust levels, validation status done |
| privacy_compliance | 46 | 25 | P1 | GDPR export/deletion, consent, crypto-shredding done |
| visibility_labels | 41 | 26 | P2 | Core implemented (labels.rs, storage, API) |
| relay_network | 43 | 20 | P2 | Basic relay done |
| message_delivery | 34 | 15 | P2 | Delivery records, device tracking done |
| contact_actions | 47 | 25 | P2 | URI builder done (phone, email, social, address) |
| contact_recovery | 59 | 30 | P2 | Trust config, vouching, proof, discovery done |
| remote_content | 45 | 8 | P2 | Manifest, version check, fallback done |
| tor_mode | 29 | 0 | P2 | Code exists, no test coverage |
| performance | 35 | 0 | P3 | Performance benchmarks |
| accessibility | 38 | 0 | P3 | A11y compliance |
| internationalization | 36 | 0 | P3 | i18n/l10n |
| theming | 39 | 0 | P3 | Visual theming |
| platform_edge_cases | 34 | 0 | P3 | Platform-specific edge cases |
| aha_moments | 15 | 0 | P3 | User delight moments |

**Total**: 908 scenarios | **Implemented**: ~340 (~37%)

## Priority Definitions

- **P0 (Core)**: Required for MVP. Must work before any release.
- **P1 (Security)**: Security-critical features. Required for public launch.
- **P2 (Infrastructure)**: Relay, federation, labels. Enhances reliability.
- **P3 (Post-launch)**: Advanced privacy features. Opt-in, can ship later.

## Feature Descriptions

### P0: Core Features

#### identity_management.feature

- Identity creation, backup, recovery
- Master seed and key derivation
- Code: `vauchi-core/src/identity/`

#### contact_card_management.feature

- Create/edit own contact card
- Field types: phone, email, social, address, website, custom
- Social network registry (35+ networks)
- Code: `vauchi-core/src/contact_card/`

#### contact_exchange.feature

- QR code generation and scanning (implemented)
- X3DH key exchange (implemented)
- BLE proximity exchange (stubbed)
- NFC Active exchange (implemented — 174-byte APDU, VNFC magic)
- Code: `vauchi-core/src/exchange/`

#### contacts_management.feature

- Contact list CRUD operations
- Search, filter, favorites
- Blocking and notes
- Code: `vauchi-core/src/contact/`

#### device_management.feature

- Multi-device linking via QR
- Device registry with signatures
- Device revocation
- Code: `vauchi-core/src/identity/device.rs`, `vauchi-core/src/exchange/device_link.rs`

#### sync_updates.feature

- Card update propagation
- Double Ratchet forward secrecy
- Offline queuing and retry
- Code: `vauchi-core/src/sync/`, `vauchi-core/src/network/`

#### onboarding.feature

- First-run experience and setup flow

#### demo_contact.feature

- Demo contact for new users to explore features
- Code: `vauchi-core/tests/demo_contact_integration_tests.rs`

### P1: Security Features

#### security.feature

- E2E encryption (XChaCha20-Poly1305)
- Signature verification (Ed25519)
- MITM detection, replay prevention
- Code: `vauchi-core/src/crypto/`

#### visibility_control.feature

- Per-contact field visibility
- View-as-contact preview
- Code: `vauchi-core/src/contact/visibility.rs`

#### field_validation.feature

- Input validation rules for contact fields
- Trust levels, validation status tracking
- Code: `vauchi-core/src/storage/validation.rs`

#### privacy_compliance.feature

- GDPR compliance, data export, data deletion
- Consent storage, crypto-shredding, revocation protocol
- Code: `vauchi-core/src/storage/consent.rs`, `vauchi-core/src/crypto/shredding.rs`

### P2: Infrastructure

#### visibility_labels.feature

- Group contacts by label (Family, Work, etc.)
- Bulk visibility rules
- Code: `vauchi-core/src/contact/labels.rs`, `vauchi-core/src/storage/labels.rs`

#### relay_network.feature

- Store-and-forward relay
- Rate limiting, blob expiration
- Federation (planned)
- Code: `vauchi-relay/`

#### message_delivery.feature

- Delivery receipts, retry logic
- Device delivery tracking, status transitions
- Code: `vauchi-core/src/storage/delivery.rs`, `vauchi-core/src/storage/device_delivery.rs`

#### contact_actions.feature

- Contact interactions (share, export, etc.)
- URI builder for phone, email, social, address, website
- Code: `vauchi-core/src/contact_card/uri_builder.rs`

#### contact_recovery.feature

- Contact recovery flows
- Trust configuration, vouching, proof collection, discovery
- Code: `vauchi-core/src/recovery/`

#### remote_content.feature

- Remote content updates
- Manifest fetching, version comparison, fallback behavior
- Code: `vauchi-core/src/content/`

**IP privacy** (via OHTTP relay — see relay_network.feature)

- Self-hosted OHTTP relay strips client IPs
- Optional SOCKS5 proxy for ISP-level hiding
- Timing obfuscation (jitter, padding)

### P3: Advanced Features (Post-Launch)

#### performance.feature

- Performance benchmarks and targets

#### accessibility.feature

- Accessibility compliance

#### internationalization.feature

- Internationalization and localization

#### theming.feature

- Visual theming support

#### platform_edge_cases.feature

- Platform-specific edge cases

#### aha_moments.feature

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

See [TDD Rules](https://docs.vauchi.app/developers/tdd-rules/) for methodology.
