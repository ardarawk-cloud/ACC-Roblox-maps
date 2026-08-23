local Workspace=game:GetService("Workspace")

-- TRACK 01 v2.8.1 aisle hotfix.
-- Removes the incorrectly rotated 38-stud InteriorHandrail pieces that crossed the
-- carriage aisle, then restores slim side-wall rails parallel to the train body.
local deadline=os.clock()+45
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_INTERIOR_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end
local interior=world:FindFirstChild("TRACK01_Interior_v25")
if not interior then return end

local removed=0
for _,obj in ipairs(interior:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Name=="InteriorHandrail" then
        obj:Destroy()
        removed+=1
    end
end

local old=world:FindFirstChild("TRACK01_AisleHotfix_v281")
if old then old:Destroy() end
local fix=Instance.new("Folder")
fix.Name="TRACK01_AisleHotfix_v281"
fix.Parent=world

local railColor=Color3.fromRGB(112,111,105)
for _,centerZ in ipairs({-58,-5,48,101}) do
    for _,x in ipairs({15.05,28.95}) do
        local rail=Instance.new("Part")
        rail.Name="SideHandrail"
        rail.Size=Vector3.new(0.24,0.24,38)
        rail.CFrame=CFrame.new(x,9.3,centerZ)
        rail.Color=railColor
        rail.Material=Enum.Material.Metal
        rail.Anchored=true
        rail.CanCollide=false
        rail.CanTouch=false
        rail.CanQuery=false
        rail.CastShadow=false
        rail.TopSurface=Enum.SurfaceType.Smooth
        rail.BottomSurface=Enum.SurfaceType.Smooth
        rail.Parent=fix
    end
end

root:SetAttribute("AisleHotfixVersion","2.8.1")
Workspace:SetAttribute("ACC_TRACK01_AISLE_CLEAR",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.8.1")
print("[TRACK 01] aisle hotfix v2.8.1 ready; removed crossing rails:",removed)
