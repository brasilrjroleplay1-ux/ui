local Profiles={}
function Profiles.create(w,create,createConfig)
 createConfig=createConfig or create
 local store=w.Storage
 local summary=createConfig('Label',{Name='Perfil ativo',Content=''})
 local selected=createConfig('Dropdown',{Name='Perfil selecionado',Options=store:ListProfiles(),Default=store.Active,Searchable=true})
 local newName,deleted,transfer
 local function refresh()
  local current=selected:GetValue()
  selected:SetOptions(store:ListProfiles()) selected:SetValue(current or store.Active,true)
  if deleted then deleted:SetOptions(store:ListProfiles(true)) end
  summary:SetValue(store.Active..'  ·  '..#store:ListProfiles()..' salvo(s)'..(store.SessionOnly and '\nCarregamento automático desativado.' or ''))
 end
 local function persist(commit)
  local saved
  if commit then saved=store:SaveProfile() else saved=store:Flush(true) end
  if not saved then w:Notify({Title='Perfis',Content='Alteração disponível nesta sessão; não foi possível gravar no armazenamento.'}) end
  refresh()
 end
 local function action(callback)
  return function()
   local ok,err=pcall(callback)
   if not ok then w:Notify({Title='Perfis',Content=tostring(err)}) end
  end
 end
 createConfig('Button',{Name='Definir como ativo',Text='Ativar',Callback=action(function()
  assert(selected:GetValue(),'Selecione um perfil.') w:LoadProfile(selected:GetValue()) persist()
 end)})
 createConfig('Button',{Name='Salvar alterações',Text='Salvar',Callback=action(function() persist(true) end)})
 createConfig('Toggle',{Name='Carregar automaticamente',Default=store.AutoLoad,Callback=function(value) store.AutoLoad=value persist() end})
 newName=create('Textbox',{Name='Nome do novo perfil',Placeholder='Automático se vazio',MaxLength=48})
 create('Button',{Name='Criar configuração',Text='Criar',Callback=action(function()
  local name=store:CreateProfile(newName:GetValue()) selected:SetOptions(store:ListProfiles()) selected:SetValue(name,true) newName:SetValue('',true) persist()
 end)})
 create('Button',{Name='Excluir configuração selecionada',Text='Excluir',Variant='Destructive',Callback=action(function()
  local name=selected:GetValue()
  assert(name and name~='Default' and name~=store.Active,'Selecione um perfil diferente do padrão e do ativo.')
  w:Confirm({Content='Mover "'..name..'" para a lixeira?',Destructive=true,Callback=function(yes)
   if yes and not w.Destroyed then action(function() store:DeleteProfile(name) selected:SetValue(store.Active,true) persist() end)() end
  end})
 end)})
 deleted=create('Dropdown',{Name='Perfis excluídos',Options=store:ListProfiles(true),Searchable=true})
 create('Button',{Name='Restaurar perfil excluído',Text='Restaurar',Variant='Secondary',Callback=action(function()
  local name=deleted:GetValue() assert(name,'Selecione um perfil excluído.') store:RestoreProfile(name) persist()
 end)})
 create('Button',{Name='Exportar configuração selecionada',Text='Exportar',Callback=action(function()
  transfer:SetValue(store:ExportProfile(selected:GetValue() or store.Active),true)
  w:Notify({Title='Exportação',Content='JSON disponível no campo de texto. Selecione e copie.'})
 end)})
 transfer=create('Textbox',{Name='Importar / exportar JSON',Placeholder='Cole o JSON aqui',MaxLength=262144})
 create('Button',{Name='Importar como novo perfil',Text='Importar',Callback=action(function()
  local name=store:ImportProfile(transfer:GetValue(),newName:GetValue())
  selected:SetOptions(store:ListProfiles()) selected:SetValue(name,true) persist()
 end)})
 refresh()
 w.RefreshProfiles=refresh
 return {Selected=selected,Name=newName,Deleted=deleted,Transfer=transfer,Refresh=refresh}
end
return Profiles
