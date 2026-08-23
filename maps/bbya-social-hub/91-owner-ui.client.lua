-- BBYA SOCIAL HUB — OWNER UI COMPATIBILITY + ROLE PANEL v7
-- Keeps existing panels mobile-safe and exposes a compact role manager only to authorized owner/admin accounts.
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local function scaleFor(parent,name,value)
 local s=parent:FindFirstChild(name)
 if not s or not s:IsA("UIScale") then if s then s:Destroy() end;s=Instance.new("UIScale");s.Name=name;s.Parent=parent end
 s.Scale=value
end
local function lift(o)
 if not o or not o:IsA("GuiObject") then return end
 o.ZIndex=math.max(o.ZIndex,100)
 if o:IsA("ScrollingFrame") then o.Active=true;o.ScrollingEnabled=true;o.ScrollBarThickness=3 end
end
local function stabilize()
 local old=pg:FindFirstChild("BBYAUnifiedMenuUI");if old then old:Destroy() end
 camera=workspace.CurrentCamera or camera
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local touch=UserInputService.TouchEnabled
 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 if social then
  local sc=touch and math.clamp(math.min(vp.X/720,vp.Y/520),.56,.78) or .82
  for _,name in ipairs({"DancePanel","CarryPanel"}) do
   local p=social:FindFirstChild(name)
   if p and p:IsA("Frame") then
    p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale(.5,.55);p.Size=UDim2.fromOffset(390,390);p.ClipsDescendants=true;p.ZIndex=100
    scaleFor(p,"BBYAOwnerPanelScaleV7",sc);for _,d in ipairs(p:GetDescendants()) do lift(d) end
   end
  end
 end
 local clubUI=pg:FindFirstChild("BBYAClubUI")
 local shade=clubUI and clubUI:FindFirstChild("CommunityOverlay")
 local p=shade and shade:FindFirstChild("CommunityPanel")
 if p and p:IsA("Frame") then
  local sc=touch and math.clamp(math.min(vp.X/760,vp.Y/600),.58,.76) or .86
  p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale(.5,.54);p.Size=UDim2.fromOffset(560,480);p.ZIndex=81;scaleFor(p,"BBYAOwnerCommunityScaleV7",sc)
 end
end

task.defer(stabilize)
pg.ChildAdded:Connect(function()task.defer(stabilize)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(stabilize)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(stabilize)end) end

-- ROLE PANEL ------------------------------------------------------------------
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",25)
local snapshotRemote=remotes and remotes:WaitForChild("RolePanelSnapshot",25)
local actionRemote=remotes and remotes:WaitForChild("RolePanelAction",25)
if not snapshotRemote or not actionRemote then
 warn("[BBYA Role Panel] remotes unavailable")
 return
end

local ok,snapshot=pcall(function()return snapshotRemote:InvokeServer()end)
if not ok or type(snapshot)~="table" or snapshot.authorized~=true then
 print("[BBYA] Role Panel hidden: account is not an authorized owner/admin")
 return
end

local oldRoleUI=pg:FindFirstChild("BBYARolePanelUI");if oldRoleUI then oldRoleUI:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="BBYARolePanelUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.DisplayOrder=145;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg

