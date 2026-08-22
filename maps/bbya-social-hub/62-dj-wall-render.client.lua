-- BBYA SOCIAL HUB — AUDIO-REACTIVE NIGHTLIFE RENDERER v2
-- Reads local Sound.PlaybackLoudness from the existing MAIN / UNDERGROUND / FUNKOT engines.
-- No playlist, queue, purchase, or transport authority lives here.
-- Visual response is amplitude/envelope based; this does NOT pretend to be a frequency spectrum.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local wallRemote=remotes:WaitForChild("DJWall",30)
if not wallRemote then return end
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local system=root:WaitForChild("DJWallMessageSystem",30)
if not system then return end
local final=system:WaitForChild("FinalMountedWall",30)
if not final then return end
local screen=final:WaitForChild("PrestigeLED",30)
if not screen then return end

for _,name in ipairs({"BBYAClientWallFront","BBYAClientWallBack"}) do
 local old=screen:FindFirstChild(name)
 if old then old:Destroy() end
end
for _,name in ipairs({"DJWallUI","DJWallUI_OppositeFace"}) do
 local old=screen:FindFirstChild(name)
 if old and old:IsA("SurfaceGui") then old.Enabled=false end
end

local C={
 black=Color3.fromRGB(4,4,8),pink=Color3.fromRGB(255,38,155),cyan=Color3.fromRGB(0,210,238),
 gold=Color3.fromRGB(238,190,94),white=Color3.fromRGB(245,243,248),muted=Color3.fromRGB(140,133,151),
 green=Color3.fromRGB(62,205,124),purple=Color3.fromRGB(111,65,214),
}
local function label(parent,text,pos,size,font,color,z)
 local l=Instance.new("TextLabel")
 l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.GothamBold
 l.TextColor3=color or C.white;l.TextScaled=true;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Center
 l.TextYAlignment=Enum.TextYAlignment.Center;l.ZIndex=z or 5;l.Parent=parent;return l
end
local function frame(parent,pos,size,color,trans,z)
 local f=Instance.new("Frame")
 f.Position=pos;f.Size=size;f.BackgroundColor3=color or C.pink;f.BackgroundTransparency=trans or 0
 f.BorderSizePixel=0;f.ZIndex=z or 4;f.Parent=parent;return f
end
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=o end

local function build(face,name)
 local sg=Instance.new("SurfaceGui")
 sg.Name=name;sg.Face=face;sg.AlwaysOnTop=false;sg.LightInfluence=0;sg.Enabled=true
 sg.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;sg.PixelsPerStud=50
 pcall(function()sg.MaxDistance=350 end)
 sg.Parent=screen

 local bg=frame(sg,UDim2.fromScale(0,0),UDim2.fromScale(1,1),C.black,0,1)
 local grad=Instance.new("UIGradient")
 grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(42,7,34)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(5,5,10)),ColorSequenceKeypoint.new(1,Color3.fromRGB(3,35,43))})
 grad.Rotation=10;grad.Parent=bg

 local idle=frame(bg,UDim2.fromScale(0,0),UDim2.fromScale(1,1),C.black,1,2)
 local logo=label(idle,"BBYA",UDim2.fromScale(.26,.18),UDim2.fromScale(.48,.28),Enum.Font.GothamBlack,C.white,6)
 local sub=label(idle,"SOCIAL HUB  //  AUDIO REACTIVE",UDim2.fromScale(.27,.47),UDim2.fromScale(.46,.07),Enum.Font.GothamBold,C.pink,6)
 local status=label(idle,"○  AUDIO IDLE",UDim2.fromScale(.78,.05),UDim2.fromScale(.17,.05),Enum.Font.GothamBold,C.muted,6)
 local footer=label(idle,"MUSIC  •  COMMUNITY  •  24/7",UDim2.fromScale(.29,.82),UDim2.fromScale(.42,.05),Enum.Font.GothamMedium,C.muted,6)

 local visual=frame(idle,UDim2.fromScale(.055,.60),UDim2.fromScale(.89,.18),Color3.fromRGB(8,8,12),.18,3);round(visual,14)
 local bars={}
 for i=1,34 do
  local b=frame(visual,UDim2.new((i-.5)/34,0,1,0),UDim2.new(.018,0,.08,0),i%5==0 and C.cyan or (i%3==0 and C.gold or C.pink),.02,4)
  b.AnchorPoint=Vector2.new(.5,1);round(b,5);table.insert(bars,b)
 end

 local matrix=frame(idle,UDim2.fromScale(.12,.15),UDim2.fromScale(.76,.58),C.black,1,3)
 matrix.Visible=false
 local dots={}
 for r=1,6 do
  for c=1,15 do
   local d=frame(matrix,UDim2.fromScale((c-.5)/15,(r-.5)/6),UDim2.fromScale(.025,.06),((r+c)%3==0) and C.cyan or (((r+c)%2==0) and C.pink or C.purple),.72,4)
   d.AnchorPoint=Vector2.new(.5,.5);round(d,5);table.insert(dots,d)
  end
 end
 local matrixLogo=label(matrix,"BBYA",UDim2.fromScale(.28,.31),UDim2.fromScale(.44,.30),Enum.Font.GothamBlack,C.white,7)

 local message=frame(bg,UDim2.fromScale(0,0),UDim2.fromScale(1,1),Color3.fromRGB(8,7,11),.02,10)
 message.Visible=false
 local mg=Instance.new("UIGradient")
 mg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(70,13,53)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(9,8,13)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,47,57))});mg.Rotation=18;mg.Parent=message
 local category=label(message,"BBYA LIVE MESSAGE",UDim2.fromScale(.08,.07),UDim2.fromScale(.84,.10),Enum.Font.GothamBlack,C.pink,12)
 local msg=label(message,"",UDim2.fromScale(.07,.22),UDim2.fromScale(.86,.45),Enum.Font.GothamBlack,C.white,12)
 local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=34;limit.MaxTextSize=180;limit.Parent=msg
 local from=label(message,"",UDim2.fromScale(.12,.70),UDim2.fromScale(.76,.09),Enum.Font.GothamBold,C.gold,12)
 label(message,"BBYA SOCIAL HUB  •  MAKE THE NIGHT YOURS",UDim2.fromScale(.18,.86),UDim2.fromScale(.64,.05),Enum.Font.GothamBold,C.muted,12)

 return {sg=sg,bg=bg,grad=grad,idle=idle,logo=logo,sub=sub,status=status,footer=footer,visual=visual,bars=bars,matrix=matrix,dots=dots,matrixLogo=matrixLogo,message=message,category=category,msg=msg,from=from}
