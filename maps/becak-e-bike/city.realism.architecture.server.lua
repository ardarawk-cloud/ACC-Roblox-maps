-- BECAK E-BIKE — Nusakarya architectural realism v1.1
-- Shapes blockout bodies into layered urban silhouettes without changing collision.
local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local world=root:WaitForChild('Nusakarya',30)
if not world then return end
local old=world:FindFirstChild('CityRealismArchitecture') if old then old:Destroy() end
local folder=Instance.new('Folder');folder.Name='CityRealismArchitecture';folder.Parent=world

local function setup(p,color,material)
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true
 p.Color=color;p.Material=material or Enum.Material.Concrete;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 return p
end
local function part(name,size,cf,color,material)
 local p=setup(Instance.new('Part'),color,material);p.Name=name;p.Size=size;p.CFrame=cf;p.Parent=folder;return p
end
local function wedge(name,size,cf,color,material)
 local p=setup(Instance.new('WedgePart'),color,material);p.Name=name;p.Size=size;p.CFrame=cf;p.Parent=folder;return p
end
local function cylinder(name,height,radius,cf,color,material)
 local p=part(name,Vector3.new(height,radius*2,radius*2),cf*CFrame.Angles(0,0,math.rad(90)),color,material);p.Shape=Enum.PartType.Cylinder;return p
end

local shaped,roofCount,bayCount,arcadeCount,balconyCount=0,0,0,0,0
local entryCount,cornerCount,utilityCount=0,0,0
local glass=Color3.fromRGB(95,126,139)
for _,model in ipairs(world:GetChildren()) do
 if model:IsA('Model') then
  local body=model:FindFirstChild('Body')
  if body and body:IsA('BasePart') then
   local s,cf=body.Size,body.CFrame
   if s.X>=18 and s.Y>=14 and s.Z>=12 then
    local seed=math.abs(math.floor(cf.Position.X*.17+cf.Position.Z*.29))
    local trim=body.Color:Lerp(Color3.fromRGB(235,229,214),.28)
    local dark=body.Color:Lerp(Color3.fromRGB(40,43,46),.42)
    local front=-s.Z/2-.72
    if seed%2==0 then
     local bayW=math.clamp(s.X*.38,7,14)
     local bay=part('ProjectingGlassBay',Vector3.new(bayW,math.clamp(s.Y*.38,6,9),.9),cf*CFrame.new(-s.X*.2,-s.Y*.12,front-.15),glass,Enum.Material.Glass);bay.Transparency=.2
     part('BayTopSlab',Vector3.new(bayW+.6,.22,1.35),cf*CFrame.new(-s.X*.2,s.Y*.08,front-.18),trim,Enum.Material.Concrete)
     bayCount+=2
    end
    local entryW=math.clamp(s.X*.16,3.2,5.4)
    local entryH=math.clamp(s.Y*.31,5.2,7.8)
    part('EntryReveal',Vector3.new(entryW+.9,entryH+.55,.48),cf*CFrame.new(s.X*.2,-s.Y/2+entryH/2+.15,front+.12),dark,Enum.Material.Concrete)
    local door=part('EntryGlassDoor',Vector3.new(entryW,entryH,.14),cf*CFrame.new(s.X*.2,-s.Y/2+entryH/2+.15,front-.18),glass,Enum.Material.Glass);door.Transparency=.16
    part('EntryCanopy',Vector3.new(entryW+1.8,.24,1.65),cf*CFrame.new(s.X*.2,-s.Y/2+entryH+.75,front-.65),trim,Enum.Material.Metal)
    entryCount+=3
    if s.X>=26 and seed%3~=1 then
     for _,x in ipairs({-s.X*.32,0,s.X*.32}) do
      if math.abs(x)<s.X/2-2.5 then
       cylinder('ArcadeColumn',math.clamp(s.Y*.32,5.5,8.5),.24,cf*CFrame.new(x,-s.Y/2+math.clamp(s.Y*.16,2.8,4.4),front-.55),trim,Enum.Material.Concrete)
       arcadeCount+=1
      end
     end
     part('ArcadeBeam',Vector3.new(s.X*.78,.32,.55),cf*CFrame.new(0,-s.Y/2+math.clamp(s.Y*.33,5.6,8.7),front-.55),trim,Enum.Material.Concrete)
     arcadeCount+=1
    end
    if s.Y>=20 and seed%4~=2 then
     local y=math.min(s.Y*.16,4.8)
     part('BalconySlab',Vector3.new(s.X*.58,.22,1.35),cf*CFrame.new(s.X*.08,y,front-.45),dark,Enum.Material.Concrete)
     for i=-3,3 do
      local x=s.X*.08+i*(s.X*.58/6)
      cylinder('BalconyRailPost',1.15,.055,cf*CFrame.new(x,y+.72,front-1.05),Color3.fromRGB(66,69,71),Enum.Material.Metal)
     end
     part('BalconyTopRail',Vector3.new(s.X*.58,.11,.11),cf*CFrame.new(s.X*.08,y+1.28,front-1.05),Color3.fromRGB(66,69,71),Enum.Material.Metal)
     balconyCount+=9
    end
    if s.X>=24 and seed%4==0 then
     local side=(seed%8==0) and 1 or -1
     local cx=side*(s.X/2+.55)
     cylinder('CornerColumn',math.clamp(s.Y*.36,6,9),.32,cf*CFrame.new(cx,-s.Y/2+math.clamp(s.Y*.18,3,4.5),front-.2),trim,Enum.Material.Concrete)
     part('CornerCanopy',Vector3.new(3.2,.26,2.1),cf*CFrame.new(cx,-s.Y/2+math.clamp(s.Y*.37,6.2,9.3),front-.5),dark,Enum.Material.Metal)
     cornerCount+=2
    end
    local roofY=s.Y/2+.15
    if seed%3==0 then
     wedge('RoofSlopeL',Vector3.new(s.X*.52,2.4,s.Z*.8),cf*CFrame.new(-s.X*.24,roofY+1.1,0)*CFrame.Angles(0,math.pi,0),dark,Enum.Material.Slate)
     wedge('RoofSlopeR',Vector3.new(s.X*.52,2.4,s.Z*.8),cf*CFrame.new(s.X*.24,roofY+1.1,0),dark,Enum.Material.Slate)
     roofCount+=2
    elseif seed%3==1 then
     part('SteppedParapet',Vector3.new(s.X*.72,1.25,.55),cf*CFrame.new(0,roofY+.62,-s.Z*.37),trim,Enum.Material.Concrete)
     part('SteppedParapetHigh',Vector3.new(s.X*.34,1.85,.55),cf*CFrame.new(s.X*.14,roofY+.92,-s.Z*.37),dark,Enum.Material.Concrete)
     roofCount+=2
    else
     cylinder('RoofPavilion',math.clamp(s.X*.22,4,8),math.clamp(s.Z*.13,1.6,3.2),cf*CFrame.new(s.X*.18,roofY+1.5,0),dark,Enum.Material.Metal)
     part('RoofCanopy',Vector3.new(math.clamp(s.X*.34,6,12),.18,math.clamp(s.Z*.38,4,9)),cf*CFrame.new(s.X*.18,roofY+3.1,0),trim,Enum.Material.Metal)
     roofCount+=2
    end
    if s.Y>=24 and seed%2==1 then
     local ux=-s.X*.18
     cylinder('RoofWaterTank',2.3,.82,cf*CFrame.new(ux,roofY+1.25,s.Z*.12),Color3.fromRGB(78,83,85),Enum.Material.Metal)
     cylinder('RoofVent',1.35,.18,cf*CFrame.new(ux+2.1,roofY+.72,-s.Z*.16),Color3.fromRGB(102,105,106),Enum.Material.Metal)
     part('RoofServicePad',Vector3.new(4.8,.18,3.2),cf*CFrame.new(ux,roofY+.12,0),dark,Enum.Material.Concrete)
     utilityCount+=3
    end
    for _,z in ipairs({-s.Z*.26,s.Z*.26}) do
     part('SideFacadeFin',Vector3.new(.28,math.clamp(s.Y*.52,7,13),s.Z*.18),cf*CFrame.new(s.X/2+.16,0,z),dark,Enum.Material.Concrete)
     part('SideFacadeFin',Vector3.new(.28,math.clamp(s.Y*.52,7,13),s.Z*.18),cf*CFrame.new(-s.X/2-.16,0,z),dark,Enum.Material.Concrete)
    end
    shaped+=1
   end
  end
 end
