-- BBYA SOCIAL HUB - VIP TRACK 01 AUTHORITY v2
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TRACK={title="Wonder Girls - Nobody (ROOKIE Amapiano Edit)",assetId="105859685125263"}

ReplicatedStorage:SetAttribute("BBYAVIPTrack01Enabled",true)
ReplicatedStorage:SetAttribute("BBYAVIPTrack01Title",TRACK.title)
ReplicatedStorage:SetAttribute("BBYAVIPTrack01AssetId",TRACK.assetId)

task.delay(9.25,function()
 local group=SoundService:FindFirstChild("BBYAVIPMaster")
 if not group or not group:IsA("SoundGroup") then
  group=Instance.new("SoundGroup")
  group.Name="BBYAVIPMaster"
  group.Parent=SoundService
 end
 group.Volume=.62
 group:SetAttribute("Venue","VIP")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",1)
 group:SetAttribute("MusicCatalogState","VIP_TRACK01_ACTIVE")
 local oldSound=SoundService:FindFirstChild("BBYAVIPTrack01")
 if oldSound then oldSound:Destroy() end
 local s=Instance.new("Sound")
 s.Name="BBYAVIPTrack01"
 s.SoundId="rbxassetid://"..TRACK.assetId
 s.Volume=.72
 s.Looped=true
 s.SoundGroup=group
 s:SetAttribute("Title",TRACK.title)
 s:SetAttribute("Venue","VIP")
 s:SetAttribute("PlaylistIndex",1)
 s.Parent=SoundService
 s:Play()
 print("[BBYA] VIP Track 01 active:",TRACK.title,TRACK.assetId)
end)