local C={bg=Color3.fromRGB(13,13,17),panel=Color3.fromRGB(21,21,27),panel2=Color3.fromRGB(29,29,37),stroke=Color3.fromRGB(64,64,76),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(166,168,178),pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(73,207,235),green=Color3.fromRGB(103,230,174),gold=Color3.fromRGB(235,184,74),red=Color3.fromRGB(235,91,104)}
local function corner(parent,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=parent end
local function stroke(parent,color,trans)local s=Instance.new("UIStroke");s.Color=color or C.stroke;s.Transparency=trans or 0;s.Thickness=1;s.Parent=parent end
local function text(parent,name,textValue,size,pos,font,textSize,color,align)
 local t=Instance.new("TextLabel");t.Name=name;t.BackgroundTransparency=1;t.Text=textValue;t.Size=size;t.Position=pos;t.Font=font or Enum.Font.GothamMedium;t.TextSize=textSize or 13;t.TextColor3=color or C.white;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextTruncate=Enum.TextTruncate.AtEnd;t.Parent=parent;return t
end
local function button(parent,name,label,size,pos,color)
 local b=Instance.new("TextButton");b.Name=name;b.Text=label;b.Size=size;b.Position=pos;b.AutoButtonColor=true;b.BackgroundColor3=color or C.panel2;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=12;b.BorderSizePixel=0;b.Parent=parent;corner(b,8);stroke(b,C.stroke,.35);return b
end

local open=button(gui,"RolePanelOpen","ROLES",UDim2.fromOffset(78,34),UDim2.new(1,-92,0,82),C.panel)
open.AnchorPoint=Vector2.new(0,0);open.TextColor3=C.gold;open.ZIndex=150

local shade=Instance.new("Frame");shade.Name="Shade";shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.38;shade.Visible=false;shade.BorderSizePixel=0;shade.ZIndex=150;shade.Parent=gui
local panel=Instance.new("Frame");panel.Name="RolePanel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.52);panel.Size=UDim2.fromOffset(520,390);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.ZIndex=151;panel.Parent=shade;corner(panel,12);stroke(panel,C.stroke,.08)
local panelScale=Instance.new("UIScale");panelScale.Name="ResponsiveScale";panelScale.Parent=panel

text(panel,"Title","BBYA ROLE PANEL",UDim2.fromOffset(300,26),UDim2.fromOffset(18,13),Enum.Font.GothamBlack,18,C.white)
text(panel,"SubTitle","Online role management • persistent after rejoin",UDim2.fromOffset(380,18),UDim2.fromOffset(18,39),Enum.Font.Gotham,11,C.muted)
local close=button(panel,"Close","×",UDim2.fromOffset(34,30),UDim2.new(1,-46,0,12),C.panel2);close.TextSize=20
local divider=Instance.new("Frame");divider.Size=UDim2.new(1,-32,0,1);divider.Position=UDim2.fromOffset(16,65);divider.BackgroundColor3=C.stroke;divider.BackgroundTransparency=.35;divider.BorderSizePixel=0;divider.ZIndex=152;divider.Parent=panel

text(panel,"PlayersLabel","ONLINE PLAYERS",UDim2.fromOffset(200,18),UDim2.fromOffset(16,78),Enum.Font.GothamBold,11,C.muted)
local list=Instance.new("ScrollingFrame");list.Name="PlayerList";list.Position=UDim2.fromOffset(16,100);list.Size=UDim2.fromOffset(225,270);list.BackgroundColor3=C.panel;list.BorderSizePixel=0;list.ScrollBarThickness=3;list.ScrollBarImageColor3=C.gold;list.CanvasSize=UDim2.new();list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.ZIndex=152;list.Parent=panel;corner(list,9);stroke(list,C.stroke,.35)
local padding=Instance.new("UIPadding");padding.PaddingTop=UDim.new(0,7);padding.PaddingBottom=UDim.new(0,7);padding.PaddingLeft=UDim.new(0,7);padding.PaddingRight=UDim.new(0,7);padding.Parent=list
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,6);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list

local detail=Instance.new("Frame");detail.Name="RoleDetail";detail.Position=UDim2.fromOffset(253,78);detail.Size=UDim2.fromOffset(251,292);detail.BackgroundColor3=C.panel;detail.BorderSizePixel=0;detail.ZIndex=152;detail.Parent=panel;corner(detail,9);stroke(detail,C.stroke,.35)
local selectedName=text(detail,"SelectedName","Select a player",UDim2.new(1,-24,0,25),UDim2.fromOffset(12,14),Enum.Font.GothamBold,15,C.white)
local selectedUser=text(detail,"SelectedUser","",UDim2.new(1,-24,0,18),UDim2.fromOffset(12,40),Enum.Font.Gotham,11,C.muted)
local currentRole=text(detail,"CurrentRole","ROLE —",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,66),Enum.Font.GothamBold,12,C.gold)
local rule=text(detail,"Rule","VIP: VIP access\nCREW: VIP + Rooftop + staff\nADMIN: full bypass + panel access",UDim2.new(1,-24,0,54),UDim2.fromOffset(12,94),Enum.Font.Gotham,10,C.muted);rule.TextWrapped=true;rule.TextYAlignment=Enum.TextYAlignment.Top

local vip=button(detail,"VIP","VIP",UDim2.fromOffset(108,36),UDim2.fromOffset(12,158),C.gold)
local crew=button(detail,"CREW","CREW",UDim2.fromOffset(108,36),UDim2.fromOffset(131,158),C.green)
local admin=button(detail,"ADMIN","ADMIN",UDim2.fromOffset(108,36),UDim2.fromOffset(12,202),C.cyan)
local remove=button(detail,"REMOVE","REMOVE",UDim2.fromOffset(108,36),UDim2.fromOffset(131,202),C.red)
local status=text(detail,"Status","Select an online player.",UDim2.new(1,-24,0,36),UDim2.fromOffset(12,248),Enum.Font.Gotham,10,C.muted);status.TextWrapped=true

