# ACC Roblox Map Builder v1.0

Mobile-first map builder untuk workflow:

**ChatGPT → ACC MAP CODE → Generate → Edit di HP → Export RBXLX → Publish Roblox**

## Yang sudah bekerja

- UI mobile/PWA.
- Project save/load di localStorage HP.
- Import `ACC MAP CODE`.
- Generator Mountain map.
- Object presets: Part, Tree, Rock, Checkpoint, Spawn, Camp.
- Tap + drag object di viewport.
- Resize, duplicate, delete.
- Export `.rbxlx`.
- Publish `.rbxlx` langsung ke Roblox Open Cloud melalui backend.
- API key hanya dibaca dari environment server.

## Jalankan

Butuh Node.js 18+.

```bash
npm install
npm start
```

Buka `http://localhost:3000`.

## Secret wajib

Pasang environment variable:

```text
ROBLOX_API_KEY=API_KEY_ROBLOX_KAMU
```

JANGAN taruh API key di `index.html`, JavaScript frontend, GitHub public repository, atau ACC MAP CODE.

## Roblox setup

Di Creator Dashboard:

1. Buat Open Cloud API Key.
2. Tambahkan access permission `universe-places`.
3. Berikan operasi `Write` ke experience yang akan diedit.
4. Salin Universe ID.
5. Salin Place ID target.
6. Masukkan Universe ID dan Place ID ke aplikasi.
7. Generate map lalu tekan `Publish Roblox`.

Endpoint server mengikuti Place Publishing API resmi:
`POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Published`

Content-Type yang digunakan: `application/xml`.

## Deploy dari HP

Project ini sengaja hanya satu Node app agar mudah di-deploy ke layanan Node hosting apa pun yang mendukung environment variables.

Workflow:
1. Extract ZIP.
2. Upload folder ke GitHub.
3. Hubungkan repo ke hosting Node.
4. Tambahkan secret `ROBLOX_API_KEY` di dashboard hosting.
5. Start command: `npm start`.
6. Buka URL hosting dari HP.
7. Install ke Home Screen jika browser menawarkan PWA install.

## Catatan teknis penting

v1.0 menghasilkan bagian map dari primitive Roblox (`Part`/`SpawnLocation`) sehingga fokusnya adalah workflow mobile yang stabil dan mudah dipublish. Terrain voxel asli, MeshPart, asset marketplace, plugin system, full Lua IDE, dan live 3D engine Roblox belum menjadi bagian v1.0.

Format `ACC MAP CODE` dapat diperluas tanpa mengubah workflow pengguna.

## Safety

API key Roblox adalah kredensial rahasia. Jika bocor, revoke key dari Creator Dashboard lalu buat key baru.
