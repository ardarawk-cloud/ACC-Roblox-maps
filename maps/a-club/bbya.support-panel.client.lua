-- BBYA Top Supporter mobile panel v1.2
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local rf=RS:WaitForChild("BBYA_Remotes"):WaitForChild("GetSupporterData")

local gui=Instance.new("ScreenGui")
gui.Name="BBYA_SupportPanel";gui.ResetOnSpawn=false;gui.DisplayOrder=29;gui.IgnoreGuiInset=false;gui.Parent=player:WaitForChild("PlayerGui")
local BG=Color3.fromRGB(13,12,19);local CARD=Color3.fromRGB(31,25,39);local PINK=Color3.fromRGB(255,82,205);local GOLD=Color3.fromRGB(255,211,90)
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o)local s=Instance.new("UIStroke");s.Transparency=.55;s.Thickness=1;s.Parent=o end

-- Unified top-right launcher row. Music occupies x=-8, Support sits immediately left of it.
local open=Instance.new("TextButton")
open.Name="SupportButton";open.Size=UDim2.fromOffset(44,44);open.AnchorPoint=Vector2.new(1,0);open.Position=UDim2.new(1,-60,0,8)
open.Text="♛";open.TextSize=21;open.TextColor3=GOLD;open.BackgroundColor3=BG;open.Font=Enum.Font.GothamBlack;open.Parent=gui;corner(open,13);stroke(open)

-- Panel opens from the same corner, directly below the launcher row.
local frame=Instance.new("Frame");frame.AnchorPoint=Vector2.new(1,0);frame.Position=UDim2.new(1,-8,0,58);frame.Size=UDim2.fromOffset(330,420);frame.BackgroundColor3=BG;frame.Visible=false;frame.Parent=gui;corner(frame,16);stroke(frame)
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,-50,0,36);title.Position=UDim2.fromOffset(14,8);title.BackgroundTransparency=1;title.Text="TOP SUPPORTERS";title.TextColor3=GOLD;title.Font=Enum.Font.GothamBlack;title.TextSize=18;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=frame
local close=Instance.new("TextButton");close.Size=UDim2.fromOffset(30,30);close.Position=UDim2.new(1,-38,0,7);close.Text="×";close.TextSize=22;close.TextColor3=Color3.new(1,1,1);close.BackgroundColor3=CARD;close.Parent=frame;corner(close,8)

local selfCard=Instance.new("Frame");selfCard.Size=UDim2.new(1,-24,0,58);selfCard.Position=UDim2.fromOffset(12,48);selfCard.BackgroundColor3=CARD;selfCard.Parent=frame;corner(selfCard,11)
local selfTxt=Instance.new("TextLabel");selfTxt.Size=UDim2.new(1,-16,1,0);selfTxt.Position=UDim2.fromOffset(8,0);selfTxt.BackgroundTransparency=1;selfTxt.Text="YOUR RANK • NEWBIE";selfTxt.TextColor3=PINK;selfTxt.Font=Enum.Font.GothamBold;selfTxt.TextSize=13;selfTxt.TextXAlignment=Enum.TextXAlignment.Left;selfTxt.Parent=selfCard

local podium=Instance.new("Frame");podium.Size=UDim2.new(1,-24,0,120);podium.Position=UDim2.fromOffset(12,116);podium.BackgroundTransparency=1;podium.Parent=frame
local pl=Instance.new("UIListLayout");pl.FillDirection=Enum.FillDirection.Horizontal;pl.Padding=UDim.new(0,7);pl.Parent=podium
local podiumSlots={}
for i=1,3 do
 local c=Instance.new("Frame");c.Size=UDim2.fromOffset(96,116);c.BackgroundColor3=CARD;c.Parent=podium;corner(c,11)
 local img=Instance.new("ImageLabel");img.Size=UDim2.fromOffset(60,60);img.Position=UDim2.new(.5,-30,0,8);img.BackgroundColor3=Color3.fromRGB(45,36,55);img.Parent=c;corner(img,30)
 local txt=Instance.new("TextLabel");txt.Size=UDim2.new(1,-8,0,42);txt.Position=UDim2.fromOffset(4,72);txt.BackgroundTransparency=1;txt.Text="#"..i.."\n—";txt.TextColor3=i==1 and GOLD or Color3.new(1,1,1);txt.Font=Enum.Font.GothamBold;txt.TextSize=10;txt.TextWrapped=true;txt.Parent=c
 podiumSlots[i]={img=img,txt=txt}
end

local scroll=Instance.new("ScrollingFrame");scroll.Size=UDim2.new(1,-24,1,-252);scroll.Position=UDim2.fromOffset(12,244);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=frame
local ll=Instance.new("UIListLayout");ll.Padding=UDim.new(0,6);ll.Parent=scroll
local function clearRows()for _,c in ipairs(scroll:GetChildren())do if c:IsA("Frame")then c:Destroy()end end end
local function row(data)local c=Instance.new("Frame");c.Size=UDim2.new(1,-4,0,44);c.BackgroundColor3=CARD;c.Parent=scroll;corner(c,9);local t=Instance.new("TextLabel");t.Size=UDim2.new(1,-12,1,0);t.Position=UDim2.fromOffset(6,0);t.BackgroundTransparency=1;t.Text=string.format("#%d   %s   •   R$%d",data.rank,data.name,data.amount);t.TextColor3=Color3.new(1,1,1);t.Font=Enum.Font.GothamBold;t.TextSize=11;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=c end
local function refresh()
 local ok,data=pcall(function()return rf:InvokeServer()end);if not ok or typeof(data)~="table" then return end
 if data.self then selfTxt.Text=string.format("YOUR RANK • %s    LV.%d    R$%d",data.self.rankTitle or "NEWBIE",data.self.level or 1,data.self.donated or 0) end
 for i=1,3 do local s=podiumSlots[i];local d=data.rows and data.rows[i];if d then s.txt.Text=string.format("#%d\n%s\nR$%d",d.rank,d.name,d.amount);if d.userId and d.userId>0 then task.spawn(function()local ok2,url=pcall(function()return Players:GetUserThumbnailAsync(d.userId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)end);if ok2 then s.img.Image=url end end)end else s.txt.Text="#"..i.."\n—";s.img.Image="" end end
 clearRows();if data.rows then for i=4,#data.rows do row(data.rows[i]) end end
end
open.Activated:Connect(function()frame.Visible=not frame.Visible;if frame.Visible then refresh()end end)
close.Activated:Connect(function()frame.Visible=false end)
task.spawn(function()while gui.Parent do task.wait(30);if frame.Visible then refresh()end end end)
print("[BBYA] Top Supporter panel v1.2 unified top-right launcher loaded")