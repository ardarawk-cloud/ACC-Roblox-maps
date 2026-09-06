-- BBYA SOCIAL HUB — UI KERNEL v3 CLEAN GENERAL PANEL REBUILD
-- Clean authority after repeated QC regressions.
-- GENERAL PANEL is restored to the original narrow right-side footprint; other compact panels follow it.
-- MUSIC, MESSAGE, ROLE and DJ LIVE own their dedicated layouts and are never resized by this kernel.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local StarterGui=game:GetService("StarterGui")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local clubUI=pg:WaitForChild("BBYAClubUI",30);if not clubUI then return end
local dock=clubUI:WaitForChild("TopDock",30);if not dock then return end
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30);if not remotes then return end

local teleportRemote=remotes:FindFirstChild("Teleport")
local travelResult=remotes:FindFirstChild("TravelResult")
local wallRemote=remotes:FindFirstChild("DJWall")
local monetizationRemote=remotes:WaitForChild("Monetization",30)
local gearRemote=remotes:WaitForChild("ClubGear",30)
local afkRemote=remotes:WaitForChild("AFKStatus",30)

local old=pg:FindFirstChild("BBYACommandMenuUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="BBYACommandMenuUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=220;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("BBYAUIAuthority","UI_KERNEL_V3_CLEAN_GENERAL_PANEL")
gui:SetAttribute("BBYALayoutLock","GENERAL_PANEL_ORIGINAL_NARROW")
dock.Visible=false

local C={bg=Color3.fromRGB(11,11,16),panel=Color3.fromRGB(19,19,26),card=Color3.fromRGB(29,29,39),white=Color3.fromRGB(246,246,249),muted=Color3.fromRGB(158,160,172),line=Color3.fromRGB(72,75,89),pink=Color3.fromRGB(234,46,163),cyan=Color3.fromRGB(38,194,222),gold=Color3.fromRGB(220,171,92),purple=Color3.fromRGB(145,84,255),green=Color3.fromRGB(77,211,137)}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o end
local function stroke(o,c,tr)local x=Instance.new("UIStroke");x.Name="KernelStroke";x.Color=c or C.line;x.Thickness=1;x.Transparency=tr or .45;x.Parent=o end
local function label(parent,value,pos,size,font,ts,color)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=tostring(value or "");l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
end
local function button(parent,value,pos,size,color)
 local b=Instance.new("TextButton");b.Text=tostring(value or "");b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=color or C.card;b.BackgroundTransparency=.10;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.AutoButtonColor=true;b.Active=true;b.Parent=parent;corner(b,9);stroke(b,C.line,.6);return b
end
local function viewport()camera=workspace.CurrentCamera or camera;return camera and camera.ViewportSize or Vector2.new(1280,720)end
local function generalRect()
 local v=viewport()
 return math.clamp(math.floor(v.X*.17),210,240),math.clamp(v.Y-42,340,620)
end
local function placeGeneral(o)
 if not o or not o:IsA("GuiObject") then return end
 local w,h=generalRect();o.AnchorPoint=Vector2.new(1,.5);o.Position=UDim2.new(1,-12,.5,0);o.Size=UDim2.fromOffset(w,h);o.ClipsDescendants=true;o:SetAttribute("BBYAOuterLayoutAuthority","GENERAL_PANEL_ORIGINAL_NARROW_V1")
end
local function setBackpackVisible(enabled)pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,enabled)end)end

