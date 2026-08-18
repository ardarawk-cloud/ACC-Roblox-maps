-- BBYA Social Hub layout hotfix v1.1
-- Salon remains in its corner. Duo Photo moves to the empty right-side wall shown in-game.

task.wait(2)

local function setCF(name, cf)
 local o=workspace:FindFirstChild(name,true)
 if o and o:IsA("BasePart") then o.CFrame=cf end
 return o
end

-- SALON: far-right corner.
setCF("BBYA Salon Counter", CFrame.new(79,2.75,34)*CFrame.Angles(0,math.rad(-90),0))
setCF("BBYA Salon Sign", CFrame.new(74.4,5.8,34)*CFrame.Angles(0,math.rad(-90),0))
setCF("Salon Reset", CFrame.new(79,1,25))

-- DUO PHOTO: remove it from the crowded VIP/Chill cluster and use the empty right-side corner.
-- Backdrop hugs the outer wall; stage/seats sit in front of it, leaving the club walkway open.
setCF("Duo Photo Wall", CFrame.new(79,5,-20)*CFrame.Angles(0,math.rad(-90),0))
setCF("Duo Photo Stage", CFrame.new(74.8,.85,-20)*CFrame.Angles(0,math.rad(-90),0))
setCF("Duo Camera Marker", CFrame.new(66.5,.7,-20)*CFrame.Angles(0,math.rad(-90),0))

local duoSeats={}
for _,o in ipairs(workspace:GetDescendants()) do
 if o:IsA("Seat") and o.Name=="Duo Photo Seat" then table.insert(duoSeats,o) end
end
table.sort(duoSeats,function(a,b)return a:GetFullName()<b:GetFullName()end)
-- Seats face outward toward the camera marker.
if duoSeats[1] then duoSeats[1].CFrame=CFrame.new(74.5,1.65,-22.7)*CFrame.Angles(0,math.rad(-90),0) end
if duoSeats[2] then duoSeats[2].CFrame=CFrame.new(74.5,1.65,-17.3)*CFrame.Angles(0,math.rad(-90),0) end

-- CHILL & TALK remains its own lounge; no Duo Photo objects mixed into it.
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

for _,name in ipairs({"BBYA Salon Sign","Duo Photo Wall","Duo Camera Marker","Chill Sign"}) do
 local o=workspace:FindFirstChild(name,true)
 if o and o:IsA("BasePart") then o.CanCollide=false end
end

print("[BBYA] Layout v1.1: Duo Photo moved from VIP/Chill pile into empty right-side corner")
