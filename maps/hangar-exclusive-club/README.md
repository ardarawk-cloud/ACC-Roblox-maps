# Hangar Exclusive Club

Target Roblox:
- Universe ID: `10745364913`
- Place ID: `76001567401911`

## Foundation v1

This map is a full-scale procedural foundation for the Hangar Exclusive Club blueprint. The runtime creates the requested hierarchy for Map/Architecture, Vehicles, Furniture, LightingSystem, AudioSystem and ReplicatedStorage/ClubEvents. StarterPlayer builds `MusicPlayerGui`, `DJPanelGui` and `InteractionGui` for each player.

Included:
- full-scale hangar shell and apron
- replaceable jet/helicopter proxy models (no fabricated MeshIds)
- stage, DJ booth, bar, sofas and fencing
- eight stage lights + six neon laser proxies
- two-track auto playlist using blueprint audio IDs
- secured server-authoritative DJ commands
- song request route to connected DJs
- Spotify-style compact now-playing UI
- donation/shoutout receipt backend with DataStore UpdateAsync de-duplication
- Roblox text filtering before shoutout storage
- donation popup, cash sound and local fireworks

## Required before monetization is live

Set real `DonationProduct.Id`, `DonationProduct.Robux`, `ShoutoutProduct.Id`, and `ShoutoutProduct.Robux` in `club.server.lua`. They intentionally default to zero so no fake product IDs are published.

## DJ access

User-owned experiences automatically allow `game.CreatorId`. Add explicit staff UserIds to `StaffUserIds`, or configure `StaffGroupId` and `MinimumStaffRank` for group-owned experiences.

## Mesh replacement contract

The proxy objects are deliberately named with the blueprint names (`Mesh_HangarFloor`, `Mesh_PrivateJet`, `Mesh_Helicopter`, `Mesh_BarCounter`, `Mesh_LeatherSofa_*`, `Mesh_MetalFencing_*`). Replace their geometry with owned/imported MeshParts later while keeping system folders and names stable.
