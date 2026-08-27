-- BECAK E-BIKE — NUSAKARYA WORLD V2 REMESH v1.0
-- Replaces the visible primitive building shells while preserving their proven collision proxies/gameplay positions.
-- Mobile budget: deterministic low-part-count modular architecture; no external assets required.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BecakEBike", 30)
if not root then return end
local world = root:WaitForChild("Nusakarya", 30)
if not world then return end

local old = world:FindFirstChild("WorldV2Visuals")
if old then old:Destroy() end
local visualRoot = Instance.new("Folder")
visualRoot.Name = "WorldV2Visuals"
visualRoot.Parent = world

local function visualPart(parent,name,size,cf,color,material,shape)
    local p=Instance.new("Part")
    p.Name=name p.Size=size p.CFrame=cf p.Color=color
    p.Material=material or Enum.Material.Concrete
    p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=true
    if shape then p.Shape=shape end
    p.Parent=parent
    return p
end

local function wedge(parent,name,size,cf,color)
    local p=Instance.new("WedgePart")
    p.Name=name p.Size=size p.CFrame=cf p.Color=color p.Material=Enum.Material.Metal
    p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
    p.Parent=parent
    return p
end

local function darken(c,f)
    return Color3.new(math.clamp(c.R*f,0,1),math.clamp(c.G*f,0,1),math.clamp(c.B*f,0,1))
end

local function addWindow(parent,cf,w,h)
    local frame=visualPart(parent,"WindowFrame",Vector3.new(w+0.35,h+0.35,0.22),cf,Color3.fromRGB(55,59,62),Enum.Material.Metal)
    local glass=visualPart(parent,"Glass",Vector3.new(w,h,0.26),cf*CFrame.new(0,0,-0.04),Color3.fromRGB(78,119,137),Enum.Material.Glass)
    glass.Transparency=0.18
    return frame
end

local function classify(name)
    if name:match("^Rumah_") then return "house" end
    if name:match("^RukoPasar_") then return "shop" end
    if name=="Sekolah" then return "school" end
    if name=="RumahSakit" then return "hospital" end
    if name=="Mall" then return "mall" end
    if name=="Hotel" then return "hotel" end
    if name=="Terminal" then return "terminal" end
    if name=="Factory" then return "industrial" end
    return nil
end

