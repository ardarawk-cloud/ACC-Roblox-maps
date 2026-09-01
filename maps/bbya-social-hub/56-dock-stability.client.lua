-- BBYA MUSIC UI TEST — UI KERNEL v1.2
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- ONE shell authority. No polling loops. No competing resize scripts.
-- Normal panels use the exact proven Dance v12 geometry. Music is large. Developer DJ is untouched.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local StarterGui=game:GetService("StarterGui")
local MarketplaceService=game:GetService("MarketplaceService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local clubUI=pg:WaitForChild("BBYAClubUI",30);if not clubUI then return end
local dock=clubUI:WaitForChild("TopDock",30);if not dock then return end

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local teleportRemote=remotes and remotes:FindFirstChild("Teleport")
local travelResult=remotes and remotes:FindFirstChild("TravelResult")
local wallRemote=remotes and remotes:FindFirstChild("DJWall")

local old=pg:FindFirstChild("BBYACommandMenuUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui");gui.Name="BBYACommandMenuUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=220;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("BBYAUIAuthority","UI_KERNEL_V1_2_DANCE_GEOMETRY")
gui:SetAttribute("BBYASinglePanelMode",true)
dock.Visible=false

local C={bg=Color3.fromRGB(11,11,16),panel=Color3.fromRGB(19,19,26),card=Color3.fromRGB(29,29,39),white=Color3.fromRGB(246,246,249),muted=Color3.fromRGB(158,160,172),line=Color3.fromRGB(72,75,89),pink=Color3.fromRGB(234,46,163),cyan=Color3.fromRGB(38,194,222),gold=Color3.fromRGB(220,171,92),purple=Color3.fromRGB(145,84,255),green=Color3.fromRGB(77,211,137),red=Color3.fromRGB(220,82,96)}
local function corner(o,r)local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o end
local function stroke(o,c,tr)local x=o:FindFirstChild("KernelStroke") or Instance.new("UIStroke");x.Name="KernelStroke";x.Color=c or C.line;x.Thickness=1;x.Transparency=tr or .45;x.Parent=o end
local function label(parent,value,pos,size,font,ts,color)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l end
local function button(parent,value,pos,size,color)local b=Instance.new("TextButton");b.Text=value;b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=color or C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.AutoButtonColor=true;b.Active=true;b.Selectable=true;b.Parent=parent;corner(b,9);stroke(b,C.line,.6);return b end
local function vp()camera=workspace.CurrentCamera or camera;return camera and camera.ViewportSize or Vector2.new(1280,720)end
local function normalRect()local v=vp();return math.clamp(math.floor(v.X*.19),270,320),math.clamp(math.floor(v.Y*.72),470,560)end
local function clearLegacyScale(o)if not o then return end;for _,n in ipairs({"BBYAOwnerPanelScaleV7","BBYAOwnerCommunityScaleV7","BBYAMatchDanceScaleV4","BBYAMatchDanceScaleV5","BBYAMatchDanceScaleV6","BBYAMatchDanceScaleV13","BBYAMatchDanceScaleV14"}) do local s=o:FindFirstChild(n);if s and s:IsA("UIScale") then s:Destroy() end end end
local function placeNormal(o)if not o or not o:IsA("GuiObject") then return end;clearLegacyScale(o);local w,h=normalRect();o.AnchorPoint=Vector2.new(1,.5);o.Position=UDim2.new(1,-12,.5,0);o.Size=UDim2.fromOffset(w,h);o.ClipsDescendants=true;o:SetAttribute("BBYAOuterLayoutAuthority","UI_KERNEL_V1_2_DANCE_V12")end
local function placeMusic(o)if not o or not o:IsA("GuiObject") then return end;clearLegacyScale(o);local v=vp();o.AnchorPoint=Vector2.new(.5,.5);o.Position=UDim2.fromScale(.5,.53);o.Size=UDim2.fromOffset(math.clamp(v.X-80,720,980),math.clamp(v.Y-36,480,680));o:SetAttribute("BBYAOuterLayoutAuthority","UI_KERNEL_V1_2_MUSIC")end

local menuButton=button(gui,"MENU",UDim2.new(1,-86,0,8),UDim2.fromOffset(74,36),Color3.fromRGB(18,18,25));menuButton.Name="MenuButton";stroke(menuButton,C.pink,.28)
local drawer=Instance.new("Frame");drawer.Name="FeatureDrawer";drawer.BackgroundColor3=C.bg;drawer.BackgroundTransparency=.24;drawer.BorderSizePixel=0;drawer.Visible=false;drawer.ZIndex=201;drawer.Parent=gui;corner(drawer,14);stroke(drawer,C.pink,.46);placeNormal(drawer)
local head=Instance.new("Frame");head.Position=UDim2.fromOffset(10,9);head.Size=UDim2.new(1,-20,0,50);head.BackgroundColor3=C.panel;head.BackgroundTransparency=.18;head.BorderSizePixel=0;head.ZIndex=202;head.Parent=drawer;corner(head,10)
label(head,"BBYA MENU",UDim2.fromOffset(11,4),UDim2.new(1,-22,0,22),Enum.Font.GothamBlack,13,C.white).ZIndex=203
label(head,"ALL FEATURES",UDim2.fromOffset(11,25),UDim2.new(1,-22,0,16),Enum.Font.GothamBold,8,C.muted).ZIndex=203
local list=Instance.new("ScrollingFrame");list.Name="FeatureList";list.Position=UDim2.fromOffset(10,66);list.Size=UDim2.new(1,-20,1,-76);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.Active=true;list.ScrollingEnabled=true;list.ScrollingDirection=Enum.ScrollingDirection.Y;list.ScrollBarThickness=3;list.ScrollBarImageColor3=C.pink;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ZIndex=202;list.Parent=drawer
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,7);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.HorizontalAlignment=Enum.HorizontalAlignment.Center;layout.Parent=list
local pad=Instance.new("UIPadding");pad.PaddingBottom=UDim.new(0,8);pad.Parent=list

