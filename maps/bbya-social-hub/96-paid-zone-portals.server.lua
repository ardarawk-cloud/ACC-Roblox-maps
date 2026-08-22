-- BBYA SOCIAL HUB — PAID ZONE PORTALS v1
-- Visible premium portal matching the hard collision boundary for Funkot Club.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",35)
if not root then return end
local old=root:FindFirstChild("PaidZonePortalsV1");if old then old:Destroy() end
local m=Instance.new("Model");m.Name="PaidZonePortalsV1";m.Parent=root
m:SetAttribute("FunkotTravelOnly",true);m:SetAttribute("FunkotPrice",10)
local C={black=Color3.fromRGB(9,9,12),metal=Color3.fromRGB(63,67,74),glass=Color3.fromRGB(77,93,105),pink=Color3.fromRGB(235,42,156),cyan=Color3.fromRGB(30,184,214),white=Color3.fromRGB(242,242,245),muted=Color3.fromRGB(171,172,180)}
local function p(n,s,cf,c,mat,collide,tr)
 local x=Instance.new("Part");x.Name=n;x.Size=s;x.CFrame=cf;x.Color=c or C.metal;x.Material=mat or Enum.Material.Metal;x.Anchored=true;x.CanCollide=collide==true;x.CanTouch=false;x.Transparency=tr or 0;x.Parent=m;return x
end
local left=p("FunkotPortalL",Vector3.new(1.1,15,2),CFrame.new(-11.4,7.5,157.1),C.metal,Enum.Material.Metal,true)
local right=p("FunkotPortalR",Vector3.new(1.1,15,2),CFrame.new(11.4,7.5,157.1),C.metal,Enum.Material.Metal,true)
p("FunkotPortalTop",Vector3.new(23.9,1.1,2),CFrame.new(0,14.45,157.1),C.metal,Enum.Material.Metal,true)
local glass=p("FunkotPortalGlass",Vector3.new(21.8,13.2,1.0),CFrame.new(0,6.7,157.1),C.glass,Enum.Material.Glass,true,.30);glass.Reflectance=.08
for x=-9,9,3 do p("FunkotSlat"..x,Vector3.new(.20,12.0,1.14),CFrame.new(x,6.7,156.9),C.black,Enum.Material.Metal,false) end
local sign=p("FunkotTravelSign",Vector3.new(19,3.4,.34),CFrame.new(0,11.2,156.35)*CFrame.Angles(0,math.rad(180),0),C.black,Enum.Material.Metal,false)
local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.PixelsPerStud=70;gui.LightInfluence=.08;gui.Parent=sign
local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromScale(.06,.08);title.Size=UDim2.fromScale(.88,.55);title.Text="FUNKOT CLUB";title.TextColor3=C.white;title.Font=Enum.Font.GothamBlack;title.TextScaled=true;title.Parent=gui
local sub=Instance.new("TextLabel");sub.BackgroundTransparency=1;sub.Position=UDim2.fromScale(.08,.66);sub.Size=UDim2.fromScale(.84,.19);sub.Text="TRAVEL ACCESS • 10 R$";sub.TextColor3=C.pink;sub.Font=Enum.Font.GothamBold;sub.TextScaled=true;sub.Parent=gui
for _,x in ipairs({-7,7}) do
 local lamp=p("PortalLamp"..x,Vector3.new(.35,.35,.35),CFrame.new(x,13.2,156.4),C.black,Enum.Material.SmoothPlastic,false,1)
 local l=Instance.new("PointLight");l.Color=(x<0) and C.pink or C.cyan;l.Brightness=.65;l.Range=11;l.Shadows=false;l.Parent=lamp
end
print("[BBYA] Paid Zone Portals v1 online: Funkot physical entry locked / Travel 10R")