local menuButton=button(gui,"MENU",UDim2.new(1,-86,0,8),UDim2.fromOffset(74,36),Color3.fromRGB(18,18,25));menuButton.Name="MenuButton";stroke(menuButton,C.pink,.28)
local drawer=Instance.new("Frame");drawer.Name="FeatureDrawer";drawer.BackgroundColor3=C.bg;drawer.BackgroundTransparency=.32;drawer.BorderSizePixel=0;drawer.Visible=false;drawer.ZIndex=201;drawer.Parent=gui;corner(drawer,14);stroke(drawer,C.pink,.46);placeGeneral(drawer)
local head=Instance.new("Frame");head.Position=UDim2.fromOffset(10,9);head.Size=UDim2.new(1,-20,0,50);head.BackgroundColor3=C.panel;head.BackgroundTransparency=.28;head.BorderSizePixel=0;head.ZIndex=202;head.Parent=drawer;corner(head,10)
label(head,"BBYA MENU",UDim2.fromOffset(11,4),UDim2.new(1,-22,0,22),Enum.Font.GothamBlack,13,C.white).ZIndex=203
label(head,"ALL FEATURES",UDim2.fromOffset(11,25),UDim2.new(1,-22,0,16),Enum.Font.GothamBold,8,C.muted).ZIndex=203
local list=Instance.new("ScrollingFrame");list.Name="FeatureList";list.Position=UDim2.fromOffset(10,66);list.Size=UDim2.new(1,-20,1,-76);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.Active=true;list.ScrollingEnabled=true;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ScrollBarThickness=3;list.ScrollBarImageColor3=C.pink;list.ZIndex=202;list.Parent=drawer
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,7);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.HorizontalAlignment=Enum.HorizontalAlignment.Center;layout.Parent=list
local pad=Instance.new("UIPadding");pad.PaddingBottom=UDim.new(0,8);pad.Parent=list

local managed={};local current=nil;local visibilityBound={}
local function restoreMenu()current=nil;menuButton.Visible=true;menuButton.Text="MENU"end
local function register(key,obj)
 managed[key]=obj
 if obj and obj:IsA("GuiObject") and not visibilityBound[obj] then visibilityBound[obj]=true;obj:GetPropertyChangedSignal("Visible"):Connect(function()if not obj.Visible and current==key then restoreMenu()end end)end
 return obj
end
local function hideAll(except)
 for k,o in pairs(managed)do if k~=except and o and o:IsA("GuiObject")then o.Visible=false end end
 current=except
end
local function showGeneral(key,obj)hideAll(key);placeGeneral(obj);obj.Visible=true;drawer.Visible=false;menuButton.Visible=false;current=key end
local function makePanel(name,title,accent)
 local p=Instance.new("Frame");p.Name=name;p.BackgroundColor3=C.bg;p.BackgroundTransparency=.34;p.BorderSizePixel=0;p.Visible=false;p.ZIndex=400;p.Active=true;p.Parent=gui;corner(p,14);stroke(p,accent,.38);placeGeneral(p)
 label(p,title,UDim2.fromOffset(14,10),UDim2.new(1,-54,0,28),Enum.Font.GothamBlack,14,C.white).ZIndex=402
 local x=button(p,"×",UDim2.new(1,-42,0,8),UDim2.fromOffset(32,32),C.card);x.TextSize=18;x.ZIndex=403;x.Activated:Connect(function()p.Visible=false end)
 return p
end
local function toast(msg)
 local oldToast=gui:FindFirstChild("KernelToast");if oldToast then oldToast:Destroy() end
 local t=label(gui,msg,UDim2.new(.5,-160,1,-54),UDim2.fromOffset(320,36),Enum.Font.GothamBold,9,C.white);t.Name="KernelToast";t.BackgroundColor3=C.panel;t.BackgroundTransparency=.14;t.BorderSizePixel=0;t.TextXAlignment=Enum.TextXAlignment.Center;t.ZIndex=900;corner(t,9);stroke(t,C.cyan,.45);task.delay(2.5,function()if t.Parent then t:Destroy()end end)
end
local function menuEntry(textValue,order,accent,callback)
 local parent=list
 if textValue=="MUSIC"then local slot=Instance.new("Frame");slot.Name="Slot_MUSIC";slot.LayoutOrder=order;slot.Size=UDim2.new(1,-4,0,44);slot.BackgroundTransparency=1;slot.BorderSizePixel=0;slot.ZIndex=203;slot.Parent=list;parent=slot end
 local b=button(parent,textValue,nil,textValue=="MUSIC"and UDim2.fromScale(1,1)or UDim2.new(1,-4,0,44),C.card);b.LayoutOrder=order;b.ZIndex=204;b:SetAttribute("BBYACommandMenuId",textValue);stroke(b,accent,.58);b.Activated:Connect(callback);return b
