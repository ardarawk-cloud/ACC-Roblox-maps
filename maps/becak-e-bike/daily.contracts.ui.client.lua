-- BECAK E-BIKE — Daily Contracts Mission UI v1.18
-- Adds a lightweight mission overlay to the existing left-side driver phone without replacing vehicle controls.

local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')

local player = Players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui')

local GREEN = Color3.fromRGB(21,155,73)
local DARK = Color3.fromRGB(12,16,19)
local CARD = Color3.fromRGB(24,30,34)
local MUTED = Color3.fromRGB(155,167,174)
local WHITE = Color3.fromRGB(246,248,249)
local PURPLE = Color3.fromRGB(111,67,161)

local function corner(obj, radius)
    local c = Instance.new('UICorner')
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = obj
    return c
end

local function label(parent, text, pos, size, textSize, bold, color)
    local t = Instance.new('TextLabel')
    t.BackgroundTransparency = 1
    t.Text = text
    t.Position = pos
    t.Size = size
    t.TextColor3 = color or WHITE
    t.TextSize = textSize or 12
    t.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.Parent = parent
    return t
end

local function waitForPhone()
    local gui = playerGui:WaitForChild('BecakDriverPhone', 25)
    if not gui then return nil end
    return gui:WaitForChild('Phone', 10), gui
end

local phone, phoneGui = waitForPhone()
if not phone or not phoneGui then return end

local panel = Instance.new('Frame')
panel.Name = 'DailyContractsPanel'
panel.AnchorPoint = Vector2.new(0,0)
panel.Position = UDim2.fromOffset(18,94)
panel.Size = UDim2.new(1,-36,1,-176)
panel.BackgroundColor3 = DARK
panel.Visible = false
panel.ZIndex = 80
panel.Parent = phone
corner(panel,18)

local stroke = Instance.new('UIStroke')
stroke.Color = Color3.fromRGB(68,76,82)
stroke.Transparency = .2
stroke.Parent = panel

label(panel,'MISI & STORY',UDim2.fromOffset(14,8),UDim2.new(1,-60,0,28),16,true,WHITE)
local summary = label(panel,'Kontrak harian 0/3',UDim2.fromOffset(14,36),UDim2.new(1,-28,0,22),11,false,MUTED)

local close = Instance.new('TextButton')
close.Text = '×'
close.Position = UDim2.new(1,-44,0,8)
close.Size = UDim2.fromOffset(32,32)
close.BackgroundColor3 = Color3.fromRGB(39,45,49)
close.TextColor3 = WHITE
close.TextSize = 20
close.Font = Enum.Font.GothamBold
close.ZIndex = 82
close.Parent = panel
corner(close,10)

local rows = {}
local defs = {
    {id='passenger', title='ANTAR PENUMPANG', reward='Reward Rp18.000 + 45 XP'},
    {id='cargo', title='KIRIM CARGO', reward='Reward Rp24.000 + 55 XP'},
    {id='charge', title='CHARGING', reward='Reward Rp8.000 + 20 XP'},
}

for i,d in ipairs(defs) do
    local row = Instance.new('Frame')
    row.Position = UDim2.fromOffset(12,72+(i-1)*106)
    row.Size = UDim2.new(1,-24,0,94)
    row.BackgroundColor3 = CARD
    row.ZIndex = 81
    row.Parent = panel
    corner(row,13)

    local title = label(row,d.title,UDim2.fromOffset(12,8),UDim2.new(1,-24,0,20),12,true,WHITE)
    title.ZIndex = 82
    local progress = label(row,'0 / 0',UDim2.fromOffset(12,31),UDim2.new(1,-24,0,20),14,true,Color3.fromRGB(124,235,151))
    progress.ZIndex = 82
    local reward = label(row,d.reward,UDim2.fromOffset(12,62),UDim2.new(1,-24,0,18),10,false,MUTED)
    reward.ZIndex = 82

    local barBack = Instance.new('Frame')
    barBack.Position = UDim2.new(0,12,1,-12)
    barBack.AnchorPoint = Vector2.new(0,1)
    barBack.Size = UDim2.new(1,-24,0,5)
    barBack.BackgroundColor3 = Color3.fromRGB(48,55,59)
    barBack.ZIndex = 82
    barBack.Parent = row
    corner(barBack,3)

    local bar = Instance.new('Frame')
    bar.Size = UDim2.new(0,0,1,0)
    bar.BackgroundColor3 = GREEN
    bar.ZIndex = 83
    bar.Parent = barBack
    corner(bar,3)

    rows[d.id] = {progress=progress,bar=bar,row=row,title=title}
