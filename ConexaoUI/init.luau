local Window=require(script.Core.Window)
local Dashboard=require(script.Pages.Dashboard)
local Settings=require(script.Pages.Settings)
local Options=require(script.Core.Options)
local Library={Version='1.6.0',Windows={}}
function Library:CreateWindow(options)
 options=Options.normalize(options)
 local id=options.Id or 'ConexaoUI'
 if self.Windows[id] then self.Windows[id]:Destroy() end
 local window=Window.new(options)
 self.Windows[id]=window
 local library=self local destroy=window.Destroy
 function window:Destroy()
  destroy(self)
  if library.Windows[id]==self then library.Windows[id]=nil end
 end
 function window:CreateDashboard(settings) return Dashboard.create(self,settings) end
 Settings.create(window,options)
 return window
end
function Library:Destroy()
 for _,window in pairs(self.Windows) do window:Destroy() end table.clear(self.Windows)
end
return Library