end

local supportPanel=register("SUPPORT",makePanel("SupportPanel","SUPPORT BBYA",C.cyan))
label(supportPanel,"Choose Robux amount",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,20),Enum.Font.GothamMedium,9,C.muted).ZIndex=402
local supportScroll=Instance.new("ScrollingFrame");supportScroll.Position=UDim2.fromOffset(12,70);supportScroll.Size=UDim2.new(1,-24,1,-82);supportScroll.BackgroundTransparency=1;supportScroll.BorderSizePixel=0;supportScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;supportScroll.CanvasSize=UDim2.new();supportScroll.ScrollBarThickness=3;supportScroll.ZIndex=402;supportScroll.Parent=supportPanel
local sl=Instance.new("UIListLayout");sl.Padding=UDim.new(0,7);sl.Parent=supportScroll
local supportButtons={}
for i,a in ipairs({10,25,50,100,250,500,1000,2000})do local b=button(supportScroll,tostring(a).." ROBUX",nil,UDim2.new(1,-4,0,44),C.card);b.LayoutOrder=i;b.ZIndex=403;stroke(b,C.cyan,.58);supportButtons[a]=b;b.Activated:Connect(function()b.Text="OPENING...";monetizationRemote:FireServer("promptSupport",a);task.delay(3,function()if b.Parent then b.Text=tostring(a).." ROBUX"end end)end)end

local travelPanel=register("TRAVEL",makePanel("TravelPanel","TRAVEL",C.gold))
local travelStatus=label(travelPanel,"Tap destination",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,20),Enum.Font.GothamMedium,9,C.muted);travelStatus.ZIndex=402
local travelScroll=Instance.new("ScrollingFrame");travelScroll.Position=UDim2.fromOffset(12,70);travelScroll.Size=UDim2.new(1,-24,1,-82);travelScroll.BackgroundTransparency=1;travelScroll.BorderSizePixel=0;travelScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;travelScroll.CanvasSize=UDim2.new();travelScroll.ScrollBarThickness=3;travelScroll.ZIndex=402;travelScroll.Parent=travelPanel
local tl=Instance.new("UIListLayout");tl.Padding=UDim.new(0,7);tl.Parent=travelScroll
for i,d in ipairs({{"ARRIVAL","Arrival"},{"PHOTO STUDIO","Photo"},{"LOOK LAB","LookLab"},{"MAIN CLUB","MainClub"},{"TOILET / RESTROOM","Toilet"},{"VIP LEVEL","VIP"},{"SKATEPARK","Skatepark"},{"ROOFTOP","Rooftop"},{"UNDERGROUND","Basement"},{"FUNKOT CLUB","Funkot"},{"BBYA MALL","Mall"},{"PASAR MALAM","NightMarket"}})do local b=button(travelScroll,d[1],nil,UDim2.new(1,-4,0,44),C.card);b.LayoutOrder=i;b.ZIndex=403;stroke(b,C.gold,.6);b.Activated:Connect(function()if teleportRemote then travelStatus.Text="Traveling to "..d[1];teleportRemote:FireServer(d[2])end end)end
if travelResult then travelResult.OnClientEvent:Connect(function(ok,key)travelStatus.Text=ok and("Arrived • "..tostring(key))or("Try again • "..tostring(key));if ok then task.delay(.12,function()travelPanel.Visible=false end)end end)end

