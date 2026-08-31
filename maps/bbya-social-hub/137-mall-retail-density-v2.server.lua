-- BBYA SOCIAL HUB — MALL RETAIL DENSITY v2
-- Screenshot-driven product density pass. Mall-only native geometry.
-- Does not touch global Lighting, audio/router, VIP, fishing or monetization.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60);if not root then return end
local mall=root:WaitForChild("BBYAMall",90);if not mall then return end
if not mall:WaitForChild("MallPremiumGalleryV6",90) then return end
task.wait(.8)
local old=mall:FindFirstChild("MallRetailDensityV2");if old then old:Destroy() end
local out=Instance.new("Model");out.Name="MallRetailDensityV2";out.Parent=mall
out:SetAttribute("Authority","MALL_RETAIL_DENSITY_V2")
out:SetAttribute("GlobalLightingUntouched",true);out:SetAttribute("AudioUntouched",true)
local C={dark=Color3.fromRGB(22,23,26),metal=Color3.fromRGB(92,95,101),white=Color3.fromRGB(239,239,236),gold=Color3.fromRGB(220,184,122)}
local total=0
local function p(name,size,cf,color,mat,parent,collide,trans)
 local x=Instance.new("Part");x.Name=name;x.Size=size;x.CFrame=cf;x.Color=color or C.white;x.Material=mat or Enum.Material.SmoothPlastic;x.Anchored=true;x.CanCollide=collide==true;x.CanTouch=false;x.CanQuery=false;x.Transparency=trans or 0;x.Parent=parent or out;total+=1;return x
end
local function cyl(name,pos,h,d,color,parent)
 local x=p(name,Vector3.new(h,d,d),CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90)),color,Enum.Material.SmoothPlastic,parent,false,0);x.Shape=Enum.PartType.Cylinder;return x
end
local stores={
 Tenant_luma={"fashion",Color3.fromRGB(228,77,153)},Tenant_stride={"shoes",Color3.fromRGB(224,132,70)},Tenant_byte={"tech",Color3.fromRGB(69,181,203)},Tenant_daily={"market",Color3.fromRGB(78,170,116)},Tenant_mono={"home",Color3.fromRGB(202,165,98)},Tenant_muse={"beauty",Color3.fromRGB(151,94,205)},Tenant_north={"fashion",Color3.fromRGB(78,120,202)},Tenant_street={"fashion",Color3.fromRGB(194,77,77)},Tenant_page={"books",Color3.fromRGB(202,165,98)},Tenant_glow={"beauty",Color3.fromRGB(224,85,154)},Tenant_sound={"tech",Color3.fromRGB(63,183,207)},Tenant_fit={"sport",Color3.fromRGB(72,169,111)}
}
local dense=0
for name,spec in pairs(stores) do
 local unit=mall:FindFirstChild(name);local floor=unit and unit:FindFirstChild("Floor");local gallery=unit and unit:FindFirstChild("PremiumRetailGalleryV6")
 if floor and gallery then
  local prior=gallery:FindFirstChild("DenseRetailStockV2");if prior then prior:Destroy() end
  local stock=Instance.new("Model");stock.Name="DenseRetailStockV2";stock.Parent=gallery
  local cx=floor.Position.X;local y=floor.Position.Y-.7;local z=floor.Position.Z;local inward=(cx<0) and 1 or -1;local outer=cx-inward*(floor.Size.X/2-.38);local accent=spec[2];local kind=spec[1]
  if kind=="fashion" or kind=="sport" then
   for i=1,12 do local zo=-5.2+(i-1)*.95;local col=(i%3==0 and C.white) or (i%2==0 and accent) or C.dark;p("Garment"..i,Vector3.new(.65,1.8,.72),CFrame.new(outer+inward*3.45,y+4.0,z+zo),col,Enum.Material.Fabric,stock,false,0) end
  elseif kind=="shoes" or kind=="books" or kind=="market" or kind=="home" then
   for row=1,3 do for slot=1,8 do local zo=-4.8+(slot-1)*1.38;local yy=y+4.2+(row-1)*1.55;local col=(slot%3==0 and accent) or (slot%2==0 and C.gold) or C.white
    if kind=="market" or (kind=="home" and slot%2==0) then cyl("Stock"..row.."_"..slot,Vector3.new(outer+inward*2.05,yy+.25,z+zo),.65,.36,col,stock) else p("Stock"..row.."_"..slot,Vector3.new(.62,.62,.82),CFrame.new(outer+inward*2.05,yy+.25,z+zo),col,kind=="home" and Enum.Material.Fabric or Enum.Material.SmoothPlastic,stock,false,0) end
   end end
  elseif kind=="beauty" then
   for row=1,3 do for slot=1,8 do local zo=-4.8+(slot-1)*1.38;local yy=y+3.2+(row-1)*1.65;cyl("Beauty"..row.."_"..slot,Vector3.new(outer+inward*2.1,yy,z+zo),.72,.30,(slot%2==0) and accent or C.white,stock) end end
  elseif kind=="tech" then
   for tableIndex,zo in ipairs({-6,0,6}) do p("TechTable"..tableIndex,Vector3.new(5,.24,3),CFrame.new(cx+inward*3,y+2.05,z+zo),C.dark,Enum.Material.Metal,stock,false,0);for d=1,4 do local dz=-1.05+(d-1)*.7;p("Device"..tableIndex.."_"..d,Vector3.new(.20,.9,.5),CFrame.new(cx+inward*3,y+2.62,z+zo+dz),d%2==0 and accent or C.white,Enum.Material.Metal,stock,false,0) end end
  end
  unit:SetAttribute("MallRetailDensity","V2");dense+=1
 end
