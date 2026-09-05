-- BBYA SOCIAL HUB — PLAYER IDENTITY UI v1.1
-- Custom TITLE editor + Level Up popup. Server progression authority remains 92-player-progression.server.lua.
-- v1.1 fixes TITLE click/input layering only; level progression logic is unchanged.

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

local old=pg:FindFirstChild("BBYAIdentityUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui");gui.Name="BBYAIdentityUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=278;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("TitleClickLayerAuthority","IDENTITY_UI_V1_1")
local C={bg=Color3.fromRGB(13,13,17),panel=Color3.fromRGB(22,22,28),card=Color3.fromRGB(31,31,39),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(162,164,176),pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(73,207,235),gold=Color3.fromRGB(235,184,74),red=Color3.fromRGB(235,91,104),green=Color3.fromRGB(103,230,174)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.muted;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function text(parent,v,pos,size,font,ts,col,align)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=tostring(v or "");t.Position=pos;t.Size=size;t.Font=font or Enum.Font.Gotham;t.TextSize=ts or 11;t.TextColor3=col or C.white;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.TextTruncate=Enum.TextTruncate.AtEnd;t.Parent=parent;return t end
local function btn(parent,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;b.Active=true;b.AutoButtonColor=true;b.Parent=parent;corner(b,9);stroke(b,C.muted,.55);return b end
local function kernelMenuVisible(visible)
 local k=pg:FindFirstChild("BBYACommandMenuUI");local m=k and k:FindFirstChild("MenuButton",true)
 if m and m:IsA("GuiObject") then m.Visible=visible end
end

local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.78;shade.Visible=false;shade.BorderSizePixel=0;shade.Active=true;shade.ZIndex=200;shade.Parent=gui
local panel=Instance.new("Frame");panel.AnchorPoint=Vector2.new(1,0);panel.Position=UDim2.new(1,-18,0,58);panel.Size=UDim2.fromOffset(330,330);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Active=true;panel.ZIndex=201;panel.Parent=shade;corner(panel,14);stroke(panel,C.pink,.28)
local titleHead=text(panel,"CUSTOM TITLE",UDim2.fromOffset(16,12),UDim2.new(1,-70,0,24),Enum.Font.GothamBlack,17,C.white);titleHead.ZIndex=202
local titleSub=text(panel,"Cosmetic only • max 16 characters",UDim2.fromOffset(16,36),UDim2.new(1,-70,0,18),Enum.Font.Gotham,9,C.muted);titleSub.ZIndex=202
local close=btn(panel,"×",UDim2.new(1,-46,0,12),UDim2.fromOffset(32,30),C.card);close.TextSize=18;close.ZIndex=204
local titleBox=Instance.new("TextBox");titleBox.Position=UDim2.fromOffset(16,70);titleBox.Size=UDim2.new(1,-32,0,40);titleBox.BackgroundColor3=C.card;titleBox.BorderSizePixel=0;titleBox.PlaceholderText="BOCIL ROBLOX";titleBox.PlaceholderColor3=C.muted;titleBox.TextColor3=C.white;titleBox.ClearTextOnFocus=false;titleBox.Font=Enum.Font.GothamSemibold;titleBox.TextSize=12;titleBox.Text="";titleBox.Active=true;titleBox.ZIndex=204;titleBox.Parent=panel;corner(titleBox,9);stroke(titleBox,C.pink,.58);local p1=Instance.new("UIPadding");p1.PaddingLeft=UDim.new(0,12);p1.PaddingRight=UDim.new(0,12);p1.Parent=titleBox
local colorBox=Instance.new("TextBox");colorBox.Position=UDim2.fromOffset(16,120);colorBox.Size=UDim2.fromOffset(112,36);colorBox.BackgroundColor3=C.card;colorBox.BorderSizePixel=0;colorBox.PlaceholderText="#FFFFFF";colorBox.PlaceholderColor3=C.muted;colorBox.TextColor3=C.white;colorBox.ClearTextOnFocus=false;colorBox.Font=Enum.Font.GothamBold;colorBox.TextSize=11;colorBox.Text="#F3F3F3";colorBox.Active=true;colorBox.ZIndex=204;colorBox.Parent=panel;corner(colorBox,9);stroke(colorBox,C.cyan,.58);local p2=Instance.new("UIPadding");p2.PaddingLeft=UDim.new(0,10);p2.Parent=colorBox
local preview=Instance.new("Frame");preview.Position=UDim2.fromOffset(140,120);preview.Size=UDim2.new(1,-156,0,68);preview.BackgroundColor3=C.panel;preview.BorderSizePixel=0;preview.ZIndex=202;preview.Parent=panel;corner(preview,9);stroke(preview,C.muted,.6)
local previewLabel=text(preview,"PREVIEW",UDim2.fromOffset(10,3),UDim2.new(1,-20,0,18),Enum.Font.GothamBold,8,C.muted);previewLabel.ZIndex=203
local previewText=text(preview,"YOUR TITLE",UDim2.fromOffset(10,22),UDim2.new(1,-20,0,34),Enum.Font.GothamBlack,14,C.white,Enum.TextXAlignment.Center);previewText.ZIndex=203
local save=btn(panel,"SAVE",UDim2.fromOffset(16,202),UDim2.fromOffset(92,38),C.pink);save.ZIndex=204
local equip=btn(panel,"EQUIP",UDim2.fromOffset(119,202),UDim2.fromOffset(92,38),Color3.fromRGB(45,86,72));equip.ZIndex=204
local remove=btn(panel,"REMOVE",UDim2.fromOffset(222,202),UDim2.fromOffset(92,38),Color3.fromRGB(83,38,47));remove.ZIndex=204
local status=text(panel,"TITLE not loaded yet.",UDim2.fromOffset(16,250),UDim2.new(1,-32,0,52),Enum.Font.Gotham,10,C.muted);status.TextWrapped=true;status.TextYAlignment=Enum.TextYAlignment.Top;status.ZIndex=202

local function parseHex(s)
 s=string.upper(tostring(s or "")):gsub("%s+","")
 if not s:match("^#%x%x%x%x%x%x$") then return nil end
 return Color3.fromRGB(tonumber(s:sub(2,3),16),tonumber(s:sub(4,5),16),tonumber(s:sub(6,7),16))
end
local function updatePreview()
 previewText.Text=(titleBox.Text~="" and titleBox.Text or "YOUR TITLE")
 previewText.TextColor3=parseHex(colorBox.Text) or C.white
end
titleBox:GetPropertyChangedSignal("Text"):Connect(function()if utf8.len(titleBox.Text or "") and utf8.len(titleBox.Text)>16 then local out="";local n=0;for _,cp in utf8.codes(titleBox.Text) do if n>=16 then break end;n+=1;out=out..utf8.char(cp) end;titleBox.Text=out end;updatePreview()end)
colorBox:GetPropertyChangedSignal("Text"):Connect(updatePreview)
local function applyResult(r)
 if type(r)~="table" then status.Text="TITLE request failed.";status.TextColor3=C.red;return end
 status.Text=tostring(r.message or "Updated.");status.TextColor3=r.ok and C.green or C.red
 if r.title~=nil then titleBox.Text=tostring(r.title) end;if r.color~=nil then colorBox.Text=tostring(r.color) end;updatePreview()
end
local function loadSnapshot()
 local ok,r=pcall(function()return snapshot:InvokeServer()end);if not ok or type(r)~="table" then status.Text="TITLE data unavailable.";status.TextColor3=C.red;return end
 titleBox.Text=tostring(r.title or "");colorBox.Text=tostring(r.color or "#F3F3F3");status.Text=r.equipped and "Current TITLE is equipped." or (titleBox.Text~="" and "TITLE saved • tap EQUIP to show it." or "Create a TITLE, choose any non-reserved HEX color, then SAVE.");status.TextColor3=C.muted;updatePreview()
end
save.Activated:Connect(function()local ok,r=pcall(function()return action:InvokeServer("save",{text=titleBox.Text,color=colorBox.Text})end);applyResult(ok and r or nil)end)
equip.Activated:Connect(function()local ok,r=pcall(function()return action:InvokeServer("equip",{})end);applyResult(ok and r or nil)end)
remove.Activated:Connect(function()local ok,r=pcall(function()return action:InvokeServer("remove",{})end);applyResult(ok and r or nil)end)
local function closePanel()shade.Visible=false;kernelMenuVisible(true) end
close.Activated:Connect(closePanel)

local menuButton=nil
local function injectMenuButton()
 local menu=pg:FindFirstChild("BBYACommandMenuUI");local drawer=menu and menu:FindFirstChild("FeatureDrawer",true);local list=drawer and drawer:FindFirstChild("FeatureList",true);if not list then return false end
 local existing=list:FindFirstChild("BBYATitleMenuButton");if existing and existing:IsA("TextButton") then menuButton=existing;return true end
 local template=nil;for _,d in ipairs(list:GetChildren()) do if d:IsA("TextButton") then template=d;break end end
 local b=template and template:Clone() or Instance.new("TextButton");b.Name="BBYATitleMenuButton";b.Text="TITLE";b.Visible=true;b.Active=true;b.AutoButtonColor=true
 if not template then b.Size=UDim2.new(1,-8,0,38);b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;corner(b,8) end
 b.Parent=list;b:SetAttribute("BBYAInjectedAuthority","IDENTITY_UI_V1_1");b.Activated:Connect(function()if drawer and drawer:IsA("GuiObject") then drawer.Visible=false end;kernelMenuVisible(false);shade.Visible=true;loadSnapshot()end);menuButton=b;return true
end
pg.ChildAdded:Connect(function(c)if c.Name=="BBYACommandMenuUI" then task.defer(injectMenuButton);task.delay(.2,injectMenuButton) end end)
task.spawn(function()for _=1,40 do if injectMenuButton() then break end;task.wait(.25) end end)

-- Level Up notification: only fired by server when an actual level threshold is crossed.
-- This block is intentionally unchanged except for UI Z-order so TITLE input can never intercept it.
local levelPopup=Instance.new("Frame");levelPopup.AnchorPoint=Vector2.new(.5,0);levelPopup.Position=UDim2.new(.5,0,.14,-120);levelPopup.Size=UDim2.fromOffset(370,94);levelPopup.BackgroundColor3=C.bg;levelPopup.BorderSizePixel=0;levelPopup.Visible=false;levelPopup.ZIndex=300;levelPopup.Parent=gui;corner(levelPopup,16);stroke(levelPopup,C.gold,.20)
local levelAvatar=Instance.new("ImageLabel");levelAvatar.Position=UDim2.fromOffset(14,15);levelAvatar.Size=UDim2.fromOffset(64,64);levelAvatar.BackgroundColor3=C.card;levelAvatar.BorderSizePixel=0;levelAvatar.ScaleType=Enum.ScaleType.Crop;levelAvatar.ZIndex=301;levelAvatar.Parent=levelPopup;corner(levelAvatar,32)
local levelHead=text(levelPopup,"LEVEL UP!",UDim2.fromOffset(94,14),UDim2.new(1,-108,0,27),Enum.Font.GothamBlack,18,C.gold);levelHead.ZIndex=301
local levelText=text(levelPopup,"You reached Level 1",UDim2.fromOffset(94,43),UDim2.new(1,-108,0,23),Enum.Font.GothamBold,13,C.white);levelText.ZIndex=301
local rankText=text(levelPopup,"NEWBIE",UDim2.fromOffset(94,67),UDim2.new(1,-108,0,14),Enum.Font.GothamBold,9,C.cyan);rankText.ZIndex=301
task.spawn(function()local ok,url=pcall(function()return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)end);if ok then levelAvatar.Image=url end end)
local levelToken=0
levelUp.OnClientEvent:Connect(function(data)
 data=type(data)=="table" and data or {};levelToken+=1;local token=levelToken
 levelText.Text="You reached Level "..tostring(data.level or player:GetAttribute("BBYALevel") or "?");rankText.Text=tostring(data.rank or player:GetAttribute("BBYARank") or "")
 levelPopup.Visible=true;levelPopup.Position=UDim2.new(.5,0,.14,-120);TweenService:Create(levelPopup,TweenInfo.new(.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(.5,0,.14,0)}):Play()
 task.delay(4,function()if levelToken~=token then return end;local tw=TweenService:Create(levelPopup,TweenInfo.new(.2),{Position=UDim2.new(.5,0,.14,-120)});tw:Play();tw.Completed:Wait();if levelToken==token then levelPopup.Visible=false end end)
end)

print("[BBYA] Identity UI v1.1 online: TITLE click layer fixed / persistent TITLE actions / level logic preserved")