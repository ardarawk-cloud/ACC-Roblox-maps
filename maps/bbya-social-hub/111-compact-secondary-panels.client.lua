-- BBYA SOCIAL HUB — COMPACT SECONDARY / DJ BRIDGE RETIRED v7
-- Runtime QC authority cleanup.
-- 56-dock-stability.client.lua is the ONLY BBYA command-menu / feature-launcher authority.
-- 137-dj-live-clean.client.lua is the ONLY visible DJ LIVE panel authority.
-- This historical bridge previously re-applied DJ-only visibility and could override owner/QA access.
-- It is intentionally a no-op to preserve old project mapping without stacking another launcher authority.

print("[BBYA] Legacy compact-secondary DJ bridge retired: launcher authority=56, DJ panel authority=137")