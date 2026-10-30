--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Session = {}
local function finite(value)
    return type(value) == "number" and value == value and value >= 0 and value < math.huge
end
local function duration(seconds)
    seconds = math.floor(seconds)
    return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
end

function Session.attach(window)
    local state = { elapsed = 0, frames = 0, interval = 0, fps = nil }
    local players, run = game:GetService("Players"), game:GetService("RunService")
    function window:GetSessionStats()
        local ok, list = pcall(function() return players:GetPlayers() end)
        local count = ok and type(list) == "table" and #list or nil
        local maximum = finite(players.MaxPlayers) and players.MaxPlayers or nil
        local ping
        local success, value = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if success and finite(value) then ping = value
        else
            success, value = pcall(function() return players.LocalPlayer:GetNetworkPing() end)
            if success and finite(value) then ping = value * 2000 end
        end
        return {
            players = count, maximum = maximum, fps = state.fps, ping = ping, elapsed = state.elapsed,
            playerText = count and (maximum and string.format("%d / %d", count, maximum) or tostring(count)) or "—",
            countText = count and tostring(count) or "—", maximumText = maximum and tostring(maximum) or "—",
            fpsText = state.fps and tostring(state.fps) or "—",
            pingText = ping and string.format("%d ms", math.floor(ping + 0.5)) or "—",
            timeText = duration(state.elapsed),
            placeText = tostring(game.PlaceId),
            saveText = self.configuration.autoSave and "Ativado" or "Desativado",
        }
    end
    window:Connect(run.RenderStepped, function() if not window.unloaded then state.frames += 1 end end)
    window:Connect(run.Heartbeat, function(delta)
        if window.unloaded or not finite(delta) then return end
        state.elapsed += delta
        state.interval += delta
        if state.interval < 1 then return end
        state.fps = state.frames > 0 and math.floor(state.frames / state.interval + 0.5) or nil
        state.frames, state.interval = 0, 0
        local page = window.HomePage
        if page and window.selectedTab == window.HomeTab and not window.hidden and page.RefreshStats then
            page:RefreshStats()
            if window.RefreshFriends then window:RefreshFriends() end
        end
    end)
end

return Session
