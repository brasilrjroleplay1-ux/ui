--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Friend data is requested when Home opens, cached, and never blocks window construction.
local Friends = {}
function Friends.attach(window)
    local players = game:GetService("Players")
    local state = { ids = nil, total = nil, online = nil, busy = false, last = nil, unavailable = false }
    function window:RefreshFriends(force)
        local now = self:GetSessionStats().elapsed
        if self.unloaded or state.busy or (not force and state.last and now - state.last < 60) then return end
        state.busy, state.last = true, now
        task.spawn(function()
            local ok, ids, count, online = pcall(function()
                local pages = players:GetFriendsAsync(players.LocalPlayer.UserId)
                local found, total, active, complete = {}, 0, 0, true
                for _ = 1, 100 do
                    if window.unloaded then return nil end
                    for _, friend in ipairs(pages:GetCurrentPage()) do
                        local id = tonumber(friend.Id)
                        if id and not found[id] then
                            found[id], total = true, total + 1
                            if type(friend.IsOnline) == "boolean" then if friend.IsOnline then active += 1 end
                            else complete = false end
                        end
                    end
                    if pages.IsFinished then
                        if not complete then
                            local succeeded, list = pcall(function() return players.LocalPlayer:GetFriendsOnline() end)
                            active = succeeded and type(list) == "table" and math.min(total, #list) or nil
                        end
                        return found, total, active
                    end
                    pages:AdvanceToNextPageAsync()
                end
                error("Friend page limit reached")
            end)
            if window.unloaded then return end
            state.busy, state.unavailable = false, not (ok and ids)
            if ok and ids then state.ids, state.total, state.online = ids, count, online end
            if window.HomePage and window.selectedTab == window.HomeTab then window.HomePage:RefreshStats() end
        end)
    end
    function window:GetFriendStats()
        local inServer
        if state.ids then
            inServer = 0
            local ok, list = pcall(function() return players:GetPlayers() end)
            if ok then for _, player in ipairs(list) do if state.ids[player.UserId] then inServer += 1 end end
            else inServer = nil end
        end
        local function show(value) return value ~= nil and tostring(value) or "—" end
        return {
            total = state.total, online = state.online, inServer = inServer,
            allText = show(state.total), onlineText = show(state.online), inServerText = show(inServer),
            offlineText = show(state.total and state.online and math.max(0, state.total - state.online) or nil),
            unavailable = state.unavailable, loading = state.busy,
        }
    end
end
return Friends
