-- BBYA SOCIAL HUB — MALL CATALOG UI v8
-- Reference-driven rebuild. This intentionally replaces the old giant storefront panel.
-- Architecture: safe-area launcher + persistent avatar preview + modular KATALOG/TOKO/
-- PRODUCTS/CART/SAVED panels. Roblox CoreGui remains unobstructed. Test candidate only.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AvatarEditorService=game:GetService("AvatarEditorService")
local MarketplaceService=game:GetService("MarketplaceService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remote=ReplicatedStorage:WaitForChild("BBYAClubRemotes"):WaitForChild("MallRobuxCommerce")

local OLD=pg:FindFirstChild("BBYAMallRobuxCommerceUI")
if OLD then OLD:Destroy() end

local C={
 dark=Color3.fromRGB(22,23,27),panel=Color3.fromRGB(34,35,40),panel2=Color3.fromRGB(43,44,50),line=Color3.fromRGB(72,73,82),
 white=Color3.fromRGB(246,246,247),muted=Color3.fromRGB(172,173,180),cyan=Color3.fromRGB(61,201,230),green=Color3.fromRGB(75,235,125),
 pink=Color3.fromRGB(231,44,212),orange=Color3.fromRGB(255,117,84),yellow=Color3.fromRGB(244,183,77),blue=Color3.fromRGB(61,181,229),red=Color3.fromRGB(233,73,89)
}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o end
local function stroke(o,col,tr)local x=Instance.new("UIStroke");x.Color=col or C.line;x.Thickness=1;x.Transparency=tr or .35;x.Parent=o end
local function txt(p,s,pos,size,font,ts,col,align)
 local x=Instance.new("TextLabel");x.BackgroundTransparency=1;x.Text=s;x.Position=pos;x.Size=size;x.Font=font or Enum.Font.Gotham;x.TextSize=ts or 12;x.TextColor3=col or C.white;x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center;x.TextWrapped=true;x.Parent=p;return x
end
local function btn(p,s,pos,size,bg)
 local x=Instance.new("TextButton");x.Text=s;x.Position=pos;x.Size=size;x.BackgroundColor3=bg or C.panel2;x.TextColor3=C.white;x.Font=Enum.Font.GothamBold;x.TextSize=12;x.BorderSizePixel=0;x.AutoButtonColor=true;x.Active=true;x.Parent=p;corner(x,9);return x
end
local function img(p,pos,size)
 local x=Instance.new("ImageLabel");x.Position=pos;x.Size=size;x.BackgroundColor3=C.panel2;x.BorderSizePixel=0;x.ScaleType=Enum.ScaleType.Crop;x.Parent=p;corner(x,8);return x
end
local function thumb(id)return id and ("rbxthumb://type=Asset&id="..tostring(id).."&w=420&h=420") or "" end
local function idOf(it)return tonumber(it and (it.Id or it.AssetId or it.id)) end
local function nameOf(it)return tostring(it and (it.Name or it.name) or "Item") end
local function priceOf(it)return tonumber(it and (it.Price or it.LowestPrice or it.price)) end
local function priceText(it)local p=priceOf(it);return p and ("R$ "..tostring(p)) or "OFFSALE" end

local TYPES={
 BEST={Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.TShirt,Enum.AvatarAssetType.Pants,Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.NeckAccessory,Enum.AvatarAssetType.ShoulderAccessory,Enum.AvatarAssetType.FrontAccessory,Enum.AvatarAssetType.BackAccessory,Enum.AvatarAssetType.WaistAccessory,Enum.AvatarAssetType.JacketAccessory,Enum.AvatarAssetType.SweaterAccessory,Enum.AvatarAssetType.ShirtAccessory,Enum.AvatarAssetType.PantsAccessory},
 HAIR={Enum.AvatarAssetType.HairAccessory},
 CLOTHES={Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.TShirt,Enum.AvatarAssetType.Pants,Enum.AvatarAssetType.TShirtAccessory,Enum.AvatarAssetType.ShirtAccessory,Enum.AvatarAssetType.JacketAccessory,Enum.AvatarAssetType.SweaterAccessory,Enum.AvatarAssetType.PantsAccessory,Enum.AvatarAssetType.ShortsAccessory,Enum.AvatarAssetType.DressSkirtAccessory},
 ACCESSORY={Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.NeckAccessory,Enum.AvatarAssetType.ShoulderAccessory,Enum.AvatarAssetType.FrontAccessory,Enum.AvatarAssetType.BackAccessory,Enum.AvatarAssetType.WaistAccessory},
 FACE={Enum.AvatarAssetType.FaceAccessory},
 SHOES={Enum.AvatarAssetType.LeftShoeAccessory,Enum.AvatarAssetType.RightShoeAccessory},
}
local ACCESSORY_MAP={Hat="Hat",HairAccessory="Hair",FaceAccessory="Face",NeckAccessory="Neck",ShoulderAccessory="Shoulder",FrontAccessory="Front",BackAccessory="Back",WaistAccessory="Waist",TShirtAccessory="TShirt",ShirtAccessory="Shirt",SweaterAccessory="Sweater",JacketAccessory="Jacket",PantsAccessory="Pants",ShortsAccessory="Shorts",DressSkirtAccessory="DressSkirt",LeftShoeAccessory="LeftShoe",RightShoeAccessory="RightShoe"}
local STORE={
 FASHION={title="LUMA FASHION",sub="Fashion & layered clothing",q="streetwear",accent=C.pink},
 SHOES={title="STRIDE SNEAKERS",sub="Shoes & sneaker catalog",q="sneakers",accent=C.orange},
 BEAUTY={title="MUSE BEAUTY",sub="Hair, face & beauty",q="hair",accent=Color3.fromRGB(178,75,235)},
 STREET={title="NORTH LABEL",sub="Accessories & street style",q="streetwear",accent=C.blue},
}

local gui=Instance.new("ScreenGui")
gui.Name="BBYAMallRobuxCommerceUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=260;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
local root=Instance.new("Frame");root.Name="CatalogRoot";root.Size=UDim2.fromScale(1,1);root.BackgroundTransparency=1;root.Visible=false;root.Parent=gui

-- Small reference-style top launcher. It deliberately sits BELOW Roblox CoreGui.
local top=Instance.new("Frame");top.Name="CatalogLauncher";top.BackgroundTransparency=1;top.Size=UDim2.fromOffset(440,46);top.Parent=root
local catBtn=btn(top,"Katalog",UDim2.fromOffset(0,0),UDim2.fromOffset(208,44),Color3.fromRGB(55,74,84));catBtn.TextSize=20
local storeBtn=btn(top,"Toko",UDim2.fromOffset(224,0),UDim2.fromOffset(208,44),Color3.fromRGB(55,74,84));storeBtn.TextSize=20

-- Persistent avatar preview card on left, matching the reference architecture.
local avatar=Instance.new("Frame");avatar.Name="AvatarCard";avatar.BackgroundColor3=C.panel;avatar.BorderSizePixel=0;avatar.Parent=root;corner(avatar,12);stroke(avatar,C.line,.18)
local viewport=Instance.new("ViewportFrame");viewport.Name="AvatarViewport";viewport.Position=UDim2.fromOffset(7,7);viewport.Size=UDim2.new(1,-14,1,-83);viewport.BackgroundColor3=Color3.fromRGB(18,19,23);viewport.BorderSizePixel=0;viewport.Ambient=Color3.fromRGB(215,215,215);viewport.LightColor=Color3.fromRGB(255,248,235);viewport.LightDirection=Vector3.new(-1,-1,-1);viewport.Parent=avatar;corner(viewport,9)
local world=Instance.new("WorldModel");world.Parent=viewport
local vcam=Instance.new("Camera");vcam.Parent=viewport;viewport.CurrentCamera=vcam
local selectedLabel=txt(avatar,"Avatar saat ini",UDim2.new(0,10,1,-74),UDim2.new(1,-20,0,22),Enum.Font.GothamBold,12,C.white,Enum.TextXAlignment.Center)
local selectedPrice=txt(avatar,"",UDim2.new(0,10,1,-52),UDim2.new(1,-20,0,18),Enum.Font.GothamBold,10,C.yellow,Enum.TextXAlignment.Center)
local avatarTools=Instance.new("Frame");avatarTools.Position=UDim2.new(0,7,1,-31);avatarTools.Size=UDim2.new(1,-14,0,25);avatarTools.BackgroundTransparency=1;avatarTools.Parent=avatar
local toolLayout=Instance.new("UIListLayout");toolLayout.FillDirection=Enum.FillDirection.Horizontal;toolLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;toolLayout.Padding=UDim.new(0,5);toolLayout.Parent=avatarTools
local homeTool=btn(avatarTools,"HOME",UDim2.new(),UDim2.new(.24,-4,1,0),C.panel2);homeTool.TextSize=8
local cartTool=btn(avatarTools,"CART",UDim2.new(),UDim2.new(.24,-4,1,0),C.panel2);cartTool.TextSize=8
local saveTool=btn(avatarTools,"SAVE",UDim2.new(),UDim2.new(.24,-4,1,0),C.panel2);saveTool.TextSize=8
local resetTool=btn(avatarTools,"RESET",UDim2.new(),UDim2.new(.24,-4,1,0),C.panel2);resetTool.TextSize=8

-- Right module host. Every function gets its own panel instead of one giant nested panel.
local host=Instance.new("Frame");host.Name="ModuleHost";host.BackgroundTransparency=1;host.Parent=root
local modules={}
local function module(name)
 local f=Instance.new("Frame");f.Name=name;f.Size=UDim2.fromScale(1,1);f.BackgroundTransparency=1;f.Visible=false;f.Parent=host;modules[name]=f;return f
end
local categories=module("CATEGORIES")
local stores=module("STORES")
local products=module("PRODUCTS")
local cartView=module("CART")
local savedView=module("SAVED")

-- Category mosaic inspired by reference screenshots.
local function tile(parent,name,textValue,pos,size,color)
 local b=btn(parent,textValue,pos,size,color);b.Name=name;b.TextXAlignment=Enum.TextXAlignment.Left;b.TextYAlignment=Enum.TextYAlignment.Top;b.TextWrapped=true;b.TextSize=22
 local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,16);pad.PaddingTop=UDim.new(0,14);pad.PaddingRight=UDim.new(0,10);pad.Parent=b
 local g=Instance.new("UIGradient");g.Color=ColorSequence.new(color,Color3.new(math.min(color.R+0.18,1),math.min(color.G+0.18,1),math.min(color.B+0.18,1)));g.Rotation=25;g.Parent=b
 return b
