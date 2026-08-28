local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")

-- TRACK 01 v3.8 social + interaction polish.
-- No uploaded assets/audio. All interaction points stay outside the protected carriage aisle.
local deadline=os.clock()+60
repeat task.wait(0.15) until (Workspace:GetAttribute("ACC_TRACK01_TICKET_ACCESS_READY") and Workspace:GetAttribute("ACC_TRACK01_ATMOSPHERE_READY")) or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end

local old=world:FindFirstChild("TRACK01_Social_v38")
if old then old:Destroy() end
local social=Instance.new("Folder")
social.Name="TRACK01_Social_v38"
social.Parent=world

local seating=Instance.new("Folder"); seating.Name="UsableSeating"; seating.Parent=social
local tables=Instance.new("Folder"); tables.Name="StandingTables"; tables.Parent=social
local bar=Instance.new("Folder"); bar.Name="CosmeticBar"; bar.Parent=social
local dance=Instance.new("Folder"); dance.Name="DanceZones"; dance.Parent=social
local photos=Instance.new("Folder"); photos.Name="PhotoSpots"; photos.Parent=social

local C={
    black=Color3.fromRGB(17,18,18),
    charcoal=Color3.fromRGB(31,31,30),
    steel=Color3.fromRGB(92,92,88),
    steel2=Color3.fromRGB(119,116,106),
    upholstery=Color3.fromRGB(62,45,42),
    cream=Color3.fromRGB(176,157,119),
    amber=Color3.fromRGB(235,153,72),
    red=Color3.fromRGB(156,43,38),
    glass=Color3.fromRGB(184,126,67),
}

local function cf(x,y,z,ry)
    return CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(ry or 0),0)
end

