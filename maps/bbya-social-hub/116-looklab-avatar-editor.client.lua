-- BBYA SOCIAL HUB — LOOK LAB AVATAR EDITOR CLIENT v1
-- Compact in-experience Roblox catalog browser for Hair / Top / Bottom / Accessories.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AvatarEditorService=game:GetService("AvatarEditorService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local remote=remotes:WaitForChild("LookLabAvatar")

local old=pg:FindFirstChild("BBYALookLabAvatarUI")
if old then old:Destroy() end

local C={
 bg=Color3.fromRGB(10,10,13),panel=Color3.fromRGB(18,17,22),card=Color3.fromRGB(27,25,31),card2=Color3.fromRGB(35,31,39),
 pink=Color3.fromRGB(244,48,149),cyan=Color3.fromRGB(31,184,207),gold=Color3.fromRGB(211,165,97),white=Color3.fromRGB(242,239,243),muted=Color3.fromRGB(158,153,166),line=Color3.fromRGB(55,50,61),green=Color3.fromRGB(72,205,133)
}
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,t,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=t or 1;s.Transparency=tr or .4;s.Parent=o;return s end
local function label(parent,text,pos,size,font,ts,col)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 12;l.TextColor3=col or C.white;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card;b.TextColor3=C.white;b.Font=Enum.Font.GothamSemibold;b.TextSize=12;b.BorderSizePixel=0;b.AutoButtonColor=true;b.Parent=parent;round(b,9);return b
end

local gui=Instance.new("ScreenGui")
gui.Name="BBYALookLabAvatarUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=55;gui.Parent=pg

local dim=Instance.new("Frame")
dim.Size=UDim2.fromScale(1,1);dim.BackgroundColor3=Color3.new(0,0,0);dim.BackgroundTransparency=.48;dim.BorderSizePixel=0;dim.Visible=false;dim.Parent=gui

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.54);panel.Size=UDim2.new(.92,0,0,470);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;round(panel,16);stroke(panel,C.pink,1.1,.42)
local lim=Instance.new("UISizeConstraint");lim.MinSize=Vector2.new(310,390);lim.MaxSize=Vector2.new(620,480);lim.Parent=panel

label(panel,"BBYA LOOK LAB",UDim2.fromOffset(18,14),UDim2.new(1,-70,0,24),Enum.Font.GothamBold,18,C.white)
local sub=label(panel,"TRY ON langsung di avatar — tanpa keluar map",UDim2.fromOffset(18,40),UDim2.new(1,-70,0,18),Enum.Font.Gotham,10,C.muted)
local close=button(panel,"×",UDim2.new(1,-48,0,12),UDim2.fromOffset(34,34),C.card2);close.TextSize=20

local tabsFrame=Instance.new("Frame");tabsFrame.BackgroundTransparency=1;tabsFrame.Position=UDim2.fromOffset(16,68);tabsFrame.Size=UDim2.new(1,-32,0,40);tabsFrame.Parent=panel
local tabLayout=Instance.new("UIListLayout");tabLayout.FillDirection=Enum.FillDirection.Horizontal;tabLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;tabLayout.Padding=UDim.new(0,6);tabLayout.Parent=tabsFrame

local searchBox=Instance.new("TextBox")
searchBox.PlaceholderText="Search catalog…";searchBox.Text="";searchBox.ClearTextOnFocus=false;searchBox.Position=UDim2.fromOffset(16,116);searchBox.Size=UDim2.new(1,-108,0,38);searchBox.BackgroundColor3=C.card;searchBox.TextColor3=C.white;searchBox.PlaceholderColor3=C.muted;searchBox.Font=Enum.Font.Gotham;searchBox.TextSize=12;searchBox.BorderSizePixel=0;searchBox.Parent=panel;round(searchBox,9);stroke(searchBox,C.line,1,.55)
local searchBtn=button(panel,"SEARCH",UDim2.new(1,-86,0,116),UDim2.fromOffset(70,38),C.card2);stroke(searchBtn,C.cyan,1,.45)