end
local best=tile(categories,"BEST","Terbaik",UDim2.new(0,0,0,0),UDim2.new(.43,-7,1,0),C.blue)
local hair=tile(categories,"HAIR","RAMBUT",UDim2.new(.44,0,0,0),UDim2.new(.31,-6,.32,-5),Color3.fromRGB(207,0,245))
local clothes=tile(categories,"CLOTHES","PAKAIAN",UDim2.new(.76,0,0,0),UDim2.new(.24,0,.55,-5),C.green)
local shoes=tile(categories,"SHOES","SEPATU",UDim2.new(.44,0,.34,0),UDim2.new(.31,-6,.26,-5),C.orange)
local accessory=tile(categories,"ACCESSORY","AKSESORI",UDim2.new(.44,0,.62,0),UDim2.new(.56,-6,.38,0),Color3.fromRGB(245,66,120))
local face=tile(categories,"FACE","WAJAH",UDim2.new(.76,0,.57,0),UDim2.new(.24,0,.43,0),C.yellow)

-- Store selector is its own panel.
local storeTitle=txt(stores,"PILIH TOKO",UDim2.fromOffset(4,0),UDim2.new(1,-8,0,34),Enum.Font.GothamBold,22,C.white)
local storeGrid=Instance.new("Frame");storeGrid.Position=UDim2.fromOffset(0,45);storeGrid.Size=UDim2.new(1,0,1,-45);storeGrid.BackgroundTransparency=1;storeGrid.Parent=stores
local sg=Instance.new("UIGridLayout");sg.CellSize=UDim2.new(.5,-6,.5,-6);sg.CellPadding=UDim2.fromOffset(12,12);sg.Parent=storeGrid
local storeButtons={}
for _,key in ipairs({"FASHION","SHOES","BEAUTY","STREET"}) do
 local d=STORE[key];local b=btn(storeGrid,d.title.."\n"..d.sub,UDim2.new(),UDim2.new(),d.accent);b.Name=key;b.TextSize=18;b.TextWrapped=true;storeButtons[key]=b
