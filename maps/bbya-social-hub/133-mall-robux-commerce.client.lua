-- BBYA SOCIAL HUB — MALL NATIVE ROBUX COMMERCE CLIENT v4
-- Roblox-native Marketplace reliability: direct SearchCatalogAsync, one bounded retry,
-- legacy compatibility fallback, compact mobile storefront, and Roblox checkout only.
-- No fabricated Marketplace products are ever shown.

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
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.BorderSizePixel=0;b.AutoButtonColor=true;b.Parent=parent;round(b,8);return b
end

local STORE_TYPES={
 FASHION={Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.TShirt,Enum.AvatarAssetType.Pants,Enum.AvatarAssetType.TShirtAccessory,Enum.AvatarAssetType.ShirtAccessory,Enum.AvatarAssetType.JacketAccessory,Enum.AvatarAssetType.SweaterAccessory,Enum.AvatarAssetType.PantsAccessory,Enum.AvatarAssetType.ShortsAccessory,Enum.AvatarAssetType.DressSkirtAccessory},
 SHOES={Enum.AvatarAssetType.LeftShoeAccessory,Enum.AvatarAssetType.RightShoeAccessory},
 BEAUTY={Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.FaceMakeup,Enum.AvatarAssetType.LipMakeup,Enum.AvatarAssetType.EyeMakeup},
 STREET={Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.NeckAccessory,Enum.AvatarAssetType.ShoulderAccessory,Enum.AvatarAssetType.FrontAccessory,Enum.AvatarAssetType.BackAccessory,Enum.AvatarAssetType.WaistAccessory},
}
local STORE_TRENDS={FASHION={"Y2K","streetwear","grunge"},SHOES={"sneakers","platform","boots"},BEAUTY={"hair","makeup","baddie"},STREET={"streetwear","goth","cyber"}}

local gui=Instance.new("ScreenGui")
gui.Name="BBYAMallRobuxCommerceUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=58;gui.Parent=pg
local dim=Instance.new("Frame")
dim.Size=UDim2.fromScale(1,1);dim.BackgroundColor3=Color3.new(0,0,0);dim.BackgroundTransparency=.58;dim.BorderSizePixel=0;dim.Visible=false;dim.Parent=gui
local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.fromOffset(560,430);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;round(panel,15);stroke(panel,C.gold,1,.42)

local title=label(panel,"BBYA MALL",UDim2.fromOffset(16,12),UDim2.new(1,-62,0,22),Enum.Font.GothamBold,16,C.white)
local subtitle=label(panel,"ROBLOX MARKETPLACE",UDim2.fromOffset(16,35),UDim2.new(1,-62,0,16),Enum.Font.GothamBold,8,C.gold)
local close=button(panel,"×",UDim2.new(1,-44,0,10),UDim2.fromOffset(30,30),C.card2);close.TextSize=18
local search=Instance.new("TextBox")
search.PlaceholderText="Search Roblox catalog…";search.Text="";search.ClearTextOnFocus=false;search.Position=UDim2.fromOffset(14,62);search.Size=UDim2.new(1,-94,0,34);search.BackgroundColor3=C.card;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.Gotham;search.TextSize=11;search.BorderSizePixel=0;search.Parent=panel;round(search,8);stroke(search,C.line,1,.54)
local searchBtn=button(panel,"SEARCH",UDim2.new(1,-74,0,62),UDim2.fromOffset(60,34),C.card2);stroke(searchBtn,C.cyan,1,.45)

