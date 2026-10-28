local Dashboard=require(script.Parent.Dashboard)
local Overview={}
function Overview.create(w,o)
 local tab=Dashboard.create(w,{Id='@conexao/home',Name=o.HomeTitle or 'Dashboard',Internal=true,Username=w.Identity.DisplayName,Handle='@'..w.Identity.Username,Executor=w.Identity.Executor,SideDescription='Versão '..(w.Version or '2.0.0')..' · Conectado'})
 w.HomeTab=tab tab.Button.LayoutOrder=-500
 w.Identity:BindImage(tab.Profile.Avatar)
 function tab:Refresh()
  tab.Profile.Fields.profile.Text=w.Storage.Active
  tab.Profile.Fields.config.Text=w.Storage.Available and 'Local' or 'Sessão'
 end
 return tab
end
return Overview