end
Workspace:SetAttribute('ACC_BecakCityRealismArchitecture','v1.0')
Workspace:SetAttribute('ACC_BecakCityRealismArchitectureEnhancement','v1.1')
Workspace:SetAttribute('BecakNonBoxBuildingSilhouette','ON')
Workspace:SetAttribute('BecakArchitecturalBayDepth','ON')
Workspace:SetAttribute('BecakArchitecturalRoofVariation','ON')
Workspace:SetAttribute('BecakArchitecturalArcades','ON')
Workspace:SetAttribute('BecakArchitecturalRecessedEntries','ON')
Workspace:SetAttribute('BecakArchitecturalCornerBreakup','ON')
Workspace:SetAttribute('BecakArchitecturalRooftopUtilities','ON')
Workspace:SetAttribute('BecakArchitecturalShapedBuildings',shaped)
Workspace:SetAttribute('BecakArchitecturalRoofPieces',roofCount)
Workspace:SetAttribute('BecakArchitecturalBayPieces',bayCount)
Workspace:SetAttribute('BecakArchitecturalArcadePieces',arcadeCount)
Workspace:SetAttribute('BecakArchitecturalBalconyPieces',balconyCount)
Workspace:SetAttribute('BecakArchitecturalEntryPieces',entryCount)
Workspace:SetAttribute('BecakArchitecturalCornerPieces',cornerCount)
Workspace:SetAttribute('BecakArchitecturalUtilityPieces',utilityCount)
