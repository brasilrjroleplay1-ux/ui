"""Verify the pinned source and the exact, documented fork edits."""
from pathlib import Path
import hashlib,json,base64,re
ROOT=Path(__file__).resolve().parents[1]
VENDOR=ROOT/'vendor/rayfield-gen2'
meta=json.loads((VENDOR/'UPSTREAM.json').read_text())
patches={
    'src/init.luau':[('local bannerFactory = if typeof(properties) == "table" then (properties :: any).startup else nil\n    local banner = if typeof(bannerFactory) == "function" then bannerFactory() else createBanner()', 'local banner = createBanner()')],
    'src/components/window.luau':[('usageAnalytics = false,','usageAnalytics = true,')],
    'src/utility/filesystemManager.luau':[('local DEFAULT_ROOT_PATH = "ConexaoUI"','local DEFAULT_ROOT_PATH = "Rayfield"')],
    'src/utility/persistencePaths.luau':[('path.join(dir, "conexao.rfld")','path.join(dir, "rayfield.rfld")')],
    'src/utility/image.luau':[('w=420&h=420','w=48&h=48')],
    'src/utility/imageCache.luau':[
        ('local headshotPx = 420','local headshotPx = 48'),
        ('tostring(userId) .. "_420.png"','tostring(userId) .. ".png"'),
    ],
}
for name,digest in meta['original_sha256'].items():
    source=(VENDOR/name).read_text()
    for changed,original in patches.get(name,[]):
        assert source.count(changed)==1,name
        source=source.replace(changed,original,1)
    assert hashlib.sha256(source.encode()).hexdigest()==digest,f'Undeclared upstream change: {name}'
assert len(list((VENDOR/'src').rglob('*.luau')))==len(meta['original_sha256'])
print(f'PASS: {len(meta["original_sha256"])} pinned Gen2 modules verified against upstream; only documented fork edits.')
embedded=re.search(r'local encoded = \[\[(.*?)\]\]',(ROOT/'ConexaoUI/Features/BrandAssets.luau').read_text(),re.S).group(1)
assert base64.b64decode(embedded)==(ROOT/'assets/delta.png').read_bytes(),'Embedded Delta artwork differs from the attributed source image'
print('PASS: embedded Delta artwork matches the packaged PNG.')
