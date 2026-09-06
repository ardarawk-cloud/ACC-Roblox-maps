-- BBYA SOCIAL HUB — IN-SESSION AVATAR SWITCH CLIENT v2 MOBILE SAFE
-- Lists the local player's Roblox outfits through AvatarEditorService and applies one without rejoin.
-- Runtime QC lock: panel must fit the full mobile landscape viewport; X is the only close control.

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

local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.80;shade.Visible=false;shade.BorderSizePixel=0;shade.Parent=gui
local panel=Instance.new("Frame");panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.fromOffset(560,330);panel.BackgroundColor3=C.bg;panel.BackgroundTransparency=.08;panel.BorderSizePixel=0;panel.Parent=shade;panel.ClipsDescendants=true;corner(panel,15);stroke(panel,C.cyan,.35)
label(panel,"GANTI AVATAR",UDim2.fromOffset(16,10),UDim2.new(1,-64,0,22),Enum.Font.GothamBlack,16,C.white)
label(panel,"Pilih outfit Roblox milikmu • tidak perlu rejoin",UDim2.fromOffset(16,32),UDim2.new(1,-64,0,16),Enum.Font.Gotham,8,C.muted)
local close=btn(panel,"×",UDim2.new(1,-44,0,9),UDim2.fromOffset(30,28),C.card);close.TextSize=17
local status=label(panel,"Tap REFRESH untuk membaca koleksi outfit Roblox kamu.",UDim2.fromOffset(16,53),UDim2.new(1,-132,0,30),Enum.Font.GothamMedium,8,C.cyan)
local refresh=btn(panel,"REFRESH",UDim2.new(1,-112,0,53),UDim2.fromOffset(96,30),C.card2);refresh.TextSize=9
local holder=Instance.new("ScrollingFrame");holder.Position=UDim2.fromOffset(14,90);holder.Size=UDim2.new(1,-28,1,-104);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.AutomaticCanvasSize=Enum.AutomaticSize.Y;holder.CanvasSize=UDim2.new();holder.Parent=panel
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(7,7);grid.CellSize=UDim2.new(1/3,-5,0,116);grid.Parent=holder

local camera=workspace.CurrentCamera
local function layout()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local landscape=vp.X>=vp.Y
 local safeW=math.max(280,vp.X-28)
 local safeH=math.max(250,vp.Y-74)
 local w=math.min(560,safeW)
 local h=math.min(landscape and 330 or 430,safeH)
 panel.Size=UDim2.fromOffset(w,h)
 panel.Position=UDim2.new(.5,0,.5,landscape and 18 or 22)
 local cols=w>=500 and 3 or 2
 grid.FillDirectionMaxCells=cols
 grid.CellSize=UDim2.new(1/cols,-6,0,landscape and 112 or 128)
end
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout) end;layout()end)

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
 local img=Instance.new("ImageLabel");img.Position=UDim2.fromOffset(6,6);img.Size=UDim2.new(1,-12,1,-46);img.BackgroundColor3=C.card2;img.BorderSizePixel=0;img.ScaleType=Enum.ScaleType.Crop;img.Image=string.format("rbxthumb://type=Outfit&id=%d&w=150&h=150",id);img.Parent=card;corner(img,8)
 local nm=label(card,name,UDim2.new(0,7,1,-38),UDim2.new(1,-14,0,14),Enum.Font.GothamBold,8,C.white,Enum.TextXAlignment.Center)
 local apply=btn(card,"APPLY",UDim2.new(0,7,1,-22),UDim2.new(1,-14,0,18),Color3.fromRGB(41,78,70));apply.TextSize=8
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

local function menuButton()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 return menu and menu:FindFirstChild("MenuButton",true)
end
local function closePanel()
 shade.Visible=false
 local mb=menuButton();if mb and mb:IsA("GuiObject") then mb.Visible=true end
end
close.Activated:Connect(closePanel)

local function inject()
 local menu=pg:FindFirstChild("BBYACommandMenuUI");local drawer=menu and menu:FindFirstChild("FeatureDrawer",true);local list=drawer and drawer:FindFirstChild("FeatureList",true);if not list then return false end
 local oldButton=list:FindFirstChild("BBYAAvatarSwitchMenuButton");if oldButton then return true end
 local template=nil;for _,d in ipairs(list:GetChildren()) do if d:IsA("TextButton") then template=d;break end end
 local b=template and template:Clone() or Instance.new("TextButton");b.Name="BBYAAvatarSwitchMenuButton";b.Text="AVATAR";b.Visible=true;b.Active=true;b.AutoButtonColor=true
 if not template then b.Size=UDim2.new(1,-8,0,38);b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;corner(b,8) end
 b:SetAttribute("BBYAInjectedAuthority","AVATAR_SWITCH_V2_MOBILE_SAFE");b.Parent=list
 b.Activated:Connect(function()
  if drawer and drawer:IsA("GuiObject") then drawer.Visible=false end
  local mb=menuButton();if mb and mb:IsA("GuiObject") then mb.Visible=false end
  layout();shade.Visible=true;task.defer(loadOutfits)
 end)
 return true
end
pg.ChildAdded:Connect(function(c)if c.Name=="BBYACommandMenuUI" then task.defer(inject);task.delay(.2,inject)end end)
task.spawn(function()for _=1,40 do if inject() then break end;task.wait(.25) end end)
player.CharacterAdded:Connect(closePanel)
task.defer(layout)

print("[BBYA] In-session Avatar Switch client v2 online: mobile-safe responsive cards + X-only close")