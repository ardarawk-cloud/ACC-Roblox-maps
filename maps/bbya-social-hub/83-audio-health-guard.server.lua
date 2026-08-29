-- BBYA MUSIC UI TEST — DIRECT UNDERGROUND ID HARNESS v1
-- TEST BRANCH ONLY. Purpose: audition approved Roblox Audio IDs without APK/OAuth.
-- Reuses this already-mapped ServerScriptService slot so no project-tree change is needed.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")

local TRACKS={
 {title="DJ LUKA NEGARA VERSI JEPANG V2",id="86006580589828"},
 {title="DJ Paradise X Velocity Baby Don't Go feat IMA Audio",id="125820152354579"},
 {title="DJ TJAP Morgan V4",id="133947654553749"},
 {title="DJ Ayang Ayang",id="95691778643767"},
 {title="Funk Do Bounce",id="130313438027284"},
 {title="Hadroh Ya Thoybha | Ar Production",id="75712054983357"},
 {title="DJ Banteng Lestari",id="88943191512256"},
 {title="DJ Gangsta MP",id="91809948844354"},
 {title="DJ Kandas HKS",id="108578144206183"},
 {title="DJ Battle HKS",id="89763491889927"},
 {title="DJ Trap Love Of War",id="96924419000406"},
 {title="DJ Cinta Yang Sempurna",id="132460784559824"},
 {title="DJ Bocah Bocah Cilik Sholawat",id="122720606049274"},
 {title="DJ Mahabarata",id="70777592375726"},
 {title="DJ Bila Nanti",id="98308711398889"},
 {title="DJ Punk Rock Jalanan",id="95839337053281"},
 {title="DJ TJAP Morgan Trompet - By Klepon Remix",id="135587255285184"},
 {title="DJ Gedhang Klutuk by DJ Tanti",id="104136707299013"},
 {title="Garam Cina",id="131597067752690"},
 {title="DJ Sin Pijama by Alvin Revolution",id="73502975968958"},
 {title="DJ Trompet Brazil",id="101289385838814"},
 {title="DJ Viral Tik Tok Pal Pal Di Kepas",id="102043858565172"},
 {title="DJ Twenty One Pilots Nova - Tambal Elang",id="79235704240751"},
 {title="DJ Prank Karnaval Viral Booyah",id="103710801320668"},
}

local group=SoundService:WaitForChild("BBYABasementMaster",45)
if not group or not group:IsA("SoundGroup") then
 warn("[BBYA/DirectIDTest] BBYABasementMaster missing")
 return
end

group:SetAttribute("DirectIDTest",true)
group:SetAttribute("DirectIDTestVersion","V1_24_APPROVED")
group:SetAttribute("DirectIDTestCount",#TRACKS)
group:SetAttribute("CatalogSource","DIRECT_ID_TEST")

local old=SoundService:FindFirstChild("BBYAUndergroundDirectIDTest")
if old then old:Destroy() end
local testSound=Instance.new("Sound")
testSound.Name="BBYAUndergroundDirectIDTest"
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
 for _,name in ipairs({"BBYABasementDeckA","BBYABasementDeckB","BBYAUndergroundBreakbeatFallbackV4"}) do
  local s=SoundService:FindFirstChild(name)
  if s and s:IsA("Sound") then
   if s.IsPlaying then s:Stop() end
   s.Volume=0
  end
 end
end

local function uiTrackList()
 local out={}
 for i,t in ipairs(TRACKS) do
  out[i]={title=t.title,artist="Screenshot Roblox ID Test",id=t.id,style="underground",order=i}
 end
 return out
end

local function fireState(target)
 if not stateRemote or not stateRemote:IsA("RemoteEvent") then return end
 local t=TRACKS[current]
 local data={
  index=current,title=t and t.title or "",artist="Screenshot Roblox ID Test",style="underground",
  playing=testSound.IsPlaying,queue=0,audioMode="DIRECT_ID_TEST",venue="BASEMENT",genre="UNDERGROUND",
  library=#TRACKS,liveDeck="TEST",standbyDeck="",standbyIndex=0,standbyTitle="",mixSeconds=0,
  catalogSource="DIRECT_ID_TEST",catalogRevision=2026083003,
 }
 if target then stateRemote:FireClient(target,"music",data);return end
 for _,p in ipairs(Players:GetPlayers()) do if inBasement(p) then stateRemote:FireClient(p,"music",data) end end
end

local function waitLoaded(timeout)
 local deadline=os.clock()+(timeout or 7)
 while os.clock()<deadline do
  if testSound.IsLoaded and (testSound.TimeLength or 0)>2 then return true end
  task.wait(.15)
 end
 return testSound.IsLoaded and (testSound.TimeLength or 0)>2
end

local function playIndex(i)
 if bad[i] or not TRACKS[i] then return false end
 stopPrimaryDecks()
 testSound:Stop()
 testSound.SoundId="rbxassetid://"..TRACKS[i].id
 testSound.TimePosition=0
 group:SetAttribute("DirectIDTestTrying",TRACKS[i].title)
 local ok=pcall(function()ContentProvider:PreloadAsync({testSound})end)
 if not ok or not waitLoaded(7) then
  bad[i]=true
  group:SetAttribute("DirectIDTestLastFailed",TRACKS[i].title)
  warn("[BBYA/DirectIDTest] unavailable: "..TRACKS[i].title.." / "..TRACKS[i].id)
  return false
 end
 current=i
 testSound:Play()
 task.wait(.25)
 if not testSound.IsPlaying then
  bad[i]=true
  group:SetAttribute("DirectIDTestLastFailed",TRACKS[i].title)
  return false
 end
 group:SetAttribute("DirectIDTestNow",TRACKS[i].title)
 group:SetAttribute("DirectIDTestAssetId",TRACKS[i].id)
 group:SetAttribute("DirectIDTestIndex",i)
 fireState()
 print(string.format("[BBYA/DirectIDTest] playing %02d/%02d %s (%s)",i,#TRACKS,TRACKS[i].title,TRACKS[i].id))
 return true
end

local function playNext()
 if #TRACKS==0 then return end
 for _=1,#TRACKS do
  local i=(current%#TRACKS)+1
  current=i
  if playIndex(i) then return end
 end
 warn("[BBYA/DirectIDTest] no playable approved screenshot ID found in this experience")
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

-- Keep the normal Underground AutoDJ/fallback from fighting the audition deck.
task.spawn(function()
 while task.wait(.5) do
  stopPrimaryDecks()
  if current>0 and not testSound.IsPlaying and testSound.PlaybackState~=Enum.PlaybackState.Paused then
   task.spawn(playNext)
  end
 end
end)

testSound.Ended:Connect(function()task.defer(playNext)end)

Players.PlayerAdded:Connect(function(player)
 task.delay(3,function()
  if player.Parent and inBasement(player) then fireState(player) end
 end)
end)

task.delay(3,function()
 stopPrimaryDecks()
 playNext()
end)

print("[BBYA] Direct Underground ID Test v1 online: 24 approved screenshot Audio IDs; APK/OAuth bypassed")
