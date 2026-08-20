-- BECAK E-BIKE — masterplan client v1.2
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local player=Players.LocalPlayer
local playerGui=player:WaitForChild('PlayerGui')

local gui=Instance.new('ScreenGui')
gui.Name='BecakMasterplanHUD';gui.ResetOnSpawn=false;gui.Parent=playerGui
local panel=Instance.new('Frame')
panel.AnchorPoint=Vector2.new(1,0);panel.Position=UDim2.new(.98,0,.03,0);panel.Size=UDim2.new(.34,0,0,118);panel.BackgroundColor3=Color3.fromRGB(15,20,24);panel.BackgroundTransparency=.12;panel.Parent=gui
local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,14);corner.Parent=panel
local function line(y,text,size)
 local t=Instance.new('TextLabel');t.Position=UDim2.new(.05,0,0,y);t.Size=UDim2.new(.9,0,0,size or 24);t.BackgroundTransparency=1;t.TextColor3=Color3.new(1,1,1);t.Font=Enum.Font.GothamBold;t.TextSize=14;t.TextXAlignment=Enum.TextXAlignment.Left;t.Text=text;t.Parent=panel;return t
end
local weather=line(8,'CUACA: CERAH',22)
local story=line(32,'STORY: CHAPTER 1',22)
local cargo=line(56,'CARGO: —',22)
local challenge=line(80,'TARGET SESI: 0/10 TRIP',28)

local function refresh()
 weather.Text='CUACA: '..tostring(Workspace:GetAttribute('BecakWeather') or 'CERAH')
 story.Text='STORY: CHAPTER '..tostring(player:GetAttribute('StoryChapter') or 1)
 local c=player:GetAttribute('CargoDestination');cargo.Text=c and ('CARGO: '..c) or 'CARGO: —'
 challenge.Text='TARGET SESI: '..tostring(player:GetAttribute('SessionTrips') or 0)..'/10 TRIP'
end
for _,name in ipairs({'StoryChapter','CargoDestination','SessionTrips'}) do player:GetAttributeChangedSignal(name):Connect(refresh) end
Workspace:GetAttributeChangedSignal('BecakWeather'):Connect(refresh)
refresh()
