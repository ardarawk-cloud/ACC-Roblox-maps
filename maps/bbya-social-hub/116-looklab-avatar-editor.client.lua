-- BBYA SOCIAL HUB — LOOK LAB AVATAR EDITOR CLIENT v2
-- Mobile-focused catalog recovery: valid catalog page size, inventory-access flow,
-- async search with legacy fallback, and a smaller centered editor.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AvatarEditorService=game:GetService("AvatarEditorService")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local remote=remotes:WaitForChild("LookLabAvatar")

local old=pg:FindFirstChild("BBYALookLabAvatarUI")
if old then old:Destroy() end

local C={
 bg=Color3.fromRGB(10,10,13),card=Color3.fromRGB(27,25,31),card2=Color3.fromRGB(35,31,39),
 pink=Color3.fromRGB(244,48,149),cyan=Color3.fromRGB(31,184,207),gold=Color3.fromRGB(211,165,97),
 white=Color3.fromRGB(242,239,243),muted=Color3.fromRGB(158,153,166),line=Color3.fromRGB(55,50,61),green=Color3.fromRGB(72,205,133)
}
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,t,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=t or 1;s.Transparency=tr or .4;s.Parent=o;return s end
local function label(parent,text,pos,size,font,ts,col)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 12;l.TextColor3=col or C.white;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card;b.TextColor3=C.white;b.Font=Enum.Font.GothamSemibold;b.TextSize=11;b.BorderSizePixel=0;b.AutoButtonColor=true;b.Parent=parent;round(b,9);return b
end

local gui=Instance.new("ScreenGui")
gui.Name="BBYALookLabAvatarUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=55;gui.Parent=pg
local dim=Instance.new("Frame")
dim.Size=UDim2.fromScale(1,1);dim.BackgroundColor3=Color3.new(0,0,0);dim.BackgroundTransparency=.58;dim.BorderSizePixel=0;dim.Visible=false;dim.Parent=gui

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.fromOffset(560,430);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;round(panel,15);stroke(panel,C.pink,1,.48)

label(panel,"BBYA LOOK LAB",UDim2.fromOffset(16,12),UDim2.new(1,-64,0,22),Enum.Font.GothamBold,16,C.white)
label(panel,"TRY ON • Roblox avatar catalog",UDim2.fromOffset(16,35),UDim2.new(1,-64,0,16),Enum.Font.Gotham,9,C.muted)
local close=button(panel,"×",UDim2.new(1,-44,0,10),UDim2.fromOffset(30,30),C.card2);close.TextSize=18

local tabsFrame=Instance.new("Frame");tabsFrame.BackgroundTransparency=1;tabsFrame.Position=UDim2.fromOffset(14,58);tabsFrame.Size=UDim2.new(1,-28,0,34);tabsFrame.Parent=panel
local tabLayout=Instance.new("UIListLayout");tabLayout.FillDirection=Enum.FillDirection.Horizontal;tabLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;tabLayout.Padding=UDim.new(0,5);tabLayout.Parent=tabsFrame

local searchBox=Instance.new("TextBox")
searchBox.PlaceholderText="Search catalog…";searchBox.Text="";searchBox.ClearTextOnFocus=false;searchBox.Position=UDim2.fromOffset(14,99);searchBox.Size=UDim2.new(1,-96,0,34);searchBox.BackgroundColor3=C.card;searchBox.TextColor3=C.white;searchBox.PlaceholderColor3=C.muted;searchBox.Font=Enum.Font.Gotham;searchBox.TextSize=11;searchBox.BorderSizePixel=0;searchBox.Parent=panel;round(searchBox,8);stroke(searchBox,C.line,1,.58)
local searchBtn=button(panel,"SEARCH",UDim2.new(1,-76,0,99),UDim2.fromOffset(62,34),C.card2);stroke(searchBtn,C.cyan,1,.48)
local status=label(panel,"Duduk di styling chair untuk mulai.",UDim2.fromOffset(14,139),UDim2.new(1,-28,0,18),Enum.Font.GothamMedium,9,C.cyan)

local holder=Instance.new("ScrollingFrame")
holder.Position=UDim2.fromOffset(14,162);holder.Size=UDim2.new(1,-28,1,-214);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.ScrollBarImageColor3=C.pink;holder.CanvasSize=UDim2.new();holder.AutomaticCanvasSize=Enum.AutomaticSize.Y;holder.ScrollingDirection=Enum.ScrollingDirection.Y;holder.Active=true;holder.Parent=panel
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(7,7);grid.CellSize=UDim2.new(.32,-5,0,122);grid.Parent=holder

