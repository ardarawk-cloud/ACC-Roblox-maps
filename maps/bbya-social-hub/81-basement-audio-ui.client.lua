-- BBYA SOCIAL HUB — LEGACY AUDIO ROUTE COMPATIBILITY v8 + MUSIC SUITE SAFETY
-- Legacy panel styling is retired. Existing MAIN / UNDERGROUND / FUNKOT SoundGroup routing
-- is preserved in purpose, while this script only adds overlap/cleanup guards for BBYAMusicSuiteV1.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function rootPosition()
 local ch=player.Character
 local root=ch and ch:FindFirstChild("HumanoidRootPart")
 return root and root.Position or nil
end

local muteButton=nil
local function isLocallyMuted()
 if not muteButton or not muteButton.Parent then
  muteButton=nil
  local gui=pg:FindFirstChild("BBYAClubUI")
  if gui then
   for _,d in ipairs(gui:GetDescendants()) do
    if d:IsA("TextButton") and ((d.Text or "")=="MUTE LOCAL" or (d.Text or "")=="UNMUTE LOCAL") then
     muteButton=d
     break
    end
   end
  end
 end
 return muteButton and muteButton.Text=="UNMUTE LOCAL" or false
end

local function mainTarget(p)
 if p.Y>40 then return .34,"ROOFTOP" end
 if p.Y>18 then return .48,"VIP" end
 if p.Z<-45 then return .10,"ARRIVAL" end
 if p.Z<-18 then return .20,"FRONT HALL" end
 if p.Z<0 then return .36,"TRANSITION" end
 if math.abs(p.X)>28 then return .62,"BAR / VIP LOUNGE" end
 if p.Z>27 then return .92,"DJ / STAGE" end
 return .84,"MAIN CLUB"
end

local function routeTargets()
 local p=rootPosition()
 if not p then return .20,0,0,"MAIN" end
 if p.Y<-4.5 then return 0,.94,0,"UNDERGROUND" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return 0,0,.96,"FUNKOT" end
 local m=mainTarget(p)
 return m,0,0,"MAIN"
end

local lastVenue=""
RunService.Heartbeat:Connect(function()
 local main,under,funkot,venue=routeTargets()
 if isLocallyMuted() then main,under,funkot=0,0,0 end
 local mg=SoundService:FindFirstChild("BBYAClubMaster")
 local ug=SoundService:FindFirstChild("BBYABasementMaster")
 local fg=SoundService:FindFirstChild("BBYAFunkotMaster")
 if mg and mg:IsA("SoundGroup") then mg.Volume=main end
 if ug and ug:IsA("SoundGroup") then ug.Volume=under end
 if fg and fg:IsA("SoundGroup") then fg.Volume=funkot end
 if venue~=lastVenue then
  lastVenue=venue
  if mg then mg:SetAttribute("ClientRouteV8",venue) end
  if ug then ug:SetAttribute("ClientRouteV8",venue) end
  if fg then fg:SetAttribute("ClientRouteV8",venue) end
 end
end)

-- MUSIC SUITE SAFETY ----------------------------------------------------------
-- This section does not touch audio. It only prevents old/new music panels from overlapping.
local boundButtons=setmetatable({},{__mode="k"})
local boundClose=setmetatable({},{__mode="k"})
local boundHub=setmetatable({},{__mode="k"})

local function suiteSafety()
 local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
 local clubUI=pg:FindFirstChild("BBYAClubUI")
 if not suite or not clubUI then return end
 local hub=clubUI:FindFirstChild("HubPanel")

 local compact=clubUI:FindFirstChild("BBYACompactMusicLayerV7")
 if compact then compact:Destroy() end
 local livePill=suite:FindFirstChild("LivePillV3",true)
 if livePill then livePill:Destroy() end

 local close=suite:FindFirstChild("Close",true)
 if close and close:IsA("GuiButton") and not boundClose[close] then
  boundClose[close]=true
  close.Activated:Connect(function()
   task.defer(function()
    suite.Enabled=false
    -- Full-close contract: do not resurrect the retired HubPanel/music shell.
    if hub then hub.Visible=false end
   end)
  end)
 end

 if hub and not boundHub[hub] then
  boundHub[hub]=true
  hub:GetPropertyChangedSignal("Visible"):Connect(function()
   if hub.Visible and suite.Enabled then suite.Enabled=false end
  end)
 end

 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=menu and menu:FindFirstChild("FeatureDrawer")
 if drawer then
  for _,slot in ipairs(drawer:GetDescendants()) do
   if slot:IsA("GuiObject") and slot.Name:match("^Slot_") and slot.Name~="Slot_MUSIC" then
    for _,b in ipairs(slot:GetChildren()) do
     if b:IsA("TextButton") and not boundButtons[b] then
      boundButtons[b]=true
      b.Activated:Connect(function()
       task.defer(function()if suite.Enabled then suite.Enabled=false end end)
      end)
     end
    end
   end
  end
 end
end

pg.ChildAdded:Connect(function()task.defer(suiteSafety)end)
for i=0,12 do task.delay(i*.35,suiteSafety) end
player:SetAttribute("BBYALegacyMusicUIRetired",true)
player:SetAttribute("BBYAMusicSuiteMainSafety","V1")

print("[BBYA] Legacy audio route compatibility v8 + Music Suite safety online: old styling retired / route preserved")
