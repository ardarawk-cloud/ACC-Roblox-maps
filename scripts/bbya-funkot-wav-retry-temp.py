#!/usr/bin/env python3
import json, os, pathlib, subprocess, tempfile, time, urllib.request, urllib.error

TRACKS=[
    ("Bbya Funkot 013","14nAtXu41ljgN8_fcN6KGNVWKWZkQxgPa"),
    ("Bbya Funkot 022","1vCqaZWxLrKDNd3_BVrWg61_vv4iNFSUm"),
]

def req(url,method="GET",payload=None,headers=None):
    data=None if payload is None else json.dumps(payload).encode()
    r=urllib.request.Request(url,data=data,headers=headers or {},method=method)
    try:
        with urllib.request.urlopen(r,timeout=45) as resp:
            raw=resp.read().decode("utf-8","replace")
            return resp.status,json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as e:
        raw=e.read().decode("utf-8","replace")
        try: body=json.loads(raw) if raw.strip() else {}
        except Exception: body={"raw":raw[-2000:]}
        return e.code,body

def main():
    key=os.environ.get("AUDIO_KEY","").strip()
    if not key: raise SystemExit("AUDIO_KEY_MISSING")
    code,info=req("https://apis.roblox.com/api-keys/v1/introspect","POST",{"apiKey":key},{"Content-Type":"application/json"})
    if code!=200: raise SystemExit(f"INTROSPECT_HTTP_{code}")
    owner=str(info.get("authorizedUserId") or "")
    if not owner: raise SystemExit("OWNER_MISSING")
    results=[]
    for title,fid in TRACKS:
        row={"title":title,"driveFileId":fid,"speedFactor":1.75,"playbackSpeed":0.5714285714}
        try:
            with tempfile.TemporaryDirectory() as td:
                td=pathlib.Path(td); src=td/"source"; wav=td/"upload.wav"
                d=subprocess.run(["gdown",f"https://drive.google.com/uc?id={fid}","-O",str(src)],text=True,capture_output=True)
                if d.returncode!=0 or not src.exists(): raise RuntimeError("DRIVE_DOWNLOAD_FAILED")
                p=subprocess.run(["ffmpeg","-y","-hide_banner","-loglevel","error","-i",str(src),"-vn","-af","aresample=44100,asetrate=77175,aresample=44100","-ac","2","-ar","44100","-c:a","pcm_s16le",str(wav)],text=True,capture_output=True)
                if p.returncode!=0: raise RuntimeError("WAV_PREPROCESS_FAILED:"+(p.stderr or "")[-1000:])
                create={"assetType":"Audio","displayName":title,"description":"BBYA Funkot WAV retry 1.75x","creationContext":{"creator":{"userId":owner}}}
                c=subprocess.run(["curl","-sS","--location","https://apis.roblox.com/assets/v1/assets","--header",f"x-api-key: {key}","--form-string","request="+json.dumps(create,separators=(",",":")),"--form",f"fileContent=@{wav};type=audio/wav","--write-out","\n%{http_code}"],text=True,capture_output=True)
                body,_,h=c.stdout.rpartition("\n")
                http=int(h or 0)
                data=json.loads(body) if body.strip() else {}
                if http not in (200,201,202): raise RuntimeError(f"UPLOAD_HTTP_{http}:{json.dumps(data)[:1200]}")
                path=data.get("path")
                if not path: raise RuntimeError("OPERATION_PATH_MISSING")
                aid=""; state=""
                for _ in range(100):
                    q,b=req("https://apis.roblox.com/assets/v1/"+path.lstrip("/"),headers={"x-api-key":key})
                    if q==200 and b.get("done"):
                        if b.get("error"): raise RuntimeError("OPERATION_REJECTED:"+json.dumps(b.get("error"))[:1200])
                        response=b.get("response") or {}; aid=str(response.get("assetId") or ""); state=str((response.get("moderationResult") or {}).get("moderationState") or "")
                        break
                    time.sleep(3)
                if not aid: raise RuntimeError("NO_ASSET_ID")
                row.update({"assetId":aid,"moderationState":state,"status":"ASSET_ID_READY"})
        except Exception as e:
            row.update({"status":"FAILED","error":str(e)[:2000]})
        results.append(row); print(json.dumps(row),flush=True)
    pathlib.Path("funkot-wav-retry-result.json").write_text(json.dumps(results,indent=2)+"\n")

if __name__=="__main__": main()