local managed={};local current=nil
local function register(key,obj)managed[key]={obj=obj};return obj end
local function hideAll(except)
 for key,r in pairs(managed) do if key~=except and r.obj and r.obj:IsA("GuiObject") then r.obj.Visible=false end end
 local hub=clubUI:FindFirstChild("HubPanel",true);if except~="MUSIC" and hub then hub.Visible=false end
 current=except
end
local function showNormal(key,obj)hideAll(key);placeNormal(obj);obj.Visible=true;drawer.Visible=false;menuButton.Text="MENU";current=key end
local function makePanel(name,title,accent,parent)
 local p=Instance.new("Frame");p.Name=name;p.BackgroundColor3=C.bg;p.BackgroundTransparency=.28;p.BorderSizePixel=0;p.Visible=false;p.ZIndex=400;p.Active=true;p.Parent=parent or gui;corner(p,14);stroke(p,accent,.38);placeNormal(p)
 label(p,title,UDim2.fromOffset(14,10),UDim2.new(1,-54,0,28),Enum.Font.GothamBlack,14,C.white).ZIndex=402
 local close=button(p,"×",UDim2.new(1,-42,0,8),UDim2.fromOffset(32,32),C.card);close.ZIndex=403;close.Activated:Connect(function()p.Visible=false end)
 return p
end
local function toast(msg)
 local oldToast=gui:FindFirstChild("KernelToast");if oldToast then oldToast:Destroy() end
 local t=label(gui,tostring(msg),UDim2.new(.5,-150,1,-58),UDim2.fromOffset(300,38),Enum.Font.GothamBold,10,C.white);t.Name="KernelToast";t.BackgroundColor3=C.panel;t.BackgroundTransparency=.08;t.BorderSizePixel=0;t.TextXAlignment=Enum.TextXAlignment.Center;t.ZIndex=900;corner(t,9);stroke(t,C.cyan,.45);task.delay(2.2,function()if t.Parent then t:Destroy() end end)
end

