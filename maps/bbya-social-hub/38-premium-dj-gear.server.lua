local W=game:GetService("Workspace")
local root=W:WaitForChild("BBYA_ZERO_BUILD")
local underground=root:WaitForChild("Underground")

-- Remove the earlier blocky controller pieces. Keep stage, desk, sound stacks and room.
for _,name in ipairs({"DeckBody-8","DeckBody8","JogWheel-8","JogWheel8","JogRing-8","JogRing8","Mixer","LaptopStand","LaptopScreen","LaptopDisplay"}) do
 local o=underground:FindFirstChild(name); if o then o:Destroy() end
end
for _,o in ipairs(underground:GetChildren()) do
 if string.match(o.Name,"^Pad") or string.match(o.Name,"^Fader") or string.match(o.Name,"^MixerLED") then o:Destroy() end
end

local old=underground:FindFirstChild("PremiumDJRig"); if old then old:Destroy() end
local rig=Instance.new("Model");rig.Name="PremiumDJRig";rig.Parent=underground
local C={black=Color3.fromRGB(14,16,20),panel=Color3.fromRGB(28,31,38),edge=Color3.fromRGB(64,68,78),blue=Color3.fromRGB(0,170,255),yellow=Color3.fromRGB(255,205,35),white=Color3.fromRGB(220,225,232),screen=Color3.fromRGB(20,72,92)}
local function part(n,s,cf,c,mat,parent)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.CanCollide=false;x.Size=s;x.CFrame=cf;x.Color=c;x.Material=mat or Enum.Material.Metal;x.Parent=parent or rig;return x
end
local function neon(n,s,cf,c,parent)local x=part(n,s,cf,c,Enum.Material.Neon,parent);return x end
local function cyl(n,diam,h,cf,c,parent)
 local x=part(n,Vector3.new(h,diam,diam),cf,c,Enum.Material.Metal,parent);x.Shape=Enum.PartType.Cylinder;return x
end
local function label(parent,text,face,color)
 local sg=Instance.new("SurfaceGui");sg.Face=face or Enum.NormalId.Top;sg.CanvasSize=Vector2.new(300,120);sg.Parent=parent
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color or C.white;t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.Parent=sg
end

-- Club-standard 2 media players + 4-channel mixer, visually inspired by professional booth layouts.
local deckX={-8.5,8.5}
for idx,x in ipairs(deckX) do
 local d=Instance.new("Model");d.Name="MediaPlayer"..idx;d.Parent=rig
 local base=part("Chassis",Vector3.new(8.2,.75,5.6),CFrame.new(x,-8.95,31),C.black,Enum.Material.Metal,d)
 part("TopPlate",Vector3.new(7.8,.18,5.2),CFrame.new(x,-8.48,31),C.panel,Enum.Material.SmoothPlastic,d)
 -- large jog wheel with rim + center display
 local jog=cyl("JogWheel",4.2,.35,CFrame.new(x,-8.25,31.55)*CFrame.Angles(0,0,math.rad(90)),C.edge,d)
 cyl("JogTop",3.55,.12,CFrame.new(x,-8.02,31.55)*CFrame.Angles(0,0,math.rad(90)),C.black,d)
 cyl("JogCenter",1.2,.14,CFrame.new(x,-7.91,31.55)*CFrame.Angles(0,0,math.rad(90)),idx==1 and C.blue or C.yellow,d)
 -- upper waveform screen
 local sc=part("WaveformScreen",Vector3.new(4.8,.18,1.65),CFrame.new(x,-8.37,29.25),C.screen,Enum.Material.Neon,d);label(sc,"WAVEFORM",Enum.NormalId.Top,C.white)
 -- cue/play buttons, hot cues and navigation knob
 for i=0,3 do neon("HotCue"..i,Vector3.new(.62,.12,.45),CFrame.new(x-2.25+i*.78,-8.32,33.1),i%2==0 and C.blue or C.yellow,d) end
 local play=cyl("Play",.75,.16,CFrame.new(x+2.55,-8.22,33)*CFrame.Angles(0,0,math.rad(90)),C.blue,d)
 local cue=cyl("Cue",.62,.16,CFrame.new(x+1.55,-8.22,33)*CFrame.Angles(0,0,math.rad(90)),C.yellow,d)
 cyl("BrowseKnob",.55,.18,CFrame.new(x+2.5,-8.2,29.25)*CFrame.Angles(0,0,math.rad(90)),C.edge,d)
 -- tempo fader
 part("TempoSlot",Vector3.new(.18,.08,2.3),CFrame.new(x-3.05,-8.28,31.9),Color3.fromRGB(90,94,104),Enum.Material.SmoothPlastic,d)
 part("TempoCap",Vector3.new(.55,.18,.35),CFrame.new(x-3.05,-8.16,31.35),C.white,Enum.Material.SmoothPlastic,d)
