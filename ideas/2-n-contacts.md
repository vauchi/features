# Web of Trust: N-of-M Contact Introduction

## The Question
Can vauchi extend in-person trust to a distance through mutual vouching?

## Proposed Feature: "3-of-N Introduction"
When 3 of your existing contacts independently propose the same unknown person to you, AND that person receives 3 proposals to connect with you - both parties receive a "vouched introduction" request.

## Why It Fits Vauchi
- **Extends real-life trust**: You haven't met, but trusted contacts vouch for both sides
- **Preserves privacy**: No central authority - trust flows through your network
- **Resistant to spam**: Requires 3 independent vouches from existing contacts
- **Different from in-person**: Clearly marked as "introduced" vs "met in person"

## Design Questions
1. Should the vouchers be revealed to both parties? (transparency vs privacy)
2. What's the minimum threshold? 3 feels right (resilient to 2 compromised contacts)
3. Can users configure their threshold (3, 4, 5)?
4. How do contacts "propose" someone? Explicit action or inferred from patterns?
5. Does this create a separate "trust tier" below in-person exchange?

## Privacy Considerations
- Vouchers learn nothing about whether introduction succeeded
- Introduced parties learn who vouched (or not - configurable?)
- No relay or server learns about the web of trust structure
