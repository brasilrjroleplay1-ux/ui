"""Verify the pinned source and the exact, documented nonvisual fork edits."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[1]
VENDOR=ROOT/'vendor/rayfield-gen2'
meta=json.loads((VENDOR/'UPSTREAM.json').read_text())
patches={
    'src/components/window.luau':('usageAnalytics = false,','usageAnalytics = true,'),
    'src/utility/filesystemManager.luau':('local DEFAULT_ROOT_PATH = "ConexaoUI"','local DEFAULT_ROOT_PATH = "Rayfield"'),
    'src/utility/persistencePaths.luau':('path.join(dir, "conexao.rfld")','path.join(dir, "rayfield.rfld")'),
}
for name,digest in meta['original_sha256'].items():
    source=(VENDOR/name).read_text()
    if name in patches:
        changed,original=patches[name]
        assert source.count(changed)==1,name
        source=source.replace(changed,original,1)
    assert hashlib.sha256(source.encode()).hexdigest()==digest,f'Undeclared upstream change: {name}'
assert len(list((VENDOR/'src').rglob('*.luau')))==len(meta['original_sha256'])
print(f'PASS: {len(meta["original_sha256"])} pinned Gen2 modules verified against upstream; visual construction preserved.')
