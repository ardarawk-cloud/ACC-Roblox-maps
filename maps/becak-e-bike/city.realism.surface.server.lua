-- BECAK E-BIKE — Nusakarya street-level realism surface pass v1.0
-- Adds visible street-level detail, restrained post-processing and material depth.
-- Dedicated to maps/becak-e-bike; generated geometry is anchored and non-collision.

local Workspace=game:GetService('Workspace')
local Lighting=game:GetService('Lighting')
local root=Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local world=root:WaitForChild('Nusakarya',30)
if not world then return end

local old=world:FindFirstChild('CityRealismSurface') if old then old:Destroy() end
local folder=Instance.new('Folder');folder.Name='CityRealismSurface';folder.Parent=world

local function setup(p,color,material)
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true
 p.Color=color or Color3.fromRGB(120,120,120);p.Material=material or Enum.Material.SmoothPlastic
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;return p
end
local function part(name,size,cf,color,material,shape)
 local p=setup(Instance.new('Part'),color,material);p.Name=name;p.Size=size;p.CFrame=cf;if shape then p.Shape=shape end;p.Parent=folder;return p
end
local function cylinder(name,height,radius,cf,color,material)
 return part(name,Vector3.new(height,radius*2,radius*2),cf*CFrame.Angles(0,0,math.rad(90)),color,material,Enum.PartType.Cylinder)
end

-- Lighting: subtle physical depth without heavy effects.
Lighting.Brightness=2.15
Lighting.EnvironmentDiffuseScale=.38
Lighting.EnvironmentSpecularScale=.5
Lighting.ShadowSoftness=.28
Lighting.OutdoorAmbient=Color3.fromRGB(128,136,146)
Lighting.Ambient=Color3.fromRGB(92,98,106)
local atmosphere=Lighting:FindFirstChild('BecakAtmosphere') or Instance.new('Atmosphere')
atmosphere.Name='BecakAtmosphere';atmosphere.Density=.22;atmosphere.Offset=.12;atmosphere.Color=Color3.fromRGB(205,222,235);atmosphere.Decay=Color3.fromRGB(105,118,130);atmosphere.Glare=.08;atmosphere.Haze=1.15;atmosphere.Parent=Lighting
local cc=Lighting:FindFirstChild('BecakColorGrade') or Instance.new('ColorCorrectionEffect')
cc.Name='BecakColorGrade';cc.Brightness=.01;cc.Contrast=.08;cc.Saturation=.04;cc.TintColor=Color3.fromRGB(250,248,244);cc.Parent=Lighting
local bloom=Lighting:FindFirstChild('BecakBloom') or Instance.new('BloomEffect')
bloom.Name='BecakBloom';bloom.Intensity=.12;bloom.Size=20;bloom.Threshold=1.45;bloom.Parent=Lighting

local roadCount,streetFurnitureCount,storeCount,greenCount=0,0,0,0

-- Street gutters, drains and reflectors create scale cues at driving height.
for x=-500,500,50 do
 for _,z in ipairs({-22.8,22.8}) do
  local gutter=part('RoadGutter',Vector3.new(38,.045,.42),CFrame.new(x,.505,z),Color3.fromRGB(72,74,75),Enum.Material.Concrete);gutter.CastShadow=false
  roadCount+=1
  if math.floor((x+500)/50)%2==0 then
   local grate=part('StormDrain',Vector3.new(3.4,.07,1.05),CFrame.new(x,.54,z),Color3.fromRGB(54,57,59),Enum.Material.Metal);grate.CastShadow=false;roadCount+=1
  end
 end
end
for z=-500,500,50 do
 for _,x in ipairs({-22.8,22.8}) do
  local gutter=part('RoadGutter',Vector3.new(.42,.045,38),CFrame.new(x,.505,z),Color3.fromRGB(72,74,75),Enum.Material.Concrete);gutter.CastShadow=false;roadCount+=1
 end
end
for x=-450,450,36 do
 local marker=part('LaneReflector',Vector3.new(.38,.08,.18),CFrame.new(x,.57,0),Color3.fromRGB(245,220,126),Enum.Material.Neon);marker.CastShadow=false;roadCount+=1
end
for z=-450,450,36 do
 local marker=part('LaneReflector',Vector3.new(.18,.08,.38),CFrame.new(0,.57,z),Color3.fromRGB(245,220,126),Enum.Material.Neon);marker.CastShadow=false;roadCount+=1
end

-- Benches, bins and planter clusters: simple rounded silhouettes, sparse placement for mobile.
local furniturePoints={
 Vector3.new(115,0,-105),Vector3.new(185,0,-105),Vector3.new(255,0,-105),
 Vector3.new(-210,0,330),Vector3.new(-135,0,330),Vector3.new(190,0,-485),Vector3.new(310,0,-485)
}
for i,pos in ipairs(furniturePoints) do
 local seat=part('StreetBenchSeat',Vector3.new(6.5,.38,1.6),CFrame.new(pos+Vector3.new(0,1.8,0)),Color3.fromRGB(112,76,48),Enum.Material.Wood);streetFurnitureCount+=1
 local back=part('StreetBenchBack',Vector3.new(6.5,1.7,.28),CFrame.new(pos+Vector3.new(0,2.75,.7))*CFrame.Angles(math.rad(-8),0,0),Color3.fromRGB(100,68,43),Enum.Material.Wood);streetFurnitureCount+=1
 for _,x in ipairs({-2.5,2.5}) do cylinder('BenchLeg',1.55,.09,CFrame.new(pos+Vector3.new(x,1.0,0)),Color3.fromRGB(58,60,62),Enum.Material.Metal);streetFurnitureCount+=1 end
 local bin=cylinder('StreetBin',2.2,.7,CFrame.new(pos+Vector3.new(4.2,1.1,0)),Color3.fromRGB(48,74,58),Enum.Material.Metal);streetFurnitureCount+=1
