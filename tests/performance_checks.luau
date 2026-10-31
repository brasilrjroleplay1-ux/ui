-- Actual client adapters with controlled Roblox/executor capabilities; no real game is altered.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local run, lighting, players = game:GetService("RunService"), game:GetService("Lighting"), game:GetService("Players")
local original = { capSet = _G.setfpscap, capGet = _G.getfpscap, user = UserSettings, render = run.Set3dRenderingEnabled, renderGet = run.Is3dRenderingEnabled, findTerrain = workspace.FindFirstChildOfClass }
local cap, rendered, capCalls, renderCalls = 144, true, 0, 0
_G.getfpscap = function() return cap end
_G.setfpscap = function(value) cap = value capCalls += 1 end
run.Set3dRenderingEnabled = function(_, value) rendered = value renderCalls += 1 end
run.Is3dRenderingEnabled = function() return rendered end
local quality = { SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel8 }
UserSettings = function() return { GetService = function() return quality end } end
lighting.GlobalShadows, lighting.EnvironmentDiffuseScale, lighting.EnvironmentSpecularScale = true, 0.8, 0.6
local roots = {}
local function node(class, parent, props, base)
    local value = Instance.new(class)
    value.Parent = parent
    for key, data in pairs(props or {}) do value[key] = data end
    if base then value.IsA = function(self, name) return name == self.ClassName or name == base end end
    table.insert(roots, value)
    return value
end
local terrain = node("Terrain", workspace, { Name = "Terrain", WaterWaveSize = 0.2, WaterWaveSpeed = 10, WaterReflectance = 0.5 })
workspace.FindFirstChildOfClass = function(_, class) return class == "Terrain" and terrain or nil end
local part = node("Part", workspace, { Material = Enum.Material.Brick, Reflectance = 0.25, CastShadow = true, CanCollide = true, Transparency = 0 }, "BasePart")
local particle = node("ParticleEmitter", part, { Enabled = true })
local decal = node("Decal", part, { Transparency = 0.2 })
local bloom = node("BloomEffect", lighting, { Enabled = true }, "PostEffect")
local gui = node("ScreenGui", players.LocalPlayer.PlayerGui, { Name = "GameHud", Enabled = true })
local disabled = node("ScreenGui", players.LocalPlayer.PlayerGui, { Name = "DisabledHud", Enabled = false })
local w = UI:CreateWindow({ Id = "Performance312", name = "CONEXÃO STUDIO", configuration = { fileName = "performance312", autoSave = true, autoLoad = true } })
local p, nav = w.Performance, w.SettingsNavigation
check(p and nav.buttons.performance and nav.membership[p.row] == "performance", "Desempenho is a built-in Settings category")
w:OpenSettings("performance")
check(nav.active == "performance" and p.row.main.Visible and w.selectedTab == w.SettingsTab, "the new category opens its own controls without a separate popup")
check(p.graphics.collapsed and not p.frames.collapsed and capCalls == 0 and renderCalls == 0, "the initial view does not change FPS or rendering before an action")
p.graphics.group.layout.AbsoluteContentSize = Vector2.new(300, 460)
p.graphics.group.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
p.graphics.header.button.MouseButton1Click:Fire()
check(not p.graphics.collapsed and p.graphics.body.Visible and p.graphics.height == 534 and p.graphics.arrow.Rotation == 90, "clicking the graphics arrow opens the card and includes all its contents")
p.graphics.header.button.MouseButton1Click:Fire()
check(p.graphics.collapsed and not p.graphics.body.Visible and p.graphics.height == 58 and p.graphics.arrow.Rotation == 0, "clicking again closes the card and reclaims its height")
p.frames.header.button.MouseButton1Click:Fire();check(p.frames.collapsed, "the frame-rate card collapses independently")
p.frames.header.button.MouseButton1Click:Fire();p.graphics:SetCollapsed(false)
for _, width in ipairs({ 240, 420, 640, 900 }) do
    p.row.main.AbsoluteSize = Vector2.new(width, 600);p.row:Layout()
    local g, f = p.graphics.group.main, p.frames.group.main
    if width >= 640 then
        check(f.Position.X.Offset >= g.Size.X.Offset + 12 and f.Position.Y.Offset == 0 and g.Size.X.Offset + f.Size.X.Offset + 12 <= width, "wide cards sit side by side without overlap")
    else check(f.Position.X.Offset == 0 and f.Position.Y.Offset >= p.graphics.height + 12 and f.Size.X.Offset <= width, "narrow cards stack and remain inside the page") end
