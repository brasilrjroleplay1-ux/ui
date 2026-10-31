--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Client-only, reversible changes. No world instances are destroyed and no remote code is loaded.
local Runtime = {}
local active
local function finite(n) return type(n) == "number" and n == n and math.abs(n) < math.huge end
local function read(object, key)
    local ok, value = pcall(function() return object[key] end)
    return ok, value
end
local function write(object, key, value) return pcall(function() object[key] = value end) end
local function api(name)
    local scopes = { getfenv(), _G }
    if type(getgenv) == "function" then local ok, env = pcall(getgenv) if ok and type(env) == "table" then table.insert(scopes, env) end end
    for _, scope in ipairs(scopes) do local ok, fn = pcall(function() return scope[name] end) if ok and type(fn) == "function" then return fn end end
end
local function records() return setmetatable({}, { __mode = "k" }) end
local function patch(store, object, key, value)
    local ok, before = read(object, key)
    if not ok or before == nil then return false end
    if not write(object, key, value) then return false end
    store[object] = store[object] or {}
    if not store[object][key] then store[object][key] = { before = before, applied = value }
    else store[object][key].applied = value end
    return true
end
local function restore(store)
    for object, fields in pairs(store) do
        for key, saved in pairs(fields) do
            local ok, current = read(object, key)
            if ok and current == saved.applied then write(object, key, saved.before) end
        end
    end
    table.clear(store)