end

local renderers={build(Enum.NormalId.Front,"BBYAClientWallFront"),build(Enum.NormalId.Back,"BBYAClientWallBack")}
local wallState={mode="idle"}
local displayMode=1
local modeStart=os.clock()

local function applyState(state)
 wallState=state or {mode="idle"}
 for _,r in ipairs(renderers) do
  local isMessage=wallState.mode=="message"
  r.message.Visible=isMessage;r.idle.Visible=not isMessage
  if isMessage then
   r.category.Text=wallState.category or "BBYA LIVE MESSAGE";r.msg.Text=wallState.text or "";r.from.Text=wallState.from or ""
  end
 end
end
applyState(wallState)
wallRemote.OnClientEvent:Connect(function(action,data)if action=="wallRenderState" and type(data)=="table" then applyState(data) end end)

local venue={
 MAIN={soundNames={"BBYAClubDeckA","BBYAClubDeckB"},peak=120,fast=0,slow=0,energy=0,beat=0,lights={},beams={}},
 BASEMENT={soundNames={"BBYABasementDeckA","BBYABasementDeckB"},peak=120,fast=0,slow=0,energy=0,beat=0,lights={},beams={}},
 FUNKOT={soundNames={"BBYAFunkotDeck"},peak=120,fast=0,slow=0,energy=0,beat=0,lights={},beams={}},
}

local function isLight(x)return x:IsA("SpotLight") or x:IsA("PointLight") or x:IsA("SurfaceLight") end
local function cacheLight(bucket,l)
 for _,row in ipairs(bucket.lights) do if row.light==l then return end end
 local base=l:GetAttribute("BBYABaseBrightness")
 if type(base)~="number" then base=l.Brightness end
 table.insert(bucket.lights,{light=l,base=math.max(.05,base)})
end
local function cacheBeam(bucket,b)
 for _,row in ipairs(bucket.beams) do if row.beam==b then return end end
 table.insert(bucket.beams,{beam=b})
end
local function refreshFX()
 for _,v in pairs(venue) do v.lights={};v.beams={} end
 local main=root:FindFirstChild("ClubAmbience")
 if main then
  for _,d in ipairs(main:GetDescendants()) do
   if isLight(d) and d.Parent and (d.Parent.Name:find("StageBeam",1,true) or d.Parent.Name:find("DanceBeam",1,true)) then cacheLight(venue.MAIN,d) end
  end
 end
 local underground=root:FindFirstChild("Underground")
 if underground then
  for _,d in ipairs(underground:GetDescendants()) do
   if isLight(d) and d.Parent then
    local n=d.Parent.Name
    if n:find("CeilingBlue",1,true) or n:find("CeilingYellow",1,true) or n:find("DJBoothBlue",1,true) or n:find("DJBoothYellow",1,true) or n:find("BarBlue",1,true) or n:find("BarYellow",1,true) then cacheLight(venue.BASEMENT,d) end
   end
  end
 end
 local funkot=root:FindFirstChild("FunkotClubV1")
 if funkot then
  local movers=funkot:FindFirstChild("MovingHeads")
  if movers then for _,d in ipairs(movers:GetDescendants()) do if isLight(d) then cacheLight(venue.FUNKOT,d) end end end
  local lasers=funkot:FindFirstChild("LaserRig")
  if lasers then for _,d in ipairs(lasers:GetDescendants()) do if d:IsA("Beam") then cacheBeam(venue.FUNKOT,d) end end end
 end