local supportPanel=register("SUPPORT",makePanel("SupportPanel","SUPPORT BBYA",C.cyan,clubUI))
label(supportPanel,"Choose Robux amount",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,20),Enum.Font.GothamMedium,9,C.muted).ZIndex=402
local supportScroll=Instance.new("ScrollingFrame");supportScroll.Name="KernelSupportScroller";supportScroll.Position=UDim2.fromOffset(12,70);supportScroll.Size=UDim2.new(1,-24,1,-82);supportScroll.BackgroundTransparency=1;supportScroll.BorderSizePixel=0;supportScroll.Active=true;supportScroll.ScrollingEnabled=true;supportScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;supportScroll.CanvasSize=UDim2.new();supportScroll.ScrollBarThickness=3;supportScroll.ZIndex=402;supportScroll.Parent=supportPanel
local supLayout=Instance.new("UIListLayout");supLayout.Padding=UDim.new(0,7);supLayout.Parent=supportScroll
local PRODUCTS={[10]=3709047095,[25]=3709047097,[50]=3709047101,[100]=3709047104,[250]=3709047106,[500]=3709047107,[1000]=3709047109,[2000]=3709048779}
local purchaseBusy=false
local function buy(amount,b)
 if purchaseBusy then return end;local productId=PRODUCTS[amount];if not productId then return end
 purchaseBusy=true;local original=b.Text;b.Text="OPENING..."
 local ok=pcall(function()MarketplaceService:PromptProductPurchase(player,productId)end)
 if not ok then toast("PURCHASE PROMPT GAGAL");purchaseBusy=false;b.Text=original;return end
 task.delay(1.5,function()purchaseBusy=false;if b.Parent then b.Text=original end end)
end
for i,a in ipairs({10,25,50,100,250,500,1000,2000}) do local b=button(supportScroll,tostring(a).." ROBUX",nil,UDim2.new(1,-4,0,44),C.card);b.LayoutOrder=i;b.ZIndex=403;stroke(b,C.cyan,.58);b.Activated:Connect(function()buy(a,b)end) end
MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId,productId,isPurchased)if userId==player.UserId and isPurchased then for _,id in pairs(PRODUCTS) do if id==productId then toast("SUPPORT DITERIMA • THANK YOU");break end end end end)

local travelPanel=register("TRAVEL",makePanel("TravelPanel","TRAVEL",C.gold,clubUI))
label(travelPanel,"Tap destination",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,20),Enum.Font.GothamMedium,9,C.muted).ZIndex=402
local travelScroll=Instance.new("ScrollingFrame");travelScroll.Position=UDim2.fromOffset(12,70);travelScroll.Size=UDim2.new(1,-24,1,-82);travelScroll.BackgroundTransparency=1;travelScroll.BorderSizePixel=0;travelScroll.Active=true;travelScroll.ScrollingEnabled=true;travelScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;travelScroll.CanvasSize=UDim2.new();travelScroll.ScrollBarThickness=3;travelScroll.ZIndex=402;travelScroll.Parent=travelPanel
local trLayout=Instance.new("UIListLayout");trLayout.Padding=UDim.new(0,7);trLayout.Parent=travelScroll
local destinations={{"ARRIVAL","Arrival"},{"PHOTO STUDIO","Photo"},{"LOOK LAB","LookLab"},{"MAIN CLUB","MainClub"},{"TOILET / RESTROOM","Toilet"},{"VIP LEVEL","VIP"},{"SKATEPARK","Skatepark"},{"ROOFTOP","Rooftop"},{"UNDERGROUND","Basement"},{"FUNKOT CLUB","Funkot"},{"BBYA MALL","Mall"},{"PASAR MALAM","NightMarket"}}
local travelButtons={}
for i,d in ipairs(destinations) do local b=button(travelScroll,d[1],nil,UDim2.new(1,-4,0,44),C.card);b.LayoutOrder=i;b.ZIndex=403;stroke(b,C.gold,.6);travelButtons[d[2]]=b;b.Activated:Connect(function()if teleportRemote then b.Text="WORKING...";teleportRemote:FireServer(d[2]);task.delay(5,function()if b.Parent and b.Text=="WORKING..." then b.Text=d[1] end end)end end) end
if travelResult then travelResult.OnClientEvent:Connect(function(ok,key)local b=travelButtons[tostring(key or "")];if b then if ok then b.Text="READY";task.delay(.12,function()travelPanel.Visible=false end) else b.Text="TRY AGAIN";task.delay(1,function()for _,d in ipairs(destinations) do if d[2]==key and b.Parent then b.Text=d[1] end end end)end end end) end

