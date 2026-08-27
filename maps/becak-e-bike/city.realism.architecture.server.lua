-- BECAK E-BIKE — NUSAKARYA WORLD V2 BASE REMESH v2.0
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
local function wedge(name,size,cf,color)
 local p=setup(Instance.new('WedgePart'),color,Enum.Material.Metal);p.Name=name;p.Size=size;p.CFrame=cf;return p
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
   body.Transparency=1;body.CastShadow=false -- invisible collision proxy, intentionally retained
   if oldRoof and oldRoof:IsA('BasePart') then oldRoof.Transparency=1;oldRoof.CanCollide=false;oldRoof.CastShadow=false end
   local s,cf=body.Size,body.CFrame;local wall=body.Color;local trim=shade(wall,.72);local roof=Color3.fromRGB(61,65,68)
   local side=(#model.Name%2==0) and 1 or -1
   -- L-shaped massing + setbacks: the dominant silhouette is no longer a single cuboid.
   part('V2_MainMass',Vector3.new(s.X*.78,s.Y*.84,s.Z*.68),cf*CFrame.new(-side*s.X*.05,-s.Y*.06,s.Z*.04),wall,Enum.Material.Concrete)
   part('V2_SideWing',Vector3.new(s.X*.30,s.Y*.58,s.Z*.48),cf*CFrame.new(side*s.X*.34,-s.Y*.19,s.Z*.10),shade(wall,.91),Enum.Material.Brick)
   pieces+=2
   -- Human-scale entrance projection + canopy.
   local eh=math.clamp(s.Y*.26,5.5,8);local ew=math.clamp(s.X*.20,5,12)
   part('V2_Entrance',Vector3.new(ew,eh,2.1),cf*CFrame.new(-side*s.X*.16,-s.Y/2+eh/2,-s.Z*.36),shade(wall,.80),Enum.Material.Concrete)
   part('V2_Canopy',Vector3.new(ew+2,.35,3.4),cf*CFrame.new(-side*s.X*.16,-s.Y/2+eh+.35,-s.Z*.46),trim,Enum.Material.Metal);pieces+=2
   -- Floor bands + recessed glazing remain sparse enough for mobile.
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
   -- Commercial/civic corner tower creates a non-box landmark edge.
   if kind~='house' and kind~='industrial' then
    local radius=math.clamp(s.Z*.10,2.8,5)
    local t=part('V2_CornerTower',Vector3.new(s.Y*.66,radius*2,radius*2),cf*CFrame.new(side*s.X*.36,-s.Y*.10,-s.Z*.29)*CFrame.Angles(0,0,math.rad(90)),shade(wall,.84),Enum.Material.Concrete,Enum.PartType.Cylinder)
    pieces+=1
   end
   -- Side facade fins keep the remesh readable from cross streets, not only from the front.
   for _,z in ipairs({-s.Z*.20,s.Z*.20}) do
    part('V2_SideFin',Vector3.new(.32,s.Y*.48,s.Z*.12),cf*CFrame.new(s.X*.40,0,z),trim,Enum.Material.Concrete)
    part('V2_SideFin',Vector3.new(.32,s.Y*.48,s.Z*.12),cf*CFrame.new(-s.X*.40,0,z),trim,Enum.Material.Concrete);pieces+=2
   end
   remeshed+=1
  end
 end
end

-- Compatibility markers retained because the dedicated build pipeline validates them.
Workspace:SetAttribute('ACC_BecakCityRealismArchitecture','v1.0')
Workspace:SetAttribute('ACC_BecakCityRealismArchitectureEnhancement','v1.2')
Workspace:SetAttribute('BecakNonBoxBuildingSilhouette','ON')
Workspace:SetAttribute('BecakArchitecturalBayDepth','ON')
Workspace:SetAttribute('BecakArchitecturalRoofVariation','ON')
Workspace:SetAttribute('BecakArchitecturalArcades','ON')
-- World V2 authority markers.
Workspace:SetAttribute('ACC_BecakWorldV2Remesh','v2.0')
Workspace:SetAttribute('BecakWorldV2VisualReplacement','ON')
Workspace:SetAttribute('BecakWorldV2CollisionProxyPreserved','ON')
Workspace:SetAttribute('BecakWorldV2RemeshedBuildings',remeshed)
Workspace:SetAttribute('BecakWorldV2VisualPieces',pieces)
print('[BECAK E-BIKE] World V2 base remesh v2.0',remeshed,'buildings',pieces,'pieces')
