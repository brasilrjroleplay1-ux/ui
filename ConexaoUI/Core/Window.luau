local E=require(script.Parent.Elements)
local Theme=require(script.Parent.Theme)
local Cleanup=require(script.Parent.Cleanup)
local Input=require(script.Parent.Input)
local Storage=require(script.Parent.Storage)
local Animate=require(script.Parent.Animation)
local Factory=require(script.Parent.Parent.Components.Factory)
local Notifications=require(script.Parent.Notifications)
local Dialogs=require(script.Parent.Dialogs)
local UIS=game:GetService('UserInputService')
local Players=game:GetService('Players')
local Options=require(script.Parent.Options)
local Group=require(script.Parent.Parent.Components.Group)
local Identity=require(script.Parent.Identity)
local Window={}
function Window.new(o)
 o=Options.normalize(o)
 local player=Players.LocalPlayer
 assert(player,'Conexão UI deve executar no cliente')
 local clean=Cleanup.new()
 local w={Cleanup=clean,Theme=Theme.new(o.Theme),Tabs={},Categories={},Ids={},Transparency=math.clamp(o.Transparency or .04,0,1),Destroyed=false,Capturing=nil}
 local parent=o.Parent or player:WaitForChild('PlayerGui')
 local guiName=o.Id or 'ConexaoUI'
 local previous=parent:FindFirstChild(guiName)
 if previous then previous:Destroy() end
 local gui=E.new('ScreenGui',{Name=guiName,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=o.DisplayOrder or 20,IgnoreGuiInset=false},parent)
 w.Gui=gui
 w.Identity=Identity.new(w,o) clean:Add(w.Identity)
 local config=table.clone(o.Config or {})
 if config.Name==nil then config.Name=(o.Id or o.Title or o.Name or guiName):gsub('[^%w_-]','_')..'-'..tostring(game.PlaceId) end
 w.ProfileName=config.Name
 w.Storage=Storage.new(config)
 w.ToggleKey=o.ToggleKey or Enum.KeyCode.RightControl
 clean:Add(w.Storage)
 clean:Add(function() table.clear(w.Theme.Bindings) gui:Destroy() end)
 clean:Add(gui.Destroying:Connect(function() w:Destroy() end))
 local dim=E.new('Frame',{Name='GameDim',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1},gui)
 local root=E.new('CanvasGroup',{ZIndex=2,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(980,640),BorderSizePixel=0,BackgroundTransparency=w.Transparency},gui)
 w.Root=root w.Theme:Bind(root,'BackgroundColor3','Background') E.corner(root,w.Theme.Values.CornerRadius)
 local border=E.new('UIStroke',{Thickness=1,Transparency=.25},root) w.Theme:Bind(border,'Color','Border')
 local scale=E.new('UIScale',{Scale=1},root)
 local header=E.new('Frame',{Name='WindowHeader',BackgroundTransparency=1,Size=UDim2.new(1,0,0,64),Active=true},root)
 local logo=E.text(header,'ϟ',30) logo.Position=UDim2.fromOffset(18,18) logo.Size=UDim2.fromOffset(30,30) w.Theme:Bind(logo,'TextColor3','Primary')
 local name=E.text(header,o.Title or o.Name or 'CONEXÃO UI',18) name.Name='WindowTitle' name.Font=Enum.Font.GothamBold name.TextWrapped=false name.Position=UDim2.fromOffset(58,13) name.Size=UDim2.new(.5,-58,0,24) w.Theme:Bind(name,'TextColor3','Text')
 local subtitle=E.text(header,o.Subtitle or 'Sua conexão. Seu estilo.',11) subtitle.Position=UDim2.fromOffset(58,38) subtitle.Size=UDim2.new(.6,-58,0,18) w.Theme:Bind(subtitle,'TextColor3','MutedText')
 local versionBadge=E.new('TextLabel',{Name='WindowVersion',Text='v'..(o.Version or '2.0.0'),Font=Enum.Font.GothamMedium,TextSize=10,BorderSizePixel=0,Size=UDim2.fromOffset(64,24),Position=UDim2.fromOffset(210,14)},header) E.corner(versionBadge,8)
 w.Theme:Bind(versionBadge,'BackgroundColor3','SurfaceHover') w.Theme:Bind(versionBadge,'TextColor3','MutedText')
 local headerLine=E.new('Frame',{Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,1,-1),BorderSizePixel=0,BackgroundTransparency=.7},header) w.Theme:Bind(headerLine,'BackgroundColor3','Border')
 local search=E.new('TextBox',{Name='HeaderSearch',Text='',PlaceholderText='Pesquisar…',ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=13,Size=UDim2.fromOffset(160,36),Position=UDim2.new(1,-252,0,14),BorderSizePixel=0},header) E.corner(search) w.Theme:Bind(search,'BackgroundColor3','Surface') w.Theme:Bind(search,'TextColor3','Text')
 local minimize=E.button(header,'−') minimize.Size=UDim2.fromOffset(34,34) minimize.Position=UDim2.new(1,-82,0,15) w.Theme:Bind(minimize,'BackgroundColor3','Surface')
 local close=E.button(header,'×') close.Size=UDim2.fromOffset(34,34) close.Position=UDim2.new(1,-42,0,15) w.Theme:Bind(close,'BackgroundColor3','Surface')
 local sidebar=E.scroll(root) sidebar.Position=UDim2.fromOffset(0,64) sidebar.Size=UDim2.new(0,176,1,-64)
 local navLine=E.new('Frame',{Name='SidebarDivider',Position=UDim2.fromOffset(63,64),Size=UDim2.new(0,1,1,-64),BorderSizePixel=0,BackgroundTransparency=.7},root) w.Theme:Bind(navLine,'BackgroundColor3','Border')
 local content=E.new('Frame',{BackgroundTransparency=1,Position=UDim2.fromOffset(176,64),Size=UDim2.new(1,-176,1,-64),ClipsDescendants=true},root)
 local restore=E.button(gui,'ϟ  Conexão') restore.Size=UDim2.fromOffset(132,44) restore.Position=UDim2.new(0,12,1,-56) restore.Visible=false restore.ZIndex=3 w.Theme:Bind(restore,'BackgroundColor3','Primary') w.Theme:Bind(restore,'TextColor3','PrimaryText')
 local profile=E.new('TextButton',{Name='Profile',Text='',AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.fromOffset(64,64),Position=UDim2.new(0,0,1,-64)},root)
 local avatar=E.new('ImageLabel',{Name='Avatar',BackgroundTransparency=1,Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(13,13)},profile) E.corner(avatar,19).Name='AvatarMask' w.Identity:BindImage(avatar)
 local profileName=E.text(profile,w.Identity.DisplayName,12) profileName.Position=UDim2.fromOffset(58,11) profileName.Size=UDim2.new(1,-66,0,22) profileName.TextTruncate=Enum.TextTruncate.AtEnd w.Theme:Bind(profileName,'TextColor3','Text')
 local profileExecutor=E.text(profile,w.Identity.Executor,10) profileExecutor.Position=UDim2.fromOffset(58,34) profileExecutor.Size=UDim2.new(1,-66,0,18) profileExecutor.TextTruncate=Enum.TextTruncate.AtEnd w.Theme:Bind(profileExecutor,'TextColor3','MutedText')
 clean:Add(profile.Activated:Connect(function() if w.HomeTab then w:SelectTab(w.HomeTab) end end))
 w.Profile={Avatar=avatar,Name=profileName,Executor=profileExecutor}
 local tooltip=E.text(gui,'',12) tooltip.BackgroundTransparency=.08 tooltip.Size=UDim2.fromOffset(180,32) tooltip.Visible=false tooltip.ZIndex=100 tooltip.TextXAlignment=Enum.TextXAlignment.Center E.corner(tooltip) w.Theme:Bind(tooltip,'BackgroundColor3','Surface') w.Theme:Bind(tooltip,'TextColor3','Text')
 local viewport=gui.AbsoluteSize
 local initialScale=viewport.X<760 and 90 or math.min(86,1120/math.max(1,viewport.X)*100,740/math.max(1,viewport.Y)*100)
 w.ScalePercent=math.clamp(tonumber(w.Storage.Values['@scale']) or o.Scale or initialScale,0,100)
 w.Minimized=false w.Visible=true
 local function clamp()
  if w.Destroyed then return end
  local viewport=gui.AbsoluteSize local size=root.AbsoluteSize
  local x=root.Position.X.Scale*viewport.X+root.Position.X.Offset
  local y=root.Position.Y.Scale*viewport.Y+root.Position.Y.Offset
  root.Position=UDim2.fromOffset(math.clamp(x,size.X/2,math.max(size.X/2,viewport.X-size.X/2)),math.clamp(y,size.Y/2,math.max(size.Y/2,viewport.Y-size.Y/2)))
 end
 w.Clamp=clamp
 local compact=false
 local sidebarIcons=o.SidebarLayout~='expanded'
 local function layout()
  if w.Destroyed then return end
  local viewport=gui.AbsoluteSize
  if viewport.X<1 or viewport.Y<1 then return end
  compact=viewport.X<760
  -- Layout uses available viewport space; no global downscaling of touch targets.
  scale.Scale=1
  local fraction=w.ScalePercent/100
  local width=math.min(viewport.X,math.max(math.min(viewport.X,compact and 290 or 520),viewport.X*fraction))
  local height=math.min(viewport.Y,math.max(math.min(viewport.Y,280),viewport.Y*fraction))
  root.Size=UDim2.fromOffset(width,w.Minimized and 64 or height)
  local nav=(compact or sidebarIcons) and 64 or 210
  navLine.Position=UDim2.fromOffset(nav-1,64)
  local showProfile=o.ShowProfile~=false and not w.Minimized
  profile.Visible=showProfile profile.Size=UDim2.fromOffset(nav,64) profileName.Visible=not (compact or sidebarIcons) profileExecutor.Visible=profileName.Visible
  sidebar.Size=UDim2.new(0,nav,1,showProfile and -128 or -64) content.Position=UDim2.fromOffset(nav,64) content.Size=UDim2.new(1,-nav,1,-64)
  search.Visible=width>=660 subtitle.Visible=width>=420
  name.TextSize=compact and 14 or 18 name.TextTruncate=Enum.TextTruncate.AtEnd
  versionBadge.Visible=width>=700
  local available=math.max(30,width-58-(search.Visible and 270 or 96)-(versionBadge.Visible and 76 or 0))
  local measured=(utf8.len(name.Text) or #name.Text)*name.TextSize*.72
  local ok,bounds=pcall(function() return game:GetService('TextService'):GetTextSize(name.Text,name.TextSize,name.Font,Vector2.new(10000,40)) end)
  if ok and bounds then measured=bounds.X end
  name.Size=UDim2.fromOffset(math.min(available,measured+4),24)
  versionBadge.Position=UDim2.fromOffset(58+math.min(available,measured+4)+10,14)
  for _,category in ipairs(w.Categories) do category.Visible=not (compact or sidebarIcons) end
  for _,t in ipairs(w.Tabs) do t.Label.Visible=not (compact or sidebarIcons) end
  for _,t in ipairs(w.Tabs) do if t.Relayout then t.Relayout(width-nav-24) end
   if t.LayoutGroups then t.LayoutGroups(width-nav-24) end end
  clamp()
 end
 function w:SetScale(percent)
  self.ScalePercent=math.clamp(tonumber(percent) or 78,0,100) self.Storage:Set('@scale',self.ScalePercent)
  if self.SettingsControls and self.SettingsControls.scale.Value~=self.ScalePercent then self.SettingsControls.scale:SetValue(self.ScalePercent,true) end
  if self.ScalePercent==0 then self:SetVisible(false) else self:SetVisible(true) end layout()
 end
 function w:SetVisible(visible)
  if not visible then tooltip.Visible=false if self.CloseDropdown then self.CloseDropdown() end end
  self.Visible=visible==true root.Visible=self.Visible restore.Visible=not self.Visible dim.Visible=self.Visible
  if self.Visible then root.GroupTransparency=1 Animate(root,{GroupTransparency=0},.18) end
 end
 function w:Minimize(value)
  tooltip.Visible=false
  if self.CloseDropdown then self.CloseDropdown() end
  self.Minimized=if value==nil then not self.Minimized else value
  sidebar.Visible=not self.Minimized content.Visible=not self.Minimized layout()
 end
 function w:SetTheme(values)
  self.Theme:Apply(values)
  if values.CornerRadius then for _,instance in ipairs(root:GetDescendants()) do if instance:IsA('UICorner') and instance.Name~='AvatarMask' then instance.CornerRadius=UDim.new(0,values.CornerRadius) end end end
 end
 function w:SetTransparency(value)
  self.Transparency=math.clamp(tonumber(value) or 0,0,1) root.BackgroundTransparency=self.Transparency
  if self.SettingsControls then local c=self.SettingsControls.transparency local v=math.floor(self.Transparency*100+.5) if c.Value~=v then c:SetValue(v,true) end end
  for _,t in ipairs(self.Tabs) do
   for _,c in ipairs(t.Controls) do if not c.Disabled then c.Instance.BackgroundTransparency=c.RowTransparent and 1 or self.Transparency end end
   for _,group in ipairs(t.Groups or {}) do group.Instance.BackgroundTransparency=self.Transparency end
  end
 end
 function w:SetDim(value)
  self.Dim=math.clamp(tonumber(value) or 0,0,1) dim.BackgroundTransparency=1-self.Dim
 end
 function w:SetGradient(colors,rotation)
  local gradient=root:FindFirstChildOfClass('UIGradient') or E.new('UIGradient',{},root)
  gradient.Color=ColorSequence.new(colors[1],colors[2]) gradient.Rotation=rotation or 30
 end
 function w:SaveConfig() return self.Storage:SaveProfile() end
 function w:Destroy()
  if self.Destroyed then return end self.Destroyed=true clean:Destroy()
 end
 local function filter()
  local q=search.Text:lower()
  for _,t in ipairs(w.Tabs) do for _,c in ipairs(t.Controls) do
   if not c.Group then c.Instance.Visible=q=='' or c.Name:lower():find(q,1,true)~=nil end
  end
   for _,group in ipairs(t.Groups or {}) do group:Filter(q) end
  end
 end
 function w:ApplySearch() filter() end
 function w:SetSidebarLayout(value) sidebarIcons=value~='expanded' layout() end
 function w:SelectTab(tab)
  if self.CloseDropdown then self.CloseDropdown() end
  for _,t in ipairs(self.Tabs) do
   t.Page.Visible=t==tab
   if t.Stroke then t.Stroke.Transparency=t==tab and .45 or 1 end
   if t.Icon then self.Theme:Bind(t.Icon,t.Icon:IsA('ImageLabel') and 'ImageColor3' or 'TextColor3',t==tab and 'Primary' or 'MutedText') end
   self.Theme:Bind(t.Button,'BackgroundColor3',t==tab and 'SurfaceHover' or 'Background')
   self.Theme:Bind(t.Indicator,'BackgroundColor3',t==tab and 'Primary' or 'Background')
  end
  self.ActiveTab=tab
  tab.Page.Position=UDim2.fromOffset(0,8) Animate(tab.Page,{Position=UDim2.fromOffset(0,0)})
 end
 function w:CreateTab(opts,iconId)
  assert(not self.Destroyed,'Janela destruída.')
  opts=Options.normalize(opts) if iconId~=nil then opts.Icon=iconId end local tab={Window=self,Cleanup=Cleanup.new(),Controls={},Groups={},Internal=opts.Internal==true}
  tab.Id=opts.Id or opts.Name or opts.name or 'Tab'..tostring(#self.Tabs+1)
  for _,existing in ipairs(self.Tabs) do assert(existing.Id~=tab.Id,'Id de aba duplicado: '..tab.Id) end
  clean:Add(tab.Cleanup)
  local b=E.button(sidebar,'') b.Size=UDim2.new(1,0,0,46) tab.Button=b tab.Stroke=b:FindFirstChildOfClass('UIStroke')
  local indicator=E.new('Frame',{Size=UDim2.new(0,3,1,-16),Position=UDim2.fromOffset(0,8),BorderSizePixel=0},b) E.corner(indicator,2) tab.Indicator=indicator
  local icon=E.icon(b,opts.Icon or opts.icon or 'house') icon.Position=UDim2.fromOffset(9,11) tab.Icon=icon
  local label=E.text(b,opts.Name or opts.name or tab.Id,13) label.Position=UDim2.fromOffset(42,0) label.Size=UDim2.new(1,-46,1,0) w.Theme:Bind(label,'TextColor3','Text') tab.Label=label
  local page=E.scroll(content) page.Visible=false tab.Page=page
  local pageTitle=E.text(page,opts.Name or tab.Id,22) pageTitle.LayoutOrder=-1000 w.Theme:Bind(pageTitle,'TextColor3','Text')
  if opts.Description then local description=E.text(page,opts.Description,12) description.LayoutOrder=-999 description.AutomaticSize=Enum.AutomaticSize.Y w.Theme:Bind(description,'TextColor3','MutedText') end
  tab.Cleanup:Add(function() self.Theme:Forget(b) self.Theme:Forget(page) b:Destroy() page:Destroy() end)
  tab.Cleanup:Add(b.Activated:Connect(function() self:SelectTab(tab) end))
  tab.Cleanup:Add(b.MouseEnter:Connect(function()
   tooltip.Text=(opts.Name or tab.Id)..(opts.Description and ' · '..opts.Description or '')
   local p=b.AbsolutePosition tooltip.Position=UDim2.fromOffset(math.min(p.X+b.AbsoluteSize.X+4,math.max(0,gui.AbsoluteSize.X-180)),math.min(p.Y,math.max(0,gui.AbsoluteSize.Y-32))) tooltip.Visible=true
  end))
  tab.Cleanup:Add(b.MouseLeave:Connect(function() tooltip.Visible=false end))
  for _,kind in ipairs({'Button','Toggle','Slider','Dropdown','Textbox','Keybind','ColorPicker','Paragraph','Label','Divider','Section','Badge','ProgressBar'}) do
   tab['Create'..kind]=function(_,options) return Factory.create(tab,kind,options) end
  end
  function tab:CreateGroup(settings)
   assert(not self.Dead and not w.Destroyed,'Aba destruída.')
   settings=Options.normalize(settings)
   local parent=self.Page
   if settings.Column~=nil then
    assert(settings.Column==1 or settings.Column==2,'Column deve ser 1 ou 2.')
    if not self.ColumnFrame then
     self.ColumnFrame=E.new('Frame',{Name='GroupColumns',BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},self.Page)
     local columnLayout=E.list(self.ColumnFrame,12) E.fit(self.ColumnFrame,columnLayout,self.Cleanup,0)
     self.Columns={}
     for index=1,2 do
      local column=E.new('Frame',{BackgroundTransparency=1,LayoutOrder=index,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},self.ColumnFrame)
      local fitList=E.list(column,12) E.fit(column,fitList,self.Cleanup,0) self.Columns[index]=column
     end
     self.LayoutGroups=function(width)
      local wide=width>=700
      columnLayout.FillDirection=wide and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
      for _,column in ipairs(self.Columns) do local height=column.Size.Y.Offset column.Size=wide and UDim2.new(.5,-6,0,height) or UDim2.new(1,0,0,height) end
     end
     self.Cleanup:Add(self.Page:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() self.LayoutGroups(self.Page.AbsoluteSize.X-24) end))
    end
    parent=self.Columns[settings.Column]
    self.LayoutGroups(self.Page.AbsoluteSize.X-24)
   end
   local group=Group.new(self,settings,parent)
   w:ApplySearch()
   return group
  end
  function tab:Destroy()
   if self.Dead then return end self.Dead=true self.Cleanup:Destroy()
   local index=table.find(w.Tabs,self) if index then table.remove(w.Tabs,index) end
   if w.ActiveTab==self and w.Tabs[1] then w:SelectTab(w.Tabs[1]) end
  end
  table.insert(self.Tabs,tab) if #self.Tabs==1 or (self.ActiveTab and self.ActiveTab.Internal and not self.HomeTab and not tab.Internal) then self:SelectTab(tab) end layout() return tab
 end
 function w:CreateCategory(nameText)
  local label=E.text(sidebar,nameText,10) self.Theme:Bind(label,'TextColor3','MutedText')
  table.insert(self.Categories,label) layout()
  return {SetValue=function(_,value) label.Text=tostring(value) end,Destroy=function() local at=table.find(self.Categories,label) if at then table.remove(self.Categories,at) end self.Theme:Forget(label) label:Destroy() end}
 end
 w.Notifications=Notifications.new(w,o.Notifications)
 w.Dialogs=Dialogs.new(w)
 clean:Add(w.Notifications) clean:Add(w.Dialogs)
 function w:Notify(opts) return self.Notifications:Notify(opts) end
 function w:Toast(opts) return self.Notifications:Notify(opts) end
 function w:Popup(opts) return self.Dialogs:Popup(opts) end
 function w:Confirm(opts)
  opts=opts or {}
  local callback=opts.Callback
  return self:Popup({
   Title=opts.Title or 'Confirmar ação',Content=opts.Content or 'Deseja continuar?',
   Cancellable=opts.Cancellable,DismissOnOutside=opts.DismissOnOutside,
   Options={{Name=opts.ConfirmText or 'Confirmar',Value=true,Variant=opts.Destructive and 'Destructive' or 'Primary'},{Name=opts.CancelText or 'Cancelar',Value=false,Variant='Secondary'}},
   Callback=callback and function(value) callback(value==true) end or nil,
  })
 end
 Input.drag(header,root,clean,clamp)
 clean:Add(minimize.Activated:Connect(function() w:Minimize() end))
 clean:Add(close.Activated:Connect(function() w:SetVisible(false) end))
 clean:Add(restore.Activated:Connect(function() if w.ScalePercent==0 then w:SetScale(78) else w:SetVisible(true) end end))
 clean:Add(UIS.InputBegan:Connect(function(i,processed)
  if not processed and (w.DialogCount or 0)==0 and not UIS:GetFocusedTextBox() and not w.Capturing and i.KeyCode==w.ToggleKey then w:SetVisible(not w.Visible) end
 end))
 clean:Add(gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout))
 clean:Add(name:GetPropertyChangedSignal('TextBounds'):Connect(layout))
 clean:Add(search:GetPropertyChangedSignal('Text'):Connect(filter))
 task.defer(function() if not w.Destroyed then layout() w:SetVisible(w.ScalePercent>0) end end)
 return w
end
return Window
