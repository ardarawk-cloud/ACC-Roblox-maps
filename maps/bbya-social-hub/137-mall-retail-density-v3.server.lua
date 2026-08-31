-- BBYA SOCIAL HUB — MALL RETAIL DENSITY v3
-- Screenshot-driven retail completion pass.
-- Mall-only: denser front-of-store merchandising, warmer local visibility,
-- benches/planters and retail islands. No global Lighting/audio/router/economy writes.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60);if not root then return end
local mall=root:WaitForChild("BBYAMall",90);if not mall then return end
local galleryAuthority=mall:WaitForChild("MallPremiumGalleryV6",90);if not galleryAuthority then return end
task.wait(1)

local previous=mall:FindFirstChild("MallRetailDensityV3");if previous then previous:Destroy() end
local out=Instance.new("Model");out.Name="MallRetailDensityV3";out.Parent=mall
out:SetAttribute("Authority","MALL_RETAIL_DENSITY_V3")
out:SetAttribute("GlobalLightingUntouched",true)
out:SetAttribute("AudioUntouched",true)
out:SetAttribute("EconomyUntouched",true)

local C={dark=Color3.fromRGB(28,30,34),char=Color3.fromRGB(42,44,49),metal=Color3.fromRGB(96,99,105),white=Color3.fromRGB(238,238,235),gold=Color3.fromRGB(207,169,104),wood=Color3.fromRGB(112,82,60),leaf=Color3.fromRGB(64,101,72),stone=Color3.fromRGB(118,115,109),warm=Color3.fromRGB(255,229,199)}
local total=0
local function p(name,size,cf,color,mat,parent,collide,tr)
 local x=Instance.new("Part");x.Name=name;x.Size=size;x.CFrame=cf;x.Color=color or C.white;x.Material=mat or Enum.Material.SmoothPlastic;x.Anchored=true;x.CanCollide=collide==true;x.CanTouch=false;x.CanQuery=false;x.Transparency=tr or 0;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=parent or out;total+=1;return x
end
local function cyl(name,pos,h,d,color,parent,mat)
 local x=p(name,Vector3.new(h,d,d),CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90)),color,mat or Enum.Material.SmoothPlastic,parent,false,0);x.Shape=Enum.PartType.Cylinder;return x
end
local function ball(name,pos,d,color,parent)
 local x=p(name,Vector3.new(d,d,d),CFrame.new(pos),color,Enum.Material.SmoothPlastic,parent,false,0);x.Shape=Enum.PartType.Ball;return x
end
local function lightAt(parent,pos)
 local fixture=p("RetailLocalLight",Vector3.new(4,.08,1.2),CFrame.new(pos),C.warm,Enum.Material.Neon,parent,false,.42);fixture.CastShadow=false
 local l=Instance.new("PointLight");l.Color=C.warm;l.Brightness=.72;l.Range=15;l.Shadows=false;l.Parent=fixture
end
local function mannequin(parent,pos,accent,turn)
 p("MannequinTorso",Vector3.new(1.55,2.1,.75),CFrame.new(pos+Vector3.new(0,2.05,0))*CFrame.Angles(0,math.rad(turn or 0),0),accent,Enum.Material.Fabric,parent,false,0)
 ball("MannequinHead",pos+Vector3.new(0,3.65,0),.92,C.white,parent)
 p("MannequinLegL",Vector3.new(.52,1.8,.52),CFrame.new(pos+Vector3.new(-.38,.72,0)),C.dark,Enum.Material.Fabric,parent,false,0)
 p("MannequinLegR",Vector3.new(.52,1.8,.52),CFrame.new(pos+Vector3.new(.38,.72,0)),C.dark,Enum.Material.Fabric,parent,false,0)
