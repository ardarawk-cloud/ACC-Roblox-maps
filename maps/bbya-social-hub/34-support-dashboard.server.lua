-- BBYA SOCIAL HUB — COMMUNITY + OWNER + TOP 3 DONATOR v1.1
-- Clean entrance authority replacing the old dual honor-wall runtime.
-- Left: readable Live Community + Owner identity. Right: server-authoritative Top 3 Donator (> 1,000 R$).
-- No fake donors. Support totals persist server-side. Sultan contribution is counted only from a verified server attribute.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local OWNER_USERNAME="nadmo97"
local QUALIFIER_MIN=1001
local SUPPORT_STORE=DataStoreService:GetDataStore("BBYA_SUPPORT_CONTRIBUTION_V1")
local RANK_STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder")
root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
for _,name in ipairs({"SupportDashboard","CommunityOwnerDonorHub"}) do
 local old=root:FindFirstChild(name);if old then old:Destroy() end
end

local model=Instance.new("Model")
model.Name="CommunityOwnerDonorHub"
model:SetAttribute("Pass","COMMUNITY_OWNER_TOP3_V1_1")
model:SetAttribute("DonorEligibility",">1000")
model:SetAttribute("FakeDonors",false)
model:SetAttribute("ServerAuthoritative",true)
model:SetAttribute("SultanContributionPolicy","VERIFIED_ATTRIBUTE_ONLY")
model.Parent=root

local C={
 DARK=Color3.fromRGB(5,6,9),PANEL=Color3.fromRGB(17,18,24),PANEL2=Color3.fromRGB(25,25,33),
 WHITE=Color3.fromRGB(246,246,249),MUTED=Color3.fromRGB(151,153,165),PINK=Color3.fromRGB(247,55,158),
 CYAN=Color3.fromRGB(30,201,231),GOLD=Color3.fromRGB(239,190,92),SILVER=Color3.fromRGB(203,208,218),
 BRONZE=Color3.fromRGB(203,133,85),BLACK=Color3.fromRGB(3,3,5),
}

local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o end
local function stroke(o,col,t,tr)local x=Instance.new("UIStroke");x.Color=col or C.MUTED;x.Thickness=t or 1;x.Transparency=tr or 0;x.Parent=o end
local function frame(parent,pos,size,color,tr,r)
 local f=Instance.new("Frame");f.Position=pos;f.Size=size;f.BackgroundColor3=color or C.PANEL;f.BackgroundTransparency=tr or 0;f.BorderSizePixel=0;f.Parent=parent;if r then corner(f,r) end;return f
end
local function label(parent,txt,pos,size,col,font,ts,align)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=tostring(txt or "");t.Position=pos;t.Size=size;t.TextColor3=col or C.WHITE;t.Font=font or Enum.Font.Gotham;t.TextSize=ts or 18;t.TextWrapped=true;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.Parent=parent;return t
end
local function image(parent,pos,size)
 local i=Instance.new("ImageLabel");i.BackgroundColor3=C.PANEL2;i.BorderSizePixel=0;i.Position=pos;i.Size=size;i.ScaleType=Enum.ScaleType.Crop;i.Parent=parent;corner(i,999);stroke(i,C.CYAN,2,.15);return i
end
local function part(name,size,cf,color,material,tr,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.DARK;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=tr or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true;p.CastShadow=false;p.Parent=parent or model;return p
end
local function formatRobux(value)
 local s=tostring(math.max(0,math.floor(tonumber(value) or 0)))
 local out={};local n=#s
 for i=1,n do
  table.insert(out,s:sub(i,i))
  local remain=n-i
  if remain>0 and remain%3==0 then table.insert(out,".") end
 end
 return table.concat(out).." R$"
end

local BOARD_W=20.25
local BOARD_H=23.15
local BOARD_Y=12
local BOARD_Z=-44.54
local function makeBoard(name,x,accentA,accentB)
 local holder=Instance.new("Model");holder.Name=name;holder.Parent=model
 local cf=CFrame.new(x,BOARD_Y,BOARD_Z)
 part("Recess",Vector3.new(20.75,23.65,.34),cf*CFrame.new(0,0,.12),C.BLACK,Enum.Material.Metal,0,holder)
 local face=part("Display",Vector3.new(BOARD_W,BOARD_H,.11),cf*CFrame.new(0,0,-.14),Color3.fromRGB(9,10,14),Enum.Material.Glass,.025,holder)
 face.Reflectance=.03
 part("TopNeon",Vector3.new(BOARD_W-.45,.10,.10),cf*CFrame.new(0,BOARD_H*.5-.17,-.22),accentA,Enum.Material.Neon,0,holder)
 part("BottomNeon",Vector3.new(BOARD_W-.45,.10,.10),cf*CFrame.new(0,-BOARD_H*.5+.17,-.22),accentB,Enum.Material.Neon,0,holder)
 part("LeftNeon",Vector3.new(.10,BOARD_H-.45,.10),cf*CFrame.new(-BOARD_W*.5+.17,0,-.22),accentB,Enum.Material.Neon,0,holder)
 part("RightNeon",Vector3.new(.10,BOARD_H-.45,.10),cf*CFrame.new(BOARD_W*.5-.17,0,-.22),accentA,Enum.Material.Neon,0,holder)
 local light=Instance.new("PointLight");light.Color=accentA;light.Brightness=.28;light.Range=7;light.Shadows=false;light.Parent=face
 local gui=Instance.new("SurfaceGui");gui.Name="BBYAEntranceBoardUI";gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.PixelsPerStud=88;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.Parent=face
 local bg=frame(gui,UDim2.fromScale(0,0),UDim2.fromScale(1,1),C.DARK,0)
 local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(33,13,30)),ColorSequenceKeypoint.new(.52,Color3.fromRGB(8,9,13)),ColorSequenceKeypoint.new(1,Color3.fromRGB(5,21,27))});grad.Rotation=18;grad.Parent=bg
 return holder,face,bg
