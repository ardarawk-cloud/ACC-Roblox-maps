import struct,json,io,sys,os
from PIL import Image

JSON=0x4E4F534A; BIN=0x004E4942

def pad4(b, pad=b'\x00'):
    return b + pad*((4-len(b)%4)%4)

def load_glb(path):
    data=open(path,'rb').read(); magic,ver,total=struct.unpack_from('<III',data,0)
    assert magic==0x46546C67 and ver==2
    off=12; js=None; bn=None
    while off<total:
        ln,typ=struct.unpack_from('<II',data,off); off+=8
        ch=data[off:off+ln]; off+=ln
        if typ==JSON: js=json.loads(ch.decode('utf-8').rstrip(' \t\r\n\x00'))
        elif typ==BIN: bn=ch
    return js,bn

def enc_image(raw,mime,maxdim=1024):
    im=Image.open(io.BytesIO(raw)); im.load()
    if max(im.size)>maxdim:
        scale=maxdim/max(im.size); im=im.resize((max(1,round(im.width*scale)),max(1,round(im.height*scale))), Image.Resampling.LANCZOS)
    out=io.BytesIO()
    if mime=='image/jpeg':
        if im.mode not in ('RGB','L'): im=im.convert('RGB')
        im.save(out,'JPEG',quality=78,optimize=True,progressive=True)
    elif mime=='image/png':
        im.save(out,'PNG',optimize=True,compress_level=9)
    else:
        return raw, im.size
    return out.getvalue(), im.size

def optimize(src,dst,maxdim=1024):
    js,bn=load_glb(src)
    img_bvs={img['bufferView']:(i,img.get('mimeType','')) for i,img in enumerate(js.get('images',[])) if 'bufferView' in img}
    replacements={}
    for bvid,(idx,mime) in img_bvs.items():
        bv=js['bufferViews'][bvid]; st=bv.get('byteOffset',0); raw=bn[st:st+bv['byteLength']]
        new,_=enc_image(raw,mime,maxdim)
        replacements[bvid]=new
    newbin=bytearray()
    for i,bv in enumerate(js.get('bufferViews',[])):
        st=bv.get('byteOffset',0); raw=bn[st:st+bv['byteLength']]
        chunk=replacements.get(i,raw)
        while len(newbin)%4: newbin.append(0)
        bv['byteOffset']=len(newbin); bv['byteLength']=len(chunk)
        newbin.extend(chunk)
    while len(newbin)%4: newbin.append(0)
    if js.get('buffers'): js['buffers'][0]['byteLength']=len(newbin)
    jraw=json.dumps(js,separators=(',',':'),ensure_ascii=False).encode('utf-8')
    jpad=pad4(jraw,b' '); bpad=pad4(bytes(newbin),b'\x00')
    total=12+8+len(jpad)+8+len(bpad)
    out=struct.pack('<III',0x46546C67,2,total)+struct.pack('<II',len(jpad),JSON)+jpad+struct.pack('<II',len(bpad),BIN)+bpad
    open(dst,'wb').write(out)
    print(f'{os.path.basename(src)} -> {os.path.basename(dst)}: {os.path.getsize(src)} -> {len(out)} bytes')

if __name__=='__main__':
    optimize(sys.argv[1],sys.argv[2],int(sys.argv[3]) if len(sys.argv)>3 else 1024)
