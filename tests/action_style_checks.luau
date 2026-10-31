-- Exercise the real controls: readable styles, adaptive layouts, input, themes and ownership.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local function rect(node, width, height)
    local s, p, a = node.Size, node.Position, node.AnchorPoint
    local w, h = s.X.Scale * width + s.X.Offset, s.Y.Scale * height + s.Y.Offset
    return { x = p.X.Scale * width + p.X.Offset - a.X * w, y = p.Y.Scale * height + p.Y.Offset - a.Y * h, w = w, h = h }
end
local function inside(node, width, height, message)
    local r = rect(node, width, height)
    check(r.x >= -0.01 and r.y >= -0.01 and r.w > 0 and r.h > 0 and r.x + r.w <= width + 0.01 and r.y + r.h <= height + 0.01, message)
    return r
end
local function apart(a, b) return a.x + a.w <= b.x or b.x + b.w <= a.x or a.y + a.h <= b.y or b.y + b.h <= a.y end
local function viewFits(view, width, height)
    local content = inside(view.content, width, height, "button content stays within its hit target")
    local icon = inside(view.iconPlate, content.w, content.h, "the icon plate fits its content group")
    local text = inside(view.label, content.w, content.h, "the label has its own space inside the button")
    check(apart(icon, text) and view.label.TextSize == 14 and view.label.FontFace.Weight == Enum.FontWeight.SemiBold, "icons and larger semibold labels never overlap")
end
local w = UI:CreateWindow({ Id = "Actions311", name = "CONEXÃO STUDIO", theme = "oceano", rememberTheme = false, configuration = { autoSave = false, autoLoad = false } })
local nav = w.SettingsNavigation
for _, width in ipairs({ 160, 240, 299, 300, 420, 559, 560, 720 }) do
    nav.main.AbsoluteSize = Vector2.new(width, 66)
    nav.scroller.AbsoluteWindowSize = Vector2.new(width, 66)
    nav:Layout()
    local roots = {}
    for key, item in pairs(nav.buttons) do
        local at = inside(item.button, nav.scroller.CanvasSize.X.Offset, nav.main.Size.Y.Offset, "category tiles remain inside their canvas")
        check(at.h >= 44, "category targets remain large enough for touch")
        viewFits(item.view, at.w, at.h)
        table.insert(roots, at)
    end
    for i = 1, #roots do for j = i + 1, #roots do check(apart(roots[i], roots[j]), "category tiles never overlap") end end
    check(nav.mode == (width >= nav.rowMinimum and "row" or (width >= 300 and "grid" or "scroll")), "the category strip changes layout without shrinking its labels")
    nav.buttons.controls.button.MouseButton1Click:Fire()
    check(nav.active == "controls" and nav.buttons.controls.view.indicator.BackgroundTransparency == 0 and nav.buttons.appearance.view.indicator.BackgroundTransparency == 1, "actual clicks update both the active category and its indicator")
    if width < 300 then
        check(nav.scroller.CanvasPosition.X > 0 and nav.overflow, "the active category is kept reachable by horizontal scrolling on tiny panels")
    else check(nav.scroller.CanvasPosition.X == 0 and not nav.overflow, "a row or grid shows every category without horizontal scrolling") end
end
local selected = nav.buttons.controls.view
selected.button.MouseEnter:Fire()
check(selected.overlay.BackgroundTransparency < 1, "hover adds visible emphasis without replacing the selected state")
selected.button.InputBegan:Fire({ UserInputType = Enum.UserInputType.Touch })
check(selected.scale.Scale == 0.98, "touch press has a short scale response")
selected.button.InputEnded:Fire({ UserInputType = Enum.UserInputType.Touch })
selected.button.MouseLeave:Fire()
check(selected.scale.Scale == 1 and selected.overlay.BackgroundTransparency == 1 and selected.indicator.BackgroundTransparency == 0, "release restores geometry while retaining the selected indicator")
nav:_setShown(false, false)
check(selected.button.BackgroundTransparency == 1 and selected.label.TextTransparency == 1 and selected.glyph[1].node[selected.glyph[1].alpha] == 1, "hiding fades the whole category treatment, including local vector glyphs")
nav:_setShown(true, false)
check(selected.button.BackgroundTransparency == 0 and selected.label.TextTransparency == 0, "revealing restores opaque surfaces and readable labels")

