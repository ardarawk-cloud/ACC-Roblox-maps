-- BBYA SOCIAL HUB — BASEMENT UI PROFILE v5
-- Premium venue identity for the independent Basement Indo AutoDJ.
-- Audio switching itself remains owned by Unified UI v5.

local Players=game:GetService("Players")
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
   local txt=obj.Text or ""
   local up=string.upper(txt)
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

local function currentUnderground()
 local ch=player.Character
 local root=ch and ch:FindFirstChild("HumanoidRootPart")
 return root and root.Position.Y<-4.5 or false
end

player.CharacterAdded:Connect(function()
 task.wait(1)
 underground=currentUnderground()
 patchPanel(underground)
end)

pg.ChildAdded:Connect(function()
 task.delay(.3,function()patchPanel(underground)end)
end)

-- Re-apply while underground because Unified UI can refresh page copy when the
-- music tab opens or when a new AutoDJ state packet arrives.
task.spawn(function()
 while task.wait(.35) do
  local now=currentUnderground()
  if now~=underground then underground=now end
  patchPanel(underground)
 end
end)

print("[BBYA] Basement UI profile v5 online: Indo Room / Dual Deck / premium underground identity")
