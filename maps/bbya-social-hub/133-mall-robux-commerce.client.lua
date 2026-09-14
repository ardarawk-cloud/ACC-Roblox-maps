-- BBYA SOCIAL HUB — MALL CATALOG UI v14 / RELIABLE COMPACT SHOP
-- Mall-only client authority: kiosk opens the panel immediately; Marketplace/avatar work runs after.
-- Compact KATALOG / TOKO / CART / SAVE panels. Native Roblox checkout only.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AvatarEditorService=game:GetService("AvatarEditorService")
local MarketplaceService=game:GetService("MarketplaceService")
local UserInputService=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local remote=remotes:WaitForChild("MallRobuxCommerce")

local old=pg:FindFirstChild("BBYAMallRobuxCommerceUI")
if old then old:Destroy() end

local C={
 bg=Color3.fromRGB(20,21,25),panel=Color3.fromRGB(31,32,37),card=Color3.fromRGB(42,43,49),line=Color3.fromRGB(72,73,82),
 white=Color3.fromRGB(246,246,247),muted=Color3.fromRGB(169,171,179),cyan=Color3.fromRGB(61,201,230),green=Color3.fromRGB(75,235,125),
 yellow=Color3.fromRGB(244,183,77),red=Color3.fromRGB(233,73,89),pink=Color3.fromRGB(231,74,184),orange=Color3.fromRGB(241,127,72),
 blue=Color3.fromRGB(78,135,225),purple=Color3.fromRGB(176,91,224),
}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 9);x.Parent=o end
local function stroke(o,col,tr)local x=Instance.new("UIStroke");x.Color=col or C.line;x.Thickness=1;x.Transparency=tr or .45;x.Parent=o end
local function label(p,text,pos,size,font,ts,col,align)
 local x=Instance.new("TextLabel");x.BackgroundTransparency=1;x.Text=text;x.Position=pos;x.Size=size;x.Font=font or Enum.Font.Gotham;x.TextSize=ts or 10
 x.TextColor3=col or C.white;x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center;x.TextWrapped=true;x.Parent=p;return x
end
local function button(p,text,pos,size,bg)
 local x=Instance.new("TextButton");x.Text=text;x.Position=pos;x.Size=size;x.BackgroundColor3=bg or C.card;x.TextColor3=C.white;x.Font=Enum.Font.GothamBold;x.TextSize=9
 x.BorderSizePixel=0;x.AutoButtonColor=true;x.Active=true;x.Parent=p;corner(x,8);return x
end
local function idOf(it)return tonumber(it and(it.Id or it.AssetId or it.id))end
local function itemTypeOf(it)local s=tostring(it and(it.ItemType or it.Type)or"Asset"):gsub("Enum%.AvatarItemType%.","");return s=="Bundle"and"Bundle"or"Asset"end
local function itemName(it)return tostring(it and(it.Name or it.name)or"Item")end
local function itemPrice(it)return tonumber(it and(it.Price or it.LowestPrice or it.price))end
local function priceText(it)local p=itemPrice(it);return p and("R$ "..math.floor(p))or"OFFSALE"end
local function itemKey(it)return itemTypeOf(it)..":"..tostring(idOf(it)or 0)end
local function thumb(it)local id=idOf(it);if not id then return""end;return string.format("rbxthumb://type=%s&id=%d&w=420&h=420",itemTypeOf(it),id)end

