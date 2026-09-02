-- BBYA MUSIC UI TEST — UI KERNEL v2.1
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- ONE UI shell authority. v69 geometry is locked.
-- Support/Party are server-authoritative. Music is large. Developer DJ stays full-screen.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local StarterGui=game:GetService("StarterGui")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local clubUI=pg:WaitForChild("BBYAClubUI",30); if not clubUI then return end
local dock=clubUI:WaitForChild("TopDock",30); if not dock then return end

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30); if not remotes then return end
local teleportRemote=remotes:FindFirstChild("Teleport")
local travelResult=remotes:FindFirstChild("TravelResult")
local wallRemote=remotes:FindFirstChild("DJWall")
local monetizationRemote=remotes:WaitForChild("Monetization",30)
local gearRemote=remotes:WaitForChild("ClubGear",30)

local old=pg:FindFirstChild("BBYACommandMenuUI")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="BBYACommandMenuUI"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.DisplayOrder=220; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=pg
gui:SetAttribute("BBYAUIAuthority","UI_KERNEL_V2_WHOLE_SYSTEM")
gui:SetAttribute("BBYALayoutLock","V69_COMPACT_V6")
dock.Visible=false

local C={
 bg=Color3.fromRGB(11,11,16),panel=Color3.fromRGB(19,19,26),card=Color3.fromRGB(29,29,39),
 white=Color3.fromRGB(246,246,249),muted=Color3.fromRGB(158,160,172),line=Color3.fromRGB(72,75,89),
 pink=Color3.fromRGB(234,46,163),cyan=Color3.fromRGB(38,194,222),gold=Color3.fromRGB(220,171,92),
 purple=Color3.fromRGB(145,84,255),green=Color3.fromRGB(77,211,137),red=Color3.fromRGB(220,82,96)
}
local function corner(o,r) local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner"); x.CornerRadius=UDim.new(0,r or 10); x.Parent=o end
local function stroke(o,c,tr) local x=o:FindFirstChild("KernelStroke") or Instance.new("UIStroke"); x.Name="KernelStroke"; x.Color=c or C.line; x.Thickness=1; x.Transparency=tr or .45; x.Parent=o end
local function label(parent,value,pos,size,font,ts,color)
 local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=value; l.Position=pos; l.Size=size
 l.Font=font or Enum.Font.Gotham; l.TextSize=ts or 10; l.TextColor3=color or C.white; l.TextWrapped=true
 l.TextXAlignment=Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Center; l.Parent=parent; return l
end
local function button(parent,value,pos,size,color)
 local b=Instance.new("TextButton"); b.Text=value; b.Position=pos or UDim2.new(); b.Size=size or UDim2.new()
 b.BackgroundColor3=color or C.card; b.BorderSizePixel=0; b.TextColor3=C.white; b.Font=Enum.Font.GothamBold
 b.TextSize=10; b.AutoButtonColor=true; b.Active=true; b.Selectable=true; b.Parent=parent; corner(b,9); stroke(b,C.line,.6); return b
end
local function vp() camera=workspace.CurrentCamera or camera; return camera and camera.ViewportSize or Vector2.new(1280,720) end
-- LOCKED FROM ACCEPTED v69. DO NOT CHANGE without explicit owner instruction.
local function normalRect()
 local v=vp()
 return math.clamp(math.floor(v.X*.17),210,240), math.clamp(v.Y-42,340,620)
end
local function clearLegacyScale(o)
 if not o then return end
 for _,n in ipairs({"BBYAOwnerPanelScaleV7","BBYAOwnerCommunityScaleV7","BBYAMatchDanceScaleV4","BBYAMatchDanceScaleV5","BBYAMatchDanceScaleV6","BBYAMatchDanceScaleV13","BBYAMatchDanceScaleV14"}) do
  local s=o:FindFirstChild(n); if s and s:IsA("UIScale") then s:Destroy() end
 end
end
local function placeNormal(o)
 if not o or not o:IsA("GuiObject") then return end
 clearLegacyScale(o); local w,h=normalRect()
 o.AnchorPoint=Vector2.new(1,.5); o.Position=UDim2.new(1,-12,.5,0); o.Size=UDim2.fromOffset(w,h)
 o.ClipsDescendants=true; o:SetAttribute("BBYAOuterLayoutAuthority","UI_KERNEL_V2_V69_LOCK")
