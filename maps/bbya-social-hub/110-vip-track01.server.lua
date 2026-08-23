-- BBYA SOCIAL HUB - VIP TRACK 01 HARD AUTHORITY v3
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TRACK={title="Wonder Girls - Nobody (ROOKIE Amapiano Edit)",assetId="105859685125263"}

local function enforce()
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01Enabled",true)
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01Title",TRACK.title)
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01AssetId",TRACK.assetId)
 local group=SoundService:FindFirstChild("BBYAVIPMaster")
 if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
 if not group then group=Instance.new("SoundGroup");group.Name="BBYAVIPMaster";group.Parent=SoundService end
 group.Volume=.62
 group:SetAttribute("Venue","VIP")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",1)
 group:SetAttribute("RecoveryActive",false)
 group:SetAttribute("RecoveryFallbackCount",0)
 group:SetAttribute("MusicCatalogState","VIP_TRACK01_ACTIVE")
 local snd=SoundService:FindFirstChild("BBYAVIPTrack01")
 if snd and not snd:IsA("Sound") then snd:Destroy();snd=nil end
 if not snd then snd=Instance.new("Sound");snd.Name="BBYAVIPTrack01";snd.Looped=true;snd.Parent=SoundService end
 snd.SoundId="rbxassetid://"..TRACK.assetId
 snd.Volume=.72;snd.Looped=true;snd.SoundGroup=group
 snd:SetAttribute("Title",TRACK.title);snd:SetAttribute("Venue","VIP");snd:SetAttribute("PlaylistIndex",1)
 if not snd.IsPlaying then pcall(function() snd:Play() end) end
end
enforce()
task.spawn(function() while task.wait(1) do enforce() end end)
print("[BBYA] VIP Track 01 HARD AUTHORITY v3:",TRACK.title,TRACK.assetId)
