-- Built-in client identity page. No game features or fictional game statistics.
local E=require(script.Parent.Parent.Core.Elements)
local Overview={}
function Overview.create(w,o)
 local info=w.Identity
 local tab=w:CreateTab({Id='@conexao/home',Name=o.HomeTitle or 'Dashboard',Icon='house',Internal=true})
 w.HomeTab=tab tab.Button.LayoutOrder=-500
 local hero=E.new('Frame',{Name='Welcome',Size=UDim2.new(1,0,0,176),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},tab.Page) E.corner(hero,18)
 local gradient=E.new('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(205,169,99),Color3.fromRGB(114,87,200)),Rotation=24},hero)
 local avatar=E.new('ImageLabel',{Name='PlayerAvatar',Size=UDim2.fromOffset(72,72),Position=UDim2.fromOffset(22,24),BackgroundColor3=Color3.fromRGB(46,41,57),BorderSizePixel=0},hero)
 E.corner(avatar,36).Name='AvatarMask' info:BindImage(avatar)
 local greeting=E.text(hero,'BEM-VINDO DE VOLTA',10) greeting.Position=UDim2.fromOffset(112,26) greeting.Size=UDim2.new(1,-132,0,20)
 local name=E.text(hero,info.DisplayName,26) name.Font=Enum.Font.GothamBold name.Position=UDim2.fromOffset(112,50) name.Size=UDim2.new(1,-132,0,36) name.TextTruncate=Enum.TextTruncate.AtEnd
 local username=E.text(hero,'@'..info.Username,12) username.Position=UDim2.fromOffset(112,90) username.Size=UDim2.new(1,-132,0,22)
 local badge=E.new('TextLabel',{Text=info.Executor,Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(42,38,53),BackgroundTransparency=.22,BorderSizePixel=0,Position=UDim2.fromOffset(22,134),Size=UDim2.new(1,-44,0,26),TextTruncate=Enum.TextTruncate.AtEnd},hero) E.corner(badge,8)
 local account=tab:CreateGroup({Id='account',Name='JOGADOR',Icon='user',Column=1})
 local system=tab:CreateGroup({Id='system',Name='CONEXÃO UI',Icon='settings',Column=2})
 local values={}
 local function field(group,key,label,value)
  local row=E.new('Frame',{Name=key,BackgroundTransparency=1,Size=UDim2.new(1,0,0,44)},group.Page)
  local heading=E.text(row,label,12) heading.Size=UDim2.new(.44,-8,1,0) w.Theme:Bind(heading,'TextColor3','MutedText')
  local text=E.text(row,tostring(value),13) text.Position=UDim2.new(.44,0,0,0) text.Size=UDim2.new(.56,0,1,0) text.TextTruncate=Enum.TextTruncate.AtEnd w.Theme:Bind(text,'TextColor3','Text')
  values[key]=text
 end
 field(account,'username','Usuário','@'..info.Username)
 field(account,'executor','Executor',info.Executor)
 field(account,'userid','ID',info.UserId)
 field(system,'version','Library',w.Version or '1.7.0')
 field(system,'profile','Perfil ativo',w.Storage.Active)
 field(system,'config','Armazenamento',w.Storage.Available and 'Disponível' or 'Só nesta sessão')
 field(system,'status','Estado','Conectado')
 account:CreateButton({Name='Preferências da interface',Text='Abrir',Callback=function() w:SelectTab(w.SettingsTab) end})
 system:CreateButton({Name='Salvar escolhas',Text='Salvar',Callback=function()
  w:Notify({Title='Perfil',Content=w:SaveConfig() and 'Suas escolhas foram salvas.' or 'Este ambiente não oferece armazenamento em arquivo.',Kind=w.Storage.Available and 'Success' or 'Warning'})
 end})
 function tab:Refresh()
  values.profile.Text=w.Storage.Active values.config.Text=w.Storage.Available and 'Disponível' or 'Só nesta sessão'
 end
 function tab:SetStat(key,value) assert(values[key],'Campo desconhecido: '..tostring(key)) values[key].Text=tostring(value) end
 function tab:SetWelcome(options)
  if options.Username then name.Text=options.Username end
  if options.Status then badge.Text=options.Status end
  if options.Avatar then avatar.Image=options.Avatar end
  if options.Gradient then gradient.Color=ColorSequence.new(options.Gradient[1],options.Gradient[2]) end
 end
 local function layout(width)
  local small=width<440
  avatar.Size=UDim2.fromOffset(small and 48 or 72,small and 48 or 72)
  avatar.Position=UDim2.fromOffset(18,26)
  local left=small and 80 or 112
  greeting.Position=UDim2.fromOffset(left,26) greeting.Size=UDim2.new(1,-left-18,0,20)
  name.Position=UDim2.fromOffset(left,50) name.Size=UDim2.new(1,-left-18,0,36) name.TextSize=small and 18 or 26
  username.Position=UDim2.fromOffset(22,100) username.Size=UDim2.new(1,-44,0,22)
 end
 tab.Relayout=layout layout(tab.Page.AbsoluteSize.X-24)
 tab.Profile={Avatar=avatar,Name=name,Executor=badge,Fields=values}
 return tab
end
return Overview