local tab = w:CreateTab({ name = "Dropdown actions" })
local changed = 0
local multi = tab:CreateDropdown({ name = "Seleção múltipla", options = { "A", "B", "C" }, value = { "A" }, multiSelect = true, callback = function() changed += 1 end })
w.size, w.main.AbsoluteSize = UDim2.fromOffset(824, 498), Vector2.new(824, 498)
w:_applyRailWidth();multi:Open()
local picker = multi.selectionPanel
local function inspectFooter()
    local fw, fh = picker.footer.Size.X.Offset, picker.footer.Size.Y.Offset
    local areas = {}
    inside(picker.footer, picker.main.Size.X.Offset, picker.body.Size.Y.Offset, "the action footer stays inside the options body")
    for index, view in ipairs(picker.actionViews) do
        local area = inside(view.button, fw, fh, "the action button stays inside its reserved footer")
        check(area.h >= 44, "dropdown actions retain a full touch target")
        viewFits(view, area.w, area.h)
        table.insert(areas, area)
    end
    for i = 1, #areas do for j = i + 1, #areas do check(apart(areas[i], areas[j]), "dropdown footer buttons never collide") end end
    local listBottom = picker.content.Position.Y.Offset + picker.content.Size.Y.Offset
    check(listBottom + 12 <= picker.footer.Position.Y.Offset and picker.body.Size.Y.Offset - picker.footer.Size.Y.Offset - 130 >= 44, "option rows keep their own viewport above the action footer")
    if fw >= 368 then
        check(areas[1].y == areas[2].y and areas[2].y == areas[3].y and picker.footerMode == "inline", "wide footers align all three actions in one row")
    elseif fw >= 180 then
        check(areas[1].y == areas[2].y and areas[3].y >= areas[1].y + areas[1].h + 8 and areas[3].w == fw, "primary Select all spans a separate row below Default and Clear")
    else
        check(areas[2].y > areas[1].y and areas[3].y > areas[2].y, "very narrow footers stack their actions without squeezing the labels")
    end
end
for _, size in ipairs({ Vector2.new(1100, 600), Vector2.new(824, 498), Vector2.new(685, 450), Vector2.new(320, 480), Vector2.new(240, 320), Vector2.new(320, 260) }) do
    w.size, w.main.AbsoluteSize = UDim2.fromOffset(size.X, size.Y), size
    w:_applyRailWidth();picker:Layout();inspectFooter()
