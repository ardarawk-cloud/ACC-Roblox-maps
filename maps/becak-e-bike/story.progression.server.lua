-- BECAK E-BIKE — story progression v1.19
-- Turns the existing trip milestones into a clearer chapter/reputation loop for MISI & STORY.

local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')

local root = Workspace:WaitForChild('BecakEBike',20)
if not root then return end

local CHAPTERS = {
    {min=0,   nextGoal=10,  title='Awal Perjalanan',      rep='Pendatang',  objective='Selesaikan 10 trip untuk dikenal warga Nusakarya.'},
    {min=10,  nextGoal=25,  title='Mulai Dipercaya',      rep='Warga Kenal', objective='Capai 25 trip dan bangun reputasi layanan.'},
    {min=25,  nextGoal=50,  title='Pengemudi Andalan',    rep='Terpercaya', objective='Capai 50 trip untuk membuka status pengemudi andalan.'},
    {min=50,  nextGoal=100, title='Nama Besar Nusakarya', rep='Andalan Kota', objective='Capai 100 trip dan kuasai rute seluruh kota.'},
    {min=100, nextGoal=nil, title='Legenda Jalanan',      rep='Legenda', objective='Pertahankan rating, selesaikan kontrak, dan bantu ekonomi kota.'},
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
end

local function setup(player)
    sync(player)
    player:GetAttributeChangedSignal('BecakTrips'):Connect(function()
        if player.Parent then sync(player) end
    end)
end

for _,player in ipairs(Players:GetPlayers()) do setup(player) end
Players.PlayerAdded:Connect(setup)

Workspace:SetAttribute('ACC_BecakStoryProgression','v1.19')
Workspace:SetAttribute('BecakStoryChapterCount',#CHAPTERS)
Workspace:SetAttribute('BecakReputationSystem','ON')
print('[BECAK E-BIKE] story progression v1.19 ready • 5 chapters + reputation tiers')