end

-- Product browser panel.
local backProducts=btn(products,"‹ KATALOG",UDim2.fromOffset(0,0),UDim2.fromOffset(102,34),C.panel2)
local productTitle=txt(products,"Katalog",UDim2.fromOffset(116,0),UDim2.new(1,-340,0,34),Enum.Font.GothamBold,20,C.white)
local search=Instance.new("TextBox");search.PlaceholderText="Pencarian..";search.Text="";search.ClearTextOnFocus=false;search.Position=UDim2.new(1,-216,0,0);search.Size=UDim2.fromOffset(158,34);search.BackgroundColor3=C.panel2;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.Gotham;search.TextSize=11;search.BorderSizePixel=0;search.Parent=products;corner(search,8)
local go=btn(products,"GO",UDim2.new(1,-50,0,0),UDim2.fromOffset(50,34),C.panel2)
local status=txt(products,"",UDim2.fromOffset(0,42),UDim2.new(1,0,0,22),Enum.Font.GothamMedium,10,C.muted)
local retry=btn(products,"RETRY",UDim2.new(1,-78,0,40),UDim2.fromOffset(78,26),C.red);retry.Visible=false;retry.TextSize=9
local productList=Instance.new("ScrollingFrame");productList.Position=UDim2.fromOffset(0,70);productList.Size=UDim2.new(1,0,1,-70);productList.BackgroundTransparency=1;productList.BorderSizePixel=0;productList.ScrollBarThickness=3;productList.AutomaticCanvasSize=Enum.AutomaticSize.Y;productList.CanvasSize=UDim2.new();productList.ScrollingDirection=Enum.ScrollingDirection.Y;productList.Parent=products
local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.new(.24,-8,0,178);grid.CellPadding=UDim2.fromOffset(10,10);grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=productList