local communityPanel=register("COMMUNITY",makePanel("CommunityPanel","BBYA COMMUNITY",C.cyan,clubUI))
local communityBody=Instance.new("ScrollingFrame");communityBody.Position=UDim2.fromOffset(12,52);communityBody.Size=UDim2.new(1,-24,1,-64);communityBody.BackgroundTransparency=1;communityBody.BorderSizePixel=0;communityBody.Active=true;communityBody.ScrollingEnabled=true;communityBody.AutomaticCanvasSize=Enum.AutomaticSize.Y;communityBody.CanvasSize=UDim2.new();communityBody.ScrollBarThickness=3;communityBody.ZIndex=402;communityBody.Parent=communityPanel
local comLayout=Instance.new("UIListLayout");comLayout.Padding=UDim.new(0,8);comLayout.Parent=communityBody
local function infoCard(titleText,bodyText,accent)local f=Instance.new("Frame");f.Size=UDim2.new(1,-4,0,100);f.BackgroundColor3=C.panel;f.BackgroundTransparency=.18;f.BorderSizePixel=0;f.ZIndex=402;f.Parent=communityBody;corner(f,10);stroke(f,accent,.58);label(f,titleText,UDim2.fromOffset(10,8),UDim2.new(1,-20,0,22),Enum.Font.GothamBold,11,C.white).ZIndex=403;local t=label(f,bodyText,UDim2.fromOffset(10,32),UDim2.new(1,-20,1,-40),Enum.Font.Gotham,9,C.muted);t.TextYAlignment=Enum.TextYAlignment.Top;t.ZIndex=403 end
infoCard("DISCORD COMMUNITY","Event alerts • DJ nights • updates • feedback • hangout",C.cyan);infoCard("HOW TO JOIN","Open the BBYA game page → Social Links → Discord.",C.gold);infoCard("WHY JOIN?","Early announcements • polls • music updates • community hangout",C.pink)

