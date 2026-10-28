-- Profile management is part of the built-in configuration page.
local Profiles={}
function Profiles.create(w,create)
 local store=w.Storage
 local summary=create('Paragraph',{Name='PERFIS',Content=''})
 local selected=create('Dropdown',{Name='Configuração selecionada',Options=store:ListProfiles(),Default=store.Active,Searchable=true})
 local newName=create('Textbox',{Name='Nome do novo perfil',Placeholder='Automático se vazio',MaxLength=48})
 local deleted=create('Dropdown',{Name='Perfis excluídos',Options=store:ListProfiles(true),Searchable=true})
 local transfer=create('Textbox',{Name='Importar / exportar JSON',Placeholder='Cole o JSON aqui para importar, ou exporte um perfil para copiar.',MultiLine=true,MaxLength=262144})
 local function refresh()
  local current=selected:GetValue()
  selected:SetOptions(store:ListProfiles()) selected:SetValue(current or store.Active,true)
  deleted:SetOptions(store:ListProfiles(true))
  summary:SetValue('Ativo: '..store.Active..'  ·  Salvos: '..#store:ListProfiles()..(store.SessionOnly and '\nSessão com valores padrão: carregamento automático desativado.' or ''))
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
 create('Button',{Name='Definir como ativo',Callback=action(function()
  assert(selected:GetValue(),'Selecione um perfil.') w:LoadProfile(selected:GetValue()) persist()
 end)})
 create('Button',{Name='Salvar alterações',Callback=action(function() persist(true) end)})
 create('Toggle',{Name='Carregar automaticamente',Default=store.AutoLoad,Callback=function(value) store.AutoLoad=value persist() end})
 create('Button',{Name='Criar configuração',Callback=action(function()
  local name=store:CreateProfile(newName:GetValue()) selected:SetOptions(store:ListProfiles()) selected:SetValue(name,true) newName:SetValue('',true) persist()
 end)})
 create('Button',{Name='Excluir configuração selecionada',Variant='Destructive',Callback=action(function()
  local name=selected:GetValue()
  assert(name and name~='Default' and name~=store.Active,'Selecione um perfil diferente do padrão e do ativo.')
  w:Confirm({Content='Mover "'..name..'" para a lixeira?',Callback=function(yes)
   if yes and not w.Destroyed then action(function() store:DeleteProfile(name) selected:SetValue(store.Active,true) persist() end)() end
  end})
 end)})
 create('Button',{Name='Restaurar perfil excluído',Variant='Secondary',Callback=action(function()
  local name=deleted:GetValue() assert(name,'Selecione um perfil excluído.') store:RestoreProfile(name) persist()
 end)})
 create('Button',{Name='Exportar configuração selecionada',Callback=action(function()
  transfer:SetValue(store:ExportProfile(selected:GetValue() or store.Active),true)
  w:Notify({Title='Exportação',Content='JSON disponível no campo Importar / exportar. Selecione e copie o texto.'})
 end)})
 create('Button',{Name='Importar como novo perfil',Callback=action(function()
  local name=store:ImportProfile(transfer:GetValue(),newName:GetValue())
  selected:SetOptions(store:ListProfiles()) selected:SetValue(name,true) persist()
 end)})
 refresh()
 w.RefreshProfiles=refresh
 return {Selected=selected,Name=newName,Deleted=deleted,Transfer=transfer,Refresh=refresh}
end
return Profiles
