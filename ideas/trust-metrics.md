<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# Trust Metrics & Indicators

## The Question
How do we surface trust-relevant information about contacts without compromising privacy?

## Use Cases

### 1. "Did I meet this person?"
- Show indicator for contacts exchanged via in-person QR vs other methods
- Icon: 👤 (in-person) vs 🔗 (introduced/vouched)
- Why: Helps user remember context, reinforces in-person value

### 2. "This contact recovered their identity"
- After identity recovery (lost phone, key rotation), flag the contact
- Prompt: "Consider re-exchanging in person to verify"
- Why: Recovery is a trust-reduction event; re-exchange restores full trust

### 3. Contact Freshness
- How recently has this contact's card been updated?
- Subtle indicator: "Last updated 3 months ago"
- Why: Stale cards might indicate abandoned accounts

### 4. Mutual Contacts (If 2-n-contacts implemented)
- "3 of your contacts also know this person"
- Why: Social proof, helps remember who someone is

## Privacy Constraints
- All metrics computed locally from data you already have
- No queries to relay/server about contact relationships
- No leaking your contact list structure to anyone

## UI Considerations
- Should be subtle, not overwhelming
- Maybe hidden in contact detail view, not list view
- User can disable trust indicators entirely (preference)

## Open Questions
- Do we show trust tier explicitly? ("Met in person" vs "Introduced by X, Y, Z")
- Is "last updated" a privacy leak? (Reveals activity patterns)
- Should recovered-identity contacts be auto-demoted or just flagged?