local communityPanel=register("COMMUNITY",makePanel("CommunityPanel","BBYA COMMUNITY",C.cyan))
local communityBody=Instance.new("ScrollingFrame");communityBody.Position=UDim2.fromOffset(12,52);communityBody.Size=UDim2.new(1,-24,1,-64);communityBody.BackgroundTransparency=1;communityBody.BorderSizePixel=0;communityBody.AutomaticCanvasSize=Enum.AutomaticSize.Y;communityBody.CanvasSize=UDim2.new();communityBody.ScrollBarThickness=3;communityBody.ZIndex=402;communityBody.Parent=communityPanel
local cl=Instance.new("UIListLayout");cl.Padding=UDim.new(0,8);cl.Parent=communityBody
for _,spec in ipairs({{"DISCORD COMMUNITY","Event alerts • DJ nights • updates • feedback • hangout",C.cyan},{"HOW TO JOIN","Open the BBYA game page → Social Links → Discord.",C.gold},{"WHY JOIN?","Early announcements • polls • music updates • community hangout",C.pink}})do local f=Instance.new("Frame");f.Size=UDim2.new(1,-4,0,100);f.BackgroundColor3=C.panel;f.BackgroundTransparency=.28;f.BorderSizePixel=0;f.ZIndex=402;f.Parent=communityBody;corner(f,10);stroke(f,spec[3],.58);label(f,spec[1],UDim2.fromOffset(10,8),UDim2.new(1,-20,0,22),Enum.Font.GothamBold,11,C.white).ZIndex=403;local t=label(f,spec[2],UDim2.fromOffset(10,32),UDim2.new(1,-20,1,-40),Enum.Font.Gotham,9,C.muted);t.TextYAlignment=Enum.TextYAlignment.Top;t.ZIndex=403 end

local partyPanel=register("PARTY",makePanel("PartyStuffPanel","PARTY STUFF",C.gold))
label(partyPanel,"Gear + AFK sign",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,20),Enum.Font.GothamMedium,9,C.muted).ZIndex=402
local partyList=Instance.new("Frame");partyList.Position=UDim2.fromOffset(12,72);partyList.Size=UDim2.new(1,-24,1,-84);partyList.BackgroundTransparency=1;partyList.ZIndex=402;partyList.Parent=partyPanel
local pl=Instance.new("UIListLayout");pl.Padding=UDim.new(0,8);pl.Parent=partyList
for i,g in ipairs({{"MONEY GUN","Money Gun",C.green},{"GLOWSTICK","Glowstick",C.cyan},{"PARTY SPARKLER","Party Sparkler",C.gold}})do local b=button(partyList,g[1],nil,UDim2.new(1,0,0,50),C.card);b.LayoutOrder=i;b.ZIndex=403;stroke(b,g[3],.5);b.Activated:Connect(function()setBackpackVisible(false);gearRemote:FireServer("equip",g[2])end)end
local afkButton=button(partyList,"AFK SIGN",nil,UDim2.new(1,0,0,50),C.card);afkButton.LayoutOrder=4;afkButton.ZIndex=403;stroke(afkButton,C.gold,.42)
local function refreshAFK()afkButton.Text=player:GetAttribute("BBYAAFKManual")==true and"AFK SIGN • ON"or"AFK SIGN"end
afkButton.Activated:Connect(function()afkRemote:FireServer("manualToggle")end)
local away=button(partyList,"SIMPAN / PUT AWAY",nil,UDim2.new(1,0,0,50),C.card);away.LayoutOrder=5;away.ZIndex=403;away.Activated:Connect(function()gearRemote:FireServer("putAway")end)

