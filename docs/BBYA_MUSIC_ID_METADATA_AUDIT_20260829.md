# BBYA Music — Roblox Asset ID Metadata Audit

Date: 2026-08-29
Workflow run: `33260916786`
Artifact: `BBYA-MUSIC-ID-METADATA-AUDIT`

## Result

- **25/25 IDs exist** through Roblox Open Cloud Asset metadata.
- **25/25 are `Audio` assets.**
- **24/25 moderation state = `Approved`.**
- **1/25 moderation state = `Rejected`: `102227106442067`.**

The rejected asset is retained for traceability but must be disabled in the device-test playlist.

| # | Asset ID | Moderation | Roblox display name |
|---:|---|---|---|
| 1 | `86006580589828` | Approved | DJ LUKA NEGARA VERSI JEPANG V2 |
| 2 | `125820152354579` | Approved | DJ PARADISE X VELOCITY BABY DONT GO FEAT IMA AUDIO |
| 3 | `133947654553749` | Approved | DJ TJAP MORGAN V4 |
| 4 | `95691778643767` | Approved | DJ ayang ayang |
| 5 | `130313438027284` | Approved | FUNK DO BOUNCE |
| 6 | `75712054983357` | Approved | HADROH YA THOYBHA / Ar Production |
| 7 | `88943191512256` | Approved | DJ Banteng lestari |
| 8 | `91809948844354` | Approved | dj gangsta mp |
| 9 | `108578144206183` | Approved | DJ Kandas HKS |
| 10 | `89763491889927` | Approved | dj battle HKS |
| 11 | `96924419000406` | Approved | DJ trap love of war |
| 12 | `132460784559824` | Approved | DJ cinta yang sempurna |
| 13 | `122720606049274` | Approved | DJ bocah cilik sholawat |
| 14 | `70777592375726` | Approved | dj mahabarata |
| 15 | `98308711398889` | Approved | dj bila nanti |
| 16 | `95839337053281` | Approved | dj punk rock jalanan |
| 17 | `135587255285184` | Approved | DJ TJAP MORGAN TROMPET BY KLEPON REMIX |
| 18 | `104136707299013` | Approved | DJ gedhang kluthuk |
| 19 | `131597067752690` | Approved | Garam cina |
| 20 | `73502975968958` | Approved | DJ SIN PIJAMA BY ALVIN REVOLUTION |
| 21 | `101289385838814` | Approved | DJ TROMPET BRAZIL - BASS JEPAT BEDIL NGUWER KING M |
| 22 | `102043858565172` | Approved | DJ VIRAL TIK TOK SLOW BAS PAL PAL DI KEPAS BY IRP |
| 23 | `79235704240751` | Approved | Dj Twenty One Pilots Nova - Tambai Elang |
| 24 | `103710801320668` | Approved | AWAS JANTUNG COPOT DJ PRANK KARNAVAL VIRAL YG |
| 25 | `102227106442067` | **Rejected** | Dj We Found Love MINIONS AUDIO |

## Important limitation

Metadata approval does **not** by itself prove runtime permission for the BBYA Music UI Test universe. Roblox audio can be restricted to specific creators/experiences. The remaining device/server test must still verify which of the 24 approved assets can actually load in universe `10762005984`.

No asset permission mutation was performed by this audit.