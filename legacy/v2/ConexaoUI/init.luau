local Window=require(script.Core.Window)
local Dashboard=require(script.Pages.Dashboard)
local Overview=require(script.Pages.Overview)
local Settings=require(script.Pages.Settings)
local Options=require(script.Core.Options)
local Library={Version='2.1.0',Windows={}}
function Library:CreateWindow(options)
 options=Options.normalize(options)
 local id=options.Id or 'ConexaoUI'
 if self.Windows[id] then self.Windows[id]:Destroy() end
 local window=Window.new(options)
 window.Version=self.Version
 self.Windows[id]=window
 local library=self local destroy=window.Destroy
 function window:Destroy()
  destroy(self)
  if library.Windows[id]==self then library.Windows[id]=nil end
 end
 function window:CreateDashboard(settings) return Dashboard.create(self,settings) end
 if options.Home~=false then Overview.create(window,options) end
 Settings.create(window,options)
 return window
end
function Library:Destroy()
 for _,window in pairs(self.Windows) do window:Destroy() end table.clear(self.Windows)
end
return Library
