-- BBYA SOCIAL HUB — DJ WALL CLIENT RENDERER v1
-- Mobile-safe local SurfaceGui renderer. Server remains authoritative for purchases/queue.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
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
 black=Color3.fromRGB(4,4,8),ink=Color3.fromRGB(10,8,15),pink=Color3.fromRGB(255,38,155),
 cyan=Color3.fromRGB(0,210,238),gold=Color3.fromRGB(238,190,94),white=Color3.fromRGB(245,243,248),
 muted=Color3.fromRGB(140,133,151),green=Color3.fromRGB(62,205,124),purple=Color3.fromRGB(111,65,214),
}

local function label(parent,text,pos,size,font,color,z)
 local l=Instance.new("TextLabel")
 l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.GothamBold
 l.TextColor3=color or C.white;l.TextScaled=true;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Center
 l.TextYAlignment=Enum.TextYAlignment.Center;l.ZIndex=z or 5;l.Parent=parent
 return l
end
local function frame(parent,pos,size,color,trans,z)
 local f=Instance.new("Frame")
 f.Position=pos;f.Size=size;f.BackgroundColor3=color or C.pink;f.BackgroundTransparency=trans or 0
 f.BorderSizePixel=0;f.ZIndex=z or 4;f.Parent=parent
 return f
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
 local sub=label(idle,"SOCIAL HUB  //  LIVE",UDim2.fromScale(.30,.47),UDim2.fromScale(.40,.07),Enum.Font.GothamBold,C.pink,6)
 local status=label(idle,"●  LIVE VISUALS",UDim2.fromScale(.78,.05),UDim2.fromScale(.17,.05),Enum.Font.GothamBold,C.green,6)
 local footer=label(idle,"MUSIC  •  COMMUNITY  •  24/7",UDim2.fromScale(.29,.82),UDim2.fromScale(.42,.05),Enum.Font.GothamMedium,C.muted,6)

 local visual=frame(idle,UDim2.fromScale(.055,.60),UDim2.fromScale(.89,.18),Color3.fromRGB(8,8,12),.18,3);round(visual,14)
 local bars={}
 for i=1,34 do
  local b=frame(visual,UDim2.new((i-.5)/34,0,1,0),UDim2.new(.018,0,.18,0),i%5==0 and C.cyan or (i%3==0 and C.gold or C.pink),.02,4)
  b.AnchorPoint=Vector2.new(.5,1);round(b,5);table.insert(bars,b)
 end

 local matrix=frame(idle,UDim2.fromScale(.12,.15),UDim2.fromScale(.76,.58),C.black,1,3)
 matrix.Visible=false
 local dots={}
 for r=1,6 do
  for c=1,15 do
   local d=frame(matrix,UDim2.fromScale((c-.5)/15,(r-.5)/6),UDim2.fromScale(.025,.06),((r+c)%3==0) and C.cyan or (((r+c)%2==0) and C.pink or C.purple),.10,4)
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
local mode=1
local modeStart=os.clock()
local nextMode=9

local function applyState(state)
 wallState=state or {mode="idle"}
 for _,r in ipairs(renderers) do
  local isMessage=wallState.mode=="message"
  r.message.Visible=isMessage
  r.idle.Visible=not isMessage
  if isMessage then
   r.category.Text=wallState.category or "BBYA LIVE MESSAGE"
   r.msg.Text=wallState.text or ""
   r.from.Text=wallState.from or ""
  end
 end
end
applyState(wallState)

wallRemote.OnClientEvent:Connect(function(action,data)
 if action=="wallRenderState" and type(data)=="table" then applyState(data) end
end)

RunService.RenderStepped:Connect(function()
 if wallState.mode=="message" then return end
 local t=os.clock()
 if t-modeStart>=nextMode then
  mode=(mode%3)+1;modeStart=t;nextMode=8+math.random()*5
 end
 for _,r in ipairs(renderers) do
  if mode==1 then
   r.matrix.Visible=false;r.visual.Visible=true;r.logo.Visible=true;r.sub.Visible=true;r.footer.Visible=true
   local pulse=.96+math.sin(t*1.8)*.035
   r.logo.Size=UDim2.fromScale(.48*pulse,.28*pulse)
   r.logo.Position=UDim2.fromScale(.5-.24*pulse,.32-.14*pulse)
  elseif mode==2 then
   r.matrix.Visible=false;r.visual.Visible=true;r.logo.Visible=true;r.sub.Visible=true;r.footer.Visible=true
   r.logo.Text="BBYA  LIVE WAVE";r.sub.Text="AUTO DJ  //  NIGHT NETWORK"
  else
   r.matrix.Visible=true;r.visual.Visible=false;r.logo.Visible=false;r.sub.Visible=false;r.footer.Visible=false
   r.matrixLogo.Rotation=math.sin(t*.8)*1.5
   for i,d in ipairs(r.dots) do d.BackgroundTransparency=.08+.55*(.5+.5*math.sin(t*2+i*.31)) end
  end
  if mode~=3 then
   r.logo.Text=(mode==1) and "BBYA" or "BBYA  LIVE WAVE"
   r.sub.Text=(mode==1) and "SOCIAL HUB  //  LIVE" or "AUTO DJ  //  NIGHT NETWORK"
   for i,b in ipairs(r.bars) do
    local h=.18+math.abs(math.sin(t*3.2+i*.47))*.72
    b.Size=UDim2.new(.018,0,h,0)
   end
  end
 end
end)

print("[BBYA] DJ wall client renderer v1 online: dual-face mobile render")