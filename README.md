# Feature Scenarios

Gherkin scenarios defining Vauchi behavior. Each scenario should have corresponding tests.

## Status Overview

| Feature | Scenarios | Implemented | Priority | Notes |
|---------|-----------|-------------|----------|-------|
| identity_management | 15 | 15 | P0 | Core |
| contact_card_management | 34 | 34 | P0 | Core |
| contact_exchange | 27 | 12 | P0 | QR done, BLE/NFC planned |
| contacts_management | 40 | 40 | P0 | Core |
| device_management | 30 | 30 | P0 | Core |
| sync_updates | 34 | 34 | P0 | WebSocket relay |
| security | 34 | 34 | P1 | Crypto, signatures |
| visibility_control | 26 | 26 | P1 | Per-contact rules |
| visibility_labels | 41 | 0 | P2 | Post-launch |
| relay_network | 43 | 20 | P2 | Basic relay done |
| social_profile_validation | 33 | 0 | P3 | Low priority |

**Total**: 357 scenarios | **Implemented**: ~245 (~69%)

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
- BLE proximity exchange (planned)
- NFC tap exchange (planned)
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

### P2: Infrastructure

**visibility_labels.feature**
- Group contacts by label (Family, Work, etc.)
- Bulk visibility rules
- Status: Designed, not implemented

**relay_network.feature**
- Store-and-forward relay
- Rate limiting, blob expiration
- Federation (planned)
- Code: `vauchi-relay/`

### P3: Advanced Privacy (Post-Launch)

**social_profile_validation.feature**
- Crowd-sourced profile validation
- OAuth verification (low priority)

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
