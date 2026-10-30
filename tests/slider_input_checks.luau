-- Actual distributed sliders: click/tap, focus events, native callbacks, bar and saved values.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local function near(a, b) return math.abs(a - b) < 1e-6 end -- UDim ratios are stored as float32.
local w = UI:CreateWindow({ Id = "SliderInput37", configuration = { fileName = "slider_input_37" } })
local tab = w:CreateTab({ name = "Precisão" })
local calls = {}
local percent = tab:CreateSlider({ name = "Porcentagem", flag = "precise_percent", range = { 0, 100 }, increment = 0.25, value = 50, format = "percent", callback = function(value, dragging) table.insert(calls, { value, dragging }) end })
local number = tab:CreateSlider({ name = "Número", flag = "precise_number", range = { -10, 10 }, increment = 0.01, value = 1.5, format = "number" })
local legacy = tab:CreateSlider({ name = "Tempo", flag = "legacy_units", range = { 0, 20 }, increment = 0.1, value = 2, suffix = "ms" })
check(percent.suffix == "%" and number.suffix == "" and legacy.suffix == "ms", "number/percent modes and existing unit suffixes are supported")
check(percent.valueInput and w.TransparencySlider.valueInput and w.WindowSizeSlider.valueInput, "script and built-in settings sliders receive inline editors")
local function begin(control)
    control._valueInput.button.MouseButton1Click:Fire()
    check(control._valueInput.editing and control.valueInput:IsFocused() and not control._valueInput.readout.Visible, "clicking the value focuses the numeric editor")
end
local function edit(control, text, enter)
    begin(control)
    control.valueInput.Text = text
    if enter then control.valueInput._focused = false control.valueInput.FocusLost:Fire(true)
    else control.valueInput:ReleaseFocus() end
    check(not control._valueInput.editing and control._valueInput.readout.Visible and not control.valueInput.Visible, "confirmation restores the formatted readout")
end
edit(percent, "37.25", true)
check(near(percent.value, 37.25) and #calls == 1 and calls[1][2] == false and near(percent.progress.Size.X.Scale, 0.3725), "Enter commits once, moves the bar and reports dragging=false")
edit(percent, "73,5 %")
check(near(percent.value, 73.5) and near(percent.progress.Size.X.Scale, 0.735), "decimal commas and a pasted percent suffix are parsed")
local before = #calls
edit(percent, "73.5000")
check(#calls == before, "an unchanged value does not replay its callback")
edit(percent, "999")
check(percent.value == 100 and percent.progress.Size.X.Scale == 1, "typed values above maximum land at the upper bound")
edit(percent, "-9")
check(percent.value == 0 and percent.progress.Size.X.Scale == 0, "typed values below minimum land at the lower bound")
edit(number, "-3,14")
check(near(number.value, -3.14), "signed decimal inputs retain the configured precision")
edit(legacy, "8.5 ms")
check(near(legacy.value, 8.5), "existing custom units can be pasted without changing their numeric value")
local step = tab:CreateSlider({ name = "Passos", range = { 0.5, 4.5 }, increment = 1, value = 0.5 })
check(step:_format(0.5) == "0.5", "offset ranges do not round their displayed minimum to an integer")
edit(step, "2.4")
check(step.value == 2.5, "typed values use the slider's increment grid anchored at its minimum")
local fixed = tab:CreateSlider({ name = "Fixo", range = { 3, 3 }, value = 3 })
edit(fixed, "50")
check(fixed.value == 3 and fixed.progress.Size.X.Scale == 0, "zero-span ranges stay finite and within bounds")
local persist = w._persist
local writes = 0
w._persist = function(self, control) writes += 1 return persist(self, control) end
local saved, callbacks = percent.value, #calls
for _, text in ipairs({ "", "-", "abc", "NaN", "inf", "1e309", "1.2.3", "1,2,3" }) do
    edit(percent, text)
    check(percent.value == saved and #calls == callbacks and writes == 0, "invalid text preserves the previous value and does not save")
end
begin(percent)
percent.valueInput.Text = "80"
game:GetService("UserInputService").InputBegan:Fire({ KeyCode = Enum.KeyCode.Escape })
check(not percent._valueInput.editing and percent.value == saved and #calls == callbacks and writes == 0, "Escape cancels the draft without changing or saving the value")
percent:Lock()
percent._valueInput.button.MouseButton1Click:Fire()
check(not percent._valueInput.editing, "locked sliders cannot enter numeric editing")
percent:Unlock()
begin(percent)
percent.valueInput.Text = "90"
percent:Lock()
check(not percent._valueInput.editing and percent.value == saved, "locking an active editor cancels its unconfirmed draft")
percent:Unlock()
local plain = tab:CreateSlider({ name = "Somente arraste", editable = false })
local minimal = tab:CreateSlider({ name = "Mínimo", minimal = true })
check(not plain.valueInput and not minimal.valueInput, "editing can be disabled and minimal sliders keep their track-only presentation")
check(not pcall(function() tab:CreateSlider({ name = "Formato inválido", format = "invalid" }) end), "invalid format names fail before creating a control")
local column = tab:CreateGroup():CreateGroup({ direction = "column" })
check(column:CreateSlider({ name = "Coluna", Format = "Percent" }).valueInput ~= nil, "sliders in nested groups support the editor and PascalCase format")
edit(w.WindowSizeSlider, "77")
check(w.UIPreferences.autoSize == false and w.UIPreferences.sizePercent == 77 and w.SizeInfo.percent == 77, "editing window size commits manual sizing through the original setting callback")
edit(percent, "61.25")
check(w:Save(), "the existing configuration backend saves typed slider values")
local old = w
w = UI:CreateWindow({ Id = "SliderInput37", configuration = { fileName = "slider_input_37" } })
tab = w:CreateTab({ name = "Precisão" })
local restored = tab:CreateSlider({ name = "Porcentagem", flag = "precise_percent", range = { 0, 100 }, increment = 0.25, value = 0, format = "percent" })
check(old.unloaded and near(restored.value, 61.25) and near(restored.progress.Size.X.Scale, 0.6125), "reexecution restores the typed number and matching handle position")
begin(restored)
restored.valueInput.Text = "82"
w:Hide()
check(not restored._valueInput.editing and restored.value == 82, "hiding the window confirms a valid active draft")
w:Show()
begin(restored)
restored.valueInput.Text = "95"
w:Unload()
restored.valueInput.FocusLost:Fire(true)
check(w.unloaded and #w.connections == 0, "late focus events cannot revive or edit an unloaded window")
print("PASS: " .. checks .. " inline slider editing and persistence checks")
