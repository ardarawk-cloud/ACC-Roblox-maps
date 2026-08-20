-- BECAK E-BIKE — World polish v1.5
-- Converts passenger markers into lightweight human silhouettes and adds service-zone props.
local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local passengers=root:WaitForChild('Passengers',20)
local interactives=root:WaitForChild('Interactives',20)
local world=root:WaitForChild('Nusakarya',20)
if not passengers or not interactives or not world then return end

local function makePart(parent,name,size,cf,color,material,collide)
    local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide==true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Parent=parent;return p
end

local outfits={
    {Color3.fromRGB(44,92,160),Color3.fromRGB(45,48,52)},
    {Color3.fromRGB(184,71,72),Color3.fromRGB(55,58,62)},
    {Color3.fromRGB(55,139,83),Color3.fromRGB(39,43,46)},
    {Color3.fromRGB(205,143,55),Color3.fromRGB(49,51,55)},
    {Color3.fromRGB(102,77,154),Color3.fromRGB(44,47,51)},
    {Color3.fromRGB(62,137,145),Color3.fromRGB(53,56,60)},
    {Color3.fromRGB(176,92,50),Color3.fromRGB(43,46,49)},
    {Color3.fromRGB(74,103,174),Color3.fromRGB(51,54,57)},
}

local function addNpcVisual(node,index)
    if node:FindFirstChild('NPCVisual') then return end
    node.Transparency=1
    local model=Instance.new('Model');model.Name='NPCVisual';model.Parent=node
    local shirt,pants=table.unpack(outfits[((index-1)%#outfits)+1])
    local base=node.CFrame
    local torso=makePart(model,'Torso',Vector3.new(1.8,2.2,.9),base*CFrame.new(0,.5,0),shirt,Enum.Material.Fabric,false)
    local head=makePart(model,'Head',Vector3.new(1.3,1.3,1.3),base*CFrame.new(0,2.25,0),Color3.fromRGB(221,172,132),Enum.Material.SmoothPlastic,false);head.Shape=Enum.PartType.Ball
    makePart(model,'LegL',Vector3.new(.7,2.1,.75),base*CFrame.new(-.45,-1.55,0),pants,Enum.Material.Fabric,false)
    makePart(model,'LegR',Vector3.new(.7,2.1,.75),base*CFrame.new(.45,-1.55,0),pants,Enum.Material.Fabric,false)
    makePart(model,'ArmL',Vector3.new(.55,2,.55),base*CFrame.new(-1.15,.45,0),Color3.fromRGB(221,172,132),Enum.Material.SmoothPlastic,false)
    makePart(model,'ArmR',Vector3.new(.55,2,.55),base*CFrame.new(1.15,.45,0),Color3.fromRGB(221,172,132),Enum.Material.SmoothPlastic,false)
    local hair=makePart(model,'Hair',Vector3.new(1.25,.45,1.15),base*CFrame.new(0,2.74,0),Color3.fromRGB(35,28,24),Enum.Material.SmoothPlastic,false)
    local function syncVisible()
        local hidden=node.Transparency>=.95
        for _,p in ipairs(model:GetChildren()) do if p:IsA('BasePart') then p.Transparency=hidden and 1 or 0 end end
    end
    -- Runtime marker stays invisible; prompt enable state controls whether NPC should be present.
    local prompt=node:FindFirstChildOfClass('ProximityPrompt')
    if prompt then
        local function syncPrompt()
            local hidden=not prompt.Enabled
            for _,p in ipairs(model:GetChildren()) do if p:IsA('BasePart') then p.Transparency=hidden and 1 or 0 end end
        end
        prompt:GetPropertyChangedSignal('Enabled'):Connect(syncPrompt);syncPrompt()
    else
        syncVisible()
    end
end

for i,node in ipairs(passengers:GetChildren()) do if node:IsA('BasePart') then addNpcVisual(node,i) end end
passengers.ChildAdded:Connect(function(node) if node:IsA('BasePart') then task.wait(.1);addNpcVisual(node,#passengers:GetChildren()) end end)

-- Charging station shelter
local charge=interactives:FindFirstChild('ChargingStation')
if charge and not world:FindFirstChild('ChargingShelter') then
    local shelter=Instance.new('Model');shelter.Name='ChargingShelter';shelter.Parent=world
    makePart(shelter,'Roof',Vector3.new(30,1,22),charge.CFrame*CFrame.new(0,8,0),Color3.fromRGB(38,44,47),Enum.Material.Metal,true)
    for _,o in ipairs({Vector3.new(-13,4,-9),Vector3.new(13,4,-9),Vector3.new(-13,4,9),Vector3.new(13,4,9)}) do makePart(shelter,'Post',Vector3.new(.7,8,.7),charge.CFrame*CFrame.new(o),Color3.fromRGB(62,67,70),Enum.Material.Metal,true) end
    local charger=makePart(shelter,'Charger',Vector3.new(3,5,2),charge.CFrame*CFrame.new(0,2.6,-8),Color3.fromRGB(32,126,83),Enum.Material.Metal,true)
    makePart(shelter,'Screen',Vector3.new(1.8,1.4,.15),charger.CFrame*CFrame.new(0,.9,-1.05),Color3.fromRGB(78,226,142),Enum.Material.Neon,false)
end

-- Garage canopy and workshop props
local garage=interactives:FindFirstChild('Garage')
if garage and not world:FindFirstChild('PakJayaWorkshop') then
    local shop=Instance.new('Model');shop.Name='PakJayaWorkshop';shop.Parent=world
    makePart(shop,'WorkshopFloor',Vector3.new(40,1,28),garage.CFrame*CFrame.new(0,-.1,0),Color3.fromRGB(87,89,88),Enum.Material.Concrete,true)
    makePart(shop,'WorkshopRoof',Vector3.new(42,1,30),garage.CFrame*CFrame.new(0,9,0),Color3.fromRGB(55,57,59),Enum.Material.Metal,true)
    for _,x in ipairs({-18,18}) do for _,z in ipairs({-12,12}) do makePart(shop,'Post',Vector3.new(.8,9,.8),garage.CFrame*CFrame.new(x,4.5,z),Color3.fromRGB(70,72,74),Enum.Material.Metal,true) end end
    makePart(shop,'ToolBench',Vector3.new(12,3,3),garage.CFrame*CFrame.new(-12,1.5,10),Color3.fromRGB(112,75,48),Enum.Material.Wood,true)
end

Workspace:SetAttribute('ACC_BecakWorldPolish','v1.5')
print('[BECAK E-BIKE] World polish v1.5 ready')