local TYPES={
 CLOTHES={Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.TShirt,Enum.AvatarAssetType.Pants,Enum.AvatarAssetType.TShirtAccessory,Enum.AvatarAssetType.ShirtAccessory,Enum.AvatarAssetType.JacketAccessory,Enum.AvatarAssetType.SweaterAccessory,Enum.AvatarAssetType.PantsAccessory,Enum.AvatarAssetType.ShortsAccessory,Enum.AvatarAssetType.DressSkirtAccessory},
 ACCESSORY={Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.NeckAccessory,Enum.AvatarAssetType.ShoulderAccessory,Enum.AvatarAssetType.FrontAccessory,Enum.AvatarAssetType.BackAccessory,Enum.AvatarAssetType.WaistAccessory,Enum.AvatarAssetType.LeftShoeAccessory,Enum.AvatarAssetType.RightShoeAccessory},
 BEAUTY={Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.Head,Enum.AvatarAssetType.Face,Enum.AvatarAssetType.DynamicHead,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.EyebrowAccessory,Enum.AvatarAssetType.EyelashAccessory,Enum.AvatarAssetType.FaceMakeup,Enum.AvatarAssetType.LipMakeup,Enum.AvatarAssetType.EyeMakeup},
}
local STORE={
 FASHION={title="LUMA FASHION",short="PAKAIAN",types=TYPES.CLOTHES,keyword="",fallback="",accent=C.pink},
 SHOES={title="STRIDE SNEAKERS",short="SEPATU",types=TYPES.ACCESSORY,keyword="sneakers",fallback="shoes",accent=C.orange},
 BYTE={title="BYTE TECH",short="TECH",types=TYPES.ACCESSORY,keyword="cyber",fallback="tech",accent=C.cyan},
 DAILY={title="DAILY MARKET",short="FOOD & FUN",types=TYPES.ACCESSORY,keyword="food",fallback="snack",accent=C.green},
 MONO={title="MONO HOME",short="LIFESTYLE",types=TYPES.ACCESSORY,keyword="backpack",fallback="bag",accent=C.yellow},
 BEAUTY={title="MUSE BEAUTY",short="BEAUTY",types=TYPES.BEAUTY,keyword="",fallback="hair",accent=C.purple},
 NORTH={title="NORTH LABEL",short="AKSESORI",types=TYPES.ACCESSORY,keyword="street",fallback="accessory",accent=C.blue},
 STREETWEAR={title="STREET UNIT",short="STREETWEAR",types=TYPES.CLOTHES,keyword="streetwear",fallback="street",accent=C.red},
 BOOKS={title="PAGE & CO",short="BOOKS",types=TYPES.ACCESSORY,keyword="book",fallback="reading",accent=C.yellow},
 GLOW={title="GLOW LAB",short="GLOW",types=TYPES.BEAUTY,keyword="makeup",fallback="beauty",accent=C.pink},
 SOUND={title="SOUND ROOM",short="MUSIC",types=TYPES.ACCESSORY,keyword="headphones",fallback="music",accent=C.cyan},
 FIT={title="FIT DISTRICT",short="SPORTS",types=TYPES.CLOTHES,keyword="sport",fallback="sportswear",accent=C.green},
}
local STORE_ORDER={"FASHION","SHOES","BYTE","DAILY","MONO","BEAUTY","NORTH","STREETWEAR","BOOKS","GLOW","SOUND","FIT"}
local REMOTE_ALIAS={STREET="NORTH"}

local gui=Instance.new("ScreenGui");gui.Name="BBYAMallRobuxCommerceUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=260;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("BBYAMallCatalogAuthority","V14_RELIABLE_COMPACT_SHOP")
local root=Instance.new("Frame");root.Name="CatalogRoot";root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=Color3.new(0,0,0);root.BackgroundTransparency=.32;root.BorderSizePixel=0;root.Visible=false;root.Parent=gui
local shell=Instance.new("Frame");shell.Name="CompactShop";shell.AnchorPoint=Vector2.new(.5,.5);shell.BackgroundColor3=C.bg;shell.BorderSizePixel=0;shell.Parent=root;corner(shell,12);stroke(shell,C.line,.25)
local top=Instance.new("Frame");top.BackgroundColor3=C.panel;top.BorderSizePixel=0;top.Parent=shell;corner(top,10)
local tabs={}
for _,spec in ipairs({{"KATALOG","PRODUCTS"},{"TOKO","STORES"},{"CART","CART"},{"SAVE","SAVED"}})do local b=button(top,spec[1],UDim2.new(),UDim2.new(),C.card);tabs[spec[2]]=b end
local close=button(top,"×",UDim2.new(),UDim2.new(),C.card);close.TextSize=18

