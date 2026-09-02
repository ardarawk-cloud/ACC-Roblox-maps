-- BBYA MUSIC UI TEST — PARTY BACKPACK COREGUI AUTHORITY v1
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Owns only Backpack CoreGui visibility while Party Stuff is open/active.
-- No panel geometry, no menu layout, no DJ/Music ownership.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local StarterGui=game:GetService("StarterGui")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local gearRemote=remotes and remotes:WaitForChild("ClubGear",30)
if not gearRemote then return end

local function setBackpackVisible(visible)
 pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,visible) end)
end

local function partyActive()
 return tostring(player:GetAttribute("BBYAPartyGear") or "")~=""
end

local boundPanel=nil
local function bindPartyPanel()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local panel=(menu and menu:FindFirstChild("PartyStuffPanel",true)) or pg:FindFirstChild("PartyStuffPanel",true)
 if not panel or not panel:IsA("GuiObject") or panel==boundPanel then return end
 boundPanel=panel
 panel:GetPropertyChangedSignal("Visible"):Connect(function()
  if panel.Visible or partyActive() then setBackpackVisible(false) else setBackpackVisible(true) end
 end)
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("TextButton") then
   d.Activated:Connect(function()
    -- Kernel may enable Backpack in its own callback. This connection runs in the same tap and wins last.
    task.defer(function() setBackpackVisible(false) end)
   end)
  end
 end
end

player:GetAttributeChangedSignal("BBYAPartyGear"):Connect(function()
 if partyActive() then setBackpackVisible(false) else setBackpackVisible(true) end
end)

gearRemote.OnClientEvent:Connect(function(action,data)
 if action~="result" then return end
 data=type(data)=="table" and data or {}
 if data.ok and tostring(data.name or "")~="" then
  setBackpackVisible(false)
 elseif data.ok and tostring(data.name or "")=="" then
  setBackpackVisible(true)
 end
end)

player.CharacterAdded:Connect(function()
 task.defer(function() setBackpackVisible(true); bindPartyPanel() end)
end)
pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" then task.defer(bindPartyPanel); task.delay(.2,bindPartyPanel) end
end)

task.defer(bindPartyPanel)
for i=1,8 do task.delay(i*.2,bindPartyPanel) end
print("[BBYA TEST] Party Backpack CoreGui authority v1 online")