end
refreshFX()
task.spawn(function()while screen.Parent do task.wait(5);refreshFX() end end)

local function rawLoudness(names)
 local raw=0
 for _,name in ipairs(names) do
  local s=SoundService:FindFirstChild(name)
  if s and s:IsA("Sound") and s.IsPlaying then raw=math.max(raw,tonumber(s.PlaybackLoudness) or 0) end
 end
 return raw
end
local function updateEnvelope(v)
 local raw=rawLoudness(v.soundNames)
 if raw>v.peak then v.peak=raw else v.peak=math.max(90,v.peak*.992) end
 local norm=(raw<2) and 0 or math.clamp(raw/math.max(v.peak,90),0,1)
 v.fast+=(norm-v.fast)*.34;v.slow+=(norm-v.slow)*.055
 v.energy+=(norm-v.energy)*.22
 v.beat=math.clamp((v.fast-v.slow)*3.1,0,1)
 return raw
end
local function applyRig(v,minGain,energyGain,beatGain)
 local gain=minGain+v.energy*energyGain+v.beat*beatGain
 for i=#v.lights,1,-1 do
  local row=v.lights[i]
  if row.light and row.light.Parent then row.light.Brightness=row.base*gain else table.remove(v.lights,i) end
 end
 for i=#v.beams,1,-1 do
  local row=v.beams[i]
  if row.beam and row.beam.Parent then
   local visible=math.clamp(.78-v.energy*.58-v.beat*.16,.06,.78)
   row.beam.Transparency=NumberSequence.new(visible)
  else table.remove(v.beams,i) end
 end
end

local accumulator=0
RunService.RenderStepped:Connect(function(dt)
 accumulator+=dt
 if accumulator<.05 then return end
 accumulator=0
 local mainRaw=updateEnvelope(venue.MAIN)
 updateEnvelope(venue.BASEMENT);updateEnvelope(venue.FUNKOT)
 applyRig(venue.MAIN,.48,.76,.34)
 applyRig(venue.BASEMENT,.58,.90,.36)
 applyRig(venue.FUNKOT,.32,.72,.28)

 if wallState.mode=="message" then return end
 local t=os.clock()
 if t-modeStart>=12 then displayMode=(displayMode%3)+1;modeStart=t end
 local e=venue.MAIN.energy;local beat=venue.MAIN.beat
 for _,r in ipairs(renderers) do
  r.status.Text=(mainRaw>2) and "●  AUDIO LINK" or "○  AUDIO IDLE"
  r.status.TextColor3=(mainRaw>2) and C.green or C.muted
  if displayMode==3 then
   r.matrix.Visible=true;r.visual.Visible=false;r.logo.Visible=false;r.sub.Visible=false;r.footer.Visible=false
   local pulse=1+beat*.035;r.matrixLogo.Size=UDim2.fromScale(.44*pulse,.30*pulse);r.matrixLogo.Position=UDim2.fromScale(.5-.22*pulse,.46-.15*pulse)
   for i,d in ipairs(r.dots) do
    local spatial=.55+.45*math.sin(t*1.15+i*.41)
    d.BackgroundTransparency=math.clamp(.82-e*(.48+.25*spatial)-beat*.12,.10,.86)
   end
  else
   r.matrix.Visible=false;r.visual.Visible=true;r.logo.Visible=true;r.sub.Visible=true;r.footer.Visible=true
   r.logo.Text=(displayMode==1) and "BBYA" or "BBYA  LIVE WAVE"
   r.sub.Text=(displayMode==1) and "SOCIAL HUB  //  AUDIO REACTIVE" or "AUTO DJ  //  LIVE ENVELOPE"
   local pulse=1+beat*.055+r.energy*.012
   r.logo.Size=UDim2.fromScale(.48*pulse,.28*pulse);r.logo.Position=UDim2.fromScale(.5-.24*pulse,.32-.14*pulse)
   for i,b in ipairs(r.bars) do
    local spatial=.52+.48*math.sin(t*1.35+i*.57)
    local accent=(i%5==0) and 1.08 or 1
    local h=math.clamp(.07+e*(.30+.58*spatial)*accent+beat*.12*(1-spatial*.35),.07,.98)
    b.Size=UDim2.new(.018,0,h,0)
   end
  end
 end
end)

screen:SetAttribute("BBYAAudioReactiveRenderer","V2_PLAYBACK_LOUDNESS")
print("[BBYA] audio-reactive renderer v2 online: real loudness envelope / MAIN + UNDERGROUND + FUNKOT")