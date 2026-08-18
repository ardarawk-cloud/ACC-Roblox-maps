-- BBYA SALON UPGRADE v2.0
-- Adds a real accessory station: party hat, cyber mask, neon shades, antenna, halo and crown.

local Players=game:GetService("Players")
task.wait(4)

local old=workspace:FindFirstChild("BBYA Salon Upgrade v2")
if old then old:Destroy() end
local root=Instance.new("Folder")
root.Name="BBYA Salon Upgrade v2"
root.Parent=workspace

local counter=workspace:FindFirstChild("BBYA Salon Counter",true)
if not counter or not counter:IsA("BasePart") then
 warn("[BBYA SALON] Counter not found")
 return
end

local PINK=Color3.fromRGB(255,70,210)
local CYAN=Color3.fromRGB(55,220,255)
local GOLD=Color3.fromRGB(255,205,80)
local PURPLE=Color3.fromRGB(155,70,255)
local WHITE=Color3.fromRGB(245,240,255)
local BLACK=Color3.fromRGB(18,12,25)

local function part(name,size,cf,color,material,transparency,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false
 p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or WHITE;p.Transparency=transparency or 0
 p.Parent=parent or root
 return p
end

local function label(p,text,color)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=28;g.LightInfluence=0;g.AlwaysOnTop=true;g.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color or WHITE;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextStrokeTransparency=.25;t.Parent=g
 return t
end

-- Build display strip relative to the salon counter so it follows future salon moves.
local base=counter.CFrame
local displayBack=part("Salon Accessory Display",Vector3.new(14,5,.35),base*CFrame.new(0,4.2,-3.3),BLACK,Enum.Material.SmoothPlastic,0,root)
label(displayBack,"ACCESSORY BAR",PINK)

local styles={"PARTY HAT","CYBER MASK","NEON SHADES","HEART ANTENNA","HALO","CROWN"}
for i,name in ipairs(styles) do
 local x=-5.4+(i-1)*2.15
 local pad=part("Salon Display "..name,Vector3.new(1.7,.28,1.7),base*CFrame.new(x,2.25,-2.7),i%2==0 and CYAN or PINK,Enum.Material.Neon,.12,root)
 local tag=part("Salon Tag "..name,Vector3.new(1.9,.65,.18),base*CFrame.new(x,3.1,-3.08),BLACK,Enum.Material.SmoothPlastic,0,root)
 label(tag,name,i%2==0 and CYAN or PINK)
end

local function clearLook(char)
 local prior=char and char:FindFirstChild("BBYA Salon Accessory")
 if prior then prior:Destroy() end
 local legacy=char and char:FindFirstChild("BBYA Salon Look")
 if legacy then legacy:Destroy() end
end

local function weldPart(model,head,name,size,offset,color,shape,material)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.Color=color;p.Material=material or Enum.Material.Neon;p.CanCollide=false;p.Massless=true
 if shape then p.Shape=shape end
 p.CFrame=head.CFrame*offset;p.Parent=model
 local w=Instance.new("WeldConstraint");w.Part0=head;w.Part1=p;w.Parent=p
 return p
end

local function newAccessory(char)
 clearLook(char)
 local head=char:FindFirstChild("Head")
 if not head then return nil,nil end
 local model=Instance.new("Model");model.Name="BBYA Salon Accessory";model.Parent=char
 return model,head
end

local apply={}

apply[1]=function(char) -- Party hat: stacked neon tiers + pom
 local m,h=newAccessory(char);if not m then return end
 weldPart(m,h,"PartyHatBase",Vector3.new(2.8,.35,2.8),CFrame.new(0,1.25,0),PINK,Enum.PartType.Cylinder)
 weldPart(m,h,"PartyHatMid",Vector3.new(2.0,.55,2.0),CFrame.new(0,1.7,0),PURPLE,Enum.PartType.Cylinder)
 weldPart(m,h,"PartyHatTop",Vector3.new(1.1,.7,1.1),CFrame.new(0,2.25,0),CYAN,Enum.PartType.Cylinder)
 weldPart(m,h,"PartyPom",Vector3.new(.55,.55,.55),CFrame.new(0,2.85,0),GOLD,Enum.PartType.Ball)
end

apply[2]=function(char) -- Cyber mask
 local m,h=newAccessory(char);if not m then return end
 weldPart(m,h,"MaskPlate",Vector3.new(2.3,1.25,.28),CFrame.new(0,-.05,-.58),Color3.fromRGB(30,25,40),nil,Enum.Material.Metal)
 weldPart(m,h,"MaskGlow",Vector3.new(1.65,.16,.12),CFrame.new(0,.08,-.76),CYAN)
 weldPart(m,h,"MaskSideL",Vector3.new(.18,.55,.18),CFrame.new(-.88,-.05,-.75),PINK)
 weldPart(m,h,"MaskSideR",Vector3.new(.18,.55,.18),CFrame.new(.88,-.05,-.75),PINK)
end

apply[3]=function(char) -- Neon shades
 local m,h=newAccessory(char);if not m then return end
 weldPart(m,h,"ShadeL",Vector3.new(.78,.5,.12),CFrame.new(-.48,.18,-.64),PINK)
 weldPart(m,h,"ShadeR",Vector3.new(.78,.5,.12),CFrame.new(.48,.18,-.64),CYAN)
 weldPart(m,h,"ShadeBridge",Vector3.new(.28,.12,.12),CFrame.new(0,.18,-.65),GOLD)
end

apply[4]=function(char) -- Heart/party antenna approximation
 local m,h=newAccessory(char);if not m then return end
 weldPart(m,h,"AntennaBand",Vector3.new(2.7,.18,.4),CFrame.new(0,1.05,0),PURPLE)
 weldPart(m,h,"AntennaL",Vector3.new(.16,1.6,.16),CFrame.new(-.65,1.75,0),PINK)
 weldPart(m,h,"AntennaR",Vector3.new(.16,1.6,.16),CFrame.new(.65,1.75,0),CYAN)
 weldPart(m,h,"AntennaBallL",Vector3.new(.55,.55,.55),CFrame.new(-.65,2.55,0),PINK,Enum.PartType.Ball)
 weldPart(m,h,"AntennaBallR",Vector3.new(.55,.55,.55),CFrame.new(.65,2.55,0),CYAN,Enum.PartType.Ball)
end

apply[5]=function(char) -- Halo
 local m,h=newAccessory(char);if not m then return end
 local ring=weldPart(m,h,"Halo",Vector3.new(.28,3.9,3.9),CFrame.new(0,1.75,0)*CFrame.Angles(0,0,math.rad(90)),PINK,Enum.PartType.Cylinder)
 ring.Transparency=.05
end

apply[6]=function(char) -- Crown approximation
 local m,h=newAccessory(char);if not m then return end
 weldPart(m,h,"CrownBand",Vector3.new(2.8,.35,2.8),CFrame.new(0,1.25,0),GOLD,Enum.PartType.Cylinder)
 for i=-2,2 do
  weldPart(m,h,"CrownSpike"..i,Vector3.new(.34,.9,.34),CFrame.new(i*.48,1.85,0),i%2==0 and GOLD or PINK)
 end
end

-- Main selector kiosk beside the counter.
local kiosk=part("Salon Accessory Selector",Vector3.new(3.2,3.6,3.2),base*CFrame.new(8.3,.3,-.4),BLACK,Enum.Material.Marble,0,root)
local top=part("Salon Accessory Selector Glow",Vector3.new(3.25,.18,3.25),kiosk.CFrame*CFrame.new(0,1.9,0),PINK,Enum.Material.Neon,0,root)
local kioskSign=part("Salon Accessory Selector Sign",Vector3.new(3.1,1.2,.2),kiosk.CFrame*CFrame.new(0,.7,-1.7),BLACK,Enum.Material.SmoothPlastic,0,root)
label(kioskSign,"TRY LOOK",CYAN)
local pr=Instance.new("ProximityPrompt");pr.ActionText="NEXT STYLE";pr.ObjectText="BBYA SALON";pr.HoldDuration=.1;pr.MaxActivationDistance=10;pr.RequiresLineOfSight=false;pr.Parent=kiosk

local index={}
pr.Triggered:Connect(function(plr)
 local char=plr.Character;if not char then return end
 local i=(index[plr.UserId] or 0)%#styles+1
 index[plr.UserId]=i
 apply[i](char)
 plr:SetAttribute("BBYASalonLook",styles[i])
 pr.ObjectText="BBYA SALON • "..styles[i]
end)

local reset=part("Salon Upgrade Reset",Vector3.new(3,.22,3),base*CFrame.new(8.3,-1.35,4),Color3.fromRGB(90,45,110),Enum.Material.Neon,.15,root)
local rp=Instance.new("ProximityPrompt");rp.ActionText="REMOVE";rp.ObjectText="SALON ACCESSORY";rp.HoldDuration=.1;rp.MaxActivationDistance=10;rp.RequiresLineOfSight=false;rp.Parent=reset
rp.Triggered:Connect(function(plr)
 clearLook(plr.Character)
 plr:SetAttribute("BBYASalonLook","")
end)

print("[BBYA] Salon Upgrade v2 loaded: party hat, cyber mask, neon shades, antenna, halo, crown")