end
local function placeMusic(o)
 if not o or not o:IsA("GuiObject") then return end
 clearLegacyScale(o); local v=vp()
 o.AnchorPoint=Vector2.new(.5,.5); o.Position=UDim2.fromScale(.5,.53)
 o.Size=UDim2.fromOffset(math.clamp(v.X-80,720,980),math.clamp(v.Y-36,480,680))
 o:SetAttribute("BBYAOuterLayoutAuthority","UI_KERNEL_V2_MUSIC")
end

local menuButton=button(gui,"MENU",UDim2.new(1,-86,0,8),UDim2.fromOffset(74,36),Color3.fromRGB(18,18,25))
menuButton.Name="MenuButton"; stroke(menuButton,C.pink,.28)

local drawer=Instance.new("Frame")
drawer.Name="FeatureDrawer"; drawer.BackgroundColor3=C.bg; drawer.BackgroundTransparency=.24; drawer.BorderSizePixel=0
drawer.Visible=false; drawer.ZIndex=201; drawer.Parent=gui; corner(drawer,14); stroke(drawer,C.pink,.46); placeNormal(drawer)
local head=Instance.new("Frame"); head.Position=UDim2.fromOffset(10,9); head.Size=UDim2.new(1,-20,0,50)
head.BackgroundColor3=C.panel; head.BackgroundTransparency=.18; head.BorderSizePixel=0; head.ZIndex=202; head.Parent=drawer; corner(head,10)
label(head,"BBYA MENU",UDim2.fromOffset(11,4),UDim2.new(1,-22,0,22),Enum.Font.GothamBlack,13,C.white).ZIndex=203
label(head,"ALL FEATURES",UDim2.fromOffset(11,25),UDim2.new(1,-22,0,16),Enum.Font.GothamBold,8,C.muted).ZIndex=203
local list=Instance.new("ScrollingFrame"); list.Name="FeatureList"; list.Position=UDim2.fromOffset(10,66); list.Size=UDim2.new(1,-20,1,-76)
list.BackgroundTransparency=1; list.BorderSizePixel=0; list.Active=true; list.ScrollingEnabled=true; list.ScrollingDirection=Enum.ScrollingDirection.Y
list.ScrollBarThickness=3; list.ScrollBarImageColor3=C.pink; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.ZIndex=202; list.Parent=drawer
local ll=Instance.new("UIListLayout"); ll.Padding=UDim.new(0,7); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.HorizontalAlignment=Enum.HorizontalAlignment.Center; ll.Parent=list
local pad=Instance.new("UIPadding"); pad.PaddingBottom=UDim.new(0,8); pad.Parent=list

local managed={}; local current=nil
local function register(key,obj) managed[key]=obj; return obj end
local function hideAll(except)
 for key,obj in pairs(managed) do if key~=except and obj and obj:IsA("GuiObject") then obj.Visible=false end end
 local hub=clubUI:FindFirstChild("HubPanel",true); if except~="MUSIC" and hub then hub.Visible=false end
 current=except
end
local function closeMenu() drawer.Visible=false; menuButton.Text="MENU" end
local function showNormal(key,obj)
 hideAll(key); placeNormal(obj); obj.Visible=true; closeMenu(); current=key
end
local function makePanel(name,title,accent,parent)
 local p=Instance.new("Frame"); p.Name=name; p.BackgroundColor3=C.bg; p.BackgroundTransparency=.28; p.BorderSizePixel=0
 p.Visible=false; p.ZIndex=400; p.Active=true; p.Parent=parent or gui; corner(p,14); stroke(p,accent,.38); placeNormal(p)
 label(p,title,UDim2.fromOffset(14,10),UDim2.new(1,-54,0,28),Enum.Font.GothamBlack,14,C.white).ZIndex=402
 local x=button(p,"×",UDim2.new(1,-42,0,8),UDim2.fromOffset(32,32),C.card); x.ZIndex=403; x.Activated:Connect(function() p.Visible=false end)
 return p