local partyPanel=register("PARTY",makePanel("PartyStuffPanel","PARTY STUFF",C.gold,gui))
label(partyPanel,"Equip cosmetic gear",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,20),Enum.Font.GothamMedium,9,C.muted).ZIndex=402
local partyList=Instance.new("Frame");partyList.Position=UDim2.fromOffset(12,72);partyList.Size=UDim2.new(1,-24,1,-84);partyList.BackgroundTransparency=1;partyList.ZIndex=402;partyList.Parent=partyPanel
local partyLayout=Instance.new("UIListLayout");partyLayout.Padding=UDim.new(0,8);partyLayout.Parent=partyList
local function gearRemote()return remotes and remotes:FindFirstChild("ClubGear")end
local function equipGear(name)local r=gearRemote();if r and r:IsA("RemoteEvent") then r:FireServer("equip",name) else local bp=player:FindFirstChildOfClass("Backpack");local ch=player.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid");local tool=bp and bp:FindFirstChild(name);if hum and tool then hum:EquipTool(tool) end end;partyPanel.Visible=false end
for i,g in ipairs({{"MONEY GUN","Money Gun",C.green},{"GLOWSTICK","Glowstick",C.cyan},{"PARTY SPARKLER","Party Sparkler",C.gold}}) do local b=button(partyList,g[1],nil,UDim2.new(1,0,0,50),C.card);b.LayoutOrder=i;b.ZIndex=403;stroke(b,g[3],.5);b.Activated:Connect(function()equipGear(g[2])end) end
local away=button(partyList,"SIMPAN / PUT AWAY",nil,UDim2.new(1,0,0,50),C.card);away.LayoutOrder=4;away.ZIndex=403;stroke(away,C.pink,.5);away.Activated:Connect(function()local r=gearRemote();if r and r:IsA("RemoteEvent") then r:FireServer("putAway") else local ch=player.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid");if hum then hum:UnequipTools() end end;partyPanel.Visible=false end)

local function menuEntry(textValue,order,accent,callback)local b=button(list,textValue,nil,UDim2.new(1,-4,0,44),C.card);b.LayoutOrder=order;b.ZIndex=204;stroke(b,accent,.58);b.Activated:Connect(callback);return b end
local function closeMenu()drawer.Visible=false;menuButton.Text="MENU"end
local musicButton=nil;local danceButton=nil;local carryButton=nil
local function enforceAdopted(b,labelText,order,accent)
 if not b then return end;b.Parent=list;b.LayoutOrder=order;b.Visible=true;b.Active=true;b.Selectable=true;b.AnchorPoint=Vector2.new(0,0);b.Size=UDim2.new(1,-4,0,44);b.BackgroundColor3=C.card;b.BackgroundTransparency=0;b.Text=labelText;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.ZIndex=204;corner(b,9);stroke(b,accent,.58)
 if not b:GetAttribute("BBYAUIKernelGeometryGuard") then b:SetAttribute("BBYAUIKernelGeometryGuard",true);b:GetPropertyChangedSignal("Size"):Connect(function()if b.Parent==list and b.Size~=UDim2.new(1,-4,0,44) then b.Size=UDim2.new(1,-4,0,44) end end) end
end
local function findDockMusic()for _,o in ipairs(dock:GetChildren()) do if o:IsA("TextButton") and string.upper(tostring(o.Text)):find("MUSIC",1,true) then return o end end end
local boundSocial=nil
local function bindSources()
 if not musicButton then musicButton=findDockMusic();if musicButton then enforceAdopted(musicButton,"MUSIC",1,C.pink);musicButton.Activated:Connect(function()task.defer(function()hideAll("MUSIC");closeMenu();local hub=clubUI:FindFirstChild("HubPanel",true);if hub then placeMusic(hub);hub.Visible=true end end)end) end end
 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 if social and boundSocial~=social then
  boundSocial=social;for _,o in ipairs(social:GetChildren()) do if o:IsA("TextButton") then local t=string.upper(tostring(o.Text));if t=="DANCE" then danceButton=o elseif t=="CARRY" or t=="DROP" then carryButton=o end end end
  local dp=social:FindFirstChild("DancePanel");local cp=social:FindFirstChild("CarryPanel");if dp then register("DANCE",dp);placeNormal(dp) end;if cp then register("CARRY",cp);placeNormal(cp) end
  if danceButton then enforceAdopted(danceButton,"DANCE",5,C.pink);danceButton.Activated:Connect(function()task.defer(function()if dp then showNormal("DANCE",dp) end end)end) end
  if carryButton then enforceAdopted(carryButton,"CARRY",6,C.cyan);carryButton.Activated:Connect(function()task.defer(function()if cp then showNormal("CARRY",cp) end end)end) end
 end
end

menuEntry("SUPPORT",2,C.cyan,function()showNormal("SUPPORT",supportPanel)end)
menuEntry("TRAVEL",3,C.gold,function()showNormal("TRAVEL",travelPanel)end)
menuEntry("MESSAGE",4,C.purple,function()
 hideAll("MESSAGE");closeMenu();if wallRemote then wallRemote:FireServer("config") end
 local wall=pg:FindFirstChild("BBYADJWallUI");local p=wall and wall:FindFirstChild("DJWallComposerPanel",true)
 if p then register("MESSAGE",p);local parent=p.Parent;if parent and parent:IsA("GuiObject") then parent.Visible=true;parent.BackgroundTransparency=1;parent.Active=false end;for _,d in ipairs(wall:GetChildren()) do if d:IsA("Frame") and d~=p and d.Size.X.Scale>=.95 and d.Size.Y.Scale>=.95 then d.BackgroundTransparency=1;d.Active=false end end;placeNormal(p);p.Visible=true end
end)
menuEntry("COMMUNITY",7,C.cyan,function()showNormal("COMMUNITY",communityPanel)end)
menuEntry("PARTY STUFF",8,C.gold,function()showNormal("PARTY",partyPanel);pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)end)end)
menuButton.Activated:Connect(function()if drawer.Visible then closeMenu() else hideAll(nil);placeNormal(drawer);drawer.Visible=true;menuButton.Text="CLOSE" end end)

local function layoutAll()
 placeNormal(drawer);placeNormal(supportPanel);placeNormal(travelPanel);placeNormal(communityPanel);placeNormal(partyPanel)
 if managed.DANCE and managed.DANCE.obj then placeNormal(managed.DANCE.obj) end;if managed.CARRY and managed.CARRY.obj then placeNormal(managed.CARRY.obj) end;if managed.MESSAGE and managed.MESSAGE.obj and managed.MESSAGE.obj.Visible then placeNormal(managed.MESSAGE.obj) end
 local hub=clubUI:FindFirstChild("HubPanel",true);if hub and hub.Visible and current=="MUSIC" then placeMusic(hub) end
end
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutAll) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(layoutAll)end)
pg.ChildAdded:Connect(function(child)if child.Name=="BBYASocialHangoutUI" or child.Name=="BBYADJWallUI" then task.defer(bindSources);task.delay(.15,bindSources) end end)
for i=0,8 do task.delay(i*.2,bindSources) end
task.defer(function()bindSources();layoutAll()end)
print("[BBYA TEST] UI KERNEL v1.2 online: proven Dance v12 geometry restored")
