-- BBYA SOCIAL HUB — FUNKOT UPLOADER REGISTRY SHIM v7
-- Intentionally no Funkot or Mall playback here.
-- Funkot runtime authority: 93-funkot-music.server.lua.
-- Mall runtime authority: 149-mall-music.server.lua.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
ReplicatedStorage:SetAttribute("BBYAFunkotUploaderRegistryShim",true)
ReplicatedStorage:SetAttribute("BBYAFunkotRegistryTrackCount",3)
ReplicatedStorage:SetAttribute("BBYALegacyMallAuthorityRetired",true)
print("[BBYA] Funkot uploader registry shim v7; legacy Mall playback retired")