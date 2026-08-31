-- BBYA SOCIAL HUB — MALL NATIVE ROBUX COMMERCE CLIENT v6
-- Compact landscape-first storefront with one-row horizontal product carousel.
-- Mall HUD hides while shopping. Roblox Marketplace checkout only.

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

local C={bg=Color3.fromRGB(9,10,12),card=Color3.fromRGB(27,28,33),card2=Color3.fromRGB(35,36,42),white=Color3.fromRGB(244,242,238),muted=Color3.fromRGB(164,164,170),line=Color3.fromRGB(57,58,65),gold=Color3.fromRGB(220,184,119),green=Color3.fromRGB(75,205,132),pink=Color3.fromRGB(235,56,147),cyan=Color3.fromRGB(38,192,214)}
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function text(parent,value,pos,size,font,ts,col,align)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=col or C.white;l.TextWrapped=true;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.Parent=parent;return l
end
local function button(parent,value,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=value;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card2;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.BorderSizePixel=0;b.AutoButtonColor=true;b.Active=true;b.Selectable=true;b.Parent=parent;round(b,7);return b
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
local dim=button(gui,"",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Color3.new(0,0,0));dim.BackgroundTransparency=.76;dim.AutoButtonColor=false;dim.Visible=false;dim.ZIndex=1
local panel=Instance.new("Frame")
panel.Name="Panel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.58);panel.Size=UDim2.fromOffset(520,270);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=2;panel.Parent=gui;round(panel,13);stroke(panel,C.gold,.38)
local title=text(panel,"BBYA MALL",UDim2.fromOffset(12,8),UDim2.new(1,-50,0,18),Enum.Font.GothamBold,13,C.white);title.ZIndex=3
local subtitle=text(panel,"ROBLOX MARKETPLACE",UDim2.fromOffset(12,26),UDim2.new(1,-50,0,14),Enum.Font.GothamBold,8,C.gold);subtitle.ZIndex=3
local close=button(panel,"×",UDim2.new(1,-38,0,7),UDim2.fromOffset(28,28),C.card2);close.TextSize=17;close.ZIndex=5

local search=Instance.new("TextBox")
search.PlaceholderText="Search catalog…";search.Text="";search.ClearTextOnFocus=false;search.Position=UDim2.fromOffset(12,46);search.Size=UDim2.new(1,-82,0,30);search.BackgroundColor3=C.card;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.Gotham;search.TextSize=10;search.BorderSizePixel=0;search.ZIndex=3;search.Parent=panel;round(search,7);stroke(search,C.line,.52)
local searchBtn=button(panel,"SEARCH",UDim2.new(1,-64,0,46),UDim2.fromOffset(52,30),C.card2);searchBtn.ZIndex=5;stroke(searchBtn,C.cyan,.4)
local trendBar=Instance.new("ScrollingFrame")
trendBar.Position=UDim2.fromOffset(12,82);trendBar.Size=UDim2.new(1,-24,0,26);trendBar.BackgroundTransparency=1;trendBar.BorderSizePixel=0;trendBar.ScrollBarThickness=0;trendBar.ScrollingDirection=Enum.ScrollingDirection.X;trendBar.CanvasSize=UDim2.new();trendBar.AutomaticCanvasSize=Enum.AutomaticSize.X;trendBar.ZIndex=3;trendBar.Parent=panel
local trendLayout=Instance.new("UIListLayout");trendLayout.FillDirection=Enum.FillDirection.Horizontal;trendLayout.Padding=UDim.new(0,5);trendLayout.Parent=trendBar
local status=text(panel,"Open a Mall shop to browse.",UDim2.fromOffset(12,109),UDim2.new(1,-24,0,15),Enum.Font.GothamMedium,8,C.cyan);status.ZIndex=3

local holder=Instance.new("ScrollingFrame")
holder.Name="ProductCarousel";holder.Position=UDim2.fromOffset(12,128);holder.Size=UDim2.new(1,-24,0,130);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.ScrollBarImageColor3=C.gold;holder.CanvasSize=UDim2.new();holder.AutomaticCanvasSize=Enum.AutomaticSize.X;holder.ScrollingDirection=Enum.ScrollingDirection.X;holder.Active=true;holder.ZIndex=3;holder.Parent=panel
local list=Instance.new("UIListLayout");list.FillDirection=Enum.FillDirection.Horizontal;list.Padding=UDim.new(0,7);list.SortOrder=Enum.SortOrder.LayoutOrder;list.Parent=holder

local activeStore="FASHION"
local searching=false
local opened=false
local hiddenMallHud=nil
local hiddenMallHudWasEnabled=false
local function setStatus(v,c)status.Text=tostring(v or "");status.TextColor3=c or C.cyan end
local function clearCards()for _,ch in ipairs(holder:GetChildren()) do if ch~=list then ch:Destroy() end end;holder.CanvasPosition=Vector2.new(0,0) end
local function clearTrends()for _,ch in ipairs(trendBar:GetChildren()) do if ch~=trendLayout then ch:Destroy() end end end
local function setMallHudHidden(hide)
 local live=pg:FindFirstChild("BBYAMallLiveUI")
 if hide then if live and live:IsA("ScreenGui") then hiddenMallHud=live;hiddenMallHudWasEnabled=live.Enabled;live.Enabled=false end
 else if hiddenMallHud and hiddenMallHud.Parent then hiddenMallHud.Enabled=hiddenMallHudWasEnabled end;hiddenMallHud=nil end
end
local function hidePanel()opened=false;searching=false;panel.Visible=false;dim.Visible=false;setMallHudHidden(false)end

local function searchCatalog(params)
 local ok,pages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if ok and pages then return pages end
 task.wait(.25)
 local ok2,pages2=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if ok2 and pages2 then return pages2 end
 return nil
end
local function pageItems(pages)
 if not pages then return nil end
 local ok,items=pcall(function()return pages:GetCurrentPage()end)
 if ok and type(items)=="table" then return items end
 return nil
end
local function makeParams(useTypes,keyword)
 local p=CatalogSearchParams.new();p.IncludeOffSale=false;p.Limit=10
 if useTypes then p.AssetTypes=STORE_TYPES[activeStore] or STORE_TYPES.FASHION end
 if keyword and keyword~="" then p.SearchKeyword=keyword end
 return p
end
local function priceText(item)local p=tonumber(item.Price or item.LowestPrice);return p and ("R$ "..math.floor(p)) or tostring(item.PriceStatus or "ROBLOX")end
local function promptPurchase(id)
 setStatus("Opening Roblox checkout…",C.gold)
 local ok,err=pcall(function()MarketplaceService:PromptPurchase(player,id,true,Enum.CurrencyType.Default)end)
 if not ok then warn("[BBYA Mall] PromptPurchase failed",err);setStatus("Checkout gagal dibuka.",C.pink)end
end
local function addCard(item,index)
 local id=tonumber(item.Id or item.AssetId);if not id then return end
 local card=button(holder,"",UDim2.new(),UDim2.fromOffset(154,118),C.card);card.Name="Product_"..id;card.LayoutOrder=index;card.ZIndex=4;stroke(card,C.line,.55)
 local img=Instance.new("ImageLabel");img.BackgroundColor3=C.card2;img.BorderSizePixel=0;img.Position=UDim2.fromOffset(5,5);img.Size=UDim2.fromOffset(144,61);img.Image=string.format("rbxthumb://type=Asset&id=%d&w=150&h=150",id);img.ScaleType=Enum.ScaleType.Crop;img.ZIndex=5;img.Parent=card;round(img,6)
 local nm=text(card,tostring(item.Name or ("Asset "..id)),UDim2.fromOffset(6,69),UDim2.fromOffset(142,20),Enum.Font.GothamMedium,7,C.white,Enum.TextXAlignment.Center);nm.ZIndex=5
 local price=text(card,priceText(item),UDim2.fromOffset(7,93),UDim2.fromOffset(55,18),Enum.Font.GothamBold,8,C.gold,Enum.TextXAlignment.Center);price.ZIndex=5
 local buy=button(card,"BUY",UDim2.fromOffset(65,91),UDim2.fromOffset(82,22),Color3.fromRGB(47,70,55));buy.ZIndex=7;stroke(buy,C.green,.28)
 local busy=false
 local function activate()if busy then return end;busy=true;promptPurchase(id);task.delay(1,function()busy=false end)end
 card.Activated:Connect(activate);buy.Activated:Connect(activate)
end
local function runSearch()
 if searching or not opened then return end
 searching=true;clearCards();setStatus("Loading Roblox Marketplace…",C.gold)
 local q=search.Text:match("^%s*(.-)%s*$") or ""
 local items=pageItems(searchCatalog(makeParams(true,q)))
 if (not items or #items==0) and activeStore=="SHOES" then items=pageItems(searchCatalog(makeParams(false,(q~="" and q) or "shoes"))) end
 if not items then setStatus("Marketplace belum merespons. Tap SEARCH.",C.pink)
 elseif #items==0 then setStatus("Tidak ada produk untuk filter ini.",C.muted)
 else for i,item in ipairs(items) do addCard(item,i) end;setStatus(string.format("%d produk live • swipe kiri/kanan • tap BUY",#items),C.green) end
 searching=false
end
local function buildTrends()
 clearTrends()
 for _,kw in ipairs(STORE_TRENDS[activeStore] or STORE_TRENDS.FASHION) do local b=button(trendBar,string.upper(kw),UDim2.new(),UDim2.fromOffset(math.max(64,#kw*7+20),25),C.card2);b.ZIndex=5;stroke(b,C.line,.48);b.Activated:Connect(function()search.Text=kw;task.defer(runSearch)end) end
end
searchBtn.Activated:Connect(runSearch)
search.FocusLost:Connect(function(enter)if enter then runSearch()end end)
close.Activated:Connect(hidePanel);dim.Activated:Connect(hidePanel)
remote.OnClientEvent:Connect(function(kind,data)
 if kind~="open" or typeof(data)~="table" then return end
 activeStore=tostring(data.key or "FASHION");title.Text=tostring(data.title or "BBYA MALL");subtitle.Text=tostring(data.subtitle or "ROBLOX MARKETPLACE")
 buildTrends();local t=STORE_TRENDS[activeStore] or STORE_TRENDS.FASHION;search.Text=t[1] or ""
 setMallHudHidden(true);opened=true;panel.Visible=true;dim.Visible=true;task.defer(runSearch)
end)
MarketplaceService.PromptPurchaseFinished:Connect(function(who,assetId,isPurchased)if who~=player then return end;if isPurchased then setStatus("PURCHASE SUCCESS • Roblox confirmed.",C.green)else setStatus("Checkout ditutup / belum dibeli.",C.muted)end end)
player.CharacterAdded:Connect(hidePanel)

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera;local vp=camera and camera.ViewportSize or Vector2.new(1280,720);local landscape=vp.X>vp.Y
 local w=math.clamp(math.floor(vp.X*(landscape and .48 or .88)),330,520);local h=landscape and 270 or math.clamp(math.floor(vp.Y*.46),260,320)
 panel.Size=UDim2.fromOffset(w,h);panel.Position=UDim2.fromScale(.5,landscape and .60 or .54)
 holder.Size=UDim2.new(1,-24,0,math.max(118,h-140))
end
task.defer(responsive)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)
print("[BBYA] Mall Commerce client v6 online: compact horizontal carousel + touch checkout")