end

local _,leftFace,left=makeBoard("CommunityOwnerWall",-34.5,C.PINK,C.CYAN)
label(left,"BBYA",UDim2.fromScale(.045,.035),UDim2.fromScale(.20,.050),C.WHITE,Enum.Font.GothamBlack,30)
label(left,"LIVE COMMUNITY",UDim2.fromScale(.045,.095),UDim2.fromScale(.75,.075),C.PINK,Enum.Font.GothamBlack,38)
label(left,"People make the room. Everyone belongs here.",UDim2.fromScale(.045,.170),UDim2.fromScale(.88,.035),C.MUTED,Enum.Font.GothamMedium,16)
local divider=frame(left,UDim2.fromScale(.045,.220),UDim2.fromScale(.91,.004),C.PINK,0)
local dg=Instance.new("UIGradient");dg.Color=ColorSequence.new(C.PINK,C.CYAN);dg.Parent=divider
local ownerCard=frame(left,UDim2.fromScale(.045,.255),UDim2.fromScale(.91,.255),Color3.fromRGB(25,17,28),.02,14);stroke(ownerCard,C.PINK,2,.12)
label(ownerCard,"OWNER",UDim2.fromScale(.31,.10),UDim2.fromScale(.58,.15),C.PINK,Enum.Font.GothamBlack,18)
local ownerAvatar=image(ownerCard,UDim2.fromScale(.045,.18),UDim2.fromScale(.22,.64))
local ownerDisplay=label(ownerCard,"NADMO97",UDim2.fromScale(.31,.29),UDim2.fromScale(.62,.25),C.WHITE,Enum.Font.GothamBlack,28)
local ownerUser=label(ownerCard,"@nadmo97",UDim2.fromScale(.31,.55),UDim2.fromScale(.62,.13),C.CYAN,Enum.Font.GothamBold,16)
label(ownerCard,"BBYA SOCIAL HUB",UDim2.fromScale(.31,.70),UDim2.fromScale(.62,.12),C.MUTED,Enum.Font.GothamBold,14)
label(left,"RECENT ARRIVALS",UDim2.fromScale(.045,.545),UDim2.fromScale(.70,.045),C.WHITE,Enum.Font.GothamBold,18)
local arrivalRows={}
for i=1,4 do
 local y=.605+(i-1)*.079
 local row=frame(left,UDim2.fromScale(.045,y),UDim2.fromScale(.91,.060),C.PANEL,.02,8);stroke(row,i==1 and C.PINK or C.CYAN,1,.72)
 frame(row,UDim2.fromScale(.025,.29),UDim2.fromScale(.035,.42),i==1 and C.PINK or C.CYAN,0,99)
 arrivalRows[i]=label(row,i==1 and "Waiting for the next guest" or "Open community slot",UDim2.fromScale(.082,.08),UDim2.fromScale(.86,.84),i==1 and C.WHITE or C.MUTED,Enum.Font.GothamBold,16)
end
local communityFooter=frame(left,UDim2.fromScale(.045,.932),UDim2.fromScale(.91,.038),Color3.fromRGB(32,17,31),0,8);stroke(communityFooter,C.PINK,1,.55)
label(communityFooter,"OPEN SUPPORT  •  LEAVE YOUR MARK",UDim2.fromScale(.025,.05),UDim2.fromScale(.95,.90),C.WHITE,Enum.Font.GothamBlack,14,Enum.TextXAlignment.Center)

