-- BBYA MUSIC UI TEST — PUBLIC AUDIO CONTROL PROBE v2
-- TEST BRANCH ONLY. This isolates player/UI/audio routing from third-party audio permissions.
-- If these Creator Store tracks play, the screenshot IDs are blocked by asset usage permissions.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")

-- Known Creator Store / open-use controls.
local TRACKS={
 {title="TutorialMusic_01 — Roblox",id="130053244401794"},
 {title="Full Force — APMOfficial",id="1842801942"},
 {title="In Suspension — APMOfficial",id="1839847453"},
}

local group=SoundService:WaitForChild("BBYABasementMaster",45)
if not group or not group:IsA("SoundGroup") then
 warn("[BBYA/PublicAudioProbe] BBYABasementMaster missing")
 return
end

group.Volume=1
group:SetAttribute("DirectIDTest",false)
group:SetAttribute("PublicAudioProbe",true)
group:SetAttribute("PublicAudioProbeVersion","V2_CREATOR_STORE_CONTROL")
group:SetAttribute("CatalogSource","PUBLIC_AUDIO_CONTROL")

local old=SoundService:FindFirstChild("BBYAUndergroundPublicAudioProbe")
if old then old:Destroy() end
local testSound=Instance.new("Sound")
testSound.Name="BBYAUndergroundPublicAudioProbe"
testSound.Volume=1
testSound.Looped=false
testSound.SoundGroup=group
testSound.Parent=SoundService

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local stateRemote=remotes and remotes:FindFirstChild("State")
local basementMusic=remotes and remotes:FindFirstChild("BasementMusic")
local current=0
local bad={}

local function inBasement(player)
 local ch=player and player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 return hrp and hrp.Position.Y<-4.5 or false
end

local function stopPrimaryDecks()
 for _,name in ipairs({"BBYABasementDeckA","BBYABasementDeckB","BBYAUndergroundBreakbeatFallbackV4","BBYAUndergroundDirectIDTest"}) do
  local s=SoundService:FindFirstChild(name)
  if s and s:IsA("Sound") then s:Stop();s.Volume=0 end
 end
end

local function uiTrackList()
 local out={}
 for i,t in ipairs(TRACKS) do
  out[i]={title=t.title,artist="Creator Store Control",id=t.id,style="underground",order=i}
 end
 return out
end

local function fireState(target)
 if not stateRemote or not stateRemote:IsA("RemoteEvent") then return end
 local t=TRACKS[current]
 local data={
  index=current,title=t and t.title or "",artist="Creator Store Control",style="underground",
  playing=testSound.IsPlaying,queue=0,audioMode="PUBLIC_AUDIO_CONTROL",venue="BASEMENT",genre="UNDERGROUND",
  library=#TRACKS,liveDeck="CONTROL",standbyDeck="",standbyIndex=0,standbyTitle="",mixSeconds=0,
  catalogSource="PUBLIC_AUDIO_CONTROL",catalogRevision=2026083004,
 }
 if target then stateRemote:FireClient(target,"music",data);return end
 for _,p in ipairs(Players:GetPlayers()) do if inBasement(p) then stateRemote:FireClient(p,"music",data) end end
end

local function waitLoaded(timeout)
 local deadline=os.clock()+(timeout or 10)
 while os.clock()<deadline do
  if testSound.IsLoaded and (testSound.TimeLength or 0)>10 then return true end
  task.wait(.15)
 end
 return testSound.IsLoaded and (testSound.TimeLength or 0)>10
end

local function playIndex(i)
 if bad[i] or not TRACKS[i] then return false end
 stopPrimaryDecks()
 testSound:Stop()
 testSound.SoundId="rbxassetid://"..TRACKS[i].id
 testSound.TimePosition=0
 group:SetAttribute("PublicAudioProbeTrying",TRACKS[i].title)
 local ok,err=pcall(function()ContentProvider:PreloadAsync({testSound})end)
 if not ok or not waitLoaded(10) then
  bad[i]=true
  group:SetAttribute("PublicAudioProbeLastFailed",TRACKS[i].title)
  warn("[BBYA/PublicAudioProbe] preload failed: "..TRACKS[i].title.." / "..TRACKS[i].id.." / "..tostring(err))
  return false
 end
 current=i
 testSound:Play()
 task.wait(.35)
 if not testSound.IsPlaying then
  bad[i]=true
  group:SetAttribute("PublicAudioProbeLastFailed",TRACKS[i].title)
  warn("[BBYA/PublicAudioProbe] play failed: "..TRACKS[i].title)
  return false
 end
 group:SetAttribute("PublicAudioProbeNow",TRACKS[i].title)
 group:SetAttribute("PublicAudioProbeAssetId",TRACKS[i].id)
 group:SetAttribute("PublicAudioProbeTimeLength",testSound.TimeLength)
 fireState()
 print(string.format("[BBYA/PublicAudioProbe] PLAYING %s (%s), length=%.2fs",TRACKS[i].title,TRACKS[i].id,testSound.TimeLength))
 return true
end

local function playNext()
 for _=1,#TRACKS do
  local i=(current%#TRACKS)+1
  current=i
  if playIndex(i) then return end
 end
 warn("[BBYA/PublicAudioProbe] no Creator Store control audio could play")
end

if basementMusic and basementMusic:IsA("BindableEvent") then
 basementMusic.Event:Connect(function(action,player,arg)
  if action=="list" and player and stateRemote then
   task.delay(.15,function()stateRemote:FireClient(player,"playlist",uiTrackList());fireState(player)end)
  elseif action=="request" and tonumber(arg) and TRACKS[tonumber(arg)] then
   task.spawn(function()playIndex(tonumber(arg))end)
  elseif action=="next" then
   task.spawn(playNext)
  end
 end)
end

task.spawn(function()
 while task.wait(.5) do stopPrimaryDecks() end
end)

testSound.Ended:Connect(function()task.defer(playNext)end)

task.delay(3,function()
 stopPrimaryDecks()
 playNext()
end)

print("[BBYA] Public Audio Control Probe v2 online — 3 Creator Store tracks, no APK/OAuth")
