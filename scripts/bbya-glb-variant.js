#!/usr/bin/env node
'use strict';

// Minimal GLB v2 material editor. Rewrites only the JSON chunk and preserves
// all binary geometry/textures byte-for-byte. Intended for deterministic
// BBYA entrance-car color variants from a vetted CC0 source model.

const fs = require('fs');

const [,, inputPath, outputPath, variant] = process.argv;
if (!inputPath || !outputPath || !variant) {
  console.error('Usage: node scripts/bbya-glb-variant.js <input.glb> <output.glb> <wine|pearl>');
  process.exit(2);
}

const palettes = {
  wine: {
    primary: [0.22, 0.008, 0.022, 1.0],
    shadow: [0.045, 0.003, 0.009, 1.0],
    metallic: 0.9,
    roughness: 0.16,
  },
  pearl: {
    primary: [0.70, 0.76, 0.84, 1.0],
    shadow: [0.12, 0.145, 0.19, 1.0],
    metallic: 0.82,
    roughness: 0.19,
  },
};

if (!palettes[variant]) {
  throw new Error(`Unknown variant: ${variant}`);
}

const src = fs.readFileSync(inputPath);
if (src.length < 20 || src.toString('ascii', 0, 4) !== 'glTF') {
  throw new Error('Input is not a GLB v2 file');
}
if (src.readUInt32LE(4) !== 2) throw new Error('Only GLB version 2 is supported');

const chunks = [];
let offset = 12;
while (offset + 8 <= src.length) {
  const len = src.readUInt32LE(offset);
  const type = src.readUInt32LE(offset + 4);
  const start = offset + 8;
  const end = start + len;
  if (end > src.length) throw new Error('Malformed GLB chunk length');
  chunks.push({ type, data: Buffer.from(src.subarray(start, end)) });
  offset = end;
}

const JSON_TYPE = 0x4E4F534A;
const jsonChunk = chunks.find((c) => c.type === JSON_TYPE);
if (!jsonChunk) throw new Error('GLB JSON chunk missing');

const jsonText = jsonChunk.data.toString('utf8').replace(/[\u0000 ]+$/g, '');
const gltf = JSON.parse(jsonText);
const p = palettes[variant];
let primaryCount = 0;
let shadowCount = 0;

for (const mat of gltf.materials || []) {
  const name = String(mat.name || '').toLowerCase();
  const mr = mat.pbrMetallicRoughness || (mat.pbrMetallicRoughness = {});
  if (name.includes('spectral blue') || name.includes('clearcoat')) {
    mr.baseColorFactor = p.primary;
    mr.metallicFactor = p.metallic;
    mr.roughnessFactor = p.roughness;
    primaryCount += 1;
  } else if (name.includes('midnight blue') || name.includes('shadow panels')) {
    mr.baseColorFactor = p.shadow;
    mr.metallicFactor = Math.max(0.72, p.metallic - 0.08);
    mr.roughnessFactor = Math.min(0.28, p.roughness + 0.07);
    shadowCount += 1;
  }
}

if (primaryCount === 0) {
  const names = (gltf.materials || []).map((m) => m.name || '<unnamed>').join(', ');
  throw new Error(`Primary paint material not found. Materials: ${names}`);
}

let newJson = Buffer.from(JSON.stringify(gltf), 'utf8');
const jsonPad = (4 - (newJson.length % 4)) % 4;
if (jsonPad) newJson = Buffer.concat([newJson, Buffer.alloc(jsonPad, 0x20)]);
jsonChunk.data = newJson;

const totalLength = 12 + chunks.reduce((n, c) => n + 8 + c.data.length, 0);
const out = Buffer.alloc(totalLength);
out.write('glTF', 0, 4, 'ascii');
out.writeUInt32LE(2, 4);
out.writeUInt32LE(totalLength, 8);
let pos = 12;
for (const chunk of chunks) {
  out.writeUInt32LE(chunk.data.length, pos);
  out.writeUInt32LE(chunk.type, pos + 4);
  chunk.data.copy(out, pos + 8);
  pos += 8 + chunk.data.length;
}
fs.writeFileSync(outputPath, out);
console.log(`BBYA_GLB_VARIANT_PASS variant=${variant} bytes=${out.length} primary=${primaryCount} shadow=${shadowCount}`);