end

-- Storefront depth: doors, transom glass, side lamps and varied material accents on existing building models.
local palette={Color3.fromRGB(115,72,44),Color3.fromRGB(62,88,92),Color3.fromRGB(113,92,58),Color3.fromRGB(78,72,95),Color3.fromRGB(97,74,63)}
for _,model in ipairs(world:GetChildren()) do
 if model:IsA('Model') then
  local body=model:FindFirstChild('Body')
  if body and body:IsA('BasePart') and body.Size.X>=18 and body.Size.Y>=12 and body.Size.Z>=12 then
   local cf,size=body.CFrame,body.Size
   local front=-size.Z/2-.9
   local variant=math.abs(math.floor(cf.Position.X*.19+cf.Position.Z*.31))%#palette+1
   local accent=palette[variant]
   local door=part('StoreDoor',Vector3.new(math.clamp(size.X*.13,2.4,4.2),math.clamp(size.Y*.3,5.2,7.4),.16),cf*CFrame.new(0,-size.Y/2+math.clamp(size.Y*.15,2.6,3.7),front),Color3.fromRGB(44,53,58),Enum.Material.Glass);door.Transparency=.18;storeCount+=1
   local transom=part('StoreTransom',Vector3.new(math.clamp(size.X*.19,3.8,6.8),1.05,.18),cf*CFrame.new(0,-size.Y/2+math.clamp(size.Y*.34,5.8,8.1),front-.02),Color3.fromRGB(118,148,158),Enum.Material.Glass);transom.Transparency=.22;storeCount+=1
   for _,x in ipairs({-size.X*.33,size.X*.33}) do
    if math.abs(x)<size.X/2-2 then
     local lamp=part('FacadeLamp',Vector3.new(.26,.54,.54),cf*CFrame.new(x,-size.Y/2+math.clamp(size.Y*.32,5.4,7.6),front-.3),Color3.fromRGB(255,220,152),Enum.Material.Neon,Enum.PartType.Ball);lamp.CastShadow=false;storeCount+=1
    end
   end
   local plinth=part('MaterialPlinth',Vector3.new(size.X*.88,.5,.48),cf*CFrame.new(0,-size.Y/2+.26,front+.08),accent,Enum.Material.Brick);storeCount+=1
  end
 end
end

-- Layered greenery: trunk + multiple crowns + ground shrubs, intentionally sparse.
local greenPoints={Vector3.new(-320,0,145),Vector3.new(-250,0,145),Vector3.new(-180,0,145),Vector3.new(335,0,195),Vector3.new(335,0,265),Vector3.new(-40,0,-455),Vector3.new(35,0,-455),Vector3.new(110,0,-455)}
for i,pos in ipairs(greenPoints) do
 cylinder('RealismTreeTrunk',7.8,.45,CFrame.new(pos+Vector3.new(0,3.9,0)),Color3.fromRGB(103,72,48),Enum.Material.Wood);greenCount+=1
 for j,offset in ipairs({Vector3.new(0,8,0),Vector3.new(-1.4,7.3,.5),Vector3.new(1.2,7.6,-.6)}) do
  local crown=part('LayeredTreeCrown',Vector3.new(4.8-j*.4,4.6-j*.3,4.8-j*.4),CFrame.new(pos+offset),Color3.fromRGB(54+8*j,118+6*j,65+5*j),Enum.Material.Grass,Enum.PartType.Ball);crown.CanQuery=false;greenCount+=1
 end
 for a=0,2 do
  local ang=a*math.pi*2/3
  local shrub=part('GroundShrub',Vector3.new(2.0,1.4,2.0),CFrame.new(pos+Vector3.new(math.cos(ang)*2.5,.7,math.sin(ang)*2.5)),Color3.fromRGB(58,128,69),Enum.Material.Grass,Enum.PartType.Ball);greenCount+=1
 end
end

Workspace:SetAttribute('ACC_BecakCityRealismSurface','v1.0')
Workspace:SetAttribute('BecakRealismLighting','ON')
Workspace:SetAttribute('BecakStreetSurfaceDetail','ON')
Workspace:SetAttribute('BecakStorefrontDepth','ON')
Workspace:SetAttribute('BecakVegetationLayering','ON')
Workspace:SetAttribute('BecakRealismRoadSurfaceCount',roadCount)
Workspace:SetAttribute('BecakRealismStreetFurnitureCount',streetFurnitureCount)
Workspace:SetAttribute('BecakRealismStoreDetailCount',storeCount)
Workspace:SetAttribute('BecakRealismGreenDetailCount',greenCount)
