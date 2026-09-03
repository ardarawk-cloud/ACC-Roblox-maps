-- BBYA SOCIAL HUB — MALL CATALOG UI v8 / V10 TENANT EXPERIENCE
-- TEST CANDIDATE ONLY. One Mall catalog authority: tenant kiosk + live Marketplace + preview + cart/save/buy.
-- Static workflow markers retained: CatalogLauncher / CATEGORIES / STORES / PRODUCTS / Keranjang Belanja.
-- GAMEPLAY LOCK: physical tenant determines catalog scope. Directory teleports only; shopping starts from an indoor display.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AvatarEditorService=game:GetService("AvatarEditorService")
local MarketplaceService=game:GetService("MarketplaceService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local remote=remotes:WaitForChild("MallRobuxCommerce")
local mallAction=remotes:WaitForChild("MallAction")

local OLD=pg:FindFirstChild("BBYAMallRobuxCommerceUI")
if OLD then OLD:Destroy() end

local C={
 dark=Color3.fromRGB(22,23,27),panel=Color3.fromRGB(34,35,40),panel2=Color3.fromRGB(43,44,50),line=Color3.fromRGB(72,73,82),
 white=Color3.fromRGB(246,246,247),muted=Color3.fromRGB(172,173,180),cyan=Color3.fromRGB(61,201,230),green=Color3.fromRGB(75,235,125),
 pink=Color3.fromRGB(231,44,212),orange=Color3.fromRGB(255,117,84),yellow=Color3.fromRGB(244,183,77),blue=Color3.fromRGB(61,181,229),red=Color3.fromRGB(233,73,89),
 purple=Color3.fromRGB(178,75,235)
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
local function idOf(it)return tonumber(it and (it.Id or it.AssetId or it.id))end
local function itemTypeOf(it)
 local s=tostring(it and (it.ItemType or it.Type) or "Asset"):gsub("Enum%.AvatarItemType%.","")
 return s=="Bundle" and "Bundle" or "Asset"
end
local function thumb(it)
 local id=idOf(it);if not id then return "" end
 return string.format("rbxthumb://type=%s&id=%d&w=420&h=420",itemTypeOf(it),id)
end
local function nameOf(it)return tostring(it and (it.Name or it.name) or "Item")end
local function priceOf(it)return tonumber(it and (it.Price or it.LowestPrice or it.price))end
local function priceText(it)local p=priceOf(it);return p~=nil and ("R$ "..tostring(p)) or "OFFSALE"end
local function itemKey(it)return itemTypeOf(it)..":"..tostring(idOf(it) or 0)end

local TYPES={
 HAIR={Enum.AvatarAssetType.HairAccessory},
 CLOTHES={Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.TShirt,Enum.AvatarAssetType.Pants,Enum.AvatarAssetType.TShirtAccessory,Enum.AvatarAssetType.ShirtAccessory,Enum.AvatarAssetType.JacketAccessory,Enum.AvatarAssetType.SweaterAccessory,Enum.AvatarAssetType.PantsAccessory,Enum.AvatarAssetType.ShortsAccessory,Enum.AvatarAssetType.DressSkirtAccessory},
 SHOES={Enum.AvatarAssetType.LeftShoeAccessory,Enum.AvatarAssetType.RightShoeAccessory},
 ACCESSORY={Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.NeckAccessory,Enum.AvatarAssetType.ShoulderAccessory,Enum.AvatarAssetType.FrontAccessory,Enum.AvatarAssetType.BackAccessory,Enum.AvatarAssetType.WaistAccessory},
 FACE={Enum.AvatarAssetType.Head,Enum.AvatarAssetType.Face,Enum.AvatarAssetType.DynamicHead,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.EyebrowAccessory,Enum.AvatarAssetType.EyelashAccessory,Enum.AvatarAssetType.FaceMakeup,Enum.AvatarAssetType.LipMakeup,Enum.AvatarAssetType.EyeMakeup},
 BEAUTY={Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.Head,Enum.AvatarAssetType.Face,Enum.AvatarAssetType.DynamicHead,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.EyebrowAccessory,Enum.AvatarAssetType.EyelashAccessory,Enum.AvatarAssetType.FaceMakeup,Enum.AvatarAssetType.LipMakeup,Enum.AvatarAssetType.EyeMakeup},
}
local ACCESSORY_MAP={Hat="Hat",HairAccessory="Hair",FaceAccessory="Face",NeckAccessory="Neck",ShoulderAccessory="Shoulder",FrontAccessory="Front",BackAccessory="Back",WaistAccessory="Waist",TShirtAccessory="TShirt",ShirtAccessory="Shirt",SweaterAccessory="Sweater",JacketAccessory="Jacket",PantsAccessory="Pants",ShortsAccessory="Shorts",DressSkirtAccessory="DressSkirt",LeftShoeAccessory="LeftShoe",RightShoeAccessory="RightShoe",EyebrowAccessory="Eyebrow",EyelashAccessory="Eyelash"}
local DIRECT_DESC={Head="Head",Face="Face",Torso="Torso",RightArm="RightArm",LeftArm="LeftArm",LeftLeg="LeftLeg",RightLeg="RightLeg",ClimbAnimation="ClimbAnimation",FallAnimation="FallAnimation",IdleAnimation="IdleAnimation",JumpAnimation="JumpAnimation",RunAnimation="RunAnimation",SwimAnimation="SwimAnimation",WalkAnimation="WalkAnimation",MoodAnimation="MoodAnimation"}
local TYPE_BY_VALUE={}
for _,e in ipairs(Enum.AvatarAssetType:GetEnumItems())do TYPE_BY_VALUE[e.Value]=e.Name end
local ASSET_TYPE_CACHE={}

local STORE={
 FASHION={tenant="luma",title="LUMA FASHION",sub="Fashion & layered clothing",catalog="PAKAIAN",assetTypes=TYPES.CLOTHES,keyword="",accent=C.pink},
 SHOES={tenant="stride",title="STRIDE SNEAKERS",sub="Shoes & sneaker catalog",catalog="SEPATU",assetTypes=TYPES.SHOES,keyword="shoes",accent=C.orange},
 BYTE={tenant="byte",title="BYTE TECH",sub="Tech & cyber accessories",catalog="TECH ACCESSORIES",assetTypes=TYPES.ACCESSORY,keyword="tech",accent=C.cyan},
 DAILY={tenant="daily",title="DAILY MARKET",sub="Food & fun accessories",catalog="FOOD & FUN",assetTypes=TYPES.ACCESSORY,keyword="food",accent=C.green},
 MONO={tenant="mono",title="MONO HOME",sub="Lifestyle & home-inspired accessories",catalog="LIFESTYLE",assetTypes=TYPES.ACCESSORY,keyword="home",accent=C.yellow},
 BEAUTY={tenant="muse",title="MUSE BEAUTY",sub="Hair, face & beauty",catalog="HAIR • FACE • BEAUTY",assetTypes=TYPES.BEAUTY,keyword="",accent=C.purple},
 NORTH={tenant="north",title="NORTH LABEL",sub="Accessories & street style",catalog="AKSESORI",assetTypes=TYPES.ACCESSORY,keyword="street",accent=C.blue},
 STREETWEAR={tenant="street",title="STREET UNIT",sub="Streetwear & layered clothing",catalog="STREETWEAR",assetTypes=TYPES.CLOTHES,keyword="streetwear",accent=C.red},
 BOOKS={tenant="page",title="PAGE & CO",sub="Books & reading accessories",catalog="BOOK ACCESSORIES",assetTypes=TYPES.ACCESSORY,keyword="book",accent=C.yellow},
 GLOW={tenant="glow",title="GLOW LAB",sub="Glow, makeup & beauty",catalog="GLOW & BEAUTY",assetTypes=TYPES.BEAUTY,keyword="makeup",accent=C.pink},
 SOUND={tenant="sound",title="SOUND ROOM",sub="Headphones & music accessories",catalog="MUSIC ACCESSORIES",assetTypes=TYPES.ACCESSORY,keyword="headphones",accent=C.cyan},
 FIT={tenant="fit",title="FIT DISTRICT",sub="Sportswear & active style",catalog="SPORTSWEAR",assetTypes=TYPES.CLOTHES,keyword="sports",accent=C.green},
}
local REMOTE_ALIAS={STREET="NORTH"}
local TENANTS={
 {id="luma",name="LUMA FASHION",cat="Fashion",floor=1,key="FASHION"},{id="stride",name="STRIDE SNEAKERS",cat="Sneakers",floor=1,key="SHOES"},
 {id="byte",name="BYTE TECH",cat="Electronics / UGC Tech",floor=1,key="BYTE"},{id="daily",name="DAILY MARKET",cat="Food / Fun UGC",floor=1,key="DAILY"},
 {id="mono",name="MONO HOME",cat="Lifestyle UGC",floor=1,key="MONO"},{id="muse",name="MUSE BEAUTY",cat="Hair / Face / Beauty",floor=1,key="BEAUTY"},
 {id="north",name="NORTH LABEL",cat="Accessories",floor=2,key="NORTH"},{id="street",name="STREET UNIT",cat="Streetwear",floor=2,key="STREETWEAR"},
 {id="page",name="PAGE & CO",cat="Book Accessories",floor=2,key="BOOKS"},{id="glow",name="GLOW LAB",cat="Glow / Makeup",floor=2,key="GLOW"},
 {id="sound",name="SOUND ROOM",cat="Music Accessories",floor=2,key="SOUND"},{id="fit",name="FIT DISTRICT",cat="Sportswear",floor=2,key="FIT"},
 {id="food",name="BBYA FOOD HALL",cat="Food Court",floor=3},{id="cafe",name="SKYLINE CAFE",cat="Cafe",floor=3},
 {id="arcade",name="PIXEL ARCADE",cat="Arcade",floor=3},{id="kids",name="LITTLE CITY",cat="Family",floor=3},
 {id="cinema",name="BBYA CINEMA",cat="Cinema",floor=4},{id="lounge",name="SKY LOUNGE",cat="Lounge / Events",floor=4},
}

local gui=Instance.new("ScreenGui")
gui.Name="BBYAMallRobuxCommerceUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=260;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("BBYAMallCatalogAuthority","V10_TENANT_EXPERIENCE")
local root=Instance.new("Frame");root.Name="CatalogRoot";root.Size=UDim2.fromScale(1,1);root.BackgroundTransparency=1;root.Visible=false;root.Parent=gui

local top=Instance.new("Frame");top.Name="CatalogLauncher";top.BackgroundTransparency=1;top.Size=UDim2.fromOffset(440,46);top.Parent=root
local catBtn=btn(top,"Katalog",UDim2.fromOffset(0,0),UDim2.fromOffset(208,44),Color3.fromRGB(55,74,84));catBtn.TextSize=20
local storeBtn=btn(top,"Toko",UDim2.fromOffset(224,0),UDim2.fromOffset(208,44),Color3.fromRGB(55,74,84));storeBtn.TextSize=20

local avatar=Instance.new("Frame");avatar.Name="AvatarCard";avatar.BackgroundColor3=C.panel;avatar.BorderSizePixel=0;avatar.Parent=root;corner(avatar,12);stroke(avatar,C.line,.18)
local viewport=Instance.new("ViewportFrame");viewport.Name="AvatarViewport";viewport.Position=UDim2.fromOffset(7,7);viewport.Size=UDim2.new(1,-14,1,-83);viewport.BackgroundColor3=Color3.fromRGB(24,25,30);viewport.BorderSizePixel=0;viewport.Ambient=Color3.fromRGB(235,235,235);viewport.LightColor=Color3.fromRGB(255,252,245);viewport.LightDirection=Vector3.new(-1,-1,-1);viewport.Parent=avatar;corner(viewport,9)
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

local host=Instance.new("Frame");host.Name="ModuleHost";host.BackgroundTransparency=1;host.Parent=root
local modules={}
local function module(name)local f=Instance.new("Frame");f.Name=name;f.Size=UDim2.fromScale(1,1);f.BackgroundTransparency=1;f.Visible=false;f.Parent=host;modules[name]=f;return f end
local categories=module("CATEGORIES")
local stores=module("STORES")
local products=module("PRODUCTS")
local cartView=module("CART")
local savedView=module("SAVED")
local function showModule(name)for n,f in pairs(modules)do f.Visible=n==name end end

local backProducts=btn(products,"‹ KEMBALI",UDim2.fromOffset(0,0),UDim2.fromOffset(118,34),C.panel2);backProducts.TextColor3=C.cyan
local productTitle=txt(products,"Katalog",UDim2.fromOffset(130,0),UDim2.new(1,-354,0,34),Enum.Font.GothamBold,20,C.white)
local search=Instance.new("TextBox");search.PlaceholderText="Cari di toko..";search.Text="";search.ClearTextOnFocus=false;search.BackgroundColor3=C.panel2;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.Gotham;search.TextSize=11;search.BorderSizePixel=0;search.Parent=products;corner(search,8)
local go=btn(products,"GO",UDim2.new(),UDim2.fromOffset(52,34),C.panel2)
local status=txt(products,"",UDim2.fromOffset(0,42),UDim2.new(1,-90,0,22),Enum.Font.GothamMedium,10,C.muted)
local retry=btn(products,"RETRY",UDim2.new(1,-78,0,40),UDim2.fromOffset(78,26),C.red);retry.Visible=false;retry.TextSize=9
local productList=Instance.new("ScrollingFrame");productList.Position=UDim2.fromOffset(0,70);productList.Size=UDim2.new(1,0,1,-70);productList.BackgroundTransparency=1;productList.BorderSizePixel=0;productList.ScrollBarThickness=3;productList.AutomaticCanvasSize=Enum.AutomaticSize.Y;productList.CanvasSize=UDim2.new();productList.ScrollingDirection=Enum.ScrollingDirection.Y;productList.Parent=products
local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.new(.24,-8,0,178);grid.CellPadding=UDim2.fromOffset(10,10);grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=productList

local storeTitle=txt(stores,"MALL DIRECTORY • 18 DESTINATIONS",UDim2.fromOffset(0,0),UDim2.new(1,0,0,36),Enum.Font.GothamBold,13,C.white,Enum.TextXAlignment.Center)
storeTitle.BackgroundTransparency=.08;storeTitle.BackgroundColor3=C.dark;corner(storeTitle,9);stroke(storeTitle,C.line,.45)
local storeGrid=Instance.new("ScrollingFrame");storeGrid.Name="TenantDirectory";storeGrid.Position=UDim2.fromOffset(0,44);storeGrid.Size=UDim2.new(1,0,1,-44);storeGrid.BackgroundTransparency=1;storeGrid.BorderSizePixel=0;storeGrid.AutomaticCanvasSize=Enum.AutomaticSize.Y;storeGrid.CanvasSize=UDim2.new();storeGrid.ScrollBarThickness=3;storeGrid.Parent=stores
local sg=Instance.new("UIGridLayout");sg.CellSize=UDim2.new(.49,-6,0,72);sg.CellPadding=UDim2.fromOffset(10,10);sg.SortOrder=Enum.SortOrder.LayoutOrder;sg.Parent=storeGrid

local cartTitle=txt(cartView,"Keranjang Belanja",UDim2.fromOffset(0,0),UDim2.new(1,-50,0,36),Enum.Font.GothamBold,24,C.white)
local cartClose=btn(cartView,"×",UDim2.new(1,-40,0,0),UDim2.fromOffset(40,36),C.panel2);cartClose.TextSize=22
local cartList=Instance.new("ScrollingFrame");cartList.Position=UDim2.fromOffset(0,48);cartList.Size=UDim2.new(1,0,1,-105);cartList.BackgroundTransparency=1;cartList.BorderSizePixel=0;cartList.AutomaticCanvasSize=Enum.AutomaticSize.Y;cartList.CanvasSize=UDim2.new();cartList.ScrollBarThickness=3;cartList.Parent=cartView
local cl=Instance.new("UIListLayout");cl.Padding=UDim.new(0,8);cl.Parent=cartList
local cartStatus=txt(cartView,"Keranjang kosong.",UDim2.new(0,0,1,-48),UDim2.new(.55,0,0,40),Enum.Font.Gotham,13,C.muted)
local checkout=btn(cartView,"PEMBAYARAN",UDim2.new(1,-184,1,-48),UDim2.fromOffset(184,40),C.green);checkout.TextColor3=Color3.new(0,0,0)
local savedTitle=txt(savedView,"Pakaian Tersimpan",UDim2.fromOffset(0,0),UDim2.new(1,-50,0,36),Enum.Font.GothamBold,24,C.white)
local savedClose=btn(savedView,"×",UDim2.new(1,-40,0,0),UDim2.fromOffset(40,36),C.panel2);savedClose.TextSize=22
local saveCurrent=btn(savedView,"SIMPAN LOOK SAAT INI",UDim2.fromOffset(0,48),UDim2.fromOffset(190,36),C.green);saveCurrent.TextColor3=Color3.new(0,0,0)
local savedNote=txt(savedView,"Belum ada item tersimpan.",UDim2.fromOffset(0,92),UDim2.new(1,0,0,26),Enum.Font.Gotham,11,C.muted)
local savedList=Instance.new("ScrollingFrame");savedList.Position=UDim2.fromOffset(0,124);savedList.Size=UDim2.new(1,0,1,-124);savedList.BackgroundTransparency=1;savedList.BorderSizePixel=0;savedList.AutomaticCanvasSize=Enum.AutomaticSize.Y;savedList.CanvasSize=UDim2.new();savedList.ScrollBarThickness=3;savedList.Parent=savedView
local sl=Instance.new("UIGridLayout");sl.CellSize=UDim2.new(.24,-8,0,160);sl.CellPadding=UDim2.fromOffset(10,10);sl.Parent=savedList

local selected=nil
local baseDescription=nil
local previewDescription=nil
local cart={}
local saved={}
local activeStore="FASHION"
local searchToken=0
local catalogPages=nil
local loadingPage=false
local exhausted=false
local loadedCount=0
local focusSaved={}
local focusConn=nil
local camera=workspace.CurrentCamera

local function hideOtherUI()
 for _,g in ipairs(pg:GetChildren())do if g:IsA("ScreenGui")and g~=gui then if focusSaved[g]==nil then focusSaved[g]=g.Enabled end;g.Enabled=false end end
 if focusConn then focusConn:Disconnect()end
 focusConn=pg.ChildAdded:Connect(function(g)if root.Visible and g:IsA("ScreenGui")and g~=gui then task.defer(function()if g.Parent then focusSaved[g]=g.Enabled;g.Enabled=false end end)end end)
end
local function restoreUI()if focusConn then focusConn:Disconnect();focusConn=nil end;for g,enabled in pairs(focusSaved)do if g and g.Parent then g.Enabled=enabled end end;table.clear(focusSaved)end
local function closeCatalog()root.Visible=false;restoreUI();player:SetAttribute("BBYAMallCatalogFocusMode",false)end

local BODY_NAMES={Head=true,UpperTorso=true,LowerTorso=true,HumanoidRootPart=true,LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,RightUpperArm=true,RightLowerArm=true,RightHand=true,LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,RightUpperLeg=true,RightLowerLeg=true,RightFoot=true,Torso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true}
local function bodyBounds(model)
 local minV=Vector3.new(math.huge,math.huge,math.huge);local maxV=Vector3.new(-math.huge,-math.huge,-math.huge);local count=0
 for _,d in ipairs(model:GetDescendants())do if d:IsA("BasePart")and BODY_NAMES[d.Name]then local p=d.Position;local h=d.Size*.5;minV=Vector3.new(math.min(minV.X,p.X-h.X),math.min(minV.Y,p.Y-h.Y),math.min(minV.Z,p.Z-h.Z));maxV=Vector3.new(math.max(maxV.X,p.X+h.X),math.max(maxV.Y,p.Y+h.Y),math.max(maxV.Z,p.Z+h.Z));count+=1 end end
 if count<3 then return nil end;return(minV+maxV)*.5,maxV-minV
end
local function getDescription()
 local ch=player.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid");if hum then local ok,d=pcall(function()return hum:GetAppliedDescription()end);if ok and d then return d end end
 local ok,d=pcall(function()return Players:GetHumanoidDescriptionFromUserId(player.UserId)end);if ok then return d end
end
local function cleanModel(m)for _,d in ipairs(m:GetDescendants())do if d:IsA("Script")or d:IsA("LocalScript")then d:Destroy()elseif d:IsA("BasePart")then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false end end end
local function framePreviewModel(m)
 if not m then return false end
 local incoming=m.Parent~=world
 cleanModel(m)
 local center,size=bodyBounds(m)
 if not center or not size then if incoming then m:Destroy()end;return false end
 if incoming then world:ClearAllChildren();m.Parent=world end
 local rp=m:FindFirstChild("HumanoidRootPart",true);local forward=rp and rp.CFrame.LookVector or Vector3.new(0,0,-1);forward=Vector3.new(forward.X,0,forward.Z);if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1)else forward=forward.Unit end
 local h=math.clamp(size.Y,4.5,8.5);local w=math.clamp(math.max(size.X,size.Z),2.5,6);local target=center;vcam.FieldOfView=34;vcam.CFrame=CFrame.lookAt(target+forward*math.max(h*1.72,w*1.95),target,Vector3.yAxis);return true
end
local function render(desc)if not desc then return false end;local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,Enum.HumanoidRigType.R15)end);if not ok or not m then return false end;return framePreviewModel(m)end
local function renderLiveCharacter()local ch=player.Character;if not ch then return false end;local old=ch.Archivable;ch.Archivable=true;local ok,m=pcall(function()return ch:Clone()end);ch.Archivable=old;if not ok or not m then return false end;return framePreviewModel(m)end
local function resetPreview()baseDescription=getDescription();previewDescription=baseDescription and baseDescription:Clone()or nil;if not renderLiveCharacter()then render(previewDescription)end;selectedLabel.Text="Avatar saat ini";selectedPrice.Text=""end
local function typeNameFromRaw(raw)
 local t=nil
 if typeof(raw)=="EnumItem"then t=raw.Name
 elseif tonumber(raw)then t=TYPE_BY_VALUE[tonumber(raw)]
 else t=tostring(raw or ""):gsub("Enum%.AvatarAssetType%.","")end
 if t==""or t=="Unknown"or tonumber(t)then return nil end
 return t
