-- BBYA SOCIAL HUB — VENUE AUDIO MASTERS v3
-- Independent local-only SoundGroups for every music venue.
-- Rooftop is active; VIP/Skatepark remain reset until their own authorities enable them.

local SoundService=game:GetService("SoundService")

local function ensure(name,venue,active)
 local g=SoundService:FindFirstChild(name)
 if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=active and .68 or 0
 g:SetAttribute("Venue",venue)
 g:SetAttribute("BBYALocalZoneOnly",true)
 g:SetAttribute("PlaylistReady",active==true)
 if active then
  g:SetAttribute("MusicCatalogState","ROOFTOP_TROPICAL_ACTIVE")
 else
  g:SetAttribute("PlaylistCount",0)
  g:SetAttribute("MusicCatalogState","RESET_EMPTY")
 end
 return g
end

ensure("BBYASkateparkMaster","SKATEPARK",false)
ensure("BBYARooftopMaster","ROOFTOP",true)
ensure("BBYAVIPMaster","VIP",false)

print("[BBYA] Venue audio masters v3 ready: Rooftop active; VIP + Skatepark isolated")
