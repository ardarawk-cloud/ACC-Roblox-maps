-- BBYA SOCIAL HUB — MALL NATIVE ROBUX COMMERCE CLIENT v5
-- Compact touch-first Mall storefront. Entire product cards are tappable.
-- Temporarily hides the Mall status HUD while shopping, then restores it.
-- Roblox-native catalog + checkout only. No fabricated products.

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
 bg=Color3.fromRGB(9,10,12),card=Color3.fromRGB(27,28,33),card2=Color3.fromRGB(35,36,42),
 white=Color3.fromRGB(244,242,238),muted=Color3.fromRGB(164,164,170),line=Color3.fromRGB(57,58,65),
 gold=Color3.fromRGB(220,184,119),green=Color3.fromRGB(75,205,132),pink=Color3.fromRGB(235,56,147),cyan=Color3.fromRGB(38,192,214)
}
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,col,t,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=t or 1;s.Transparency=tr or .45;s.Parent=o end
local function label(parent,text,pos,size,font,ts,col)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 11;l.TextColor3=col or C.white;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;b.BorderSizePixel=0;b.AutoButtonColor=true;b.Active=true;b.Selectable=true;b.Parent=parent;round(b,8);return b
end

local STORE_TYPES={
 FASHION={Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.TShirt,Enum.AvatarAssetType.Pants,Enum.AvatarAssetType.TShirtAccessory,Enum.AvatarAssetType.ShirtAccessory,Enum.AvatarAssetType.JacketAccessory,Enum.AvatarAssetType.SweaterAccessory,Enum.AvatarAssetType.PantsAccessory,Enum.AvatarAssetType.ShortsAccessory,Enum.AvatarAssetType.DressSkirtAccessory},
 SHOES={Enum.AvatarAssetType.LeftShoeAccessory,Enum.AvatarAssetType.RightShoeAccessory},
 BEAUTY={Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.FaceMakeup,Enum.AvatarAssetType.LipMakeup,Enum.AvatarAssetType.EyeMakeup},
 STREET={Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.NeckAccessory,Enum.AvatarAssetType.ShoulderAccessory,Enum.AvatarAssetType.FrontAccessory,Enum.AvatarAssetType.BackAccessory,Enum.AvatarAssetType.WaistAccessory},
}
local STORE_TRENDS={FASHION={"Y2K","streetwear","grunge"},SHOES={"shoes","sneakers","boots"},BEAUTY={"hair","makeup","baddie"},STREET={"streetwear","goth","cyber"}}

local gui=Instance.new("ScreenGui")
gui.Name="BBYAMallRobuxCommerceUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=92;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
local dim=Instance.new("TextButton")
dim.Name="Dim";dim.Text="";dim.Size=UDim2.fromScale(1,1);dim.BackgroundColor3=Color3.new(0,0,0);dim.BackgroundTransparency=.72;dim.BorderSizePixel=0;dim.Visible=false;dim.AutoButtonColor=false;dim.ZIndex=1;dim.Parent=gui
local panel=Instance.new("Frame")
panel.Name="Panel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.59);panel.Size=UDim2.fromOffset(520,360);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=2;panel.Parent=gui;round(panel,14);stroke(panel,C.gold,1,.42)

local title=label(panel,"BBYA MALL",UDim2.fromOffset(14,10),UDim2.new(1,-58,0,20),Enum.Font.GothamBold,14,C.white);title.ZIndex=3
local subtitle=label(panel,"ROBLOX MARKETPLACE",UDim2.fromOffset(14,30),UDim2.new(1,-58,0,14),Enum.Font.GothamBold,8,C.gold);subtitle.ZIndex=3
local close=button(panel,"×",UDim2.new(1,-42,0,8),UDim2.fromOffset(30,30),C.card2);close.TextSize=18;close.ZIndex=4

local search=Instance.new("TextBox")
search.PlaceholderText="Search catalog…";search.Text="";search.ClearTextOnFocus=false;search.Position=UDim2.fromOffset(12,52);search.Size=UDim2.new(1,-86,0,32);search.BackgroundColor3=C.card;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.Gotham;search.TextSize=11;search.BorderSizePixel=0;search.ZIndex=3;search.Parent=panel;round(search,8);stroke(search,C.line,1,.54)
local searchBtn=button(panel,"SEARCH",UDim2.new(1,-68,0,52),UDim2.fromOffset(56,32),C.card2);searchBtn.ZIndex=4;stroke(searchBtn,C.cyan,1,.45)

