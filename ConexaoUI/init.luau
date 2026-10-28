local Window=require(script.Core.Window)
local Dashboard=require(script.Pages.Dashboard)
local Settings=require(script.Pages.Settings)
local Library={Version='1.5.0',Windows={}}
function Library:CreateWindow(options)
 options=options or {}
 local id=options.Id or 'ConexaoUI'
 if self.Windows[id] then self.Windows[id]:Destroy() end
 local window=Window.new(options)
 self.Windows[id]=window
 function window:CreateDashboard(settings) return Dashboard.create(self,settings) end
 Settings.create(window,options)
 return window
end
function Library:Destroy()
 for _,window in pairs(self.Windows) do window:Destroy() end table.clear(self.Windows)
end
return Library
