-- BBYA SOCIAL HUB — FUNKOT LEGACY MUSIC ENGINE SHIM v3
-- Playback ownership moved to 121-funkot-playlist.server.lua.
-- Keep this mapped script as a compatibility marker only so two Funkot engines never race.
local SoundService=game:GetService("SoundService")

local group=SoundService:FindFirstChild("BBYAFunkotMaster")
if group and group:IsA("SoundGroup") then
 group:SetAttribute("LegacyFunkotEngineSuppressed",true)
 group:SetAttribute("LegacyFunkotEngineVersion","V2_SUPPRESSED_BY_V3")
end

-- Clean up only the legacy deck/feed names if an older live instance created them.
for _,name in ipairs({"BBYAFunkotClubFeed","BBYAFunkotDeck"}) do
 local old=SoundService:FindFirstChild(name)
 if old and old:IsA("Sound") then
  pcall(function()old:Stop()end)
  old:Destroy()
 end
end

print("[BBYA] Funkot legacy music v2 suppressed; playlist authority v3 owns playback")