end
p.controls.fpsCap.callback(240, true)
check(capCalls == 0 and cap == 144, "drag previews do not call the executor every frame")
p.controls.fpsCap:Set(240)
check(cap == 240 and capCalls == 1 and p.engine.state.fpsCap == 240, "committing FPS cap invokes the detected executor function")
p.controls.fpsCap._valueInput.button.MouseButton1Click:Fire()
p.controls.fpsCap.valueInput.Text = "165"
p.controls.fpsCap.valueInput:ReleaseFocus()
check(cap == 165 and p.controls.fpsCap.value == 165, "typing an exact FPS value uses the same cap adapter")
local validSetter = p.engine.setCap
p.engine.setCap = function() return false end
p.controls.fpsCap:Set(200)
check(cap == 165 and p.controls.fpsCap.value == 165, "a rejected executor operation rolls the slider back to the actual previous choice")
p.engine.setCap = validSetter
p.controls.mode:Set("Leve");p.controls.lowGraphics:Set(true);run.Heartbeat:Fire(1)
check(not lighting.GlobalShadows and quality.SavedQualityLevel == Enum.SavedQualitySetting.QualityLevel1 and not bloom.Enabled, "light optimization lowers actual client quality and disables post effects")
check(particle.Enabled and decal.Transparency == 0.2 and part.Material == Enum.Material.Brick, "light mode preserves heavier scene properties")
p.controls.mode:Set("Máximo");run.Heartbeat:Fire(1)
check(not particle.Enabled and decal.Transparency == 1 and not part.CastShadow and part.Reflectance == 0, "maximum mode processes supported scene graphics in bounded batches")
check(part.CanCollide and part.Transparency == 0 and part.Material == Enum.Material.Brick and part.Parent == workspace, "optimization preserves world geometry, its collision toggle and physical material")
check(terrain.WaterWaveSize == 0 and terrain.WaterWaveSpeed == 0, "the stronger modes disable water animation")
local later = node("Decal", part, { Transparency = 0.4 })
workspace.DescendantAdded:Fire(later);run.Heartbeat:Fire(1)
check(later.Transparency == 1, "new scene descendants receive the active optimization")
decal.Transparency = 0.6
p.controls.lowGraphics:Set(false)
check(lighting.GlobalShadows and quality.SavedQualityLevel == Enum.SavedQualitySetting.QualityLevel8 and bloom.Enabled and particle.Enabled, "turning optimization off restores quality, shadows and enabled effects")
check(part.Material == Enum.Material.Brick and part.Reflectance == 0.25 and part.CastShadow and later.Transparency == 0.4 and decal.Transparency == 0.6, "restoration preserves game-authored changes made after our patches")
p.controls.disable3D:Set(true)
check(not rendered and p.engine.backdrop.Visible and w.screenGui.Enabled, "3D rendering can be disabled while the library stays enabled")
p.controls.background:Set("Branco")
check(p.engine.backdrop.BackgroundColor3 == Color3.new(1, 1, 1) and p.engine.backdrop.ZIndex < w.main.ZIndex, "background color is drawn behind the panel while 3D is disabled")
p.controls.disable3D:Set(false)
check(rendered and not p.engine.backdrop.Visible, "turning 3D rendering back on removes the background")
p.controls.hideUI:Set(true)
check(not gui.Enabled and not disabled.Enabled and w.screenGui.Enabled, "Hide game UI leaves the library accessible and remembers disabled GUIs")
local lateGui = node("ScreenGui", players.LocalPlayer.PlayerGui, { Name = "LateHud", Enabled = true })
players.LocalPlayer.PlayerGui.DescendantAdded:Fire(lateGui)
check(not lateGui.Enabled, "new game HUDs are hidden too")
gui.Enabled = true;gui:GetPropertyChangedSignal("Enabled"):Fire()
check(not gui.Enabled, "game scripts cannot accidentally re-enable a HUD while hiding is selected")
p.controls.hideUI:Set(false)
check(gui.Enabled and lateGui.Enabled and not disabled.Enabled and #p.engine.guiConnections == 0, "turning Hide UI off restores each original state and disconnects its watchers")
local oldPing = players.LocalPlayer.GetNetworkPing
players.LocalPlayer.GetNetworkPing = function() return 0.04 end
p.controls.showStats:Set(true)
for _ = 1, 60 do run.RenderStepped:Fire() end
run.Heartbeat:Fire(1)
check(p.engine.stats.Visible and p.engine.stats.Text:find("FPS", 1, true) and p.engine.stats.Text:find("80 ms", 1, true), "FPS/ping uses measured session frames and the client ping provider")
w:Hide();check(p.engine.stats.Visible, "the FPS/ping overlay can remain visible while the menu is hidden")
w:Show()
p.controls.lowGraphics:Set(true);p.controls.hideUI:Set(true);p.controls.disable3D:Set(true)
run.Heartbeat:Fire(1)
check(not rendered and not lighting.GlobalShadows and not gui.Enabled, "runtime effects are active before unloading")
check(w:Save(), "performance choices participate in explicit saving")
w:Unload()
check(rendered and cap == 144 and gui.Enabled and not disabled.Enabled and #w.connections == 0, "unload restores the original cap, rendering and game UI")
check(lighting.GlobalShadows and bloom.Enabled and part.Material == Enum.Material.Brick, "unload restores scene graphics that were still enabled in the optimizer")
local restored = UI:CreateWindow({ Id = "Performance312", configuration = { fileName = "performance312", autoSave = true, autoLoad = true } })
check(cap == 165 and restored.Performance.controls.showStats.value and not restored.Performance.graphics.collapsed, "reexecution restores saved performance choices and card expansion state")
check(not rendered and not lighting.GlobalShadows and not gui.Enabled, "saved rendering, graphics and UI choices are reapplied by auto load")
restored:Unload();check(cap == 144, "reexecuted settings also restore their captured client values on unload")
local quiet = UI:CreateWindow({ Id = "Performance312", configuration = { fileName = "performance312", autoSave = false, autoLoad = false } })
check(cap == 144 and not quiet.Performance.controls.showStats.value, "disabling auto load prevents stored runtime effects from being applied: " .. tostring(cap) .. "/" .. tostring(quiet.configuration.autoLoad) .. "/" .. tostring(quiet.Performance.controls.showStats.value))
quiet.Performance.controls.fpsCap:Set(300);quiet:Unload()
restored = UI:CreateWindow({ Id = "Performance312", configuration = { fileName = "performance312", autoSave = false, autoLoad = true } })
check(cap == 165, "disabling autosave keeps unsaved performance edits out of the stored profile")
restored:Unload()
local untouchedCalls, untouchedRender = capCalls, renderCalls
local untouched = UI:CreateWindow({ Id = "UntouchedPerformance312", configuration = { fileName = "untouched312", autoSave = true, autoLoad = true } })
untouched:Save()
check(untouched.UIPreferences.performance.fpsCap == nil, "saving an untouched UI does not configure an FPS limit implicitly")
untouched:Unload()
untouched = UI:CreateWindow({ Id = "UntouchedPerformance312", configuration = { fileName = "untouched312", autoSave = true, autoLoad = true } })
check(capCalls == untouchedCalls and renderCalls == untouchedRender, "reopening default preferences does not write FPS or rendering APIs")
untouched:Unload()
local first = UI:CreateWindow({ Id = "PerformanceOwnerA", configuration = { autoSave = false, autoLoad = false } })
first.Performance.controls.fpsCap:Set(240)
local second = UI:CreateWindow({ Id = "PerformanceOwnerB", configuration = { autoSave = false, autoLoad = false } })
second.Performance.controls.fpsCap:Set(300)
check(cap == 300 and not first.Performance.engine.capChanged and first.Performance.controls.fpsCap.value == 144, "a second window takes ownership without leaving the first window reporting an active override")
second:Unload();first:Unload()
check(cap == 144, "multiple windows still restore the original client cap when released")
local batchNodes = {}
for _ = 1, 300 do table.insert(batchNodes, node("Decal", part, { Transparency = 0.1 })) end
local batch = UI:CreateWindow({ Id = "PerformanceBatch", configuration = { autoSave = false, autoLoad = false } })
batch.Performance.controls.mode:Set("Máximo");batch.Performance.controls.lowGraphics:Set(true)
run.Heartbeat:Fire(0.016)
check(#batch.Performance.engine.queue > 120 and batch.Performance.engine.next > 1 and batch.Performance.engine.next <= 121, "large scenes are processed with a maximum of 120 objects per heartbeat")
batch:Unload()
for _, value in ipairs(batchNodes) do check(value.Transparency == 0.1, "unloading halfway through a batch restores processed nodes and leaves pending nodes untouched") end
_G.setfpscap, _G.getfpscap, run.Set3dRenderingEnabled, run.Is3dRenderingEnabled = nil, nil, nil, nil
local unavailable = UI:CreateWindow({ Id = "UnsupportedPerformance312", configuration = { autoSave = false, autoLoad = false } })
check(unavailable.Performance.controls.fpsCap.locked and unavailable.Performance.controls.disable3D.locked, "unsupported executor features are explicitly locked")
local ok, reason = unavailable.Performance.engine:Set("fpsCap", 240)
check(not ok and type(reason) == "string", "unsupported runtime APIs return an explanation without crashing the window")
unavailable:Unload()
_G.setfpscap, _G.getfpscap, UserSettings, run.Set3dRenderingEnabled, run.Is3dRenderingEnabled, workspace.FindFirstChildOfClass = original.capSet, original.capGet, original.user, original.render, original.renderGet, original.findTerrain
players.LocalPlayer.GetNetworkPing = oldPing
for _, root in ipairs(roots) do root:Destroy() end
print("PASS: " .. checks .. " collapsible performance controls, client adapters, persistence and restoration checks")