end

local storyCard = Instance.new('Frame')
storyCard.Position = UDim2.fromOffset(12,398)
storyCard.Size = UDim2.new(1,-24,0,86)
storyCard.BackgroundColor3 = Color3.fromRGB(35,25,52)
storyCard.ZIndex = 81
storyCard.Parent = panel
corner(storyCard,13)
local st1 = label(storyCard,'STORY • CHAPTER 1',UDim2.fromOffset(12,8),UDim2.new(1,-24,0,20),11,true,Color3.fromRGB(201,171,239)); st1.ZIndex=82
local st2 = label(storyCard,'Awal Perjalanan',UDim2.fromOffset(12,31),UDim2.new(1,-24,0,22),14,true,WHITE); st2.ZIndex=82
local st3 = label(storyCard,'Bangun reputasi lewat penumpang, cargo, dan layanan kota.',UDim2.fromOffset(12,54),UDim2.new(1,-24,0,25),9,false,MUTED); st3.ZIndex=82
st3.TextWrapped = true

local function refresh()
    local completed = tonumber(player:GetAttribute('DailyContractsCompleted')) or 0
    local total = tonumber(player:GetAttribute('DailyContractsTotal')) or 3
    summary.Text = string.format('Kontrak harian %d/%d',completed,total)
    for _,d in ipairs(defs) do
        local p = tonumber(player:GetAttribute('DailyContract_'..d.id..'_Progress')) or 0
        local g = math.max(1,tonumber(player:GetAttribute('DailyContract_'..d.id..'_Goal')) or 1)
        local claimed = player:GetAttribute('DailyContract_'..d.id..'_Claimed') == true
        local ui = rows[d.id]
        ui.progress.Text = claimed and 'SELESAI ✓' or string.format('%d / %d',math.min(p,g),g)
        ui.progress.TextColor3 = claimed and Color3.fromRGB(116,242,145) or WHITE
        ui.bar.Size = UDim2.new(math.clamp(p/g,0,1),0,1,0)
        ui.row.BackgroundColor3 = claimed and Color3.fromRGB(24,48,34) or CARD
    end
end

for _,d in ipairs(defs) do
    for _,suffix in ipairs({'Progress','Goal','Claimed'}) do
        player:GetAttributeChangedSignal('DailyContract_'..d.id..'_'..suffix):Connect(refresh)
    end
end
player:GetAttributeChangedSignal('DailyContractsCompleted'):Connect(refresh)
player:GetAttributeChangedSignal('DailyContractsTotal'):Connect(refresh)

local function bindMissionButton()
    for _,obj in ipairs(phoneGui:GetDescendants()) do
        if obj:IsA('TextButton') and obj.Text == 'MISI & STORY' and not obj:GetAttribute('DailyContractsBound') then
            obj:SetAttribute('DailyContractsBound',true)
            obj.Activated:Connect(function()
                refresh()
                panel.Visible = true
            end)
        end
    end
end

close.Activated:Connect(function() panel.Visible=false end)
phone:GetPropertyChangedSignal('Visible'):Connect(function()
    if not phone.Visible then panel.Visible=false end
end)

bindMissionButton()
phoneGui.DescendantAdded:Connect(function(obj)
    if obj:IsA('TextButton') and obj.Text == 'MISI & STORY' then task.defer(bindMissionButton) end
end)
refresh()

Workspace:SetAttribute('ACC_BecakDailyContractsUI','v1.18')
Workspace:SetAttribute('BecakMissionUIPhoneIntegrated','ON')
print('[BECAK E-BIKE] daily contracts mission UI v1.18 ready')