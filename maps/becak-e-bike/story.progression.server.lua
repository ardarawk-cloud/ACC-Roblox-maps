-- BECAK E-BIKE — story progression v1.20
-- Story chapters now also unlock reputation-based cargo job tiers without adding a second economy system.

local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')

local root = Workspace:WaitForChild('BecakEBike',20)
if not root then return end

local CHAPTERS = {
    {min=0,   nextGoal=10,  title='Awal Perjalanan',      rep='Pendatang',   jobTier='Pemula',      cargoMultiplier=1.00, objective='Selesaikan 10 trip untuk dikenal warga Nusakarya.'},
    {min=10,  nextGoal=25,  title='Mulai Dipercaya',      rep='Warga Kenal', jobTier='Lokal',       cargoMultiplier=1.05, objective='Capai 25 trip dan bangun reputasi layanan.'},
    {min=25,  nextGoal=50,  title='Pengemudi Andalan',    rep='Terpercaya',  jobTier='Profesional', cargoMultiplier=1.10, objective='Capai 50 trip untuk membuka kontrak cargo bernilai lebih tinggi.'},
    {min=50,  nextGoal=100, title='Nama Besar Nusakarya', rep='Andalan Kota',jobTier='Prioritas',    cargoMultiplier=1.15, objective='Capai 100 trip dan kuasai rute seluruh kota.'},
    {min=100, nextGoal=nil, title='Legenda Jalanan',      rep='Legenda',     jobTier='Elite',        cargoMultiplier=1.25, objective='Pertahankan rating, selesaikan kontrak, dan bantu ekonomi kota.'},
}

local function chapterForTrips(trips)
    local chapter = 1
    for i,c in ipairs(CHAPTERS) do
        if trips >= c.min then chapter = i else break end
    end
    return chapter, CHAPTERS[chapter]
end

local function sync(player)
    local trips = math.max(0, tonumber(player:GetAttribute('BecakTrips')) or 0)
    local chapter, data = chapterForTrips(trips)
    local progressStart = data.min
    local nextGoal = data.nextGoal

    player:SetAttribute('StoryChapter', chapter)
    player:SetAttribute('StoryChapterTitle', data.title)
    player:SetAttribute('StoryReputation', data.rep)
    player:SetAttribute('StoryObjective', data.objective)
    player:SetAttribute('StoryProgressStart', progressStart)
    player:SetAttribute('StoryProgressTrips', math.max(0, trips-progressStart))
    player:SetAttribute('StoryNextTripGoal', nextGoal or trips)
    player:SetAttribute('StoryMaxChapter', #CHAPTERS)
    player:SetAttribute('StoryComplete', nextGoal == nil)
    player:SetAttribute('StoryJobTier', data.jobTier)
    player:SetAttribute('StoryCargoRewardMultiplier', data.cargoMultiplier)
    player:SetAttribute('StoryCargoRewardBonusPct', math.floor((data.cargoMultiplier-1)*100+.5))
end

local function setup(player)
    sync(player)
    player:GetAttributeChangedSignal('BecakTrips'):Connect(function()
        if player.Parent then sync(player) end
    end)
end

for _,player in ipairs(Players:GetPlayers()) do setup(player) end
Players.PlayerAdded:Connect(setup)

Workspace:SetAttribute('ACC_BecakStoryProgression','v1.20')
Workspace:SetAttribute('BecakStoryChapterCount',#CHAPTERS)
Workspace:SetAttribute('BecakReputationSystem','ON')
Workspace:SetAttribute('BecakReputationCargoTiers','ON')
print('[BECAK E-BIKE] story progression v1.20 ready • 5 chapters + reputation cargo job tiers')