end
local function toast(msg)
 local oldToast=gui:FindFirstChild("KernelToast"); if oldToast then oldToast:Destroy() end
 local t=label(gui,tostring(msg),UDim2.new(.5,-170,1,-58),UDim2.fromOffset(340,38),Enum.Font.GothamBold,10,C.white)
 t.Name="KernelToast"; t.BackgroundColor3=C.panel; t.BackgroundTransparency=.08; t.BorderSizePixel=0
 t.TextXAlignment=Enum.TextXAlignment.Center; t.ZIndex=900; corner(t,9); stroke(t,C.cyan,.45)
 task.delay(3,function() if t.Parent then t:Destroy() end end)
end
local function menuEntry(textValue,order,accent,callback)
 local b=button(list,textValue,nil,UDim2.new(1,-4,0,44),C.card); b.LayoutOrder=order; b.ZIndex=204; stroke(b,accent,.58); b.Activated:Connect(callback); return b
end

-- SUPPORT: buttons ask the ONE server monetization authority. No client product IDs.
local supportPanel=register("SUPPORT",makePanel("SupportPanel","SUPPORT BBYA",C.cyan,clubUI))
label(supportPanel,"Choose Robux amount",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,20),Enum.Font.GothamMedium,9,C.muted).ZIndex=402
local supportScroll=Instance.new("ScrollingFrame"); supportScroll.Name="KernelSupportScroller"; supportScroll.Position=UDim2.fromOffset(12,70)
supportScroll.Size=UDim2.new(1,-24,1,-82); supportScroll.BackgroundTransparency=1; supportScroll.BorderSizePixel=0; supportScroll.Active=true
supportScroll.ScrollingEnabled=true; supportScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; supportScroll.CanvasSize=UDim2.new(); supportScroll.ScrollBarThickness=3; supportScroll.ZIndex=402; supportScroll.Parent=supportPanel
local sl=Instance.new("UIListLayout"); sl.Padding=UDim.new(0,7); sl.Parent=supportScroll
local supportButtons={}
for i,a in ipairs({10,25,50,100,250,500,1000,2000}) do
 local b=button(supportScroll,tostring(a).." ROBUX",nil,UDim2.new(1,-4,0,44),C.card); b.LayoutOrder=i; b.ZIndex=403; stroke(b,C.cyan,.58); supportButtons[a]=b
 b.Activated:Connect(function()
  b.Text="OPENING..."; monetizationRemote:FireServer("promptSupport",a)
  task.delay(4,function() if b.Parent and b.Text=="OPENING..." then b.Text=tostring(a).." ROBUX" end end)
 end)
end

-- TRAVEL
local travelPanel=register("TRAVEL",makePanel("TravelPanel","TRAVEL",C.gold,clubUI))
label(travelPanel,"Tap destination",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,20),Enum.Font.GothamMedium,9,C.muted).ZIndex=402
local travelScroll=Instance.new("ScrollingFrame"); travelScroll.Position=UDim2.fromOffset(12,70); travelScroll.Size=UDim2.new(1,-24,1,-82)
travelScroll.BackgroundTransparency=1; travelScroll.BorderSizePixel=0; travelScroll.Active=true; travelScroll.ScrollingEnabled=true
travelScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; travelScroll.CanvasSize=UDim2.new(); travelScroll.ScrollBarThickness=3; travelScroll.ZIndex=402; travelScroll.Parent=travelPanel
local tl=Instance.new("UIListLayout"); tl.Padding=UDim.new(0,7); tl.Parent=travelScroll
local destinations={{"ARRIVAL","Arrival"},{"PHOTO STUDIO","Photo"},{"LOOK LAB","LookLab"},{"MAIN CLUB","MainClub"},{"TOILET / RESTROOM","Toilet"},{"VIP LEVEL","VIP"},{"SKATEPARK","Skatepark"},{"ROOFTOP","Rooftop"},{"UNDERGROUND","Basement"},{"FUNKOT CLUB","Funkot"},{"BBYA MALL","Mall"},{"PASAR MALAM","NightMarket"}}
local travelButtons={}
for i,d in ipairs(destinations) do
 local b=button(travelScroll,d[1],nil,UDim2.new(1,-4,0,44),C.card); b.LayoutOrder=i; b.ZIndex=403; stroke(b,C.gold,.6); travelButtons[d[2]]=b
 b.Activated:Connect(function()
  if teleportRemote then b.Text="WORKING..."; teleportRemote:FireServer(d[2]); task.delay(5,function() if b.Parent and b.Text=="WORKING..." then b.Text=d[1] end end) end
 end)
