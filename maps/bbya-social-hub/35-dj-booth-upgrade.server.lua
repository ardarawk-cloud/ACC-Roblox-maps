local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("DJBoothUpgrade");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="DJBoothUpgrade"
local C={black=Color3.fromRGB(16,16,20),metal=Color3.fromRGB(49,50,58),pink=Color3.fromRGB(255,42,157),cyan=Color3.fromRGB(0,190,255),white=Color3.fromRGB(230,230,235),skin=Color3.fromRGB(222,190,160),shirt=Color3.fromRGB(24,24,30),pants=Color3.fromRGB(15,15,19),hair=Color3.fromRGB(28,20,20)}
local function part(n,s,cf,col,mat,shape,parent)local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.CanCollide=false;p.Size=s;p.CFrame=cf;p.Color=col;p.Material=mat or Enum.Material.SmoothPlastic;if shape then p.Shape=shape end;p.Parent=parent or m;return p end
local function neon(n,s,cf,col,parent)local p=part(n,s,cf,col,Enum.Material.Neon,nil,parent);return p end
local deck=Instance.new("Model",m);deck.Name="PremiumDJEquipment"
-- twin club decks
for _,x in ipairs({-5.2,5.2}) do
 local base=part("DeckBase",Vector3.new(5.2,.65,3.6),CFrame.new(x,5.1,30.1),C.black,Enum.Material.Metal,nil,deck)
 part("DeckTop",Vector3.new(4.8,.25,3.2),CFrame.new(x,5.55,30.1),C.metal,Enum.Material.Metal,nil,deck)
 local platter=part("Platter",Vector3.new(2.5,.18,2.5),CFrame.new(x,5.78,30.1),C.black,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder,deck);platter.CFrame=platter.CFrame*CFrame.Angles(0,0,math.rad(90))
 neon("DeckRing",Vector3.new(2.8,.08,2.8),CFrame.new(x,5.88,30.1),x<0 and C.cyan or C.pink,deck).Transparency=.08
 for i=-1,1 do neon("DeckButton",Vector3.new(.22,.08,.22),CFrame.new(x+1.65,5.92,29.6+i*.45),i==0 and C.pink or C.cyan,deck) end
end
-- central mixer
part("MixerBase",Vector3.new(4,.7,3.8),CFrame.new(0,5.1,30.1),C.black,Enum.Material.Metal,nil,deck)
part("MixerTop",Vector3.new(3.6,.22,3.4),CFrame.new(0,5.56,30.1),C.metal,Enum.Material.Metal,nil,deck)
for i=-2,2 do part("Fader"..i,Vector3.new(.12,.12,1.3),CFrame.new(i*.48,5.76,30.25),C.white,Enum.Material.SmoothPlastic,nil,deck) end
for i=-1,1 do neon("MixerPad"..i,Vector3.new(.32,.08,.32),CFrame.new(i*.7,5.86,29.25),i==0 and C.pink or C.cyan,deck) end
-- angled laptop/display
part("LaptopBase",Vector3.new(3.8,.18,2.2),CFrame.new(0,5.8,31.55),C.black,Enum.Material.Metal,nil,deck)
local screen=part("LaptopScreen",Vector3.new(3.8,2.4,.18),CFrame.new(0,7.05,32.35)*CFrame.Angles(math.rad(-10),0,0),C.black,Enum.Material.SmoothPlastic,nil,deck)
neon("LaptopGlow",Vector3.new(3.45,2.05,.05),screen.CFrame*CFrame.new(0,0,-.12),C.cyan,deck).Transparency=.45
-- headphones on booth
local band=part("HeadphoneBand",Vector3.new(2.2,.22,.22),CFrame.new(-2.9,6.05,32),C.black,Enum.Material.Metal,nil,deck)
part("HeadphoneL",Vector3.new(.5,.7,.35),CFrame.new(-3.8,5.8,32),C.black,Enum.Material.Metal,nil,deck)
part("HeadphoneR",Vector3.new(.5,.7,.35),CFrame.new(-2,5.8,32),C.black,Enum.Material.Metal,nil,deck)
-- NPC DJ, stylized human proportions with curved head instead of block stack
local npc=Instance.new("Model",m);npc.Name="ResidentDJ"
local function body(n,s,cf,col,shape)local p=part(n,s,cf,col,Enum.Material.SmoothPlastic,shape,npc);return p end
body("Torso",Vector3.new(3.4,4.2,1.7),CFrame.new(0,8.15,34.1)*CFrame.Angles(math.rad(-4),0,0),C.shirt)
body("Waist",Vector3.new(2.7,1.3,1.5),CFrame.new(0,5.55,34.05),C.pants)
body("Head",Vector3.new(2.15,2.15,2.15),CFrame.new(0,11.25,33.9),C.skin,Enum.PartType.Ball)
body("Hair",Vector3.new(2.25,.75,2.2),CFrame.new(0,12.03,33.9),C.hair,Enum.PartType.Ball)
-- legs
for _,x in ipairs({-1,1}) do body("Leg",Vector3.new(1.05,3.8,1.15),CFrame.new(x*.72,3.65,34),C.pants) end
-- arms angled toward mixer
local la=body("LeftArm",Vector3.new(.8,3.4,.8),CFrame.new(-2.05,7.8,32.85)*CFrame.Angles(math.rad(35),0,math.rad(-18)),C.skin)
local ra=body("RightArm",Vector3.new(.8,3.4,.8),CFrame.new(2.05,7.8,32.85)*CFrame.Angles(math.rad(35),0,math.rad(18)),C.skin)
body("LeftSleeve",Vector3.new(1,1.8,1),CFrame.new(-1.6,9.1,33.55)*CFrame.Angles(0,0,math.rad(-18)),C.shirt)
body("RightSleeve",Vector3.new(1,1.8,1),CFrame.new(1.6,9.1,33.55)*CFrame.Angles(0,0,math.rad(18)),C.shirt)
-- face + headphones
neon("Visor",Vector3.new(1.45,.22,.08),CFrame.new(0,11.35,32.82),C.pink,npc)
local hb=part("DJHeadphoneBand",Vector3.new(2.35,.22,.22),CFrame.new(0,12.15,33.85),C.black,Enum.Material.Metal,nil,npc)
part("DJHeadphoneL",Vector3.new(.38,.85,.42),CFrame.new(-1.07,11.45,33.85),C.black,Enum.Material.Metal,nil,npc)
part("DJHeadphoneR",Vector3.new(.38,.85,.42),CFrame.new(1.07,11.45,33.85),C.black,Enum.Material.Metal,nil,npc)
-- subtle name plate
local plate=neon("ResidentDJPlate",Vector3.new(7,.18,.12),CFrame.new(0,5.15,28.82),C.pink,m);plate.CanCollide=false
print("[BBYA] Premium DJ equipment + resident NPC DJ added")