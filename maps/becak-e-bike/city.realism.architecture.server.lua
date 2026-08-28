-- BECAK E-BIKE — NUSAKARYA WORLD V2 BASE REMESH v2.1
-- Replaces visible primitive building shells instead of stacking more micro-polish on top of blockout.
-- Original Body remains invisible as the proven collision proxy, preserving gameplay and road safety.
local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',30) if not root then return end
local world=root:WaitForChild('Nusakarya',30) if not world then return end
local old=world:FindFirstChild('CityRealismArchitecture') if old then old:Destroy() end
local folder=Instance.new('Folder');folder.Name='CityRealismArchitecture';folder.Parent=world

local function setup(p,color,material)
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true
 p.Color=color;p.Material=material or Enum.Material.Concrete;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=folder;return p
end
local function part(name,size,cf,color,material,shape)
 local p=setup(Instance.new('Part'),color,material);p.Name=name;p.Size=size;p.CFrame=cf;if shape then p.Shape=shape end;return p
end
local function wedge(name,size,cf,color,material)
 local p=setup(Instance.new('WedgePart'),color,material or Enum.Material.Metal);p.Name=name;p.Size=size;p.CFrame=cf;return p
end
local function shade(c,f)return Color3.new(math.clamp(c.R*f,0,1),math.clamp(c.G*f,0,1),math.clamp(c.B*f,0,1))end
local function classify(n)
 if n:match('^Rumah_') then return 'house' elseif n:match('^RukoPasar_') then return 'shop' elseif n=='Sekolah' then return 'school' elseif n=='RumahSakit' then return 'hospital' elseif n=='Mall' then return 'mall' elseif n=='Hotel' then return 'hotel' elseif n=='Terminal' then return 'terminal' elseif n=='Factory' then return 'industrial' end
end
local function window(cf,w,h)
 part('WindowFrame',Vector3.new(w+.32,h+.32,.20),cf,Color3.fromRGB(54,58,61),Enum.Material.Metal)
 local g=part('WindowGlass',Vector3.new(w,h,.23),cf*CFrame.new(0,0,-.03),Color3.fromRGB(78,119,137),Enum.Material.Glass);g.Transparency=.2
end

