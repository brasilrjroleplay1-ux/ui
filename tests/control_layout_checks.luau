-- Actual distributed controls, with predictable font metrics in the Roblox-service shim.
local service = game:GetService("TextService")
service.GetTextBoundsAsync = function(_, params)
    local text = tostring(params.Text):gsub("<.->", "")
    local size, limit = params.Size, params.Width
    local width = (utf8.len(text) or #text) * size * 0.6
    local lines = limit < math.huge and math.max(1, math.ceil(width / math.max(1, limit))) or 1
    return Vector2.new(math.min(width, limit), lines * size)
end
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local window = UI:CreateWindow({ Id = "LayoutRegression", configuration = { autoSave = false, autoLoad = false } })
local tab = window:CreateTab({ name = "Geometria" })
local calls = 0
local toggle = tab:CreateToggle({ name = "Salvar escolhas automaticamente neste dispositivo", icon = 93364949241311, callback = function() calls += 1 end })
local slider = tab:CreateSlider({ name = "Transparência do fundo e da janela", icon = 93364949241311, range = { 0, 100 }, suffix = "%", value = 37, description = "Esta descrição usa a largura disponível e acompanha o tamanho da janela sem cortar o texto." })
local input = tab:CreateInput({ name = "Nome da configuração para restaurar", value = "Um nome comprido para uma configuração" })
local key = tab:CreateKeybind({ name = "Tecla para mostrar e esconder a interface", value = Enum.KeyCode.LeftControl })
local button = tab:CreateButton({ name = "Salvar esta configuração no dispositivo agora" })
local bare = tab:CreateSlider({ minimal = true, range = { 0, 100 } })
local function rect(node, root, width, height)
    if node == root then return { x = 0, y = 0, w = width, h = height } end
    local parent = rect(node.Parent, root, width, height)
    local size, at, anchor = node.Size, node.Position, node.AnchorPoint
    local w, h = size.X.Scale * parent.w + size.X.Offset, size.Y.Scale * parent.h + size.Y.Offset
    return { x = parent.x + at.X.Scale * parent.w + at.X.Offset - anchor.X * w,
        y = parent.y + at.Y.Scale * parent.h + at.Y.Offset - anchor.Y * h, w = w, h = h }
end
local function inside(r, width, height, name)
    check(r.w > 0 and r.h > 0 and r.x >= -0.01 and r.y >= -0.01 and r.x + r.w <= width + 0.01 and r.y + r.h <= height + 0.01, name .. " must stay inside its control")
end
local function separate(a, b, name)
    check(a.x + a.w <= b.x + 0.01 or b.x + b.w <= a.x + 0.01 or a.y + a.h <= b.y + 0.01 or b.y + b.h <= a.y + 0.01, name .. " must not overlap")
end
for _, width in ipairs({ 120, 160, 180, 199, 240, 299, 319, 320, 426, 559, 560, 720, 1000, 426, 199 }) do
    for _, control in ipairs({ toggle, slider, input, key, button, bare }) do
        control.main.AbsoluteSize = Vector2.new(width, 100)
        control.main:GetPropertyChangedSignal("AbsoluteSize"):Fire()
        control:_layoutConexaoControl()
        local height = control._controlLayout.height
        check(height > 0 and control._controlConstraint.MinSize.Y == height and control._controlConstraint.MaxSize.Y == height, "rendered height is protected from fixed-height press animations")
        if control.title then inside(rect(control.title, control.main, width, height), width, height, "title") end
        if control.functionContainer then
            local pill = rect(control.functionContainer, control.main, width, height)
            inside(pill, width, height, "toggle switch")
            separate(rect(control.title, control.main, width, height), pill, "title and toggle switch")
        elseif control.box then
            local field = rect(control.box, control.main, width, height)
            inside(field, width, height, "input/key field")
            separate(rect(control.title, control.main, width, height), field, "title and input/key field")
        end
        if control.__type == "Slider" then
            local hit = rect(control.interact, control.main, width, height)
            inside(hit, width, height, "slider hit area")
            if control.title then
                local title, value = rect(control.title, control.main, width, height), rect(control.valueHost, control.main, width, height)
                inside(value, width, height, "slider readout")
                separate(title, value, "slider title and readout")
                separate(title, hit, "slider title and drag target")
                separate(value, hit, "slider readout and drag target")
            end
            for _, value in ipairs({ 0, 50, 100 }) do
                control:Set(value, true)
                control.handle.Size = UDim2.fromOffset(41, 22)
                inside(rect(control.handle, control.main, width, height), width, height, "held handle at " .. value .. "%")
            end
        end
    end
    local description = slider.descriptor
    description.main.AbsoluteSize = Vector2.new(width, 40)
    description.main:GetPropertyChangedSignal("AbsoluteSize"):Fire()
    check(description.titleLabel.Size.X.Scale == 1 and description.titleLabel.Size.X.Offset == 0 and description.titleLabel.TextWrapped, "description uses the available width without its old 90px blank margin")
end
toggle.main.AbsoluteSize = Vector2.new(199, 100)
toggle:_layoutConexaoControl()
local height = toggle._controlLayout.height
check(height > 44 and toggle.title.TextWrapped and toggle.title.AutomaticSize == Enum.AutomaticSize.None, "long compact toggle labels wrap instead of growing underneath the switch")
toggle.interact.MouseButton1Click:Fire()
check(calls == 1 and toggle.value and toggle._controlConstraint.MinSize.Y == height, "a real click still calls the callback without collapsing wrapped labels to 41px")
slider.main.AbsoluteSize = Vector2.new(426, 100)
slider:_layoutConexaoControl()
check(slider._controlLayout.mode == "stacked", "the reported 426px slider case stacks instead of overlapping its left title")
local rawConstraint = slider._controlConstraint
slider._controlConstraint = setmetatable({}, {
    __index = function(_, property) return rawConstraint[property] end,
    __newindex = function(_, property, value)
        if property == "MinSize" then assert(value.Y <= rawConstraint.MaxSize.Y, "MinSize must never exceed MaxSize during reflow") end
        if property == "MaxSize" then assert(value.Y >= rawConstraint.MinSize.Y, "MaxSize must never fall below MinSize during reflow") end
        rawConstraint[property] = value
    end,
})
slider.main.AbsoluteSize = Vector2.new(199, 100)
slider:_layoutConexaoControl()
slider.main.AbsoluteSize = Vector2.new(720, 100)
slider:_layoutConexaoControl()
check(slider._controlLayout.height == rawConstraint.MinSize.Y, "growing and shrinking rows update size constraints in a valid order")
slider._controlConstraint = rawConstraint
slider.main.AbsoluteSize = Vector2.new(426, 100)
slider:_layoutConexaoControl()
slider.title.Text = "Um texto ainda maior depois de trocar o idioma da interface"
slider.title:GetPropertyChangedSignal("Text"):Fire()
check(slider.title.Size.Y.Scale == 1 and slider.title.TextWrapped, "live translated text triggers remeasurement")
local beforeTrack = slider.track.Position
slider.dragging = true
slider.main.AbsoluteSize = Vector2.new(199, 100)
slider:_layoutConexaoControl()
check(slider.track.Position == beforeTrack, "pending reflow cannot move the track under a held pointer")
slider:_endDrag()
check(slider._controlLayout.mode == "compact", "pending layout applies after release")
do
    local measure, rawContainer = service.GetTextBoundsAsync, slider.container
    local changed = false
    slider.container = setmetatable({}, {
        __index = function(_, property) return rawContainer[property] end,
        __newindex = function(_, property, value)
            if property == "Size" then assert(value.X.Offset <= slider.main.AbsoluteSize.X, "a stale font measurement must not commit the old wider layout") end
            rawContainer[property] = value
        end,
    })
    service.GetTextBoundsAsync = function(self, params)
        if not changed and params.Width < math.huge then
            changed = true
            slider.main.AbsoluteSize = Vector2.new(199, 100)
            slider.main:GetPropertyChangedSignal("AbsoluteSize"):Fire()
        end
        return measure(self, params)
    end
    slider.main.AbsoluteSize = Vector2.new(426, 100)
    slider.title.Text = "Uma nova medição interrompida por outra alteração da janela"
    slider.title:GetPropertyChangedSignal("Text"):Fire()
    check(changed and slider._controlLayout.mode == "compact", "a resize during font measurement commits only the latest viewport layout")
    slider.container, service.GetTextBoundsAsync = rawContainer, measure
end
local row = tab:CreateGroup()
local column = row:CreateGroup({ direction = "column" })
local nested = column:CreateSlider({ name = "Slider dentro de uma coluna", value = 50 })
nested.main.AbsoluteSize = Vector2.new(199, 100)
local beforeX = nested.main.Size.X
nested:_layoutConexaoControl()
check(nested.main.Size.X == beforeX and nested._controlLayout.mode == "compact", "column-controlled widths survive responsive layout")
local dropdown = tab:CreateDropdown({ name = "Selecionar a configuração previamente salva", options = { "Nome de uma configuração longa" }, value = "Nome de uma configuração longa" })
dropdown.main.AbsoluteSize = Vector2.new(420, 100)
dropdown:_layoutConexaoHeader()
local labelRect, selectedRect = rect(dropdown.title, dropdown.main, 420, dropdown.main.Size.Y.Offset), rect(dropdown.selectedLabel, dropdown.main, 420, dropdown.main.Size.Y.Offset)
check(dropdown.main.Size.Y.Offset == 70, "long dropdown titles stack before they collide with selected values")
separate(labelRect, selectedRect, "dropdown title and selection")
window:Unload()
check(#window.connections == 0, "control layout listeners are released on unload")
print("PASS: " .. checks .. " responsive control geometry and interaction checks")
