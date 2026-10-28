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
local Window={}
function Window.new(o)
 o=o or {}
 local player=Players.LocalPlayer
 assert(player,'Conexão UI deve executar no cliente')
 local clean=Cleanup.new()
 local w={Cleanup=clean,Theme=Theme.new(o.Theme),Tabs={},Ids={},Transparency=math.clamp(o.Transparency or .08,0,1),Destroyed=false,Capturing=nil}
 local parent=o.Parent or player:WaitForChild('PlayerGui')
 local guiName=o.Id or 'ConexaoUI'
 local previous=parent:FindFirstChild(guiName)
 if previous then previous:Destroy() end
 local gui=E.new('ScreenGui',{Name=guiName,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=o.DisplayOrder or 20,IgnoreGuiInset=false},parent)
 w.Gui=gui
 local config=table.clone(o.Config or {})
 if config.Name==nil then config.Name=(o.Id or o.Title or o.name or guiName):gsub('[^%w_-]','_')..'-'..tostring(game.PlaceId) end
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
 local header=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,64),Active=true},root)
 local logo=E.text(header,'ϟ',30) logo.Position=UDim2.fromOffset(18,18) logo.Size=UDim2.fromOffset(30,30) w.Theme:Bind(logo,'TextColor3','Primary')
 local name=E.text(header,o.Title or o.name or 'CONEXÃO UI',18) name.Position=UDim2.fromOffset(58,13) name.Size=UDim2.new(.5,-58,0,24) w.Theme:Bind(name,'TextColor3','Text')
 local subtitle=E.text(header,(o.Subtitle or o.subtitle or 'Sua conexão. Seu estilo.')..'  /  '..(o.Version or '1.5.0'),11) subtitle.Position=UDim2.fromOffset(58,38) subtitle.Size=UDim2.new(.6,-58,0,18) w.Theme:Bind(subtitle,'TextColor3','MutedText')
 local search=E.new('TextBox',{Text='',PlaceholderText='Pesquisar…',ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=13,Size=UDim2.fromOffset(160,36),Position=UDim2.new(1,-252,0,14),BorderSizePixel=0},header) E.corner(search) w.Theme:Bind(search,'BackgroundColor3','Surface') w.Theme:Bind(search,'TextColor3','Text')
 local minimize=E.button(header,'−') minimize.Size=UDim2.fromOffset(34,34) minimize.Position=UDim2.new(1,-82,0,15) w.Theme:Bind(minimize,'BackgroundColor3','Surface')
 local close=E.button(header,'×') close.Size=UDim2.fromOffset(34,34) close.Position=UDim2.new(1,-42,0,15) w.Theme:Bind(close,'BackgroundColor3','Surface')
 local sidebar=E.scroll(root) sidebar.Position=UDim2.fromOffset(0,64) sidebar.Size=UDim2.new(0,176,1,-64)
 local content=E.new('Frame',{BackgroundTransparency=1,Position=UDim2.fromOffset(176,64),Size=UDim2.new(1,-176,1,-64),ClipsDescendants=true},root)
 local restore=E.button(gui,'ϟ  Conexão') restore.Size=UDim2.fromOffset(132,44) restore.Position=UDim2.new(0,12,1,-56) restore.Visible=false restore.ZIndex=3 w.Theme:Bind(restore,'BackgroundColor3','Primary')
 local tooltip=E.text(gui,'',12) tooltip.BackgroundTransparency=.08 tooltip.Size=UDim2.fromOffset(180,32) tooltip.Visible=false tooltip.ZIndex=100 tooltip.TextXAlignment=Enum.TextXAlignment.Center E.corner(tooltip) w.Theme:Bind(tooltip,'BackgroundColor3','Surface') w.Theme:Bind(tooltip,'TextColor3','Text')
 w.ScalePercent=math.clamp(tonumber(w.Storage.Values['@scale']) or o.Scale or 78,0,100)
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
  local nav=compact and 60 or 176
  sidebar.Size=UDim2.new(0,nav,1,-64) content.Position=UDim2.fromOffset(nav,64) content.Size=UDim2.new(1,-nav,1,-64)
  search.Visible=width>=660 subtitle.Visible=width>=420
  name.TextSize=compact and 14 or 18 name.Size=UDim2.new(1,-154,0,24)
  for _,t in ipairs(w.Tabs) do t.Label.Visible=not compact end
  for _,t in ipairs(w.Tabs) do if t.Relayout then t.Relayout(width-nav-24) end end
  clamp()
 end
 function w:SetScale(percent)
  self.ScalePercent=math.clamp(tonumber(percent) or 78,0,100) self.Storage:Set('@scale',self.ScalePercent)
  if self.SettingsControls and self.SettingsControls.scale.Value~=self.ScalePercent then self.SettingsControls.scale:SetValue(self.ScalePercent,true) end
  if self.ScalePercent==0 then self:SetVisible(false) else self:SetVisible(true) end layout()
 end
 function w:SetVisible(visible)
  if not visible and self.CloseDropdown then self.CloseDropdown() end
  self.Visible=visible==true root.Visible=self.Visible restore.Visible=not self.Visible dim.Visible=self.Visible
  if self.Visible then root.GroupTransparency=1 Animate(root,{GroupTransparency=0},.18) end
 end
 function w:Minimize(value)
  if self.CloseDropdown then self.CloseDropdown() end
  self.Minimized=if value==nil then not self.Minimized else value
  sidebar.Visible=not self.Minimized content.Visible=not self.Minimized layout()
 end
 function w:SetTheme(values)
  self.Theme:Apply(values)
  if values.CornerRadius then for _,instance in ipairs(root:GetDescendants()) do if instance:IsA('UICorner') then instance.CornerRadius=UDim.new(0,values.CornerRadius) end end end
 end
 function w:SetTransparency(value)
  self.Transparency=math.clamp(tonumber(value) or 0,0,1) root.BackgroundTransparency=self.Transparency
  if self.SettingsControls then local c=self.SettingsControls.transparency local v=math.floor(self.Transparency*100+.5) if c.Value~=v then c:SetValue(v,true) end end
  for _,t in ipairs(self.Tabs) do for _,c in ipairs(t.Controls) do if not c.Disabled then c.Instance.BackgroundTransparency=self.Transparency end end end
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
   local label=c.Instance:FindFirstChildOfClass('TextLabel')
   c.Instance.Visible=q=='' or (label and label.Text:lower():find(q,1,true)~=nil)
  end end
 end
 function w:SelectTab(tab)
  if self.CloseDropdown then self.CloseDropdown() end
  for _,t in ipairs(self.Tabs) do
   t.Page.Visible=t==tab
   self.Theme:Bind(t.Button,'BackgroundColor3',t==tab and 'SurfaceHover' or 'Background')
   self.Theme:Bind(t.Indicator,'BackgroundColor3',t==tab and 'Primary' or 'Background')
  end
  self.ActiveTab=tab
  tab.Page.Position=UDim2.fromOffset(0,8) Animate(tab.Page,{Position=UDim2.fromOffset(0,0)})
 end
 function w:CreateTab(opts)
  opts=opts or {} local tab={Window=self,Cleanup=Cleanup.new(),Controls={},Internal=opts.Internal==true}
  tab.Id=opts.Id or opts.Name or opts.name or 'Tab'..tostring(#self.Tabs+1)
  for _,existing in ipairs(self.Tabs) do assert(existing.Id~=tab.Id,'Id de aba duplicado: '..tab.Id) end
  clean:Add(tab.Cleanup)
  local b=E.button(sidebar,'') b.Size=UDim2.new(1,0,0,46) tab.Button=b
  local indicator=E.new('Frame',{Size=UDim2.new(0,3,1,-16),Position=UDim2.fromOffset(0,8),BorderSizePixel=0},b) E.corner(indicator,2) tab.Indicator=indicator
  local icon=E.icon(b,opts.Icon or opts.icon or 'house') icon.Position=UDim2.fromOffset(9,11)
  local label=E.text(b,opts.Name or opts.name or tab.Id,13) label.Position=UDim2.fromOffset(42,0) label.Size=UDim2.new(1,-46,1,0) w.Theme:Bind(label,'TextColor3','Text') tab.Label=label
  local page=E.scroll(content) page.Visible=false tab.Page=page
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
  function tab:Destroy()
   if self.Dead then return end self.Dead=true self.Cleanup:Destroy()
   local index=table.find(w.Tabs,self) if index then table.remove(w.Tabs,index) end
   if w.ActiveTab==self and w.Tabs[1] then w:SelectTab(w.Tabs[1]) end
  end
  table.insert(self.Tabs,tab) if #self.Tabs==1 or (self.ActiveTab and self.ActiveTab.Internal and not tab.Internal) then self:SelectTab(tab) end layout() return tab
 end
 function w:CreateCategory(nameText)
  local label=E.text(sidebar,nameText,10) self.Theme:Bind(label,'TextColor3','MutedText')
  return {SetValue=function(_,value) label.Text=tostring(value) end,Destroy=function() self.Theme:Forget(label) label:Destroy() end}
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
   Options={{Name=opts.ConfirmText or 'Confirmar',Value=true,Variant=opts.Destructive and 'Destructive' or nil},{Name=opts.CancelText or 'Cancelar',Value=false,Variant='Secondary'}},
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
 clean:Add(search:GetPropertyChangedSignal('Text'):Connect(filter))
 task.defer(function() if not w.Destroyed then layout() w:SetVisible(w.ScalePercent>0) end end)
 return w
end
return Window
