--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Optional script-owned messages; notifications are disabled unless explicitly enabled.
local Notifications = {}
local interactive = { Button = true, Toggle = true, Slider = true, Dropdown = true, Input = true, Keybind = true, ColorPicker = true }
local function prop(p, name)
    if p[name] ~= nil then return p[name] end
    return p[name:sub(1, 1):upper() .. name:sub(2)]
end
function Notifications.prepare(window, kind, props)
    if not interactive[kind] or prop(props, "notification") ~= true then return function() end end
    local title = prop(props, "notificationTitle")
    assert(type(title) == "string" and title:match("%S"), "notification = true requires a non-empty notificationTitle")
    local message = prop(props, "notificationMessage")
    if message == nil then message = "" end
    assert(type(message) == "function" or type(message) == "string", "notificationMessage must be text or a function (or omitted)")
    local callback = props.callback or props.Callback or function() end
    local armed = false
    props.callback = function(...)
        -- Snapshot before calling user code: it may yield or manually load a profile.
        local announce = armed and not window._loading and not window.unloaded
        local args = table.pack(...)
        local result = table.pack(callback(table.unpack(args, 1, args.n)))
        if announce and not window.unloaded and not (kind == "Slider" and args[2] == true) then
            local content = if type(message) == "function" then message(table.unpack(args, 1, args.n)) else message
            assert(type(content) == "string", "notificationMessage function must return text; empty text is allowed")
            window:Notify({
                title = title, content = content,
                type = prop(props, "notificationType"), duration = prop(props, "notificationDuration"),
            })
        end
        return table.unpack(result, 1, result.n)
    end
    return function() armed = true end
end
return Notifications
