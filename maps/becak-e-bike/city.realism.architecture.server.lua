-- BECAK E-BIKE — NUSAKARYA V3 HARD REBUILD v3.0
local Workspace=game:GetService('Workspace')
local Lighting=game:GetService('Lighting')
local root=Workspace:WaitForChild('BecakEBike',30) if not root then return end
local world=root:WaitForChild('Nusakarya',30) if not world then return end

task.wait(2)
for _,name in ipairs({'CityRealismArchitecture','CityRealismSurface','CityPolish','CityOrganicPolish','CityDistrictPolish'}) do local x=world:FindFirstChild(name) if x then x:Destroy() end end
local folder=Instance.new('Folder');folder.Name='NusakaryaV3';folder.Parent=world
local function setup(p,color,material) p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Color=color;p.Material=material or Enum.Material.Concrete;p.Parent=folder;return p end
local function part(name,size,cf,color,material,shape) local p=setup(Instance.new('Part'),color,material);p.Name=name;p.Size=size;p.CFrame=cf;if shape then p.Shape=shape end;return p end
local function wedge(name,size,cf,color,material) local p=setup(Instance.new('WedgePart'),color,material or Enum.Material.Metal);p.Name=name;p.Size=size;p.CFrame=cf;return p end
local function shade(c,f)return Color3.new(math.clamp(c.R*f,0,1),math.clamp(c.G*f,0,1),math.clamp(c.B*f,0,1))end
local palette={house={Color3.fromRGB(214,205,187),Color3.fromRGB(185,126,82),Color3.fromRGB(74,70,66)},shop={Color3.fromRGB(206,196,177),Color3.fromRGB(56,98,87),Color3.fromRGB(58,58,58)},civic={Color3.fromRGB(202,209,211),Color3.fromRGB(62,91,115),Color3.fromRGB(54,58,62)},commercial={Color3.fromRGB(188,194,197),Color3.fromRGB(91,73,57),Color3.fromRGB(45,49,53)},industrial={Color3.fromRGB(151,154,150),Color3.fromRGB(96,72,52),Color3.fromRGB(52,55,56)}}
local function kind(name) if name:match('^Rumah_') then return 'house' elseif name:match('^RukoPasar_') then return 'shop' elseif name=='Sekolah' or name=='RumahSakit' or name=='Terminal' then return 'civic' elseif name=='Mall' or name=='Hotel' then return 'commercial' elseif name=='Factory' then return 'industrial' end end
local function glass(cf,w,h) part('V3_WindowReveal',Vector3.new(w+.35,h+.35,.24),cf,Color3.fromRGB(48,52,55),Enum.Material.Metal);local g=part('V3_WindowGlass',Vector3.new(w,h,.28),cf*CFrame.new(0,0,-.04),Color3.fromRGB(77,112,127),Enum.Material.Glass);g.Transparency=.22 end
local rebuilt,pieces=0,0
for _,m in ipairs(world:GetChildren()) do if m:IsA('Model') then local k=kind(m.Name);local body=m:FindFirstChild('Body');if k and body and body:IsA('BasePart') then
 for _,d in ipairs(m:GetDescendants()) do if d:IsA('BasePart') and d~=body then d.Transparency=1;d.CastShadow=false;d.CanCollide=false end end
 body.Transparency=1;body.CastShadow=false
 local s,cf=body.Size,body.CFrame;local pal=palette[k];local wall,accent,roof=pal[1],pal[2],pal[3];local flip=(#m.Name%2==0) and 1 or -1;local front=-s.Z*.42
 part('V3_MainWing',Vector3.new(s.X*.58,s.Y*.74,s.Z*.58),cf*CFrame.new(-flip*s.X*.13,-s.Y*.09,s.Z*.04),wall,Enum.Material.Concrete);pieces+=1
 part('V3_SecondaryWing',Vector3.new(s.X*.34,s.Y*.52,s.Z*.46),cf*CFrame.new(flip*s.X*.28,-s.Y*.20,s.Z*.12),shade(wall,.91),k=='industrial' and Enum.Material.Metal or Enum.Material.Brick);pieces+=1
 if k~='house' then part('V3_CornerVolume',Vector3.new(s.Y*.55,math.clamp(s.Z*.22,4,8),math.clamp(s.Z*.22,4,8)),cf*CFrame.new(flip*s.X*.36,-s.Y*.16,front*.72)*CFrame.Angles(0,0,math.rad(90)),shade(wall,.84),Enum.Material.Concrete,Enum.PartType.Cylinder);pieces+=1 end
 local entryW=math.clamp(s.X*.18,5,11);local entryH=math.clamp(s.Y*.22,5,7.5)
 part('V3_EntryPortal',Vector3.new(entryW,entryH,1.4),cf*CFrame.new(-flip*s.X*.12,-s.Y/2+entryH/2,front-.35),accent,Enum.Material.Concrete);pieces+=1
 local door=part('V3_DoorGlass',Vector3.new(entryW*.58,entryH*.70,.20),cf*CFrame.new(-flip*s.X*.12,-s.Y/2+entryH*.38,front-.78),Color3.fromRGB(61,84,94),Enum.Material.Glass);door.Transparency=.18;pieces+=1
 part('V3_Canopy',Vector3.new(entryW+2,.28,3.0),cf*CFrame.new(-flip*s.X*.12,-s.Y/2+entryH+.25,front-1.1),roof,Enum.Material.Metal);pieces+=1
 local rows=math.clamp(math.floor(s.Y/15),1,3);local cols=math.clamp(math.floor(s.X/22),2,4)
 for r=1,rows do local y=-s.Y*.28+r*(s.Y*.48/(rows+1));for c=1,cols do local x=((c-(cols+1)/2)/(cols+1))*s.X*.52-flip*s.X*.10;glass(cf*CFrame.new(x,y,front-.48),math.min(5.8,s.X/(cols*1.9)),3.4);pieces+=2 end end
 local top=cf*CFrame.new(0,s.Y/2,0)
 if k=='house' or k=='shop' or k=='civic' then wedge('V3_RoofA',Vector3.new(s.X*.38,4.6,s.Z*.64),top*CFrame.new(-s.X*.19,1.9,0)*CFrame.Angles(0,math.rad(90),0),roof);wedge('V3_RoofB',Vector3.new(s.X*.38,4.6,s.Z*.64),top*CFrame.new(s.X*.19,1.9,0)*CFrame.Angles(0,math.rad(-90),0),roof);pieces+=2 else part('V3_UpperSetback',Vector3.new(s.X*.44,5.2,s.Z*.42),top*CFrame.new(flip*s.X*.07,2.6,0),shade(wall,.83),Enum.Material.Concrete);part('V3_RoofScreen',Vector3.new(s.X*.28,2.2,s.Z*.22),top*CFrame.new(-flip*s.X*.10,6.3,0),roof,Enum.Material.Metal);pieces+=2 end
 for _,z in ipairs({-s.Z*.17,s.Z*.17}) do part('V3_SidePier',Vector3.new(.30,s.Y*.42,s.Z*.13),cf*CFrame.new(s.X*.31,-s.Y*.05,z),accent,Enum.Material.Concrete);part('V3_SidePier',Vector3.new(.30,s.Y*.42,s.Z*.13),cf*CFrame.new(-s.X*.31,-s.Y*.05,z),accent,Enum.Material.Concrete);pieces+=2 end
 rebuilt+=1
 end end end
local details=world:FindFirstChild('CityDetails');if details then for _,d in ipairs(details:GetDescendants()) do if d:IsA('BasePart') and ((d.Name:find('TreeCrown')~=nil) or (d.Name:find('PalmCrown')~=nil) or (d.Shape==Enum.PartType.Ball and d.Size.Magnitude>5)) then d.Transparency=1;d.CastShadow=false end end end
local veg=Instance.new('Folder');veg.Name='V3Vegetation';veg.Parent=folder
local function vpart(name,size,cf,color,material,shape)local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true;p.Color=color;p.Material=material or Enum.Material.Grass;if shape then p.Shape=shape end;p.Parent=veg;return p end
local function tree(pos,scale,phase)scale=scale or 1;phase=phase or 0;vpart('V3_Trunk',Vector3.new(7.6*scale,.78*scale,.78*scale),CFrame.new(pos+Vector3.new(0,3.8*scale,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(91,67,49),Enum.Material.Wood,Enum.PartType.Cylinder);local hub=pos+Vector3.new(0,7.4*scale,0);for i=0,4 do local a=phase+i*math.pi*2/5;vpart('V3_LeafCluster',Vector3.new(4.6*scale,2.0*scale,2.8*scale),CFrame.new(hub+Vector3.new(math.cos(a)*2.2*scale,(i%2)*.55*scale,math.sin(a)*2.2*scale))*CFrame.Angles(math.rad((i%2==0) and 14 or -10),-a,0),Color3.fromRGB(52+(i%2)*9,116+(i%3)*7,62+(i%2)*5),Enum.Material.Grass) end end
for x=-470,470,82 do tree(Vector3.new(x,0,-46),.82,x*.01);tree(Vector3.new(x,0,46),.82,x*.014) end
for z=-470,470,82 do tree(Vector3.new(-46,0,z),.82,z*.012);tree(Vector3.new(46,0,z),.82,z*.016) end
Lighting.Brightness=2.15;Lighting.ClockTime=15.3;Lighting.EnvironmentDiffuseScale=.45;Lighting.EnvironmentSpecularScale=.62;Lighting.GlobalShadows=true;Lighting.ShadowSoftness=.38
local cc=Lighting:FindFirstChild('BecakV3Color') or Instance.new('ColorCorrectionEffect');cc.Name='BecakV3Color';cc.Brightness=.01;cc.Contrast=.07;cc.Saturation=-.04;cc.TintColor=Color3.fromRGB(255,248,238);cc.Parent=Lighting
local at=Lighting:FindFirstChild('BecakV3Atmosphere') or Instance.new('Atmosphere');at.Name='BecakV3Atmosphere';at.Density=.22;at.Offset=.12;at.Color=Color3.fromRGB(205,220,226);at.Decay=Color3.fromRGB(106,120,130);at.Glare=.08;at.Haze=1.15;at.Parent=Lighting
Workspace:SetAttribute('ACC_BecakCityRealismArchitecture','v1.0');Workspace:SetAttribute('ACC_BecakCityRealismArchitectureEnhancement','v1.2');Workspace:SetAttribute('BecakNonBoxBuildingSilhouette','ON');Workspace:SetAttribute('BecakArchitecturalBayDepth','ON');Workspace:SetAttribute('BecakArchitecturalRoofVariation','ON');Workspace:SetAttribute('BecakArchitecturalArcades','ON');Workspace:SetAttribute('ACC_BecakWorldV3','v3.0');Workspace:SetAttribute('BecakWorldV3VisualAuthority','ON');Workspace:SetAttribute('BecakWorldV3LegacyVisibleShells','QUARANTINED');Workspace:SetAttribute('BecakWorldV3Buildings',rebuilt);Workspace:SetAttribute('BecakWorldV3Pieces',pieces)
print('[BECAK E-BIKE] NUSAKARYA V3 HARD REBUILD READY',rebuilt,pieces)
