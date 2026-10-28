local Cleanup = {}
Cleanup.__index = Cleanup
function Cleanup.new() return setmetatable({items = {}, dead = false}, Cleanup) end
function Cleanup:Add(item)
 if self.dead then
  if typeof(item) == 'RBXScriptConnection' then item:Disconnect() elseif type(item) == 'function' then item() elseif item.Destroy then item:Destroy() end
 else table.insert(self.items, item) end
 return item
end
function Cleanup:Destroy()
 if self.dead then return end
 self.dead = true
 for i = #self.items, 1, -1 do
  local item = self.items[i]
  pcall(function()
   if typeof(item) == 'RBXScriptConnection' then item:Disconnect() elseif type(item) == 'function' then item() elseif item.Destroy then item:Destroy() end
  end)
 end
 table.clear(self.items)
end
return Cleanup