local function part(parent,name,size,frame,color,material,transparency,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color or C.steel
    p.Material=material or Enum.Material.Metal
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=collide==true
    p.CanTouch=false
    p.CanQuery=true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function prompt(parent,action,objectText,distance)
    local p=Instance.new("ProximityPrompt")
    p.Name="SocialPrompt"
    p.ActionText=action
    p.ObjectText=objectText
    p.HoldDuration=0
    p.MaxActivationDistance=distance or 7
    p.RequiresLineOfSight=false
    p.KeyboardKeyCode=Enum.KeyCode.E
    p.GamepadKeyCode=Enum.KeyCode.ButtonX
    p.Parent=parent
    return p
end

local function hasTicket(player)
    return player:GetAttribute("TRACK01_TICKET")==true
end

local function notify(player,kind,text)
    player:SetAttribute("TRACK01_SOCIAL_KIND",kind)
    player:SetAttribute("TRACK01_SOCIAL_TEXT",text)
    player:SetAttribute("TRACK01_SOCIAL_TOKEN",(player:GetAttribute("TRACK01_SOCIAL_TOKEN") or 0)+1)
end

local function denyTicket(player,car)
    player:SetAttribute("TRACK01_ACCESS_DENIED_CAR",car or 1)
    player:SetAttribute("TRACK01_ACCESS_DENIED_TOKEN",(player:GetAttribute("TRACK01_ACCESS_DENIED_TOKEN") or 0)+1)
end

-- CAR 01: real usable seats on the left wall, safely outside x=18.85..25.15 aisle keep-clear band.
for i,z in ipairs({-70,-58,-46}) do
    local seat=Instance.new("Seat")
    seat.Name=string.format("Car01UsableSeat%02d",i)
    seat.Size=Vector3.new(3.0,0.65,3.4)
    seat.CFrame=cf(16.45,5.55,z,-90)
    seat.Color=C.upholstery
    seat.Material=Enum.Material.Fabric
    seat.Anchored=true
    seat.CanCollide=true
    seat.CanTouch=false
    seat.CanQuery=true
    seat.Parent=seating

    local back=part(seating,"Car01SeatBack",Vector3.new(0.65,3.2,3.4),cf(15.25,7.0,z),C.upholstery,Enum.Material.Fabric,0,false)
    local sitPrompt=prompt(back,"SIT","CAR 01 • SOCIAL SEAT",6)
    sitPrompt.Triggered:Connect(function(player)
        if not hasTicket(player) then denyTicket(player,1); return end
        local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            seat:Sit(humanoid)
            notify(player,"SEAT","CAR 01 • SOCIAL SEAT")
        end
    end)
end

-- The Yard: make the existing salvage benches actually usable without changing their appearance.
for i,spec in ipairs({{-58,58,0},{-43,58,180},{-58,78,0},{-43,78,180}}) do
    local x,z,ry=spec[1],spec[2],spec[3]
    local seat=Instance.new("Seat")
    seat.Name=string.format("YardBenchSeat%02d",i)
    seat.Size=Vector3.new(7.4,0.45,1.8)
    seat.CFrame=cf(x,2.88,z,ry)
    seat.Transparency=1
    seat.Anchored=true
    seat.CanCollide=false
    seat.CanTouch=false
    seat.CanQuery=true
    seat.Parent=seating
    local sitPrompt=prompt(seat,"SIT","THE YARD • RAILWAY BENCH",7)
    sitPrompt.Triggered:Connect(function(player)
        local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            seat:Sit(humanoid)
            notify(player,"SEAT","THE YARD • RAILWAY BENCH")
        end
    end)
end

-- CAR 02: narrow standing tables against the left wall, never across the central aisle.
for i,z in ipairs({-14,0,14}) do
    local base=part(tables,string.format("Car02StandingTable%02d",i),Vector3.new(3.1,0.28,3.1),cf(16.55,8.8,z),C.charcoal,Enum.Material.Metal,0,false)
    base.Shape=Enum.PartType.Cylinder
    base.CFrame=cf(16.55,8.8,z)*CFrame.Angles(0,0,math.rad(90))
    local stem=part(tables,"StandingTableStem",Vector3.new(3.5,0.28,0.28),cf(16.55,7.0,z),C.steel2,Enum.Material.Metal,0,false)
    stem.Shape=Enum.PartType.Cylinder
    stem.CFrame=cf(16.55,7.0,z)*CFrame.Angles(0,0,math.rad(90))
    local p=prompt(base,"SOCIAL SPOT","CAR 02 • STANDING TABLE",6)
    p.Triggered:Connect(function(player)
        if not hasTicket(player) then denyTicket(player,2); return end
        notify(player,"SOCIAL","CAR 02 • STANDING TABLE")
    end)
end

-- Cosmetic bar pickup: one drink per player, no stats, buffs, currency or gameplay effect.
local tray=part(bar,"NightDrinkTray",Vector3.new(3.2,0.22,5.0),cf(27.0,9.1,12),C.charcoal,Enum.Material.Metal,0,false)
for i,dz in ipairs({-1.6,-0.55,0.55,1.6}) do
    local glass=part(bar,"DisplayDrink",Vector3.new(0.95,0.62,0.62),cf(26.75,9.8,12+dz),C.glass,Enum.Material.Glass,0.28,false)
    glass.Shape=Enum.PartType.Cylinder
    glass.CFrame=cf(26.75,9.8,12+dz)*CFrame.Angles(0,0,math.rad(90))
end
local drinkPrompt=prompt(tray,"TAKE DRINK","CAR 02 • NIGHT DRINK",6)
drinkPrompt.Triggered:Connect(function(player)
    if not hasTicket(player) then denyTicket(player,2); return end
    local backpack=player:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    local oldTool=backpack:FindFirstChild("TRACK01 Night Drink") or (player.Character and player.Character:FindFirstChild("TRACK01 Night Drink"))
    if oldTool then oldTool:Destroy() end
    local tool=Instance.new("Tool")
    tool.Name="TRACK01 Night Drink"
    tool.ToolTip="Cosmetic only • TRACK 01"
    tool.CanBeDropped=false
    tool.RequiresHandle=true
    tool:SetAttribute("TRACK01_COSMETIC",true)
    local handle=Instance.new("Part")
    handle.Name="Handle"
    handle.Size=Vector3.new(0.95,0.62,0.62)
    handle.Shape=Enum.PartType.Cylinder
    handle.Color=C.glass
    handle.Material=Enum.Material.Glass
    handle.Transparency=0.18
    handle.CanCollide=false
    handle.CanTouch=false
    handle.CanQuery=false
    handle.Massless=true
    handle.Parent=tool
    tool.Parent=backpack
    notify(player,"DRINK","NIGHT DRINK • COSMETIC ONLY")
end)

-- CAR 03: two wall-side dance prompts. Uses Roblox's default dance emote when available.
for i,x in ipairs({16.1,27.9}) do
    local marker=part(dance,string.format("Car03DanceZone%02d",i),Vector3.new(0.28,2.2,5.4),cf(x,7.0,48),i==1 and C.amber or C.red,Enum.Material.Neon,0.42,false)
    local p=prompt(marker,"DANCE","CAR 03 • DANCE ZONE",7)
    p.Triggered:Connect(function(player)
        if not hasTicket(player) then denyTicket(player,3); return end
        local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then pcall(function() humanoid:PlayEmote("dance") end) end
        notify(player,"DANCE","CAR 03 • DANCE ZONE")
    end)
end

-- THE YARD photo spot: uses the existing railway photo wall; marker stays clear of the wall and circulation.
local photoMarker=part(photos,"YardPhotoSpot",Vector3.new(4.0,0.10,4.0),cf(-68.2,0.48,74),C.amber,Enum.Material.Neon,0.55,false)
photoMarker.CanQuery=false
local photoPromptAnchor=part(photos,"YardPhotoPrompt",Vector3.new(0.45,2.8,0.45),cf(-68.2,2.0,74),C.steel,Enum.Material.Metal,0.65,false)
local photoPrompt=prompt(photoPromptAnchor,"PHOTO MODE","THE YARD • PHOTO WALL",7)
photoPrompt.Triggered:Connect(function(player)
    notify(player,"PHOTO","THE YARD • NO DESTINATION. JUST THE NIGHT.")
end)

for _,player in ipairs(Players:GetPlayers()) do
    if player:GetAttribute("TRACK01_SOCIAL_TOKEN")==nil then player:SetAttribute("TRACK01_SOCIAL_TOKEN",0) end
end
Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("TRACK01_SOCIAL_TOKEN",0)
end)

root:SetAttribute("SocialInteractionVersion","3.8.0")
Workspace:SetAttribute("ACC_TRACK01_SOCIAL_READY",true)
print("[TRACK 01] social + interaction polish ready v3.8.0")
