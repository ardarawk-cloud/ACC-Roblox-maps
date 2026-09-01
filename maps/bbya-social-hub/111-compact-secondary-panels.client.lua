-- BBYA MUSIC UI TEST — DANCE CANVAS CONFLICT GUARD v2
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- The 212 catalog in 92-freecam.client.lua is the sole owner of DanceCatalogScroll.
-- V1 repeatedly changed AutomaticCanvasSize/CanvasSize/CanvasPosition every heartbeat,
-- which could race the catalog renderer on mobile and leave the list visually empty.
-- This script is intentionally passive during the isolated 212-dance test.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function markAuthority()
 local gui=pg:WaitForChild("BBYASocialHangoutUI",45)
 if not gui then return end
 local panel=gui:WaitForChild("DancePanel",20)
 if not panel then return end
 panel:SetAttribute("BBYADanceCanvasAuthority","CATALOG_92_ONLY_V2")
 panel:SetAttribute("BBYADanceCanvasHotfix","DISABLED_CONFLICT_V2")
 print("[BBYA TEST] Dance canvas conflict guard v2: 92-freecam is sole list/canvas owner")
end

task.spawn(markAuthority)
