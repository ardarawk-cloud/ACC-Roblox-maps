# BBYAVATAR

Roblox avatar catalog / outfit creator experience for ACC Creative Lab.

## Locked target
- Universe ID: `10744157359`
- Place ID: `85866320744490`
- Publish mode: `OFF` until explicit release authorization

## Product scope
- Full-look avatar catalog
- Individual item browsing
- Try-on preview
- Full outfit apply/preview
- Creator collections
- Featured / trending collections
- Mobile-first catalog UI
- Saved looks / favorites foundation
- Purchase handoff through Roblox-supported marketplace flows

## Safety rules
1. Never publish this project to any other Universe/Place.
2. Never reuse BBYA Social Hub, WONDERPOCKET, Mountain Social Adventure, or other map target IDs.
3. Catalog data is config-driven; assets may be disabled without deleting the map.
4. Missing/moderated assets must fail gracefully.
5. Server validates all catalog requests before applying avatar descriptions.

## Planned Roblox hierarchy

```text
ReplicatedStorage
  BBYAVATAR
    Shared
      CatalogConfig
    Remotes
      CatalogRequest
      CatalogResult

ServerScriptService
  BBYAVATAR
    Bootstrap.server.lua
    CatalogService.lua

StarterPlayer
  StarterPlayerScripts
    BBYAVATAR
      Catalog.client.lua

Workspace
  BBYAVATAR_WORLD
    Spawn
    FeaturedHall
    CollectionWings
    Mannequins
    PhotoZone
```

## Initial player loop

SPAWN -> FEATURED LOOKS -> BROWSE COLLECTION -> SELECT LOOK -> TRY ON -> EDIT ITEMS -> BUY / SAVE -> CONTINUE EXPLORING
