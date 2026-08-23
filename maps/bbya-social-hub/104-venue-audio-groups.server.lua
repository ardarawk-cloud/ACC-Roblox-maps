-- BBYA SOCIAL HUB — VENUE AUDIO MASTERS v2
-- Independent local-only SoundGroups for every music venue.
-- All playlists are currently reset/empty until the owner rebuilds them.

local SoundService=game:GetService("SoundService")

local function ensure(name,venue)
 local g=SoundService:FindFirstChild(name)
 if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=0
 g:SetAttribute("Venue",venue)
 g:SetAttribute("BBYALocalZoneOnly",true)
 g:SetAttribute("PlaylistReady",false)
 g:SetAttribute("PlaylistCount",0)
 g:SetAttribute("MusicCatalogState","RESET_EMPTY")
 return g
end

ensure("BBYASkateparkMaster","SKATEPARK")
ensure("BBYARooftopMaster","ROOFTOP")
ensure("BBYAVIPMaster","VIP")

print("[BBYA] Venue audio masters v2 ready: VIP + Skatepark + Rooftop isolated / playlists empty")