local remeshed=0
local visualPieces=0
for _,model in ipairs(world:GetChildren()) do
    if model:IsA("Model") then
        local kind=classify(model.Name)
        local body=model:FindFirstChild("Body")
        local roof=model:FindFirstChild("Roof")
        if kind and body and body:IsA("BasePart") then
            -- Keep original Body as invisible collision proxy. This preserves gameplay while replacing its primitive appearance.
            body.Transparency=1 body.CastShadow=false
            if roof and roof:IsA("BasePart") then roof.Transparency=1 roof.CanCollide=false roof.CastShadow=false end

            local m=Instance.new("Model") m.Name="V2_"..model.Name m.Parent=visualRoot
            local s=body.Size local base=body.CFrame*CFrame.new(0,-s.Y*0.04,0)
            local wall=body.Color local trim=darken(wall,0.72) local roofColor=Color3.fromRGB(64,67,69)
            local floors=math.max(1,math.floor(s.Y/12))

            -- Main mass is narrower than the old collision box, immediately breaking the cuboid silhouette.
            visualPart(m,"MainMass",Vector3.new(s.X*0.82,s.Y*0.88,s.Z*0.72),base*CFrame.new(0,0,s.Z*0.04),wall,Enum.Material.Concrete)
            visualPieces+=1
            -- Side wing / setback creates an L-shaped footprint instead of one rectangular block.
            local wingSide=((#model.Name%2)==0) and 1 or -1
            visualPart(m,"SideWing",Vector3.new(s.X*0.28,s.Y*0.62,s.Z*0.48),base*CFrame.new(wingSide*s.X*0.37,-s.Y*0.11,s.Z*0.10),darken(wall,0.93),Enum.Material.Brick)
            visualPieces+=1
            -- Ground-floor entrance volume and canopy give real facade depth at player eye level.
            visualPart(m,"EntranceVolume",Vector3.new(math.max(6,s.X*0.22),math.min(7,s.Y*0.28),2.2),body.CFrame*CFrame.new(0,-s.Y*0.32,-s.Z*0.38),darken(wall,0.82),Enum.Material.Concrete)
            visualPart(m,"Canopy",Vector3.new(math.max(8,s.X*0.28),0.45,3.4),body.CFrame*CFrame.new(0,-s.Y*0.16,-s.Z*0.48),trim,Enum.Material.Metal)
            visualPieces+=2

            -- Horizontal floor bands and recessed window rhythm; capped for mobile performance.
            local rows=math.min(4,floors)
            local cols=math.clamp(math.floor(s.X/18),2,5)
            for r=1,rows do
                local y=-s.Y/2 + (r/(rows+1))*s.Y
                visualPart(m,"FloorBand",Vector3.new(s.X*0.80,0.32,0.34),body.CFrame*CFrame.new(0,y,-s.Z*0.37),trim,Enum.Material.Concrete)
                visualPieces+=1
                for c=1,cols do
                    local x=((c-(cols+1)/2)/(cols))*s.X*0.66
                    addWindow(m,body.CFrame*CFrame.new(x,y+1.4,-s.Z*0.372),math.min(5,s.X/(cols*1.6)),3.5)
                    visualPieces+=2
                end
            end

            -- Roof silhouette depends on building class; no more universal flat slab.
            local top=body.CFrame*CFrame.new(0,s.Y/2,0)
            if kind=="house" or kind=="shop" or kind=="school" then
                local halfX=s.X*0.44
                wedge(m,"RoofSlopeA",Vector3.new(halfX,4,s.Z*0.80),top*CFrame.new(-halfX/2,1.6,0)*CFrame.Angles(0,math.rad(90),0),roofColor)
                wedge(m,"RoofSlopeB",Vector3.new(halfX,4,s.Z*0.80),top*CFrame.new(halfX/2,1.6,0)*CFrame.Angles(0,math.rad(-90),0),roofColor)
                visualPieces+=2
            elseif kind=="hotel" or kind=="hospital" or kind=="mall" then
                visualPart(m,"SetbackCrown",Vector3.new(s.X*0.52,5,s.Z*0.48),top*CFrame.new(0,2.5,s.Z*0.05),darken(wall,0.88),Enum.Material.Concrete)
                visualPart(m,"RoofPavilion",Vector3.new(s.X*0.30,4,s.Z*0.28),top*CFrame.new(0,7,s.Z*0.04),Color3.fromRGB(86,91,94),Enum.Material.Metal)
                visualPieces+=2
            else
                visualPart(m,"RaisedParapet",Vector3.new(s.X*0.72,2.2,s.Z*0.62),top*CFrame.new(0,1.1,0),roofColor,Enum.Material.Metal)
                visualPieces+=1
            end

            -- Rounded corner element on civic/commercial buildings breaks the skyline from all approach angles.
            if kind~="house" and kind~="industrial" then
                local tower=visualPart(m,"CornerTower",Vector3.new(math.clamp(s.Z*0.18,5,10),s.Y*0.72,math.clamp(s.Z*0.18,5,10)),body.CFrame*CFrame.new(s.X*0.38,-s.Y*0.08,-s.Z*0.31),darken(wall,0.86),Enum.Material.Concrete,Enum.PartType.Cylinder)
                tower.CFrame=tower.CFrame*CFrame.Angles(0,0,math.rad(90))
                visualPieces+=1
            end
            remeshed+=1
        end
    end
end

Workspace:SetAttribute("ACC_BecakWorldV2Remesh","v1.0")
Workspace:SetAttribute("BecakWorldV2VisualReplacement","ON")
Workspace:SetAttribute("BecakWorldV2CollisionProxyPreserved","ON")
Workspace:SetAttribute("BecakWorldV2RemeshedBuildings",remeshed)
Workspace:SetAttribute("BecakWorldV2VisualPieces",visualPieces)
print("[BECAK E-BIKE] Nusakarya World V2 remesh v1.0",remeshed,"buildings",visualPieces,"visual pieces")
