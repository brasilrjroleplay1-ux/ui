--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Runtime = require(script.Parent.PerformanceRuntime)
local Card = require(script.Parent.Collapsible)
local Preferences = require(script.Parent.Preferences)
local Performance = {}
function Performance.attach(window, tab)
    local engine = Runtime.new(window)
    local self = { engine = engine, controls = {}, restoring = true }
    window.Performance = self
    local saved = table.clone(window.UIPreferences.performance or {})
    local restore = window.configuration.autoLoad == true
    local defaults = table.clone(engine.state)
    local function save(force)
        if self.restoring or window.unloaded or (not force and not window.configuration.autoSave) then return true end
        local state = table.clone(engine.state)
        -- Merely opening the UI must not turn the slider's default into an FPS override.
        if not engine.capChanged then state.fpsCap = nil end
        state.graphicsCollapsed, state.frameCollapsed = self.graphics.collapsed, self.frames.collapsed
        window.UIPreferences.performance = state
        return Preferences.save(window)
    end
    local function change(key, value)
        local previous = engine.state[key]
        local ok, reason = engine:Set(key, value)
        if not ok then
            engine.state[key] = previous
            if self.Sync then self:Sync()
            elseif self.controls[key] then self.controls[key]:Set(previous, true) end
            if not self.restoring then window:Toast({ title = "Ajuste indisponível", subtitle = reason, type = "warning" }) end
            return
        end
        save(false)
    end
    local row = tab:CreateGroup()
    self.row = row
    row.name = "Otimização de desempenho"
    -- Keep the native group as the owner; only its two-card positioning is customized.
    local storage = window:Create("Frame", { Parent = row.main, Name = "PreservedPerformanceLayout", Visible = false, BackgroundTransparency = 1 })
    row.layout.Parent = storage
    row.main.AutomaticSize = Enum.AutomaticSize.None
    local graphics = row:CreateGroup({ direction = "column" })
    local frames = row:CreateGroup({ direction = "column" })
    self.graphics = Card.attach(graphics, "GRÁFICOS", "graphics", saved.graphicsCollapsed ~= false, function() save(false) end)
    self.frames = Card.attach(frames, "TAXA DE QUADROS", "performance", saved.frameCollapsed == true, function() save(false) end)
    local function initial(key) return restore and saved[key] ~= nil and saved[key] or defaults[key] end
    local function toggle(host, key, name)
        local c = host:CreateToggle({ name = name, value = false, forgetState = true, callback = function(value) change(key, value) end })
        self.controls[key] = c
        return c
    end
    toggle(graphics, "lowGraphics", "Gráficos reduzidos")
    self.controls.mode = graphics:CreateDropdown({ name = "Modo de otimização", options = { "Leve", "Equilibrado", "Máximo" }, value = initial("mode"), forgetState = true,
        callback = function(value) change("mode", value) end })
    local rendering = toggle(graphics, "disable3D", "Desativar renderização 3D")
    if not engine.render then rendering:Lock("O cliente não oferece controle da renderização 3D.") end
    self.controls.background = graphics:CreateDropdown({ name = "Cor de fundo", options = { "Preto", "Grafite", "Branco" }, value = initial("background"), forgetState = true,
        description = "Usada quando a renderização 3D estiver desativada.", callback = function(value) change("background", value) end })
    toggle(graphics, "hideUI", "Ocultar interface do jogo")
    local fps = frames:CreateSlider({ name = "Limite de FPS", range = { 30, 360 }, increment = 1, value = initial("fpsCap"), suffix = " FPS", format = "number", forgetState = true,
        description = "Limita os quadros; o resultado depende do aparelho e do jogo.",
        callback = function(value, dragging) if not dragging then change("fpsCap", value) end end })
    self.controls.fpsCap = fps
    if not engine.setCap then fps:Lock("Este executor não oferece controle do limite de FPS.") end
    toggle(frames, "showStats", "Mostrar FPS e ping")
    frames:CreateButton({ name = "Restaurar desempenho", callback = function() engine:Restore() save(true) end })
    function self:Sync()
        for key, control in pairs(self.controls) do control:Set(engine.state[key], true) end
    end
    engine.onRestore = function() self:Sync() end
    local layoutBusy = false
    function row:Layout()
        if layoutBusy or window.unloaded or not self.main.Parent then return end
        layoutBusy = true
        local width = self.main.AbsoluteSize.X
        if width > 0 then
            local columns = width >= 640
            local cardWidth = columns and (width - 12) / 2 or width
            graphics.main.Position, graphics.main.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(cardWidth, window.Performance.graphics.height)
            frames.main.Position = UDim2.fromOffset(columns and cardWidth + 12 or 0, columns and 0 or window.Performance.graphics.height + 12)
            frames.main.Size = UDim2.fromOffset(cardWidth, window.Performance.frames.height)
            local height = columns and math.max(window.Performance.graphics.height, window.Performance.frames.height) or window.Performance.graphics.height + window.Performance.frames.height + 12
            self.main.Size = UDim2.new(1, -20, 0, height)
        end
        layoutBusy = false
    end
    self.graphics.onLayout, self.frames.onLayout = function() row:Layout() end, function() row:Layout() end
    window:ConnectFor(row, row.main:GetPropertyChangedSignal("AbsoluteSize"), function() row:Layout() end)
    row:Layout()
    self.graphics:Layout(false);self.frames:Layout(false)
    if restore then
        for _, key in ipairs({ "mode", "background", "fpsCap", "lowGraphics", "showStats", "hideUI", "disable3D" }) do
            if saved[key] ~= nil and (saved[key] ~= engine.state[key] or key == "fpsCap") then
                if not self.controls[key].locked then change(key, saved[key]) end
            end
        end
    end
    self:Sync()
    self.restoring = false
    row:_setShown(not window.hidden, false)
    local previousSave = window.Save
    function window:Save(...)
        local prefsOK = save(true)
        local result = previousSave(self, ...)
        return result and prefsOK
    end
    window.SaveConfig = window.Save
    local unload = window.Unload
    function window:Unload(...)
        engine:Destroy()
        return unload(self, ...)
    end
    return row
end
return Performance
