-- BBYA FUNKOT WEB CANDIDATE AUDITION
-- Existing public Roblox asset IDs only; no uploads. Temporary audition runner.
local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")

local IDS={
"87341958008372","105935548669522","8878668071","7286537818","7287031566",
"7108512201","6508860948","6771823728","5627485930","4538932098","6931626800",
"934724376","6890571982","6804448837","7268396686","7261833046","7264412676",
"7124423466","7141032014","5247527968","4708989492","5173622713","4620744989","5105314606"
}

local function inFunkot(p)
 local c=p.Character; local h=c and c:FindFirstChild("HumanoidRootPart")
 if not h then return false end
 local x=h.Position
 return x.Y>-4 and x.Y<34 and math.abs(x.X)<61 and x.Z>157 and x.Z<253
end
local function occupied()
 for _,p in ipairs(Players:GetPlayers()) do if inFunkot(p) then return true end end
 return false
end

local s=Instance.new("Sound")
s.Name="BBYAFunkotWebAudition"
s.Volume=.9
s.Looped=false
s.Parent=SoundService

local i=0
local busy=false
local function nextCandidate()
 if busy or not occupied() then return end
 busy=true
 for _=1,#IDS do
  i=(i%#IDS)+1
  pcall(function() s:Stop() end)
  s.SoundId="rbxassetid://"..IDS[i]
  s.TimePosition=0
  local ok=pcall(function() s:Play() end)
  local ready=false
  if ok then
   local deadline=os.clock()+4.5
   repeat
    if s.IsPlaying and (s.IsLoaded or (s.TimeLength or 0)>1) then ready=true break end
    task.wait(.15)
   until os.clock()>=deadline
  end
  if ready then
   SoundService:SetAttribute("BBYAFunkotAuditionAssetId",IDS[i])
   SoundService:SetAttribute("BBYAFunkotAuditionIndex",i)
   busy=false
   return
  end
 end
 busy=false
end

s.Ended:Connect(function() task.delay(.5,nextCandidate) end)
task.spawn(function()
 while task.wait(2) do
  if occupied() then
   if not s.IsPlaying and not busy then nextCandidate() end
  elseif s.IsPlaying then
   pcall(function() s:Stop() end)
  end
 end
end)
print("[BBYA] Funkot web audition ready",#IDS)
