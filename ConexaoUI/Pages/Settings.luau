-- Owned by the library. Application/game features belong in the caller's tabs.
local E=require(script.Parent.Parent.Core.Elements)
local Factory=require(script.Parent.Parent.Components.Factory)
local Profiles=require(script.Parent.Profiles)
local Settings={}
local themeNames={'Conexão Dark','Violeta','Dourado','Aurora','Oceano','Rosa','Noite','Monocromático'}
local presets={
 ['Conexão Dark']={Background=Color3.fromRGB(16,18,22),Surface=Color3.fromRGB(28,31,36),SurfaceHover=Color3.fromRGB(40,44,52),Primary=Color3.fromRGB(143,110,247)},
 ['Violeta']={Background=Color3.fromRGB(22,18,32),Surface=Color3.fromRGB(36,29,49),SurfaceHover=Color3.fromRGB(49,39,67),Primary=Color3.fromRGB(173,135,255)},
 ['Dourado']={Background=Color3.fromRGB(23,21,17),Surface=Color3.fromRGB(36,33,27),SurfaceHover=Color3.fromRGB(51,46,36),Primary=Color3.fromRGB(224,184,100)},
 ['Aurora']={Background=Color3.fromRGB(13,24,27),Surface=Color3.fromRGB(20,39,43),SurfaceHover=Color3.fromRGB(28,55,58),Primary=Color3.fromRGB(51,221,190)},
 ['Oceano']={Background=Color3.fromRGB(12,21,35),Surface=Color3.fromRGB(21,35,55),SurfaceHover=Color3.fromRGB(29,49,75),Primary=Color3.fromRGB(56,170,250)},
 ['Rosa']={Background=Color3.fromRGB(29,18,30),Surface=Color3.fromRGB(45,29,46),SurfaceHover=Color3.fromRGB(64,39,64),Primary=Color3.fromRGB(235,134,204)},
 ['Noite']={Background=Color3.fromRGB(14,14,30),Surface=Color3.fromRGB(25,24,48),SurfaceHover=Color3.fromRGB(38,35,68),Primary=Color3.fromRGB(115,102,255)},
 ['Monocromático']={Background=Color3.fromRGB(19,21,24),Surface=Color3.fromRGB(30,33,38),SurfaceHover=Color3.fromRGB(45,49,55),Primary=Color3.fromRGB(184,204,227)},
}
function Settings.create(w,o)
 o=o or {}
 local initialTheme=table.clone(w.Theme.Values)
 local tab=w:CreateTab({Id='@conexao/settings',Name='Configurações',Icon='settings',Description='Preferências da interface',Internal=true})
 tab.Button.LayoutOrder=100000
 w.SettingsTab=tab
 local heading=E.text(tab.Page,'Configurações',24) w.Theme:Bind(heading,'TextColor3','Text')
 local nav=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,44)},tab.Page)
 local groups={} local buttons={} local groupLayouts={}
 local function select(name)
  for key,group in pairs(groups) do group.Visible=key==name w.Theme:Bind(buttons[key],'BackgroundColor3',key==name and 'Primary' or 'Surface') end
 end
 for index,name in ipairs({'Interface','Config'}) do
  local b=E.button(nav,name) b.Size=UDim2.new(.5,-4,1,0) b.Position=UDim2.new((index-1)*.5,(index-1)*8,0,0) buttons[name]=b
  local frame=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},tab.Page) groupLayouts[name]=E.list(frame,10) groups[name]=frame
  tab.Cleanup:Add(b.Activated:Connect(function() select(name) end))
 end
 local configLeft=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},groups.Config) E.list(configLeft,10)
 local configRight=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},groups.Config) E.list(configRight,10)
 local function create(group,kind,options)
  options.FireOnInit=false
  return Factory.create({Window=w,Id=tab.Id,Page=group=='Config' and configLeft or group=='Profiles' and configRight or groups[group],Cleanup=tab.Cleanup,Controls=tab.Controls},kind,options)
 end
 local controls={} local defaults={}
 local refreshGallery=function() end
 local function add(kind,key,name,default,props,apply)
  props=props or {} props.Id='@ui/'..key props.Name=name props.Default=default props.Callback=apply
  local c=create('Interface',kind,props) controls[key]=c defaults[key]=default return c
 end
 create('Interface','Section',{Name='APARÊNCIA',Content='Suas preferências são aplicadas automaticamente nas próximas execuções.'})
 local function syncColors()
  for key,themeKey in pairs({accent='Primary',background='Background'}) do
   local color=w.Theme.Values[themeKey]
   controls[key]:SetValue(color,true)
  end
 end
 add('Dropdown','theme','Tema','Conexão Dark',{Options=themeNames},function(value)
  if presets[value] then w:SetTheme(presets[value]) syncColors() refreshGallery() end
 end)
 local preset=presets[controls.theme:GetValue()]
 -- Respect a custom initial Theme when no built-in preset has been saved yet.
 if w.Storage.Values['@ui/accent']==nil and type(o.Theme)=='table' then preset=nil end
 if preset then w:SetTheme(preset) end
 -- Real buttons with live selection; previews are assembled from GUI objects.
 local gallery=E.new('Frame',{Name='ThemeGallery',BackgroundTransparency=1,Size=UDim2.new(1,0,0,224)},groups.Interface)
 local grid=E.new('UIGridLayout',{CellPadding=UDim2.fromOffset(10,10),CellSize=UDim2.new(.25,-8,0,106),SortOrder=Enum.SortOrder.LayoutOrder},gallery)
 local cards={}
 for index,themeName in ipairs(themeNames) do
  local palette=presets[themeName]
  local card=E.button(gallery,'') card.LayoutOrder=index E.corner(card,16)
  w.Theme:Bind(card,'BackgroundColor3','Surface')
  local border=E.new('UIStroke',{Thickness=1,Transparency=.5},card) w.Theme:Bind(border,'Color','Border')
  local preview=E.new('Frame',{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.fromOffset(10,10),Size=UDim2.new(1,-20,0,52)},card) E.corner(preview,10)
  E.new('UIGradient',{Color=ColorSequence.new(palette.Surface,palette.Primary),Rotation=25},preview)
  local bar=E.new('Frame',{BackgroundColor3=palette.Primary,BorderSizePixel=0,Position=UDim2.new(0,10,1,-18),Size=UDim2.new(.45,0,0,6)},preview) E.corner(bar,3)
  local label=E.text(card,themeName,12) label.Position=UDim2.fromOffset(10,69) label.Size=UDim2.new(1,-20,0,26) label.TextTruncate=Enum.TextTruncate.AtEnd w.Theme:Bind(label,'TextColor3','Text')
  cards[themeName]={Button=card,Border=border}
  tab.Cleanup:Add(card.Activated:Connect(function() controls.theme:SetValue(themeName) end))
 end
 refreshGallery=function()
  for themeName,card in pairs(cards) do
   local selected=controls.theme:GetValue()==themeName
   card.Border.Thickness=selected and 2 or 1 card.Border.Transparency=selected and 0 or .5
   w.Theme:Bind(card.Border,'Color',selected and 'Primary' or 'Border')
  end
 end
 tab.ThemeCards=cards
 tab.Relayout=function(width)
  local wide=width>=650
  groupLayouts.Config.FillDirection=wide and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
  configLeft.Size=UDim2.new(wide and .45 or 1,wide and -5 or 0,0,0)
  configRight.Size=UDim2.new(wide and .55 or 1,wide and -5 or 0,0,0)
  local columns=width>=600 and 4 or width>=290 and 2 or 1
  grid.CellSize=UDim2.new(1/columns,-10*(columns-1)/columns,0,106)
  gallery.Size=UDim2.new(1,0,0,math.ceil(#themeNames/columns)*116-10)
 end
 tab.Relayout(tab.Page.AbsoluteSize.X-24) refreshGallery()
 add('Slider','scale','Tamanho da janela (%)',w.ScalePercent,{Min=0,Max=100,Suffix='%'},function(value) w:SetScale(value) end)
 add('Slider','transparency','Transparência (%)',math.floor(w.Transparency*100+.5),{Min=0,Max=100,Suffix='%'},function(value) w:SetTransparency(value/100) end)
 add('Slider','dim','Escurecer o jogo (%)',0,{Min=0,Max=100,Suffix='%'},function(value) w:SetDim(value/100) end)
 add('ColorPicker','accent','Cor de destaque','#'..w.Theme.Values.Primary:ToHex(),nil,function(value) w:SetTheme({Primary=value}) end)
 add('ColorPicker','background','Cor de fundo','#'..w.Theme.Values.Background:ToHex(),nil,function(value) w:SetTheme({Background=value}) end)
 local function gradient()
  local enabled=controls.gradient:GetValue()
  local a=Color3.fromHex(controls.gradientStart:GetValue():sub(2))
  local b=Color3.fromHex(controls.gradientEnd:GetValue():sub(2))
  w:SetGradient(enabled and {a,b} or {Color3.new(1,1,1),Color3.new(1,1,1)},controls.rotation:GetValue())
 end
 add('Toggle','gradient','Usar gradiente',false,nil,gradient)
 add('ColorPicker','gradientStart','Gradiente: início','#FFFFFF',nil,gradient)
 add('ColorPicker','gradientEnd','Gradiente: fim','#8E79CF',nil,gradient)
 add('Slider','rotation','Ângulo do gradiente',30,{Min=0,Max=360},gradient)
 local originalKey=o.ToggleKey or Enum.KeyCode.RightControl
 add('Keybind','key','Tecla para mostrar / esconder',originalKey.Name,{Changed=function(value) w.ToggleKey=value end},nil)
 -- Restore before returning CreateWindow, independently of callback scheduling.
 local function apply()
  w:SetScale(controls.scale:GetValue()) w:SetTransparency(controls.transparency:GetValue()/100)
  w:SetTheme({Primary=controls.accent.Color,Background=controls.background.Color})
  w.ToggleKey=Enum.KeyCode[controls.key:GetValue()] w:SetDim(controls.dim:GetValue()/100) gradient() refreshGallery()
 end
 apply()
 defaults.accent='#'..initialTheme.Primary:ToHex() defaults.background='#'..initialTheme.Background:ToHex()
 w.SettingsControls=controls
 create('Interface','Button',{Name='Restaurar aparência padrão',Variant='Secondary',Callback=function()
  w:Confirm({Content='Restaurar apenas a aparência? As escolhas das suas abas serão preservadas.',Callback=function(yes)
   if not yes or w.Destroyed then return end
   w:SetTheme(initialTheme)
   for key,value in pairs(defaults) do controls[key]:SetValue(value,true) end
   apply()
  end})
 end})
 create('Config','Section',{Name='ARMAZENAMENTO',Content='Salvamento e restauração de escolhas já fazem parte da library.'})
 local status=create('Config','Paragraph',{Name='Estado do perfil',Content=''})
 local function refresh()
  status:SetValue('Perfil: '..w.ProfileName..'\n'..(w.Storage.Available and 'Armazenamento disponível.' or 'Sem API de arquivos: escolhas somente em memória.')..(w.Storage.LastError and '\nÚltimo erro: '..w.Storage.LastError or ''))
 end
 local auto=create('Config','Toggle',{Id='@ui/autosave',Name='Salvar automaticamente',Default=w.Storage.Enabled,Callback=function(value)
  -- Persist the opt-out before disabling writes, so the next run respects it.
  if not value then w.Storage:Flush() end
  w.Storage.Enabled=value if value then w.Storage:Flush() end refresh()
 end})
 w.Storage.Enabled=auto:GetValue()
 create('Config','Button',{Name='Atualizar estado',Variant='Secondary',Callback=refresh})
 function w:LoadProfile(name)
  self.Storage:ActivateProfile(name)
  local snapshot=table.clone(self.Storage.Values)
  for _,page in ipairs(self.Tabs) do
   for _,control in ipairs(page.Controls) do
    if control.Persistent then
     local value=snapshot[control.Id]
     if value==nil then value=control.Default end
     control:SetValue(value,true)
    end
   end
  end
  local palette=presets[controls.theme:GetValue()]
  if palette then self:SetTheme(palette) end
  apply() self.Storage.Enabled=auto:GetValue()
  -- Apply application callbacks after the entire profile has been restored.
  for _,page in ipairs(self.Tabs) do
   if not page.Internal then
    for _,control in ipairs(page.Controls) do if control.Persistent and control.Kind~='Keybind' then control:SetValue(control:GetValue()) end end
   end
  end
  refresh() if self.RefreshProfiles then self.RefreshProfiles() end
 end
 w.ProfileControls=Profiles.create(w,function(kind,props) props.Persistent=false return create('Profiles',kind,props) end)
 refresh() select('Interface')
 return tab
end
return Settings
