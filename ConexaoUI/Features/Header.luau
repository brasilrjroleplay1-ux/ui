--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Brand = require(script.Parent.BrandMark)
local tweenService = game:GetService("TweenService")
local Header = {}
local function studioName(value)
    return tostring(value):gsub("Ã", "A"):gsub("ã", "a"):lower():gsub("[^a-z0-9]", "") == "conexaostudio"
end
local function boldFont(font) return Font.new(font.Family, Enum.FontWeight.Bold, font.Style) end

function Header.attach(window, version)
    local self = { targets = {}, actions = {} }
    window.BrandHeader = self
    local function create(class, props, themed) return window:Create(class, props, themed) end
    local function track(node, property, value) table.insert(self.targets, { node = node, property = property, value = value }) end
    -- Preserve native layouts as owned descendants, without letting them reposition the wordmark.
    local storage = create("Frame", { Name = "HeaderLayoutStorage", Parent = window.topbar, Visible = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0) })
    for _, layout in ipairs({ window.topContainerLayout, window.titleContainerLayout }) do
        local holder = create("Frame", { Parent = storage, Visible = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0) })
        layout.Parent = holder
    end
    self.root = window.topContainer
    self.root.Name, self.root.AutomaticSize = "ConexaoHeader", Enum.AutomaticSize.None
    window.titleContainer.AutomaticSize, window.titleContainer.AnchorPoint = Enum.AutomaticSize.None, Vector2.new(0, 0)
    self.mark = not window.topbarIcon and Brand.new(create, self.root, 40, window.theme) or nil
    if window.title then
        window.title.AutomaticSize, window.title.TextWrapped = Enum.AutomaticSize.None, false
        window.title.TextTruncate = Enum.TextTruncate.AtEnd
        window.title.Position, window.title.Size = UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 25)
        window.title.FontFace = window.theme.TitleFont
        window.themeProperties[window.title].FontFace = "TitleFont"
    end
    self.wordmark = create("TextLabel", {
        Name = "ConexaoWordmark", Parent = window.titleContainer, Text = "CONEXÃO STUDIO", TextSize = 23,
        Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(132, 30), BackgroundTransparency = 1,
        TextTransparency = 1, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.None, TextWrapped = false, TextScaled = true, ZIndex = 5,
    }, { FontFace = { "TitleFont", boldFont } })
    self.wordmarkSize = create("UITextSizeConstraint", { Parent = self.wordmark, MinTextSize = 1, MaxTextSize = 23 })
    self.wordmarkGradient = create("UIGradient", { Parent = self.wordmark, Rotation = 0 }, { Color = { "TitlingColor", function(color)
        return ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(0.55, color), ColorSequenceKeypoint.new(1, color:Lerp(window.theme.AccentColor, 0.35)) })
    end } })
    track(self.wordmark, "TextTransparency", 0)
    self.wordmarkRule = create("Frame", {
        Name = "SignatureLine", Parent = window.titleContainer, Position = UDim2.fromOffset(0, 30), Size = UDim2.fromOffset(132, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    }, { BackgroundColor3 = "AccentColor" })
    create("UIGradient", { Parent = self.wordmarkRule, Transparency = NumberSequence.new(0.1, 1) })
    track(self.wordmarkRule, "BackgroundTransparency", 0.45)
    self.pill = create("Frame", {
        Name = "VersionPill", Parent = window.titleContainer, Position = UDim2.fromOffset(0, 28), Size = UDim2.fromOffset(56, 18),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4,
    }, { BackgroundColor3 = "StatBackground" })
    create("UICorner", { Parent = self.pill, CornerRadius = UDim.new(0, 6) })
    local pillRim = create("UIStroke", { Parent = self.pill, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
    track(self.pill, "BackgroundTransparency", 0.12)
    track(pillRim, "Transparency", 0.7)
    self.version = window.subtitle or create("TextLabel", {
        Name = "Version", Text = version, Parent = self.pill, BackgroundTransparency = 1, TextTransparency = 1,
    }, { FontFace = "Font", TextColor3 = "TitlingColor" })
    self.version.Parent, self.version.AutomaticSize = self.pill, Enum.AutomaticSize.None
    self.version.AnchorPoint, self.version.Position, self.version.Size = Vector2.new(0, 0), UDim2.fromOffset(6, 0), UDim2.new(1, -12, 1, 0)
    self.version.TextSize, self.version.TextWrapped, self.version.TextTruncate = 10, false, Enum.TextTruncate.AtEnd
    self.version.TextXAlignment = Enum.TextXAlignment.Center
    -- Native reveal paths dim their subtitle independently. Mirror its text into the badge
    -- so every open/restore uses the same readable opacity.
    self.version.Visible = false
    self.versionDisplay = create("TextLabel", {
        Name = "VersionDisplay", Parent = self.pill, Text = self.version.Text, Position = UDim2.fromOffset(6, 0),
        Size = UDim2.new(1, -12, 1, 0), TextSize = 10, BackgroundTransparency = 1, TextTransparency = 1,
        TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5,
    }, { FontFace = "Font", TextColor3 = "TitlingColor" })
    track(self.versionDisplay, "TextTransparency", 0.18)
    self.caption = create("TextLabel", {
        Name = "BrandCaption", Parent = window.titleContainer, Text = "UI LIBRARY", TextSize = 9, BackgroundTransparency = 1,
        TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
    }, { FontFace = "TitleFont", TextColor3 = "TitlingColor" })
    track(self.caption, "TextTransparency", 0.38)
    -- Script-created tags share the metadata row; a long row scrolls instead of covering the name.
    self.tagSlot = create("ScrollingFrame", {
        Name = "HeaderTags", Parent = window.titleContainer, BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X, ClipsDescendants = true, Active = true, ScrollingEnabled = true, Visible = false,
    })
    window.tagContainer.Parent, window.tagContainer.AnchorPoint = self.tagSlot, Vector2.new(0, 0)
    window.tagContainer.Position = UDim2.fromOffset(0, 0)
    create("UIScale", { Parent = window.tagContainer, Scale = 0.75 })
    self.separator = create("Frame", {
        Name = "HeaderAccent", Parent = window.topbar, Position = UDim2.new(0, 18, 1, -1), Size = UDim2.new(1, -36, 0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    create("UIGradient", {
        Parent = self.separator, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.18, 0.1), NumberSequenceKeypoint.new(0.8, 0.3), NumberSequenceKeypoint.new(1, 1) }),
    }, { Color = { "SurfaceStroke", function(color) return ColorSequence.new(color) end } })
    track(self.separator, "BackgroundTransparency", 0.82)
    for _, node in ipairs(window.actionContainer:GetChildren()) do
        if node.Parent == window.actionContainer and node:IsA("Frame") and node.Visible ~= false and node:FindFirstChild("ImageLabel") then
            window.themeProperties[node] = window.themeProperties[node] or {}
            window.themeProperties[node].BackgroundColor3 = "StatBackground"
            node.BackgroundColor3 = window.theme.StatBackground
            create("UICorner", { Parent = node, CornerRadius = UDim.new(0, 9) })
            local rim = create("UIStroke", { Parent = node, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
            track(node, "BackgroundTransparency", 0.45)
            track(rim, "Transparency", 0.86)
            table.insert(self.actions, node)
            window:Connect(node.MouseEnter, function()
                if window:_interactive() then tweenService:Create(node, TweenInfo.new(0.15), { BackgroundTransparency = 0.05 }):Play() end
            end)
            window:Connect(node.MouseLeave, function()
                tweenService:Create(node, TweenInfo.new(0.15), { BackgroundTransparency = window.hidden and 1 or 0.45 }):Play()
            end)
        end
    end
    window.actionContainer.AutomaticSize = Enum.AutomaticSize.None
    function self:Layout()
        if window.unloaded then return end
        local width = window.main.AbsoluteSize.X
        if width <= 0 or window.animating or window._revealing then width = window.size.X.Offset end
        local compact, tiny = width < 540, width < 380
        local slot, padding, gap = compact and 26 or 28, 12, 12
        local actionGap = 5
        if width < 240 then slot, padding, gap, actionGap = 22, 8, 8, 4 end
        window.actionsListLayout.Padding = UDim.new(0, actionGap)
        local actionsWidth = #self.actions * slot + math.max(0, #self.actions - 1) * actionGap
        local available = math.max(1, width - padding * 2 - gap - actionsWidth)
        window.actionContainer.Position, window.actionContainer.Size = UDim2.new(1, -padding, 0.5, 0), UDim2.fromOffset(actionsWidth, slot)
        for _, node in ipairs(self.actions) do node.Size = UDim2.fromOffset(slot, slot) end
        self.root.Position, self.root.Size = UDim2.new(0, padding, 0.5, 0), UDim2.fromOffset(available, 32)
        local iconSize = tiny and 28 or 32
        local icon = self.mark and self.mark.root or window.topbarIcon
        icon.Visible = available >= 76
        icon.AnchorPoint, icon.Position, icon.Size = Vector2.new(0, 0.5), UDim2.fromScale(0, 0.5), UDim2.fromOffset(iconSize, iconSize)
        local textLeft = icon.Visible and iconSize + 10 or 0
        local textWidth = math.max(1, available - textLeft)
        window.titleContainer.Position, window.titleContainer.Size = UDim2.fromOffset(textLeft, 0), UDim2.fromOffset(textWidth, 32)
        local titleSize = tiny and 14 or 16
        if window.title then window.title.TextSize = titleSize end
        -- A bounded capsule needs no yielding font request during a resize. Longer subtitles truncate.
        local pillWidth = math.min(textWidth, math.clamp((utf8.len(self.version.Text) or #self.version.Text) * 6 + 14, 38, 130))
        self.pill.Visible = textWidth >= 170
        local titleText = window.title and window.title.Text or ""
        local titleWidth = math.max(1, math.min(textWidth - (self.pill.Visible and pillWidth + 8 or 0), (utf8.len(titleText) or #titleText) * titleSize * 0.64 + 4))
        self.branded = studioName(titleText)
        self.wordmark.Visible, self.wordmarkRule.Visible = self.branded, self.branded
        if window.title then window.title.Visible = not self.branded end
        if self.branded then
            local wordSize = tiny and 18 or (compact and 21 or 23)
            local wordWidth = math.max(1, math.min(textWidth, math.ceil(wordSize * 9.8)))
            self.wordmark.TextSize, self.wordmark.Size = wordSize, UDim2.fromOffset(wordWidth, 30)
            self.wordmarkSize.MaxTextSize = wordSize
            self.wordmarkRule.Size = UDim2.fromOffset(wordWidth, 1)
            titleWidth = wordWidth
            self.pill.Visible = textWidth - titleWidth >= pillWidth + 8
        end
        if window.title then window.title.Position, window.title.Size = UDim2.fromOffset(0, 5), UDim2.fromOffset(titleWidth, 22) end
        self.pill.Position = UDim2.fromOffset(titleWidth + 8, 7)
        self.pill.Size = UDim2.fromOffset(pillWidth, 18)
        local hasTags = false
        for _, child in ipairs(window.tagContainer:GetChildren()) do if child:IsA("Frame") and child.Name == "Tag" then hasTags = true break end end
        local tagLeft = titleWidth + (self.pill.Visible and pillWidth + 18 or 10)
        self.tagSlot.Visible = hasTags and textWidth - tagLeft >= 48
        self.tagSlot.Position, self.tagSlot.Size = UDim2.fromOffset(tagLeft, 7), UDim2.fromOffset(math.max(1, textWidth - tagLeft), 18)
        self.caption.Visible = false
    end
    function self:SetShown(shown, info, assemble)
        for _, target in ipairs(self.targets) do
            local props = { [target.property] = shown and target.value or 1 }
            if info then tweenService:Create(target.node, info, props):Play()
            else target.node[target.property] = props[target.property] end
        end
        if self.mark then self.mark:SetShown(shown, info, assemble) end
    end
    local fade = window._fadeSurfaces
    function window:_fadeSurfaces(shown, info)
        fade(self, shown, info)
        self.BrandHeader:SetShown(shown or (self.minimised and not self.hidden), info)
    end
    window:Connect(window.main:GetPropertyChangedSignal("AbsoluteSize"), function() self:Layout() end)
    window:Connect(self.version:GetPropertyChangedSignal("Text"), function() self.versionDisplay.Text = self.version.Text self:Layout() end)
    if window.title then window:Connect(window.title:GetPropertyChangedSignal("Text"), function() self:Layout() end) end
    local createTag = window.CreateTag
    function window:CreateTag(...)
        local tag = createTag(self, ...)
        self.BrandHeader:Layout()
        local remove = tag.Remove
        function tag:Remove(...)
            remove(self, ...)
            window.BrandHeader:Layout()
        end
        return tag
    end
    self:Layout()
    self:SetShown(not window.hidden)
end

return Header
