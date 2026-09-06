-- BBYA SOCIAL HUB — PLAYER IDENTITY UI v1.3 GENERAL PANEL ORIGINAL
-- Custom TITLE follows restored narrow General Panel. No fullscreen backdrop.
-- Level-up notification logic remains independent.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local snapshot=remotes and remotes:WaitForChild("TitleSnapshot",30)
local action=remotes and remotes:WaitForChild("TitleAction",30)
local levelUp=remotes and remotes:WaitForChild("LevelUp",30)
if not snapshot or not action or not levelUp then return end
local old=pg:FindFirstChild("BBYAIdentityUI");if old then old:Destroy()end
local gui=Instance.new("ScreenGui");gui.Name="BBYAIdentityUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=278;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg;gui:SetAttribute("TitleClickLayerAuthority","IDENTITY_UI_V1_3_GENERAL_ORIGINAL")
local C={bg=Color3.fromRGB(13,13,17),panel=Color3.fromRGB(22,22,28),card=Color3.fromRGB(31,31,39),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(162,164,176),pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(73,207,235),gold=Color3.fromRGB(235,184,74),red=Color3.fromRGB(235,91,104),green=Color3.fromRGB(103,230,174)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.muted;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function text(p,v,pos,size,font,ts,col,align)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=tostring(v or"");t.Position=pos;t.Size=size;t.Font=font or Enum.Font.Gotham;t.TextSize=ts or 10;t.TextColor3=col or C.white;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.TextTruncate=Enum.TextTruncate.AtEnd;t.Parent=p;return t end
local function btn(p,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.AutoButtonColor=true;b.Parent=p;corner(b,9);stroke(b,C.muted,.55);return b end
local function kernelMenuVisible(v)local k=pg:FindFirstChild("BBYACommandMenuUI");local m=k and k:FindFirstChild("MenuButton",true);if m then m.Visible=v end end
local camera=workspace.CurrentCamera
local function generalRect()camera=workspace.CurrentCamera or camera;local vp=camera and camera.ViewportSize or Vector2.new(1280,720);return math.clamp(math.floor(vp.X*.17),210,240),math.clamp(vp.Y-42,340,620)end

local panel=Instance.new("Frame");panel.Name="TitlePanel";panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-12,.5,0);panel.BackgroundColor3=C.bg;panel.BackgroundTransparency=.20;panel.BorderSizePixel=0;panel.Visible=false;panel.ClipsDescendants=true;panel.Parent=gui;corner(panel,14);stroke(panel,C.pink,.28);panel:SetAttribute("BBYAOuterLayoutAuthority","GENERAL_PANEL_ORIGINAL_NARROW_V1")
local titleHead=text(panel,"CUSTOM TITLE",UDim2.fromOffset(14,9),UDim2.new(1,-54,0,24),Enum.Font.GothamBlack,14,C.white)
local close=btn(panel,"×",UDim2.new(1,-40,0,7),UDim2.fromOffset(30,30),C.card);close.TextSize=17
text(panel,"Cosmetic • max 16 chars",UDim2.fromOffset(14,33),UDim2.new(1,-28,0,16),Enum.Font.Gotham,8,C.muted)
local titleBox=Instance.new("TextBox");titleBox.Position=UDim2.fromOffset(12,58);titleBox.Size=UDim2.new(1,-24,0,38);titleBox.BackgroundColor3=C.card;titleBox.BorderSizePixel=0;titleBox.PlaceholderText="BOCIL ROBLOX";titleBox.PlaceholderColor3=C.muted;titleBox.TextColor3=C.white;titleBox.ClearTextOnFocus=false;titleBox.Font=Enum.Font.GothamSemibold;titleBox.TextSize=10;titleBox.Text="";titleBox.Parent=panel;corner(titleBox,9);stroke(titleBox,C.pink,.58);local p1=Instance.new("UIPadding");p1.PaddingLeft=UDim.new(0,10);p1.PaddingRight=UDim.new(0,10);p1.Parent=titleBox
local colorBox=Instance.new("TextBox");colorBox.Position=UDim2.fromOffset(12,106);colorBox.Size=UDim2.new(1,-24,0,34);colorBox.BackgroundColor3=C.card;colorBox.BorderSizePixel=0;colorBox.PlaceholderText="#FFFFFF";colorBox.PlaceholderColor3=C.muted;colorBox.TextColor3=C.white;colorBox.ClearTextOnFocus=false;colorBox.Font=Enum.Font.GothamBold;colorBox.TextSize=9;colorBox.Text="#F3F3F3";colorBox.Parent=panel;corner(colorBox,9);stroke(colorBox,C.cyan,.58);local p2=Instance.new("UIPadding");p2.PaddingLeft=UDim.new(0,10);p2.Parent=colorBox
local preview=Instance.new("Frame");preview.Position=UDim2.fromOffset(12,150);preview.Size=UDim2.new(1,-24,0,66);preview.BackgroundColor3=C.panel;preview.BorderSizePixel=0;preview.Parent=panel;corner(preview,9);stroke(preview,C.muted,.6)
text(preview,"PREVIEW",UDim2.fromOffset(8,3),UDim2.new(1,-16,0,16),Enum.Font.GothamBold,7,C.muted)
local previewText=text(preview,"YOUR TITLE",UDim2.fromOffset(8,20),UDim2.new(1,-16,0,36),Enum.Font.GothamBlack,12,C.white,Enum.TextXAlignment.Center)
local save=btn(panel,"SAVE",UDim2.fromOffset(12,226),UDim2.new(1,-24,0,36),C.pink)
local equip=btn(panel,"EQUIP",UDim2.fromOffset(12,270),UDim2.new(.5,-16,0,34),Color3.fromRGB(45,86,72))
local remove=btn(panel,"REMOVE",UDim2.new(.5,4,0,270),UDim2.new(.5,-16,0,34),Color3.fromRGB(83,38,47))
local status=text(panel,"TITLE not loaded yet.",UDim2.fromOffset(14,314),UDim2.new(1,-28,1,-326),Enum.Font.Gotham,8,C.muted);status.TextWrapped=true;status.TextYAlignment=Enum.TextYAlignment.Top
local function parseHex(s)s=string.upper(tostring(s or"")):gsub("%s+","");if not s:match("^#%x%x%x%x%x%x$")then return nil end;return Color3.fromRGB(tonumber(s:sub(2,3),16),tonumber(s:sub(4,5),16),tonumber(s:sub(6,7),16))end
local function updatePreview()previewText.Text=titleBox.Text~=""and titleBox.Text or"YOUR TITLE";previewText.TextColor3=parseHex(colorBox.Text)or C.white end
titleBox:GetPropertyChangedSignal("Text"):Connect(function()if utf8.len(titleBox.Text or"")and utf8.len(titleBox.Text)>16 then local out="";local n=0;for _,cp in utf8.codes(titleBox.Text)do if n>=16 then break end;n+=1;out=out..utf8.char(cp)end;titleBox.Text=out end;updatePreview()end);colorBox:GetPropertyChangedSignal("Text"):Connect(updatePreview)
local function applyResult(r)if type(r)~="table"then status.Text="TITLE request failed.";status.TextColor3=C.red;return end;status.Text=tostring(r.message or"Updated.");status.TextColor3=r.ok and C.green or C.red;if r.title~=nil then titleBox.Text=tostring(r.title)end;if r.color~=nil then colorBox.Text=tostring(r.color)end;updatePreview()end
local function loadSnapshot()local ok,r=pcall(function()return snapshot:InvokeServer()end);if not ok or type(r)~="table"then status.Text="TITLE data unavailable.";return end;titleBox.Text=tostring(r.title or"");colorBox.Text=tostring(r.color or"#F3F3F3");status.Text=r.equipped and"Current TITLE is equipped."or"Edit then SAVE / EQUIP.";updatePreview()end
save.Activated:Connect(function()local ok,r=pcall(function()return action:InvokeServer("save",{text=titleBox.Text,color=colorBox.Text})end);applyResult(ok and r or nil)end);equip.Activated:Connect(function()local ok,r=pcall(function()return action:InvokeServer("equip",{})end);applyResult(ok and r or nil)end);remove.Activated:Connect(function()local ok,r=pcall(function()return action:InvokeServer("remove",{})end);applyResult(ok and r or nil)end)
local function layout()local w,h=generalRect();panel.Size=UDim2.fromOffset(w,h);panel.Position=UDim2.new(1,-12,.5,0)end
local function closePanel()panel.Visible=false;kernelMenuVisible(true)end;close.Activated:Connect(closePanel)
local function inject()
 local menu=pg:FindFirstChild("BBYACommandMenuUI");local drawer=menu and menu:FindFirstChild("FeatureDrawer",true);local list=drawer and drawer:FindFirstChild("FeatureList",true);if not list then return false end;local existing=list:FindFirstChild("BBYATitleMenuButton");if existing then return true end;local template=nil;for _,d in ipairs(list:GetChildren())do if d:IsA("TextButton")then template=d;break end end;local b=template and template:Clone()or Instance.new("TextButton");b.Name="BBYATitleMenuButton";b.Text="TITLE";b.Visible=true;b.Active=true;b.AutoButtonColor=true;if not template then b.Size=UDim2.new(1,-8,0,38);b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=10;corner(b,8)end;b.Parent=list;b.Activated:Connect(function()drawer.Visible=false;kernelMenuVisible(false);layout();panel.Visible=true;loadSnapshot()end);return true
end
pg.ChildAdded:Connect(function(c)if c.Name=="BBYACommandMenuUI"then task.defer(inject)end end);task.spawn(function()for _=1,40 do if inject()then break end;task.wait(.25)end end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end

local levelPopup=Instance.new("Frame");levelPopup.AnchorPoint=Vector2.new(.5,0);levelPopup.Position=UDim2.new(.5,0,.14,-120);levelPopup.Size=UDim2.fromOffset(330,86);levelPopup.BackgroundColor3=C.bg;levelPopup.BorderSizePixel=0;levelPopup.Visible=false;levelPopup.ZIndex=300;levelPopup.Parent=gui;corner(levelPopup,14);stroke(levelPopup,C.gold,.20)
local levelAvatar=Instance.new("ImageLabel");levelAvatar.Position=UDim2.fromOffset(12,13);levelAvatar.Size=UDim2.fromOffset(58,58);levelAvatar.BackgroundColor3=C.card;levelAvatar.BorderSizePixel=0;levelAvatar.ScaleType=Enum.ScaleType.Crop;levelAvatar.Parent=levelPopup;corner(levelAvatar,29)
local levelHead=text(levelPopup,"LEVEL UP!",UDim2.fromOffset(84,11),UDim2.new(1,-96,0,24),Enum.Font.GothamBlack,16,C.gold);local levelText=text(levelPopup,"You reached Level 1",UDim2.fromOffset(84,36),UDim2.new(1,-96,0,20),Enum.Font.GothamBold,11,C.white);local rankText=text(levelPopup,"NEWBIE",UDim2.fromOffset(84,59),UDim2.new(1,-96,0,14),Enum.Font.GothamBold,8,C.cyan)
task.spawn(function()local ok,url=pcall(function()return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)end);if ok then levelAvatar.Image=url end end)
local token=0;levelUp.OnClientEvent:Connect(function(data)data=type(data)=="table"and data or{};token+=1;local me=token;levelText.Text="You reached Level "..tostring(data.level or player:GetAttribute("BBYALevel")or"?");rankText.Text=tostring(data.rank or player:GetAttribute("BBYARank")or"");levelPopup.Visible=true;levelPopup.Position=UDim2.new(.5,0,.14,-120);TweenService:Create(levelPopup,TweenInfo.new(.24),{Position=UDim2.new(.5,0,.14,0)}):Play();task.delay(4,function()if token~=me then return end;local tw=TweenService:Create(levelPopup,TweenInfo.new(.2),{Position=UDim2.new(.5,0,.14,-120)});tw:Play();tw.Completed:Wait();if token==me then levelPopup.Visible=false end end)end)
task.defer(layout)
print("[BBYA] Identity UI v1.3 online: restored narrow General Panel / no backdrop / level popup preserved")