-- Exercise the actual launcher, header and delayed entrance with simulated Roblox services.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local function rect(node, width, height)
    local size, position, anchor = node.Size, node.Position, node.AnchorPoint
    local w, h = size.X.Scale * width + size.X.Offset, size.Y.Scale * height + size.Y.Offset
    return { x = position.X.Scale * width + position.X.Offset - anchor.X * w, y = position.Y.Scale * height + position.Y.Offset - anchor.Y * h, w = w, h = h }
end
local function inside(node, width, height, message)
    local r = rect(node, width, height)
    check(r.x >= -0.01 and r.y >= -0.01 and r.w > 0 and r.h > 0 and r.x + r.w <= width + 0.01 and r.y + r.h <= height + 0.01, message)
    return r
end
local window = UI:CreateWindow({ Id = "Header354", name = "CONEXÃO STUDIO", subtitle = UI.Version, configuration = { autoSave = false, autoLoad = false } })
local header = window.BrandHeader
check(header.mark and #header.mark.links == 2 and header.mark.root.Parent == window.topContainer, "the header contains the shared vector signature")
check(window.title.Text == "CONEXÃO STUDIO" and header.version.Text == UI.Version and window.title.FontFace == window.theme.TitleFont, "the wordmark retains the script title, version and themed title font")
local statusTag = window:CreateTag({ text = "Conectado" })
for _, width in ipairs({ 180, 220, 240, 319, 320, 379, 380, 426, 539, 540, 685, 1000 }) do
    window.main.AbsoluteSize = Vector2.new(width, 450)
    header:Layout()
    local left = inside(header.root, width, window.layout.topbarHeight, "brand cluster fits resized header")
    local right = inside(window.actionContainer, width, window.layout.topbarHeight, "native action group fits resized header")
    check(left.x + left.w < right.x, "wordmark and action group never collide")
    local title = inside(window.titleContainer, left.w, left.h, "title container fits brand cluster")
    inside(window.title, title.w, title.h, "window name remains bounded")
    if header.mark.root.Visible then inside(header.mark.root, left.w, left.h, "vector mark fits brand cluster") end
    if header.pill.Visible then inside(header.pill, title.w, title.h, "version capsule fits title container") end
    if header.caption.Visible then inside(header.caption, title.w, title.h, "signature caption fits title container") end
    if header.tagSlot.Visible then
        local tags = inside(header.tagSlot, title.w, title.h, "script-created status tags stay in the metadata row")
        check(tags.x >= header.pill.Size.X.Offset + 10 and not header.caption.Visible and header.tagSlot.ClipsDescendants, "status tags cannot cover the version, caption or title")
    end
    local sum = 0
    for _, action in ipairs(header.actions) do sum += action.Size.X.Offset end
    sum += math.max(0, #header.actions - 1) * window.actionsListLayout.Padding.Offset
    check(math.abs(sum - right.w) < 0.01, "native action layout has exactly the width it needs")
end
statusTag:Remove()
header:Layout()
check(not header.tagSlot.Visible, "removing the final status tag clears its metadata slot")
window:Hide()
check(header.mark.targets[1].node.BackgroundTransparency == 1 and header.pill.BackgroundTransparency == 1, "header decorations disappear when hidden")
window:Show()
check(header.mark.targets[1].node.BackgroundTransparency == 0 and header.pill.BackgroundTransparency < 1, "native restore also restores the custom header")
window:ToggleMinimise()
check(window.minimised and header.mark.plate.BackgroundTransparency == 0, "minimising keeps the header signature visible")
window:ToggleMinimise()
window:ChangeTheme("porcelana")
check(header.mark.gradient.Color == window.theme.SliderProgress and header.version.TextColor3 == window.theme.TitlingColor, "the signature and version follow a light theme")
local personalized = UI:CreateWindow({ Id = "CustomHeader354", name = "Meu projeto", subtitle = "Um subtítulo bem maior para testar o espaço do cabeçalho", icon = 93364949241311, configuration = { autoSave = false, autoLoad = false } })
check(personalized.title.Text == "Meu projeto" and not personalized.BrandHeader.mark and personalized.topbarIcon.Parent == personalized.topContainer, "a script can still supply its own name, subtitle and icon")
personalized:Unload()

-- Keep delay callbacks pending so teardown and each phase can be checked independently.
local oldDelay, clock, queue = task.delay, 0, {}
task.delay = function(delay, callback, ...)
    table.insert(queue, { at = clock + delay, callback = callback, args = table.pack(...) })
end
local function advance(duration)
    local deadline, steps = clock + duration, 0
    while true do
        table.sort(queue, function(a, b) return a.at < b.at end)
        local next = queue[1]
        if not next or next.at > deadline then break end
        table.remove(queue, 1)
        clock, steps = next.at, steps + 1
        assert(steps < 2000, "delay scheduler must terminate")
        next.callback(table.unpack(next.args, 1, next.args.n))
    end
    clock = deadline
end
local early = UI:CreateWindow({ Id = "CancelIntro354", configuration = { autoSave = false, autoLoad = false } })
local intro = early.Introduction
check(intro and not intro.closed and intro.gui.Parent and intro.mark.links[1].node.Parent == intro.mark.plate, "the launcher owns the same signature as the header")
check(intro.stage == 3 and intro.progress.Size.X.Scale == 1 and intro.phase.Text == "INTERFACE PRONTA", "progress reaches ready when Gen2 completes construction")
intro:Ready()
intro:Advance(1, 0.36, "late step")
check(intro.stage == 3 and intro.progress.Size.X.Scale == 1, "late construction callbacks cannot move progress backwards")
local previousCamera = workspace.CurrentCamera
local camera = previousCamera or Instance.new("Camera")
local viewport = camera.ViewportSize
workspace.CurrentCamera = camera
for _, dimensions in ipairs({ { 240, 320 }, { 320, 240 }, { 390, 844 }, { 1280, 768 } }) do
    camera.ViewportSize = Vector2.new(dimensions[1], dimensions[2])
    intro:Layout()
    check(intro.scale.Scale * 420 <= dimensions[1] - 28 + 0.01 and intro.scale.Scale * 212 <= dimensions[2] - 28 + 0.01, "launcher fits both screen dimensions")
end
camera.ViewportSize = viewport
workspace.CurrentCamera = previousCamera
early:Unload()
advance(2)
check(intro.closed and intro.gui.Parent == nil and #intro.connections == 0 and #intro.tweens == 0, "unloading during startup cancels animations and releases launcher signals")

window.hidden, window.hasShownOnce, window.animating, window._revealing = true, false, false, false
window:Show()
check(window.animating and window._revealing and not window.topbar.Visible and not window.elements.Visible, "first entrance begins with just the window surface")
advance(0.13)
check(window.topbar.Visible and not window.elements.Visible and header.mark.plate.BackgroundTransparency == 0, "the wordmark arrives before the content")
advance(0.12)
check(window.elements.Visible and window.animating, "navigation and content arrive in the next phase")
advance(0.55)
check(not window.animating and not window._revealing and window.drag.drag.Visible, "entrance settles and restores normal window interaction")
window.hidden, window.hasShownOnce, window.animating, window._revealing = true, false, false, false
window:Show()
window:Unload()
advance(2)
check(window.unloaded and #window.connections == 0, "queued entrance phases cannot revive an unloaded window")
task.delay = oldDelay
print("PASS: " .. checks .. " header geometry and staged entrance lifecycle checks")