local preview=Instance.new("Frame");preview.Name="AvatarPreview";preview.BackgroundColor3=C.panel;preview.BorderSizePixel=0;preview.Parent=shell;corner(preview,10);stroke(preview,C.line,.42)
local viewport=Instance.new("ViewportFrame");viewport.BackgroundColor3=Color3.fromRGB(23,24,28);viewport.BorderSizePixel=0;viewport.Ambient=Color3.fromRGB(225,225,225);viewport.LightColor=Color3.fromRGB(255,250,242);viewport.LightDirection=Vector3.new(-1,-1,-1);viewport.Parent=preview;corner(viewport,8)
local world=Instance.new("WorldModel");world.Parent=viewport
local vcam=Instance.new("Camera");vcam.FieldOfView=34;vcam.Parent=viewport;viewport.CurrentCamera=vcam
local previewName=label(preview,"Avatar saat ini",UDim2.new(),UDim2.new(),Enum.Font.GothamBold,9,C.white,Enum.TextXAlignment.Center)
local previewPrice=label(preview,"",UDim2.new(),UDim2.new(),Enum.Font.GothamBold,8,C.yellow,Enum.TextXAlignment.Center)
local reset=button(preview,"RESET",UDim2.new(),UDim2.new(),C.card);reset.TextSize=8
local saveLook=button(preview,"SAVE AVATAR",UDim2.new(),UDim2.new(),C.green);saveLook.TextSize=8;saveLook.TextColor3=Color3.new(0,0,0)

local content=Instance.new("Frame");content.Name="PanelHost";content.BackgroundColor3=C.panel;content.BorderSizePixel=0;content.Parent=shell;corner(content,10);stroke(content,C.line,.42)
local modules={}
local function module(name)local f=Instance.new("Frame");f.Name=name;f.Size=UDim2.fromScale(1,1);f.BackgroundTransparency=1;f.Visible=false;f.Parent=content;modules[name]=f;return f end
local products=module("PRODUCTS");local stores=module("STORES");local cartView=module("CART");local savedView=module("SAVED")
local function show(name)for n,f in pairs(modules)do f.Visible=n==name end end

local shopTitle=label(products,"Katalog",UDim2.new(),UDim2.new(),Enum.Font.GothamBold,13,C.white)
local search=Instance.new("TextBox");search.PlaceholderText="Cari produk..";search.Text="";search.ClearTextOnFocus=false;search.BackgroundColor3=C.card;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.Gotham;search.TextSize=10;search.BorderSizePixel=0;search.Parent=products;corner(search,8)
local go=button(products,"GO",UDim2.new(),UDim2.new(),C.card)
local status=label(products,"",UDim2.new(),UDim2.new(),Enum.Font.GothamMedium,8,C.muted)
local retry=button(products,"RETRY",UDim2.new(),UDim2.new(),C.red);retry.TextSize=7;retry.Visible=false
local productList=Instance.new("ScrollingFrame");productList.BackgroundTransparency=1;productList.BorderSizePixel=0;productList.ScrollBarThickness=3;productList.AutomaticCanvasSize=Enum.AutomaticSize.Y;productList.CanvasSize=UDim2.new();productList.ScrollingDirection=Enum.ScrollingDirection.Y;productList.Parent=products
local productGrid=Instance.new("UIGridLayout");productGrid.CellPadding=UDim2.fromOffset(7,7);productGrid.SortOrder=Enum.SortOrder.LayoutOrder;productGrid.Parent=productList

local storesTitle=label(stores,"PILIH TOKO • 12 RETAIL TENANTS",UDim2.new(),UDim2.new(),Enum.Font.GothamBold,12,C.white,Enum.TextXAlignment.Center)
local storeList=Instance.new("ScrollingFrame");storeList.BackgroundTransparency=1;storeList.BorderSizePixel=0;storeList.ScrollBarThickness=3;storeList.AutomaticCanvasSize=Enum.AutomaticSize.Y;storeList.CanvasSize=UDim2.new();storeList.Parent=stores
local storeGrid=Instance.new("UIGridLayout");storeGrid.CellPadding=UDim2.fromOffset(7,7);storeGrid.SortOrder=Enum.SortOrder.LayoutOrder;storeGrid.Parent=storeList

