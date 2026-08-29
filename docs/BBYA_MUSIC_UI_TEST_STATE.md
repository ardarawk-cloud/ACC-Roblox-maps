# BBYA Music UI Test — Current State

Status: ACTIVE / ISOLATED DEVICE TEST
Date: 2026-08-29

## Hard boundary

This branch is used for **BBYA Music UI Test**, not production BBYA Social Hub.

- Test universe: `10762005984`
- Test place: `124607344716828`
- Production universe `8116636513` must not be targeted by the current APK ID test.
- This branch is heavily diverged from current `main`; do not merge it wholesale into production.

## Verified published test build

Source commit containing the APK mirror receiver:

`8765be9d484b09e044a6997b74f42e41de555346`

Dedicated preview/publish workflow run:

`33260307966`

Result: `SUCCESS`

Published receipt:

- mapId: `bbya-music-test`
- universeId: `10762005984`
- placeId: `124607344716828`
- Roblox version: `14`
- status: `PUBLISHED`

## Underground APK mirror receiver

Runtime file:

`maps/bbya-social-hub/85-basement-autodj.server.lua`

Transport:

`Android APK -> Roblox OAuth/Open Cloud -> universe publishMessage -> BBYA_MUSIC_UNDERGROUND_V1 -> MessagingService SubscribeAsync -> Underground mirror catalog`

Mirror persistence:

- DataStore: `BBYAMusicCatalogV1`
- key: `zone:underground`

The mirror receiver accepts `upsert`, `delete`, `clear`, and `fallback` deltas, validates Asset IDs/track IDs/revisions, persists mirror state, and feeds the existing Underground Deck A/B playback authority and player music state.

## Android counterpart

Canonical device-test APK: `BBYA Music Manager v0.3.16-ID-Test-UIMap`

Expected OAuth scopes:

`openid universe-messaging-service:publish`

The Android test build contains exactly 25 pre-existing Roblox Asset IDs in its isolated Underground catalog. It does not require audio upload scopes for this test.

## Remaining gate

No further promotion is allowed until the device test confirms:

1. OAuth consent succeeds without a scope error.
2. `SYNC UNDERGROUND` publishes the catalog to this test universe.
3. The test-map receiver gets the deltas.
4. Underground UI exposes the received tracks.
5. At least one authorized Asset ID loads and plays.

Main BBYA Social Hub remains outside this test.