local bottom=Instance.new("Frame");bottom.BackgroundTransparency=1;bottom.Position=UDim2.new(0,14,1,-44);bottom.Size=UDim2.new(1,-28,0,32);bottom.Parent=panel
local resetBtn=button(bottom,"RESET",UDim2.fromOffset(0,0),UDim2.new(.30,-3,1,0),C.card2);stroke(resetBtn,C.gold,1,.48)
local saveBtn=button(bottom,"SAVE AVATAR",UDim2.new(.30,3,0,0),UDim2.new(.42,-3,1,0),Color3.fromRGB(54,35,52));stroke(saveBtn,C.pink,1,.4)
local doneBtn=button(bottom,"DONE",UDim2.new(.72,3,0,0),UDim2.new(.28,-3,1,0),C.card2);stroke(doneBtn,C.cyan,1,.52)

local TAB_TYPES={
 HAIR={Enum.AvatarAssetType.HairAccessory},
 TOP={Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.TShirt,Enum.AvatarAssetType.TShirtAccessory,Enum.AvatarAssetType.ShirtAccessory,Enum.AvatarAssetType.JacketAccessory,Enum.AvatarAssetType.SweaterAccessory},
 BOTTOM={Enum.AvatarAssetType.Pants,Enum.AvatarAssetType.PantsAccessory,Enum.AvatarAssetType.ShortsAccessory,Enum.AvatarAssetType.DressSkirtAccessory},
 ACCESSORY={Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.FaceAccessory,Enum.AvatarAssetType.NeckAccessory,Enum.AvatarAssetType.ShoulderAccessory,Enum.AvatarAssetType.FrontAccessory,Enum.AvatarAssetType.BackAccessory,Enum.AvatarAssetType.WaistAccessory},
}
local tabButtons={}
local activeTab="HAIR"
local searching=false
local visibleSession=false
local lastSeatedAt=0
local accessState="unknown"

local function setStatus(text,col)status.Text=tostring(text or "");status.TextColor3=col or C.cyan end
local function clearCards()for _,ch in ipairs(holder:GetChildren()) do if ch~=grid then ch:Destroy() end end end
local function setActiveTab(name)
 activeTab=name
 for n,b in pairs(tabButtons) do
  b.BackgroundColor3=(n==name) and Color3.fromRGB(58,34,51) or C.card
  local st=b:FindFirstChildOfClass("UIStroke");if st then st.Color=(n==name) and C.pink or C.line end
 end
end
for _,name in ipairs({"HAIR","TOP","BOTTOM","ACCESSORY"}) do
 local width=name=="ACCESSORY" and 92 or 68
 local b=button(tabsFrame,name,UDim2.new(),UDim2.fromOffset(width,31),C.card);stroke(b,C.line,1,.58);tabButtons[name]=b
 b.MouseButton1Click:Connect(function()setActiveTab(name);task.defer(function()searchBtn:Activate()end)end)
end
setActiveTab("HAIR")

local function assetTypeName(v)
 if typeof(v)=="EnumItem" then return v.Name end
 return tostring(v or ""):gsub("Enum%.AvatarAssetType%.","")
end
local function addCard(item)
 local id=tonumber(item.Id or item.AssetId);if not id then return end
 local typeName=assetTypeName(item.AssetType)
 local name=tostring(item.Name or ("Asset "..id))
 local card=Instance.new("TextButton");card.Text="";card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.AutoButtonColor=true;card.Parent=holder;round(card,9);stroke(card,C.line,1,.58)
 local img=Instance.new("ImageLabel");img.BackgroundColor3=C.card2;img.BorderSizePixel=0;img.Position=UDim2.fromOffset(6,6);img.Size=UDim2.new(1,-12,0,70);img.Image=string.format("rbxthumb://type=Asset&id=%d&w=150&h=150",id);img.ScaleType=Enum.ScaleType.Crop;img.Parent=card;round(img,7)
 local nm=label(card,name,UDim2.fromOffset(6,80),UDim2.new(1,-12,0,27),Enum.Font.GothamMedium,8,C.white);nm.TextXAlignment=Enum.TextXAlignment.Center;nm.TextYAlignment=Enum.TextYAlignment.Top
 local tag=label(card,"TRY ON",UDim2.new(0,6,1,-15),UDim2.new(1,-12,0,11),Enum.Font.GothamBold,7,C.pink);tag.TextXAlignment=Enum.TextXAlignment.Center
 card.MouseButton1Click:Connect(function()setStatus("Applying "..name.."…",C.gold);remote:FireServer("tryOn",{assetId=id,assetType=typeName})end)
end

