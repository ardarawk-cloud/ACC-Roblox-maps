-- BBYA V6 — VIP / QUEEN FINISH PASS
-- Warm premium lounge language. No giant floating labels and no obstruction of balcony/lift circulation.

-- C1/C2 outer-wall panel rhythm and warm sconces.
for _,cfg in ipairs({
    {parent=C1,x=-68,zs={76,90,104,118},code="09W"},
    {parent=C2,x=53,zs={76,90,104},code="09E"},
}) do
    for _,z in ipairs(cfg.zs) do
        part(cfg.parent,"VIP WALL PANEL "..cfg.x.." "..z,Vector3.new(.28,8,8),CFrame.new(cfg.x,27,z),P.wood,Enum.Material.WoodPlanks,0,false,cfg.code)
        local l=light(cfg.parent,"VIP WALL SCONCE "..cfg.x.." "..z,Vector3.new(cfg.x+(cfg.x<0 and 1 or -1),28,z),P.warm,.68,9,cfg.code)
        l.Parent:SetAttribute("BBYADecorativeLight",true)
    end
end

-- Slim ceiling coffers over lounge edges; center/balcony view stays open.
for _,z in ipairs({76,94,112}) do
    part(C1,"C1 LOUNGE COFFER "..z,Vector3.new(40,.45,8),CFrame.new(-48,36.6,z),P.graphite,Enum.Material.WoodPlanks,0,false,"09W")
    part(C2,"C2 LOUNGE COFFER "..z,Vector3.new(38,.45,8),CFrame.new(28,36.6,z),P.graphite,Enum.Material.WoodPlanks,0,false,"09E")
end

-- Bottle-service table highlights, human scale.
for _,cfg in ipairs({
    {p=C1,x=-50,z=78,c="09W"},{p=C1,x=-50,z=98,c="09W"},{p=C2,x=27,z=78,c="09E"},{p=C2,x=27,z=98,c="09E"},
}) do
    local top=part(cfg.p,"VIP BOTTLE TABLE "..cfg.x.." "..cfg.z,Vector3.new(4,.4,3),CFrame.new(cfg.x,21.4,cfg.z),P.black,Enum.Material.Marble,0,true,cfg.c)
    neon(cfg.p,"VIP TABLE WARM EDGE",Vector3.new(3.6,.1,.1),top.CFrame*CFrame.new(0,-.18,-1.5),P.warm,cfg.c)
end

-- Balcony top rails give the upper level a finished architectural edge.
part(C1,"C1 BALCONY TOP RAIL",Vector3.new(40,.35,.55),CFrame.new(-38,25.25,65),P.gold,Enum.Material.Metal,0,false,"11W")
part(C2,"C2 BALCONY TOP RAIL",Vector3.new(40,.35,.55),CFrame.new(28,25.25,65),P.gold,Enum.Material.Metal,0,false,"11E")

-- Queen room: physical crown mark built from neon strokes, attached to rear wall.
local qBase=CFrame.new(-18,29.4,147.05)
neon(C3,"C3 QUEEN CROWN BASE",Vector3.new(10,.18,.18),qBase,P.pink,"10")
for i,cfg in ipairs({{-4,2,22},{0,3.7,0},{4,2,-22}}) do
    neon(C3,"C3 QUEEN CROWN RAY "..i,Vector3.new(.18,5,.18),qBase*CFrame.new(cfg[1],cfg[2],-.1)*CFrame.Angles(0,0,math.rad(cfg[3])),P.pink,"10")
end
for _,x in ipairs({-4,0,4}) do
    local jewel=part(C3,"C3 QUEEN CROWN JEWEL "..x,Vector3.new(.55,.55,.55),qBase*CFrame.new(x,5.5,-.1),P.gold,Enum.Material.Neon,0,false,"10")
    jewel.Shape=Enum.PartType.Ball
end

-- Queen/private-room softer decorative pools.
for _,cfg in ipairs({
    {x=-18,z=141,c="10"},{x=-38.5,z=141,c="12W"},{x=35,z=141,c="12E"},
}) do
    local l=light(C3,"C3 PRIVATE AMBIENT "..cfg.x,Vector3.new(cfg.x,27.5,cfg.z),P.warm,.72,10,cfg.c)
    l.Parent:SetAttribute("BBYADecorativeLight",true)
end

workspace:SetAttribute("BBYAV6VIPFinish","PREMIUM_PASS_1")
