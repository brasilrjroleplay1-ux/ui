-- Exercise the actual notification presenter, lifecycle and responsive stack with simulated services.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local run, textService = game:GetService("RunService"), game:GetService("TextService")
local originalMeasure = textService.GetTextBoundsAsync
textService.GetTextBoundsAsync = function(_, p)
    local width, lines, size = 0, 0, p.Size or 16
    for line in (tostring(p.Text) .. "\n"):gmatch("(.-)\n") do
        local extent = (utf8.len(line) or #line) * size * 0.55
        width = math.max(width, extent)
        lines += math.max(1, math.ceil(extent / math.max(1, p.Width)))
    end
    return Vector2.new(math.min(width, p.Width), math.ceil(lines * size * 1.2))
end
local w = UI:CreateWindow({ Id = "Feedback372", name = "CONEXÃO STUDIO", theme = "conexao", configuration = { autoSave = false, autoLoad = false } })
local manager = w.Feedback
for _, m in ipairs(table.clone(manager.messages)) do m:_destroy() end
local function tick(dt) run.Heartbeat:Fire(dt) end
local function clear() for _, m in ipairs(table.clone(manager.messages)) do m:_destroy() end end
local previousInstances, previousConnections = #w.instances, #w.connections
for _, props in ipairs({ {}, { content = "Message only" }, { title = "" }, { title = "  \n\t" }, { title = false }, { title = 42 }, { Title = "" } }) do
    local ok = pcall(function() w:Notify(props) end)
    check(not ok, "Notify rejects a missing, blank or non-text title")
end
check(#w.instances == previousInstances and #w.connections == previousConnections and #manager.messages == 0, "invalid notification titles create no UI or listeners")
for _, props in ipairs({ { title = "Só título" }, { title = "Só título", content = "" }, { Title = "Só título", Content = "" } }) do
    local message = w:Notify(props)
    check(message.title == "Só título" and message.content == "" and not message.descriptionLabel, "an omitted or empty message renders a title-only card without a description")
    message:_destroy()
end
local n = w:Notify({ title = "Escolhas salvas", content = "Pode continuar de onde parou.", type = "success", duration = 4 })
check(n.__type == "Notification" and n.caption.Text == "CONCLUÍDO" and n.state == "entering" and n.titleLabel.FontFace.Weight == Enum.FontWeight.Bold, "Notify presents the new semantic card and bold heading")
check(n.main.Parent == w.notifications and n.progress.Size.X.Scale == 1 and n.closeButton and n.iconPlate, "the card includes a separate icon plate, dismiss button and duration bar")
tick(0.32)
check(n.state == "visible" and n.elapsed == 0, "dwell begins after the entrance finishes")
tick(1)
check(n.elapsed == 1 and math.abs(n.progress.Size.X.Scale - 0.75) < 0.00001, "remaining-time bar follows the dwell clock")
n.body.MouseEnter:Fire();tick(2)
check(n.elapsed == 1 and n.state == "visible", "hover pauses the dwell and countdown")
n.body.MouseLeave:Fire();tick(3)
check(n.state == "exiting" and n._dismissed and n.progress.Size.X.Scale == 0, "duration expiry fades and collapses the notification")
tick(0.3)
check(n.state == "destroyed" and not n.main.Parent and #n.connections == 0 and not table.find(manager.messages, n), "expiry releases every message instance and handler")
local icon = w:Notify({ Title = "Ícone próprio", Content = "Continua funcionando", Icon = 125823673784681, Duration = 3 })
check(icon.iconLabel.Image ~= "" and icon.title == "Ícone próprio" and icon.content == "Continua funcionando", "existing PascalCase properties and custom image icons stay compatible")
icon.closeButton.MouseButton1Click:Fire()
check(icon.state == "exiting", "the close button dismisses a live message")
icon:Close();tick(0.3)
check(icon.state == "destroyed", "dismiss is safe to repeat")
local click = w:Notify({ title = "Toque para fechar" })
click.body.InputBegan:Fire({ UserInputType = Enum.UserInputType.Touch })
check(click.state == "exiting", "short messages retain tap-to-dismiss")
tick(0.3)
local top = w:Toast({ title = "Tudo pronto", subtitle = "Suas escolhas foram salvas", type = "success", duration = 5 })
local bottom = w:Toast({ Title = "Aviso", Subtitle = "Outro local", Position = "bOtToM", Type = "warning" })
check(top.main.Parent == w._toastsTop and bottom.main.Parent == w._toastsBottom and top.stack ~= bottom.stack, "Top/Bottom toasts retain independent stack positions")
local avatar = w:Toast({ title = "Spec User", subtitle = "Conectado como", subtitleAbove = true, avatar = 12345, minWidth = 240 })
check(avatar.iconLabel.Image:find("w=420&h=420", 1, true) and avatar.width >= 240 and avatar.descriptionLabel.Position.Y.Offset < avatar.titleLabel.Position.Y.Offset, "welcome toast keeps the 420px untinted avatar, minimum width and subtitle-above layout")
check(not w.themeProperties[avatar.iconLabel] or not w.themeProperties[avatar.iconLabel].ImageColor3, "player photos are not recolored like glyph icons")
clear()
local function rect(node, width, height)
    local s, p, a = node.Size, node.Position, node.AnchorPoint
    local ww, hh = s.X.Scale * width + s.X.Offset, s.Y.Scale * height + s.Y.Offset
    return { x = p.X.Scale * width + p.X.Offset - a.X * ww, y = p.Y.Scale * height + p.Y.Offset - a.Y * hh, w = ww, h = hh }
end
local function inside(node, width, height, message)
    local r = rect(node, width, height)
    check(r.w > 0 and r.h > 0 and r.x >= -0.01 and r.y >= -0.01 and r.x + r.w <= width + 0.01 and r.y + r.h <= height + 0.01, message)
    return r
end
local oldCamera = workspace.CurrentCamera
local camera = Instance.new("Camera")
workspace.CurrentCamera = camera
local oldInset = game:GetService("GuiService"):GetGuiInset()
for _, size in ipairs({ Vector2.new(200, 240), Vector2.new(320, 568), Vector2.new(568, 320), Vector2.new(768, 1024), Vector2.new(1920, 1080) }) do
    camera.ViewportSize = size
    game:GetService("GuiService")._setGuiInset(Vector2.new(0, 24))
    local card = w:Notify({ title = "Título com mais informações para testar a quebra de linha", content = string.rep("Conteúdo da notificação com detalhes. ", 25), type = "warning", duration = 10 })
    local root = inside(card.stack.root, size.X, size.Y, "notification stack remains inside the viewport and GUI insets")
    check(root.y >= 32 and card.width <= root.w and card.height + 8 <= root.h, "the new card fits both portrait and landscape safe areas")
    inside(card.iconPlate, card.width, card.height, "icon plate fits the card")
    local close = inside(card.closeButton, card.width, card.height, "dismiss button fits the card")
    local caption = inside(card.caption, card.width, card.height, "category fits the card")
    local column = inside(card.container, card.width, card.height, "wrapped message viewport fits the card")
    check(column.x + column.w < close.x and caption.x + caption.w < close.x, "close never overlaps message text")
    inside(card.progressTrack, card.width, card.height, "duration bar stays inside the rounded surface")
    inside(card.titleLabel, column.w, card.container.CanvasSize.Y.Offset, "long title remains reachable in the message canvas")
    inside(card.descriptionLabel, column.w, card.container.CanvasSize.Y.Offset, "long description remains reachable in the message canvas")
    check(card.scrollable and card.container.ScrollingEnabled and card.container.ClipsDescendants, "oversized copy scrolls inside a bounded card")
    card.body.InputBegan:Fire({ UserInputType = Enum.UserInputType.Touch })
    check(not card._dismissed, "scrolling long copy does not immediately dismiss it")
    clear()
    for _, position in ipairs({ "Top", "Bottom" }) do
        local toast = w:Toast({ title = string.rep("Texto longo ", 15), subtitle = string.rep("Detalhes ", 10), position = position })
        inside(toast.stack.root, size.X, size.Y, "toast stack stays in the safe viewport")
        check(toast.width <= toast.stack.root.Size.X.Offset and toast.height + 8 <= toast.stack.root.Size.Y.Offset, "long toast fits narrow screens without spilling horizontally")
        clear()
    end
end
local gui = game:GetService("GuiService")
local getInset = gui.GetGuiInset
gui.GetGuiInset = function() return Vector2.new(40, 24), Vector2.new(0, 8) end
camera.ViewportSize = Vector2.new(320, 568)
local notch = w:Toast({ title = "Área segura", minWidth = 320 })
local notchRect = rect(notch.stack.root, 320, 568)
check(notchRect.x >= 40 and notchRect.x + notchRect.w <= 320, "asymmetric screen insets also shift the toast center into the safe area")
clear()
gui.GetGuiInset = getInset
camera.ViewportSize = Vector2.new(320, 320)
manager:Geometry(true)
for i = 1, 20 do w:Notify({ title = "Aviso " .. i, duration = 20 }) end
local stack = manager.stacks.notifications
local height = 0
for _, m in ipairs(stack.live) do height += m.height + 8 end
check(#stack.live <= 6 and height <= manager.bounds.height and stack.live[#stack.live].title == "Aviso 20", "stack pressure retires oldest messages while preserving the newest within screen height")
clear()
camera.ViewportSize = Vector2.new(1024, 768)
local light = w:Notify({ title = "Tema", type = "error", duration = 20 })
local oldGradient, oldGlyph = light.gradient.Color, light.iconPlate.BackgroundColor3
w:ChangeTheme("porcelana")
check(light.gradient.Color ~= oldGradient and light.iconPlate.BackgroundColor3 ~= oldGlyph and light.titleLabel.TextColor3 == w.theme.ContentColor, "visible notifications follow light/dark theme changes with adjusted semantic accents")
w:Hide()
check(light:_alive() and light.body.BackgroundTransparency < 1, "feedback can remain readable while the main panel is hidden")
w:Show()
clear()
-- Empty stack containers are reused; individual messages must not accumulate resources.
w:Notify({ title = "Seed" }):_destroy()
w:Toast({ title = "Seed" }):_destroy()
w:Toast({ title = "Seed", position = "Bottom" }):_destroy()
local connections, instances = #w.connections, #w.instances
for i = 1, 20 do
    local m = w:Notify({ title = "Repetição", duration = 0.1 })
    m:Close();tick(0.3)
end
check(#w.connections == connections and #w.instances == instances and #manager.messages == 0, "repeated notification use does not leak handlers or owned instances")
local pending = w:Notify({ title = "Pendente" })
local pendingToast = w:Toast({ title = "Pendente" })
w:Unload()
check(pending.state == "destroyed" and pendingToast.state == "destroyed" and manager.destroyed and #w.connections == 0 and #w.instances == 0, "unload cancels active effects and destroys all feedback resources")
pending:Close();pendingToast:Close();tick(10)
check(w:Notify({ title = "Tarde" }) == nil and w:Toast({ title = "Tarde" }) == nil, "late callbacks cannot recreate notifications after unload")
local dying = UI:CreateWindow({ Id = "FeedbackMeasureRace", configuration = { autoSave = false, autoLoad = false } })
local measure = textService.GetTextBoundsAsync
local interrupted = false
textService.GetTextBoundsAsync = function(service, p)
    if not interrupted and p.Text == "Unload during font measurement" then interrupted = true dying:Unload() end
    return measure(service, p)
end
local aborted = dying:Notify({ title = "Unload during font measurement" })
check(interrupted and aborted.state == "destroyed" and #dying.connections == 0 and #dying.instances == 0, "a window removed during yielding font measurement cannot revive the pending notification")
textService.GetTextBoundsAsync = measure
workspace.CurrentCamera = oldCamera
camera:Destroy()
game:GetService("GuiService")._setGuiInset(oldInset)
textService.GetTextBoundsAsync = originalMeasure
print("PASS: " .. checks .. " notification styling, responsive layout and lifecycle checks")
