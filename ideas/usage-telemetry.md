<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# Opt-In Usage Telemetry

## The Question
Can we add usage telemetry that respects vauchi's privacy-first principles?

## Proposed Design

### Core Principles
1. **Off by default** - Must be explicitly enabled in Settings
2. **No personal data** - Never includes card content, contact names, or identifiers
3. **Aggregated only** - Individual events are bucketed, not timestamped precisely
4. **Transparent** - Show exactly what would be sent before enabling
5. **Revocable** - Disable anytime, delete previously sent data on request

### What We'd Collect (If Opted In)
- App version, OS version, device type (generic: "Android phone", not model)
- Feature usage counts (not timing): "exchanged N cards this week"
- Error rates (not content): "sync failed N times"
- Onboarding completion: "reached step 3 of 5"

### What We'd NEVER Collect
- Contact names, phone numbers, emails, any card content
- Precise timestamps (only day-level at most)
- Device identifiers, IP addresses stored long-term
- Location data
- Anything that could identify the user or their contacts

### Implementation Approach
- Collect locally, batch, send weekly (if enabled)
- Show pending telemetry data in Settings before send
- User can view and delete before transmission
- Use differential privacy techniques for aggregation

### Settings UI
```
[Privacy & Data]

  Usage Statistics (Help improve vauchi)
  [ ] Share anonymous usage data

  [View what would be shared]
  [Delete my data from vauchi servers]
```

## Why Bother?
- Understand where users drop off in onboarding
- Identify which features are used/ignored
- Catch systematic errors before user reports
- Make data-informed decisions without compromising values

## Open Questions
- Is even opt-in telemetry a trust violation for our audience?
- Should we use a privacy-respecting analytics service (Plausible, Fathom) or self-host?
- Do we need a separate privacy policy section for telemetry?
