-- BBYA SOCIAL HUB — MALL COMMERCE UI v7
-- Reference-driven modular catalog UI for mobile/landscape.
-- SHOP / TRY / CART / SAVED modules, avatar preview, horizontal product rail,
-- Roblox-native catalog + checkout. Test candidate only until owner acceptance.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AvatarEditorService=game:GetService("AvatarEditorService")
local MarketplaceService=game:GetService("MarketplaceService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local remote=remotes:WaitForChild("MallRobuxCommerce")

local old=pg:FindFirstChild("BBYAMallRobuxCommerceUI")
if old then old:Destroy() end

local C={
 bg=Color3.fromRGB(13,14,17), panel=Color3.fromRGB(24,25,29), card=Color3.fromRGB(36,37,42), card2=Color3.fromRGB(46,47,53),
 white=Color3.fromRGB(245,244,241), muted=Color3.fromRGB(164,165,172), line=Color3.fromRGB(70,71,78),
 gold=Color3.fromRGB(223,184,111), green=Color3.fromRGB(73,218,133), pink=Color3.fromRGB(236,65,153), cyan=Color3.fromRGB(54,199,220),
 red=Color3.fromRGB(218,77,83)
}

local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o;return c end
local function stroke(o,col,t,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=t or 1;s.Transparency=tr or .45;s.Parent=o;return s end
local function label(parent,text,pos,size,font,ts,col)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 11;l.TextColor3=col or C.white;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.BorderSizePixel=0;b.AutoButtonColor=true;b.Active=true;b.Selectable=true;b.Parent=parent;round(b,8);return b
end
local function image(parent,pos,size)
 local i=Instance.new("ImageLabel");i.Position=pos;i.Size=size;i.BackgroundColor3=C.card2;i.BorderSizePixel=0;i.ScaleType=Enum.ScaleType.Crop;i.Parent=parent;round(i,8);return i
end

local STORE_TYPES={
 FASHION={Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.TShirt,Enum.AvatarAssetType.Pants,Enum.AvatarAssetType.TShirtAccessory,Enum.AvatarAssetType.ShirtAccessory,Enum.AvatarAssetType.JacketAccessory,Enum.AvatarAssetType.SweaterAccessory,Enum.AvatarAssetType.PantsAccessory,Enum.AvatarAssetType.ShortsAccessory,Enum.AvatarAssetType.DressSkirtAccessory},
 SHOES={Enum.AvatarAssetType.LeftShoeAccessory,Enum.AvatarAssetType.RightShoeAccessory},
 BEAUTY={Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.FaceMakeup,Enum.AvatarAssetType.LipMakeup,Enum.AvatarAssetType.EyeMakeup},
 STREET={Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.NeckAccessory,Enum.AvatarAssetType.ShoulderAccessory,Enum.AvatarAssetType.FrontAccessory,Enum.AvatarAssetType.BackAccessory,Enum.AvatarAssetType.WaistAccessory},
}
local STORE_TRENDS={FASHION={"Y2K","streetwear","grunge"},SHOES={"shoes","sneakers","boots"},BEAUTY={"hair","makeup","baddie"},STREET={"streetwear","goth","cyber"}}
local ACCESSORY_MAP={
 Hat="Hat",HairAccessory="Hair",FaceAccessory="Face",NeckAccessory="Neck",ShoulderAccessory="Shoulder",FrontAccessory="Front",BackAccessory="Back",WaistAccessory="Waist",
 TShirtAccessory="TShirt",ShirtAccessory="Shirt",SweaterAccessory="Sweater",JacketAccessory="Jacket",PantsAccessory="Pants",ShortsAccessory="Shorts",DressSkirtAccessory="DressSkirt",LeftShoeAccessory="LeftShoe",RightShoeAccessory="RightShoe"
}

local gui=Instance.new("ScreenGui")
gui.Name="BBYAMallRobuxCommerceUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=94;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
local dim=button(gui,"",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Color3.new(0,0,0));dim.Name="Dim";dim.BackgroundTransparency=.84;dim.AutoButtonColor=false;dim.Visible=false;dim.ZIndex=1
local panel=Instance.new("Frame")
panel.Name="Panel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.54);panel.Size=UDim2.fromOffset(860,410);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=2;panel.Parent=gui;round(panel,15);stroke(panel,C.gold,1,.48)

local title=label(panel,"BBYA MALL",UDim2.fromOffset(14,8),UDim2.new(1,-62,0,20),Enum.Font.GothamBold,15,C.white);title.ZIndex=3
local subtitle=label(panel,"CATALOG STUDIO",UDim2.fromOffset(14,27),UDim2.new(1,-62,0,14),Enum.Font.GothamBold,8,C.gold);subtitle.ZIndex=3
local close=button(panel,"×",UDim2.new(1,-42,0,7),UDim2.fromOffset(30,30),C.card2);close.TextSize=18;close.ZIndex=5

-- LEFT: avatar / selected item preview. World stays visible around the panel.
local previewPane=Instance.new("Frame");previewPane.Name="AvatarPreview";previewPane.Position=UDim2.fromOffset(12,50);previewPane.Size=UDim2.new(.31,-17,1,-104);previewPane.BackgroundColor3=C.panel;previewPane.BorderSizePixel=0;previewPane.ZIndex=3;previewPane.Parent=panel;round(previewPane,12);stroke(previewPane,C.line,1,.5)
local viewport=Instance.new("ViewportFrame");viewport.Name="AvatarViewport";viewport.Position=UDim2.fromOffset(7,7);viewport.Size=UDim2.new(1,-14,.66,-10);viewport.BackgroundColor3=Color3.fromRGB(20,21,25);viewport.BackgroundTransparency=0;viewport.BorderSizePixel=0;viewport.Ambient=Color3.fromRGB(210,210,210);viewport.LightColor=Color3.fromRGB(255,245,232);viewport.LightDirection=Vector3.new(-1,-1,-1);viewport.ZIndex=4;viewport.Parent=previewPane;round(viewport,9)
local world=Instance.new("WorldModel");world.Parent=viewport
local previewCam=Instance.new("Camera");previewCam.Parent=viewport;viewport.CurrentCamera=previewCam
local itemBadge=image(previewPane,UDim2.new(1,-61,0,13),UDim2.fromOffset(48,48));itemBadge.Image="";itemBadge.Visible=false;itemBadge.ZIndex=6;stroke(itemBadge,C.gold,1,.25)
local selectedName=label(previewPane,"Select an item",UDim2.new(0,8,.67,0),UDim2.new(1,-16,0,35),Enum.Font.GothamBold,10,C.white);selectedName.TextXAlignment=Enum.TextXAlignment.Center;selectedName.ZIndex=4
local selectedPrice=label(previewPane,"",UDim2.new(0,8,.67,34),UDim2.new(1,-16,0,18),Enum.Font.GothamBold,9,C.gold);selectedPrice.TextXAlignment=Enum.TextXAlignment.Center;selectedPrice.ZIndex=4
local previewActions=Instance.new("Frame");previewActions.BackgroundTransparency=1;previewActions.Position=UDim2.new(0,7,1,-40);previewActions.Size=UDim2.new(1,-14,0,32);previewActions.ZIndex=4;previewActions.Parent=previewPane
local tryBtn=button(previewActions,"TRY",UDim2.fromScale(0,0),UDim2.new(.24,-3,1,0),C.card2);tryBtn.ZIndex=5;stroke(tryBtn,C.cyan,1,.32)
local cartBtn=button(previewActions,"+ CART",UDim2.new(.24,1,0,0),UDim2.new(.30,-3,1,0),C.card2);cartBtn.ZIndex=5;stroke(cartBtn,C.gold,1,.32)
local saveBtn=button(previewActions,"♡",UDim2.new(.54,1,0,0),UDim2.new(.16,-3,1,0),C.card2);saveBtn.TextSize=16;saveBtn.ZIndex=5;stroke(saveBtn,C.pink,1,.32)
local buyBtn=button(previewActions,"BUY",UDim2.new(.70,1,0,0),UDim2.new(.30,-1,1,0),Color3.fromRGB(48,79,58));buyBtn.ZIndex=5;stroke(buyBtn,C.green,1,.22)

-- RIGHT: one modular panel at a time.
local content=Instance.new("Frame");content.Name="Modules";content.Position=UDim2.new(.31,4,0,50);content.Size=UDim2.new(.69,-16,1,-104);content.BackgroundColor3=C.panel;content.BorderSizePixel=0;content.ZIndex=3;content.Parent=panel;round(content,12);stroke(content,C.line,1,.5)
local shopView=Instance.new("Frame");shopView.Name="SHOP";shopView.Size=UDim2.fromScale(1,1);shopView.BackgroundTransparency=1;shopView.ZIndex=4;shopView.Parent=content
local tryView=Instance.new("Frame");tryView.Name="TRY";tryView.Size=UDim2.fromScale(1,1);tryView.BackgroundTransparency=1;tryView.Visible=false;tryView.ZIndex=4;tryView.Parent=content
local cartView=Instance.new("Frame");cartView.Name="CART";cartView.Size=UDim2.fromScale(1,1);cartView.BackgroundTransparency=1;cartView.Visible=false;cartView.ZIndex=4;cartView.Parent=content
local savedView=Instance.new("Frame");savedView.Name="SAVED";savedView.Size=UDim2.fromScale(1,1);savedView.BackgroundTransparency=1;savedView.Visible=false;savedView.ZIndex=4;savedView.Parent=content

-- Dock: compact and persistent while shopping.
local dock=Instance.new("Frame");dock.Name="Dock";dock.Position=UDim2.new(0,12,1,-44);dock.Size=UDim2.new(1,-24,0,34);dock.BackgroundTransparency=1;dock.ZIndex=4;dock.Parent=panel
local dockLayout=Instance.new("UIListLayout");dockLayout.FillDirection=Enum.FillDirection.Horizontal;dockLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;dockLayout.Padding=UDim.new(0,6);dockLayout.Parent=dock
local dockButtons={}
for _,name in ipairs({"SHOP","TRY","CART","SAVED"}) do local b=button(dock,name,UDim2.new(),UDim2.new(.25,-5,1,0),C.card);b.Name=name;b.ZIndex=5;dockButtons[name]=b end

-- SHOP module
local search=Instance.new("TextBox");search.Name="CatalogSearch";search.PlaceholderText="Search Roblox catalog…";search.Text="";search.ClearTextOnFocus=false;search.Position=UDim2.fromOffset(10,9);search.Size=UDim2.new(1,-79,0,30);search.BackgroundColor3=C.card;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.Gotham;search.TextSize=10;search.BorderSizePixel=0;search.ZIndex=5;search.Parent=shopView;round(search,8);stroke(search,C.line,1,.5)
local searchBtn=button(shopView,"GO",UDim2.new(1,-61,0,9),UDim2.fromOffset(51,30),C.card2);searchBtn.ZIndex=5;stroke(searchBtn,C.cyan,1,.35)
local trendBar=Instance.new("ScrollingFrame");trendBar.Name="TrendRail";trendBar.Position=UDim2.fromOffset(10,44);trendBar.Size=UDim2.new(1,-20,0,28);trendBar.BackgroundTransparency=1;trendBar.BorderSizePixel=0;trendBar.ScrollBarThickness=0;trendBar.ScrollingDirection=Enum.ScrollingDirection.X;trendBar.CanvasSize=UDim2.new();trendBar.AutomaticCanvasSize=Enum.AutomaticSize.X;trendBar.ZIndex=5;trendBar.Parent=shopView
local trendLayout=Instance.new("UIListLayout");trendLayout.FillDirection=Enum.FillDirection.Horizontal;trendLayout.Padding=UDim.new(0,5);trendLayout.Parent=trendBar
local status=label(shopView,"Open a Mall storefront.",UDim2.fromOffset(10,75),UDim2.new(1,-20,0,18),Enum.Font.GothamMedium,9,C.cyan);status.ZIndex=5
local productRail=Instance.new("ScrollingFrame");productRail.Name="ProductCarousel";productRail.Position=UDim2.fromOffset(10,98);productRail.Size=UDim2.new(1,-20,1,-108);productRail.BackgroundTransparency=1;productRail.BorderSizePixel=0;productRail.ScrollBarThickness=3;productRail.ScrollBarImageColor3=C.gold;productRail.ScrollingDirection=Enum.ScrollingDirection.X;productRail.CanvasSize=UDim2.new();productRail.AutomaticCanvasSize=Enum.AutomaticSize.X;productRail.Active=true;productRail.ZIndex=5;productRail.Parent=shopView
local productLayout=Instance.new("UIListLayout");productLayout.FillDirection=Enum.FillDirection.Horizontal;productLayout.Padding=UDim.new(0,8);productLayout.VerticalAlignment=Enum.VerticalAlignment.Top;productLayout.Parent=productRail

-- TRY module
local tryTitle=label(tryView,"TRY STUDIO",UDim2.fromOffset(12,10),UDim2.new(1,-24,0,24),Enum.Font.GothamBold,15,C.white);tryTitle.ZIndex=5
local tryInfo=label(tryView,"Select an item in SHOP, then tap TRY. The avatar preview on the left changes without touching your live character.",UDim2.fromOffset(12,39),UDim2.new(1,-24,0,46),Enum.Font.Gotham,10,C.muted);tryInfo.ZIndex=5
local tryCurrent=label(tryView,"No preview item yet.",UDim2.fromOffset(12,91),UDim2.new(1,-24,0,32),Enum.Font.GothamBold,11,C.cyan);tryCurrent.ZIndex=5
local resetPreviewBtn=button(tryView,"RESET PREVIEW",UDim2.fromOffset(12,132),UDim2.fromOffset(128,32),C.card2);resetPreviewBtn.ZIndex=5;stroke(resetPreviewBtn,C.line,1,.35)
local saveLookBtn=button(tryView,"SAVE LOOK TO ROBLOX",UDim2.fromOffset(148,132),UDim2.fromOffset(168,32),Color3.fromRGB(48,79,58));saveLookBtn.ZIndex=5;stroke(saveLookBtn,C.green,1,.25)
local tryHistoryTitle=label(tryView,"TRIED ITEMS",UDim2.fromOffset(12,174),UDim2.new(1,-24,0,20),Enum.Font.GothamBold,9,C.gold);tryHistoryTitle.ZIndex=5
local tryRail=Instance.new("ScrollingFrame");tryRail.Position=UDim2.fromOffset(12,198);tryRail.Size=UDim2.new(1,-24,1,-208);tryRail.BackgroundTransparency=1;tryRail.BorderSizePixel=0;tryRail.ScrollBarThickness=2;tryRail.ScrollingDirection=Enum.ScrollingDirection.X;tryRail.AutomaticCanvasSize=Enum.AutomaticSize.X;tryRail.CanvasSize=UDim2.new();tryRail.ZIndex=5;tryRail.Parent=tryView
local tryLayout=Instance.new("UIListLayout");tryLayout.FillDirection=Enum.FillDirection.Horizontal;tryLayout.Padding=UDim.new(0,7);tryLayout.Parent=tryRail

-- CART module
local cartTitle=label(cartView,"CART",UDim2.fromOffset(12,9),UDim2.new(1,-24,0,24),Enum.Font.GothamBold,15,C.white);cartTitle.ZIndex=5
local cartStatus=label(cartView,"0 items",UDim2.fromOffset(12,32),UDim2.new(1,-24,0,18),Enum.Font.GothamMedium,9,C.gold);cartStatus.ZIndex=5
local cartList=Instance.new("ScrollingFrame");cartList.Position=UDim2.fromOffset(12,56);cartList.Size=UDim2.new(1,-24,1,-102);cartList.BackgroundTransparency=1;cartList.BorderSizePixel=0;cartList.ScrollBarThickness=3;cartList.ScrollBarImageColor3=C.gold;cartList.ScrollingDirection=Enum.ScrollingDirection.Y;cartList.AutomaticCanvasSize=Enum.AutomaticSize.Y;cartList.CanvasSize=UDim2.new();cartList.ZIndex=5;cartList.Parent=cartView
local cartLayout=Instance.new("UIListLayout");cartLayout.Padding=UDim.new(0,6);cartLayout.Parent=cartList
local checkoutBtn=button(cartView,"CHECKOUT",UDim2.new(1,-132,1,-39),UDim2.fromOffset(120,30),Color3.fromRGB(48,79,58));checkoutBtn.ZIndex=6;stroke(checkoutBtn,C.green,1,.2)

-- SAVED module
local savedTitle=label(savedView,"SAVED",UDim2.fromOffset(12,9),UDim2.new(1,-24,0,24),Enum.Font.GothamBold,15,C.white);savedTitle.ZIndex=5
local savedNote=label(savedView,"Session saved items • test mode",UDim2.fromOffset(12,32),UDim2.new(1,-24,0,18),Enum.Font.GothamMedium,9,C.muted);savedNote.ZIndex=5
local savedRail=Instance.new("ScrollingFrame");savedRail.Position=UDim2.fromOffset(12,58);savedRail.Size=UDim2.new(1,-24,1,-70);savedRail.BackgroundTransparency=1;savedRail.BorderSizePixel=0;savedRail.ScrollBarThickness=3;savedRail.ScrollBarImageColor3=C.pink;savedRail.ScrollingDirection=Enum.ScrollingDirection.X;savedRail.AutomaticCanvasSize=Enum.AutomaticSize.X;savedRail.CanvasSize=UDim2.new();savedRail.ZIndex=5;savedRail.Parent=savedView
local savedLayout=Instance.new("UIListLayout");savedLayout.FillDirection=Enum.FillDirection.Horizontal;savedLayout.Padding=UDim.new(0,8);savedLayout.Parent=savedRail

local activeStore="FASHION"
local opened=false
local searching=false
local selectedItem=nil
local selectedById={}
local cart={}
local saved={}
local tried={}
local baseDescription=nil
local previewDescription=nil
local hiddenMallHud=nil
local hiddenMallHudWasEnabled=false
local checkoutQueue={}
local checkoutActive=false
local checkoutMode=false

local function idOf(item)return item and tonumber(item.Id or item.AssetId) or nil end
local function nameOf(item)return tostring(item and item.Name or "Roblox item") end
local function priceOf(item)local p=tonumber(item and (item.Price or item.LowestPrice));return p and math.floor(p) or nil end
local function priceText(item)local p=priceOf(item);return p and ("R$ "..p) or tostring(item and item.PriceStatus or "ROBLOX") end
local function thumb(id)return string.format("rbxthumb://type=Asset&id=%d&w=420&h=420",id) end
local function setStatus(text,col)status.Text=tostring(text or "");status.TextColor3=col or C.cyan end
local function setMallHudHidden(hide)
 local live=pg:FindFirstChild("BBYAMallLiveUI")
 if hide then if live and live:IsA("ScreenGui") then hiddenMallHud=live;hiddenMallHudWasEnabled=live.Enabled;live.Enabled=false end
 else if hiddenMallHud and hiddenMallHud.Parent and hiddenMallHud:IsA("ScreenGui") then hiddenMallHud.Enabled=hiddenMallHudWasEnabled end;hiddenMallHud=nil end
end
local function clearContainer(container,keep)
 for _,ch in ipairs(container:GetChildren()) do if ch~=keep then ch:Destroy() end end
end

local function getBaseDescription()
 local char=player.Character
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 if hum then local ok,d=pcall(function()return hum:GetAppliedDescription()end);if ok and d then return d end end
 local ok,d=pcall(function()return Players:GetHumanoidDescriptionFromUserId(player.UserId)end)
 if ok then return d end
 return nil
end
local function renderDescription(desc)
 world:ClearAllChildren()
 if not desc then return false end
 local ok,model=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,Enum.HumanoidRigType.R15)end)
 if not ok or not model then
  local char=player.Character
  if char then
   local was=char.Archivable;char.Archivable=true;local clone=char:Clone();char.Archivable=was
   if clone then model=clone;ok=true end
  end
 end
 if not ok or not model then return false end
 model.Name="PreviewAvatar";model.Parent=world
 for _,d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false end end
 pcall(function()model:PivotTo(CFrame.new(0,0,0))end)
 local _,size=model:GetBoundingBox();local h=math.max(size.Y,5);local target=Vector3.new(0,h*.48,0);previewCam.CFrame=CFrame.new(target+Vector3.new(0,.15,h*1.12),target);previewCam.FieldOfView=34
 return true