local _,rightFace,right=makeBoard("Top3DonatorWall",34.5,C.GOLD,C.PINK)
label(right,"BBYA",UDim2.fromScale(.045,.035),UDim2.fromScale(.20,.050),C.WHITE,Enum.Font.GothamBlack,30)
label(right,"TOP 3 DONATOR",UDim2.fromScale(.045,.095),UDim2.fromScale(.78,.075),C.GOLD,Enum.Font.GothamBlack,38)
label(right,"QUALIFIER > 1,000 R$  •  REAL CONTRIBUTION ONLY",UDim2.fromScale(.045,.172),UDim2.fromScale(.90,.035),C.MUTED,Enum.Font.GothamBold,15)
local d2=frame(right,UDim2.fromScale(.045,.220),UDim2.fromScale(.91,.004),C.GOLD,0)
local d2g=Instance.new("UIGradient");d2g.Color=ColorSequence.new(C.GOLD,C.PINK);d2g.Parent=d2
local rankColors={C.GOLD,C.SILVER,C.BRONZE}
local rankRefs={}
for i=1,3 do
 local y=.275+(i-1)*.205
 local card=frame(right,UDim2.fromScale(.045,y),UDim2.fromScale(.91,.165),C.PANEL2,.01,13);stroke(card,rankColors[i],i==1 and 2 or 1,.18)
 local badge=frame(card,UDim2.fromScale(.025,.16),UDim2.fromScale(.14,.68),C.BLACK,0,99);stroke(badge,rankColors[i],2,.08)
 label(badge,"#"..i,UDim2.fromScale(0,0),UDim2.fromScale(1,1),rankColors[i],Enum.Font.GothamBlack,26,Enum.TextXAlignment.Center)
 local av=image(card,UDim2.fromScale(.19,.18),UDim2.fromScale(.18,.64));local avStroke=av:FindFirstChildOfClass("UIStroke");if avStroke then avStroke.Color=rankColors[i] end
 local name=label(card,"QUALIFIER SLOT EMPTY",UDim2.fromScale(.40,.16),UDim2.fromScale(.56,.25),C.WHITE,Enum.Font.GothamBlack,18)
 local amount=label(card,"> 1.000 R$ required",UDim2.fromScale(.40,.47),UDim2.fromScale(.56,.18),C.MUTED,Enum.Font.GothamBold,16)
 local source=label(card,"WAITING FOR REAL CONTRIBUTION",UDim2.fromScale(.40,.68),UDim2.fromScale(.56,.12),rankColors[i],Enum.Font.GothamBold,11)
 rankRefs[i]={avatar=av,name=name,amount=amount,source=source}
end
local donorFooter=frame(right,UDim2.fromScale(.045,.902),UDim2.fromScale(.91,.068),Color3.fromRGB(31,26,18),0,9);stroke(donorFooter,C.GOLD,1,.45)
label(donorFooter,"SUPPORT + VERIFIED SULTAN CONTRIBUTION",UDim2.fromScale(.025,.08),UDim2.fromScale(.95,.40),C.GOLD,Enum.Font.GothamBlack,13,Enum.TextXAlignment.Center)
label(donorFooter,"No placeholder names. Empty slot stays empty.",UDim2.fromScale(.025,.50),UDim2.fromScale(.95,.32),C.MUTED,Enum.Font.GothamMedium,12,Enum.TextXAlignment.Center)

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local stateRemote=remotes:FindFirstChild("State")
for _,face in ipairs({leftFace,rightFace}) do
 local p=Instance.new("ProximityPrompt");p.Name="OpenSupportMenu";p.ActionText="Open Support";p.ObjectText="BBYA Community";p.KeyboardKeyCode=Enum.KeyCode.E;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.HoldDuration=0;p.MaxActivationDistance=11;p.RequiresLineOfSight=false;p.Parent=face
 p.Triggered:Connect(function(plr)if stateRemote and stateRemote:IsA("RemoteEvent") then stateRemote:FireClient(plr,"openSupport",true) end end)
end

task.spawn(function()
 local ok,uid=pcall(function()return Players:GetUserIdFromNameAsync(OWNER_USERNAME)end)
 if not ok or not uid then return end
 local okName,name=pcall(function()return Players:GetNameFromUserIdAsync(uid)end)
 if okName and name then ownerUser.Text="@"..name end
 local display=name or OWNER_USERNAME
 for _,p in ipairs(Players:GetPlayers()) do if p.UserId==uid then display=p.DisplayName break end end
 ownerDisplay.Text=string.upper(display)
 local okThumb,url=pcall(function()return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)end)
 if okThumb and url then ownerAvatar.Image=url end
end)

local recent={}
local seen={}
local function refreshArrivals()
 for i=1,4 do
  local row=arrivalRows[i]
  if recent[i] then row.Text=recent[i] else row.Text=(i==1 and "Waiting for the next guest" or "Open community slot") end
 end