local trendBar=Instance.new("ScrollingFrame")
trendBar.Position=UDim2.fromOffset(12,90);trendBar.Size=UDim2.new(1,-24,0,28);trendBar.BackgroundTransparency=1;trendBar.BorderSizePixel=0;trendBar.ScrollBarThickness=0;trendBar.ScrollingDirection=Enum.ScrollingDirection.X;trendBar.CanvasSize=UDim2.new();trendBar.AutomaticCanvasSize=Enum.AutomaticSize.X;trendBar.ZIndex=3;trendBar.Parent=panel
local trendLayout=Instance.new("UIListLayout");trendLayout.FillDirection=Enum.FillDirection.Horizontal;trendLayout.Padding=UDim.new(0,5);trendLayout.Parent=trendBar
local status=label(panel,"Open a Mall shop to browse.",UDim2.fromOffset(12,121),UDim2.new(1,-24,0,16),Enum.Font.GothamMedium,9,C.cyan);status.ZIndex=3

local holder=Instance.new("ScrollingFrame")
holder.Position=UDim2.fromOffset(12,142);holder.Size=UDim2.new(1,-24,1,-154);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.ScrollBarImageColor3=C.gold;holder.CanvasSize=UDim2.new();holder.AutomaticCanvasSize=Enum.AutomaticSize.Y;holder.ScrollingDirection=Enum.ScrollingDirection.Y;holder.Active=true;holder.ZIndex=3;holder.Parent=panel
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(7,7);grid.CellSize=UDim2.new(.5,-4,0,142);grid.Parent=holder

local activeStore="FASHION"
local searching=false
local opened=false
local lastCatalogError=""
local hiddenMallHud=nil
local hiddenMallHudWasEnabled=false

local function setStatus(text,col)status.Text=tostring(text or "");status.TextColor3=col or C.cyan end
local function clearCards()for _,ch in ipairs(holder:GetChildren()) do if ch~=grid then ch:Destroy() end end end
local function clearTrends()for _,ch in ipairs(trendBar:GetChildren()) do if ch~=trendLayout then ch:Destroy() end end end
local function setMallHudHidden(hide)
 local live=pg:FindFirstChild("BBYAMallLiveUI")
 if hide then
  if live and live:IsA("ScreenGui") then hiddenMallHud=live;hiddenMallHudWasEnabled=live.Enabled;live.Enabled=false end
 else
  if hiddenMallHud and hiddenMallHud.Parent and hiddenMallHud:IsA("ScreenGui") then hiddenMallHud.Enabled=hiddenMallHudWasEnabled end
  hiddenMallHud=nil
 end
end
local function hidePanel()
 opened=false;panel.Visible=false;dim.Visible=false;searching=false;setMallHudHidden(false)
end

local function searchCatalog(params)
 lastCatalogError=""
 local ok,pages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if ok and pages then return pages end
 local firstErr=tostring(pages or "unknown")
 task.wait(.30)
 local retryOk,retryPages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if retryOk and retryPages then return retryPages end
 local retryErr=tostring(retryPages or "unknown")
 local legacyOk,legacyPages=pcall(function()return AvatarEditorService:SearchCatalog(params)end)
 if legacyOk and legacyPages then return legacyPages end
 lastCatalogError=string.format("async=%s | retry=%s | legacy=%s",firstErr,retryErr,tostring(legacyPages or "unknown"))
 warn("[BBYA Mall Commerce] Roblox catalog unavailable:",lastCatalogError)
 return nil
end
local function pageItems(pages)
 if not pages then return nil end
 local ok,items=pcall(function()return pages:GetCurrentPage()end)
 if ok and type(items)=="table" then return items end
 return nil
end
local function priceText(item)
 local p=tonumber(item.Price or item.LowestPrice);if p then return "R$ "..math.floor(p) end
 return tostring(item.PriceStatus or "ROBLOX")
end
local function promptPurchase(id)
 setStatus("Opening Roblox checkout…",C.gold)
 local ok,err=pcall(function()MarketplaceService:PromptPurchase(player,id)end)
 if not ok then warn("[BBYA Mall Commerce] PromptPurchase failed:",err);setStatus("Checkout tidak tersedia untuk item ini.",C.pink)end
