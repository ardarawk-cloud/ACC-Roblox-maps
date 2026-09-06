-- BBYA SOCIAL HUB — VENUE-AWARE MUSIC UI BRIDGE RETIRED v1
-- Repeated QC showed this helper was mutating/assuming legacy Music UI geometry and hiding venue playlists.
-- All Music UI/data presentation now belongs to 103-music-ui-final.client.lua CLEAN REBUILD.
-- Audio playback authorities remain server-side and are intentionally untouched here.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
ReplicatedStorage:SetAttribute("BBYAVenueAwareMusicUIBridgeRetired",true)
print("[BBYA] Venue-aware Music UI bridge retired; 103 is the only Music presentation authority")