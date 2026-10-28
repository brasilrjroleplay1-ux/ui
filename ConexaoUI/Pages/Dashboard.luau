local E=require(script.Parent.Parent.Core.Elements)
local Dashboard={}
function Dashboard.create(w,o)
 o=o or {}
 local tab=w:CreateTab({Name=o.Name or 'Dashboard',Id=o.Id or 'dashboard',Icon=o.Icon or 'house',Description='Visão geral'})
 local clean=tab.Cleanup
 local hero=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,174)},tab.Page)
 local welcome=E.new('Frame',{BorderSizePixel=0,Size=UDim2.new(.66,-6,1,0),BackgroundColor3=Color3.new(1,1,1)},hero) E.corner(welcome,22)
 local gradient=E.new('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(226,188,104),Color3.fromRGB(124,91,239)),Rotation=24},welcome)
 local avatar=E.new('ImageLabel',{BackgroundColor3=Color3.fromRGB(240,227,204),Size=UDim2.fromOffset(66,66),Position=UDim2.fromOffset(20,24),Image=o.Avatar or '',BorderSizePixel=0},welcome) E.corner(avatar,33)
 local eyebrow=E.text(welcome,'BEM-VINDO DE VOLTA',10) eyebrow.Position=UDim2.fromOffset(102,25) eyebrow.Size=UDim2.new(1,-114,0,20)
 local username=E.text(welcome,o.Username or game:GetService('Players').LocalPlayer.DisplayName,24) username.Position=UDim2.fromOffset(102,51) username.Size=UDim2.new(1,-114,0,38) username.TextTruncate=Enum.TextTruncate.AtEnd
 local badge=E.text(welcome,o.Status or '●  Interface conectada',12) badge.Position=UDim2.fromOffset(24,125) badge.Size=UDim2.new(1,-48,0,22)
 local side=E.new('Frame',{BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(49,52,116),Position=UDim2.new(.66,6,0,0),Size=UDim2.new(.34,-6,1,0)},hero) E.corner(side,22) E.pad(side,18) E.list(side,10)
 local sideTitle=E.text(side,o.SideTitle or 'Conexão UI',17) sideTitle.AutomaticSize=Enum.AutomaticSize.Y
 local sideDesc=E.text(side,o.SideDescription or 'Feita para conectar suas ideias.',12) sideDesc.Size=UDim2.new(1,0,0,0) sideDesc.AutomaticSize=Enum.AutomaticSize.Y
 local action=E.button(side,o.SideActionName or 'Conhecer a library') action.BackgroundColor3=Color3.fromRGB(94,111,250)
 clean:Add(action.Activated:Connect(function() if o.SideAction then local ok,err=pcall(o.SideAction) if not ok then warn(err) end else w:Notify({Title='Conexão UI',Content='Abas, temas e componentes configuráveis em Luau.'}) end end))
 local quick=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,54)},tab.Page)
 local quickGrid=E.new('UIGridLayout',{CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder},quick)
 local actions=o.Actions or {
  {Name='Configurações',Icon='settings',Callback=function() w:SelectTab(o.SettingsTab or w.SettingsTab) end},
  {Name='Salvar perfil',Icon='star',Callback=function() w:Notify({Title='Perfil',Content=w:SaveConfig() and 'Configuração salva.' or 'Armazenamento em arquivo indisponível neste ambiente.'}) end},
  {Name='Minimizar',Icon='bolt',Callback=function() w:Minimize(true) end},
 }
 for _,item in ipairs(actions) do
  local b=E.button(quick,item.Name) w.Theme:Bind(b,'BackgroundColor3','Surface')
  if item.Icon then local icon=E.icon(b,item.Icon) icon.Position=UDim2.fromOffset(10,15) b.Text='      '..item.Name end
  clean:Add(b.Activated:Connect(function() local ok,err=pcall(item.Callback) if not ok then warn(err) end end))
 end
 local bottom=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,300)},tab.Page)
 local stats=E.new('Frame',{Size=UDim2.new(.64,-6,1,0),BorderSizePixel=0},bottom) E.corner(stats,20) E.pad(stats,14) w.Theme:Bind(stats,'BackgroundColor3','Surface')
 local statsTitle=E.text(stats,'◷  SESSÃO',12) w.Theme:Bind(statsTitle,'TextColor3','Text')
 local statsContainer=E.new('Frame',{BackgroundTransparency=1,Position=UDim2.fromOffset(0,40),Size=UDim2.new(1,0,1,-40)},stats)
 local statsGrid=E.new('UIGridLayout',{CellPadding=UDim2.fromOffset(10,10),CellSize=UDim2.new(.5,-5,0,64),SortOrder=Enum.SortOrder.LayoutOrder},statsContainer)
 local statLabels={} local statCount=0
 for _,item in ipairs(o.Stats or {{Id='profile',Name='PERFIL',Value='Padrão',Icon='user'},{Id='version',Name='VERSÃO',Value='1.0.0',Icon='star'},{Id='theme',Name='TEMA',Value='Conexão Dark',Icon='palette'},{Id='status',Name='STATUS',Value='Pronto',Icon='bolt'},{Id='platform',Name='PLATAFORMA',Value='Adaptável',Icon='settings'},{Id='config',Name='CONFIGURAÇÃO',Value=w.Storage.Available and 'Local' or 'Memória',Icon='info'}}) do
  statCount+=1
  local card=E.new('Frame',{BorderSizePixel=0},statsContainer) E.corner(card,14) w.Theme:Bind(card,'BackgroundColor3','SurfaceHover')
  local icon=E.icon(card,item.Icon or 'star') icon.Position=UDim2.fromOffset(10,20) w.Theme:Bind(icon,icon:IsA('ImageLabel') and 'ImageColor3' or 'TextColor3','Secondary')
  local label=E.text(card,item.Name,9) label.Position=UDim2.fromOffset(42,10) label.Size=UDim2.new(1,-48,0,16) w.Theme:Bind(label,'TextColor3','MutedText')
  local value=E.text(card,tostring(item.Value),15) value.Position=UDim2.fromOffset(42,29) value.Size=UDim2.new(1,-48,0,24) w.Theme:Bind(value,'TextColor3','Text') statLabels[item.Id or item.Name]=value
 end
 local news=E.new('Frame',{Position=UDim2.new(.64,6,0,0),Size=UDim2.new(.36,-6,1,0),BorderSizePixel=0},bottom) E.corner(news,20) E.pad(news,16) E.list(news,12) w.Theme:Bind(news,'BackgroundColor3','Surface')
 local newsTitle=E.text(news,'✦  NOVIDADES',12) w.Theme:Bind(newsTitle,'TextColor3','Secondary')
 for _,item in ipairs(o.News or {{Title='Seu estilo, sua interface',Content='Gradientes, cores e transparência em tempo real.'},{Title='Continue de onde parou',Content='Seu perfil é restaurado automaticamente quando há armazenamento disponível.'}}) do
  local label=E.text(news,item.Title,13) label.Size=UDim2.new(1,0,0,0) label.AutomaticSize=Enum.AutomaticSize.Y w.Theme:Bind(label,'TextColor3','Text')
  local body=E.text(news,item.Content,12) body.Size=UDim2.new(1,0,0,0) body.AutomaticSize=Enum.AutomaticSize.Y w.Theme:Bind(body,'TextColor3','MutedText')
 end
 tab.Relayout=function(width)
  local small=width<540
  hero.Size=UDim2.new(1,0,0,small and 330 or 174)
  welcome.Size=small and UDim2.new(1,0,0,174) or UDim2.new(.66,-6,1,0)
  side.Position=small and UDim2.fromOffset(0,186) or UDim2.new(.66,6,0,0)
  side.Size=small and UDim2.new(1,0,0,144) or UDim2.new(.34,-6,1,0)
  local columns=small and 1 or math.max(1,#actions)
  quickGrid.CellSize=UDim2.new(1/columns,-8*(columns-1)/columns,0,54)
  quick.Size=UDim2.new(1,0,0,math.ceil(#actions/columns)*62-8)
  local statColumns=width<360 and 1 or 2
  statsGrid.CellSize=UDim2.new(1/statColumns,-10*(statColumns-1)/statColumns,0,64)
  local statsHeight=math.max(180,math.ceil(statCount/statColumns)*74+58)
  stats.Size=small and UDim2.new(1,0,0,statsHeight) or UDim2.new(.64,-6,1,0)
  news.Position=small and UDim2.fromOffset(0,statsHeight+12) or UDim2.new(.64,6,0,0)
  news.Size=small and UDim2.new(1,0,0,300) or UDim2.new(.36,-6,1,0)
  bottom.Size=UDim2.new(1,0,0,small and statsHeight+312 or 300)
  avatar.Visible=width>=300
  username.Position=UDim2.fromOffset(width<300 and 20 or 102,51) username.Size=UDim2.new(1,width<300 and -32 or -114,0,38)
  eyebrow.Position=UDim2.fromOffset(width<300 and 20 or 102,25) eyebrow.Size=UDim2.new(1,width<300 and -32 or -114,0,20)
 end
 function tab:SetStat(id,value) assert(statLabels[id],'Stat desconhecida: '..id) statLabels[id].Text=tostring(value) end
 function tab:SetWelcome(values)
  username.Text=values.Username or username.Text badge.Text=values.Status or badge.Text
  if values.Avatar then avatar.Image=values.Avatar end
  if values.Gradient then gradient.Color=ColorSequence.new(values.Gradient[1],values.Gradient[2]) end
 end
 clean:Add(function() w.Theme:Forget(hero) w.Theme:Forget(quick) w.Theme:Forget(bottom) end)
 tab.Relayout(tab.Page.AbsoluteSize.X-24)
 return tab
end
return Dashboard
