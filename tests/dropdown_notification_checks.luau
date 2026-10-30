-- Actual public bundle: anchored selection, checkboxes, optional messages and saved state.
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
local w = UI:CreateWindow({ Id = "Dropdown390", name = "Dropdown test", configuration = { fileName = "dropdown390", autoSave = false, autoLoad = false } })
local tab = w:CreateTab({ name = "Options" })
tab:Select()
tab.tabPage.AbsolutePosition, tab.tabPage.AbsoluteSize = Vector2.new(100, 60), Vector2.new(600, 600)
local options = { "Um", "Dois", "Três", "Quatro", "Cinco" }
local callbackCount = 0
local multi = tab:CreateDropdown({ name = "Marque opções", flag = "multi", multiSelect = true, options = options, value = { "Um" }, callback = function() callbackCount += 1 end })
multi.main.AbsolutePosition, multi.main.AbsoluteSize = Vector2.new(300, 150), Vector2.new(300, 41)
local function heartbeat() run.Heartbeat:Fire(0.016) end
local function rect(p) return p.main.Position.X.Offset, p.main.Position.Y.Offset, p.main.Size.X.Offset, p.main.Size.Y.Offset end
local tabCount = #w.tabs
multi.interact.MouseButton1Click:Fire()
local p = multi.selectionPanel
local x, y, width, height = rect(p)
check(p.side == "right" and x == 608 and y == 150 and width == 300 and height <= 388, "the compact list anchors immediately to the right of its dropdown")
check(#w.tabs == tabCount and w.selectedTab == tab and p.main.Parent == w.screenGui and not p.scrim, "opening creates no tab, fullscreen blocker or dimming")
check(multi.panel.Visible == false and multi.main.Size.Y.Offset <= 70, "opening does not expand the header or shift other controls")
check(p.grid:IsA("UIListLayout") and #p.items == 5 and p.items[1].checkbox.Size.X.Offset == 20, "each vertical option row has an explicit checkbox")
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
multi.main.AbsolutePosition = Vector2.new(400, 180);heartbeat()
check(p.main.Position.X.Offset == 708 and p.main.Position.Y.Offset == 180, "moving the anchor repositions the open list")
multi.main.AbsolutePosition = Vector2.new(900, 180);heartbeat()
check(p.side == "left" and p.main.Position.X.Offset == 592, "insufficient right space flips the list left")
local accent = p.items[1].checkbox.BackgroundColor3
w:ChangeTheme("porcelana")
check(p.items[1].checkbox.BackgroundColor3 ~= accent and p.items[1].label.TextColor3 == w.theme.ContentColor, "open checkboxes follow light/dark theme changes")
for _, view in ipairs({ Vector2.new(320, 568), Vector2.new(568, 320), Vector2.new(240, 320), Vector2.new(768, 1024) }) do
    testCamera.ViewportSize = view
    tab.tabPage.AbsolutePosition, tab.tabPage.AbsoluteSize = Vector2.new(0, 24), Vector2.new(view.X, view.Y - 24)
    multi.main.AbsolutePosition, multi.main.AbsoluteSize = Vector2.new(12, 100), Vector2.new(math.min(260, view.X - 24), 70)
    heartbeat();x, y, width, height = rect(p)
    check(x >= 8 and y >= 32 and x + width <= view.X - 8 and y + height <= view.Y - 8, "portrait/landscape list stays inside safe screen edges")
    check(width <= 300 and height <= 388 and height - 166 > 0, "small screens retain a bounded scrollable option viewport")
end
gui.GetGuiInset = function() return Vector2.new(32, 24), Vector2.new(12, 8) end
heartbeat();x, y, width, height = rect(p)
check(x >= 40 and x + width <= testCamera.ViewportSize.X - 20 and y + height <= testCamera.ViewportSize.Y - 16, "asymmetric notches and bottom insets are respected")
testCamera.ViewportSize = Vector2.new(1280, 768)
gui.GetGuiInset = function() return Vector2.new(0, 24), Vector2.new(0, 0) end
tab.tabPage.AbsolutePosition, tab.tabPage.AbsoluteSize = Vector2.new(100, 60), Vector2.new(600, 600)
multi.main.AbsolutePosition, multi.main.AbsoluteSize = Vector2.new(300, 150), Vector2.new(300, 41)
heartbeat()
p.main.AbsolutePosition, p.main.AbsoluteSize = Vector2.new(p.main.Position.X.Offset, p.main.Position.Y.Offset), Vector2.new(p.main.Size.X.Offset, p.main.Size.Y.Offset)
input.InputBegan:Fire({ UserInputType = Enum.UserInputType.Touch, Position = p.main.AbsolutePosition + Vector2.new(20, 20) })
check(not p.closed, "inside touch keeps the list open")
input.InputBegan:Fire({ UserInputType = Enum.UserInputType.Touch, Position = Vector2.new(10, 700) })
check(p.closed and not multi._isOpen and w.selectedTab == tab, "outside touch dismisses only the list")
multi:Open();p = multi.selectionPanel
input.InputBegan:Fire({ UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.Escape })
check(p.closed and not multi._isOpen, "Escape dismisses the anchored list")
multi:Open();p = multi.selectionPanel;multi:Lock()
check(p.closed and not multi._isOpen, "locking an open dropdown dismisses its list")
multi:Open();check(not multi._isOpen, "a locked dropdown cannot reopen")
multi:Unlock();multi:Open();p = multi.selectionPanel
multi.main.AbsolutePosition = Vector2.new(300, 700);heartbeat()
check(p.closed, "scrolling the anchor outside its page dismisses the list")
multi.main.AbsolutePosition = Vector2.new(300, 150)
multi:Open();p = multi.selectionPanel;w:ToggleMinimise()
check(p.closed and not w._conexaoPanel, "minimising the window dismisses the list")
w:ToggleMinimise()
local single = tab:CreateDropdown({ name = "Uma", options = options, value = "Um", multiSelect = false })
single:Open();p = single.selectionPanel;p.items[4].hit.MouseButton1Click:Fire()
check(single:GetValue() == "Quatro" and p.closed and w.selectedTab == tab, "single choice commits one value and closes without navigation")
local connections, instances = #w.connections, #w.instances
for _ = 1, 10 do multi:Open();multi:Close() end
check(#w.connections == connections and #w.instances == instances, "reopening leaks no rows, frames or listeners")

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
local noCallback = tab:CreateButton({ Name = "Pascal", Notification = true, NotificationMessage = "Sem callback" })
noCallback.interact.MouseButton1Click:Fire()
check(sent[#sent].content == "Sem callback" and sent[#sent].title == "Pascal", "PascalCase options and message-only controls work")
local ok = pcall(function() tab:CreateButton({ name = "Invalid", notification = true }) end)
check(not ok, "true requires a message at creation")
tab:CreateButton({ name = "No validation", notification = false, notificationMessage = false })
button:Lock();start = #sent;button.interact.MouseButton1Click:Fire()
check(#sent == start and calls == 2, "Lock blocks both callback and automatic message")
button:Unlock()
local toggle = tab:CreateToggle({ name = "Feature", flag = "notificationToggle", value = false, notification = true,
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
local slider = tab:CreateSlider({ name = "Precision", range = { 0, 100 }, increment = 0.25, value = 20, notification = true,
    notificationMessage = function(value, dragging) observed = { value, dragging } return tostring(value) .. "%" end })
start = #sent;slider.callback(30, true)
check(#sent == start, "slider previews do not flood notifications")
slider:Set(73.5)
check(#sent == start + 1 and observed[1] == 73.5 and observed[2] == false and sent[#sent].content == "73.5%", "committing a slider sends its exact value once")
local choices = tab:CreateDropdown({ name = "Choices", flag = "choices", options = options, multiSelect = true, value = {}, notification = true,
    notificationMessage = function(values) return #values == 0 and "Vazio" or table.concat(values, ", ") end })
choices:Open();p = choices.selectionPanel;p.items[2].hit.MouseButton1Click:Fire()
check(sent[#sent].content == "Dois" and not p.closed, "checkbox clicks can notify without closing a multiple-choice list")
choices:Close()
local text = tab:CreateInput({ name = "Text", value = "", notification = true, notificationMessage = function(value) return "Texto: " .. value end })
text.input.Text = "Olá";text.input.FocusLost:Fire()
check(sent[#sent].content == "Texto: Olá", "input commits supply their text to the message")
local bind = tab:CreateKeybind({ name = "Key", value = Enum.KeyCode.F9, notification = true, notificationMessage = function(key) return key.Name end })
input.InputBegan:Fire({ UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.F9 }, false)
check(sent[#sent].content == "F9", "key actions support optional messages")
local color = tab:CreateColorPicker({ name = "Color", color = Color3.fromRGB(1, 2, 3), notification = true, notificationMessage = function(value) return value:ToHex() end })
color:Set(Color3.fromRGB(4, 5, 6))
check(sent[#sent].content:upper() == "040506", "color callbacks supply their selected color")
local group = tab:CreateGroup({ direction = "column" })
local nested = group:CreateButton({ name = "Nested", notification = true, notificationMessage = "No grupo" })
nested.interact.MouseButton1Click:Fire()
check(sent[#sent].content == "No grupo", "nested groups expose the same notification options")
local failing = tab:CreateButton({ name = "Failure", notification = true, notificationMessage = "Wrong success", callback = function() error("test failure") end })
start = #sent;failing.interact.MouseButton1Click:Fire()
check(#sent == start and failing.title.Text == failing.name, "failed actions retain native error guards without misleading automatic messages")
local suppress = tab:CreateButton({ name = "Conditional", notification = true, notificationMessage = function() return "" end })
suppress.interact.MouseButton1Click:Fire()
check(#sent == start, "an empty message-function result suppresses that event")
multi:Set({ "Dois", "Cinco" });toggle:Set(true);check(w:Save(), "checkboxes still use native persistence")
choices:Open();p = choices.selectionPanel;w:Hide()
check(p.closed and not w._conexaoPanel, "Hide dismisses the list")
w:Show();w.Notify = notify;w:Unload()
check(#w.connections == 0, "Unload releases all picker and control listeners")
local restored = UI:CreateWindow({ Id = "Dropdown390", name = "Dropdown test", configuration = { fileName = "dropdown390", autoSave = false, autoLoad = true } })
local restoredMessages = 0
restored.Notify = function() restoredMessages += 1 end
local restoredTab = restored:CreateTab({ name = "Options" })
local restoredMulti = restoredTab:CreateDropdown({ name = "Marque opções", flag = "multi", options = options, multiSelect = true, value = {}, notification = true, notificationMessage = "Não deve aparecer" })
local restoredToggle = restoredTab:CreateToggle({ name = "Feature", flag = "notificationToggle", value = false, notification = true, notificationMessage = "Não deve aparecer" })
check(#restoredMulti.value == 2 and restoredMulti.value[1] == "Dois" and restoredMulti.value[2] == "Cinco" and restoredToggle.value, "reexecution restores each checkbox and toggle")
check(restoredMessages == 0, "late-created controls never announce restored choices")
restoredMulti:Open();p = restoredMulti.selectionPanel
check(p.items[2].marker.Text == "✓" and p.items[5].marker.Text == "✓" and p.items[1].marker.Text == "", "restored values repaint their exact checked states")
restoredTab:Remove()
check(p.closed and not restored._conexaoPanel, "removing the owner tab destroys the picker immediately")
restored:Unload()
workspace.CurrentCamera, gui.GetGuiInset = camera, getInset
print("PASS: " .. checks .. " anchored dropdown and optional control-notification checks")