end
local before = changed
picker.actions[3].MouseButton1Click:Fire()
check(#multi.value == 3 and changed == before + 1, "the redesigned primary action still selects everything once")
picker.actions[2].MouseButton1Click:Fire()
check(#multi.value == 0 and changed == before + 2, "the redesigned Clear action still removes every choice once")
picker.actions[1].MouseButton1Click:Fire()
check(#multi.value == 1 and multi.value[1] == "A" and changed == before + 3, "Default still restores the script's initial choice once")
local primary = picker.actionViews[3]
primary.button.SelectionGained:Fire()
check(primary.overlay.BackgroundTransparency < 1, "keyboard/gamepad focus has visible feedback too")
primary.button.SelectionLost:Fire()
local function luminance(c)
    local function linear(x) return x <= 0.04045 and x / 12.92 or ((x + 0.055) / 1.055) ^ 2.4 end
    return 0.2126 * linear(c.R) + 0.7152 * linear(c.G) + 0.0722 * linear(c.B)
end
local function contrast(a, b) local x, y = luminance(a), luminance(b) return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05) end
for _, theme in ipairs(UI.Themes) do
    w:ChangeTheme(theme.id)
    for _, point in ipairs(primary.gradient.Color.Keypoints) do
        check(contrast(primary.label.TextColor3, point.Value) >= 4.5, "primary action text stays readable across every palette: " .. theme.id)
    end
    check(primary.label.FontFace.Family == w.theme.TitleFont.Family and selected.label.FontFace.Family == w.theme.TitleFont.Family, "both button groups follow the current font")
    for _, item in ipairs({ picker.items[1], picker.items[2] }) do
        local text = item.label.TextColor3:Lerp(item.frame.BackgroundColor3, item.label.TextTransparency)
        check(contrast(text, item.frame.BackgroundColor3) >= 4.5, "selected and unselected card titles stay readable in " .. theme.id)
    end
    check(contrast(picker.items[1].marker.TextColor3, picker.items[1].frame.BackgroundColor3) >= 3, "the right-hand selection mark stays visible in " .. theme.id)
end

-- Optional internal rendering input. This is real geometry/theme data, not a Roblox screenshot.
if process.env.CONEXAO_ACTION_AUDIT == "1" then
    local function serialize(node)
        local function color(c) return { c.R, c.G, c.B } end
        local size, pos, anchor = node.Size, node.Position, node.AnchorPoint
        local out = { name = node.Name, size = { { size.X.Scale, size.X.Offset }, { size.Y.Scale, size.Y.Offset } }, position = { { pos.X.Scale, pos.X.Offset }, { pos.Y.Scale, pos.Y.Offset } }, anchor = { anchor.X, anchor.Y },
            visible = node.Visible ~= false, z = node.ZIndex or 1, rotation = node.Rotation or 0, alpha = node.BackgroundTransparency or 0, color = color(node.BackgroundColor3 or Color3.new(1, 1, 1)), children = {} }
        if node.ClassName == "TextLabel" or node.ClassName == "TextButton" then
            out.text, out.textSize, out.textAlpha, out.textColor, out.bold = node.Text, node.TextSize or 14, node.TextTransparency or 0, color(node.TextColor3 or Color3.new(1, 1, 1)), true
            out.align = tostring(node.TextXAlignment or Enum.TextXAlignment.Left)
        end
        for _, child in ipairs(node:GetChildren()) do
            if child.ClassName == "UICorner" then out.radius = { child.CornerRadius.Scale, child.CornerRadius.Offset }
            elseif child.ClassName == "UIStroke" then out.stroke = { weight = child.Thickness, alpha = child.Transparency, color = color(child.Color) }
            elseif child.ClassName == "UIGradient" then
                local points = {} for _, point in ipairs(child.Color.Keypoints) do table.insert(points, { point.Time, color(point.Value) }) end
                out.gradient = { rotation = child.Rotation or 0, points = points }
            elseif child.ClassName == "Frame" or child.ClassName == "ScrollingFrame" or child.ClassName == "TextLabel" or child.ClassName == "TextButton" then table.insert(out.children, serialize(child)) end
        end
        return out
    end
    for _, theme in ipairs({ "oceano", "conexao", "porcelana" }) do
        w:ChangeTheme(theme)
        for _, width in ipairs({ 560, 420 }) do
            nav.scroller.AbsoluteWindowSize = Vector2.new(width, 66);nav:Layout();nav:Select("appearance", false)
            local data = serialize(nav.main);data.size = { { 0, width }, { 0, nav.main.Size.Y.Offset } }
            fs.writeFile("/tmp/conexao-buttons-" .. theme .. "-" .. width .. ".json", serde.encode("json", data))
        end
        tab:Select()
        if not multi._isOpen then multi:Open() picker = multi.selectionPanel end
        w.size, w.main.AbsoluteSize = UDim2.fromOffset(685, 450), Vector2.new(685, 450);w:_applyRailWidth();picker:Layout()
        fs.writeFile("/tmp/conexao-footer-" .. theme .. ".json", serde.encode("json", serialize(picker.footer)))
    end
end
multi:Close()
local connections, instances = #w.connections, #w.instances
for _ = 1, 8 do multi:Open();multi:Close() end
check(#w.connections == connections and #w.instances == instances, "styling and focus handlers do not accumulate during repeated picker use")
w:Unload()
check(#w.connections == 0 and #w.instances == 0, "unload releases the new button groups and their owned listeners")
print("PASS: " .. checks .. " category/action styling, responsive geometry, contrast and interaction checks")