local status=label(panel,"Duduk di styling chair untuk mulai.",UDim2.fromOffset(16,160),UDim2.new(1,-32,0,22),Enum.Font.GothamMedium,10,C.cyan)

local holder=Instance.new("ScrollingFrame")
holder.Position=UDim2.fromOffset(16,188);holder.Size=UDim2.new(1,-32,1,-250);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.ScrollBarImageColor3=C.pink;holder.CanvasSize=UDim2.new();holder.AutomaticCanvasSize=Enum.AutomaticSize.Y;holder.ScrollingDirection=Enum.ScrollingDirection.Y;holder.Active=true;holder.Parent=panel
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(8,8);grid.CellSize=UDim2.new(.32,-6,0,132);grid.Parent=holder

local bottom=Instance.new("Frame");bottom.BackgroundTransparency=1;bottom.Position=UDim2.new(0,16,1,-54);bottom.Size=UDim2.new(1,-32,0,40);bottom.Parent=panel
local resetBtn=button(bottom,"RESET",UDim2.fromOffset(0,0),UDim2.new(.30,-4,1,0),C.card2);stroke(resetBtn,C.gold,1,.42)
local saveBtn=button(bottom,"SAVE AVATAR",UDim2.new(.30,4,0,0),UDim2.new(.42,-4,1,0),Color3.fromRGB(54,35,52));stroke(saveBtn,C.pink,1,.35)
local doneBtn=button(bottom,"DONE",UDim2.new(.72,4,0,0),UDim2.new(.28,-4,1,0),C.card2);stroke(doneBtn,C.cyan,1,.48)

local footer=label(panel,"Catalog items can be previewed. Saving does not grant unowned items.",UDim2.new(0,16,1,-77),UDim2.new(1,-32,0,16),Enum.Font.Gotham,9,C.muted);footer.TextXAlignment=Enum.TextXAlignment.Center

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

local function setStatus(text,col)status.Text=tostring(text or "");status.TextColor3=col or C.cyan end
local function clearCards()
 for _,ch in ipairs(holder:GetChildren()) do if ch~=grid then ch:Destroy() end end
end
local function setActiveTab(name)
 activeTab=name
 for n,b in pairs(tabButtons) do
  b.BackgroundColor3=(n==name) and Color3.fromRGB(58,34,51) or C.card
  local st=b:FindFirstChildOfClass("UIStroke");if st then st.Color=(n==name) and C.pink or C.line end
 end
end

for _,name in ipairs({"HAIR","TOP","BOTTOM","ACCESSORY"}) do
 local b=button(tabsFrame,name,UDim2.new(),UDim2.fromOffset(name=="ACCESSORY" and 102 or 74,36),C.card);stroke(b,C.line,1,.55);tabButtons[name]=b
 b.MouseButton1Click:Connect(function()setActiveTab(name);task.defer(function()searchBtn:Activate()end)end)
end
setActiveTab("HAIR")

local function assetTypeName(v)
 if typeof(v)=="EnumItem" then return v.Name end
 local s=tostring(v or "")
 s=s:gsub("Enum%.AvatarAssetType%.","")
 return s
end
local function addCard(item)
 local id=tonumber(item.Id or item.AssetId)
 if not id then return end
 local typeName=assetTypeName(item.AssetType)
 local name=tostring(item.Name or ("Asset "..id))
 local card=Instance.new("TextButton")
 card.Text="";card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.AutoButtonColor=true;card.Parent=holder;round(card,10);stroke(card,C.line,1,.55)
 local img=Instance.new("ImageLabel")
 img.BackgroundColor3=C.card2;img.BorderSizePixel=0;img.Position=UDim2.fromOffset(7,7);img.Size=UDim2.new(1,-14,0,78);img.Image=string.format("rbxthumb://type=Asset&id=%d&w=150&h=150",id);img.ScaleType=Enum.ScaleType.Crop;img.Parent=card;round(img,8)
 local nm=label(card,name,UDim2.fromOffset(7,89),UDim2.new(1,-14,0,32),Enum.Font.GothamMedium,9,C.white);nm.TextXAlignment=Enum.TextXAlignment.Center;nm.TextYAlignment=Enum.TextYAlignment.Top
 local tag=label(card,"TRY ON",UDim2.new(0,7,1,-18),UDim2.new(1,-14,0,14),Enum.Font.GothamBold,8,C.pink);tag.TextXAlignment=Enum.TextXAlignment.Center
 card.MouseButton1Click:Connect(function()
  setStatus("Applying "..name.."…",C.gold)
  remote:FireServer("tryOn",{assetId=id,assetType=typeName})
 end)
