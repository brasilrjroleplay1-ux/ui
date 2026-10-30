-- Compact shell navigation and real friend-provider behavior, using the distributed bundle.
local UI = (function()
-- BUNDLE
end)()
local checks = 0
local function check(value, message) assert(value, message) checks += 1 end
local w = UI:CreateWindow({ Id = "Shell36", configuration = { autoSave = false, autoLoad = false } })
local page = w:OpenHome()
check(w.layout.topbarHeight == 44 and w.sidebar.Size.X.Offset == 196 and w.elements.Size.X.Offset == -196, "standard windows reserve room for named tabs and the player card")
check(w.searchPill.Position.Y.Offset == 52, "search follows the shorter header instead of retaining the old vertical offset")
check(page.tab.topbarItem and not page.tab.neglectSelector and page.tab.customOrder == -1000, "Home is a real first item in the icon rail")
check(w.searchAction.action.Parent == w.actionContainer and not w.settingsAction.action.Visible and #w.BrandHeader.actions == 3, "search returns to the top while settings remains available in the sidebar")
w.SettingsTab.topbarItemInteract.MouseButton1Click:Fire()
check(w.selectedTab == w.SettingsTab, "the settings cog opens the built-in settings page")
page.tab.topbarItemInteract.MouseButton1Click:Fire()
check(w.selectedTab == page.tab, "the home icon returns to the same Home page")
local group = w:CreateSection({ name = "Um grupo com um nome comprido" })
check(group.title.Text == "Um grupo com um nome comprido" and group.main.Visible ~= false, "named sidebar groups remain visible when labels fit")
group:Remove()
local another = UI:CreateWindow({ Id = "SecondShell36", sidebarLayout = false, configuration = { autoSave = false, autoLoad = false } })
check(w.layout ~= another.layout and another.layout.topbarHeight == 44 and another.layout.mode == "top", "each window owns its geometry and the top-tab option still works")
another:Unload()
local tab = w:CreateTab({ name = "Meu script", icon = 93364949241311 })
check(w.selectedTab == tab, "an internal Home page does not prevent the first user tab from selecting itself")
for _, width in ipairs({ 320, 685, 1200 }) do
    w.size = UDim2.fromOffset(width, 450)
    w:_applyRailWidth()
    check(w.sidebar.Size.X.Offset == (width < 480 and 64 or 196) and tab.topbarItemTitle.Visible == (width >= 480), "tab names reappear when the window has room for its labelled sidebar")
end
w:Unload()
check(#w.connections == 0, "the shell's native and custom navigation handlers are released")

local players, run = game:GetService("Players"), game:GetService("RunService")
local oldFriends, oldPlayers = players.GetFriendsAsync, players.GetPlayers
local requests, advances = 0, 0
players.GetPlayers = function() return { { UserId = 2 }, { UserId = 12345 }, { UserId = 99 } } end
players.GetFriendsAsync = function(_, id)
    check(id == players.LocalPlayer.UserId, "friend provider receives the current player's ID")
    requests += 1
    local pages = { IsFinished = false }
    function pages:GetCurrentPage()
        if not self.IsFinished then return { { Id = 2, IsOnline = true }, { Id = 3, IsOnline = false } } end
        return { { Id = 2, IsOnline = true }, { Id = 4, IsOnline = true } }
    end
    function pages:AdvanceToNextPageAsync() self.IsFinished = true advances += 1 end
    return pages
end
local friendsWindow = UI:CreateWindow({ Id = "Friends36", configuration = { autoSave = false, autoLoad = false } })
local friendsPage = friendsWindow:OpenHome()
local data = friendsWindow:GetFriendStats()
check(requests == 1 and advances == 1 and data.total == 3 and data.online == 2 and data.inServer == 1 and data.offlineText == "1", "pagination deduplicates friend IDs and computes real online/server counts")
check(friendsPage.dashboard.friendStats[1].value.Text == "1" and friendsPage.dashboard.friendStats[4].value.Text == "3", "the reference friend tiles show the loaded counts")
friendsWindow:OpenHome()
run.Heartbeat:Fire(59.9)
check(requests == 1, "reopening Home and sampling metrics do not repeatedly request friend pages")
run.Heartbeat:Fire(1.1)
check(requests == 2, "friend data refreshes after the one-minute cache interval")
friendsWindow:Unload()
players.GetFriendsAsync = function() error("unavailable") end
local failed = UI:CreateWindow({ Id = "UnavailableFriends36", configuration = { autoSave = false, autoLoad = false } })
local failedPage = failed:OpenHome()
check(failed:GetFriendStats().allText == "—" and failed:GetFriendStats().onlineText == "—" and failed:GetFriendStats().unavailable, "unavailable friend APIs preserve unknown counts")
check(failedPage.dashboard.friendSubtitle.Text == "Dados indisponíveis neste cliente", "friend-provider failure is explained inside its card")
failed:Unload()
local suspended
players.GetFriendsAsync = function()
    suspended = coroutine.running()
    coroutine.yield()
    return { IsFinished = true, GetCurrentPage = function() return {} end }
end
local waiting = UI:CreateWindow({ Id = "UnloadFriends36", configuration = { autoSave = false, autoLoad = false } })
waiting:OpenHome()
check(suspended and waiting:GetFriendStats().loading, "a yielding friend request leaves the interface available")
waiting:Unload()
local ok = coroutine.resume(suspended)
check(ok and waiting.unloaded and not waiting.HomePage and #waiting.connections == 0, "a late friend request cannot update an unloaded page")
players.GetFriendsAsync, players.GetPlayers = oldFriends, oldPlayers
print("PASS: " .. checks .. " compact shell and friend-provider checks")
