-- BBYA SOCIAL HUB — UNIFIED UI COORDINATOR v1.0
-- Keeps launchers independent while ensuring only one large panel is open at a time.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local watched = {}
local mutating = false

local function majorPanel(gui)
 if not gui or not gui:IsA("ScreenGui") then return nil end
 if gui.Name == "BBYA_DanceStudio" then return gui:FindFirstChild("DancePanel") end
 if gui.Name == "BBYA_MusicPanel" then return gui:FindFirstChild("Panel") end
 if gui.Name == "BBYA_UserSawerPanel" then return gui:FindFirstChild("SawerPanel") end
 if gui.Name == "BBYA_SupportPanel" then
  for _,child in ipairs(gui:GetChildren()) do
   if child:IsA("Frame") and child.Size.Y.Offset >= 300 then return child end
  end
 end
 return nil
end

local function closeOthers(active)
 if mutating then return end
 mutating = true
 for panel in pairs(watched) do
  if panel ~= active and panel.Parent and panel.Visible then panel.Visible = false end
 end
 mutating = false
end

local function watchPanel(panel)
 if not panel or watched[panel] then return end
 watched[panel] = true
 panel:GetPropertyChangedSignal("Visible"):Connect(function()
  if panel.Visible then closeOthers(panel) end
 end)
 if panel.Visible then closeOthers(panel) end
end

local targetGuiNames = {
 BBYA_DanceStudio=true,
 BBYA_MusicPanel=true,
 BBYA_UserSawerPanel=true,
 BBYA_SupportPanel=true,
}

local function inspect(gui)
 if not gui:IsA("ScreenGui") or not targetGuiNames[gui.Name] then return end
 local panel = majorPanel(gui)
 if panel then
  watchPanel(panel)
 else
  gui.ChildAdded:Connect(function()
   task.defer(function()
    local found=majorPanel(gui)
    if found then watchPanel(found) end
   end)
  end)
 end
end

for _,gui in ipairs(pg:GetChildren()) do inspect(gui) end
pg.ChildAdded:Connect(function(gui) task.defer(inspect,gui) end)

-- Escape / Back-button behavior is handled by each panel's own close button.
player:SetAttribute("BBYAUIConsolidated",true)
print("[BBYA] Unified UI Coordinator v1.0 loaded")
