-- BBYA Social Hub layout hotfix v1.0
-- Repositions Salon, Duo Photo, and Chill & Talk into one clean social corner.

task.wait(2)

local function setCF(name, cf)
 local o=workspace:FindFirstChild(name,true)
 if o and o:IsA("BasePart") then o.CFrame=cf end
 return o
end

-- SALON: move hard into far-right corner, away from main traffic.
setCF("BBYA Salon Counter", CFrame.new(79,2.75,34)*CFrame.Angles(0,math.rad(-90),0))
setCF("BBYA Salon Sign", CFrame.new(74.4,5.8,34)*CFrame.Angles(0,math.rad(-90),0))
setCF("Salon Reset", CFrame.new(79,1,25))

-- DUO PHOTO: place beside salon as a dedicated photo nook.
setCF("Duo Photo Wall", CFrame.new(79,5,6)*CFrame.Angles(0,math.rad(-90),0))
setCF("Duo Photo Stage", CFrame.new(74.6,.85,6)*CFrame.Angles(0,math.rad(-90),0))
setCF("Duo Camera Marker", CFrame.new(66,.7,6)*CFrame.Angles(0,math.rad(-90),0))

local duoSeats={}
for _,o in ipairs(workspace:GetDescendants()) do
 if o:IsA("Seat") and o.Name=="Duo Photo Seat" then table.insert(duoSeats,o) end
end
table.sort(duoSeats,function(a,b)return a:GetFullName()<b:GetFullName()end)
if duoSeats[1] then duoSeats[1].CFrame=CFrame.new(74.5,1.65,3.3)*CFrame.Angles(0,math.rad(-90),0) end
if duoSeats[2] then duoSeats[2].CFrame=CFrame.new(74.5,1.65,8.7)*CFrame.Angles(0,math.rad(-90),0) end

-- CHILL & TALK: compact lounge between main club and the salon/photo corner.
local chillTable=workspace:FindFirstChild("Chill Table",true)
if chillTable and chillTable:IsA("BasePart") then chillTable.CFrame=CFrame.new(52,2,18) end
local chillSign=workspace:FindFirstChild("Chill Sign",true)
if chillSign and chillSign:IsA("BasePart") then chillSign.CFrame=CFrame.new(52,6,10) end

local chillSeats={}
for _,o in ipairs(workspace:GetDescendants()) do
 if o:IsA("Seat") and o.Name=="Chill Seat" then table.insert(chillSeats,o) end
end
local center=Vector3.new(52,2,18)
for i,s in ipairs(chillSeats) do
 local a=((i-1)/math.max(#chillSeats,1))*math.pi*2
 local pos=center+Vector3.new(math.cos(a)*8,0,math.sin(a)*8)
 s.CFrame=CFrame.new(pos,center)*CFrame.Angles(0,math.pi,0)
end

-- Keep the whole social corner clean by disabling collisions on signs/markers.
for _,name in ipairs({"BBYA Salon Sign","Duo Photo Wall","Duo Camera Marker","Chill Sign"}) do
 local o=workspace:FindFirstChild(name,true)
 if o and o:IsA("BasePart") then o.CanCollide=false end
end

print("[BBYA] Layout hotfix: Salon corner + Duo Photo + Chill & Talk regrouped")