end
local function supportedAssetType(t)return t and (t=="Shirt"or t=="TShirt"or t=="Pants"or DIRECT_DESC[t]~=nil or ACCESSORY_MAP[t]~=nil)end
local function resolveAssetType(raw,id)
 id=tonumber(id)
 if id and ASSET_TYPE_CACHE[id]then return ASSET_TYPE_CACHE[id]end

 -- SearchCatalogAsync can return an absent/Unknown AssetType. ProductInfo was
 -- the last runtime-proven source for TRY, so resolve from the asset itself first.
 if id then
  local ok,info=pcall(function()return MarketplaceService:GetProductInfo(id,Enum.InfoType.Asset)end)
  local t=ok and info and TYPE_BY_VALUE[tonumber(info.AssetTypeId)]or nil
  if supportedAssetType(t)then ASSET_TYPE_CACHE[id]=t;return t end
 end

 local t=typeNameFromRaw(raw)
 if supportedAssetType(t)then if id then ASSET_TYPE_CACHE[id]=t end;return t end

 if id then
  local ok,details=pcall(function()return AvatarEditorService:GetItemDetails(id,Enum.AvatarItemType.Asset)end)
  t=ok and details and typeNameFromRaw(details.AssetType or details.AssetTypeId)or nil
  if supportedAssetType(t)then ASSET_TYPE_CACHE[id]=t;return t end
 end
