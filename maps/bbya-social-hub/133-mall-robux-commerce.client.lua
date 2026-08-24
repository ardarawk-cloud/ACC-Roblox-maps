-- BBYA SOCIAL HUB — MALL NATIVE ROBUX COMMERCE CLIENT v1
-- Browse live Roblox catalog inventory from selected BBYA Mall tenants and buy with real Robux.
-- Purchase prompt is Roblox-native MarketplaceService:PromptPurchase.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AvatarEditorService=game:GetService("AvatarEditorService")
local MarketplaceService=game:GetService("MarketplaceService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local remote=remotes:WaitForChild("MallRobuxCommerce")

local old=pg:FindFirstChild("BBYAMallRobuxCommerceUI")
if old then old:Destroy() end

local C={
 bg=Color3.fromRGB(9,10,12),panel=Color3.fromRGB(18,19,23),card=Color3.fromRGB(27,28,33),card2=Color3.fromRGB(35,36,42),
 white=Color3.fromRGB(244,242,238),muted=Color3.fromRGB(164,164,170),line=Color3.fromRGB(57,58,65),
 gold=Color3.fromRGB(220,184,119),green=Color3.fromRGB(75,205,132),pink=Color3.fromRGB(235,56,147),cyan=Color3.fromRGB(38,192,214),
}

local STORE_TYPES={
 FASHION={
  Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.TShirt,Enum.AvatarAssetType.Pants,
  Enum.AvatarAssetType.TShirtAccessory,Enum.AvatarAssetType.ShirtAccessory,Enum.AvatarAssetType.JacketAccessory,
  Enum.AvatarAssetType.SweaterAccessory,Enum.AvatarAssetType.PantsAccessory,Enum.AvatarAssetType.ShortsAccessory,Enum.AvatarAssetType.DressSkirtAccessory,
 },
 SHOES={Enum.AvatarAssetType.LeftShoeAccessory,Enum.AvatarAssetType.RightShoeAccessory},
 BEAUTY={
  Enum.AvatarAssetType.HairAccessory,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.EyebrowAccessory,
  Enum.AvatarAssetType.EyelashAccessory,Enum.AvatarAssetType.FaceMakeup,Enum.AvatarAssetType.LipMakeup,Enum.AvatarAssetType.EyeMakeup,
 },
 STREET={
  Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.NeckAccessory,Enum.AvatarAssetType.ShoulderAccessory,
  Enum.AvatarAssetType.FrontAccessory,Enum.AvatarAssetType.BackAccessory,Enum.AvatarAssetType.WaistAccessory,
 },
}

local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,t,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=t or 1;s.Transparency=tr or .45;s.Parent=o;return s end
local function label(parent,text,pos,size,font,ts,col)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 12;l.TextColor3=col or C.white;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=12;b.BorderSizePixel=0;b.AutoButtonColor=true;b.Parent=parent;round(b,9);return b
end

local gui=Instance.new("ScreenGui")
gui.Name="BBYAMallRobuxCommerceUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=58;gui.Parent=pg

local dim=Instance.new("Frame")
dim.Size=UDim2.fromScale(1,1);dim.BackgroundColor3=Color3.new(0,0,0);dim.BackgroundTransparency=.45;dim.BorderSizePixel=0;dim.Visible=false;dim.Parent=gui

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.new(.94,0,0,520);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;round(panel,16);stroke(panel,C.gold,1.1,.35)
local limit=Instance.new("UISizeConstraint");limit.MinSize=Vector2.new(310,410);limit.MaxSize=Vector2.new(720,540);limit.Parent=panel

local title=label(panel,"BBYA MALL",UDim2.fromOffset(18,14),UDim2.new(1,-70,0,25),Enum.Font.GothamBold,19,C.white)
local subtitle=label(panel,"NATIVE ROBLOX CHECKOUT",UDim2.fromOffset(18,42),UDim2.new(1,-70,0,18),Enum.Font.GothamBold,10,C.gold)
local close=button(panel,"×",UDim2.new(1,-48,0,12),UDim2.fromOffset(34,34),C.card2);close.TextSize=20

local search=Instance.new("TextBox")
search.PlaceholderText="Search Roblox catalog…";search.Text="";search.ClearTextOnFocus=false;search.Position=UDim2.fromOffset(16,74);search.Size=UDim2.new(1,-112,0,38);search.BackgroundColor3=C.card;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.Gotham;search.TextSize=12;search.BorderSizePixel=0;search.Parent=panel;round(search,9);stroke(search,C.line,1,.52)
local searchBtn=button(panel,"SEARCH",UDim2.new(1,-90,0,74),UDim2.fromOffset(74,38),C.card2);stroke(searchBtn,C.cyan,1,.42)

local status=label(panel,"Open a Mall shop to browse.",UDim2.fromOffset(16,119),UDim2.new(1,-32,0,24),Enum.Font.GothamMedium,10,C.cyan)

local holder=Instance.new("ScrollingFrame")
holder.Position=UDim2.fromOffset(16,147);holder.Size=UDim2.new(1,-32,1,-190);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.ScrollBarImageColor3=C.gold;holder.CanvasSize=UDim2.new();holder.AutomaticCanvasSize=Enum.AutomaticSize.Y;holder.ScrollingDirection=Enum.ScrollingDirection.Y;holder.Active=true;holder.Parent=panel
local grid=Instance.new("UIGridLayout")
grid.CellPadding=UDim2.fromOffset(8,8);grid.CellSize=UDim2.new(.32,-6,0,174);grid.Parent=holder

local footer=label(panel,"Checkout & ownership are handled by Roblox. Prices shown by Roblox at purchase are authoritative.",UDim2.new(0,16,1,-35),UDim2.new(1,-32,0,24),Enum.Font.Gotham,9,C.muted);footer.TextXAlignment=Enum.TextXAlignment.Center

local activeStore="FASHION"
local searching=false
local opened=false

local function setStatus(text,col)status.Text=tostring(text or "");status.TextColor3=col or C.cyan end
local function clearCards()for _,ch in ipairs(holder:GetChildren()) do if ch~=grid then ch:Destroy() end end end

local function priceText(item)
 local p=tonumber(item.Price or item.LowestPrice)
 if p then return "R$ "..tostring(math.floor(p)) end
 local ps=tostring(item.PriceStatus or "")
 if ps=="Free" then return "FREE" end
 return "ROBLOX PRICE"
end

local function addCard(item)
 local id=tonumber(item.Id or item.AssetId)
 if not id then return end
 local name=tostring(item.Name or ("Asset "..id))

 local card=Instance.new("Frame")
 card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.Parent=holder;round(card,10);stroke(card,C.line,1,.55)
 local img=Instance.new("ImageLabel")
 img.BackgroundColor3=C.card2;img.BorderSizePixel=0;img.Position=UDim2.fromOffset(7,7);img.Size=UDim2.new(1,-14,0,88);img.Image=string.format("rbxthumb://type=Asset&id=%d&w=150&h=150",id);img.ScaleType=Enum.ScaleType.Crop;img.Parent=card;round(img,8)
 local nm=label(card,name,UDim2.fromOffset(7,100),UDim2.new(1,-14,0,29),Enum.Font.GothamMedium,9,C.white);nm.TextXAlignment=Enum.TextXAlignment.Center;nm.TextYAlignment=Enum.TextYAlignment.Top
 local price=label(card,priceText(item),UDim2.new(0,7,1,-41),UDim2.new(.42,-6,0,29),Enum.Font.GothamBold,10,C.gold);price.TextXAlignment=Enum.TextXAlignment.Center
 local buy=button(card,"BUY",UDim2.new(.43,0,1,-42),UDim2.new(.57,-7,0,30),Color3.fromRGB(47,70,55));stroke(buy,C.green,1,.28)
 buy.MouseButton1Click:Connect(function()
  setStatus("Opening Roblox purchase for "..name.."…",C.gold)
  local ok,err=pcall(function()
   MarketplaceService:PromptPurchase(player,id,true,Enum.CurrencyType.Default)
  end)
  if not ok then
   warn("[BBYA Mall Commerce] PromptPurchase failed",err)
   setStatus("Roblox checkout tidak tersedia untuk item ini.",C.pink)
  end
 end)
end

local function runSearch()
 if searching or not opened then return end
 searching=true;clearCards();setStatus("Loading live Roblox catalog…",C.gold)
 local params=CatalogSearchParams.new()
 params.AssetTypes=STORE_TYPES[activeStore] or STORE_TYPES.FASHION
 params.IncludeOffSale=false
 params.Limit=18
 local q=search.Text:match("^%s*(.-)%s*$") or ""
 if q~="" then params.SearchKeyword=q end
 local ok,pages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if not ok or not pages then
  searching=false;setStatus("Catalog Roblox gagal dimuat. Tekan SEARCH lagi.",C.pink);return
 end
 local items=pages:GetCurrentPage()
 if #items==0 then
  setStatus("Tidak ada produk dijual untuk pencarian ini.",C.muted)
 else
  for _,item in ipairs(items) do addCard(item) end
  setStatus(string.format("%d produk live • BUY = Robux asli via Roblox",#items),C.green)
 end
 searching=false
end

searchBtn.MouseButton1Click:Connect(runSearch)
search.FocusLost:Connect(function(enter)if enter then runSearch() end end)
close.MouseButton1Click:Connect(function()opened=false;panel.Visible=false;dim.Visible=false;searching=false end)

remote.OnClientEvent:Connect(function(kind,data)
 if kind~="open" or typeof(data)~="table" then return end
 activeStore=tostring(data.key or "FASHION")
 title.Text=tostring(data.title or "BBYA MALL")
 subtitle.Text=tostring(data.subtitle or "NATIVE ROBLOX CHECKOUT").."  •  R$"
 search.Text=""
 opened=true;panel.Visible=true;dim.Visible=true
 task.defer(runSearch)
end)

MarketplaceService.PromptPurchaseFinished:Connect(function(who,assetId,isPurchased)
 if who~=player then return end
 if isPurchased then
  setStatus("PURCHASE SUCCESS • item masuk ke akun Roblox kamu.",C.green)
 else
  setStatus("Purchase dibatalkan / tidak selesai.",C.muted)
 end
end)

player.CharacterAdded:Connect(function()opened=false;panel.Visible=false;dim.Visible=false;searching=false end)
print("[BBYA] Mall Native Robux Commerce client v1 online")