end
local stores={
 Tenant_luma={"fashion",Color3.fromRGB(228,77,153)},Tenant_stride={"shoes",Color3.fromRGB(224,132,70)},Tenant_byte={"tech",Color3.fromRGB(69,181,203)},Tenant_daily={"market",Color3.fromRGB(78,170,116)},Tenant_mono={"home",Color3.fromRGB(202,165,98)},Tenant_muse={"beauty",Color3.fromRGB(151,94,205)},Tenant_north={"fashion",Color3.fromRGB(78,120,202)},Tenant_street={"fashion",Color3.fromRGB(194,77,77)},Tenant_page={"books",Color3.fromRGB(202,165,98)},Tenant_glow={"beauty",Color3.fromRGB(224,85,154)},Tenant_sound={"tech",Color3.fromRGB(63,183,207)},Tenant_fit={"sport",Color3.fromRGB(72,169,111)}
}
local dense=0
for name,spec in pairs(stores) do
 local unit=mall:FindFirstChild(name);local floor=unit and unit:FindFirstChild("Floor");local gallery=unit and unit:FindFirstChild("PremiumRetailGalleryV6")
 if floor and gallery then
  local old=gallery:FindFirstChild("DenseRetailStockV3");if old then old:Destroy() end
  local stock=Instance.new("Model");stock.Name="DenseRetailStockV3";stock.Parent=gallery
  local cx=floor.Position.X;local y=floor.Position.Y-.7;local z=floor.Position.Z;local inward=(cx<0) and 1 or -1;local accent=spec[2];local kind=spec[1]
  for _,n in ipairs({"ExteriorBack","ShortSideReturn","FeaturePanel"}) do for _,d in ipairs(gallery:GetChildren()) do if d.Name==n and d:IsA("BasePart") then d.Color=C.char end end end
  lightAt(stock,Vector3.new(cx+inward*7,y+9.8,z))
  -- Two front islands put merchandise close to the corridor instead of hiding it on rear walls.
  for island,zo in ipairs({-5.2,5.2}) do
   p("IslandBase"..island,Vector3.new(8,.5,3.3),CFrame.new(cx+inward*10,y+1.35,z+zo),C.wood,Enum.Material.WoodPlanks,stock,true,0)
   p("IslandTop"..island,Vector3.new(7.5,.18,3.0),CFrame.new(cx+inward*10,y+1.72,z+zo),accent,Enum.Material.Metal,stock,false,.14)
  end
  if kind=="fashion" or kind=="sport" then
   mannequin(stock,Vector3.new(cx+inward*15,y+1,z-5),accent,inward>0 and -20 or 20);mannequin(stock,Vector3.new(cx+inward*15,y+1,z+5),C.white,inward>0 and 20 or -20)
   for i=1,10 do local zo=-4.5+(i-1);p("FrontGarment"..i,Vector3.new(.72,1.8,.74),CFrame.new(cx+inward*8.2,y+3.1,z+zo),(i%3==0 and C.white) or (i%2==0 and accent) or C.dark,Enum.Material.Fabric,stock,false,0) end
   if kind=="sport" then for _,zo in ipairs({-5.2,5.2}) do ball("SportBall",Vector3.new(cx+inward*10,y+2.5,z+zo),1.25,accent,stock) end end
  elseif kind=="tech" then
   for island,zo in ipairs({-5.2,5.2}) do for i=1,5 do local dz=-1.15+(i-1)*.58;p("Device"..island.."_"..i,Vector3.new(.22,1.15,.54),CFrame.new(cx+inward*10,y+2.55,z+zo+dz),(i%2==0) and accent or C.white,Enum.Material.Metal,stock,false,0) end end
   for _,zo in ipairs({-5,5}) do p("HeroScreen",Vector3.new(.22,3.4,4.2),CFrame.new(cx+inward*16,y+4.4,z+zo),C.dark,Enum.Material.Metal,stock,false,0);p("HeroScreenGlow",Vector3.new(.08,2.7,3.5),CFrame.new(cx+inward*15.86,y+4.4,z+zo),accent,Enum.Material.Neon,stock,false,.22) end
  else
   for row=1,3 do for slot=1,7 do local zo=-4.4+(slot-1)*1.46;local yy=y+3.0+(row-1)*1.5;local col=(slot%3==0 and accent) or (slot%2==0 and C.gold) or C.white
    if kind=="beauty" or kind=="market" then cyl("WallItem"..row.."_"..slot,Vector3.new(cx+inward*16,yy,z+zo),.72,.34,col,stock) else p("WallItem"..row.."_"..slot,Vector3.new(.68,.58,.92),CFrame.new(cx+inward*16,yy,z+zo),col,kind=="home" and Enum.Material.Fabric or Enum.Material.SmoothPlastic,stock,false,0) end
   end end
   for island,zo in ipairs({-5.2,5.2}) do for i=1,5 do local dz=-1.05+(i-1)*.52;local col=(i%2==0 and accent) or C.white;if kind=="beauty" or kind=="market" then cyl("IslandItem"..island.."_"..i,Vector3.new(cx+inward*10,y+2.35,z+zo+dz),.58,.30,col,stock) else p("IslandItem"..island.."_"..i,Vector3.new(.58,.55,.65),CFrame.new(cx+inward*10,y+2.35,z+zo+dz),col,Enum.Material.SmoothPlastic,stock,false,0) end end end
  end
  unit:SetAttribute("MallRetailDensity","V3");dense+=1
 end