local cartTitle=label(cartView,"CART",UDim2.new(),UDim2.new(),Enum.Font.GothamBold,15,C.white)
local cartMeta=label(cartView,"Keranjang kosong.",UDim2.new(),UDim2.new(),Enum.Font.Gotham,9,C.muted)
local cartList=Instance.new("ScrollingFrame");cartList.BackgroundTransparency=1;cartList.BorderSizePixel=0;cartList.ScrollBarThickness=3;cartList.AutomaticCanvasSize=Enum.AutomaticSize.Y;cartList.CanvasSize=UDim2.new();cartList.Parent=cartView
local cartLayout=Instance.new("UIListLayout");cartLayout.Padding=UDim.new(0,6);cartLayout.Parent=cartList
local savedTitle=label(savedView,"SAVED",UDim2.new(),UDim2.new(),Enum.Font.GothamBold,15,C.white)
local savedMeta=label(savedView,"Belum ada item tersimpan.",UDim2.new(),UDim2.new(),Enum.Font.Gotham,9,C.muted)
local savedList=Instance.new("ScrollingFrame");savedList.BackgroundTransparency=1;savedList.BorderSizePixel=0;savedList.ScrollBarThickness=3;savedList.AutomaticCanvasSize=Enum.AutomaticSize.Y;savedList.CanvasSize=UDim2.new();savedList.Parent=savedView
local savedGrid=Instance.new("UIGridLayout");savedGrid.CellPadding=UDim2.fromOffset(7,7);savedGrid.SortOrder=Enum.SortOrder.LayoutOrder;savedGrid.Parent=savedList

local currentStore="FASHION";local cart={};local saved={};local searchToken=0;local pages=nil;local loadingPage=false;local exhausted=false;local loaded={};local loadedCount=0;local previewDescription=nil
local TYPE_BY_VALUE={};for _,e in ipairs(Enum.AvatarAssetType:GetEnumItems())do TYPE_BY_VALUE[e.Value]=e.Name end
local function clearDynamic(parent)for _,ch in ipairs(parent:GetChildren())do if not ch:IsA("UIGridLayout")and not ch:IsA("UIListLayout")and not ch:IsA("UIPadding")then ch:Destroy()end end end
local function uniqueAdd(list,it)local k=itemKey(it);for _,v in ipairs(list)do if itemKey(v)==k then return false end end;table.insert(list,it);return true end
local function getDescription()
 local ch=player.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid");if hum then local ok,d=pcall(function()return hum:GetAppliedDescription()end);if ok and d then return d end end
 local ok,d=pcall(function()return Players:GetHumanoidDescriptionFromUserId(player.UserId)end);if ok then return d end
end
local BODY={Head=true,UpperTorso=true,LowerTorso=true,HumanoidRootPart=true,LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,RightUpperArm=true,RightLowerArm=true,RightHand=true,LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,RightUpperLeg=true,RightLowerLeg=true,RightFoot=true,Torso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true}
local function frameModel(m)
 if not m then return false end
 for _,d in ipairs(m:GetDescendants())do if d:IsA("Script")or d:IsA("LocalScript")then d:Destroy()elseif d:IsA("BasePart")then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false end end
 local minV=Vector3.new(math.huge,math.huge,math.huge);local maxV=Vector3.new(-math.huge,-math.huge,-math.huge);local count=0
 for _,d in ipairs(m:GetDescendants())do if d:IsA("BasePart")and BODY[d.Name]then local h=d.Size*.5;local p=d.Position;minV=Vector3.new(math.min(minV.X,p.X-h.X),math.min(minV.Y,p.Y-h.Y),math.min(minV.Z,p.Z-h.Z));maxV=Vector3.new(math.max(maxV.X,p.X+h.X),math.max(maxV.Y,p.Y+h.Y),math.max(maxV.Z,p.Z+h.Z));count=count+1 end end
 if count<3 then m:Destroy();return false end
 local center=(minV+maxV)*.5;local size=maxV-minV;local h=math.clamp(size.Y,4.5,8.5);local w=math.clamp(math.max(size.X,size.Z),2.5,6)
 world:ClearAllChildren();m.Parent=world;vcam.CFrame=CFrame.lookAt(center+Vector3.new(0,h*.02,math.max(h*1.72,w*1.9)),center+Vector3.new(0,h*.02,0));return true
end
local function renderDescription(desc)local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,Enum.HumanoidRigType.R15)end);return ok and m and frameModel(m)or false end
local function resetPreview()previewDescription=getDescription();if previewDescription then previewDescription=previewDescription:Clone();renderDescription(previewDescription)end;previewName.Text="Avatar saat ini";previewPrice.Text=""end
local function typeName(raw,id)
 local t=typeof(raw)=="EnumItem"and raw.Name or tostring(raw or""):gsub("Enum%.AvatarAssetType%.","");if t~=""and t~="nil"then return t end
 if id then local ok,info=pcall(function()return MarketplaceService:GetProductInfo(id,Enum.InfoType.Asset)end);if ok and info then return TYPE_BY_VALUE[tonumber(info.AssetTypeId)]end end
