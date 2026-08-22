-- BBYA SOCIAL HUB — BASEMENT UI PROFILE v6 + AUDIO ROUTE HARD LOCK
-- Underground identity plus final client-side isolation for MAIN / UNDERGROUND / FUNKOT.
-- Heartbeat runs after legacy RenderStepped mixer so the wrong venue feed cannot leak.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local underground=false

local MAIN_PANEL=Color3.fromRGB(9,9,12)
local UNDER_PANEL=Color3.fromRGB(6,11,17)
local MAIN_CARD=Color3.fromRGB(25,23,30)
local UNDER_CARD=Color3.fromRGB(17,24,31)
local MAIN_LINE=Color3.fromRGB(247,55,158)
local UNDER_LINE=Color3.fromRGB(0,144,255)

local function patchPanel(on)
 local gui=pg:FindFirstChild("BBYAClubUI")
 if not gui then return end
 local dock=gui:FindFirstChild("TopDock")
 if dock then
  for _,obj in ipairs(dock:GetChildren()) do
   if obj:IsA("TextButton") then
    local up=string.upper(obj.Text or "")
    if up:find("MUSIC",1,true) or up=="UNDERGROUND" then
     obj.Text=on and "UNDERGROUND" or "MUSIC"
     obj.BackgroundColor3=on and Color3.fromRGB(20,55,84) or Color3.fromRGB(15,14,19)
    end
   end
  end
 end
 local panel=gui:FindFirstChild("HubPanel")
 if not panel then return end
 panel.BackgroundColor3=on and UNDER_PANEL or MAIN_PANEL
 local playerCard=panel:FindFirstChild("PlayerCard",true)
 local libraryCard=panel:FindFirstChild("LibraryCard",true)
 if playerCard and playerCard:IsA("Frame") then playerCard.BackgroundColor3=on and UNDER_CARD or MAIN_CARD end
 if libraryCard and libraryCard:IsA("Frame") then libraryCard.BackgroundColor3=on and Color3.fromRGB(15,21,28) or MAIN_CARD end
 for _,obj in ipairs(panel:GetDescendants()) do
  if obj:IsA("UIStroke") and obj.Parent==panel then
   obj.Color=on and UNDER_LINE or MAIN_LINE
  elseif obj:IsA("TextLabel") then
   local up=string.upper(obj.Text or "")
   if up=="MUSIC SYSTEM" or up=="UNDERGROUND MUSIC" or up=="UNDERGROUND / INDO ROOM" then
    obj.Text=on and "UNDERGROUND / INDO ROOM" or "MUSIC SYSTEM"
   elseif up:find("INDEPENDENT INDO CHANNEL",1,true) or up:find("MAIN WESTERN CHANNEL",1,true) or up:find("DUAL DECK AUTOMIX",1,true) then
    obj.Text=on and "Independent Indo venue • Dual Deck AutoMix • breakbeat / indo-bounce" or "Main progressive channel • independent from Underground"
   elseif up:find("BASEMENT • INDO",1,true) or up:find("MAIN • WESTERN",1,true) then
    obj.Text=on and "UNDERGROUND • INDO AUTODJ • DECK A/B" or "MAIN • WESTERN / INTERNATIONAL"
   elseif up=="LIBRARY / REQUEST" or up=="BASEMENT LIBRARY / REQUEST" then
    obj.Text=on and "UNDERGROUND LIBRARY / REQUEST" or "LIBRARY / REQUEST"
   elseif up=="BASEMENT INDO LIBRARY / REQUEST" or up=="REQUEST MASUK QUEUE BASEMENT • TIDAK MEMOTONG TRACK AKTIF" then
    obj.Text=on and "Request masuk queue Underground • tidak memotong track aktif" or "MAIN PROGRESSIVE LIBRARY / REQUEST"
   end
  end
 end
end

local function rootPosition()
 local ch=player.Character
 local root=ch and ch:FindFirstChild("HumanoidRootPart")
 return root and root.Position or nil
end
local function currentUnderground()
 local p=rootPosition()
 return p and p.Y<-4.5 or false
end

player.CharacterAdded:Connect(function()
 task.wait(1)
 underground=currentUnderground()
 patchPanel(underground)
end)
pg.ChildAdded:Connect(function()task.delay(.3,function()patchPanel(underground)end)end)

task.spawn(function()
 while task.wait(.35) do
  local now=currentUnderground()
  if now~=underground then underground=now end
  patchPanel(underground)
 end
end)

-- FINAL AUDIO AUTHORITY -------------------------------------------------------
-- Main Progressive is never audible below the Underground threshold.
-- Underground Indo is never audible on the main floors.
-- Funkot has its own sealed rear-club feed.
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
  if mg then mg:SetAttribute("ClientRouteV6",venue) end
  if ug then ug:SetAttribute("ClientRouteV6",venue) end
  if fg then fg:SetAttribute("ClientRouteV6",venue) end
 end
end)

print("[BBYA] Basement UI v6 + hard audio route online: MAIN / UNDERGROUND / FUNKOT isolated")
