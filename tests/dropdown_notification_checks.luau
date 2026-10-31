-- Actual public bundle: split content, checkboxes, optional messages and saved state.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local run, input, gui = game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("GuiService")
local camera, getInset = workspace.CurrentCamera, gui.GetGuiInset
local testCamera = Instance.new("Camera")
workspace.CurrentCamera = testCamera
testCamera.ViewportSize = Vector2.new(1280, 768)
gui.GetGuiInset = function() return Vector2.new(0, 24), Vector2.new(0, 0) end
local w = UI:CreateWindow({ Id = "Dropdown392", name = "Dropdown test", configuration = { fileName = "dropdown390", autoSave = false, autoLoad = false } })
w.size, w.main.AbsoluteSize, w.main.AbsolutePosition = UDim2.fromOffset(800, 600), Vector2.new(800, 600), Vector2.new(100, 60)
w:_applyRailWidth()
local originalWidth = w._applyRailWidth
local originalElementsSize, originalElementsPosition = w.elements.Size, w.elements.Position
local originalFadeSize, originalFadePosition = w.bottomFade.Size, w.bottomFade.Position
local tab = w:CreateTab({ name = "Options" })
tab:Select()
tab.tabPage.AbsolutePosition, tab.tabPage.AbsoluteSize = Vector2.new(296, 104), Vector2.new(604, 556)
local options = { "Um", "Dois", "Três", "Quatro", "Cinco" }
local callbackCount = 0
local multi = tab:CreateDropdown({ name = "Marque opções", flag = "multi", multiSelect = true, options = options, value = { "Um" }, callback = function() callbackCount += 1 end })
multi.main.AbsolutePosition, multi.main.AbsoluteSize = Vector2.new(316, 220), Vector2.new(300, 41)
local function heartbeat() run.Heartbeat:Fire(0.016) end
local function rect(node)
    local parent = w.main.AbsoluteSize
    local width, height = parent.X * node.Size.X.Scale + node.Size.X.Offset, parent.Y * node.Size.Y.Scale + node.Size.Y.Offset
    local x = parent.X * node.Position.X.Scale + node.Position.X.Offset - node.AnchorPoint.X * width
    local y = parent.Y * node.Position.Y.Scale + node.Position.Y.Offset - node.AnchorPoint.Y * height
    return { x = x, y = y, width = width, height = height }
end
local function insideContent(picker)
    local p, b = rect(picker.main), picker.bounds
    check(p.x >= b.x and p.y >= b.y and p.x + p.width <= b.x + b.width and p.y + p.height <= b.y + b.height, "options stay inside the window's content bounds")
    local controls = rect(w.elements)
    check(controls.width > 0 and controls.height > 0, "the original controls retain visible space")
    if picker.mode == "right" then
        check(controls.x + controls.width <= p.x and controls.height == b.height, "the controls and options occupy separate left/right columns")
    else
        check(controls.y + controls.height <= p.y and controls.width == b.width, "narrow windows divide controls above and options below without overlap")
    end