end
local DIRECT={Head="Head",Face="Face",Torso="Torso",RightArm="RightArm",LeftArm="LeftArm",LeftLeg="LeftLeg",RightLeg="RightLeg"}
local function applyItem(it)
 if itemTypeOf(it)=="Bundle"then return false end;local id=idOf(it);if not id then return false end
 if not previewDescription then previewDescription=getDescription()end;local d=previewDescription and previewDescription:Clone();if not d then return false end;local t=typeName(it.AssetType,id)
 if t=="Shirt"then d.Shirt=id elseif t=="TShirt"then d.GraphicTShirt=id elseif t=="Pants"then d.Pants=id
 elseif DIRECT[t]then local ok=pcall(function()d[DIRECT[t]]=id end);if not ok then return false end
 else
  local okEnum,enumItem=pcall(function()return Enum.AvatarAssetType[t]end);if not okEnum or not enumItem then return false end
  local okType,accessoryType=pcall(function()return AvatarEditorService:GetAccessoryType(enumItem)end);if not okType or not accessoryType or accessoryType==Enum.AccessoryType.Unknown then return false end
  local okList,list=pcall(function()return d:GetAccessories(true)end);if not okList then return false end
  if accessoryType==Enum.AccessoryType.Hair or accessoryType==Enum.AccessoryType.LeftShoe or accessoryType==Enum.AccessoryType.RightShoe then for i=#list,1,-1 do if list[i].AccessoryType==accessoryType then table.remove(list,i)end end end
  table.insert(list,{AssetId=id,AccessoryType=accessoryType,Order=#list+1});if not pcall(function()d:SetAccessories(list,true)end)then return false end
 end
 if not renderDescription(d)then return false end;previewDescription=d;previewName.Text="TRY • "..itemName(it);previewPrice.Text=priceText(it);return true
end
local function promptBuy(it)local id=idOf(it);if not id then return end;if itemTypeOf(it)=="Bundle"then pcall(function()MarketplaceService:PromptBundlePurchase(player,id)end)else pcall(function()MarketplaceService:PromptPurchase(player,id,true,Enum.CurrencyType.Default)end)end end

local renderCart,renderSaved
local function makeProductCard(parent,it)
 if not idOf(it)then return end;local card=Instance.new("Frame");card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.Parent=parent;corner(card,8);stroke(card,C.line,.55)
 local im=Instance.new("ImageButton");im.Position=UDim2.fromOffset(5,5);im.Size=UDim2.new(1,-10,0,78);im.BackgroundColor3=C.panel;im.BorderSizePixel=0;im.Image=thumb(it);im.ScaleType=Enum.ScaleType.Crop;im.Parent=card;corner(im,7)
 local nm=label(card,itemName(it),UDim2.fromOffset(6,86),UDim2.new(1,-12,0,25),Enum.Font.GothamMedium,8,C.white,Enum.TextXAlignment.Center);nm.TextTruncate=Enum.TextTruncate.AtEnd
 label(card,priceText(it),UDim2.fromOffset(6,111),UDim2.new(1,-12,0,14),Enum.Font.GothamBold,8,C.yellow,Enum.TextXAlignment.Center)
 local row=Instance.new("Frame");row.BackgroundTransparency=1;row.Position=UDim2.fromOffset(5,128);row.Size=UDim2.new(1,-10,0,25);row.Parent=card;local lay=Instance.new("UIListLayout");lay.FillDirection=Enum.FillDirection.Horizontal;lay.Padding=UDim.new(0,3);lay.Parent=row
 local try=button(row,"TRY",UDim2.new(),UDim2.new(.25,-3,1,0),C.panel);try.TextSize=7;try.TextColor3=C.cyan
 local add=button(row,"CART",UDim2.new(),UDim2.new(.25,-3,1,0),C.panel);add.TextSize=7
 local keep=button(row,"SAVE",UDim2.new(),UDim2.new(.25,-3,1,0),C.panel);keep.TextSize=7
 local buy=button(row,"BUY",UDim2.new(),UDim2.new(.25,-3,1,0),C.green);buy.TextSize=7;buy.TextColor3=Color3.new(0,0,0)
 local function tryNow()if applyItem(it)then status.Text="TRY ON aktif";status.TextColor3=C.green else status.Text="TRY ON tidak tersedia untuk item ini";status.TextColor3=C.red end end
 im.Activated:Connect(tryNow);try.Activated:Connect(tryNow)
 add.Activated:Connect(function()status.Text=uniqueAdd(cart,it)and("Masuk CART • "..itemName(it))or"Sudah ada di CART";status.TextColor3=C.green end)
 keep.Activated:Connect(function()status.Text=uniqueAdd(saved,it)and("Disimpan • "..itemName(it))or"Sudah tersimpan";status.TextColor3=C.green end)
 buy.Activated:Connect(function()promptBuy(it)end)
end
renderCart=function()
 clearDynamic(cartList);local total=0
 for _,it in ipairs(cart)do total=total+(itemPrice(it)or 0);local row=Instance.new("Frame");row.Size=UDim2.new(1,-4,0,58);row.BackgroundColor3=C.card;row.BorderSizePixel=0;row.Parent=cartList;corner(row,8)
  local im=Instance.new("ImageLabel");im.Position=UDim2.fromOffset(5,5);im.Size=UDim2.fromOffset(48,48);im.BackgroundColor3=C.panel;im.BorderSizePixel=0;im.Image=thumb(it);im.ScaleType=Enum.ScaleType.Crop;im.Parent=row;corner(im,6)
  local nm=label(row,itemName(it),UDim2.fromOffset(60,5),UDim2.new(1,-205,0,25),Enum.Font.GothamBold,8,C.white);nm.TextTruncate=Enum.TextTruncate.AtEnd;label(row,priceText(it),UDim2.fromOffset(60,29),UDim2.new(1,-205,0,18),Enum.Font.GothamBold,8,C.yellow)
  local buy=button(row,"BUY",UDim2.new(1,-130,.5,-13),UDim2.fromOffset(54,26),C.green);buy.TextColor3=Color3.new(0,0,0);buy.TextSize=7;local rm=button(row,"HAPUS",UDim2.new(1,-71,.5,-13),UDim2.fromOffset(64,26),C.red);rm.TextSize=7
  buy.Activated:Connect(function()promptBuy(it)end);rm.Activated:Connect(function()local k=itemKey(it);for i=#cart,1,-1 do if itemKey(cart[i])==k then table.remove(cart,i);break end end;renderCart()end)
 end
 cartMeta.Text=#cart==0 and"Keranjang kosong."or string.format("%d item • R$ %d • BUY via Roblox",#cart,total)
end
renderSaved=function()clearDynamic(savedList);for _,it in ipairs(saved)do makeProductCard(savedList,it)end;savedMeta.Text=#saved==0 and"Belum ada item tersimpan."or(tostring(#saved).." item tersimpan")end

local function renderPage(token,p)
 if token~=searchToken or not p then return 0 end;local ok,items=pcall(function()return p:GetCurrentPage()end);if not ok or type(items)~="table"then return 0 end;local added=0
 for _,it in ipairs(items)do local k=itemKey(it);if not loaded[k]then loaded[k]=true;makeProductCard(productList,it);loadedCount=loadedCount+1;added=added+1 end end
 exhausted=p.IsFinished;status.Text=string.format("%d produk live%s",loadedCount,exhausted and""or" • scroll untuk lanjut");status.TextColor3=loadedCount>0 and C.green or C.muted;return added
end
local function queryPages(spec,q)local p=CatalogSearchParams.new();p.IncludeOffSale=false;p.Limit=30;p.AssetTypes=spec.types;if q and q~=""then p.SearchKeyword=q end;return AvatarEditorService:SearchCatalogAsync(p)end
local function doSearch()
 searchToken=searchToken+1;local token=searchToken;pages=nil;loadingPage=false;exhausted=false;loaded={};loadedCount=0;retry.Visible=false;clearDynamic(productList);productList.CanvasPosition=Vector2.zero;status.Text="Memuat Roblox Marketplace…";status.TextColor3=C.yellow
 local spec=STORE[currentStore]or STORE.FASHION;local typed=search.Text:match("^%s*(.-)%s*$")or"";local q=typed~=""and typed or spec.keyword
 task.spawn(function()
  local ok,p=pcall(function()return queryPages(spec,q)end);if token~=searchToken then return end
  if ok and p then pages=p;local added=renderPage(token,p);if added==0 and typed==""and spec.fallback~=""and spec.fallback~=q then loaded={};loadedCount=0;clearDynamic(productList);local ok2,p2=pcall(function()return queryPages(spec,spec.fallback)end);if token~=searchToken then return end;if ok2 and p2 then pages=p2;renderPage(token,p2)end end
   retry.Visible=loadedCount==0;if loadedCount==0 then status.Text="Tidak ada hasil. Coba kata lain.";status.TextColor3=C.muted end
  else status.Text="Marketplace belum merespons. Tap RETRY.";status.TextColor3=C.red;retry.Visible=true end
 end)
end
local function loadNext()
 if loadingPage or exhausted or not pages then return end;loadingPage=true;local token=searchToken;status.Text="Memuat produk berikutnya…";status.TextColor3=C.yellow
 task.spawn(function()local ok=pcall(function()pages:AdvanceToNextPageAsync()end);if token==searchToken then if ok then renderPage(token,pages)else status.Text="Gagal memuat halaman. Scroll/retry.";status.TextColor3=C.red end end;loadingPage=false end)
end
local function openProducts(key)if key and STORE[key]then currentStore=key end;local spec=STORE[currentStore]or STORE.FASHION;shopTitle.Text=spec.title.." • "..spec.short;search.Text="";search.PlaceholderText="Cari di "..spec.title.."..";show("PRODUCTS");doSearch()end
for i,key in ipairs(STORE_ORDER)do local s=STORE[key];local b=button(storeList,string.format("%s\n%s",s.title,s.short),UDim2.new(),UDim2.new(),s.accent);b.LayoutOrder=i;b.TextWrapped=true;b.Activated:Connect(function()openProducts(key)end)end

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera;local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local ok,tl,br=pcall(function()local a,b=GuiService:GetGuiInset();return a,b end);if not ok then tl,br=Vector2.zero,Vector2.zero end;tl=tl or Vector2.zero;br=br or Vector2.zero
 local usableW=math.max(300,vp.X-tl.X-br.X-16);local usableH=math.max(300,vp.Y-tl.Y-br.Y-18);local w=math.min(960,usableW);local h=math.min(620,usableH)
 shell.Position=UDim2.new(.5,math.floor((tl.X-br.X)/2),.5,math.floor((tl.Y-br.Y)/2));shell.Size=UDim2.fromOffset(w,h);top.Position=UDim2.fromOffset(7,7);top.Size=UDim2.new(1,-14,0,38)
 local topW=w-14;local closeW=34;local gap=5;local tabW=math.floor((topW-closeW-gap*5)/4);for index,name in ipairs({"PRODUCTS","STORES","CART","SAVED"})do local b=tabs[name];b.Position=UDim2.fromOffset(gap+(index-1)*(tabW+gap),4);b.Size=UDim2.fromOffset(tabW,30)end;close.Position=UDim2.new(1,-closeW-4,0,4);close.Size=UDim2.fromOffset(closeW,30)
 local bodyY=52;local bodyH=h-bodyY-7;local previewW=math.clamp(math.floor(w*.27),w<520 and 118 or 170,260);local contentX=7+previewW+8
 preview.Position=UDim2.fromOffset(7,bodyY);preview.Size=UDim2.fromOffset(previewW,bodyH);content.Position=UDim2.fromOffset(contentX,bodyY);content.Size=UDim2.fromOffset(w-contentX-7,bodyH)
 viewport.Position=UDim2.fromOffset(6,6);viewport.Size=UDim2.new(1,-12,1,-78);previewName.Position=UDim2.new(0,6,1,-69);previewName.Size=UDim2.new(1,-12,0,17);previewPrice.Position=UDim2.new(0,6,1,-52);previewPrice.Size=UDim2.new(1,-12,0,14)
 reset.Position=UDim2.new(0,6,1,-31);reset.Size=UDim2.new(.38,-5,0,25);saveLook.Position=UDim2.new(.38,4,1,-31);saveLook.Size=UDim2.new(.62,-10,0,25)
 local cw=math.max(150,content.Size.X.Offset);local pad=7;shopTitle.Position=UDim2.fromOffset(pad,4);shopTitle.Size=UDim2.new(1,-pad*2,0,24);local goW=42;local searchW=math.max(88,math.floor(cw*.45));local actualSearch=math.min(searchW,cw-goW-pad*3)
 search.Position=UDim2.fromOffset(pad,32);search.Size=UDim2.fromOffset(actualSearch,28);go.Position=UDim2.fromOffset(actualSearch+pad*2,32);go.Size=UDim2.fromOffset(goW,28);status.Position=UDim2.fromOffset(pad,62);status.Size=UDim2.new(1,-86,0,18);retry.Position=UDim2.new(1,-72,0,61);retry.Size=UDim2.fromOffset(64,20);productList.Position=UDim2.fromOffset(pad,84);productList.Size=UDim2.new(1,-pad*2,1,-91)
 local cols=cw<300 and 1 or(cw<520 and 2 or 3);productGrid.CellSize=UDim2.new(1/cols,-6,0,158);savedGrid.CellSize=productGrid.CellSize;storesTitle.Position=UDim2.fromOffset(pad,6);storesTitle.Size=UDim2.new(1,-pad*2,0,26);storeList.Position=UDim2.fromOffset(pad,38);storeList.Size=UDim2.new(1,-pad*2,1,-45);storeGrid.CellSize=UDim2.new(cw<390 and 1 or .5,-5,0,54)
 cartTitle.Position=UDim2.fromOffset(pad,5);cartTitle.Size=UDim2.new(1,-pad*2,0,24);cartMeta.Position=UDim2.fromOffset(pad,29);cartMeta.Size=UDim2.new(1,-pad*2,0,22);cartList.Position=UDim2.fromOffset(pad,56);cartList.Size=UDim2.new(1,-pad*2,1,-63);savedTitle.Position=cartTitle.Position;savedTitle.Size=cartTitle.Size;savedMeta.Position=cartMeta.Position;savedMeta.Size=cartMeta.Size;savedList.Position=cartList.Position;savedList.Size=cartList.Size
end
local function closePanel()root.Visible=false;player:SetAttribute("BBYAMallCatalogFocusMode",false)end
local function openStore(key)
 key=REMOTE_ALIAS[key]or key;if not STORE[key]then key="FASHION"end;currentStore=key
 root.Visible=true;player:SetAttribute("BBYAMallCatalogFocusMode",true);responsive();show("PRODUCTS");status.Text="Membuka "..STORE[key].title.."…";status.TextColor3=C.cyan
 task.defer(resetPreview);task.defer(function()openProducts(key)end)
end

tabs.PRODUCTS.Activated:Connect(function()openProducts(currentStore)end)
tabs.STORES.Activated:Connect(function()show("STORES")end)
tabs.CART.Activated:Connect(function()renderCart();show("CART")end)
tabs.SAVED.Activated:Connect(function()renderSaved();show("SAVED")end)
close.Activated:Connect(closePanel);reset.Activated:Connect(resetPreview)
saveLook.Activated:Connect(function()if not previewDescription then previewDescription=getDescription()end;if previewDescription then pcall(function()AvatarEditorService:PromptSaveAvatar(previewDescription,Enum.HumanoidRigType.R15)end)end end)
go.Activated:Connect(doSearch);retry.Activated:Connect(doSearch);search.FocusLost:Connect(function(enter)if enter then doSearch()end end)
productList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()if products.Visible and not loadingPage and not exhausted and pages and productList.CanvasPosition.Y+productList.AbsoluteWindowSize.Y>=productList.AbsoluteCanvasSize.Y-180 then loadNext()end end)
remote.OnClientEvent:Connect(function(kind,data)if kind~="open"then return end;local key=typeof(data)=="table"and tostring(data.key or"FASHION")or"FASHION";openStore(key)end)
MarketplaceService.PromptPurchaseFinished:Connect(function(who,_,purchased)if who==player and root.Visible then status.Text=purchased and"Purchase selesai."or"Purchase dibatalkan.";status.TextColor3=purchased and C.green or C.muted end end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)
player.CharacterAdded:Connect(function()if root.Visible then task.delay(.8,resetPreview)end end)
task.defer(responsive)
print("[BBYA] Mall Catalog V14 online: reliable kiosk open + compact KATALOG/TOKO/CART/SAVE")