end
local function recognize(p)
 if not p or not p.Parent then return end
 local now=os.clock();if now-(seen[p.UserId] or 0)<8 then return end;seen[p.UserId]=now
 local name=(p.DisplayName and p.DisplayName~="") and p.DisplayName or p.Name
 table.insert(recent,1,name);while #recent>4 do table.remove(recent) end;refreshArrivals()
end
local function wireArrival(p)
 task.delay(1.2,function()if p.Parent then recognize(p) end end)
 p:GetAttributeChangedSignal("BBYACheckedIn"):Connect(function()if p:GetAttribute("BBYACheckedIn")==true then recognize(p) end end)
end
for _,p in ipairs(Players:GetPlayers()) do wireArrival(p) end
Players.PlayerAdded:Connect(wireArrival)

local saveToken={}
local wiring={}
local function supportKey(uid)return "u_"..tostring(uid) end
local function numeric(v)return math.max(0,math.floor(tonumber(v) or 0)) end
local function verifiedSultan(p)
 return numeric(p and p:GetAttribute("BBYASultanContributionRobux"))
end
local function persistPlayer(p)
 if not p then return end
 local uid=p.UserId;local support=numeric(p:GetAttribute("BBYASupportRobuxTotal"));local total=support+verifiedSultan(p)
 task.spawn(function()
  pcall(function()SUPPORT_STORE:SetAsync(supportKey(uid),support)end)
  pcall(function()RANK_STORE:SetAsync(tostring(uid),total)end)
 end)
end
local refreshToken=0
local function donorIdentity(uid)
 local name="USER "..tostring(uid)
 local ok,n=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);if ok and n then name=n end
 local display=name
 local online=Players:GetPlayerByUserId(uid);if online then display=online.DisplayName end
 local thumb="";local okT,u=pcall(function()return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)end);if okT and u then thumb=u end
 return display,name,thumb
end
local function refreshRanking()
 refreshToken+=1;local token=refreshToken
 task.spawn(function()
  local ok,pages=pcall(function()return RANK_STORE:GetSortedAsync(false,20)end)
  if not ok or not pages or token~=refreshToken then return end
  local qualifiers={}
  for _,entry in ipairs(pages:GetCurrentPage()) do
   local total=numeric(entry.value);local uid=tonumber(entry.key)
   if uid and total>=QUALIFIER_MIN then table.insert(qualifiers,{uid=uid,total=total}) end
   if #qualifiers>=3 then break end
  end
  if token~=refreshToken then return end
  for i=1,3 do
   local ref=rankRefs[i];local q=qualifiers[i]
   if q then
    local display,username,thumb=donorIdentity(q.uid)
    if token~=refreshToken then return end
    ref.name.Text=display
    ref.amount.Text=formatRobux(q.total)
    ref.source.Text="@"..username
    ref.avatar.Image=thumb
   else
    ref.name.Text="QUALIFIER SLOT EMPTY"
    ref.amount.Text="> 1.000 R$ required"
    ref.source.Text="WAITING FOR REAL CONTRIBUTION"
    ref.avatar.Image=""
   end
  end
  model:SetAttribute("QualifiedDonorCount",#qualifiers)
 end)
end
local function scheduleSave(p)
 if not p or not p.Parent then return end
 saveToken[p.UserId]=(saveToken[p.UserId] or 0)+1;local token=saveToken[p.UserId]
 task.delay(.8,function()
  if not p.Parent or saveToken[p.UserId]~=token then return end
  persistPlayer(p);task.delay(.5,refreshRanking)
 end)
end
local function wireDonor(p)
 if wiring[p.UserId] then return end;wiring[p.UserId]=true
 task.spawn(function()
  local stored=0;local ok,v=pcall(function()return SUPPORT_STORE:GetAsync(supportKey(p.UserId))end);if ok then stored=numeric(v) end
  local current=numeric(p:GetAttribute("BBYASupportRobuxTotal"))
  if stored>current then p:SetAttribute("BBYASupportRobuxTotal",stored) end
  persistPlayer(p);refreshRanking()
 end)
 p:GetAttributeChangedSignal("BBYASupportRobuxTotal"):Connect(function()scheduleSave(p)end)
 p:GetAttributeChangedSignal("BBYASultanContributionRobux"):Connect(function()scheduleSave(p)end)
end
for _,p in ipairs(Players:GetPlayers()) do wireDonor(p) end
Players.PlayerAdded:Connect(wireDonor)
Players.PlayerRemoving:Connect(function(p)
 persistPlayer(p);seen[p.UserId]=nil;saveToken[p.UserId]=nil;wiring[p.UserId]=nil
end)

task.delay(2,refreshRanking)
task.spawn(function()while task.wait(30) do refreshRanking() end end)
game:BindToClose(function()for _,p in ipairs(Players:GetPlayers()) do persistPlayer(p) end end)

print("[BBYA] Community + Owner + Top 3 Donator v1.1 online: readable neon / real donor ranking / >1000 eligibility")