local selectedUserId=nil
local selectedLocked=false
local currentSnapshot=snapshot

local function roleColor(role)
 if role=="OWNER" then return C.pink elseif role=="ADMIN" then return C.cyan elseif role=="CREW" then return C.green elseif role=="VIP" then return C.gold end
 return C.muted
end
local function setSelection(entry)
 selectedUserId=entry and entry.userId or nil;selectedLocked=entry and entry.locked==true or false
 selectedName.Text=entry and entry.displayName or "Select a player"
 selectedUser.Text=entry and ("@"..entry.username) or ""
 currentRole.Text=entry and ("ROLE • "..entry.role) or "ROLE —";currentRole.TextColor3=entry and roleColor(entry.role) or C.gold
 local disabled=not entry or selectedLocked
 for _,b in ipairs({vip,crew,admin,remove}) do b.Active=not disabled;b.AutoButtonColor=not disabled;b.TextTransparency=disabled and .55 or 0 end
 if selectedLocked then status.Text="OWNER is locked and cannot be changed.";status.TextColor3=C.pink elseif entry then status.Text="Choose a role for this player.";status.TextColor3=C.muted else status.Text="Select an online player.";status.TextColor3=C.muted end
end

local function clearRows()
 for _,child in ipairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
end
local function renderSnapshot(snap)
 if type(snap)~="table" or snap.authorized~=true then return end
 currentSnapshot=snap;clearRows()
 local keepSelection=nil
 for i,entry in ipairs(snap.players or {}) do
  local row=button(list,"P_"..tostring(entry.userId),"",UDim2.new(1,0,0,49),UDim2.new(),C.panel2);row.LayoutOrder=i;row.ZIndex=153
  local n=text(row,"Name",entry.displayName,UDim2.new(1,-78,0,18),UDim2.fromOffset(9,7),Enum.Font.GothamSemibold,12,C.white)
  local u=text(row,"User","@"..entry.username,UDim2.new(1,-78,0,15),UDim2.fromOffset(9,26),Enum.Font.Gotham,9,C.muted)
  local r=text(row,"Role",entry.role,UDim2.fromOffset(64,18),UDim2.new(1,-71,0,15),Enum.Font.GothamBold,9,roleColor(entry.role),Enum.TextXAlignment.Right)
  n.ZIndex=154;u.ZIndex=154;r.ZIndex=154
  row.Activated:Connect(function()setSelection(entry)end)
  if selectedUserId==entry.userId then keepSelection=entry end
 end
 if keepSelection then setSelection(keepSelection) elseif selectedUserId then setSelection(nil) end
end

local function refresh()
 local good,snap=pcall(function()return snapshotRemote:InvokeServer()end)
 if good then renderSnapshot(snap) end
end
local function assign(role)
 if not selectedUserId or selectedLocked then return end
 status.Text="Applying "..role.."...";status.TextColor3=C.muted
 local good,result=pcall(function()return actionRemote:InvokeServer(selectedUserId,role)end)
 if not good or type(result)~="table" then status.Text="Role update failed.";status.TextColor3=C.red;return end
 status.Text=tostring(result.message or (result.ok and "Updated." or "Denied."));status.TextColor3=result.ok and C.green or C.red
 if result.snapshot then renderSnapshot(result.snapshot) else refresh() end
end
vip.Activated:Connect(function()assign("VIP")end)
crew.Activated:Connect(function()assign("CREW")end)
admin.Activated:Connect(function()assign("ADMIN")end)
remove.Activated:Connect(function()assign("NONE")end)
open.Activated:Connect(function()shade.Visible=true;refresh()end)
close.Activated:Connect(function()shade.Visible=false end)
shade.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Enum.KeyCode.Escape then shade.Visible=false end end)
Players.PlayerAdded:Connect(function()if shade.Visible then task.delay(.5,refresh)end end)
Players.PlayerRemoving:Connect(function()if shade.Visible then task.delay(.2,refresh)end end)

local function resizeRolePanel()
 camera=workspace.CurrentCamera or camera
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local scale=math.clamp(math.min(vp.X/590,vp.Y/470),.62,1)
 if not UserInputService.TouchEnabled then scale=math.clamp(scale,.82,1) end
 panelScale.Scale=scale
 open.Position=UDim2.new(1,-92,0,UserInputService.TouchEnabled and 70 or 82)
end
resizeRolePanel()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeRolePanel) end
renderSnapshot(snapshot);setSelection(nil)

print("[BBYA] Owner UI v7 online: compact persistent Role Panel enabled for authorized OWNER/ADMIN including @nadmo97")