end

-- Corridor furniture breaks the long empty strips seen on mobile screenshots.
local furniture=Instance.new("Model");furniture.Name="MallRetailFurnitureV3";furniture.Parent=out
for _,levelY in ipairs({1,15}) do
 for _,z in ipairs({332,365,398}) do
  for _,x in ipairs({-39,39}) do
   p("Bench",Vector3.new(7,.75,2.4),CFrame.new(x,levelY+1.45,z),C.char,Enum.Material.Fabric,furniture,true,0)
   p("Planter",Vector3.new(3.2,1.3,3.2),CFrame.new(x+(x<0 and 6 or -6),levelY+1.15,z),C.dark,Enum.Material.Concrete,furniture,true,0)
   p("PlantStem",Vector3.new(.28,2.1,.28),CFrame.new(x+(x<0 and 6 or -6),levelY+2.45,z),C.wood,Enum.Material.Wood,furniture,false,0)
   ball("PlantTop",Vector3.new(x+(x<0 and 6 or -6),levelY+3.7,z),2.15,C.leaf,furniture)
  end
 end
end

-- Retail islands on L3 keep Food Hall/Cafe visible while removing dead floor.
local islands=Instance.new("Model");islands.Name="MallRetailIslandsV3";islands.Parent=out
for _,spec in ipairs({{-42,334,Color3.fromRGB(224,132,70)},{42,334,Color3.fromRGB(63,183,207)},{-42,398,Color3.fromRGB(194,77,77)},{42,398,Color3.fromRGB(78,170,116)}}) do
 local x,z,a=spec[1],spec[2],spec[3];p("RetailIslandBase",Vector3.new(12,.45,7),CFrame.new(x,30.15,z),C.char,Enum.Material.Metal,islands,true,0);p("RetailIslandCounter",Vector3.new(10,1.15,2.4),CFrame.new(x,31.05,z),C.wood,Enum.Material.WoodPlanks,islands,true,0)
 for i=1,7 do local xx=x-3.6+(i-1)*1.2;if i%2==0 then cyl("RetailIslandItem",Vector3.new(xx,31.95,z),.65,.34,(i%3==0) and C.white or a,islands) else p("RetailIslandItem",Vector3.new(.62,.68,.62),CFrame.new(xx,31.95,z),(i%3==0) and C.gold or a,Enum.Material.SmoothPlastic,islands,false,0) end end
end

mall:SetAttribute("MallRetailDensityAuthority","MALL_RETAIL_DENSITY_V3")
mall:SetAttribute("MallDenseRetailStores",dense)
out:SetAttribute("TotalNativeParts",total)
print(string.format("[BBYA] Mall Retail Density v3 online: %d stores / %d native parts",dense,total))