end
local function applyAssetToDescription(d,id,t)
 if not d or not id or not t then return false end;if t=="Shirt"then d.Shirt=id;return true elseif t=="TShirt"then d.GraphicTShirt=id;return true elseif t=="Pants"then d.Pants=id;return true end
 local prop=DIRECT_DESC[t];if prop then return pcall(function()d[prop]=id end)end;local mapped=ACCESSORY_MAP[t];if not mapped then return false end
 local ok,accType=pcall(function()return Enum.AccessoryType[mapped]end);if not ok or not accType then return false end;local ok2,list=pcall(function()return d:GetAccessories(true)end);if not ok2 then return false end
 if mapped=="Hair"or mapped=="LeftShoe"or mapped=="RightShoe"then for i=#list,1,-1 do if list[i].AccessoryType==accType then table.remove(list,i)end end end
 table.insert(list,{AssetId=id,AccessoryType=accType,Order=#list+1});return pcall(function()d:SetAccessories(list,true)end)
end
local function applyItem(it)
 if not it then return false end;if not previewDescription then previewDescription=getDescription()end;local d=previewDescription and previewDescription:Clone();if not d then return false end
 local id=idOf(it);if not id or itemTypeOf(it)=="Bundle"then return false end
 local changed=applyAssetToDescription(d,id,resolveAssetType(it.AssetType,id))
 if not changed or not render(d)then return false end
 previewDescription=d;selectedLabel.Text="TRY • "..nameOf(it);selectedPrice.Text=priceText(it);return true
end
local function selectItem(it)selected=it;selectedLabel.Text=nameOf(it);selectedPrice.Text=priceText(it)end

local function clearGui(container,keep)for _,x in ipairs(container:GetChildren())do if not keep[x]and not x:IsA("UIGridLayout")and not x:IsA("UIListLayout")and not x:IsA("UIPadding")then x:Destroy()end end end
local function productCard(parent,it)
 local id=idOf(it);if not id then return end;local card=btn(parent,"",UDim2.new(),UDim2.new(),C.panel);card.Name="Item_"..itemKey(it):gsub(":","_");stroke(card,C.line,.48)
 local im=img(card,UDim2.fromOffset(6,6),UDim2.new(1,-12,0,112));im.Image=thumb(it);txt(card,nameOf(it),UDim2.fromOffset(7,121),UDim2.new(1,-14,0,30),Enum.Font.GothamMedium,9,C.white,Enum.TextXAlignment.Center);txt(card,priceText(it),UDim2.fromOffset(7,151),UDim2.new(1,-14,0,18),Enum.Font.GothamBold,9,C.yellow,Enum.TextXAlignment.Center);card.Activated:Connect(function()selectItem(it)end)
end
local function renderCart()
 clearGui(cartList,{[cl]=true});local total=0;for _,it in ipairs(cart)do total+=priceOf(it)or 0;local row=Instance.new("Frame");row.Size=UDim2.new(1,-4,0,66);row.BackgroundColor3=C.panel;row.BorderSizePixel=0;row.Parent=cartList;corner(row,9);local im=img(row,UDim2.fromOffset(6,6),UDim2.fromOffset(54,54));im.Image=thumb(it);txt(row,nameOf(it),UDim2.fromOffset(70,7),UDim2.new(1,-160,0,28),Enum.Font.GothamBold,10,C.white);txt(row,priceText(it),UDim2.fromOffset(70,35),UDim2.new(1,-160,0,20),Enum.Font.GothamBold,9,C.yellow);local rm=btn(row,"HAPUS",UDim2.new(1,-82,.5,-15),UDim2.fromOffset(72,30),C.red);rm.TextSize=9;rm.Activated:Connect(function()local k=itemKey(it);for i=#cart,1,-1 do if itemKey(cart[i])==k then table.remove(cart,i)break end end;renderCart()end)end;cartStatus.Text=#cart==0 and"Keranjang kosong."or string.format("%d item • R$ %d",#cart,total)
end
local function renderSaved()clearGui(savedList,{[sl]=true});for _,it in ipairs(saved)do productCard(savedList,it)end;savedNote.Text=#saved==0 and"Belum ada item tersimpan."or(tostring(#saved).." item tersimpan")end

local function querySpec()local d=STORE[activeStore]or STORE.FASHION;return{assetTypes=d.assetTypes,keyword=d.keyword or"",title=d.catalog}end
local function appendCurrentPage(token)
 if token~=searchToken or not catalogPages then return false end;local ok,items=pcall(function()return catalogPages:GetCurrentPage()end);if not ok or not items then return false end
 for _,it in ipairs(items)do productCard(productList,it);loadedCount+=1 end;exhausted=catalogPages.IsFinished;status.Text=string.format("%d produk live%s",loadedCount,exhausted and""or" • scroll untuk lainnya");status.TextColor3=C.green;return true
end
local function loadNextPage()
 if loadingPage or exhausted or not catalogPages then return end;loadingPage=true;local token=searchToken;status.Text="Memuat produk berikutnya…";status.TextColor3=C.yellow
 task.spawn(function()local ok=pcall(function()catalogPages:AdvanceToNextPageAsync()end);if token==searchToken then if not ok then status.Text="Gagal memuat. Scroll lagi.";status.TextColor3=C.red else appendCurrentPage(token)end end;loadingPage=false end)
end
local function doSearch()
 searchToken+=1;local token=searchToken;catalogPages=nil;loadingPage=false;exhausted=false;loadedCount=0;retry.Visible=false;status.Text="Memuat katalog tenant…";status.TextColor3=C.yellow;clearGui(productList,{[grid]=true});productList.CanvasPosition=Vector2.zero
 local spec=querySpec();local q=search.Text:match("^%s*(.-)%s*$");if q==""then q=spec.keyword end
 task.delay(7,function()if token==searchToken and loadedCount==0 then status.Text="Marketplace lambat. Tap RETRY.";status.TextColor3=C.red;retry.Visible=true end end)
 task.spawn(function()local params=CatalogSearchParams.new();params.IncludeOffSale=false;params.Limit=30;params.AssetTypes=spec.assetTypes;if q~=""then params.SearchKeyword=q end;local ok,pages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end);if token~=searchToken then return end;if not ok or not pages then status.Text="Marketplace belum merespons. Tap RETRY.";status.TextColor3=C.red;retry.Visible=true;return end;catalogPages=pages;retry.Visible=false;if not appendCurrentPage(token)then status.Text="Tidak ada hasil. Coba kata lain.";status.TextColor3=C.muted end end)
end
local function openProducts()
 local d=STORE[activeStore]or STORE.FASHION;productTitle.Text=d.catalog;search.Text="";search.PlaceholderText="Cari di "..d.title.."..";selected=nil;showModule("PRODUCTS");doSearch()
end

go.Activated:Connect(doSearch);retry.Activated:Connect(doSearch);search.FocusLost:Connect(function(enter)if enter then doSearch()end end)
productList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()if not products.Visible or loadingPage or exhausted or not catalogPages then return end;if productList.CanvasPosition.Y+productList.AbsoluteWindowSize.Y>=productList.AbsoluteCanvasSize.Y-240 then loadNextPage()end end)

local action=Instance.new("Frame");action.Name="SelectedActions";action.AnchorPoint=Vector2.new(.5,1);action.BackgroundColor3=C.dark;action.BackgroundTransparency=.04;action.BorderSizePixel=0;action.Visible=false;action.Parent=root;corner(action,12);stroke(action,C.line,.25)
local tryB=btn(action,"TRY",UDim2.fromOffset(8,7),UDim2.fromOffset(78,36),C.panel2);local cartB=btn(action,"+ CART",UDim2.fromOffset(92,7),UDim2.fromOffset(90,36),C.panel2);local favB=btn(action,"♡ SAVE",UDim2.fromOffset(188,7),UDim2.fromOffset(92,36),C.panel2);local buyB=btn(action,"BUY",UDim2.fromOffset(286,7),UDim2.fromOffset(88,36),C.green);buyB.TextColor3=Color3.new(0,0,0)
local function syncAction()action.Visible=root.Visible and products.Visible and selected~=nil end
selectedLabel:GetPropertyChangedSignal("Text"):Connect(syncAction)
tryB.Activated:Connect(function()if selected then local ok=applyItem(selected);if ok then status.Text="TRY aktif • lihat avatar di kiri";status.TextColor3=C.green else status.Text="Item ini belum bisa dipreview.";status.TextColor3=C.red end end end)
cartB.Activated:Connect(function()if not selected then return end;local k=itemKey(selected);for _,it in ipairs(cart)do if itemKey(it)==k then renderCart();showModule("CART");return end end;table.insert(cart,selected);renderCart();showModule("CART")end)
favB.Activated:Connect(function()if not selected then return end;local k=itemKey(selected);for _,it in ipairs(saved)do if itemKey(it)==k then renderSaved();showModule("SAVED");return end end;table.insert(saved,1,selected);renderSaved();showModule("SAVED")end)
local function promptBuy(it)if not it then return end;local id=idOf(it);if not id then return end;if itemTypeOf(it)=="Bundle"then pcall(function()MarketplaceService:PromptBundlePurchase(player,id)end)else pcall(function()MarketplaceService:PromptPurchase(player,id,true,Enum.CurrencyType.Default)end)end end
buyB.Activated:Connect(function()promptBuy(selected)end);checkout.Activated:Connect(function()if cart[1]then promptBuy(cart[1])end end)

local function responsive()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local touch=UserInputService.TouchEnabled
 local topSafe=touch and 112 or 78
 local left=math.max(72,math.floor(vp.X*.065))
 local rightSafe=touch and 150 or 70
 local bottom=36
 local shiftX=touch and -91 or 0
 local shiftY=touch and -63 or 0
 local totalW=math.min(1220,math.max(760,vp.X-left-rightSafe))
 local leftW=math.clamp(math.floor(totalW*.30),260,360)
 local gap=24
 local rightW=totalW-leftW-gap
 local hostX=left+leftW+gap+shiftX
 local hostY=topSafe+52+shiftY
 local totalH
 if touch then totalH=math.min(330,math.max(190,vp.Y-hostY-10)) else totalH=math.min(510,math.max(360,vp.Y-topSafe-bottom-48)) end
 local navReserve=56
 local navW=math.min(440,math.max(320,rightW-navReserve-12))
 local navGap=12
 local navButtonW=math.floor((navW-navGap)/2)
 top.Size=UDim2.fromOffset(navW,46);catBtn.Position=UDim2.fromOffset(0,0);catBtn.Size=UDim2.fromOffset(navButtonW,44);storeBtn.Position=UDim2.fromOffset(navButtonW+navGap,0);storeBtn.Size=UDim2.fromOffset(navButtonW,44)
 top.Position=UDim2.fromOffset(hostX+math.floor((rightW-navW-navReserve)/2),topSafe+shiftY);avatar.Position=UDim2.fromOffset(left+shiftX,hostY);avatar.Size=UDim2.fromOffset(leftW,totalH);host.Position=UDim2.fromOffset(hostX,hostY);host.Size=UDim2.fromOffset(rightW,totalH)
 local exit=root:FindFirstChild("ExitButton");if exit then exit.Position=UDim2.fromOffset(hostX+rightW-44,topSafe+shiftY)end
 action.Position=UDim2.fromOffset(hostX+math.floor(rightW/2),vp.Y-bottom+shiftY);action.Size=UDim2.fromOffset(382,50)
 local searchW=math.clamp(math.floor(rightW*.26),150,220);local goW=52;local searchX=rightW-searchW-goW-10
 backProducts.Position=UDim2.fromOffset(0,0);productTitle.Position=UDim2.fromOffset(130,0);productTitle.Size=UDim2.fromOffset(math.max(90,searchX-138),34);productTitle.TextSize=rightW<700 and 15 or 17
 search.Position=UDim2.fromOffset(searchX,0);search.Size=UDim2.fromOffset(searchW,34);go.Position=UDim2.fromOffset(rightW-goW,0);go.Size=UDim2.fromOffset(goW,34);status.Position=UDim2.fromOffset(0,44);retry.Position=UDim2.fromOffset(rightW-78,42);productList.Position=UDim2.fromOffset(0,76);productList.Size=UDim2.new(1,0,1,-76)
 grid.CellSize=UDim2.new(rightW<700 and .32 or .24,-8,0,178);sl.CellSize=UDim2.new(rightW<700 and .32 or .24,-8,0,160);sg.CellSize=UDim2.new(.49,-6,0,touch and 62 or 72)
 task.defer(function()local m=world:FindFirstChildOfClass("Model");if m then framePreviewModel(m)end end)
end

local function openStore(key)
 if not STORE[key]then return end
 activeStore=key;local d=STORE[key];storeBtn.Text=d.title;selected=nil;resetPreview();responsive();hideOtherUI();root.Visible=true;player:SetAttribute("BBYAMallCatalogFocusMode",true);openProducts();syncAction()
end

for index,t in ipairs(TENANTS)do
 local accent=t.key and (STORE[t.key] and STORE[t.key].accent or C.blue) or C.panel2
 local b=btn(storeGrid,string.format("L%d • %s\n%s\nTELEPORT →",t.floor,t.name,t.cat),UDim2.new(),UDim2.new(),accent);b.LayoutOrder=index;b.TextWrapped=true;b.TextSize=11
 b.Activated:Connect(function()mallAction:FireServer("guide",t.id);closeCatalog()end)
end

catBtn.Activated:Connect(function()openProducts();syncAction()end)
storeBtn.Activated:Connect(function()selected=nil;showModule("STORES");syncAction()end)
homeTool.Activated:Connect(function()openProducts();syncAction()end)
backProducts.Activated:Connect(closeCatalog)
cartTool.Activated:Connect(function()renderCart();showModule("CART");syncAction()end)
saveTool.Activated:Connect(function()renderSaved();showModule("SAVED");syncAction()end)
resetTool.Activated:Connect(resetPreview)
cartClose.Activated:Connect(function()openProducts();syncAction()end)
savedClose.Activated:Connect(function()openProducts();syncAction()end)
saveCurrent.Activated:Connect(function()if previewDescription then pcall(function()AvatarEditorService:PromptSaveAvatar(previewDescription,Enum.HumanoidRigType.R15)end)end end)

local exit=btn(root,"×",UDim2.new(1,-72,0,0),UDim2.fromOffset(44,44),C.panel2);exit.Name="ExitButton";exit.TextSize=24;exit.Activated:Connect(closeCatalog)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)
viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()task.defer(function()local m=world:FindFirstChildOfClass("Model");if m then framePreviewModel(m)end end)end)

