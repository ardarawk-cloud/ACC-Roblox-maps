# BBYA Music Bridge MVP

Status: **ISOLATED / NOT WIRED / NOT LIVE**

This folder proves the data path for a future BBYA Music APK/controller:

`APK/controller -> BBYA Music backend -> Roblox HttpService -> Sound + Now Playing UI`

The APK/controller is the write/admin surface. Roblox only reads a sanitized public state endpoint.

## Why this is isolated

The MVP is intentionally not mounted into the active BBYA Social Hub project yet. It must not alter Mall, Fishing, Main Club, economy, global lighting, or any current live system while the bridge is being validated.

## Roblox integration targets

When we are ready to wire the MVP into the project, map/copy the files as follows:

- `shared/BBYAMusicConfig.lua` -> `ReplicatedStorage/BBYAMusicConfig`
- `server/BBYAMusicBridge.server.lua` -> `ServerScriptService/BBYAMusicBridge`
- `client/BBYAMusicUI.client.lua` -> `StarterPlayer/StarterPlayerScripts/BBYAMusicUI`

Then replace the placeholder `Endpoint` in `BBYAMusicConfig` with the HTTPS backend URL.

Roblox HTTP requests must be enabled in Experience Settings > Security before `HttpService:RequestAsync()` can reach the backend.

## Read endpoint

`GET /api/bbya/music/state`

Example response:

```json
{
  "revision": 12,
  "isPlaying": true,
  "currentTrack": {
    "id": "funkot-001",
    "title": "BBYA Funkot 01",
    "artist": "ACC Music",
    "robloxAssetId": "123456789",
    "coverImage": "rbxassetid://987654321"
  }
}
```

`currentTrack` may be `null` to put the player into an idle state.

## Audio rule

The controller/backend selects the track, but the actual sound played in Roblox is still a Roblox audio asset referenced by `robloxAssetId`. The audio asset must be usable by the target experience/account permissions.

The APK must not attempt to stream arbitrary local MP3 bytes directly into this Roblox `Sound` path.

## Security rule

Do **not** put an APK/admin bearer token, API secret, or backend write credential in Roblox code.

Recommended split:

- Public/read-only state endpoint for Roblox.
- Authenticated write endpoint for APK/controller.
- Backend validates allowed track IDs and Roblox asset IDs before publishing state.

## MVP behavior

The server:

1. Polls the backend every 10 seconds by default.
2. Validates and sanitizes the response.
3. Plays/pauses the selected Roblox Sound.
4. Replicates only the sanitized now-playing state through `BBYAMusicState`.

The client:

- Renders a compact centered `NOW PLAYING` panel.
- Shows title, artist, cover, and PLAYING/PAUSED/IDLE state.
- Has no player-side DJ controls in v1.

## Safe test sequence

1. Stand up a dedicated BBYA Music backend with the read endpoint above.
2. Put one known-good Roblox audio asset ID in the backend state.
3. Enable HTTP Requests in a Studio test copy.
4. Wire the three MVP scripts into their integration targets.
5. Test `PLAYING -> PAUSED -> PLAYING` and a track change.
6. Verify UI updates and audio behavior in Studio.
7. Only after QC, integrate through the normal BBYA branch/PR/deploy workflow.
8. Do not call the feature LIVE until the exact source is proven by the deployment receipt.

## Next phase

After this bridge passes Studio validation:

- Build the dedicated backend write endpoint.
- Build the Android playlist/controller UI.
- Add queue/reorder/next/previous.
- Add zone routing (Main Club, Mall, Fishing, events) only with explicit scope approval.
- Add DJ Mode after the basic state path is stable.
