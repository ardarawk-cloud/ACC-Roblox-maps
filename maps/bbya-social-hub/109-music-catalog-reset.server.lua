-- BBYA SOCIAL HUB — OPENING STABILITY AUTHORITY v5
-- Replaces the obsolete destructive catalog-reset runtime.
-- Active venue audio authorities stay authoritative; this script never scrubs Sounds,
-- never disables AutoDJ engines, and never changes global Lighting.
-- Also adds a restrained local-only readability lift to the former Photo Studio / Salon lounge.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")

-- AUDIO STABILITY -------------------------------------------------------------
-- The old reset authority left this true and then destroyed late-created venue Sounds.
-- Opening runtime is now additive: each dedicated venue authority owns its own playlist/player.
ReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",false)
ReplicatedStorage:SetAttribute("BBYAMusicCatalogVersion","ACTIVE_VENUES_OPENING_STABILITY_V5")
ReplicatedStorage:SetAttribute("BBYAMainPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYAUndergroundPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYASkateparkPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYARooftopPlaylistEnabled",true)
Workspace:SetAttribute("BBYAMusicCatalogReset",false)
Workspace:SetAttribute("BBYAOpeningAudioStability","V5_ACTIVE_AUTHORITIES")

local ACTIVE_GROUPS={
 BBYAClubMaster="MAIN",
 BBYABasementMaster="UNDERGROUND",
 BBYAFunkotMaster="FUNKOT",
 BBYASkateparkMaster="SKATEPARK",
 BBYARooftopMaster="ROOFTOP",
}

local function markActiveGroups()
 for name,venue in pairs(ACTIVE_GROUPS) do
  local g=SoundService:FindFirstChild(name)
  if g and g:IsA("SoundGroup") then
   g:SetAttribute("Venue",venue)
   g:SetAttribute("BBYALocalZoneOnly",true)
   if g:GetAttribute("MusicCatalogState")=="RESET_EMPTY" then
    g:SetAttribute("MusicCatalogState","ACTIVE_AUTHORITY_RECOVERED_V5")
   end
  end
 end
end
markActiveGroups()

task.spawn(function()
 while task.wait(1) do
  -- Keep only the compatibility flag authoritative. Dedicated venue scripts own
  -- SoundId, playback, health checks, SoundGroup volume and playlist state.
  if ReplicatedStorage:GetAttribute("BBYAMusicCatalogReset")~=false then
   ReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",false)
  end
  markActiveGroups()
 end
end)

-- FORMER-STUDIO LOCAL READABILITY --------------------------------------------
-- Local fixtures only. WITA/global Brightness/Ambient/ClockTime remain untouched.
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",120)
 if not root then return end
 local lounge=root:WaitForChild("MainClubSocialLoungeV1",120)
 if not lounge then
  warn("[BBYA] Opening stability v5: MainClubSocialLoungeV1 unavailable; local lift skipped")
  return
 end

 local old=root:FindFirstChild("MainClubOpeningStabilityV1")
 if old then old:Destroy() end
 local out=Instance.new("Model")
 out.Name="MainClubOpeningStabilityV1"
 out:SetAttribute("Pass","FORMER_STUDIO_LOCAL_READABILITY_V1")
 out:SetAttribute("LocalLightingOnly",true)
 out:SetAttribute("GlobalLightingUntouched",true)
 out:SetAttribute("UndergroundUntouched",true)
 out:SetAttribute("WITAUntouched",true)
 out.Parent=root

 local warm=Color3.fromRGB(255,222,195)
 local neutral=Color3.fromRGB(235,226,218)
 local specs={
  {Vector3.new(-42.0,9.7,-31.0),warm,.72,14.5},
  {Vector3.new(-42.0,9.7,-21.0),warm,.76,15.0},
  {Vector3.new(-42.0,9.7,-11.0),warm,.72,14.5},
  {Vector3.new(-33.0,9.2,-31.0),neutral,.56,13.0},
  {Vector3.new(-33.0,9.2,-21.0),neutral,.60,13.5},
  {Vector3.new(-33.0,9.2,-11.0),neutral,.56,13.0},
  {Vector3.new(-28.5,7.3,-21.0),warm,.42,10.5},
 }
 for i,s in ipairs(specs) do
  local anchor=Instance.new("Part")
  anchor.Name="FormerStudioFill"..i
  anchor.Size=Vector3.new(.18,.18,.18)
  anchor.Position=s[1]
  anchor.Anchored=true
  anchor.CanCollide=false
  anchor.CanTouch=false
  anchor.CanQuery=false
  anchor.Transparency=1
  anchor.CastShadow=false
  anchor.Parent=out
  local light=Instance.new("PointLight")
  light.Name="FormerStudioLocalReadability"
  light.Color=s[2]
  light.Brightness=s[3]
  light.Range=s[4]
  light.Shadows=false
  light.Parent=anchor
 end

 print("[BBYA] Opening stability v5: destructive music reset removed; active venue authorities preserved; former-studio local readability lift online")
end)