local function installTenantKiosks()
 local build=workspace:WaitForChild("BBYA_ZERO_BUILD",60);local mall=build and build:WaitForChild("BBYAMall",60);if not mall then return end
 for key,d in pairs(STORE)do
  local unit=mall:FindFirstChild("Tenant_"..d.tenant)
  if unit then
   for _,x in ipairs(unit:GetDescendants())do
    if x:IsA("ProximityPrompt") and (x.Name=="NativeRobuxShopPrompt" or (x.Parent and (x.Parent.Name=="Interact" or x.Parent.Name=="StoreDoor"))) then x.Enabled=false end
    if x:IsA("BillboardGui") and x.Name=="NativeRobuxBadge" then x.Enabled=false end
   end
   local anchor=unit:FindFirstChild("Display2") or unit:FindFirstChild("Counter")
   if anchor and anchor:IsA("BasePart")then
    local old=unit:FindFirstChild("BBYACatalogKioskLocal");if old then old:Destroy()end
    local side=anchor.Position.X<0 and -1 or 1
    local screen=Instance.new("Part");screen.Name="BBYACatalogKioskLocal";screen.Size=Vector3.new(5.8,3.4,.28);screen.Anchored=true;screen.CanCollide=false;screen.CanTouch=false;screen.CanQuery=false;screen.Material=Enum.Material.SmoothPlastic;screen.Color=Color3.fromRGB(16,17,20)
    local pos=anchor.Position+Vector3.new(0,2.55,0);screen.CFrame=CFrame.lookAt(pos,pos+Vector3.new(-side,0,0));screen.Parent=unit
    local surface=Instance.new("SurfaceGui");surface.Face=Enum.NormalId.Front;surface.PixelsPerStud=70;surface.Parent=screen
    local frame=Instance.new("Frame");frame.Size=UDim2.fromScale(1,1);frame.BackgroundColor3=Color3.fromRGB(15,16,19);frame.BorderSizePixel=0;frame.Parent=surface
    local title=txt(frame,d.title.."\n"..d.catalog.."\nTAP BROWSE",UDim2.fromScale(.05,.08),UDim2.fromScale(.9,.84),Enum.Font.GothamBold,18,C.white,Enum.TextXAlignment.Center);title.TextYAlignment=Enum.TextYAlignment.Center
    local st=Instance.new("UIStroke");st.Color=d.accent;st.Thickness=3;st.Parent=frame
    local pr=Instance.new("ProximityPrompt");pr.Name="BBYATenantCatalogPrompt";pr.ActionText="BROWSE";pr.ObjectText=d.title;pr.MaxActivationDistance=8;pr.HoldDuration=0;pr.RequiresLineOfSight=false;pr.Parent=screen
    pr.Triggered:Connect(function()openStore(key)end)
   end
  end
 end
end

task.defer(installTenantKiosks)
remote.OnClientEvent:Connect(function(kind,data)
 if kind~="open"or typeof(data)~="table"then return end
 local key=tostring(data.key or"FASHION");key=REMOTE_ALIAS[key]or key;if STORE[key]then openStore(key)end
end)
player.CharacterAdded:Connect(function()task.delay(.8,function()if root.Visible then resetPreview()end end)end)
task.defer(responsive)
print("[BBYA] Mall Catalog V10 online: 12 retail tenant kiosks + 18-destination teleport directory + direct live Marketplace")