end

local mixer=Instance.new("Model");mixer.Name="FourChannelMixer";mixer.Parent=rig
part("MixerBase",Vector3.new(6.6,.8,5.6),CFrame.new(0,-8.95,31),C.black,Enum.Material.Metal,mixer)
part("MixerTop",Vector3.new(6.25,.18,5.2),CFrame.new(0,-8.47,31),C.panel,Enum.Material.SmoothPlastic,mixer)
-- four channel strips
for ch=1,4 do
 local x=-2.25+(ch-1)*1.5
 for row=0,2 do cyl("EQ"..ch.."_"..row,.42,.18,CFrame.new(x,-8.18,29.55+row*.7)*CFrame.Angles(0,0,math.rad(90)),C.edge,mixer) end
 part("ChannelFaderSlot"..ch,Vector3.new(.12,.06,1.55),CFrame.new(x,-8.26,32.1),Color3.fromRGB(80,84,94),Enum.Material.SmoothPlastic,mixer)
 part("ChannelFaderCap"..ch,Vector3.new(.5,.16,.28),CFrame.new(x,-8.14,32.35-(ch%2)*.45),C.white,Enum.Material.SmoothPlastic,mixer)
 neon("VU"..ch,Vector3.new(.18,.08,1.55),CFrame.new(x+.48,-8.22,30.55),ch%2==0 and C.blue or C.yellow,mixer)
end
-- crossfader + master controls
part("CrossfaderSlot",Vector3.new(3.2,.06,.12),CFrame.new(0,-8.26,33.18),Color3.fromRGB(80,84,94),Enum.Material.SmoothPlastic,mixer)
part("CrossfaderCap",Vector3.new(.35,.16,.55),CFrame.new(.45,-8.14,33.18),C.white,Enum.Material.SmoothPlastic,mixer)
for x=-1,1 do cyl("MasterKnob"..x,.55,.18,CFrame.new(x*1.15,-8.16,29.15)*CFrame.Angles(0,0,math.rad(90)),x==0 and C.yellow or C.edge,mixer) end

-- Laptop moved to the front edge of the mixer area, normal open angle, facing the DJ.
local stand=part("LaptopShelf",Vector3.new(5.5,.22,2.3),CFrame.new(0,-7.78,27.7),C.edge,Enum.Material.Metal,rig)
part("LaptopBase",Vector3.new(5,.22,2.1),CFrame.new(0,-7.56,27.7),C.black,Enum.Material.Metal,rig)
local screenCF=CFrame.new(0,-6.25,28.65)*CFrame.Angles(math.rad(-12),0,0)
local screen=part("LaptopScreen",Vector3.new(5,2.9,.2),screenCF,C.black,Enum.Material.Metal,rig)
local glow=neon("LaptopDisplay",Vector3.new(4.55,2.45,.06),screenCF*CFrame.new(0,0,-.13),C.blue,rig)

print("[BBYA] Premium club-standard DJ rig installed")