menuEntry("MUSIC",1,C.pink,function()drawer.Visible=false;menuButton.Visible=false;current="MUSIC"end)
menuEntry("SUPPORT",2,C.cyan,function()showGeneral("SUPPORT",supportPanel)end)
menuEntry("TRAVEL",3,C.gold,function()travelStatus.Text="Tap destination";showGeneral("TRAVEL",travelPanel)end)
menuEntry("MESSAGE",4,C.purple,function()
 drawer.Visible=false;menuButton.Visible=false;current="MESSAGE";if wallRemote then wallRemote:FireServer("config")end
 local wall=pg:FindFirstChild("BBYADJWallUI");local p=wall and wall:FindFirstChild("DJWallComposerPanel",true)
 if p then register("MESSAGE",p);p.Visible=true else restoreMenu()end
end)
menuEntry("DANCE",5,C.pink,function()local social=pg:FindFirstChild("BBYASocialHangoutUI");local p=social and social:FindFirstChild("DancePanel");if p then register("DANCE",p);showGeneral("DANCE",p)else toast("DANCE LOADING...")end end)
menuEntry("CARRY",6,C.cyan,function()local social=pg:FindFirstChild("BBYASocialHangoutUI");local p=social and social:FindFirstChild("CarryPanel");if p then register("CARRY",p);showGeneral("CARRY",p)else toast("CARRY LOADING...")end end)
menuEntry("COMMUNITY",7,C.cyan,function()showGeneral("COMMUNITY",communityPanel)end)
menuEntry("PARTY STUFF",8,C.gold,function()showGeneral("PARTY",partyPanel);setBackpackVisible(false);refreshAFK()end)
local djEntry=menuEntry("DJ LIVE",9,C.gold,function()
 local dj=pg:FindFirstChild("BBYADJLiveCleanUI");local p=dj and dj:FindFirstChild("DJLivePanel",true)
 if p then drawer.Visible=false;menuButton.Visible=false;current="DJ";p.Visible=true else toast("DJ LIVE LOADING...")end
end)
local function refreshDJEntry()if djEntry then djEntry.Visible=player:GetAttribute("BBYAOwner")==true or(player:GetAttribute("BBYAHasDJRole")==true and player:GetAttribute("BBYAManagedRole")=="DJ")or string.lower(player.Name)=="nadmo97"or string.lower(player.Name)=="arda_moron123"end end

menuButton.Activated:Connect(function()if drawer.Visible then drawer.Visible=false else hideAll(nil);placeGeneral(drawer);drawer.Visible=true end end)
monetizationRemote.OnClientEvent:Connect(function(action,data)data=type(data)=="table"and data or{};if action=="status"or action=="receipt"then local amount=tonumber(data.amount);if amount and supportButtons[amount]then supportButtons[amount].Text=tostring(amount).." ROBUX"end;if data.message then toast(data.message)end end end)
gearRemote.OnClientEvent:Connect(function(action,data)data=type(data)=="table"and data or{};if action=="result"then if data.ok then partyPanel.Visible=false;toast(data.message or"EQUIPPED")else setBackpackVisible(true);toast(data.message or"PARTY GEAR FAILED")end end end)
if afkRemote then afkRemote.OnClientEvent:Connect(function(action)if action=="manualState"then refreshAFK()end end)end
player:GetAttributeChangedSignal("BBYAHasDJRole"):Connect(refreshDJEntry);player:GetAttributeChangedSignal("BBYAManagedRole"):Connect(refreshDJEntry);player:GetAttributeChangedSignal("BBYAOwner"):Connect(refreshDJEntry);player:GetAttributeChangedSignal("BBYAAFKManual"):Connect(refreshAFK)

local function watchExternal(name,key)
 local g=pg:FindFirstChild(name);if not g then return end
 for _,d in ipairs(g:GetDescendants())do if d:IsA("GuiObject")and(d.Name=="RolePanel"or d.Name=="DJLivePanel"or d.Name=="DJWallComposerPanel")then register(key,d)end end
end
pg.ChildAdded:Connect(function(child)if child.Name=="BBYAMusicSuiteV1"then child:GetPropertyChangedSignal("Enabled"):Connect(function()if child.Enabled then drawer.Visible=false;menuButton.Visible=false;current="MUSIC"elseif current=="MUSIC"then restoreMenu()end end)elseif child.Name=="BBYADJWallUI"then task.defer(function()watchExternal("BBYADJWallUI","MESSAGE")end)end end)
local function layoutAll()placeGeneral(drawer);placeGeneral(supportPanel);placeGeneral(travelPanel);placeGeneral(communityPanel);placeGeneral(partyPanel);for _,k in ipairs({"DANCE","CARRY"})do local o=managed[k];if o and o.Visible then placeGeneral(o)end end end
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutAll)end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(layoutAll)end)
player.CharacterAdded:Connect(function()setBackpackVisible(true);restoreMenu();refreshAFK();refreshDJEntry()end)
task.defer(function()layoutAll();refreshAFK();refreshDJEntry()end)
print("[BBYA] UI Kernel v3 online: original narrow General Panel restored / dedicated panels untouched")