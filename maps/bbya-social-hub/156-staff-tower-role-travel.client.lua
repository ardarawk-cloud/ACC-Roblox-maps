-- BBYA SOCIAL HUB — STAFF TOWER ROLE TRAVEL CLIENT v1
-- Adds exactly one Staff Tower destination to the existing TRAVEL panel.
-- Visibility is role-only; server remains the final access authority.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local teleportRemote=remotes:WaitForChild("Teleport",30)

local VALID={COOWNER=true,ADMIN=true,MODERATOR=true,DJ=true,LEAD=true,MEDIA=true,VIP=true,CREW=true}
local buttonRef=nil

local function hasTowerRole()
 if player:GetAttribute("BBYAOwner")==true or player:GetAttribute("BBYACoOwner")==true or player:GetAttribute("BBYAAdmin")==true or player:GetAttribute("BBYAModerator")==true then return true end
 local role=player:GetAttribute("BBYAManagedRole")
 return type(role)=="string" and VALID[role]==true
end

local function travelParts()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local panel=menu and menu:FindFirstChild("TravelPanel",true)
 if not panel then return nil,nil end
 local scroll=panel:FindFirstChildWhichIsA("ScrollingFrame")
 return panel,scroll
end

local function findTemplate(scroll)
 if not scroll then return nil end
 for _,child in ipairs(scroll:GetChildren()) do
  if child:IsA("TextButton") and child.Name~="StaffTowerTravelButton" then return child end
 end
 return nil
end

local function removeButton()
 if buttonRef and buttonRef.Parent then buttonRef:Destroy() end
 buttonRef=nil
 local _,scroll=travelParts()
 local stale=scroll and scroll:FindFirstChild("StaffTowerTravelButton")
 if stale then stale:Destroy() end
end

local function installButton()
 local allowed=hasTowerRole()
 local _,scroll=travelParts()
 if not allowed then removeButton();return end
 if not scroll then return end
 local existing=scroll:FindFirstChild("StaffTowerTravelButton")
 if existing and existing:IsA("TextButton") then buttonRef=existing;buttonRef.Visible=true;return end
 local template=findTemplate(scroll)
 if not template then return end
 local b=template:Clone()
 b.Name="StaffTowerTravelButton"
 b.Text="STAFF TOWER"
 b.LayoutOrder=13
 b.Visible=true
 b:SetAttribute("BBYAStaffTowerTravel","ROLE_ONLY_V1")
 b.Parent=scroll
 b.Activated:Connect(function()
  if not hasTowerRole() then b.Visible=false;return end
  teleportRemote:FireServer("StaffTower")
 end)
 buttonRef=b
end

for _,attr in ipairs({"BBYAManagedRole","BBYAOwner","BBYACoOwner","BBYAAdmin","BBYAModerator"}) do
 player:GetAttributeChangedSignal(attr):Connect(function()task.defer(installButton)end)
end

pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" then task.delay(.15,installButton) end
end)

task.spawn(function()
 for _=1,40 do
  installButton()
  if buttonRef then break end
  task.wait(.25)
 end
end)

print("[BBYA] Staff Tower role travel v1 online: role-only button / server-gated access")
