-- BBYA SOCIAL HUB — SAWERIA LINK PANEL v1
-- LINK is information/copy-oriented only. It never opens a browser or redirects automatically.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local SAWERIA_URL="https://saweria.co/BBYAsocialhub"

local old=pg:FindFirstChild("BBYASaweriaLinkUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui");gui.Name="BBYASaweriaLinkUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=174;gui.Parent=pg
gui:SetAttribute("AutoOpenWeb",false);gui:SetAttribute("OfficialSaweriaURL",SAWERIA_URL)
local C={bg=Color3.fromRGB(13,13,17),card=Color3.fromRGB(29,29,37),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(164,166,177),gold=Color3.fromRGB(235,184,74),cyan=Color3.fromRGB(73,207,235)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function label(parent,v,pos,size,font,ts,col,align)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=tostring(v or "");t.Position=pos;t.Size=size;t.Font=font or Enum.Font.Gotham;t.TextSize=ts or 11;t.TextColor3=col or C.white;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.TextWrapped=true;t.Parent=parent;return t end
local function btn(parent,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;b.Parent=parent;corner(b,9);stroke(b,C.muted,.55);return b end

local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.8;shade.Visible=false;shade.BorderSizePixel=0;shade.Parent=gui
local panel=Instance.new("Frame");panel.AnchorPoint=Vector2.new(1,0);panel.Position=UDim2.new(1,-18,0,58);panel.Size=UDim2.fromOffset(360,220);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Parent=shade;corner(panel,14);stroke(panel,C.gold,.28)
label(panel,"LINK • SAWERIA",UDim2.fromOffset(16,12),UDim2.new(1,-64,0,24),Enum.Font.GothamBlack,17,C.white)
label(panel,"Support di luar Robux melalui halaman Saweria resmi BBYA. Link ini hanya ditampilkan agar bisa kamu salin.",UDim2.fromOffset(16,42),UDim2.new(1,-32,0,48),Enum.Font.Gotham,10,C.muted)
local close=btn(panel,"×",UDim2.new(1,-46,0,12),UDim2.fromOffset(32,30),C.card);close.TextSize=18
local box=Instance.new("TextBox");box.Position=UDim2.fromOffset(16,100);box.Size=UDim2.new(1,-32,0,42);box.BackgroundColor3=C.card;box.BorderSizePixel=0;box.Text=SAWERIA_URL;box.ClearTextOnFocus=false;box.TextEditable=true;box.MultiLine=false;box.TextColor3=C.cyan;box.Font=Enum.Font.Code;box.TextSize=12;box.TextXAlignment=Enum.TextXAlignment.Left;box.Parent=panel;corner(box,9);stroke(box,C.cyan,.45);local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,10);pad.Parent=box
local select=btn(panel,"SELECT LINK",UDim2.fromOffset(16,154),UDim2.fromOffset(132,38),Color3.fromRGB(35,68,78))
label(panel,"Tidak membuka web otomatis.",UDim2.fromOffset(160,154),UDim2.new(1,-176,0,38),Enum.Font.GothamBold,9,C.gold)
local function selectAll()
 box:CaptureFocus();task.defer(function()box.CursorPosition=#box.Text+1;box.SelectionStart=1 end)
end
select.Activated:Connect(selectAll)
box.FocusLost:Connect(function()if box.Text~=SAWERIA_URL then box.Text=SAWERIA_URL end end)
close.Activated:Connect(function()shade.Visible=false end)

local function inject()
 local menu=pg:FindFirstChild("BBYACommandMenuUI");local drawer=menu and menu:FindFirstChild("FeatureDrawer",true);local list=drawer and drawer:FindFirstChild("FeatureList",true);if not list then return false end
 local oldButton=list:FindFirstChild("BBYASaweriaMenuButton");if oldButton then return true end
 local template=nil;for _,d in ipairs(list:GetChildren()) do if d:IsA("TextButton") then template=d;break end end
 local b=template and template:Clone() or Instance.new("TextButton");b.Name="BBYASaweriaMenuButton";b.Text="LINK";b.Visible=true;b.Active=true;b.AutoButtonColor=true
 if not template then b.Size=UDim2.new(1,-8,0,38);b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;corner(b,8) end
 b:SetAttribute("BBYAInjectedAuthority","SAWERIA_LINK_V1");b.Parent=list
 b.Activated:Connect(function()if drawer and drawer:IsA("GuiObject") then drawer.Visible=false end;box.Text=SAWERIA_URL;shade.Visible=true end)
 return true
end
pg.ChildAdded:Connect(function(c)if c.Name=="BBYACommandMenuUI" then task.defer(inject);task.delay(.2,inject) end end)
task.spawn(function()for _=1,40 do if inject() then break end;task.wait(.25) end end)

print("[BBYA] Saweria LINK v1 online: display/select only, no browser redirect")