-- Cart panel.
local cartTitle=txt(cartView,"Keranjang Belanja",UDim2.fromOffset(0,0),UDim2.new(1,-50,0,36),Enum.Font.GothamBold,24,C.white)
local cartClose=btn(cartView,"×",UDim2.new(1,-40,0,0),UDim2.fromOffset(40,36),C.panel2);cartClose.TextSize=22
local cartList=Instance.new("ScrollingFrame");cartList.Position=UDim2.fromOffset(0,48);cartList.Size=UDim2.new(1,0,1,-105);cartList.BackgroundTransparency=1;cartList.BorderSizePixel=0;cartList.AutomaticCanvasSize=Enum.AutomaticSize.Y;cartList.CanvasSize=UDim2.new();cartList.ScrollBarThickness=3;cartList.Parent=cartView
local cl=Instance.new("UIListLayout");cl.Padding=UDim.new(0,8);cl.Parent=cartList
local cartStatus=txt(cartView,"Keranjang kosong.",UDim2.new(0,0,1,-48),UDim2.new(.55,0,0,40),Enum.Font.Gotham,13,C.muted)
local checkout=btn(cartView,"PEMBAYARAN",UDim2.new(1,-184,1,-48),UDim2.fromOffset(184,40),C.green);checkout.TextColor3=Color3.new(0,0,0)