end
local function addCard(item)
 local id=tonumber(item.Id or item.AssetId);if not id then return end
 local name=tostring(item.Name or ("Asset "..id))
 local card=button(holder,"",UDim2.new(),UDim2.new(),C.card);card.Name="Product_"..id;card.ZIndex=4;stroke(card,C.line,1,.56)
 local img=Instance.new("ImageLabel");img.BackgroundColor3=C.card2;img.BorderSizePixel=0;img.Position=UDim2.fromOffset(6,6);img.Size=UDim2.new(1,-12,0,72);img.Image=string.format("rbxthumb://type=Asset&id=%d&w=150&h=150",id);img.ScaleType=Enum.ScaleType.Crop;img.ZIndex=5;img.Parent=card;round(img,7)
 local nm=label(card,name,UDim2.fromOffset(7,81),UDim2.new(1,-14,0,27),Enum.Font.GothamMedium,8,C.white);nm.TextXAlignment=Enum.TextXAlignment.Center;nm.ZIndex=5
 local price=label(card,priceText(item),UDim2.fromOffset(8,111),UDim2.new(.42,-6,0,22),Enum.Font.GothamBold,9,C.gold);price.TextXAlignment=Enum.TextXAlignment.Center;price.ZIndex=5
 local buy=button(card,"BUY",UDim2.new(.44,0,1,-31),UDim2.new(.56,-7,0,26),Color3.fromRGB(47,70,55));buy.ZIndex=6;stroke(buy,C.green,1,.3)
 local busy=false
 local function activate()
  if busy then return end;busy=true;promptPurchase(id);task.delay(.8,function()busy=false end)
 end
 card.Activated:Connect(activate)
 buy.Activated:Connect(activate)
end

local function makeParams(useTypes,keyword)
 local params=CatalogSearchParams.new();params.IncludeOffSale=false;params.Limit=10
 if useTypes then params.AssetTypes=STORE_TYPES[activeStore] or STORE_TYPES.FASHION end
 if keyword and keyword~="" then params.SearchKeyword=keyword end
 return params
end
local function runSearch()
 if searching or not opened then return end
 searching=true;clearCards();setStatus("Loading Roblox Marketplace…",C.gold)
 local q=search.Text:match("^%s*(.-)%s*$") or ""
 local items=pageItems(searchCatalog(makeParams(true,q)))
 -- Roblox shoe search can return zero when filtering only left/right shoe accessory enums.
 -- In that case use a keyword-only Marketplace query so the test storefront is still usable.
 if (not items or #items==0) and activeStore=="SHOES" then
  local fallback=(q~="" and q) or "shoes"
  items=pageItems(searchCatalog(makeParams(false,fallback)))
 end
 if not items then setStatus("Marketplace belum merespons. Tap SEARCH untuk retry.",C.pink);searching=false;return end
 if #items==0 then setStatus("Tidak ada produk untuk filter ini.",C.muted) else for _,item in ipairs(items) do addCard(item) end;setStatus(string.format("%d produk live • tap card atau BUY",#items),C.green) end
 searching=false
end
local function buildTrendRail()
 clearTrends()
 for _,keyword in ipairs(STORE_TRENDS[activeStore] or STORE_TRENDS.FASHION) do
  local b=button(trendBar,string.upper(keyword),UDim2.new(),UDim2.fromOffset(math.max(66,#keyword*7+22),27),C.card2);b.ZIndex=4;stroke(b,C.line,1,.48)
  b.Activated:Connect(function()search.Text=keyword;task.defer(runSearch)end)
 end
end
searchBtn.Activated:Connect(runSearch)
search.FocusLost:Connect(function(enter)if enter then runSearch() end end)
close.Activated:Connect(hidePanel)
dim.Activated:Connect(hidePanel)

remote.OnClientEvent:Connect(function(kind,data)
 if kind~="open" or typeof(data)~="table" then return end
 activeStore=tostring(data.key or "FASHION");title.Text=tostring(data.title or "BBYA MALL");subtitle.Text=tostring(data.subtitle or "ROBLOX MARKETPLACE")
 buildTrendRail();local trends=STORE_TRENDS[activeStore] or STORE_TRENDS.FASHION;search.Text=trends[1] or ""
 setMallHudHidden(true);opened=true;panel.Visible=true;dim.Visible=true;task.defer(runSearch)
end)
MarketplaceService.PromptPurchaseFinished:Connect(function(who,assetId,isPurchased)
 if who~=player then return end
 if isPurchased then setStatus("PURCHASE SUCCESS • Roblox confirmed.",C.green)else setStatus("Checkout ditutup / belum dibeli.",C.muted)end
end)
player.CharacterAdded:Connect(hidePanel)

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local touch=UserInputService.TouchEnabled
 local landscape=vp.X>vp.Y
 local w,h
 if touch then
  w=math.clamp(math.floor(vp.X*(landscape and .52 or .88)),330,520)
  h=math.clamp(math.floor(vp.Y*(landscape and .60 or .56)),300,360)
 else
  w=math.clamp(math.floor(vp.X*.48),420,560);h=math.clamp(math.floor(vp.Y*.58),320,420)
 end
 panel.Size=UDim2.fromOffset(w,h)
 panel.Position=UDim2.fromScale(.5,landscape and .60 or .54)
 grid.CellSize=UDim2.new(.5,-4,0,142)
end
task.defer(responsive)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)
print("[BBYA] Mall Native Robux Commerce client v5 online: compact touch-first cards + shoe fallback + native checkout")
