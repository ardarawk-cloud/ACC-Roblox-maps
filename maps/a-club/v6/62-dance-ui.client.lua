-- BBYA V6 — DANCE STUDIO
-- Approved launcher parity: left rail = DANCE / VIP / PHOTO / TP.
-- Reuses the existing SOCIAL button/closure by reassigning socialPanel to this panel.

local Dance=net:WaitForChild("Dance")
local SyncDance=net:WaitForChild("SyncDance")

local dancePanel,danceBody=makePanel("DANCE_PANEL","DANCE STUDIO")
local intro=text(danceBody,"Pick a vibe • sync with friends • own the floor",13,UDim2.fromOffset(6,4),Enum.Font.Gotham,C.muted)
intro.Size=UDim2.new(1,-12,0,24)

local dances={
    {label="BBYA VIBES",key="dance",color=C.pink},
    {label="NEON GROOVE",key="dance2",color=C.cyan},
    {label="MIDNIGHT FLOW",key="dance3",color=C.pink},
    {label="HELLO CLUB",key="wave",color=C.cyan},
    {label="HYPE CROWD",key="cheer",color=C.gold},
    {label="GOOD VIBES",key="laugh",color=C.green},
    {label="POINT DROP",key="point",color=C.gold},
}
for i,d in ipairs(dances) do
    local col=(i-1)%2;local row=math.floor((i-1)/2)
    local b=button(danceBody,d.label,UDim2.new(.5,-8,0,54),UDim2.new(col*.5,3,0,38+row*64),C.panel2)
    b.TextColor3=d.color
    b.MouseButton1Click:Connect(function() Dance:FireServer(d.key) end)
end

local sync=button(danceBody,"SYNC NEARBY",UDim2.new(.48,-6,0,52),UDim2.new(0,3,0,306),C.panel2);sync.TextColor3=C.cyan
local auto=button(danceBody,"AUTO: OFF",UDim2.new(.48,-6,0,52),UDim2.new(.5,3,0,306),C.panel2);auto.TextColor3=C.pink
sync.MouseButton1Click:Connect(function()
    local my=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not my then return end
    local nearest=nil;local dist=35
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player then
            local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then local d=(hrp.Position-my.Position).Magnitude;if d<dist then dist=d;nearest=p end end
        end
    end
    if nearest then SyncDance:FireServer(nearest.UserId) else toast("Tidak ada player dalam jarak sync") end
end)

local autoOn=false;local autoToken=0
auto.MouseButton1Click:Connect(function()
    autoOn=not autoOn;autoToken+=1;local token=autoToken
    auto.Text=autoOn and "AUTO: ON" or "AUTO: OFF"
    if not autoOn then return end
    task.spawn(function()
        local seq={"dance","dance2","dance3"};local i=1
        while autoOn and token==autoToken do
            Dance:FireServer(seq[i]);i=i%#seq+1
            task.wait(12)
        end
    end)
end)

-- The existing launcher closure captures socialPanel by reference, so reassigning is deterministic.
socialPanel=dancePanel
launch.SOCIAL.Text="DANCE"
launch.SOCIAL.TextColor3=C.pink
launch.DANCE=launch.SOCIAL

player:SetAttribute("BBYAV6DanceUI",true)