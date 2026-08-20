-- ACC Mountain Master v3.0 — compact expedition HUD
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui"); gui.Name="ACC_MountainVitals"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local frame=Instance.new("Frame"); frame.Name="Vitals"; frame.AnchorPoint=Vector2.new(0,1); frame.Position=UDim2.new(0,14,1,-18); frame.Size=UDim2.new(0,224,0,138); frame.BackgroundColor3=Color3.fromRGB(18,22,24); frame.BackgroundTransparency=.22; frame.BorderSizePixel=0; frame.Parent=gui
local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,10); corner.Parent=frame
local padding=Instance.new("UIPadding"); padding.PaddingTop=UDim.new(0,8); padding.PaddingBottom=UDim.new(0,8); padding.PaddingLeft=UDim.new(0,10); padding.PaddingRight=UDim.new(0,10); padding.Parent=frame
local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,4); layout.Parent=frame
local zone=Instance.new("TextLabel"); zone.Name="Zone"; zone.Size=UDim2.new(1,0,0,20); zone.BackgroundTransparency=1; zone.Font=Enum.Font.GothamBold; zone.TextSize=13; zone.TextXAlignment=Enum.TextXAlignment.Left; zone.TextColor3=Color3.fromRGB(245,245,240); zone.Parent=frame
local rows={}; local names={"Stamina","Hydration","Hunger","Temperature","Oxygen"}
for _,name in ipairs(names) do
 local row=Instance.new("Frame"); row.Name=name; row.Size=UDim2.new(1,0,0,17); row.BackgroundTransparency=1; row.Parent=frame
 local label=Instance.new("TextLabel"); label.Size=UDim2.new(0,78,1,0); label.BackgroundTransparency=1; label.Font=Enum.Font.Gotham; label.TextSize=11; label.TextXAlignment=Enum.TextXAlignment.Left; label.TextColor3=Color3.fromRGB(225,228,229); label.Text=name; label.Parent=row
 local back=Instance.new("Frame"); back.Position=UDim2.new(0,82,.5,-3); back.Size=UDim2.new(1,-82,0,6); back.BackgroundColor3=Color3.fromRGB(55,60,62); back.BorderSizePixel=0; back.Parent=row
 local fill=Instance.new("Frame"); fill.Name="Fill"; fill.Size=UDim2.new(1,0,1,0); fill.BackgroundColor3=Color3.fromRGB(218,221,212); fill.BorderSizePixel=0; fill.Parent=back; rows[name]=fill
end
local function refresh()
 zone.Text=string.format("%s  •  %dm",player:GetAttribute("AltitudeZone") or "BASE",player:GetAttribute("Altitude") or 0)
 for _,name in ipairs(names) do local value=math.clamp(player:GetAttribute(name) or 100,0,100); rows[name].Size=UDim2.new(value/100,0,1,0); rows[name].BackgroundTransparency=value<20 and .05 or .15 end
end
for _,name in ipairs(names) do player:GetAttributeChangedSignal(name):Connect(refresh) end
player:GetAttributeChangedSignal("AltitudeZone"):Connect(refresh); player:GetAttributeChangedSignal("Altitude"):Connect(refresh); refresh()
