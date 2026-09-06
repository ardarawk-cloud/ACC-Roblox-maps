-- BBYA SOCIAL HUB — ROLE PANEL v10 CLEAN COMPACT
-- Floating compact panel; no fullscreen backdrop. Same footprint family as Music Player.
-- Persistent role logic remains server-authoritative through RolePanelSnapshot / RolePanelAction.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",25)
local snapshotRemote=remotes and remotes:WaitForChild("RolePanelSnapshot",25)
local actionRemote=remotes and remotes:WaitForChild("RolePanelAction",25)
if not snapshotRemote or not actionRemote then return end
local ok,snapshot=pcall(function()return snapshotRemote:InvokeServer()end)
if not ok or type(snapshot)~="table" or snapshot.authorized~=true then return end

local old=pg:FindFirstChild("BBYARolePanelUI");if old then old:Destroy()end
local gui=Instance.new("ScreenGui");gui.Name="BBYARolePanelUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=245;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("BBYARolePanelAuthority","ROLE_PANEL_V10_CLEAN_COMPACT")
local C={bg=Color3.fromRGB(10,10,14),panel=Color3.fromRGB(20,20,26),card=Color3.fromRGB(31,31,39),line=Color3.fromRGB(72,74,86),white=Color3.fromRGB(248,248,250),muted=Color3.fromRGB(185,187,197),pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(73,207,235),green=Color3.fromRGB(103,230,174),gold=Color3.fromRGB(235,184,74),red=Color3.fromRGB(235,91,104),purple=Color3.fromRGB(174,104,255),orange=Color3.fromRGB(255,151,78)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Transparency=tr or .4;s.Thickness=1;s.Parent=o end
local function text(p,v,pos,size,font,ts,col,align)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=tostring(v or"");t.Position=pos;t.Size=size;t.Font=font or Enum.Font.Gotham;t.TextSize=ts or 11;t.TextColor3=col or C.white;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.TextTruncate=Enum.TextTruncate.AtEnd;t.TextStrokeTransparency=.78;t.Parent=p;return t end
local function button(p,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBlack;b.TextSize=10;b.TextStrokeTransparency=.55;b.AutoButtonColor=true;b.Parent=p;corner(b,9);stroke(b,C.line,.45);return b end
local function kernelMenuVisible(visible)local k=pg:FindFirstChild("BBYACommandMenuUI");local m=k and k:FindFirstChild("MenuButton",true);if m then m.Visible=visible end end

local open=button(gui,"ROLES",UDim2.new(1,-92,0,52),UDim2.fromOffset(78,34),C.panel);open.TextColor3=C.gold;open.Name="RolePanelOpen"
local panel=Instance.new("Frame");panel.Name="RolePanel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.new(.5,0,.5,18);panel.Size=UDim2.fromOffset(420,420);panel.BackgroundColor3=C.bg;panel.BackgroundTransparency=.08;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;corner(panel,16);stroke(panel,C.gold,.28)
text(panel,"BBYA ROLE PANEL",UDim2.fromOffset(16,10),UDim2.new(1,-64,0,26),Enum.Font.GothamBlack,16,C.white)
text(panel,"Persistent staff roles",UDim2.fromOffset(16,34),UDim2.new(1,-64,0,16),Enum.Font.GothamBold,8,C.muted)
local close=button(panel,"×",UDim2.new(1,-44,0,9),UDim2.fromOffset(32,32),C.card);close.TextSize=18

local playerList=Instance.new("ScrollingFrame");playerList.Position=UDim2.fromOffset(12,62);playerList.Size=UDim2.fromOffset(150,346);playerList.BackgroundColor3=C.panel;playerList.BackgroundTransparency=.15;playerList.BorderSizePixel=0;playerList.ScrollBarThickness=2;playerList.AutomaticCanvasSize=Enum.AutomaticSize.Y;playerList.CanvasSize=UDim2.new();playerList.Parent=panel;corner(playerList,11);stroke(playerList,C.line,.55)
local lp=Instance.new("UIPadding");lp.PaddingTop=UDim.new(0,6);lp.PaddingBottom=UDim.new(0,6);lp.PaddingLeft=UDim.new(0,6);lp.PaddingRight=UDim.new(0,6);lp.Parent=playerList
local ll=Instance.new("UIListLayout");ll.Padding=UDim.new(0,5);ll.Parent=playerList

local detail=Instance.new("Frame");detail.Position=UDim2.fromOffset(172,62);detail.Size=UDim2.new(1,-184,1,-74);detail.BackgroundColor3=C.panel;detail.BackgroundTransparency=.15;detail.BorderSizePixel=0;detail.Parent=panel;corner(detail,11);stroke(detail,C.line,.55)
local selectedName=text(detail,"SELECT PLAYER",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,22),Enum.Font.GothamBlack,13,C.white)
local selectedUser=text(detail,"",UDim2.fromOffset(12,28),UDim2.new(1,-24,0,16),Enum.Font.Gotham,8,C.muted)
local currentRole=text(detail,"ROLE —",UDim2.fromOffset(12,47),UDim2.new(1,-24,0,18),Enum.Font.GothamBold,9,C.gold)
local grid=Instance.new("Frame");grid.Position=UDim2.fromOffset(10,76);grid.Size=UDim2.new(1,-20,0,210);grid.BackgroundTransparency=1;grid.Parent=detail
local gl=Instance.new("UIGridLayout");gl.CellPadding=UDim2.fromOffset(6,6);gl.CellSize=UDim2.new(.5,-3,0,45);gl.FillDirectionMaxCells=2;gl.Parent=grid
local roleSpecs={{"COOWNER","CO OWNER",C.orange},{"ADMIN","ADMIN",C.cyan},{"MODERATOR","MODERATOR",C.green},{"DJ","DJ",C.purple},{"LEAD","LEAD",C.red},{"MEDIA","MEDIA",Color3.fromRGB(69,172,255)},{"VIP","VIP",C.gold},{"CREW","CREW",C.green}}
local roleButtons={};for i,s in ipairs(roleSpecs)do local b=button(grid,s[2],nil,UDim2.new(),s[3]);b.LayoutOrder=i;roleButtons[s[1]]=b end
local remove=button(detail,"REMOVE ROLE",UDim2.fromOffset(10,296),UDim2.new(1,-20,0,40),C.red)
local status=text(detail,"Select an online player.",UDim2.fromOffset(12,338),UDim2.new(1,-24,0,18),Enum.Font.GothamBold,8,C.muted)

local selectedUserId=nil;local selectedLocked=false
local function roleColor(r)if r=="OWNER"then return C.pink elseif r=="ADMIN"then return C.cyan elseif r=="CO OWNER"then return C.orange elseif r=="DJ"then return C.purple elseif r=="LEAD"then return C.red elseif r=="MEDIA"then return Color3.fromRGB(69,172,255)elseif r=="VIP"then return C.gold elseif r=="CREW"or r=="MODERATOR"then return C.green end;return C.muted end
local function setSelection(e)
 selectedUserId=e and e.userId or nil;selectedLocked=e and e.locked==true or false;selectedName.Text=e and e.displayName or"SELECT PLAYER";selectedUser.Text=e and("@"..e.username)or"";currentRole.Text=e and("ROLE • "..e.role)or"ROLE —";currentRole.TextColor3=e and roleColor(e.role)or C.gold
 for _,b in pairs(roleButtons)do b.Active=e~=nil and not selectedLocked;b.AutoButtonColor=b.Active;b.TextTransparency=b.Active and 0 or .5 end;remove.Active=e~=nil and not selectedLocked;remove.TextTransparency=remove.Active and 0 or .5;status.Text=selectedLocked and"OWNER role locked."or(e and"Choose a role."or"Select an online player.")
end
local function clearRows()for _,c in ipairs(playerList:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end end
local function render(snap)
 if type(snap)~="table"or snap.authorized~=true then return end;clearRows();local keep=nil
 for i,e in ipairs(snap.players or{})do local row=button(playerList,"",nil,UDim2.new(1,-2,0,48),C.card);row.LayoutOrder=i;local n=text(row,e.displayName,UDim2.fromOffset(8,5),UDim2.new(1,-16,0,18),Enum.Font.GothamBold,10,C.white);local u=text(row,"@"..e.username,UDim2.fromOffset(8,24),UDim2.new(1,-16,0,15),Enum.Font.Gotham,7,C.muted);row.Activated:Connect(function()setSelection(e)end);if selectedUserId==e.userId then keep=e end end
 if keep then setSelection(keep)elseif selectedUserId then setSelection(nil)end
end
local function refresh()local good,s=pcall(function()return snapshotRemote:InvokeServer()end);if good then render(s)end end
local function assign(role)
 if not selectedUserId or selectedLocked then return end;status.Text="Applying...";local good,r=pcall(function()return actionRemote:InvokeServer(selectedUserId,role)end);if not good or type(r)~="table"then status.Text="Role update failed.";return end;status.Text=tostring(r.message or"Updated.");if r.snapshot then render(r.snapshot)else refresh()end
end
for key,b in pairs(roleButtons)do b.Activated:Connect(function()assign(key)end)end;remove.Activated:Connect(function()assign("NONE")end)
local function closePanel()panel.Visible=false;kernelMenuVisible(true);open.Visible=true end
open.Activated:Connect(function()panel.Visible=true;open.Visible=false;kernelMenuVisible(false);refresh()end);close.Activated:Connect(closePanel)
Players.PlayerAdded:Connect(function()if panel.Visible then task.delay(.4,refresh)end end);Players.PlayerRemoving:Connect(function()if panel.Visible then task.delay(.2,refresh)end end)

local function dockLauncher()
 local menu=pg:FindFirstChild("BBYACommandMenuUI");local mb=menu and menu:FindFirstChild("MenuButton",true);if mb and mb:IsA("GuiObject")then if open.Parent~=menu then open.Parent=menu end;open.Position=UDim2.new(mb.Position.X.Scale,mb.Position.X.Offset,mb.Position.Y.Scale,mb.Position.Y.Offset+mb.Size.Y.Offset+8);open.Size=UDim2.fromOffset(78,34);open.Visible=mb.Visible and not panel.Visible end
end
local function layoutPanel()camera=workspace.CurrentCamera or camera;local vp=camera and camera.ViewportSize or Vector2.new(1280,720);local s=math.clamp(math.min(vp.X-28,vp.Y-86),330,430);panel.Size=UDim2.fromOffset(s,s);panel.Position=UDim2.new(.5,0,.5,18)end
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutPanel)end
pg.ChildAdded:Connect(function(c)if c.Name=="BBYACommandMenuUI"then task.defer(dockLauncher);task.delay(.2,dockLauncher)end end)
task.spawn(function()for _=1,40 do dockLauncher();task.wait(.25)end end)
task.defer(function()layoutPanel();render(snapshot);dockLauncher()end)
print("[BBYA] Role Panel v10 online: compact floating / no backdrop / readable role buttons")