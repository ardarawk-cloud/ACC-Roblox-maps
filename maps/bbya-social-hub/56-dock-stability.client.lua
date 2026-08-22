-- BBYA SOCIAL HUB — SIX TAB DOCK STABILITY v2
-- Final layout authority for BBYA / MUSIC / SUPPORT / TRAVEL / MESSAGE / COMMUNITY.
-- v2: mobile dock sits below Roblox CoreGui chat area, keeps BBYA visible,
-- and never overwrites CLUB / UNDERGROUND / FUNKOT venue labels.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local gui=pg:WaitForChild("BBYAClubUI",20)
if not gui then return end
local dock=gui:WaitForChild("TopDock",20)
if not dock then return end

local function findButton(word)
 word=word:upper()
 for _,obj in ipairs(dock:GetChildren()) do
  if obj:IsA("TextButton") and tostring(obj.Text):upper():find(word,1,true) then return obj end
 end
end
local function findMusicButton()
 return findButton("MUSIC") or findButton("CLUB") or findButton("UNDERGROUND") or findButton("FUNKOT")
end

local function layout()
 camera=workspace.CurrentCamera or camera
 if not camera then return false end
 local brand=findButton("BBYA")
 local music=findMusicButton()
 local support=findButton("SUPPORT")
 local travel=findButton("TRAVEL")
 local message=dock:FindFirstChild("MessageTab") or findButton("MESSAGE")
 local community=dock:FindFirstChild("CommunityTab") or findButton("COMM")
 if not (brand and music and support and travel and message and community) then return false end

 local vp=camera.ViewportSize
 local touchLandscape=UserInputService.TouchEnabled and vp.X>vp.Y
 local width=math.clamp(vp.X*.62,520,960)
 local topY=UserInputService.TouchEnabled and 66 or 14
 dock.AnchorPoint=Vector2.new(.5,0)
 dock.Position=UDim2.new(touchLandscape and .59 or .5,0,0,topY)
 dock.Size=UDim2.fromOffset(width,52)

 local pad=6
 local gap=4
 local brandW=math.clamp(width*.105,48,72)
 local each=(width-pad*2-brandW-gap*5)/5
 local x=pad
 local function place(btn,w)
  btn.Position=UDim2.fromOffset(x,6)
  btn.Size=UDim2.fromOffset(w,40)
  btn.Visible=true
  btn.Active=true
  x+=w+gap
 end
 place(brand,brandW)
 place(music,each)
 place(support,each)
 place(travel,each)
 place(message,each)
 place(community,each)

 brand.ZIndex=96
 local compact=width<760
 brand.TextSize=compact and 9 or 11
 music.TextSize=compact and 8 or 11
 support.Text=compact and "SUPPORT" or "◇  SUPPORT";support.TextSize=compact and 8 or 11
 travel.Text=compact and "TRAVEL" or "⌖  TRAVEL";travel.TextSize=compact and 8 or 11
 message.Text=compact and "MESSAGE" or "✦  MESSAGE";message.TextSize=compact and 8 or 11
 community.Text=compact and "COMM" or "◆  COMMUNITY";community.TextSize=compact and 8 or 11

 for _,obj in ipairs(dock:GetChildren()) do
  if obj:IsA("Frame") then
   for _,d in ipairs(obj:GetDescendants()) do
    if d:IsA("TextLabel") and tostring(d.Text):upper():find("CLUB LIVE",1,true) then obj.Visible=false end
   end
  end
 end
 return true
end

for _=1,40 do if layout() then break end;task.wait(.15) end
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(layout)end) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 task.defer(layout)
 if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(layout)end) end
end)
dock.ChildAdded:Connect(function()task.defer(layout)end)

task.spawn(function()
 while dock.Parent do
  task.wait(.75)
  layout()
 end
end)

print("[BBYA] Six-tab dock stability v2 online: mobile chat-safe / venue labels preserved")
