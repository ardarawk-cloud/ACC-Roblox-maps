-- BBYA SOCIAL HUB — LEGACY DASHBOARD RETIREMENT v6
-- The compact UI system is now the only HubPanel layout authority.
-- Retires old structural dashboard chrome that could bleed through SUPPORT/TRAVEL/MESSAGE.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local panel=gui:WaitForChild("HubPanel",30)
if not panel then return end

panel.ClipsDescendants=true
panel:SetAttribute("BBYAStructuralDashboardAuthority","V6_RETIRED_FOR_COMPACT_UI")

local LEGACY={
 DashboardSideRailV2=true,
 DashboardTopGlassV2=true,
 DashboardShadow=true,
 DashboardAccent=true,
}

local function retire(obj)
 if not obj then return end
 if LEGACY[obj.Name] then
  obj:Destroy()
 end
end

for _,child in ipairs(panel:GetChildren()) do retire(child) end

panel.ChildAdded:Connect(function(child)
 if LEGACY[child.Name] then
  task.defer(function()
   if child.Parent==panel then child:Destroy() end
  end)
 end
end)

print("[BBYA] Legacy Dashboard v6 retired: side rail / top glass / shadow / accent removed; compact UI owns HubPanel")
