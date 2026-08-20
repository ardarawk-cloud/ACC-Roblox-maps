# Mountain Social Adventure — Final Readiness

Status: SOURCE COMPLETE / PUBLISH DISABLED

## Master-plan hard lock
- Original fictional ACC mountain.
- Hiking + exploration + social hangout + cinematic ambience + secrets.
- Not a generic obby.
- Mobile-first and low-maintenance.
- Modular systems reusable for future ACC mountain assets.

## World
- Basecamp and lower forest.
- 12 named checkpoint journey.
- Camps and campfire interactions.
- Ridge / mist / cloud-sea progression.
- Waterfall landmark.
- Main summit payoff.
- Hidden route and secret summit/reward hooks.
- Photo spots.

## Systems
- Persistent checkpoint save/restore.
- Day/night cycle.
- CLEAR / FOG / RAIN weather states.
- Rain/fog client visuals.
- Summit counter, leaderboard and title progression.
- Server-authoritative carry/drop foundation.
- Mobile carry/drop/photo HUD.
- Photo mode.
- Campfire warm-up interaction.
- Secret discovery state/reward hook.
- Adaptive mobile FX performance guard.
- Fail-closed QC gate.

## Target lock
- Universe ID: 10744139279
- Place ID: 82661754996018
- Registry must remain `enabled: false` until closed-test publish is explicitly authorized.

## Publish gate
Before enabling the registry target:
1. Build/generate the Roblox place with all Mountain scripts installed in their intended services.
2. Run in Roblox and confirm `workspace.ACC_MountainReady == true`.
3. Confirm DataStore API access in the target experience.
4. Test checkpoint restore, summit progression, carry/drop, weather, campfire, photo mode and secret route on mobile.
5. Verify no cross-map objects or target IDs are referenced.
6. Only then enable closed-test publishing for the Mountain target.

No production/public release is authorized by this file.