local remeshed,pieces=0,0
for _,model in ipairs(world:GetChildren()) do
 if model:IsA('Model') then
  local kind=classify(model.Name);local body=model:FindFirstChild('Body');local oldRoof=model:FindFirstChild('Roof')
  if kind and body and body:IsA('BasePart') then
   body.Transparency=1;body.CastShadow=false
   if oldRoof and oldRoof:IsA('BasePart') then oldRoof.Transparency=1;oldRoof.CanCollide=false;oldRoof.CastShadow=false end
   local s,cf=body.Size,body.CFrame;local wall=body.Color;local trim=shade(wall,.72);local roof=Color3.fromRGB(61,65,68)
   local side=(#model.Name%2==0) and 1 or -1
   part('V2_MainMass',Vector3.new(s.X*.78,s.Y*.84,s.Z*.68),cf*CFrame.new(-side*s.X*.05,-s.Y*.06,s.Z*.04),wall,Enum.Material.Concrete)
   part('V2_SideWing',Vector3.new(s.X*.30,s.Y*.58,s.Z*.48),cf*CFrame.new(side*s.X*.34,-s.Y*.19,s.Z*.10),shade(wall,.91),Enum.Material.Brick)
   pieces+=2
   local eh=math.clamp(s.Y*.26,5.5,8);local ew=math.clamp(s.X*.20,5,12)
   part('V2_Entrance',Vector3.new(ew,eh,2.1),cf*CFrame.new(-side*s.X*.16,-s.Y/2+eh/2,-s.Z*.36),shade(wall,.80),Enum.Material.Concrete)
   part('V2_Canopy',Vector3.new(ew+2,.35,3.4),cf*CFrame.new(-side*s.X*.16,-s.Y/2+eh+.35,-s.Z*.46),trim,Enum.Material.Metal);pieces+=2
   local rows=math.clamp(math.floor(s.Y/14),1,4);local cols=math.clamp(math.floor(s.X/20),2,5)
   for r=1,rows do
    local y=-s.Y/2+(r/(rows+1))*s.Y
    part('V2_FloorBand',Vector3.new(s.X*.76,.28,.30),cf*CFrame.new(-side*s.X*.05,y,-s.Z*.345),trim,Enum.Material.Concrete);pieces+=1
    for c=1,cols do
     local x=-side*s.X*.05+((c-(cols+1)/2)/cols)*s.X*.58
     window(cf*CFrame.new(x,y+1.25,-s.Z*.347),math.min(5.2,s.X/(cols*1.7)),3.3);pieces+=2
    end
   end
   local top=cf*CFrame.new(0,s.Y/2,0)
   if kind=='house' or kind=='shop' or kind=='school' then
    local hx=s.X*.40
    wedge('V2_RoofSlopeL',Vector3.new(hx,4.2,s.Z*.78),top*CFrame.new(-hx/2,1.8,0)*CFrame.Angles(0,math.rad(90),0),roof)
    wedge('V2_RoofSlopeR',Vector3.new(hx,4.2,s.Z*.78),top*CFrame.new(hx/2,1.8,0)*CFrame.Angles(0,math.rad(-90),0),roof);pieces+=2
   elseif kind=='mall' or kind=='hospital' or kind=='hotel' then
    part('V2_UpperSetback',Vector3.new(s.X*.54,5.5,s.Z*.50),top*CFrame.new(-side*s.X*.08,2.75,s.Z*.04),shade(wall,.86),Enum.Material.Concrete)
    part('V2_RoofPavilion',Vector3.new(s.X*.30,4,s.Z*.27),top*CFrame.new(side*s.X*.08,7.2,0),roof,Enum.Material.Metal);pieces+=2
   else
    part('V2_Parapet',Vector3.new(s.X*.70,2,s.Z*.60),top*CFrame.new(0,1,0),roof,Enum.Material.Metal);pieces+=1
   end
   if kind~='house' and kind~='industrial' then
    local radius=math.clamp(s.Z*.10,2.8,5)
    part('V2_CornerTower',Vector3.new(s.Y*.66,radius*2,radius*2),cf*CFrame.new(side*s.X*.36,-s.Y*.10,-s.Z*.29)*CFrame.Angles(0,0,math.rad(90)),shade(wall,.84),Enum.Material.Concrete,Enum.PartType.Cylinder)
    pieces+=1
   end
   for _,z in ipairs({-s.Z*.20,s.Z*.20}) do
    part('V2_SideFin',Vector3.new(.32,s.Y*.48,s.Z*.12),cf*CFrame.new(s.X*.40,0,z),trim,Enum.Material.Concrete)
    part('V2_SideFin',Vector3.new(.32,s.Y*.48,s.Z*.12),cf*CFrame.new(-s.X*.40,0,z),trim,Enum.Material.Concrete);pieces+=2
   end
   remeshed+=1
  end
 end
end

-- World V2 streetscape: lane edges, raised visual medians, drainage rhythm and compact corner islands.
local streets=Instance.new('Folder');streets.Name='WorldV2Streetscape';streets.Parent=folder
local function streetPart(name,size,cf,color,material,shape)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true;p.Color=color;p.Material=material or Enum.Material.Concrete;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;if shape then p.Shape=shape end;p.Parent=streets;return p
end
local asphalt=Color3.fromRGB(67,69,70);local curb=Color3.fromRGB(132,129,121);local paint=Color3.fromRGB(230,224,196)
for _,z in ipairs({-18.8,18.8}) do streetPart('V2_LaneEdge',Vector3.new(1080,.045,.18),CFrame.new(0,.52,z),paint,Enum.Material.SmoothPlastic) end
for _,x in ipairs({-18.8,18.8}) do streetPart('V2_LaneEdge',Vector3.new(.18,.045,1080),CFrame.new(x,.52,0),paint,Enum.Material.SmoothPlastic) end
for x=-480,480,32 do
 if math.abs(x)>48 then
  streetPart('V2_DrainSlot',Vector3.new(7,.055,.32),CFrame.new(x,.50,-20.2),Color3.fromRGB(48,50,51),Enum.Material.Metal)
  streetPart('V2_DrainSlot',Vector3.new(7,.055,.32),CFrame.new(x,.50,20.2),Color3.fromRGB(48,50,51),Enum.Material.Metal)
 end
end
for z=-480,480,32 do
 if math.abs(z)>48 then
  streetPart('V2_DrainSlot',Vector3.new(.32,.055,7),CFrame.new(-20.2,.50,z),Color3.fromRGB(48,50,51),Enum.Material.Metal)
  streetPart('V2_DrainSlot',Vector3.new(.32,.055,7),CFrame.new(20.2,.50,z),Color3.fromRGB(48,50,51),Enum.Material.Metal)
 end
end
for _,p0 in ipairs({Vector3.new(-42,.48,-42),Vector3.new(42,.48,-42),Vector3.new(-42,.48,42),Vector3.new(42,.48,42)}) do
 streetPart('V2_CornerIsland',Vector3.new(.18,8,8),CFrame.new(p0)*CFrame.Angles(0,0,math.rad(90)),curb,Enum.Material.Concrete,Enum.PartType.Cylinder)
 streetPart('V2_CornerIslandInset',Vector3.new(.20,6.2,6.2),CFrame.new(p0+Vector3.new(0,.10,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(82,105,72),Enum.Material.Grass,Enum.PartType.Cylinder)
end

-- Replace spherical tree dominance with trunk branching and layered leaf planes while keeping old tree collision irrelevant.
local vegetation=Instance.new('Folder');vegetation.Name='WorldV2Vegetation';vegetation.Parent=folder
local vegPieces=0
local function vegPart(name,size,cf,color,material,shape)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true;p.Color=color;p.Material=material or Enum.Material.Grass;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;if shape then p.Shape=shape end;p.Parent=vegetation;vegPieces+=1;return p
end
local details=world:FindFirstChild('CityDetails')
if details then
 for _,d in ipairs(details:GetChildren()) do
  if d:IsA('BasePart') and (d.Name=='TreeCrown' or d.Name=='TreeCrownLayer' or d.Name=='PalmCrown' or d.Name=='PalmFrond') then d.Transparency=1;d.CastShadow=false end
 end
 for _,trunk in ipairs(details:GetChildren()) do
  if trunk:IsA('BasePart') and trunk.Name=='TreeTrunk' then
   local base=trunk.Position+Vector3.new(0,trunk.Size.X*.42,0)
   for i=0,4 do
    local a=i*math.pi*2/5
    local branch=vegPart('V2_Branch',Vector3.new(4.8,.22,.22),CFrame.new(base+Vector3.new(math.cos(a)*1.3,1.4,math.sin(a)*1.3))*CFrame.Angles(0,-a,math.rad(-24)),Color3.fromRGB(93,66,43),Enum.Material.Wood)
    for j=1,2 do
     local dist=2.2+j*1.3
     local leafCf=CFrame.new(base+Vector3.new(math.cos(a)*dist,2.0+j*.35,math.sin(a)*dist))*CFrame.Angles(math.rad(-8+j*12),-a,math.rad((j==1 and -22 or 22)))
     vegPart('V2_LeafBlade',Vector3.new(5.4,.16,1.25),leafCf,Color3.fromRGB(52+j*6,121+j*8,66+j*4),Enum.Material.Grass)
    end
   end
   vegPart('V2_CrownCore',Vector3.new(5.6,4.2,5.6),CFrame.new(base+Vector3.new(0,2.4,0)),Color3.fromRGB(58,128,69),Enum.Material.Grass,Enum.PartType.Ball)
  elseif trunk:IsA('BasePart') and trunk.Name=='PalmTrunk' then
   local top=trunk.Position+Vector3.new(0,trunk.Size.X*.52,0)
   for i=0,7 do
    local a=i*math.pi/4
    vegPart('V2_PalmFrond',Vector3.new(8.4,.18,1.05),CFrame.new(top+Vector3.new(math.cos(a)*3.4,.35,math.sin(a)*3.4))*CFrame.Angles(0,-a,math.rad(-17)),Color3.fromRGB(48+(i%2)*6,124+(i%3)*5,66),Enum.Material.Grass)
   end
   vegPart('V2_PalmHeart',Vector3.new(2.5,1.8,2.5),CFrame.new(top+Vector3.new(0,.45,0)),Color3.fromRGB(57,137,73),Enum.Material.Grass,Enum.PartType.Ball)
  end
 end
end

-- Remesh ambient traffic after the traffic system spawns. Physics/AI uses only PrimaryPart position, so proportions are visual-only.
local trafficStyled=0
local function styleTraffic()
 local traffic=world:FindFirstChild('AmbientTraffic')
 if not traffic then return end
 for index,m in ipairs(traffic:GetChildren()) do
  if m:IsA('Model') and not m:GetAttribute('WorldV2VehicleStyled') then
   local body=m:FindFirstChild('Body');local roofOld=m:FindFirstChild('Roof')
   if body and body:IsA('BasePart') then
    m:SetAttribute('WorldV2VehicleStyled',true)
    body.Size=Vector3.new(5.15,1.05,6.7);body.CFrame=body.CFrame*CFrame.new(0,-.12,.15)
    if roofOld and roofOld:IsA('BasePart') then roofOld.Size=Vector3.new(4.25,.82,3.15);roofOld.CFrame=body.CFrame*CFrame.new(0,1.05,.25) end
    local color=body.Color;local dark=shade(color,.62);local cf=body.CFrame
    local hood=wedge('V2Traffic_Hood',Vector3.new(5.0,.72,2.15),cf*CFrame.new(0,.38,-3.15)*CFrame.Angles(0,math.rad(180),0),color,Enum.Material.Metal);hood.Parent=m
    local trunk=wedge('V2Traffic_Trunk',Vector3.new(4.9,.66,1.55),cf*CFrame.new(0,.34,3.15),shade(color,.92),Enum.Material.Metal);trunk.Parent=m
    local frontGlass=part('V2Traffic_Windscreen',Vector3.new(4.0,1.18,.14),cf*CFrame.new(0,1.42,-1.35)*CFrame.Angles(math.rad(-22),0,0),Color3.fromRGB(62,88,100),Enum.Material.Glass);frontGlass.Transparency=.18;frontGlass.Parent=m
    local rearGlass=part('V2Traffic_RearGlass',Vector3.new(3.75,1.0,.14),cf*CFrame.new(0,1.38,1.70)*CFrame.Angles(math.rad(20),0,0),Color3.fromRGB(62,88,100),Enum.Material.Glass);rearGlass.Transparency=.2;rearGlass.Parent=m
    for _,side in ipairs({-1,1}) do
     local rocker=part('V2Traffic_Rocker',Vector3.new(.20,.46,4.9),cf*CFrame.new(side*2.58,-.18,.35),dark,Enum.Material.Metal);rocker.Parent=m
     local mirror=part('V2Traffic_Mirror',Vector3.new(.32,.38,.62),cf*CFrame.new(side*2.65,1.2,-1.25),dark,Enum.Material.Metal,Enum.PartType.Ball);mirror.Parent=m
    end
    local bumper=part('V2Traffic_Bumper',Vector3.new(4.65,.34,.34),cf*CFrame.new(0,-.25,-3.55),Color3.fromRGB(48,50,52),Enum.Material.Metal);bumper.Parent=m
    local grille=part('V2Traffic_Grille',Vector3.new(2.25,.38,.12),cf*CFrame.new(0,.05,-3.73),Color3.fromRGB(38,40,42),Enum.Material.Metal);grille.Parent=m
    trafficStyled+=1
   end
  end
 end
end
for attempt=1,8 do task.delay(attempt*.75,styleTraffic) end

Workspace:SetAttribute('ACC_BecakCityRealismArchitecture','v1.0')
Workspace:SetAttribute('ACC_BecakCityRealismArchitectureEnhancement','v1.2')
Workspace:SetAttribute('BecakNonBoxBuildingSilhouette','ON')
Workspace:SetAttribute('BecakArchitecturalBayDepth','ON')
Workspace:SetAttribute('BecakArchitecturalRoofVariation','ON')
Workspace:SetAttribute('BecakArchitecturalArcades','ON')
Workspace:SetAttribute('ACC_BecakWorldV2Remesh','v2.1')
Workspace:SetAttribute('BecakWorldV2VisualReplacement','ON')
Workspace:SetAttribute('BecakWorldV2CollisionProxyPreserved','ON')
Workspace:SetAttribute('BecakWorldV2RemeshedBuildings',remeshed)
Workspace:SetAttribute('BecakWorldV2VisualPieces',pieces)
Workspace:SetAttribute('BecakWorldV2Streetscape','ON')
Workspace:SetAttribute('BecakWorldV2Vegetation','ON')
Workspace:SetAttribute('BecakWorldV2VegetationPieces',vegPieces)
Workspace:SetAttribute('BecakWorldV2TrafficRemesh','ON')
print('[BECAK E-BIKE] World V2 remesh v2.1',remeshed,'buildings',pieces,'building pieces',vegPieces,'vegetation pieces')
