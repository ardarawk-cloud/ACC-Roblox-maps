-- BBYA V6 — GROUND LEVEL FINISH PASS
-- Architecture is already locked. This file adds non-obstructive hospitality/club finish only.

-- A1 arrival: warm lifestyle courtyard, not club neon overload.
for _,x in ipairs({-58,-38,38,58}) do
    part(A1,"A1 WARM BOLLARD "..x,Vector3.new(1.1,3.1,1.1),CFrame.new(x,2.05,-11),P.charcoal,Enum.Material.Metal,0,true,"01")
    local l=light(A1,"A1 BOLLARD LIGHT "..x,Vector3.new(x,3.25,-11),P.warm,.72,8,"01")
    l.Parent:SetAttribute("BBYADecorativeLight",true)
end
for _,z in ipairs({-34,-22,-10}) do
    part(A1,"A1 PAVER BAND "..z,Vector3.new(26,.08,.35),CFrame.new(0,.64,z),Color3.fromRGB(169,151,139),Enum.Material.Marble,0,false,"01")
end

-- A2 facade: canopy slats and vertical warm accents frame the open storefront without closing it.
for _,x in ipairs({-40,-24,-8,8,24,40}) do
    part(A2,"A2 CANOPY SLAT "..x,Vector3.new(1.4,.3,7),CFrame.new(x,8.8,3),P.wood,Enum.Material.WoodPlanks,0,false,nil)
end
for _,x in ipairs({-65,65}) do
    neon(A2,"A2 FACADE PINK EDGE "..x,Vector3.new(.16,10,.16),CFrame.new(x,8.5,-1.1),P.pink,nil)
end

-- A3 Social Commons: premium ceiling rhythm + wall panels; clear center spine remains untouched.
for _,z in ipairs({23,35,47,59}) do
    part(A3,"A3 CEILING BEAM "..z,Vector3.new(132,.45,1.2),CFrame.new(0,16.75,z),P.graphite,Enum.Material.Metal,0,false,nil)
end
for _,x in ipairs({-69,69}) do
    for _,z in ipairs({26,38,50}) do
        part(A3,"A3 WALL PANEL "..x.." "..z,Vector3.new(.22,7,8),CFrame.new(x,7,z),P.wood,Enum.Material.WoodPlanks,0,false,nil)
        local l=light(A3,"A3 WALL WARM "..x.." "..z,Vector3.new(x+(x<0 and 1 or -1),8,z),P.warm,.62,9,nil)
        l.Parent:SetAttribute("BBYADecorativeLight",true)
    end
end
-- low side tables beside commons seating, outside x=-10..10 circulation spine.
for _,p in ipairs({Vector3.new(-28,1.25,46),Vector3.new(28,1.25,49)}) do
    tableLow(A3,"A3 SIDE TABLE "..tostring(p.X),p,Vector3.new(3,.55,3),P.black,nil)
end

-- Look Studio: real studio ceiling strips / makeup-light feel.
for _,x in ipairs({-58,-52,-42,-36}) do
    neon(A3,"A3 LOOK SOFTBOX STRIP "..x,Vector3.new(4,.12,.12),CFrame.new(x,10.5,59.7),P.white,"04")
end

-- A4 Club Facility: modern bright club language; neon accents + neutral avatar light.
for _,z in ipairs({74,88,102,116}) do
    part(A4,"A4 CEILING TRUSS X "..z,Vector3.new(84,.45,.7),CFrame.new(0,16.6,z),P.graphite,Enum.Material.Metal,0,false,"07")
end
for _,x in ipairs({-32,-16,0,16,32}) do
    part(A4,"A4 CEILING TRUSS Z "..x,Vector3.new(.7,.45,52),CFrame.new(x,16.55,94),P.graphite,Enum.Material.Metal,0,false,"07")
end
for _,cfg in ipairs({
    {-32,15.9,80,P.cyan},{-16,15.9,88,P.pink},{0,15.9,80,P.white},{16,15.9,88,P.pink},{32,15.9,80,P.cyan},
    {-32,15.9,108,P.pink},{-16,15.9,100,P.cyan},{0,15.9,108,P.white},{16,15.9,100,P.cyan},{32,15.9,108,P.pink},
}) do
    neon(A4,"A4 CEILING LINE",Vector3.new(6,.16,.16),CFrame.new(cfg[1],cfg[2],cfg[3]),cfg[4],"07")
end
-- speaker columns are architectural objects, not giant text props.
for _,x in ipairs({-39,39}) do
    for _,z in ipairs({117,124}) do
        part(A4,"A4 SPEAKER COLUMN "..x.." "..z,Vector3.new(4,10,3.5),CFrame.new(x,6,z),P.black,Enum.Material.Metal,0,true,"07")
        for _,dy in ipairs({3.5,6,8.5}) do
            local cone=part(A4,"A4 SPEAKER CONE",Vector3.new(.35,2.2,2.2),CFrame.new(x+(x<0 and 2.05 or -2.05),dy,z),P.graphite,Enum.Material.SmoothPlastic,0,false,"07")
            cone.Shape=Enum.PartType.Cylinder
            cone.CFrame=cone.CFrame*CFrame.Angles(0,0,math.rad(90))
        end
    end
end

-- A5 Social Bar: warm backbar shelves and bottle silhouettes.
part(A5,"A5 BACKBAR WALL",Vector3.new(1,10,42),CFrame.new(70.4,6.3,96),P.black,Enum.Material.Slate,0,false,"08")
for _,y in ipairs({3.8,6.3,8.8}) do
    part(A5,"A5 BACKBAR SHELF "..y,Vector3.new(.6,.35,36),CFrame.new(69.7,y,96),P.wood,Enum.Material.WoodPlanks,0,false,"08")
    neon(A5,"A5 BACKBAR WARM LINE "..y,Vector3.new(.12,.12,34),CFrame.new(69.35,y-.2,96),P.warm,"08")
end
for _,z in ipairs({82,88,94,100,106,112}) do
    part(A5,"A5 BOTTLE SILHOUETTE "..z,Vector3.new(.9,2,.9),CFrame.new(69.1,5,z),Color3.fromRGB(105,63,50),Enum.Material.Glass,.2,false,"08")
end

-- A6 Chill / Conversation: acoustic wall rhythm, warm low-key lounge lights.
for _,z in ipairs({72,82,92,102,112,122}) do
    part(A6,"A6 ACOUSTIC PANEL "..z,Vector3.new(.35,8,6),CFrame.new(-70.8,7,z),Color3.fromRGB(71,61,65),Enum.Material.Fabric,0,false,nil)
end
for _,z in ipairs({84,104}) do
    planter(A6,"A6 LOUNGE PLANTER "..z,Vector3.new(-49,1.25,z),Vector3.new(3.5,1.6,3.5),nil)
end

workspace:SetAttribute("BBYAV6GroundFinish","PREMIUM_PASS_1")