end
if travelResult then travelResult.OnClientEvent:Connect(function(ok,key)
 local b=travelButtons[tostring(key or "")]; if not b then return end
 if ok then b.Text="READY"; task.delay(.12,function() travelPanel.Visible=false end)
 else b.Text="TRY AGAIN"; task.delay(1,function() for _,d in ipairs(destinations) do if d[2]==key and b.Parent then b.Text=d[1] end end end) end
end) end

-- COMMUNITY
local communityPanel=register("COMMUNITY",makePanel("CommunityPanel","BBYA COMMUNITY",C.cyan,clubUI))
local communityBody=Instance.new("ScrollingFrame"); communityBody.Position=UDim2.fromOffset(12,52); communityBody.Size=UDim2.new(1,-24,1,-64)
communityBody.BackgroundTransparency=1; communityBody.BorderSizePixel=0; communityBody.Active=true; communityBody.ScrollingEnabled=true
communityBody.AutomaticCanvasSize=Enum.AutomaticSize.Y; communityBody.CanvasSize=UDim2.new(); communityBody.ScrollBarThickness=3; communityBody.ZIndex=402; communityBody.Parent=communityPanel
local cl=Instance.new("UIListLayout"); cl.Padding=UDim.new(0,8); cl.Parent=communityBody
local function infoCard(titleText,bodyText,accent)
 local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,100); f.BackgroundColor3=C.panel; f.BackgroundTransparency=.18; f.BorderSizePixel=0; f.ZIndex=402; f.Parent=communityBody; corner(f,10); stroke(f,accent,.58)
 label(f,titleText,UDim2.fromOffset(10,8),UDim2.new(1,-20,0,22),Enum.Font.GothamBold,11,C.white).ZIndex=403
 local t=label(f,bodyText,UDim2.fromOffset(10,32),UDim2.new(1,-20,1,-40),Enum.Font.Gotham,9,C.muted); t.TextYAlignment=Enum.TextYAlignment.Top; t.ZIndex=403
end
infoCard("DISCORD COMMUNITY","Event alerts • DJ nights • updates • feedback • hangout",C.cyan)
infoCard("HOW TO JOIN","Open the BBYA game page → Social Links → Discord.",C.gold)
infoCard("WHY JOIN?","Early announcements • polls • music updates • community hangout",C.pink)

-- PARTY STUFF: gear stays equipped, but Roblox Backpack/hotbar stays hidden while Party gear is active.
local partyPanel=register("PARTY",makePanel("PartyStuffPanel","PARTY STUFF",C.gold,gui))
label(partyPanel,"Equip cosmetic gear",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,20),Enum.Font.GothamMedium,9,C.muted).ZIndex=402
local partyList=Instance.new("Frame"); partyList.Position=UDim2.fromOffset(12,72); partyList.Size=UDim2.new(1,-24,1,-84); partyList.BackgroundTransparency=1; partyList.ZIndex=402; partyList.Parent=partyPanel
local pl=Instance.new("UIListLayout"); pl.Padding=UDim.new(0,8); pl.Parent=partyList
local function setBackpackVisible(enabled)
 pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,enabled) end)
end
local function requestGear(name)
 setBackpackVisible(false)
 toast("EQUIPPING "..string.upper(name).."..."); gearRemote:FireServer("equip",name)
end
for i,g in ipairs({{"MONEY GUN","Money Gun",C.green},{"GLOWSTICK","Glowstick",C.cyan},{"PARTY SPARKLER","Party Sparkler",C.gold}}) do
 local b=button(partyList,g[1],nil,UDim2.new(1,0,0,50),C.card); b.LayoutOrder=i; b.ZIndex=403; stroke(b,g[3],.5)
 b.Activated:Connect(function() requestGear(g[2]) end)
end
local away=button(partyList,"SIMPAN / PUT AWAY",nil,UDim2.new(1,0,0,50),C.card); away.LayoutOrder=4; away.ZIndex=403; stroke(away,C.pink,.5)
away.Activated:Connect(function() gearRemote:FireServer("putAway") end)