-- Saved panel.
local savedTitle=txt(savedView,"Pakaian Tersimpan",UDim2.fromOffset(0,0),UDim2.new(1,-50,0,36),Enum.Font.GothamBold,24,C.white)
local savedClose=btn(savedView,"×",UDim2.new(1,-40,0,0),UDim2.fromOffset(40,36),C.panel2);savedClose.TextSize=22
local saveCurrent=btn(savedView,"SIMPAN LOOK SAAT INI",UDim2.fromOffset(0,48),UDim2.fromOffset(190,36),C.green);saveCurrent.TextColor3=Color3.new(0,0,0)
local savedNote=txt(savedView,"Belum ada item tersimpan.",UDim2.fromOffset(0,92),UDim2.new(1,0,0,26),Enum.Font.Gotham,11,C.muted)
local savedList=Instance.new("ScrollingFrame");savedList.Position=UDim2.fromOffset(0,124);savedList.Size=UDim2.new(1,0,1,-124);savedList.BackgroundTransparency=1;savedList.BorderSizePixel=0;savedList.AutomaticCanvasSize=Enum.AutomaticSize.Y;savedList.CanvasSize=UDim2.new();savedList.ScrollBarThickness=3;savedList.Parent=savedView
local sl=Instance.new("UIGridLayout");sl.CellSize=UDim2.new(.24,-8,0,160);sl.CellPadding=UDim2.fromOffset(10,10);sl.Parent=savedList

local activeStore="FASHION"
local activeCategory="BEST"
local selected=nil
local baseDescription=nil
local previewDescription=nil
local cart={}
local saved={}
local searchToken=0
local focusSaved={}
local focusConn=nil
local camera=workspace.CurrentCamera

local function hideOtherUI()
 for _,g in ipairs(pg:GetChildren()) do
  if g:IsA("ScreenGui") and g~=gui then
   if focusSaved[g]==nil then focusSaved[g]=g.Enabled end
   g.Enabled=false
  end
 end
 if focusConn then focusConn:Disconnect() end
 focusConn=pg.ChildAdded:Connect(function(g)
  if root.Visible and g:IsA("ScreenGui") and g~=gui then task.defer(function()if g.Parent then focusSaved[g]=g.Enabled;g.Enabled=false end end) end
 end)
end
local function restoreUI()
 if focusConn then focusConn:Disconnect();focusConn=nil end
 for g,enabled in pairs(focusSaved) do if g and g.Parent then g.Enabled=enabled end end
 table.clear(focusSaved)
end
local function showModule(name)
 for n,f in pairs(modules) do f.Visible=n==name end
end

local function getDescription()
 local ch=player.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid")
 if hum then local ok,d=pcall(function()return hum:GetAppliedDescription()end);if ok and d then return d end end
 local ok,d=pcall(function()return Players:GetHumanoidDescriptionFromUserId(player.UserId)end);if ok then return d end
end
local function render(desc)
 world:ClearAllChildren();if not desc then return end
 local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,Enum.HumanoidRigType.R15)end)
 if not ok or not m then return end
 m.Parent=world
 for _,d in ipairs(m:GetDescendants()) do if d:IsA("BasePart") then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false end end
 local _,sz=m:GetBoundingBox();local h=math.max(sz.Y,5);local target=Vector3.new(0,h*.48,0);vcam.CFrame=CFrame.new(target+Vector3.new(0,.1,h*1.12),target);vcam.FieldOfView=34
end
local function resetPreview()
 baseDescription=getDescription();previewDescription=baseDescription and baseDescription:Clone() or nil;render(previewDescription);selectedLabel.Text="Avatar saat ini";selectedPrice.Text=""
