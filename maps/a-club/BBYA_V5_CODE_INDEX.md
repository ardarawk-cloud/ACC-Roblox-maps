# BBYA SOCIAL HUB — V5.3 INSPECTION CODE INDEX

Status: **MASTER BUILD / FOUNDER ONE-PASS REVIEW**

Purpose: every screenshot, bug, overlap, sign error, collision, lighting issue, or UI navigation issue should be referenced by a stable code before editing. Do not rebuild unrelated zones to fix a localized defect.

## Macro zones

| Code | Area |
|---|---|
| A1 | Exterior / Spawn |
| A2 | Main Entrance / Façade |
| A3 | Lobby / Orientation |
| A4 | Main Club / Dance Hall |
| A5 | Main Bar |
| A6 | Chill Lounge |
| B1 | West Stair Core |
| B2 | East Stair Core |
| B3 | Main Lift Core |
| C1 | VIP West Mezzanine |
| C2 | VIP East Mezzanine |
| C3 | Queen / VIP Bridges |
| D1 | Rooftop Arrival / Circulation |
| D2 | Infinity Pool / Pool DJ |
| D3 | Sky Bar |
| D4 | Rooftop Chill / Sunset Social |
| D5 | Cabana Zones |
| D6 | Photo / View Deck |
| S1 | Service / Restroom / Backstage |

## Blueprint component codes

| Code | Parent | Component |
|---|---|---|
| 01 | A1 | Arrival Plaza |
| 02 | A3 | Reception / Host |
| 03 | A3 | Photo / Selfie Spot |
| 04 | A3 | Look Studio |
| 05 | A4 | Main Dance Floor |
| 06 | A4 | DJ Booth |
| 07 | A4 | Stage / Lighting Show |
| 08 | A5 | Main Bar |
| 09W | C1 | VIP Lounge West |
| 09E | C2 | VIP Lounge East |
| 10 | C3 | Queen Skybox / Private |
| 11W | C1 | VIP Balcony West |
| 11E | C2 | VIP Balcony East |
| 12W | C1 | Private Room West |
| 12E | C2 | Private Room East |
| 13 | D2 | Infinity Pool |
| 14 | D2 | Pool DJ Deck |
| 15 | D3 | Sky Bar |
| 16W | D5 | Cabanas West |
| 16E | D5 | Cabanas East |
| 17 | D6 | View / Photo Deck |
| 18 | A6 | Chill Lounge |
| 19 | B3 | Main Lift |
| 20 | B1 | West Stair Core |
| 21 | B2 | East Stair Core |
| 22 | S1 | Service / Backstage |
| 23 | D1 | Rooftop Arrival |

## Screenshot workflow

Example: if the HUD says `A4 / 06 • DJ BOOTH`, fix only A4 DJ/stage files unless QC proves the defect originates from a shared helper.

Example: if the HUD says `C2 / 12E • PRIVATE ROOM EAST`, do not touch C1, A4, or rooftop modules.

## ACC founder rule

Build a complete planned package first, run automated/source QC, publish the newest valid state, then request one founder inspection pass. Do not require repeated founder inspections after every small build change.
