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
     'src/utility/persistencePaths.luau':[
        ('path.join(dir, "conexao.rfld")','path.join(dir, "rayfield.rfld")'),
        ('function paths.getSettingsPath(window: { configuration: { customFolder: string? }? }?): (string, string)\n    local dir = variables.fileSystemManager:getPath("Settings")\n    if window and window.configuration and window.configuration.customFolder then\n        dir = path.join(dir, path.sanitizeFolder(window.configuration.customFolder))\n    end', 'function paths.getSettingsPath(): (string, string)\n    local dir = variables.fileSystemManager:getPath("Settings")'),
    ],
    'src/utility/persistenceSettings.luau':[
        ('type SettingsWindow = {\n    configuration: { customFolder: string? }?,', 'type SettingsWindow = {'),
        ('function persistenceSettings.getSettingsPath(window: SettingsWindow?): (string, string)\n    return paths.getSettingsPath(window)', 'function persistenceSettings.getSettingsPath(): (string, string)\n    return paths.getSettingsPath()'),
        ('function persistenceSettings.saveSettings(window: SettingsWindow): boolean\n    local dir, fullPath = persistenceSettings.getSettingsPath(window)', 'function persistenceSettings.saveSettings(window: SettingsWindow): boolean\n    local dir, fullPath = persistenceSettings.getSettingsPath()'),
        ('function persistenceSettings.loadSettings(window: SettingsWindow): boolean\n    local dir, fullPath = persistenceSettings.getSettingsPath(window)', 'function persistenceSettings.loadSettings(window: SettingsWindow): boolean\n    local dir, fullPath = persistenceSettings.getSettingsPath()'),
    ],
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
embedded=dict(re.findall(r'\["([a-z0-9]+)"\] = \[\[(.*?)\]\]',(ROOT/'ConexaoUI/Features/BrandAssets.luau').read_text(),re.S))
catalog=json.loads((ROOT/'assets/executors/catalog.json').read_text())
for entry in catalog:
    if 'file' in entry:
        assert base64.b64decode(embedded[entry['id']])==(ROOT/'assets/executors'/entry['file']).read_bytes(),entry['id']
assert len(embedded)==sum('file' in entry for entry in catalog)
print(f'PASS: {len(embedded)} embedded brand images match their packaged PNGs.')