end
local tabCount = #w.tabs
local pageChildren = #w.elements:GetChildren()
multi.interact.MouseButton1Click:Fire()
local p = multi.selectionPanel
check(p.mode == "right" and rect(p.main).width <= 440, "a regular window reserves a bounded options column on the inside right")
check(#w.tabs == tabCount and w.selectedTab == tab and p.main.Parent == w.main and not p.scrim, "the options are a child of the main panel, with no replacement tab or fullscreen blocker")
check(#w.elements:GetChildren() == pageChildren, "the options never become a child page of the native UIPageLayout")
insideContent(p)
check(w.elements.Size ~= originalElementsSize and w.elements.Position ~= originalElementsPosition and w.size == UDim2.fromOffset(800, 600), "opening divides content without resizing the actual window")
check(multi.panel.Visible == false and multi.main.Size.Y.Offset <= 70, "the dropdown's own row stays collapsed")
check(p.grid:IsA("UIGridLayout") and p.columns == 2 and #p.items == 5 and p.grid.CellSize.Y.Offset >= 44, "the options use two columns of touch-sized cards when they fit")
check(p.items[1].checkbox.AnchorPoint.X == 1 and p.items[1].label.Position.X.Offset == 14, "selection marks are on the right of the option title")
check(p.subtitle.Text:find("Escolha várias", 1, true) and #p.actions == 3, "multiple selection is clearly labelled and exposes all bulk actions")
check(p.items[1].marker.Text == "✓" and p.items[2].marker.Text == "", "initial choices have checked and unchecked boxes")
local before = callbackCount
p.items[2].hit.MouseButton1Click:Fire()
check(#multi.value == 2 and p.items[2].marker.Text == "✓" and not p.closed and callbackCount == before + 1, "another row checks independently and invokes one callback")
p.items[2].hit.MouseButton1Click:Fire()
check(#multi.value == 1 and p.items[2].marker.Text == "" and callbackCount == before + 2, "clicking again unchecks only that option")
p.search.Text = "três";p.search:GetPropertyChangedSignal("Text"):Fire()
check(p.items[3].frame.Visible and not p.items[1].frame.Visible, "search filters rows without altering selection")
p.actions[3].MouseButton1Click:Fire()
check(#multi.value == 5 and p.items[5].marker.Text == "✓", "Select all includes filtered-out rows")
p.actions[2].MouseButton1Click:Fire()
check(#multi.value == 0 and p.items[1].marker.Text == "", "Clear unchecks every box")
p.actions[1].MouseButton1Click:Fire()
check(#multi.value == 1 and multi.value[1] == "Um", "Default restores the script's initial choice")
multi:Refresh({ "Um", "Dois", "Três", "Quatro", "Cinco", "Seis" })
check(#p.items == 6 and p.items[1].marker.Text == "✓", "Refresh updates the open list and preserves selected boxes")
w.animating = true;heartbeat()
p.list.AbsoluteWindowSize = Vector2.new(276, 120)
p.grid.AbsoluteContentSize = Vector2.new(268, 260)
p.grid:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
w.animating = false;heartbeat()
check(p.list.CanvasSize.Y.Offset == 266 and p.list.ScrollBarImageTransparency < 1, "option scrolling recovers when geometry arrives during a resize animation")
p.list.CanvasPosition = Vector2.new(0, 146);p.list:GetPropertyChangedSignal("CanvasPosition"):Fire()
p.list.AbsoluteWindowSize = Vector2.new(276, 220);p.list:GetPropertyChangedSignal("AbsoluteWindowSize"):Fire()
check(p.list.CanvasPosition.Y == 46, "a resized list keeps its last row reachable without overscrolling")
p.search.Text = "nada";p.search:GetPropertyChangedSignal("Text"):Fire()
check(p.empty.Visible, "unmatched search shows an empty state")
p.search.Text = "";p.search:GetPropertyChangedSignal("Text"):Fire()
local position = p.main.Position
w.main.AbsolutePosition = Vector2.new(180, 90);heartbeat()
check(p.main.Parent == w.main and p.main.Position == position, "the options move with the parent window without screen-relative positioning")
local accent = p.items[1].frame.BackgroundColor3
w:ChangeTheme("porcelana")
check(p.items[1].frame.BackgroundColor3 ~= accent and p.items[1].label.TextColor3 == w.theme.ContentColor, "open option cards follow light/dark theme changes")
for _, size in ipairs({ Vector2.new(685, 450), Vector2.new(1024, 720), Vector2.new(480, 320), Vector2.new(320, 480), Vector2.new(240, 320), Vector2.new(320, 260) }) do
    w.size, w.main.AbsoluteSize = UDim2.fromOffset(size.X, size.Y), size
    w:_applyRailWidth();heartbeat()
    insideContent(p)
    check(p.columns == (p.main.Size.X.Offset - 32 >= 272 and 2 or 1), "resizing switches between one and two columns based on available card width")
    check(p.grid.CellSize.X.Offset * p.columns + 8 * (p.columns - 1) <= p.main.Size.X.Offset - 32, "option cards fit their list without a horizontal scrollbar")
    check(p.grid.CellSize.X.Offset - 54 > 0 and p.grid.CellSize.Y.Offset == 56, "option titles retain their own space beside the check mark")
    check(not p.closed and p.main.Parent == w.main, "resizing never detaches or closes the internal pane")
    local split = w.elements.Size
    for _ = 1, 5 do w:_applyRailWidth() end
    check(w.elements.Size == split, "repeated native rail layout cannot progressively shrink the controls")
    if p.viewport.ScrollingEnabled then
        check(p.body.Size.Y.Offset >= 212 and p.viewport.CanvasSize.Y.Offset > rect(p.main).height, "short windows make the entire options body scrollable so search and actions remain reachable")
    end
end
p:Close()
check(w.elements.Size.X.Offset == -w.sidebar.Size.X.Offset and w.elements.Size.Y.Offset == -w.layout.chromeHeight, "closing after a narrow resize restores the current rail and full content height")
multi:Open();p = multi.selectionPanel
w.size, w.main.AbsoluteSize = UDim2.fromOffset(800, 600), Vector2.new(800, 600)
w:_applyRailWidth();heartbeat()
input.InputBegan:Fire({ UserInputType = Enum.UserInputType.Touch, Position = w.main.AbsolutePosition + Vector2.new(30, 100) })
check(not p.closed, "touching the controls side does not dismiss the options while scrolling or testing controls")
multi.main.AbsolutePosition = Vector2.new(316, 900);heartbeat()
check(not p.closed, "scrolling the controls keeps the separate options pane open")
multi.main.AbsolutePosition = Vector2.new(316, 220)
input.InputBegan:Fire({ UserInputType = Enum.UserInputType.Touch, Position = Vector2.new(10, 700) })
check(p.closed and not multi._isOpen and w.selectedTab == tab, "touching outside the window closes the options pane")
check(w.elements.Size == originalElementsSize and w.elements.Position == originalElementsPosition and w.bottomFade.Size == originalFadeSize and w.bottomFade.Position == originalFadePosition, "closing restores the full content and fade geometry")
check(w._applyRailWidth == originalWidth, "closing restores the native rail method")
multi:Open();p = multi.selectionPanel
input.InputBegan:Fire({ UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.Escape })
check(p.closed and not multi._isOpen and w.elements.Size == originalElementsSize, "Escape closes the pane and restores content space")
multi:Open();p = multi.selectionPanel;multi:Lock()
check(p.closed and not multi._isOpen, "locking an open dropdown dismisses its pane")
multi:Open();check(not multi._isOpen, "a locked dropdown cannot reopen")
multi:Unlock();multi:Open();p = multi.selectionPanel;w:ToggleMinimise()
check(p.closed and not w._conexaoPanel and w.elements.Size == originalElementsSize, "minimising restores the full content geometry")
w:ToggleMinimise()
local single = tab:CreateDropdown({ name = "Uma", options = options, value = "Um", multiSelect = false })
single:Open();p = single.selectionPanel
check(p.subtitle.Text == "Escolha uma" and #p.actions == 0 and not p.footer.Visible and not p.footerDivider.Visible, "single choice has its own label and no bulk-action footer")
p.items[4].hit.MouseButton1Click:Fire()
check(single:GetValue() == "Quatro" and p.closed and w.selectedTab == tab and w.elements.Size == originalElementsSize, "single choice commits and restores full width without tab navigation")
single:Open();p = single.selectionPanel
check(p.items[4].marker.Text == "✓" and p.items[1].marker.Text == "", "reopening a single-choice picker marks only the current choice")
p.items[2].hit.MouseButton1Click:Fire()
check(single:GetValue() == "Dois" and #single.value == 1, "choosing a new single option replaces the previous value")
local connections, instances = #w.connections, #w.instances
for _ = 1, 10 do multi:Open();multi:Close() end
check(#w.connections == connections and #w.instances == instances and w._applyRailWidth == originalWidth, "reopening leaks no rows, frames, listeners or layout wrappers")
local groupWithDropdown = tab:CreateGroup({ direction = "column" })
local nestedDropdown = groupWithDropdown:CreateDropdown({ name = "Nested dropdown", options = options, value = "Um" })
nestedDropdown:Open()
check(nestedDropdown.selectionPanel.tab == tab and nestedDropdown.selectionPanel.main.Parent == w.main, "a dropdown in a nested group splits the owning window rather than the group")
local previousPane = nestedDropdown.selectionPanel
multi:Open()
check(previousPane.closed and multi.selectionPanel and w.selectedTab == tab, "opening a different dropdown replaces the options and preserves the selected tab")
multi:Close()

local topWindow = UI:CreateWindow({ Id = "TopSplit392", name = "Top layout", sidebarLayout = false, configuration = { autoSave = false, autoLoad = false } })
topWindow.size, topWindow.main.AbsoluteSize = UDim2.fromOffset(800, 500), Vector2.new(800, 500)
local topTab = topWindow:CreateTab({ name = "Top options" })
local topControl = topTab:CreateDropdown({ name = "Top dropdown", options = options })
local topSize, topPosition = topWindow.elements.Size, topWindow.elements.Position
topControl:Open()
local topPane = topControl.selectionPanel
check(topPane.mode == "right" and topPane.main.Parent == topWindow.main and topWindow.selectedTab == topTab, "the top-tab layout also reserves an internal right-hand options column")
check(topWindow.elements.Size.X.Offset == topSize.X.Offset - topPane.main.Size.X.Offset - 18 and topPane.main.Position.Y.Offset >= topWindow.layout.chromeHeight, "top layout controls shrink beside a pane below the tab strip")
topPane:Close()
check(topWindow.elements.Size == topSize and topWindow.elements.Position == topPosition, "closing a top-layout pane restores its original content geometry")
topWindow:Unload()

-- Optional messages never replace or require the user's callback.
local sent, calls, observed = {}, 0, nil
local notify = w.Notify
w.Notify = function(_, props) table.insert(sent, props) return props end
local button = tab:CreateButton({ name = "Optional", notification = true, notificationMessage = "Clicou!", notificationTitle = "Pronto", notificationType = "success", notificationDuration = 7,
    callback = function() calls += 1 end })
check(#sent == 0, "creating an enabled control does not announce it")
button.interact.MouseButton1Click:Fire()
check(calls == 1 and #sent == 1 and sent[1].content == "Clicou!" and sent[1].title == "Pronto" and sent[1].type == "success" and sent[1].duration == 7, "one click runs the action and sends exactly the configured message")
local quiet = tab:CreateButton({ name = "Quiet", notification = false, callback = function() calls += 1 end })
local start = #sent
quiet.interact.MouseButton1Click:Fire()
check(#sent == start and calls == 2, "false needs no message and preserves the callback")
local noCallback = tab:CreateButton({ Name = "Pascal", Notification = true, NotificationTitle = "Pascal", NotificationMessage = "Sem callback" })
noCallback.interact.MouseButton1Click:Fire()
check(sent[#sent].content == "Sem callback" and sent[#sent].title == "Pascal", "PascalCase options and message-only controls work")
local ok = pcall(function() tab:CreateButton({ name = "Invalid", notification = true }) end)
check(not ok, "true requires an explicit non-empty title at creation")
tab:CreateButton({ name = "No validation", notification = false, notificationTitle = false, notificationMessage = false })
for _, invalidTitle in ipairs({ "", "   ", "\n\t", false, 123 }) do
    local ok = pcall(function() tab:CreateButton({ name = "Invalid title", notification = true, notificationTitle = invalidTitle, notificationMessage = "Mensagem" }) end)
    check(not ok, "blank or non-text notificationTitle is rejected even when a message is supplied")
end
for _, message in ipairs({ "", "Com mensagem" }) do
    local onlyTitle = tab:CreateButton({ name = "Title only", notification = true, notificationTitle = "Concluído", notificationMessage = message })
    start = #sent;onlyTitle.interact.MouseButton1Click:Fire()
    check(#sent == start + 1 and sent[#sent].title == "Concluído" and sent[#sent].content == message, "a valid title allows an empty or populated message")
end
local omitted = tab:CreateButton({ name = "Omitted message", notification = true, notificationTitle = "Só o título" })
start = #sent;omitted.interact.MouseButton1Click:Fire()
check(#sent == start + 1 and sent[#sent].content == "", "omitting the message sends a title-only notification")
button:Lock();start = #sent;button.interact.MouseButton1Click:Fire()
check(#sent == start and calls == 2, "Lock blocks both callback and automatic message")
button:Unlock()
local toggle = tab:CreateToggle({ name = "Feature", flag = "notificationToggle", value = false, notification = true, notificationTitle = "Teste",
    notificationMessage = function(state) observed = state return state and "Ativado" or "Desativado" end,
    callback = function() calls += 1 end })
start = #sent;toggle.interact.MouseButton1Click:Fire()
check(observed == true and #sent == start + 1 and sent[#sent].content == "Ativado", "message functions receive the selected toggle value")
toggle.interact.MouseButton1Click:Fire()
check(observed == false and sent[#sent].content == "Desativado", "the same function customizes the off message")
w._loading = true;start = #sent;local callCount = calls
toggle:Set(true)
w._loading = false
check(calls == callCount + 1 and #sent == start, "restore applies callbacks without automatic messages")
toggle:Set(false, true)
check(calls == callCount + 1 and #sent == start, "silent Set skips both callback and message")
local slider = tab:CreateSlider({ name = "Precision", range = { 0, 100 }, increment = 0.25, value = 20, notification = true, notificationTitle = "Teste",
    notificationMessage = function(value, dragging) observed = { value, dragging } return tostring(value) .. "%" end })
start = #sent;slider.callback(30, true)
check(#sent == start, "slider previews do not flood notifications")
slider:Set(73.5)
check(#sent == start + 1 and observed[1] == 73.5 and observed[2] == false and sent[#sent].content == "73.5%", "committing a slider sends its exact value once")
local choices = tab:CreateDropdown({ name = "Choices", flag = "choices", options = options, multiSelect = true, value = {}, notification = true, notificationTitle = "Teste",
    notificationMessage = function(values) return #values == 0 and "Vazio" or table.concat(values, ", ") end })
choices:Open();p = choices.selectionPanel;p.items[2].hit.MouseButton1Click:Fire()
check(sent[#sent].content == "Dois" and not p.closed, "checkbox clicks can notify without closing a multiple-choice list")
choices:Close()
local text = tab:CreateInput({ name = "Text", value = "", notification = true, notificationTitle = "Teste", notificationMessage = function(value) return "Texto: " .. value end })
text.input.Text = "Olá";text.input.FocusLost:Fire()
check(sent[#sent].content == "Texto: Olá", "input commits supply their text to the message")
local bind = tab:CreateKeybind({ name = "Key", value = Enum.KeyCode.F9, notification = true, notificationTitle = "Teste", notificationMessage = function(key) return key.Name end })
input.InputBegan:Fire({ UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.F9 }, false)
check(sent[#sent].content == "F9", "key actions support optional messages")
local color = tab:CreateColorPicker({ name = "Color", color = Color3.fromRGB(1, 2, 3), notification = true, notificationTitle = "Teste", notificationMessage = function(value) return value:ToHex() end })
color:Set(Color3.fromRGB(4, 5, 6))
check(sent[#sent].content:upper() == "040506", "color callbacks supply their selected color")
local group = tab:CreateGroup({ direction = "column" })
local nested = group:CreateButton({ name = "Nested", notification = true, notificationTitle = "Teste", notificationMessage = "No grupo" })
nested.interact.MouseButton1Click:Fire()
check(sent[#sent].content == "No grupo", "nested groups expose the same notification options")
local failing = tab:CreateButton({ name = "Failure", notification = true, notificationTitle = "Teste", notificationMessage = "Wrong success", callback = function() error("test failure") end })
start = #sent;failing.interact.MouseButton1Click:Fire()
check(#sent == start and failing.title.Text == failing.name, "failed actions retain native error guards without misleading automatic messages")
local titleOnly = tab:CreateButton({ name = "Conditional", notification = true, notificationTitle = "Teste", notificationMessage = function() return "" end })
titleOnly.interact.MouseButton1Click:Fire()
check(#sent == start + 1 and sent[#sent].title == "Teste" and sent[#sent].content == "", "an empty function result sends a title-only notification")
multi:Set({ "Dois", "Cinco" });toggle:Set(true);check(w:Save(), "checkboxes still use native persistence")
choices:Open();p = choices.selectionPanel;w:Hide()
check(p.closed and not w._conexaoPanel, "Hide dismisses the list")
w:Show();w.Notify = notify;w:Unload()
check(#w.connections == 0, "Unload releases all picker and control listeners")
local restored = UI:CreateWindow({ Id = "Dropdown390", name = "Dropdown test", configuration = { fileName = "dropdown390", autoSave = false, autoLoad = true } })
local restoredMessages = 0
restored.Notify = function() restoredMessages += 1 end
local restoredTab = restored:CreateTab({ name = "Options" })
local restoredMulti = restoredTab:CreateDropdown({ name = "Marque opções", flag = "multi", options = options, multiSelect = true, value = {}, notification = true, notificationTitle = "Teste", notificationMessage = "Não deve aparecer" })
local restoredToggle = restoredTab:CreateToggle({ name = "Feature", flag = "notificationToggle", value = false, notification = true, notificationTitle = "Teste", notificationMessage = "Não deve aparecer" })
check(#restoredMulti.value == 2 and restoredMulti.value[1] == "Dois" and restoredMulti.value[2] == "Cinco" and restoredToggle.value, "reexecution restores each checkbox and toggle")
check(restoredMessages == 0, "late-created controls never announce restored choices")
restoredMulti:Open();p = restoredMulti.selectionPanel
check(p.items[2].marker.Text == "✓" and p.items[5].marker.Text == "✓" and p.items[1].marker.Text == "", "restored values repaint their exact checked states")
restoredTab:Remove()
check(p.closed and not restored._conexaoPanel, "removing the owner tab destroys the picker immediately")
restored:Unload()
workspace.CurrentCamera, gui.GetGuiInset = camera, getInset
print("PASS: " .. checks .. " internal split dropdown and optional control-notification checks")
