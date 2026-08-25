# BBYA MUSIC RIGHTS + ROYALTY MASTERPLAN v1

Status: LOCKED GOVERNANCE / NON-RUNTIME

## Scope
Applies to BBYA Social Hub music operations and is designed to extend to future AM STUDIO Creative Lab Roblox experiences.

Primary BBYA venues:
- Main Club
- Underground
- Funkot Diskotik

## Rights model
Two independent gates are always recorded:

1. Real-world rights / community clearance
   - Source of truth: owner-confirmed clearance with the relevant DJ/community in the real world.
   - Registry status: `OWNER_CONFIRMED`, `PENDING`, or `DENIED`.

2. Roblox platform eligibility
   - Moderation/platform status is tracked separately.
   - Restricted audio must have permission for the Universe where it will be used.
   - Roblox rejection means the rejected asset does not go live and follows the permanent-blacklist rule.

A Roblox approval is not stored as proof of real-world rights; the two records remain separate so future audits and payouts stay clear.

## Runtime eligibility
A track may go live only when all required gates are satisfied:
- real-world rights = OWNER_CONFIRMED;
- Roblox asset = APPROVED;
- permission to the target Universe = GRANTED.

## Current monetization state
Paid requests are NOT enabled yet.

Current behavior remains:
- AutoDJ = free;
- normal request system remains as currently implemented;
- no Developer Product is created by this governance change.

Future target:
- paid request = 1–2 Robux per request;
- separate Developer Product mapping per Universe when required;
- every paid request recorded to the canonical request ledger.

## Future royalty / DJ community revenue share
The ledger is designed to record:
- venue;
- track/canonical track ID;
- Roblox asset ID;
- DJ/community beneficiary;
- request count;
- actual Robux paid;
- monthly period;
- receipt ID;
- settlement status;
- future fiat payout amount.

Gross request Robux and real-world payout must remain separate values. Payout calculation is defined only when monetization/DevEx operations are activated.

## Hard rules
- Never retry a Roblox moderation rejection.
- Never alter pitch, speed, or musical key to evade moderation.
- Never intentionally upload duplicate source audio.
- Never allow a track without the required Roblox Universe permission to go live.
- Never mix real-world rights status with Roblox moderation status.
- Future uploader/build systems must preserve the canonical rights metadata and beneficiary mapping.

## Source of Truth files
- `ops/music-rights/bbya-music-rights-policy.json`
- `ops/music-rights/bbya-music-rights-registry.json`
- `ops/music-rights/bbya-music-request-ledger.schema.json`

This masterplan changes governance/data structure only and must not change BBYA runtime audio, pricing, or live map behavior by itself.