local function ensureCatalogAccess()
 if accessState=="granted" then return true end
 if accessState=="denied" then return false end
 accessState="pending";setStatus("Connecting Roblox avatar catalog…",C.gold)
 local ok,err=pcall(function()AvatarEditorService:PromptAllowInventoryReadAccess()end)
 if not ok then
  warn("[BBYA LookLab] Inventory access prompt failed:",err)
  accessState="unknown"
  return false
 end
 local result=AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Wait()
 if result==Enum.AvatarPromptResult.Success then accessState="granted";return true end
 accessState="denied";setStatus("Izinkan akses avatar Roblox untuk membuka catalog.",C.muted);return false
end

local function searchCatalog(params)
 local ok,pages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if ok and pages then return pages end
 warn("[BBYA LookLab] SearchCatalogAsync failed:",pages)
 local legacyOk,legacyPages=pcall(function()return AvatarEditorService:SearchCatalog(params)end)
 if legacyOk and legacyPages then return legacyPages end
 warn("[BBYA LookLab] SearchCatalog fallback failed:",legacyPages)
 return nil
end

local function runSearch()
 if searching or not visibleSession then return end
 searching=true;clearCards()
 if accessState~="granted" then
  local accessOk=ensureCatalogAccess()
  if not accessOk then searching=false;return end
 end
 setStatus("Loading Roblox Catalog…",C.gold)
 local params=CatalogSearchParams.new();params.AssetTypes=TAB_TYPES[activeTab];params.Limit=10;params.IncludeOffSale=false
 local q=searchBox.Text:match("^%s*(.-)%s*$") or "";if q~="" then params.SearchKeyword=q end
 local pages=searchCatalog(params)
 if not pages then setStatus("Catalog belum tersedia. Tekan SEARCH lagi.",C.pink);searching=false;return end
 local ok,results=pcall(function()return pages:GetCurrentPage()end)
 if not ok or type(results)~="table" then setStatus("Catalog belum tersedia. Tekan SEARCH lagi.",C.pink);searching=false;return end
 if #results==0 then setStatus("Tidak ada item. Coba keyword lain.",C.muted) else
  for _,item in ipairs(results) do addCard(item) end
  setStatus(string.format("%d items • tap untuk TRY ON",#results),C.green)
 end
 searching=false
end
searchBtn.MouseButton1Click:Connect(runSearch)
searchBox.FocusLost:Connect(function(enter)if enter then runSearch() end end)

local function closePanel()visibleSession=false;panel.Visible=false;dim.Visible=false;searching=false end
local function openPanel()visibleSession=true;panel.Visible=true;dim.Visible=true;lastSeatedAt=os.clock();task.defer(runSearch)end
close.MouseButton1Click:Connect(closePanel)
doneBtn.MouseButton1Click:Connect(function()local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if hum then hum.Sit=false end;closePanel()end)
resetBtn.MouseButton1Click:Connect(function()setStatus("Resetting avatar…",C.gold);remote:FireServer("reset")end)
saveBtn.MouseButton1Click:Connect(function()
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if not hum then return end
 local ok,desc=pcall(function()return hum:GetAppliedDescription()end);if not ok or not desc then setStatus("Avatar belum siap disimpan.",C.pink);return end
 setStatus("Opening Roblox SAVE AVATAR…",C.gold)
 local promptOk=pcall(function()AvatarEditorService:PromptSaveAvatar(desc,hum.RigType)end);if not promptOk then setStatus("SAVE AVATAR tidak tersedia saat ini.",C.pink)end
end)
AvatarEditorService.PromptSaveAvatarCompleted:Connect(function(result)
 if result==Enum.AvatarPromptResult.Success then setStatus("Avatar saved.",C.green) else setStatus("Save tidak selesai.",C.muted) end
end)
remote.OnClientEvent:Connect(function(kind,data)if kind=="open" then openPanel() elseif kind=="status" then setStatus(tostring(data or ""),C.cyan) end end)

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.Y<800
 panel.Size=UDim2.fromOffset(math.clamp(math.floor(vp.X*(phone and .88 or .64)),310,560),math.clamp(math.floor(vp.Y*(phone and .68 or .62)),350,430))
end
task.defer(responsive)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)

local acc=0
RunService.Heartbeat:Connect(function(dt)
 if not visibleSession then return end
 acc+=dt;if acc<.20 then return end;acc=0
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid");local seat=hum and hum.SeatPart
 if seat and tostring(seat.Name):match("^LookLabSeat") then lastSeatedAt=os.clock() elseif os.clock()-lastSeatedAt>1.25 then closePanel() end
end)
player.CharacterAdded:Connect(function()closePanel()end)
print("[BBYA] Look Lab Avatar Editor client v2 online: access-gated catalog recovery + compact mobile UI")
