local E=require(script.Parent.Parent.Core.Elements)
local Dashboard={}
function Dashboard.create(w,o)
 o=o or {}
 local tab=w:CreateTab({Name=o.Name or 'Dashboard',Id=o.Id or 'dashboard',Icon=o.Icon or 'house',Description=o.Description,Internal=o.Internal==true})
 local cleanup=tab.Cleanup
 local function card(parent,name)
  local node=E.new('Frame',{Name=name,BorderSizePixel=0},parent) E.corner(node,20)
  w.Theme:Bind(node,'BackgroundColor3','Surface')
  E.new('UIGradient',{Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(145,169,224)),Rotation=65},node)
  local stroke=E.new('UIStroke',{Thickness=1,Transparency=.3},node) w.Theme:Bind(stroke,'Color','Border')
  return node
 end
 local hero=E.new('Frame',{Name='WelcomeRow',BackgroundTransparency=1,Size=UDim2.new(1,0,0,176)},tab.Page)
 local welcome=E.new('Frame',{Name='Welcome',BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Size=UDim2.new(.66,-6,1,0)},hero) E.corner(welcome,22)
 local gradient=E.new('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(132,64,236),Color3.fromRGB(74,67,203)),Rotation=18},welcome)
 E.new('UIStroke',{Color=Color3.fromRGB(211,166,255),Thickness=1.3,Transparency=.16},welcome)
 local avatar=E.new('ImageLabel',{Name='PlayerAvatar',Size=UDim2.fromOffset(74,74),Position=UDim2.fromOffset(22,26),BackgroundColor3=Color3.fromRGB(54,51,65),BorderSizePixel=0,Image=o.Avatar or (w.Identity and w.Identity.Avatar) or ''},welcome)
 E.corner(avatar,37).Name='AvatarMask'
 E.new('UIStroke',{Color=Color3.fromRGB(225,193,255),Thickness=2,Transparency=.12},avatar)
 local infoGlass=E.new('Frame',{Name='ProfileGlass',BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.94,BorderSizePixel=0,Position=UDim2.fromOffset(106,20),Size=UDim2.new(1,-124,0,99)},welcome) E.corner(infoGlass,14)
 local greeting=E.text(welcome,'BEM-VINDO DE VOLTA',11) greeting.Font=Enum.Font.GothamBold greeting.TextColor3=Color3.fromRGB(231,215,255) greeting.Position=UDim2.fromOffset(118,26) greeting.Size=UDim2.new(1,-138,0,20)
 local username=E.text(welcome,o.Username or (w.Identity and w.Identity.DisplayName) or 'Jogador',30) username.Font=Enum.Font.GothamBold username.TextColor3=Color3.fromRGB(255,252,255) username.Position=UDim2.fromOffset(118,48) username.Size=UDim2.new(1,-138,0,38) username.TextTruncate=Enum.TextTruncate.AtEnd
 local handle=E.text(welcome,o.Handle or (w.Identity and '@'..w.Identity.Username) or '',13) handle.TextColor3=Color3.fromRGB(233,214,255) handle.Position=UDim2.fromOffset(118,91) handle.Size=UDim2.new(1,-138,0,22)
 for _,label in ipairs({greeting,username,handle}) do label.TextWrapped=false label.TextTruncate=Enum.TextTruncate.AtEnd end
 local chip=E.new('TextLabel',{Text=o.Status or o.Executor or (w.Identity and w.Identity.Executor) or 'Conectado',TextColor3=Color3.fromRGB(240,247,255),TextSize=12,Font=Enum.Font.GothamMedium,BackgroundColor3=Color3.fromRGB(18,26,48),BackgroundTransparency=.08,BorderSizePixel=0,Position=UDim2.fromOffset(22,132),Size=UDim2.new(1,-44,0,27),TextTruncate=Enum.TextTruncate.AtEnd},welcome) E.corner(chip,9)
 local side=E.new('Frame',{Name='LibraryCard',BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.new(.66,6,0,0),Size=UDim2.new(.34,-6,1,0)},hero) E.corner(side,22)
 E.new('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(46,29,82),Color3.fromRGB(27,23,56)),Rotation=30},side)
 E.new('UIStroke',{Color=Color3.fromRGB(158,151,255),Thickness=1,Transparency=.2},side)
 local sideTitle=E.text(side,o.SideTitle or 'Conexão UI',19) sideTitle.Font=Enum.Font.GothamBold sideTitle.Position=UDim2.fromOffset(18,20) sideTitle.Size=UDim2.new(1,-36,0,28)
 sideTitle.TextWrapped=false sideTitle.TextTruncate=Enum.TextTruncate.AtEnd
 local sideText=E.text(side,o.SideDescription or ('Versão '..(w.Version or '2.1.0')..' · Conectado'),12) sideText.Position=UDim2.fromOffset(18,55) sideText.Size=UDim2.new(1,-36,0,32)
 local sideButton=E.button(side,o.SideActionName or 'Preferências') sideButton.Position=UDim2.new(0,18,1,-58) sideButton.Size=UDim2.new(1,-36,0,38) sideButton.Font=Enum.Font.GothamBold w.Theme:Bind(sideButton,'BackgroundColor3','Primary') w.Theme:Bind(sideButton,'TextColor3','PrimaryText')
 local arrowSlot=E.new('Frame',{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.88,Size=UDim2.fromOffset(30,30),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-4,.5,0),BorderSizePixel=0},sideButton) E.corner(arrowSlot,9)
 local arrow=E.icon(arrowSlot,'arrow') arrow.Size=UDim2.fromOffset(18,18) arrow.AnchorPoint=Vector2.new(.5,.5) arrow.Position=UDim2.fromScale(.5,.5) w.Theme:Bind(arrow,'TextColor3','PrimaryText')
 if w.Effects then w.Effects:RegisterButton(sideButton,cleanup) end
 cleanup:Add(sideButton.Activated:Connect(function()
  if o.SideAction then local ok,err=pcall(o.SideAction) if not ok then warn(err) end
  elseif w.SettingsTab then w:SelectTab(w.SettingsTab) end
 end))
 local actions=o.Actions or {
  {Name='Configurações',Icon='settings',Callback=function() if w.SettingsTab then w:SelectTab(w.SettingsTab) end end},
  {Name='Salvar perfil',Icon='star',Callback=function() w:Notify({Title='Perfil',Content=w:SaveConfig() and 'Suas escolhas foram salvas.' or 'Armazenamento em arquivo indisponível.',Kind=w.Storage.Available and 'Success' or 'Warning'}) end},
  {Name='Minimizar',Icon='bolt',Callback=function() w:Minimize(true) end},
 }
 local quick=E.new('Frame',{Name='QuickActions',BackgroundTransparency=1,Size=UDim2.new(1,0,0,64)},tab.Page)
 local quickGrid=E.new('UIGridLayout',{CellPadding=UDim2.fromOffset(12,12),SortOrder=Enum.SortOrder.LayoutOrder},quick)
 local accents={Color3.fromRGB(102,178,255),Color3.fromRGB(171,133,255),Color3.fromRGB(255,210,92)}
 for index,action in ipairs(actions) do
  local b=E.button(quick,'') E.corner(b,16) w.Theme:Bind(b,'BackgroundColor3','Surface')
  local accent=accents[(index-1)%#accents+1]
  local square=E.new('Frame',{BackgroundTransparency=.82,BackgroundColor3=accent,BorderSizePixel=0,Size=UDim2.fromOffset(36,36),Position=UDim2.fromOffset(14,14)},b) E.corner(square,11)
  local icon=E.icon(square,action.Icon or 'star') icon.AnchorPoint=Vector2.new(.5,.5) icon.Position=UDim2.fromScale(.5,.5)
  E.tint(icon,accent)
  local title=E.text(b,action.Name,15) title.Position=UDim2.fromOffset(62,0) title.Size=UDim2.new(1,-76,1,0) w.Theme:Bind(title,'TextColor3','Text')
  cleanup:Add(b.Activated:Connect(function() local ok,err=pcall(action.Callback) if not ok then warn(err) end end))
 end
 local bottom=E.new('Frame',{Name='DashboardPanels',BackgroundTransparency=1,Size=UDim2.new(1,0,0,280)},tab.Page)
 local stats=card(bottom,'Session') stats.Size=UDim2.new(.65,-6,1,0)
 local statsTitle=E.text(stats,'SESSÃO',12) statsTitle.Font=Enum.Font.GothamBold statsTitle.Position=UDim2.fromOffset(18,14) statsTitle.Size=UDim2.new(1,-36,0,26) w.Theme:Bind(statsTitle,'TextColor3','Text')
 local statArea=E.new('Frame',{BackgroundTransparency=1,Position=UDim2.fromOffset(16,52),Size=UDim2.new(1,-32,1,-68)},stats)
 local statGrid=E.new('UIGridLayout',{CellPadding=UDim2.fromOffset(10,10),SortOrder=Enum.SortOrder.LayoutOrder},statArea)
 local values={} local statCount=0
 local data=o.Stats or {
  {Id='username',Name='USUÁRIO',Value=w.Identity and '@'..w.Identity.Username or 'Jogador',Icon='user'},
  {Id='executor',Name='EXECUTOR',Value=w.Identity and w.Identity.Executor or 'Não identificado',Icon='bolt'},
  {Id='profile',Name='PERFIL',Value=w.Storage.Active,Icon='star'},
  {Id='version',Name='VERSÃO',Value=w.Version or '2.1.0',Icon='info'},
  {Id='config',Name='ARMAZENAMENTO',Value=w.Storage.Available and 'Local' or 'Sessão',Icon='settings'},
  {Id='status',Name='ESTADO',Value='Conectado',Icon='house'},
 }
 for _,item in ipairs(data) do
  statCount+=1
  local tile=card(statArea,'Stat') E.corner(tile,14) w.Theme:Bind(tile,'BackgroundColor3','SurfaceHover')
  local icon=E.icon(tile,item.Icon or 'star') icon.AnchorPoint=Vector2.new(.5,.5) icon.Position=UDim2.new(0,25,.5,0) w.Theme:Bind(icon,icon:IsA('ImageLabel') and 'ImageColor3' or 'TextColor3','Secondary')
  local label=E.text(tile,item.Name,10) label.Font=Enum.Font.GothamBold label.Position=UDim2.fromOffset(47,13) label.Size=UDim2.new(1,-57,0,17) label.TextTruncate=Enum.TextTruncate.AtEnd w.Theme:Bind(label,'TextColor3','MutedText')
  local value=E.text(tile,tostring(item.Value),16) value.Font=Enum.Font.GothamBold value.Position=UDim2.fromOffset(47,35) value.Size=UDim2.new(1,-57,0,24) value.TextTruncate=Enum.TextTruncate.AtEnd w.Theme:Bind(value,'TextColor3','Text')
  label.TextWrapped=false value.TextWrapped=false
  values[item.Id or item.Name]=value
 end
 local news=card(bottom,'News') news.Position=UDim2.new(.65,6,0,0) news.Size=UDim2.new(.35,-6,1,0)
 local newsTitle=E.text(news,'NOVIDADES',12) newsTitle.Font=Enum.Font.GothamBold newsTitle.Position=UDim2.fromOffset(18,14) newsTitle.Size=UDim2.new(1,-36,0,26) w.Theme:Bind(newsTitle,'TextColor3','Secondary')
 local newsBody=E.scroll(news) newsBody.Position=UDim2.fromOffset(4,44) newsBody.Size=UDim2.new(1,-8,1,-52)
 for _,entry in ipairs(o.News or {{Title='Seu estilo, sua interface',Content='Temas, cores e controles configuráveis.'},{Title='Continue de onde parou',Content='Perfis e escolhas podem ser restaurados quando o ambiente oferece arquivos.'}}) do
  local headline=E.text(newsBody,entry.Title,14) headline.Font=Enum.Font.GothamBold headline.AutomaticSize=Enum.AutomaticSize.Y headline.Size=UDim2.new(1,0,0,0) w.Theme:Bind(headline,'TextColor3','Text')
  local body=E.text(newsBody,entry.Content,13) body.AutomaticSize=Enum.AutomaticSize.Y body.Size=UDim2.new(1,0,0,0) w.Theme:Bind(body,'TextColor3','MutedText')
 end
 tab.Relayout=function(width)
  local small=width<700
  hero.Size=UDim2.new(1,0,0,small and 344 or 176)
  welcome.Size=small and UDim2.new(1,0,0,176) or UDim2.new(.66,-6,1,0)
  side.Position=small and UDim2.fromOffset(0,188) or UDim2.new(.66,6,0,0)
  side.Size=small and UDim2.new(1,0,0,156) or UDim2.new(.34,-6,1,0)
  local left=width<360 and 86 or 118
  avatar.Size=UDim2.fromOffset(width<360 and 48 or 74,width<360 and 48 or 74)
  greeting.Position=UDim2.fromOffset(left,26) greeting.Size=UDim2.new(1,-left-18,0,20)
  infoGlass.Position=UDim2.fromOffset(left-12,20) infoGlass.Size=UDim2.new(1,-left-6,0,99)
  username.Position=UDim2.fromOffset(left,48) username.Size=UDim2.new(1,-left-18,0,38) username.TextSize=width<360 and 21 or 30
  handle.Position=UDim2.fromOffset(left,91) handle.Size=UDim2.new(1,-left-18,0,22)
  local quickColumns=width<500 and 1 or math.max(1,#actions)
  quickGrid.CellSize=UDim2.new(1/quickColumns,-12*(quickColumns-1)/quickColumns,0,64)
  quick.Size=UDim2.new(1,0,0,#actions>0 and math.ceil(#actions/quickColumns)*76-12 or 0)
  local statWidth=small and width-32 or width*.65-44
  local columns=statWidth>=540 and 3 or statWidth>=320 and 2 or 1
  statGrid.CellSize=UDim2.new(1/columns,-10*(columns-1)/columns,0,76)
  local statHeight=math.max(256,math.ceil(statCount/columns)*86-10+68)
  stats.Size=small and UDim2.new(1,0,0,statHeight) or UDim2.new(.65,-6,1,0)
  news.Position=small and UDim2.fromOffset(0,statHeight+12) or UDim2.new(.65,6,0,0)
  news.Size=small and UDim2.new(1,0,0,256) or UDim2.new(.35,-6,1,0)
  bottom.Size=UDim2.new(1,0,0,small and statHeight+268 or statHeight)
 end
 function tab:SetStat(key,value) assert(values[key],'Campo desconhecido: '..tostring(key)) values[key].Text=tostring(value) end
 function tab:SetWelcome(options)
  if options.Username then username.Text=options.Username end
  if options.Status then chip.Text=options.Status end
  if options.Avatar then avatar.Image=options.Avatar end
  if options.Gradient then gradient.Color=ColorSequence.new(options.Gradient[1],options.Gradient[2]) end
 end
 tab.Profile={Avatar=avatar,Name=username,Executor=chip,Fields=values}
 tab.Relayout(tab.Page.AbsoluteSize.X-24)
 return tab
end
return Dashboard
