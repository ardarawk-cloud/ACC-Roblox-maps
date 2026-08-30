-- BBYA SOCIAL HUB — MUSIC SUITE MAIN SAFETY GUARD v1
-- Prevents Music Suite overlap with other command-menu panels on current main.
-- UI-only guard: no Sound, SoundGroup, playlist, or server authority writes.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local suite=pg:FindFirstChild("BBYAMusicSuiteV1") or pg:WaitForChild("BBYAMusicSuiteV1",20)
local clubUI=pg:FindFirstChild("BBYAClubUI") or pg:WaitForChild("BBYAClubUI",20)
if not suite or not clubUI then return end
local hub=clubUI:FindFirstChild("HubPanel") or clubUI:WaitForChild("HubPanel",20)
if not hub then return end

local bound={}
local function retireLegacyMusic()
 local compact=clubUI:FindFirstChild("BBYACompactMusicLayerV7")
 if compact then compact:Destroy() end
 local card=hub:FindFirstChild("PlayerCard",true)
 local legacy=card and card.Parent
 if legacy and legacy~=hub then legacy.Visible=false end
end

local function closeSuiteForOtherPanel()
 if suite.Enabled then suite.Enabled=false end
end

local function bindCommandMenu()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=menu and menu:FindFirstChild("FeatureDrawer")
 if not drawer then return end
 for _,slot in ipairs(drawer:GetDescendants()) do
  if slot:IsA("GuiObject") and slot.Name:match("^Slot_") then
   local isMusic=slot.Name=="Slot_MUSIC"
   for _,b in ipairs(slot:GetChildren()) do
    if b:IsA("TextButton") and not bound[b] then
     bound[b]=true
     if not isMusic then b.Activated:Connect(function()task.defer(closeSuiteForOtherPanel)end) end
    end
   end
  end
 end
end

local close=suite:FindFirstChild("Close",true)
if close and close:IsA("GuiButton") then
 close.Activated:Connect(function()
  task.defer(function()
   suite.Enabled=false
   hub.Visible=true
  end)
 end)
end

hub:GetPropertyChangedSignal("Visible"):Connect(function()
 if hub.Visible and suite.Enabled then suite.Enabled=false end
end)

clubUI.ChildAdded:Connect(function(child)
 if child.Name=="BBYACompactMusicLayerV7" then task.defer(retireLegacyMusic) end
end)
pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" then task.defer(bindCommandMenu) end
end)

retireLegacyMusic()
bindCommandMenu()
for i=1,10 do task.delay(i*.35,function()retireLegacyMusic();bindCommandMenu()end) end

suite:SetAttribute("BBYAMainSafetyGuard","V1")
print("[BBYA] Music Suite main safety guard v1 online: no panel overlap / legacy compact layer retired")
