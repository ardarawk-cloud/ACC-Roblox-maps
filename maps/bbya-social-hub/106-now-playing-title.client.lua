-- BBYA SOCIAL HUB — LEGACY NOW-PLAYING / MASTER METER RETIRED v3
-- Runtime QC authority cleanup.
-- 103-music-ui-final.client.lua is the ONLY Music player visual authority.
-- Historical Rooftop compact rows and MasterLevelMeterV6 injection are intentionally retired
-- because they can mutate the compact player after it has already rendered.
-- Audio playback, venue routing and server playlist authorities are NOT touched here.

print("[BBYA] Legacy now-playing/meter visual helper retired: Music visual authority=103 only")