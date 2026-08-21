-- BBYA SOCIAL HUB — BASEMENT UI PROFILE v4
-- Visual identity only. Audio switching is owned by Unified UI v5 so Main cannot bleed into Basement.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local underground=false

local function patchPanel(on)
 local gui=pg:FindFirstChild("BBYAClubUI")
 if not gui then return end
 local dock=gui:FindFirstChild("TopDock")
 if dock then
  for _,obj in ipairs(dock:GetChildren()) do
   if obj:IsA("TextButton") then
    local up=string.upper(obj.Text or "")
    if up:find("MUSIC",1,true) or up=="UNDERGROUND" then
     obj.Text=on and "UNDERGROUND" or "♫  MUSIC"
     obj.BackgroundColor3=on and Color3.fromRGB(22,48,74) or Color3.fromRGB(15,14,19)
    end
   end
  end
 end
 local panel=gui:FindFirstChild("HubPanel")
 if panel then
  panel.BackgroundColor3=on and Color3.fromRGB(7,12,18) or Color3.fromRGB(9,9,12)
  for _,obj in ipairs(panel:GetDescendants()) do
   if obj:IsA("UIStroke") and obj.Parent==panel then obj.Color=on and Color3.fromRGB(0,144,255) or Color3.fromRGB(247,55,158) end
  end
 end
end

local function currentUnderground()
 local ch=player.Character
 local root=ch and ch:FindFirstChild("HumanoidRootPart")
 return root and root.Position.Y<-4.5 or false
end

player.CharacterAdded:Connect(function()task.wait(1);underground=currentUnderground();patchPanel(underground)end)
pg.ChildAdded:Connect(function()task.delay(.3,function()patchPanel(underground)end)end)

task.spawn(function()
 while task.wait(.45) do
  local now=currentUnderground()
  if now~=underground then underground=now;patchPanel(now) end
 end
end)

print("[BBYA] Basement UI profile v4 online: visual only / audio routing delegated to venue mixer")