local trendBar=Instance.new("ScrollingFrame")
trendBar.Position=UDim2.fromOffset(14,102);trendBar.Size=UDim2.new(1,-28,0,30);trendBar.BackgroundTransparency=1;trendBar.BorderSizePixel=0;trendBar.ScrollBarThickness=0;trendBar.ScrollingDirection=Enum.ScrollingDirection.X;trendBar.CanvasSize=UDim2.new();trendBar.AutomaticCanvasSize=Enum.AutomaticSize.X;trendBar.Parent=panel
local trendLayout=Instance.new("UIListLayout");trendLayout.FillDirection=Enum.FillDirection.Horizontal;trendLayout.Padding=UDim.new(0,5);trendLayout.Parent=trendBar
local status=label(panel,"Open a Mall shop to browse.",UDim2.fromOffset(14,138),UDim2.new(1,-28,0,18),Enum.Font.GothamMedium,9,C.cyan)

local holder=Instance.new("ScrollingFrame")
holder.Position=UDim2.fromOffset(14,162);holder.Size=UDim2.new(1,-28,1,-204);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.ScrollBarImageColor3=C.gold;holder.CanvasSize=UDim2.new();holder.AutomaticCanvasSize=Enum.AutomaticSize.Y;holder.ScrollingDirection=Enum.ScrollingDirection.Y;holder.Active=true;holder.Parent=panel
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(7,7);grid.CellSize=UDim2.new(.32,-5,0,132);grid.Parent=holder
local footer=label(panel,"BUY opens Roblox checkout.",UDim2.new(0,14,1,-32),UDim2.new(1,-28,0,18),Enum.Font.Gotham,8,C.muted);footer.TextXAlignment=Enum.TextXAlignment.Center

local activeStore="FASHION"
local searching=false
local opened=false
local lastCatalogError=""
local function setStatus(text,col)status.Text=tostring(text or "");status.TextColor3=col or C.cyan end
local function clearCards()for _,ch in ipairs(holder:GetChildren()) do if ch~=grid then ch:Destroy() end end end
local function clearTrends()for _,ch in ipairs(trendBar:GetChildren()) do if ch~=trendLayout then ch:Destroy() end end end

local function searchCatalog(params)
 lastCatalogError=""
 local ok,pages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if ok and pages then return pages end
 local firstErr=tostring(pages or "unknown")
 task.wait(.35)
 local retryOk,retryPages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if retryOk and retryPages then return retryPages end
 local retryErr=tostring(retryPages or "unknown")
 local legacyOk,legacyPages=pcall(function()return AvatarEditorService:SearchCatalog(params)end)
 if legacyOk and legacyPages then return legacyPages end
 lastCatalogError=string.format("async=%s | retry=%s | legacy=%s",firstErr,retryErr,tostring(legacyPages or "unknown"))
 warn("[BBYA Mall Commerce] Roblox catalog unavailable:",lastCatalogError)
 return nil
end

local function priceText(item)
 local p=tonumber(item.Price or item.LowestPrice);if p then return "R$ "..math.floor(p) end
 return tostring(item.PriceStatus or "ROBLOX")
end
local function addCard(item)
 local id=tonumber(item.Id or item.AssetId);if not id then return end
 local name=tostring(item.Name or ("Asset "..id))
 local card=Instance.new("Frame");card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.Parent=holder;round(card,9);stroke(card,C.line,1,.56)
 local img=Instance.new("ImageLabel");img.BackgroundColor3=C.card2;img.BorderSizePixel=0;img.Position=UDim2.fromOffset(6,6);img.Size=UDim2.new(1,-12,0,74);img.Image=string.format("rbxthumb://type=Asset&id=%d&w=150&h=150",id);img.ScaleType=Enum.ScaleType.Crop;img.Parent=card;round(img,7)
 local nm=label(card,name,UDim2.fromOffset(6,84),UDim2.new(1,-12,0,25),Enum.Font.GothamMedium,8,C.white);nm.TextXAlignment=Enum.TextXAlignment.Center
 local price=label(card,priceText(item),UDim2.fromOffset(6,110),UDim2.new(.45,-8,0,16),Enum.Font.GothamBold,8,C.gold);price.TextXAlignment=Enum.TextXAlignment.Center
 local buy=button(card,"BUY",UDim2.new(.47,0,1,-25),UDim2.new(.53,-6,0,20),Color3.fromRGB(47,70,55));stroke(buy,C.green,1,.3)
 buy.MouseButton1Click:Connect(function()
  setStatus("Opening Roblox checkout…",C.gold)
  local ok,err=pcall(function()MarketplaceService:PromptPurchase(player,id,true,Enum.CurrencyType.Default)end)
  if not ok then warn("[BBYA Mall Commerce] PromptPurchase failed:",err);setStatus("Checkout tidak tersedia untuk item ini.",C.pink)end
 end)
