--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Disable the optional analytics collector before native window construction can start it.
local NativeWindow = require(script.Parent.Parent.Gen2.components.window)
local Privacy = {}
local installed = false
function Privacy.install()
    if installed then return end
    installed = true
    function NativeWindow:_siaStart()
        self.settings.usageAnalytics = false
        self._sia = nil
    end
    for _, name in ipairs({ "LoadSettings", "SaveSettings" }) do
        local original = NativeWindow[name]
        NativeWindow[name] = function(self, ...)
            self.settings.usageAnalytics = false
            local result = original(self, ...)
            self.settings.usageAnalytics = false
            return result
        end
    end
    local build = NativeWindow._buildSettingsUI
    function NativeWindow:_buildSettingsUI(...)
        local tab, create = self.rfSettings, self.rfSettings.CreateToggle
        function tab:CreateToggle(props)
            if type(props) == "table" and (props.name or props.Name) == "Usage analytics" then return nil end
            return create(self, props)
        end
        local ok, result = pcall(build, self, ...)
        tab.CreateToggle = create
        if not ok then error(result, 0) end
        return result
    end
end
return table.freeze(Privacy)