end
local function assetType(it)local s=tostring(it and it.AssetType or "");return s:gsub("Enum%.AvatarAssetType%.","") end
local function applyItem(it)
 if not it then return false end
 if not previewDescription then resetPreview() end
 local d=previewDescription and previewDescription:Clone();if not d then return false end
 local id=idOf(it);if not id then return false end
 local t=assetType(it)
 if t=="Shirt" then d.Shirt=id
 elseif t=="TShirt" then d.GraphicTShirt=id
 elseif t=="Pants" then d.Pants=id
 else
  local mapped=ACCESSORY_MAP[t];if not mapped then return false end
  local ok,accType=pcall(function()return Enum.AccessoryType[mapped]end);if not ok or not accType then return false end
  local ok2,list=pcall(function()return d:GetAccessories(true)end);if not ok2 then return false end
  table.insert(list,{AssetId=id,AccessoryType=accType,Order=#list+1})
  local ok3=pcall(function()d:SetAccessories(list,true)end);if not ok3 then return false end
 end
 previewDescription=d;render(d);selectedLabel.Text=nameOf(it);selectedPrice.Text=priceText(it);return true
end
local function selectItem(it)
 selected=it;selectedLabel.Text=nameOf(it);selectedPrice.Text=priceText(it);applyItem(it)
end

local function clearGui(container,keep)
 for _,x in ipairs(container:GetChildren()) do if not keep[x] and not x:IsA("UIGridLayout") and not x:IsA("UIListLayout") and not x:IsA("UIPadding") then x:Destroy() end end
end
local function productCard(parent,it)
 local id=idOf(it);if not id then return end
 local card=btn(parent,"",UDim2.new(),UDim2.new(),C.panel);card.Name="Item_"..id;stroke(card,C.line,.48)
 local im=img(card,UDim2.fromOffset(6,6),UDim2.new(1,-12,0,112));im.Image=thumb(id)
 local n=txt(card,nameOf(it),UDim2.fromOffset(7,121),UDim2.new(1,-14,0,30),Enum.Font.GothamMedium,9,C.white,Enum.TextXAlignment.Center)
 local p=txt(card,priceText(it),UDim2.fromOffset(7,151),UDim2.new(1,-14,0,18),Enum.Font.GothamBold,9,C.yellow,Enum.TextXAlignment.Center)
 card.Activated:Connect(function()selectItem(it)end)
end
local function renderCart()
 clearGui(cartList,{[cl]=true});local total=0
 for _,it in ipairs(cart) do
  total+=priceOf(it) or 0
  local row=Instance.new("Frame");row.Size=UDim2.new(1,-4,0,66);row.BackgroundColor3=C.panel;row.BorderSizePixel=0;row.Parent=cartList;corner(row,9)
  local im=img(row,UDim2.fromOffset(6,6),UDim2.fromOffset(54,54));im.Image=thumb(idOf(it))
  txt(row,nameOf(it),UDim2.fromOffset(70,7),UDim2.new(1,-160,0,28),Enum.Font.GothamBold,10,C.white)
  txt(row,priceText(it),UDim2.fromOffset(70,35),UDim2.new(1,-160,0,20),Enum.Font.GothamBold,9,C.yellow)
  local rm=btn(row,"HAPUS",UDim2.new(1,-82,.5,-15),UDim2.fromOffset(72,30),C.red);rm.TextSize=9
  rm.Activated:Connect(function()for i=#cart,1,-1 do if idOf(cart[i])==idOf(it) then table.remove(cart,i) break end end;renderCart()end)
 end
 cartStatus.Text=#cart==0 and "Keranjang kosong." or string.format("%d item • R$ %d",#cart,total)
end
local function renderSaved()
 clearGui(savedList,{[sl]=true});for _,it in ipairs(saved) do productCard(savedList,it) end
 savedNote.Text=#saved==0 and "Belum ada item tersimpan." or (tostring(#saved).." item tersimpan • tap untuk mencoba")
end

local function queryDefaults(category)
 local store=STORE[activeStore] or STORE.FASHION
 if category=="BEST" then return TYPES.BEST,store.q end
 if category=="HAIR" then return TYPES.HAIR,"hair" end
 if category=="CLOTHES" then return TYPES.CLOTHES,(activeStore=="STREET" and "streetwear" or "clothing") end
 if category=="ACCESSORY" then return TYPES.ACCESSORY,"accessory" end
 if category=="FACE" then return TYPES.FACE,"face" end
 if category=="SHOES" then return TYPES.SHOES,"shoes" end
 return TYPES.BEST,store.q
end
local function doSearch()
 searchToken+=1;local token=searchToken;retry.Visible=false;status.Text="Memuat Roblox Marketplace…";status.TextColor3=C.yellow
 clearGui(productList,{[grid]=true})
 local types,defaultQ=queryDefaults(activeCategory);local q=search.Text:match("^%s*(.-)%s*$");if q=="" then q=defaultQ end
 task.delay(6,function()if token==searchToken then status.Text="Marketplace lambat. Tap RETRY.";status.TextColor3=C.red;retry.Visible=true end end)
 task.spawn(function()
  local function request(useTypes,keyword)
   local params=CatalogSearchParams.new();params.IncludeOffSale=false;params.Limit=20;if useTypes then params.AssetTypes=types end;if keyword and keyword~="" then params.SearchKeyword=keyword end
   local ok,pages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end);if not ok or not pages then return nil end
   local ok2,items=pcall(function()return pages:GetCurrentPage()end);return ok2 and items or nil
  end
  local items=request(true,q)
  if token~=searchToken then return end
  if not items or #items==0 then items=request(false,q) end
  if token~=searchToken then return end
  retry.Visible=false
  if not items then status.Text="Marketplace belum merespons. Tap RETRY.";status.TextColor3=C.red;retry.Visible=true;return end
  if #items==0 then status.Text="Tidak ada hasil. Coba kata lain.";status.TextColor3=C.muted;return end
  for _,it in ipairs(items) do productCard(productList,it) end
  status.Text=tostring(#items).." produk live • tap item untuk TRY";status.TextColor3=C.green
 end)
end
local function openProducts(category)
 activeCategory=category;productTitle.Text=category=="BEST" and "Terbaik" or category;local _,q=queryDefaults(category);search.Text=q;showModule("PRODUCTS");doSearch()
end
for _,b in ipairs({best,hair,clothes,accessory,face,shoes}) do b.Activated:Connect(function()openProducts(b.Name)end) end
backProducts.Activated:Connect(function()showModule("CATEGORIES")end)
go.Activated:Connect(doSearch);retry.Activated:Connect(doSearch);search.FocusLost:Connect(function(enter)if enter then doSearch() end end)

for key,b in pairs(storeButtons) do
 b.Activated:Connect(function()activeStore=key;local d=STORE[key];catBtn.Text="Katalog";storeBtn.Text=d.title;showModule("CATEGORIES")end)
end
catBtn.Activated:Connect(function()showModule("CATEGORIES")end)
storeBtn.Activated:Connect(function()showModule("STORES")end)
homeTool.Activated:Connect(function()showModule("CATEGORIES")end)
cartTool.Activated:Connect(function()renderCart();showModule("CART")end)
saveTool.Activated:Connect(function()renderSaved();showModule("SAVED")end)
resetTool.Activated:Connect(resetPreview)
cartClose.Activated:Connect(function()showModule("CATEGORIES")end)
savedClose.Activated:Connect(function()showModule("CATEGORIES")end)
saveCurrent.Activated:Connect(function()
 if previewDescription then pcall(function()AvatarEditorService:PromptSaveAvatar(previewDescription,Enum.HumanoidRigType.R15)end) end
end)

-- A compact action strip appears only after selecting a product.
local action=Instance.new("Frame");action.Name="SelectedActions";action.AnchorPoint=Vector2.new(.5,1);action.BackgroundColor3=C.dark;action.BackgroundTransparency=.04;action.BorderSizePixel=0;action.Visible=false;action.Parent=root;corner(action,12);stroke(action,C.line,.25)
local tryB=btn(action,"TRY",UDim2.fromOffset(8,7),UDim2.fromOffset(78,36),C.panel2)
local cartB=btn(action,"+ CART",UDim2.fromOffset(92,7),UDim2.fromOffset(90,36),C.panel2)
local favB=btn(action,"♡ SAVE",UDim2.fromOffset(188,7),UDim2.fromOffset(92,36),C.panel2)
local buyB=btn(action,"BUY",UDim2.fromOffset(286,7),UDim2.fromOffset(88,36),C.green);buyB.TextColor3=Color3.new(0,0,0)
local function syncAction()action.Visible=root.Visible and selected~=nil end
selectedLabel:GetPropertyChangedSignal("Text"):Connect(syncAction)
tryB.Activated:Connect(function()if selected then applyItem(selected)end end)
cartB.Activated:Connect(function()if not selected then return end;for _,it in ipairs(cart) do if idOf(it)==idOf(selected) then renderCart();showModule("CART");return end end;table.insert(cart,selected);renderCart();showModule("CART")end)
favB.Activated:Connect(function()if not selected then return end;for _,it in ipairs(saved) do if idOf(it)==idOf(selected) then renderSaved();showModule("SAVED");return end end;table.insert(saved,1,selected);renderSaved();showModule("SAVED")end)
local function promptBuy(it)if not it then return end;local id=idOf(it);if not id then return end;pcall(function()MarketplaceService:PromptPurchase(player,id,true,Enum.CurrencyType.Default)end)end
buyB.Activated:Connect(function()promptBuy(selected)end)
checkout.Activated:Connect(function()if cart[1] then promptBuy(cart[1]) end end)
MarketplaceService.PromptPurchaseFinished:Connect(function(who,assetId,bought)if who~=player or not bought then return end;for i=#cart,1,-1 do if idOf(cart[i])==assetId then table.remove(cart,i) end end;renderCart()end)

local function closeCatalog()
 root.Visible=false;action.Visible=false;restoreUI();player:SetAttribute("BBYAMallCatalogFocusMode",false)
end
local exit=btn(root,"×",UDim2.new(1,-72,0,0),UDim2.fromOffset(44,44),C.panel2);exit.TextSize=24
exit.Activated:Connect(closeCatalog)

local function responsive()
 camera=workspace.CurrentCamera or camera;local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local touch=UserInputService.TouchEnabled;local topSafe=touch and 112 or 78;local left=math.max(72,math.floor(vp.X*.065));local rightSafe=touch and 150 or 70;local bottom=36
 local totalW=math.min(1220,math.max(760,vp.X-left-rightSafe));local totalH=math.min(510,math.max(360,vp.Y-topSafe-bottom-48));local leftW=math.clamp(math.floor(totalW*.30),260,360);local gap=24;local rightW=totalW-leftW-gap
 top.Position=UDim2.fromOffset(left+leftW+gap+math.floor((rightW-440)/2),topSafe)
 avatar.Position=UDim2.fromOffset(left,topSafe+52);avatar.Size=UDim2.fromOffset(leftW,totalH)
 host.Position=UDim2.fromOffset(left+leftW+gap,topSafe+52);host.Size=UDim2.fromOffset(rightW,totalH)
 action.Position=UDim2.fromOffset(left+leftW+gap+math.floor(rightW/2),vp.Y-bottom);action.Size=UDim2.fromOffset(382,50)
 exit.Position=UDim2.fromOffset(math.min(vp.X-rightSafe+50,left+totalW-44),topSafe)
 -- category cards / item grids remain usable at smaller landscape widths.
 grid.CellSize=UDim2.new(rightW<700 and .32 or .24,-8,0,178);sl.CellSize=UDim2.new(rightW<700 and .32 or .24,-8,0,160)
end
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)

remote.OnClientEvent:Connect(function(kind,data)
 if kind~="open" or typeof(data)~="table" then return end
 activeStore=tostring(data.key or "FASHION");if not STORE[activeStore] then activeStore="FASHION" end
 local d=STORE[activeStore];storeBtn.Text=d.title;selected=nil;resetPreview();showModule("CATEGORIES");responsive();hideOtherUI();root.Visible=true;player:SetAttribute("BBYAMallCatalogFocusMode",true);syncAction()
end)
player.CharacterAdded:Connect(function()task.delay(.6,function()if root.Visible then resetPreview() end end)end)

task.defer(responsive)
print("[BBYA] Mall Catalog UI v8 online: reference modular architecture / CoreGui-safe / catalog focus mode")
