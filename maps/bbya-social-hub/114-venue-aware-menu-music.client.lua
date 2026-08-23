-- BBYA SOCIAL HUB — VENUE-AWARE MENU MUSIC v1
-- Keeps the command-menu music button synchronized with the player's active venue.
-- Labels: CLUB / UNDERGROUND / VIP / FUNKOT / SKATEPARK / ROOFTOP.

local Players=game:GetService("Players")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local LABELS={
 MAIN="CLUB",
 UNDERGROUND="UNDERGROUND",
 VIP="VIP",
 FUNKOT="FUNKOT",
 SKATEPARK="SKATEPARK",
 ROOFTOP="ROOFTOP",
 NONE="MUSIC",
}

local menuGui
local musicButton
local textGuard
local writing=false

local function currentVenue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
 return LABELS[v] and v or "NONE"
end

local function resolveMenu()
 if menuGui and menuGui.Parent then return menuGui end
 menuGui=pg:FindFirstChild("BBYACommandMenuUI") or pg:WaitForChild("BBYACommandMenuUI",30)
 return menuGui
end

local function findMusicButton()
 local gui=resolveMenu()
 if not gui then return nil end
 if musicButton and musicButton.Parent and musicButton:GetAttribute("BBYACommandMenuId")=="MUSIC" then return musicButton end
 musicButton=nil
 for _,d in ipairs(gui:GetDescendants()) do
  if d:IsA("TextButton") and d:GetAttribute("BBYACommandMenuId")=="MUSIC" then
   musicButton=d
   break
  end
 end
 return musicButton
end

local function desiredLabel()
 return LABELS[currentVenue()] or "MUSIC"
end

local function updateMusicLabel()
 local b=findMusicButton()
 if not b then return end
 local target=desiredLabel()
 if b.Text~=target then
  writing=true
  b.Text=target
  writing=false
 end
 b:SetAttribute("BBYAVenueAwareMusicLabel",target)
end

local function bindButtonGuard()
 local b=findMusicButton()
 if not b or b:GetAttribute("BBYAVenueAwareTextGuardV1") then return end
 b:SetAttribute("BBYAVenueAwareTextGuardV1",true)
 b:GetPropertyChangedSignal("Text"):Connect(function()
  if writing then return end
  task.defer(updateMusicLabel)
 end)
 b.AncestryChanged:Connect(function()
  task.defer(function()
   musicButton=nil
   bindButtonGuard()
   updateMusicLabel()
  end)
 end)
end

local function refresh()
 bindButtonGuard()
 updateMusicLabel()
end

player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()
 task.defer(refresh)
end)

pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" then
  menuGui=child
  musicButton=nil
  task.defer(refresh)
 end
end)

local gui=resolveMenu()
if gui then
 gui.DescendantAdded:Connect(function(d)
  if d:IsA("TextButton") then task.defer(refresh) end
 end)
end

-- A few delayed passes cover startup ordering between ClubUI, Command Menu and the audio router.
for i=0,8 do task.delay(i*.25,refresh) end

print("[BBYA] Venue-aware menu music v1 online: CLUB / UNDERGROUND / VIP / FUNKOT / SKATEPARK / ROOFTOP")