end
local function refreshBasePreview()
 baseDescription=getBaseDescription();previewDescription=baseDescription and baseDescription:Clone() or nil;renderDescription(previewDescription)
end

local function assetTypeName(item)
 local raw=item and item.AssetType
 local s=tostring(raw or "")
 s=s:gsub("Enum%.AvatarAssetType%.","")
 return s
end
local function applyItemToDescription(desc,item)
 local id=idOf(item);if not desc or not id then return false,"missing item" end
 local t=assetTypeName(item)
 if t=="Shirt" then desc.Shirt=id;return true end
 if t=="TShirt" then desc.GraphicTShirt=id;return true end
 if t=="Pants" then desc.Pants=id;return true end
 local mapped=ACCESSORY_MAP[t]
 if mapped then
  local enumOk,accType=pcall(function()return Enum.AccessoryType[mapped]end)
  if not enumOk or not accType then return false,"unsupported accessory type" end
  local ok,list=pcall(function()return desc:GetAccessories(true)end)
  if not ok or type(list)~="table" then return false,"accessories unavailable" end
  table.insert(list,{AssetId=id,AccessoryType=accType,Order=#list+1})
  local setOk,setErr=pcall(function()desc:SetAccessories(list,true)end)
  if not setOk then return false,tostring(setErr) end
  return true
 end
 return false,"preview unsupported for "..t
end

local function selectItem(item)
 selectedItem=item
 local id=idOf(item)
 if not id then selectedName.Text="Select an item";selectedPrice.Text="";itemBadge.Visible=false;return end
 selectedById[id]=item
 selectedName.Text=nameOf(item);selectedPrice.Text=priceText(item);itemBadge.Image=thumb(id);itemBadge.Visible=true
end

local function compactTile(parent,item,w,h,onTap)
 local id=idOf(item);if not id then return end
 local tile=button(parent,"",UDim2.new(),UDim2.fromOffset(w,h),C.card);tile.Name="Item_"..id;tile.ZIndex=6;stroke(tile,C.line,1,.55)
 local im=image(tile,UDim2.fromOffset(6,6),UDim2.new(1,-12,0,h-54));im.Image=thumb(id);im.ZIndex=7
 local nm=label(tile,nameOf(item),UDim2.new(0,6,1,-45),UDim2.new(1,-12,0,24),Enum.Font.GothamMedium,8,C.white);nm.TextXAlignment=Enum.TextXAlignment.Center;nm.ZIndex=7
 local pr=label(tile,priceText(item),UDim2.new(0,6,1,-22),UDim2.new(1,-12,0,16),Enum.Font.GothamBold,8,C.gold);pr.TextXAlignment=Enum.TextXAlignment.Center;pr.ZIndex=7
 tile.Activated:Connect(function()selectItem(item);if onTap then onTap(item)end end)
 return tile
end

local function renderTryHistory()
 clearContainer(tryRail,tryLayout)
 for _,item in ipairs(tried) do compactTile(tryRail,item,104,92,function(it)selectItem(it)end) end
end
local function renderSaved()
 clearContainer(savedRail,savedLayout)
 for _,item in ipairs(saved) do compactTile(savedRail,item,126,164,function(it)selectItem(it)end) end
 savedNote.Text=(#saved==0 and "Session saved items • test mode" or (tostring(#saved).." saved items • tap to select"))
end
local function removeCartId(id)
 for i=#cart,1,-1 do if idOf(cart[i])==id then table.remove(cart,i) end end
end
local function renderCart()
 clearContainer(cartList,cartLayout)
 local total=0
 for _,item in ipairs(cart) do
  local id=idOf(item);local p=priceOf(item) or 0;total+=p
  local row=Instance.new("Frame");row.Size=UDim2.new(1,-2,0,54);row.BackgroundColor3=C.card;row.BorderSizePixel=0;row.ZIndex=6;row.Parent=cartList;round(row,8)
  local im=image(row,UDim2.fromOffset(5,5),UDim2.fromOffset(44,44));im.Image=thumb(id);im.ZIndex=7
  local nm=label(row,nameOf(item),UDim2.fromOffset(56,5),UDim2.new(1,-150,0,25),Enum.Font.GothamMedium,9,C.white);nm.ZIndex=7
  local pr=label(row,priceText(item),UDim2.fromOffset(56,29),UDim2.new(1,-150,0,18),Enum.Font.GothamBold,8,C.gold);pr.ZIndex=7
  local rm=button(row,"REMOVE",UDim2.new(1,-84,.5,-13),UDim2.fromOffset(76,26),C.card2);rm.ZIndex=7;stroke(rm,C.red,1,.35)
  rm.Activated:Connect(function()removeCartId(id);renderCart()end)
 end
 cartStatus.Text=string.format("%d item%s%s",#cart,#cart==1 and "" or "s",total>0 and (" • R$ "..total) or "")
 checkoutBtn.Visible=#cart>0
end

local function setModule(name)
 shopView.Visible=name=="SHOP";tryView.Visible=name=="TRY";cartView.Visible=name=="CART";savedView.Visible=name=="SAVED"
 for n,b in pairs(dockButtons) do b.BackgroundColor3=(n==name) and C.card2 or C.card;local st=b:FindFirstChildOfClass("UIStroke");if st then st.Color=(n==name) and C.gold or C.line;st.Transparency=(n==name) and .2 or .55 end end
 if name=="CART" then renderCart() elseif name=="SAVED" then renderSaved() elseif name=="TRY" then renderTryHistory() end
end
for n,b in pairs(dockButtons) do b.Activated:Connect(function()setModule(n)end) end

local function searchCatalog(params)
 local ok,pages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if ok and pages then return pages end
 task.wait(.25)
 local ok2,pages2=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if ok2 and pages2 then return pages2 end
 warn("[BBYA Mall v7] SearchCatalog failed:",pages,pages2)
 return nil
end
local function pageItems(pages)
 if not pages then return nil end
 local ok,items=pcall(function()return pages:GetCurrentPage()end)
 if ok and type(items)=="table" then return items end
 return nil
end
local function makeParams(useTypes,keyword)
 local params=CatalogSearchParams.new();params.IncludeOffSale=false;params.Limit=12
 if useTypes then params.AssetTypes=STORE_TYPES[activeStore] or STORE_TYPES.FASHION end
 if keyword and keyword~="" then params.SearchKeyword=keyword end
 return params
end
local function clearProducts()clearContainer(productRail,productLayout)end
local function runSearch()
 if searching or not opened then return end
 searching=true;clearProducts();setStatus("Loading Roblox Marketplace…",C.gold)
 local q=search.Text:match("^%s*(.-)%s*$") or ""
 local items=pageItems(searchCatalog(makeParams(true,q)))
 if (not items or #items==0) and activeStore=="SHOES" then items=pageItems(searchCatalog(makeParams(false,(q~="" and q) or "shoes"))) end
 if not items then setStatus("Marketplace belum merespons. Tap GO untuk retry.",C.pink);searching=false;return end
 if #items==0 then setStatus("Tidak ada produk untuk filter ini.",C.muted) else
  for _,item in ipairs(items) do compactTile(productRail,item,132,176,function(it)selectItem(it)end) end
  setStatus(string.format("%d produk live • tap item untuk pilih",#items),C.green)
  if not selectedItem and items[1] then selectItem(items[1]) end
 end
 searching=false
end
local function buildTrendRail()
 clearContainer(trendBar,trendLayout)
 for _,keyword in ipairs(STORE_TRENDS[activeStore] or STORE_TRENDS.FASHION) do
  local b=button(trendBar,string.upper(keyword),UDim2.new(),UDim2.fromOffset(math.max(66,#keyword*7+22),27),C.card2);b.ZIndex=6;stroke(b,C.line,1,.48)
  b.Activated:Connect(function()search.Text=keyword;task.defer(runSearch)end)
 end
end
searchBtn.Activated:Connect(runSearch)
search.FocusLost:Connect(function(enter)if enter then runSearch() end end)

local function trySelected()
 if not selectedItem then setStatus("Pilih item dulu.",C.pink);return end
 if not previewDescription then refreshBasePreview() end
 local nextDesc=previewDescription and previewDescription:Clone() or nil
 local ok,why=applyItemToDescription(nextDesc,selectedItem)
 if not ok then tryCurrent.Text="Preview belum didukung: "..tostring(why);tryCurrent.TextColor3=C.pink;setModule("TRY");return end
 previewDescription=nextDesc;renderDescription(previewDescription)
 local id=idOf(selectedItem);local exists=false;for _,it in ipairs(tried) do if idOf(it)==id then exists=true break end end;if not exists then table.insert(tried,1,selectedItem) end
 tryCurrent.Text="Previewing: "..nameOf(selectedItem);tryCurrent.TextColor3=C.green;renderTryHistory();setModule("TRY")
end
tryBtn.Activated:Connect(trySelected)
resetPreviewBtn.Activated:Connect(function()refreshBasePreview();tryCurrent.Text="Preview reset to your current avatar.";tryCurrent.TextColor3=C.cyan end)
saveLookBtn.Activated:Connect(function()
 if not previewDescription then return end
 local ok,err=pcall(function()AvatarEditorService:PromptSaveAvatar(previewDescription,Enum.HumanoidRigType.R15)end)
 tryCurrent.Text=ok and "Roblox Save Avatar prompt opened." or ("Save unavailable: "..tostring(err));tryCurrent.TextColor3=ok and C.green or C.pink
end)

cartBtn.Activated:Connect(function()
 if not selectedItem then return end
 local id=idOf(selectedItem);for _,it in ipairs(cart) do if idOf(it)==id then setModule("CART");return end end
 table.insert(cart,selectedItem);renderCart();setModule("CART")
end)
saveBtn.Activated:Connect(function()
 if not selectedItem then return end
 local id=idOf(selectedItem);for _,it in ipairs(saved) do if idOf(it)==id then setModule("SAVED");return end end
 table.insert(saved,1,selectedItem);saveBtn.Text="♥";renderSaved();setModule("SAVED")
end)

local function promptPurchase(item)
 local id=idOf(item);if not id then return false end
 setStatus("Opening Roblox checkout…",C.gold)
 local ok,err=pcall(function()MarketplaceService:PromptPurchase(player,id,true,Enum.CurrencyType.Default)end)
 if not ok then warn("[BBYA Mall v7] PromptPurchase failed:",err);setStatus("Checkout tidak tersedia untuk item ini.",C.pink);return false end
 return true
end
buyBtn.Activated:Connect(function()if selectedItem then promptPurchase(selectedItem)end end)
local function checkoutNext()
 if checkoutActive or #checkoutQueue==0 then checkoutMode=false;return end
 checkoutActive=true;local item=checkoutQueue[1];selectItem(item)
 if not promptPurchase(item) then checkoutActive=false;checkoutMode=false;checkoutQueue={} end
end
checkoutBtn.Activated:Connect(function()
 if #cart==0 then return end
 checkoutQueue={};for _,it in ipairs(cart) do table.insert(checkoutQueue,it) end;checkoutMode=true;checkoutActive=false;checkoutNext()
end)
MarketplaceService.PromptPurchaseFinished:Connect(function(who,assetId,isPurchased)
 if who~=player then return end
 checkoutActive=false
 if isPurchased then
  setStatus("PURCHASE SUCCESS • Roblox confirmed.",C.green);removeCartId(assetId);renderCart()
  if checkoutMode and #checkoutQueue>0 and idOf(checkoutQueue[1])==assetId then table.remove(checkoutQueue,1) end
  if checkoutMode and #checkoutQueue>0 then task.delay(.45,checkoutNext) else checkoutMode=false end
 else
  setStatus("Checkout ditutup / belum dibeli.",C.muted);checkoutMode=false;checkoutQueue={}
 end
end)

local function hidePanel()
 opened=false;panel.Visible=false;dim.Visible=false;searching=false;checkoutMode=false;checkoutQueue={};setMallHudHidden(false)
end
close.Activated:Connect(hidePanel);dim.Activated:Connect(hidePanel)
remote.OnClientEvent:Connect(function(kind,data)
 if kind~="open" or typeof(data)~="table" then return end
 activeStore=tostring(data.key or "FASHION");title.Text=tostring(data.title or "BBYA MALL");subtitle.Text=tostring(data.subtitle or "CATALOG STUDIO")
 buildTrendRail();local trends=STORE_TRENDS[activeStore] or STORE_TRENDS.FASHION;search.Text=trends[1] or ""
 selectedItem=nil;selectedName.Text="Select an item";selectedPrice.Text="";itemBadge.Visible=false;saveBtn.Text="♡"
 refreshBasePreview();setMallHudHidden(true);opened=true;panel.Visible=true;dim.Visible=true;setModule("SHOP");task.defer(runSearch)
end)
player.CharacterAdded:Connect(function()task.wait(.5);if opened then refreshBasePreview() end end)

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local landscape=vp.X>vp.Y
 local touch=UserInputService.TouchEnabled
 local w,h
 if landscape then w=math.clamp(math.floor(vp.X*(touch and .64 or .62)),640,920);h=math.clamp(math.floor(vp.Y*(touch and .61 or .60)),350,470)
 else w=math.clamp(math.floor(vp.X*.92),330,680);h=math.clamp(math.floor(vp.Y*.66),390,620) end
 panel.Size=UDim2.fromOffset(w,h);panel.Position=UDim2.fromScale(.5,landscape and .54 or .51)
end
task.defer(responsive)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)

print("[BBYA] Mall Commerce UI v7 online: modular SHOP/TRY/CART/SAVED + avatar preview + native checkout")