-- Menu entries. Their outer geometry is all owned here.
menuEntry("MUSIC",1,C.pink,function()
 hideAll("MUSIC"); closeMenu(); local hub=clubUI:FindFirstChild("HubPanel",true)
 if hub then placeMusic(hub); hub.Visible=true; current="MUSIC" end
end)
menuEntry("SUPPORT",2,C.cyan,function() showNormal("SUPPORT",supportPanel) end)
menuEntry("TRAVEL",3,C.gold,function() showNormal("TRAVEL",travelPanel) end)
menuEntry("MESSAGE",4,C.purple,function()
 hideAll("MESSAGE"); closeMenu(); if wallRemote then wallRemote:FireServer("config") end
 local wall=pg:FindFirstChild("BBYADJWallUI"); local p=wall and wall:FindFirstChild("DJWallComposerPanel",true)
 if p then register("MESSAGE",p); placeNormal(p); p.Visible=true; current="MESSAGE" end
end)
menuEntry("DANCE",5,C.pink,function()
 local social=pg:FindFirstChild("BBYASocialHangoutUI"); local dp=social and social:FindFirstChild("DancePanel")
 if dp then register("DANCE",dp); showNormal("DANCE",dp) else toast("DANCE LOADING...") end
end)
menuEntry("CARRY",6,C.cyan,function()
 local social=pg:FindFirstChild("BBYASocialHangoutUI"); local cp=social and social:FindFirstChild("CarryPanel")
 if cp then register("CARRY",cp); showNormal("CARRY",cp) else toast("CARRY LOADING...") end
end)
menuEntry("COMMUNITY",7,C.cyan,function() showNormal("COMMUNITY",communityPanel) end)
menuEntry("PARTY STUFF",8,C.gold,function() showNormal("PARTY",partyPanel); setBackpackVisible(false) end)
menuEntry("DJ LIVE",9,C.gold,function()
 hideAll("DJ"); closeMenu()
 local dj=pg:FindFirstChild("BBYADeveloperDJUI"); local p=dj and dj:FindFirstChild("DeveloperDJMixerPanel",true)
 if p then p.Visible=true; current="DJ" else toast("DJ LIVE NOT AVAILABLE") end
end)

menuButton.Activated:Connect(function()
 if drawer.Visible then closeMenu() else hideAll(nil); placeNormal(drawer); drawer.Visible=true; menuButton.Text="CLOSE" end
end)

monetizationRemote.OnClientEvent:Connect(function(action,data)
 data=type(data)=="table" and data or {}
 if action=="status" then
  local amount=tonumber(data.amount)
  if amount and supportButtons[amount] then supportButtons[amount].Text=tostring(amount).." ROBUX" end
  if data.message then toast(data.message) end
 elseif action=="receipt" then
  local amount=tonumber(data.amount)
  if amount and supportButtons[amount] then supportButtons[amount].Text=tostring(amount).." ROBUX" end
  toast(data.message or "SUPPORT RECEIVED • THANK YOU")
 end
end)
gearRemote.OnClientEvent:Connect(function(action,data)
 data=type(data)=="table" and data or {}
 if action=="result" then
  local gearName=tostring(data.name or "")
  if data.ok then
   if gearName=="" then setBackpackVisible(true) else setBackpackVisible(false) end
   partyPanel.Visible=false; toast(data.message or ("EQUIPPED • "..gearName))
  else
   setBackpackVisible(true); toast(data.message or "PARTY GEAR FAILED")
  end
 end
end)
player.CharacterAdded:Connect(function() task.defer(function() setBackpackVisible(true) end) end)

local function layoutAll()
 placeNormal(drawer); placeNormal(supportPanel); placeNormal(travelPanel); placeNormal(communityPanel); placeNormal(partyPanel)
 for _,key in ipairs({"DANCE","CARRY","MESSAGE"}) do local o=managed[key]; if o and o.Visible then placeNormal(o) end end
 local hub=clubUI:FindFirstChild("HubPanel",true); if hub and hub.Visible and current=="MUSIC" then placeMusic(hub) end
end
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutAll) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() camera=workspace.CurrentCamera; task.defer(layoutAll) end)
task.defer(layoutAll)
print("[BBYA TEST] UI KERNEL v2.1 online: v69 geometry locked + Party hotbar hidden while equipped")