end
local function kiosk(name,y,z,accent)
 local m=Instance.new("Model");m.Name=name;m.Parent=out;p("Deck",Vector3.new(13,.35,8),CFrame.new(0,y+.85,z),C.dark,Enum.Material.Metal,m,true,0);p("Counter",Vector3.new(11,1.1,2),CFrame.new(0,y+1.75,z),C.dark,Enum.Material.Metal,m,true,0);p("Canopy",Vector3.new(11,.2,4.5),CFrame.new(0,y+5.5,z),C.dark,Enum.Material.Metal,m,false,0)
 for _,x in ipairs({-5,5}) do p("Post",Vector3.new(.28,4.5,.28),CFrame.new(x,y+3.25,z),C.metal,Enum.Material.Metal,m,false,0) end
 for i=1,9 do local xx=-4.4+(i-1)*1.1;local col=(i%3==0 and C.white) or (i%2==0 and accent) or C.gold;if i%2==0 then cyl("Item"..i,Vector3.new(xx,y+2.55,z),.68,.34,col,m) else p("Item"..i,Vector3.new(.62,.68,.62),CFrame.new(xx,y+2.55,z),col,Enum.Material.SmoothPlastic,m,false,0) end end
end
local kiosks=0
for _,y in ipairs({1,15,29}) do kiosk("SouthPopUp"..y,y,316,Color3.fromRGB(228,77,153));kiosk("NorthPopUp"..y,y,414,Color3.fromRGB(63,183,207));kiosks+=2 end
for i,z in ipairs({352,364,376,388}) do local a=({Color3.fromRGB(224,132,70),Color3.fromRGB(78,170,116),Color3.fromRGB(194,77,77),Color3.fromRGB(63,183,207)})[i];p("FoodDisplay"..i,Vector3.new(.35,3.4,7),CFrame.new(-72.3,35.0,z),a,Enum.Material.Metal,out,false,0);for n=1,5 do cyl("FoodItem"..i.."_"..n,Vector3.new(-71.8,31.9,z-2.2+(n-1)*1.1),.62,.34,n%2==0 and C.white or a,out) end end
for i=1,10 do p("CafeStock"..i,Vector3.new(.55,.75,.55),CFrame.new(43.8,32.1,352.5+(i-1)*.75),(i%2==0) and C.gold or C.white,Enum.Material.SmoothPlastic,out,false,0) end
mall:SetAttribute("MallRetailDensityAuthority","MALL_RETAIL_DENSITY_V2");mall:SetAttribute("MallDenseRetailStores",dense);mall:SetAttribute("MallRetailPopUpKiosks",kiosks);out:SetAttribute("TotalNativeParts",total)
print(string.format("[BBYA] Mall Retail Density v2 online: %d stores / %d kiosks / %d native parts",dense,kiosks,total))
