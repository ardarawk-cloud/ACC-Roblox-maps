-- BBYA SOCIAL HUB — PREMIUM PHASE 6 v4.6
-- Final venue language: consistent floor identity, circulation cues and non-blocking wayfinding.

local ROOT_NAME = "BBYA Premium Phase 6 v4.6"
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
 black=Color3.fromRGB(8,8,14),
 pink=Color3.fromRGB(255,45,170),
 cyan=Color3.fromRGB(48,228,255),
 gold=Color3.fromRGB(255,193,79),
 white=Color3.fromRGB(240,236,246),
 muted=Color3.fromRGB(145,139,157),
}

local function part(name,size,cf,color,material,transparency,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false
 p.Material=material or Enum.Material.Metal;p.Color=color or C.black;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root
 return p
end

local function sign(name,text,cf,size,color,sub)
 local p=part(name,size,cf,C.black,Enum.Material.Metal,0,root)
 local g=Instance.new("SurfaceGui")
 g.Face=Enum.NormalId.Front;g.LightInfluence=0;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=34;g.Parent=p
 local title=Instance.new("TextLabel")
 title.BackgroundTransparency=1;title.Position=UDim2.fromScale(.05,.08);title.Size=UDim2.fromScale(.9,sub and .58 or .84)
 title.Text=text;title.TextColor3=color or C.white;title.TextStrokeTransparency=.38;title.Font=Enum.Font.GothamBlack;title.TextScaled=true;title.TextWrapped=true;title.Parent=g
 if sub then
  local s=Instance.new("TextLabel")
  s.BackgroundTransparency=1;s.Position=UDim2.fromScale(.05,.67);s.Size=UDim2.fromScale(.9,.22)
  s.Text=sub;s.TextColor3=C.muted;s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.TextWrapped=true;s.Parent=g
 end
 return p
end

local function strip(name,cf,size,color)
 local p=part(name,size,cf,color,Enum.Material.Neon,0,root)
 p:SetAttribute("BBYADecorativeNeon",true)
 return p
end

-- Arrival / lobby hierarchy.
sign("WF Arrival Welcome","BBYA SOCIAL HUB",CFrame.new(0,16,80.4),Vector3.new(48,5,.35),C.pink,"WELCOME TO THE NIGHT")
sign("WF Lobby Directory","CLUB  ↑     VIP  ↗     ROOFTOP  ↖",CFrame.new(0,10.5,44.2),Vector3.new(48,3.5,.3),C.gold,"MUSIC • DANCE • SOCIAL")
strip("WF Lobby Guide",CFrame.new(0,2.6,48),Vector3.new(30,.08,.18),C.cyan)

-- Main club identifiers.
sign("WF Main Club","MAIN CLUB",CFrame.new(0,18,-37),Vector3.new(25,3,.3),C.white,"DANCE FLOOR • DJ • SOCIAL")
sign("WF West Services","BAR  ←     VIP  ↖",CFrame.new(-57,9,14),Vector3.new(22,3,.3),C.gold,"WEST WING")
sign("WF East Services","PHOTO  →     VIP  ↗",CFrame.new(57,9,14),Vector3.new(24,3,.3),C.cyan,"EAST WING")

-- VIP circulation.
sign("WF West VIP","WEST VIP",CFrame.new(-70,18,-17.3),Vector3.new(18,3,.3),C.cyan,"PRIVATE LOUNGE")
sign("WF East VIP","EAST VIP",CFrame.new(70,18,-17.3),Vector3.new(18,3,.3),C.pink,"PRIVATE LOUNGE")
sign("WF Queen","QUEEN SKYBOX",CFrame.new(0,34,2.3),Vector3.new(24,3.4,.3),C.gold,"PRIVATE VIEW")

-- Lift / stairs markers.
sign("WF Lift Main","SKY LIFT  →",CFrame.new(70,9,32),Vector3.new(18,3,.3),C.gold,"ROOFTOP ACCESS")
sign("WF Stairs West","ROOFTOP STAIRS",CFrame.new(-78,25,19.3),Vector3.new(20,3,.3),C.cyan,"LEVEL 2 ↑")
sign("WF Stairs East","ROOFTOP STAIRS",CFrame.new(78,25,19.3),Vector3.new(20,3,.3),C.pink,"LEVEL 2 ↑")

-- Rooftop zones.
sign("WF Rooftop Hero","BBYA ROOFTOP",CFrame.new(0,52,30.8),Vector3.new(34,4,.35),C.pink,"POOL PARTY • SKY BAR • CITY VIEW")
sign("WF Pool","INFINITY POOL",CFrame.new(0,45,-43),Vector3.new(24,3,.3),C.cyan,"POOL PARTY ZONE")
sign("WF Sky Bar","SKY BAR",CFrame.new(-62,49,25.2),Vector3.new(18,3,.3),C.gold,"SOCIAL LOUNGE")
sign("WF City View","CITY VIEW  →",CFrame.new(68,45,45),Vector3.new(18,3,.3),C.white,"PHOTO • CHILL")

-- Low-profile floor direction strips. No collision and few parts.
for _,cfg in ipairs({
 {Vector3.new(0,1.78,31),Vector3.new(22,.08,.18),C.pink},
 {Vector3.new(-43,1.78,23),Vector3.new(16,.08,.18),C.cyan},
 {Vector3.new(43,1.78,23),Vector3.new(16,.08,.18),C.pink},
 {Vector3.new(0,38.3,19),Vector3.new(24,.08,.18),C.gold},
}) do
 strip("WF Floor Guide",CFrame.new(cfg[1]),cfg[2],cfg[3])
end

workspace:SetAttribute("BBYAPremiumPhase6","4.6")
workspace:SetAttribute("BBYAWayfindingReady",true)
print("[BBYA] Premium Phase 6 v4.6 wayfinding loaded")
