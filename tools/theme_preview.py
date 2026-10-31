"""Render the palette reference from the actual public bundle, using the existing service shim."""
from pathlib import Path
import html, json, os, subprocess, tempfile

ROOT = Path(__file__).resolve().parents[1]
LUNE = os.environ.get("CONEXAO_LUNE", "/workspace/tools/lune-0.8.9/lune")
runner = (ROOT / "vendor/rayfield-gen2/scripts/run-tests.luau").read_text()
prefix = runner[:runner.index("local results = {")]
lua = '''
local UI = (function()
-- BUNDLE
end)()
local palettes = {}
for _, entry in ipairs(UI.Themes) do
    local out = { name = entry.name, id = entry.id, group = entry.group }
    for _, key in ipairs({ "WindowColor", "HeaderGradient", "ElementGradient", "TabBackground", "SliderProgress" }) do
        out[key] = {}
        for _, point in ipairs(entry.theme[key].Keypoints) do table.insert(out[key], { point.Time, point.Value:ToHex() }) end
    end
    for _, key in ipairs({ "ContentColor", "MutedContent", "AccentColor", "StatBackground", "SurfaceStroke" }) do out[key] = entry.theme[key]:ToHex() end
    table.insert(palettes, out)
end
fs.writeFile("-- OUTPUT", serde.encode("json", palettes))
'''
with tempfile.TemporaryDirectory() as folder:
    output, script = Path(folder) / "palettes.json", Path(folder) / "palettes.luau"
    script.write_text(prefix + lua.replace("-- BUNDLE", (ROOT / "dist/ConexaoUI.luau").read_text()).replace("-- OUTPUT", output.as_posix()))
    subprocess.run([LUNE, "run", str(script)], cwd=ROOT / "vendor/rayfield-gen2", check=True, capture_output=True, text=True)
    palettes = json.loads(output.read_text())

parts = ['<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="2216" viewBox="0 0 1280 2216">',
         '<rect width="1280" height="2216" fill="#0b0e16"/>',
         '<g font-family="Arial,sans-serif"><text x="22" y="34" fill="#f4f6fc" font-size="25" font-weight="700">Conexão Studio · 60 temas</text>',
         '<text x="22" y="58" fill="#aeb8ca" font-size="13">Paletas reais da library · referência de cores · não é uma captura do Roblox</text>']

def rect(x, y, width, height, fill, radius=6, extra=""):
    return f'<rect x="{x}" y="{y}" width="{width}" height="{height}" rx="{radius}" fill="{fill}" {extra}/>'

for index, palette in enumerate(palettes):
    x, y = 22 + (index % 5) * 250, 78 + (index // 5) * 177
    parts.append('<defs>')
    for key in ["WindowColor", "HeaderGradient", "ElementGradient", "TabBackground", "SliderProgress"]:
        stops = ''.join(f'<stop offset="{time * 100}%" stop-color="#{color}"/>' for time, color in palette[key])
        parts.append(f'<linearGradient id="p{index}-{key}" x2="1" y2="1">{stops}</linearGradient>')
    parts.append('</defs>')
    color = lambda key: '#' + palette[key]
    fill = lambda key: f'url(#p{index}-{key})'
    parts.append(rect(x, y, 236, 164, fill("WindowColor"), 12, f'stroke="{color("SurfaceStroke")}" stroke-opacity=".55"'))
    parts.append(rect(x + 8, y + 8, 220, 100, fill("WindowColor"), 8))
    parts.append(rect(x + 8, y + 8, 220, 18, fill("HeaderGradient"), 5))
    parts.append(f'<text x="{x + 40}" y="{y + 21}" fill="{color("ContentColor")}" font-size="9" font-weight="700">Conexão Studio</text>')
    parts.append(rect(x + 14, y + 33, 25, 67, color("StatBackground"), 5))
    parts.append(rect(x + 17, y + 39, 19, 8, fill("TabBackground"), 3))
    for offset in [55, 69, 83]:
        parts.append(rect(x + 19, y + offset, 14, 3, color("MutedContent"), 1, 'opacity=".45"'))
    parts.append(rect(x + 46, y + 33, 174, 67, fill("ElementGradient"), 6))
    parts.append(f'<text x="{x + 56}" y="{y + 49}" fill="{color("ContentColor")}" font-size="9">Aparência</text>')
    parts.append(rect(x + 56, y + 58, 141, 5, color("SurfaceStroke"), 2, 'opacity=".45"'))
    parts.append(rect(x + 56, y + 58, 96, 5, fill("SliderProgress"), 2))
    parts.append(f'<circle cx="{x + 152}" cy="{y + 60.5}" r="5" fill="{color("ContentColor")}"/>')
    parts.append(rect(x + 56, y + 77, 28, 13, color("AccentColor"), 7))
    parts.append(f'<circle cx="{x + 77}" cy="{y + 83.5}" r="4.5" fill="{color("ContentColor")}"/>')
    parts.append(f'<text x="{x + 12}" y="{y + 132}" fill="{color("ContentColor")}" font-size="16" font-weight="700">{html.escape(palette["name"])}</text>')
    parts.append(f'<text x="{x + 12}" y="{y + 151}" fill="{color("MutedContent")}" font-size="11">{html.escape(palette["group"])} · {color("AccentColor").upper()}</text>')

parts.append('</g></svg>')
(ROOT / "docs/theme-preview.svg").write_text('\n'.join(parts) + '\n')
print(f"Rendered {len(palettes)} palette references from the public bundle.")
