-- BBYA SOCIAL HUB — IN-SESSION AVATAR SWITCH CLIENT v1
-- Lists the local player's Roblox outfits through AvatarEditorService and applies one without rejoin.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AvatarEditorService=game:GetService("AvatarEditorService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local remote=remotes and remotes:WaitForChild("AvatarSwitch",30)
if not remote then return end

local old=pg:FindFirstChild("BBYAAvatarSwitchUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui");gui.Name="BBYAAvatarSwitchUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=176;gui.Parent=pg
local C={bg=Color3.fromRGB(13,13,17),card=Color3.fromRGB(29,29,37),card2=Color3.fromRGB(38,38,48),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(164,166,177),pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(73,207,235),green=Color3.fromRGB(103,230,174),red=Color3.fromRGB(235,91,104)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.muted;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function label(parent,v,pos,size,font,ts,col,align)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=tostring(v or "");t.Position=pos;t.Size=size;t.Font=font or Enum.Font.Gotham;t.TextSize=ts or 11;t.TextColor3=col or C.white;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.TextTruncate=Enum.TextTruncate.AtEnd;t.Parent=parent;return t end
local function btn(parent,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.Parent=parent;corner(b,9);stroke(b,C.muted,.55);return b end

local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.74;shade.Visible=false;shade.BorderSizePixel=0;shade.Parent=gui
local panel=Instance.new("Frame");panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.52);panel.Size=UDim2.fromOffset(560,430);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Parent=shade;corner(panel,15);stroke(panel,C.cyan,.35)
label(panel,"GANTI AVATAR",UDim2.fromOffset(16,12),UDim2.new(1,-64,0,24),Enum.Font.GothamBlack,17,C.white)
label(panel,"Pilih outfit Roblox milikmu • tidak perlu rejoin",UDim2.fromOffset(16,36),UDim2.new(1,-64,0,18),Enum.Font.Gotham,9,C.muted)
local close=btn(panel,"×",UDim2.new(1,-46,0,12),UDim2.fromOffset(32,30),C.card);close.TextSize=18
local status=label(panel,"Tap REFRESH untuk membaca koleksi outfit Roblox kamu.",UDim2.fromOffset(16,62),UDim2.new(1,-144,0,34),Enum.Font.GothamMedium,9,C.cyan)
local refresh=btn(panel,"REFRESH",UDim2.new(1,-124,0,62),UDim2.fromOffset(108,34),C.card2)
local holder=Instance.new("ScrollingFrame");holder.Position=UDim2.fromOffset(16,104);holder.Size=UDim2.new(1,-32,1,-120);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.AutomaticCanvasSize=Enum.AutomaticSize.Y;holder.CanvasSize=UDim2.new();holder.Parent=panel
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(8,8);grid.CellSize=UDim2.new(.32,-5,0,146);grid.Parent=holder

local outfitsPermission=false
local loading=false
local pages=nil
local function clearCards()for _,c in ipairs(holder:GetChildren()) do if c~=grid then c:Destroy() end end end
local function setStatus(v,col)status.Text=tostring(v);status.TextColor3=col or C.cyan end
local function itemId(item)return tonumber(item.Id or item.id or item.OutfitId or item.outfitId)end
local function addOutfit(item)
 local id=itemId(item);if not id then return end
 local name=tostring(item.Name or item.name or ("OUTFIT "..id))
 local card=Instance.new("Frame");card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.Parent=holder;corner(card,10);stroke(card,C.muted,.62)
 local img=Instance.new("ImageLabel");img.Position=UDim2.fromOffset(6,6);img.Size=UDim2.new(1,-12,0,88);img.BackgroundColor3=C.card2;img.BorderSizePixel=0;img.ScaleType=Enum.ScaleType.Crop;img.Image=string.format("rbxthumb://type=Outfit&id=%d&w=150&h=150",id);img.Parent=card;corner(img,8)
 local nm=label(card,name,UDim2.fromOffset(7,96),UDim2.new(1,-14,0,18),Enum.Font.GothamBold,9,C.white,Enum.TextXAlignment.Center)
 local apply=btn(card,"APPLY",UDim2.fromOffset(7,118),UDim2.new(1,-14,0,22),Color3.fromRGB(41,78,70));apply.TextSize=9
 apply.Activated:Connect(function()setStatus("Applying "..name.."…",C.cyan);remote:FireServer("applyOutfit",id)end)
end
local function renderPage()
 if not pages then return end
 clearCards();local ok,data=pcall(function()return pages:GetCurrentPage()end)
 if not ok or type(data)~="table" then setStatus("Koleksi outfit belum tersedia.",C.red);return end
 for _,item in ipairs(data) do addOutfit(item) end
 setStatus(#data>0 and (tostring(#data).." outfit ditemukan • tap APPLY") or "Belum ada outfit di halaman ini.",#data>0 and C.green or C.muted)
end
local function loadOutfits()
 if loading then return end;loading=true
 local ok,result=pcall(function()return AvatarEditorService:GetOutfitsAsync(Enum.OutfitSource.All,Enum.OutfitType.Avatar)end)
 if ok and result then pages=result;outfitsPermission=true;renderPage();loading=false;return end
 loading=false
 if not outfitsPermission then
  setStatus("Izinkan BBYA membaca daftar outfit Roblox kamu.",C.cyan)
  pcall(function()AvatarEditorService:PromptAllowInventoryReadAccess()end)
 else setStatus("Outfit Roblox belum dapat dimuat. Coba REFRESH.",C.red) end
end
refresh.Activated:Connect(loadOutfits)
AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Connect(function(result)
 if result==Enum.AvatarPromptResult.Success then outfitsPermission=true;setStatus("Permission granted • loading outfits…",C.green);task.defer(loadOutfits) else setStatus("Akses outfit tidak diberikan.",C.muted) end
end)
remote.OnClientEvent:Connect(function(kind,data)
 if kind~="status" or type(data)~="table" then return end
 setStatus(tostring(data.message or ""),data.ok and C.green or C.red)
end)
close.Activated:Connect(function()shade.Visible=false end)

local function inject()
 local menu=pg:FindFirstChild("BBYACommandMenuUI");local drawer=menu and menu:FindFirstChild("FeatureDrawer",true);local list=drawer and drawer:FindFirstChild("FeatureList",true);if not list then return false end
 local oldButton=list:FindFirstChild("BBYAAvatarSwitchMenuButton");if oldButton then return true end
 local template=nil;for _,d in ipairs(list:GetChildren()) do if d:IsA("TextButton") then template=d;break end end
 local b=template and template:Clone() or Instance.new("TextButton");b.Name="BBYAAvatarSwitchMenuButton";b.Text="AVATAR";b.Visible=true;b.Active=true;b.AutoButtonColor=true
 if not template then b.Size=UDim2.new(1,-8,0,38);b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;corner(b,8) end
 b:SetAttribute("BBYAInjectedAuthority","AVATAR_SWITCH_V1");b.Parent=list
 b.Activated:Connect(function()if drawer and drawer:IsA("GuiObject") then drawer.Visible=false end;shade.Visible=true;task.defer(loadOutfits)end)
 return true
end
pg.ChildAdded:Connect(function(c)if c.Name=="BBYACommandMenuUI" then task.defer(inject);task.delay(.2,inject)end end)
task.spawn(function()for _=1,40 do if inject() then break end;task.wait(.25) end end)
player.CharacterAdded:Connect(function()shade.Visible=false end)

print("[BBYA] In-session Avatar Switch client v1 online: own Roblox outfits + APPLY without rejoin")
