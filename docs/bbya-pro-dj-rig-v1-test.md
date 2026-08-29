# BBYA Pro DJ Rig v1 — Isolated Visual Test

Status: TEST ONLY / DO NOT PUBLISH TO BBYA LIVE

## Source baseline

- BBYA stability baseline: Roblox v534
- Exact source baseline: `26a73635438bd4ed07cd9e6f79da48a5a9a2384d`
- Working branch: `feat/bbya-pro-dj-rig-v1-test`

## Approved publish target

This branch may be published only to the dedicated BBYA Music UI test place:

- Universe ID: `10762005984`
- Place ID: `124607344716828`

Forbidden target for this prototype:

- BBYA Social Hub LIVE Universe: `8116636513`
- BBYA Social Hub LIVE Place: `131894120482837`

Do not merge or publish this prototype to the live BBYA place as part of visual testing.

## Prototype scope

`maps/bbya-social-hub/41-mesh-assets.server.lua` replaces only the primitive Main Club DJ hardware after the Main Club realism pass has completed. It builds a visual-only professional layout:

- two professional media-player/deck units;
- large layered jog wheels;
- raised information displays;
- pitch/tempo faders;
- performance pad banks;
- transport and loop controls;
- one central four-channel mixer;
- per-channel gain/EQ/filter controls;
- four channel faders;
- dual VU meter ladders;
- crossfader and FX bank;
- headphones and BBYA generic hardware branding.

## Stability firewall

The prototype must not:

- write `SoundGroup.Volume`;
- call or recreate `forceNeutralVolumes()`;
- alter venue audio routing;
- add or remove playlist authorities;
- write global Lighting properties;
- touch Mall work.

The live v534 audio v8 / lighting v4 baseline remains authoritative and untouched.

## Acceptance gate

Publish to the Music UI test place only after source QC/build succeeds. Visual approval is based on whether the rig reads immediately as real professional DJ hardware rather than a flat Roblox box with random buttons. If it fails that visual bar, rollback/discard the prototype instead of promoting it.
