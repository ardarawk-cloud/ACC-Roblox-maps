const express = require("express");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json({ limit: "15mb" }));
app.use(express.static(path.join(__dirname, "public")));

app.get("/api/health", (_req, res) => {
  res.json({
    ok: true,
    app: "ACC Roblox Map Builder",
    robloxKeyConfigured: Boolean(process.env.ROBLOX_API_KEY)
  });
});

app.post("/api/publish", async (req, res) => {
  try {
    const apiKey = process.env.ROBLOX_API_KEY;
    if (!apiKey) {
      return res.status(500).json({
        ok: false,
        error: "ROBLOX_API_KEY belum dipasang di environment server."
      });
    }

    const { universeId, placeId, rbxlx } = req.body || {};
    if (!/^\d+$/.test(String(universeId || "")) ||
        !/^\d+$/.test(String(placeId || "")) ||
        typeof rbxlx !== "string" ||
        !rbxlx.includes("<roblox")) {
      return res.status(400).json({
        ok: false,
        error: "Universe ID, Place ID, atau data RBXLX tidak valid."
      });
    }

    const url =
      `https://apis.roblox.com/universes/v1/${encodeURIComponent(universeId)}` +
      `/places/${encodeURIComponent(placeId)}/versions?versionType=Published`;

    const response = await fetch(url, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "Content-Type": "application/xml"
      },
      body: rbxlx
    });

    const bodyText = await response.text();
    let roblox;
    try { roblox = JSON.parse(bodyText); }
    catch { roblox = { raw: bodyText }; }

    if (!response.ok) {
      return res.status(response.status).json({
        ok: false,
        error: "Roblox menolak publish.",
        status: response.status,
        roblox
      });
    }

    res.json({
      ok: true,
      versionNumber: roblox.versionNumber ?? null,
      roblox
    });
  } catch (err) {
    res.status(500).json({
      ok: false,
      error: err?.message || "Terjadi error pada server."
    });
  }
});

app.get("*", (_req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(PORT, () => {
  console.log(`ACC Roblox Map Builder running on port ${PORT}`);
});