end

local function runSearch()
 if searching or not visibleSession then return end
 searching=true;clearCards();setStatus("Loading Roblox Catalog…",C.gold)
 local params=CatalogSearchParams.new();params.AssetTypes=TAB_TYPES[activeTab];params.Limit=18
 local q=searchBox.Text:match("^%s*(.-)%s*$") or ""
 if q~="" then params.SearchKeyword=q end
 local ok,pages=pcall(function()return AvatarEditorService:SearchCatalogAsync(params)end)
 if not ok or not pages then
  setStatus("Catalog gagal dimuat. Coba SEARCH lagi.",C.pink);searching=false;return
 end
 local results=pages:GetCurrentPage()
 if #results==0 then setStatus("Tidak ada item. Coba keyword lain.",C.muted) else
  for _,item in ipairs(results) do addCard(item) end
  setStatus(string.format("%d items · tap untuk TRY ON",#results),C.green)
 end
 searching=false
end

searchBtn.MouseButton1Click:Connect(runSearch)
searchBox.FocusLost:Connect(function(enter)if enter then runSearch() end end)

local function closePanel()
 visibleSession=false;panel.Visible=false;dim.Visible=false;searching=false
end
local function openPanel()
 visibleSession=true;panel.Visible=true;dim.Visible=true;lastSeatedAt=os.clock();setStatus("Loading Look Lab…",C.cyan);task.defer(runSearch)
end
close.MouseButton1Click:Connect(closePanel)
doneBtn.MouseButton1Click:Connect(function()
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if hum then hum.Sit=false end
 closePanel()
end)
resetBtn.MouseButton1Click:Connect(function()setStatus("Resetting avatar…",C.gold);remote:FireServer("reset")end)
saveBtn.MouseButton1Click:Connect(function()
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not hum then return end
 local ok,desc=pcall(function()return hum:GetAppliedDescription()end)
 if not ok or not desc then setStatus("Avatar belum siap disimpan.",C.pink);return end
 setStatus("Opening Roblox SAVE AVATAR…",C.gold)
 local promptOk=pcall(function()AvatarEditorService:PromptSaveAvatar(desc,hum.RigType)end)
 if not promptOk then setStatus("SAVE AVATAR tidak tersedia saat ini.",C.pink) end
end)

AvatarEditorService.PromptSaveAvatarCompleted:Connect(function(result)
 if result==Enum.AvatarPromptResult.Success then setStatus("Avatar saved.",C.green)
 elseif result==Enum.AvatarPromptResult.PermissionDenied then setStatus("Save dibatalkan.",C.muted)
 else setStatus("Roblox gagal menyimpan avatar.",C.pink) end
end)

remote.OnClientEvent:Connect(function(kind,data)
 if kind=="open" then openPanel()
 elseif kind=="status" then setStatus(tostring(data or ""),C.cyan) end
end)

local acc=0
RunService.Heartbeat:Connect(function(dt)
 if not visibleSession then return end
 acc+=dt;if acc<.20 then return end;acc=0
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 local seat=hum and hum.SeatPart
 if seat and tostring(seat.Name):match("^LookLabSeat") then lastSeatedAt=os.clock() elseif os.clock()-lastSeatedAt>1.25 then closePanel() end
end)

player.CharacterAdded:Connect(function()closePanel()end)
print("[BBYA] Look Lab Avatar Editor client v1 online")