end
local function is(object, class) local ok, value = pcall(object.IsA, object, class) return ok and value end
local function descendants(root) local ok, values = pcall(root.GetDescendants, root) return ok and values or {} end
function Runtime.new(window)
    local run, lighting, players = game:GetService("RunService"), game:GetService("Lighting"), game:GetService("Players")
    local guiOK, playerGui = pcall(function() return players.LocalPlayer:FindFirstChild("PlayerGui") end)
    if not guiOK then playerGui = nil end
    -- Some hosts expose PlayerGui directly before FindFirstChild is usable.
    if not playerGui then local ok, value = pcall(function() return players.LocalPlayer.PlayerGui end) if ok then playerGui = value end end
    local self = { window = window, connections = {}, graphics = records(), interfaces = records(), queue = {}, next = 1,
        guiConnections = {}, watched = records(),
        state = { lowGraphics = false, mode = "Equilibrado", disable3D = false, background = "Preto", hideUI = false, showStats = false }, closed = false }
    self.setCap, self.getCap = api("setfpscap") or api("set_fps_cap"), api("getfpscap") or api("get_fps_cap")
    if self.getCap then local ok, value = pcall(self.getCap) if ok and finite(value) and value >= 0 then self.originalCap = value end end
    if active and active.capChanged then self.originalCap = active.originalCap or 60 end
    self.state.fpsCap = math.clamp(math.floor(self.originalCap and self.originalCap > 0 and self.originalCap or 60), 30, 360)
    self.quality = nil
    if type(UserSettings) == "function" then
        local ok, value = pcall(function() return UserSettings():GetService("UserGameSettings") end)
        if ok then self.quality = value end
    end
    local ok, method = read(run, "Set3dRenderingEnabled")
    self.render = ok and type(method) == "function" and method or nil
    local getterOK, getter = read(run, "Is3dRenderingEnabled")
    if getterOK and type(getter) == "function" then
        local got, enabled = pcall(getter, run)
        if got and type(enabled) == "boolean" then self.originalRender = enabled end
    end
    if self.originalRender == nil then self.originalRender = true end
    if active and active.renderChanged then self.originalRender = active.originalRender end
    local colors = { Preto = Color3.fromRGB(0, 0, 0), Grafite = Color3.fromRGB(18, 20, 26), Branco = Color3.new(1, 1, 1) }
    self.backdrop = window:Create("Frame", { Name = "PerformanceBackdrop", Parent = window.screenGui, Size = UDim2.fromScale(1, 1), BackgroundColor3 = colors.Preto,
        Visible = false, BorderSizePixel = 0, ZIndex = 0, Active = false })
    self.stats = window:Create("TextLabel", { Name = "PerformanceStats", Parent = window.screenGui, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8),
        Size = UDim2.fromOffset(190, 30), Text = "— FPS  ·  — ms", TextSize = 13, BackgroundTransparency = 0.15, BorderSizePixel = 0,
        Visible = false, Active = false, ZIndex = 4500,
    }, { BackgroundColor3 = "StatBackground", TextColor3 = "ContentColor", FontFace = "TitleFont" })
    window:Create("UICorner", { Parent = self.stats, CornerRadius = UDim.new(0, 9) })
    window:Create("UIStroke", { Parent = self.stats, Thickness = 1, Transparency = 0.6 }, { Color = "AccentStroke" })
    function self:Acquire()
        if active and active ~= self then active:Restore() end
        active = self
    end
    function self:GraphicsNode(object)
        if self.closed or not self.state.lowGraphics then return end
        local parentOK, parent = read(object, "Parent")
        if parentOK and parent == nil then return end
        if is(object, "PostEffect") then patch(self.graphics, object, "Enabled", false) end
        if self.state.mode ~= "Leve" then
            for _, class in ipairs({ "ParticleEmitter", "Trail", "Beam", "Fire", "Smoke", "Sparkles" }) do
                if is(object, class) then patch(self.graphics, object, "Enabled", false) break end
            end
        end
        if self.state.mode == "Máximo" then
            if is(object, "BasePart") then
                patch(self.graphics, object, "CastShadow", false)
                patch(self.graphics, object, "Reflectance", 0)
            elseif is(object, "Decal") or is(object, "Texture") then patch(self.graphics, object, "Transparency", 1) end
        end
    end
    function self:QueueGraphics()
        self.queue, self.next = {}, 1
        if not self.state.lowGraphics then return end
        for _, root in ipairs({ workspace, lighting }) do for _, node in ipairs(descendants(root)) do table.insert(self.queue, node) end end
    end
    function self:SetLowGraphics(enabled)
        restore(self.graphics)
        self.state.lowGraphics, self.queue, self.next = false, {}, 1
        if not enabled then return true end
        self:Acquire()
        local applied = patch(self.graphics, lighting, "GlobalShadows", false)
        if self.quality then applied = patch(self.graphics, self.quality, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1) or applied end
        if not applied then return false, "Este cliente não permite ajustar a qualidade gráfica." end
        self.state.lowGraphics = true
        if self.state.mode ~= "Leve" then
            patch(self.graphics, lighting, "EnvironmentDiffuseScale", 0)
            patch(self.graphics, lighting, "EnvironmentSpecularScale", 0)
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                patch(self.graphics, terrain, "WaterWaveSize", 0)
                patch(self.graphics, terrain, "WaterWaveSpeed", 0)
                patch(self.graphics, terrain, "WaterReflectance", 0)
            end
        end
        self:QueueGraphics()
        return true
    end
    function self:HideGui(node)
        if is(node, "ScreenGui") and node ~= window.screenGui and not tostring(node.Name):match("^ConexaoUI3_") then
            patch(self.interfaces, node, "Enabled", false)
            if not self.watched[node] then
                self.watched[node] = true
                local connections = {}
                table.insert(connections, window:ConnectFor(self, node:GetPropertyChangedSignal("Enabled"), function()
                    if self.state.hideUI and node.Enabled ~= false then patch(self.interfaces, node, "Enabled", false) end
                end))
                table.insert(connections, window:ConnectFor(self, node.Destroying, function()
                    window:DisconnectMany(self, connections)
                    for _, connection in ipairs(connections) do local at = table.find(self.guiConnections, connection) if at then table.remove(self.guiConnections, at) end end
                end))
                for _, connection in ipairs(connections) do table.insert(self.guiConnections, connection) end
            end
        end
    end
    function self:RestoreInterfaces()
        self.state.hideUI = false
        window:DisconnectMany(self, table.clone(self.guiConnections))
        table.clear(self.guiConnections);table.clear(self.watched)
        restore(self.interfaces)
    end
    function self:SetHideUI(enabled)
        if enabled and not playerGui then return false, "A interface deste jogo ainda não está disponível." end
        self:RestoreInterfaces()
        self.state.hideUI = enabled
        if enabled then self:Acquire() for _, node in ipairs(descendants(playerGui)) do self:HideGui(node) end end
        return true
    end
    function self:SetRendering(disabled)
        if not self.render then return false, "Este cliente não oferece controle da renderização 3D." end
        self:Acquire()
        local success, result = pcall(self.render, run, if disabled then false else self.originalRender)
        if not success or result == false then return false, "O cliente recusou a alteração da renderização 3D." end
        self.state.disable3D, self.renderChanged = disabled, disabled
        self.backdrop.Visible = disabled
        return true
    end
    function self:SetCap(value)
        if not self.setCap then return false, "Este executor não oferece controle do limite de FPS." end
        if not finite(value) or value < 30 or value > 360 then return false, "Escolha um limite entre 30 e 360 FPS." end
        self:Acquire()
        local success, result = pcall(self.setCap, math.floor(value))
        if not success or result == false then return false, "O executor recusou o limite de FPS." end
        self.state.fpsCap, self.capChanged = math.floor(value), true
        return true
    end
    function self:Set(key, value)
        if self.closed or window.unloaded then return false, "Janela encerrada." end
        if key == "lowGraphics" then return self:SetLowGraphics(value == true)
        elseif key == "hideUI" then return self:SetHideUI(value == true)
        elseif key == "disable3D" then return self:SetRendering(value == true)
        elseif key == "fpsCap" then return self:SetCap(value)
        elseif key == "mode" then
            if not ({ Leve = true, Equilibrado = true, ["Máximo"] = true })[value] then return false, "Modo inválido." end
            self.state.mode = value
            if self.state.lowGraphics then return self:SetLowGraphics(true) end
        elseif key == "background" then
            if not colors[value] then return false, "Cor inválida." end
            self.state.background, self.backdrop.BackgroundColor3 = value, colors[value]
        elseif key == "showStats" then self.state.showStats, self.stats.Visible = value == true, value == true
        else return false, "Opção inválida." end
        return true
    end
    function self:Restore()
        restore(self.graphics);self:RestoreInterfaces()
        self.queue, self.next = {}, 1
        if self.renderChanged and self.render then pcall(self.render, run, self.originalRender) end
        if self.capChanged and self.setCap then pcall(self.setCap, self.originalCap or 60) end
        self.renderChanged, self.capChanged = false, false
        self.state.fpsCap = math.clamp(math.floor(self.originalCap and self.originalCap > 0 and self.originalCap or 60), 30, 360)
        self.state.lowGraphics, self.state.disable3D, self.state.hideUI, self.state.showStats = false, false, false, false
        self.backdrop.Visible, self.stats.Visible = false, false
        if active == self then active = nil end
        if self.onRestore then pcall(self.onRestore) end
    end
    function self:Destroy() if self.closed then return end self:Restore() self.closed = true end
    local function added(signal, callback) if signal and type(signal.Connect) == "function" then window:ConnectFor(self, signal, callback) end end
    added(workspace.DescendantAdded, function(node) if self.state.lowGraphics then table.insert(self.queue, node) end end)
    added(lighting.DescendantAdded, function(node) if self.state.lowGraphics then table.insert(self.queue, node) end end)
    if playerGui then added(playerGui.DescendantAdded, function(node) if self.state.hideUI then self:HideGui(node) end end) end
    local elapsed = 0
    window:ConnectFor(self, run.Heartbeat, function(delta)
        if self.closed or window.unloaded then return end
        local started, count = os.clock(), 0
        while self.next <= #self.queue and count < 120 and os.clock() - started < 0.003 do
            local node = self.queue[self.next];self.next += 1;count += 1
            self:GraphicsNode(node)
        end
        if self.next > #self.queue then self.queue, self.next = {}, 1 end
        if finite(delta) and delta >= 0 then elapsed += delta end
        if self.state.showStats and elapsed >= 0.5 then
            elapsed = 0
            local stats = window.GetSessionStats and window:GetSessionStats()
            self.stats.Text = stats and (stats.fpsText .. " FPS  ·  " .. stats.pingText) or "— FPS  ·  — ms"
            local okInset, inset = pcall(function() return game:GetService("GuiService"):GetGuiInset() end)
            self.stats.Position = UDim2.new(0.5, 0, 0, okInset and inset.Y + 8 or 8)
            local view = window.screenGui.AbsoluteSize
            self.stats.Size = UDim2.fromOffset(math.min(190, math.max(1, view.X - 16)), 30)
        end
    end)
    return self
end
return Runtime
