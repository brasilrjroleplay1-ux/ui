-- Exercise the global presentation with actual native controls and all authored palettes.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local function luminance(c)
    local function linear(v) return v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4 end
    return 0.2126 * linear(c.R) + 0.7152 * linear(c.G) + 0.0722 * linear(c.B)
end
local function contrast(a, b)
    local x, y = luminance(a), luminance(b)
    return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05)
end
local w = UI:CreateWindow({ Id = "Presentation315", name = "CONEXÃO STUDIO", rememberTheme = false, configuration = { autoSave = false, autoLoad = false } })
local tab = w:CreateTab({ name = "Principal", icon = 93364949241311 })
local other = w:CreateTab({ name = "Outra aba" })
tab:Select()
local calls = 0
local button = tab:CreateButton({ name = "Executar ação", callback = function() calls += 1 end })
local toggle = tab:CreateToggle({ name = "Ativar", flag = "presentation/toggle", value = true, description = "Uma descrição que precisa ser legível." })
local slider = tab:CreateSlider({ name = "Quantidade", range = { 0, 100 }, value = 30 })
local copy = tab:CreateText({ name = "Informações", text = "O corpo do cartão acompanha a nova hierarquia visual." })
local section = tab:CreateSection({ name = "Controles" })
check(w.Presentation and w.Presentation.header.Parent == w.topbar and w.Presentation.rail.Parent == w.sidebar, "header and navigation surfaces belong to the native window")
check(not w.Presentation.header.Active and not w.Presentation.rail.Active, "decorative layers cannot capture touch or mouse input")
check(tab.topbarItem.ZIndex > w.Presentation.rail.ZIndex and tab.topbarItemTitle.ZIndex > w.Presentation.rail.ZIndex, "navigation backgrounds remain behind native tab labels and click targets")
check(w.layout.topbarHeight == 52 and w.layout.rowHeight == 42 and w.theme.CornerRoundness.Offset == 14, "window spacing, navigation targets and corners share the new scale")
check(tab.activeMarker.BackgroundTransparency == 0 and other.activeMarker.BackgroundTransparency == 1 and other.topbarItemTitle.TextTransparency < 0.25, "the selected tab has a clear marker while other names remain readable")
other:Select()
check(tab.activeMarker.BackgroundTransparency == 1 and other.activeMarker.BackgroundTransparency == 0, "tab selection updates the native page and its marker together")
tab:Select()
check(button.title.FontFace.Weight == Enum.FontWeight.SemiBold and copy.title.FontFace.Weight == Enum.FontWeight.SemiBold, "actions and card headings use stronger typography")
check(toggle.descriptor.titleLabel.TextTransparency == 0 and copy.body.TextTransparency == 0 and section.title.TextTransparency == 0, "supporting text uses a legible colour instead of heavily faded text")
button.interact.MouseButton1Click:Fire()
check(calls == 1 and toggle.value, "visual decorators preserve callbacks and the current control values")
check(toggle.indicator.Size.X.Offset == toggle.indicator.Size.Y.Offset and toggle.functionContainer.BackgroundColor3 == w.theme.AccentColor, "enabled toggles use a round knob on a coloured track")
toggle:Set(false, true)
check(toggle.indicator.Position.X.Offset == 3 and toggle.functionContainer.BackgroundColor3 == w.theme.ToggleTrack, "disabled toggles move the round knob to the opposite end")
toggle:Set(true, true)
check(slider.handle.Size.X.Offset == slider.handle.Size.Y.Offset and slider.track.Size.Y.Offset == 8, "sliders use round handles on a slimmer track")
slider.dragging = true;slider:_setHeld(true)
check(slider.handle.Size.X.Offset == 22 and slider.handle.Size.Y.Offset == 22, "holding the slider grows its round handle without changing its shape")
slider:_endDrag()
check(slider.handle.Size.X.Offset == 20 and not slider.dragging and slider.value == 30, "releasing restores the handle without changing the selected number")
local instances, connections = #w.instances, #w.connections
for _, theme in ipairs(UI.Themes) do
    w:ChangeTheme(theme.id)
    for _, key in ipairs({ "WindowColor", "ElementGradient", "ButtonGradient", "HeroGradient", "TabBackground" }) do
        for _, point in ipairs(w.theme[key].Keypoints) do
            check(contrast(w.theme.ContentColor, point.Value) >= 4.5, "primary text stays readable in " .. theme.id .. " / " .. key)
        end
    end
    for _, point in ipairs(w.theme.ElementGradient.Keypoints) do
        check(contrast(w.theme.MutedContent, point.Value) >= 4.5, "secondary text stays readable on cards in " .. theme.id)
    end
    check(copy.body.TextColor3 == w.theme.MutedContent and toggle.descriptor.titleLabel.TextColor3 == w.theme.MutedContent, "supporting text follows each palette")
    check(tab.activeMarker.BackgroundColor3 == w.theme.AccentColor and tab.topbarItemTitle.FontFace.Weight == Enum.FontWeight.SemiBold, "selection stays consistent through a theme change")
end
check(#w.instances == instances and #w.connections == connections, "theme changes reuse existing visual layers without adding instances or handlers")
local custom = ColorSequence.new(Color3.fromRGB(18, 25, 37), Color3.fromRGB(29, 36, 49))
w:ChangeTheme({ WindowColor = custom, ElementGradient = custom })
check(w.theme.HeaderGradient == custom and w.theme.ButtonGradient == custom, "custom partial background overrides also reach the decorative layers")
w:ChangeTheme("conexao")
w.UIPreferences.transparency = 45;w:ApplyTransparency()
check(math.abs(w.Presentation.header.BackgroundTransparency - 0.45) < 0.001 and math.abs(w.Presentation.rail.BackgroundTransparency - 0.45) < 0.001, "decorative surfaces respect the existing transparency preference")
w:Hide()
check(w.Presentation.header.BackgroundTransparency == 1 and tab.activeMarker.BackgroundTransparency == 1 and copy.body.TextTransparency == 1, "hide fades the chrome, selected marker and supporting text")
w:Show()
check(w.Presentation.header.BackgroundTransparency < 1 and tab.activeMarker.BackgroundTransparency == 0 and copy.body.TextTransparency == 0, "show restores visual hierarchy and selection")
w:SetSidebarIconsOnly(true)
check(not tab.topbarItemTitle.Visible and w.sidebar.Size.X.Offset == 64 and tab.activeMarker.Size.X.Offset == 3, "compact navigation retains its selection marker and icon access")
w:SetSidebarIconsOnly(false)
local group = tab:CreateGroup({ name = "Grupo", collapsible = true })
local nested = group:CreateText({ name = "Texto dentro do grupo", text = "Também usa as mesmas cores e fontes." })
check(nested._presentation and nested.body.TextColor3 == w.theme.MutedContent, "late controls inside groups receive the same presentation")
group:Collapse();group:Expand()
check(nested.body.TextTransparency == 0 and calls == 1 and toggle.value, "folding preserves both appearance and values without replaying callbacks")
local message = w:Notify({ title = "Interface atualizada", content = "O aviso compartilha a identidade visual.", type = "success", duration = 5 })
check(message.signal and message.signal.Parent == message.body and message.descriptionLabel.TextSize == 14, "notifications use a semantic accent and readable body copy")
w:Unload()
check(#w.instances == 0 and #w.connections == 0, "all presentation layers and their handlers are released on unload")
print("PASS: " .. checks .. " global presentation, palette contrast and lifecycle checks")
