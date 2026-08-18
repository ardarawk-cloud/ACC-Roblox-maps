-- BBYA SOCIAL HUB — QUEEN PLAYTEST SYSTEM TEST v1.0
-- Non-destructive smoke-test service. Queen-only; normal players cannot invoke it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local QUEEN_ID = 4271188557
local remotes = ReplicatedStorage:FindFirstChild("BBYA_Remotes") or Instance.new("Folder")
remotes.Name = "BBYA_Remotes"
remotes.Parent = ReplicatedStorage

local rf = remotes:FindFirstChild("RunPlaytestCheck") or Instance.new("RemoteFunction")
rf.Name = "RunPlaytestCheck"
rf.Parent = remotes

local function add(rows,label,ok,detail)
 table.insert(rows,{label=label,ok=ok==true,detail=tostring(detail or "")})
 return ok==true
end

local function find(name)
 return workspace:FindFirstChild(name,true)
end

local function hasPrompt(name)
 local obj=find(name)
 return obj and obj:FindFirstChildWhichIsA("ProximityPrompt",true)~=nil
end

local function run(player)
 if not player or player.UserId~=QUEEN_ID then
  return {ok=false,denied=true,rows={},summary="OWNER ONLY"}
 end

 local rows={}
 local passCount=0
 local total=0
 local function check(label,ok,detail)
  total+=1
  if add(rows,label,ok,detail) then passCount+=1 end
 end

 -- Build roots / navigation anchors.
 check("Visual Rebuild",workspace:FindFirstChild("BBYA Premium Visual Rebuild v4")~=nil,"premium shell")
 check("Venue Polish",workspace:FindFirstChild("BBYA Premium Venue Polish v4.1")~=nil,"detail layer")
 check("Phase 3",workspace:FindFirstChild("BBYA Premium Phase 3 v4.3")~=nil,"lobby/queen/rooftop")
 check("Phase 4",workspace:FindFirstChild("BBYA Premium Phase 4 v4.4")~=nil,"VIP/lift/photo")
 check("Phase 5",workspace:FindFirstChild("BBYA Premium Phase 5 v4.5")~=nil,"density/crowd")
 check("Phase 6",workspace:FindFirstChild("BBYA Premium Phase 6 v4.6")~=nil,"wayfinding")

 local anchors={"Main Floor","Dance Floor","DJ Booth","Left VIP Platform","Right VIP Platform","Rooftop Floor","Rooftop Pool"}
 for _,name in ipairs(anchors) do
  check(name,find(name)~=nil,"anchor")
 end

 -- Functional buses.
 local requiredRemotes={"Dance","SyncDance","FX","Teleport","Feedback","MusicControl","MusicState","GetSupporterData"}
 for _,name in ipairs(requiredRemotes) do
  check("Remote "..name,remotes:FindFirstChild(name)~=nil,"BBYA_Remotes")
 end

 local music=SoundService:FindFirstChild("BBYA_MainMusic")
 check("Music Sound",music~=nil,music and (music.SoundId~="" and music.SoundId or "ready") or "missing")
 check("Music State",workspace:GetAttribute("BBYANowPlaying")~=nil,tostring(workspace:GetAttribute("BBYANowPlaying") or "not published yet"))

 -- Interactive venue pieces. Only existence/prompt wiring is checked; nothing is triggered.
 check("West VIP Gate",hasPrompt("West VIP Gate Access Pad"),"access prompt")
 check("East VIP Gate",hasPrompt("East VIP Gate Access Pad"),"access prompt")
 check("Main Club Lift",hasPrompt("Main Club Lift Call Panel"),"lift prompt")
 check("Rooftop Lift",hasPrompt("Rooftop Lift Call Panel"),"lift prompt")
 check("Photo Portal",find("Photo Portal Floor")~=nil,"pose zone")

 -- Safety / regression guards.
 local legacy={"BBYA Visual v1.2","BBYA Social Systems","BBYA Arrival Neon Box"}
 for _,name in ipairs(legacy) do
  check("No Legacy "..name,workspace:FindFirstChild(name)==nil,"must stay absent")
 end

 local buildValidation=tostring(workspace:GetAttribute("BBYABuildValidation") or "WAIT")
 check("Runtime Validation",buildValidation=="PASS",buildValidation)

 local allGood=passCount==total
 workspace:SetAttribute("BBYALastPlaytestStatus",allGood and "PASS" or "WARN")
 workspace:SetAttribute("BBYALastPlaytestPassed",passCount)
 workspace:SetAttribute("BBYALastPlaytestTotal",total)
 workspace:SetAttribute("BBYALastPlaytestAt",os.time())

 return {
  ok=allGood,
  rows=rows,
  passed=passCount,
  total=total,
  summary=string.format("%d/%d checks passed",passCount,total),
  build=tostring(workspace:GetAttribute("BBYABuildVersion") or "?"),
 }
end

rf.OnServerInvoke=run

Players.PlayerAdded:Connect(function(player)
 if player.UserId==QUEEN_ID then
  player:SetAttribute("BBYAPlaytestAccess",true)
 end
end)
for _,player in ipairs(Players:GetPlayers()) do
 if player.UserId==QUEEN_ID then player:SetAttribute("BBYAPlaytestAccess",true) end
end

print("[BBYA] Queen Playtest System Test v1.0 loaded")
