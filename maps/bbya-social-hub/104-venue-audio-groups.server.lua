-- BBYA SOCIAL HUB — VENUE AUDIO MASTERS v1
-- Prepares independent SoundGroups for future venue-specific playlists.
-- Existing MAIN / UNDERGROUND / FUNKOT engines keep owning their own groups.

local SoundService=game:GetService("SoundService")

local function ensure(name,venue)
 local g=SoundService:FindFirstChild(name)
 if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=0
 g:SetAttribute("Venue",venue)
 g:SetAttribute("BBYALocalZoneOnly",true)
 g:SetAttribute("PlaylistReady",false)
 return g
end

ensure("BBYASkateparkMaster","SKATEPARK")
ensure("BBYARooftopMaster","ROOFTOP")

print("[BBYA] Venue audio masters ready: Skatepark + Rooftop isolated channels")