end

local function runSearch()
 if searching or not opened then return end
 searching=true;clearCards()
 setStatus("Loading live Roblox Marketplace…",C.gold)
 local params=CatalogSearchParams.new();params.AssetTypes=STORE_TYPES[activeStore] or STORE_TYPES.FASHION;params.IncludeOffSale=false;params.Limit=10
 local q=search.Text:match("^%s*(.-)%s*$") or "";if q~="" then params.SearchKeyword=q end
 local pages=searchCatalog(params)
 if not pages then setStatus("Roblox Marketplace belum merespons. Tekan SEARCH untuk retry.",C.pink);searching=false;return end
 local ok,items=pcall(function()return pages:GetCurrentPage()end)
 if not ok or type(items)~="table" then
  lastCatalogError=tostring(items or "GetCurrentPage failed")
  warn("[BBYA Mall Commerce] Catalog page unavailable:",lastCatalogError)
  setStatus("Marketplace page belum tersedia. Tekan SEARCH untuk retry.",C.pink);searching=false;return
 end
 if #items==0 then setStatus("Tidak ada produk untuk filter ini.",C.muted) else for _,item in ipairs(items) do addCard(item) end;setStatus(string.format("%d produk live • Roblox checkout",#items),C.green) end
 searching=false
end

local function buildTrendRail()
 clearTrends()
 for _,keyword in ipairs(STORE_TRENDS[activeStore] or STORE_TRENDS.FASHION) do
  local b=button(trendBar,string.upper(keyword),UDim2.new(),UDim2.fromOffset(math.max(68,#keyword*7+24),27),C.card2);stroke(b,C.line,1,.48)
  b.MouseButton1Click:Connect(function()search.Text=keyword;task.defer(runSearch)end)
 end
end
searchBtn.MouseButton1Click:Connect(runSearch)
search.FocusLost:Connect(function(enter)if enter then runSearch() end end)
close.MouseButton1Click:Connect(function()opened=false;panel.Visible=false;dim.Visible=false;searching=false end)

remote.OnClientEvent:Connect(function(kind,data)
 if kind~="open" or typeof(data)~="table" then return end
 activeStore=tostring(data.key or "FASHION");title.Text=tostring(data.title or "BBYA MALL");subtitle.Text=tostring(data.subtitle or "ROBLOX MARKETPLACE")
 buildTrendRail();local trends=STORE_TRENDS[activeStore] or STORE_TRENDS.FASHION;search.Text=trends[1] or ""
 opened=true;panel.Visible=true;dim.Visible=true;task.defer(runSearch)
end)
MarketplaceService.PromptPurchaseFinished:Connect(function(who,assetId,isPurchased)if who~=player then return end;if isPurchased then setStatus("PURCHASE SUCCESS • Roblox confirmed.",C.green)else setStatus("Purchase tidak selesai.",C.muted)end end)
player.CharacterAdded:Connect(function()opened=false;panel.Visible=false;dim.Visible=false;searching=false end)

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720);local phone=UserInputService.TouchEnabled or vp.Y<800
 panel.Size=UDim2.fromOffset(math.clamp(math.floor(vp.X*(phone and .88 or .64)),310,560),math.clamp(math.floor(vp.Y*(phone and .68 or .62)),350,430))
end
task.defer(responsive)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)
print("[BBYA] Mall Native Robux Commerce client v4 online: direct Roblox catalog search + bounded retry + native checkout")
