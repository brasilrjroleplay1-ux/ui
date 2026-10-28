local E = require(script.Parent.Elements)
local Cleanup = require(script.Parent.Cleanup)
local TweenService = game:GetService('TweenService')
local UIS = game:GetService('UserInputService')
local Dialogs = {}
local function validate(options)
 assert(type(options)=='table' and #options>0 and #options<=10,'Options precisa conter de 1 a 10 ações.')
 for _,entry in ipairs(options) do
  assert(type(entry)=='table' and type(entry.Name)=='string','Cada opção precisa de Name.')
  assert(entry.Callback==nil or type(entry.Callback)=='function','Callback de opção inválido.')
 end
end
function Dialogs.new(w)
 local manager={Queue={},Records={},Active=nil,Dead=false}
 local pump,finish,render
 local function safe(callback,...)
  if not callback then return end
  local args=table.pack(...)
  task.spawn(function()
   if manager.Dead or w.Destroyed then return end
   local ok,err=pcall(callback,table.unpack(args,1,args.n))
   if not ok then warn('[Conexão UI / popup] '..tostring(err)) end
  end)
 end
 function manager:Popup(options)
  assert(not self.Dead,'Janela destruída.')
  local o=table.clone(options or {})
  o.Options=o.Options or {{Name='Fechar',Value=true}}
  validate(o.Options)
  assert(#self.Queue<20,'Fila de popups cheia.')
  local d={State='Queued',Options=o,Cleanup=Cleanup.new()}
  self.Records[d]=true
  function d:SetValue(value) return self:Update({Content=tostring(value)}) end
  function d:SetOptions(values) return self:Update({Options=values}) end
  function d:Update(values)
   if self.State=='Closed' then return false end
   if values.Options~=nil then validate(values.Options) end
   for key,value in pairs(values) do self.Options[key]=value end
   if self.State=='Visible' then render(self) end
   return true
  end
  function d:Cancel() finish(self,nil,nil) end
  function d:Destroy() self:Cancel() end
  table.insert(self.Queue,d) pump()
  return d
 end
 finish=function(d,value,entry)
  if d.State=='Closed' then return end
  local wasVisible=d.State=='Visible'
  d.State='Closed' d.Cleanup:Destroy() manager.Records[d]=nil
  local index=table.find(manager.Queue,d) if index then table.remove(manager.Queue,index) end
  if wasVisible then manager.Active=nil w.DialogCount=math.max(0,(w.DialogCount or 0)-1) end
  if entry then safe(entry.Callback,value) end
  safe(d.Options.Callback,value)
  if not manager.Dead then pump() end
 end
 render=function(d)
  local o=d.Options
  if not d.Layer then
   local layer=E.new('Frame',{Name='PopupOverlay',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=200},w.Gui) d.Layer=layer
   local scrim=E.new('TextButton',{Text='',AutoButtonColor=false,Modal=true,BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.4,Size=UDim2.fromScale(1,1),BorderSizePixel=0,ZIndex=200},layer)
   local panel=E.new('CanvasGroup',{Active=true,GroupTransparency=1,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BorderSizePixel=0,ZIndex=201},layer) d.Panel=panel
   E.corner(panel,20) w.Theme:Bind(panel,'BackgroundColor3','Surface')
   local stroke=E.new('UIStroke',{Thickness=1,Transparency=.2},panel) w.Theme:Bind(stroke,'Color','Border')
   d.Title=E.text(panel,'',18) d.Title.Position=UDim2.fromOffset(18,16) d.Title.Size=UDim2.new(1,-84,0,38) d.Title.TextTruncate=Enum.TextTruncate.AtEnd w.Theme:Bind(d.Title,'TextColor3','Text')
   local close=E.button(panel,'×') close.Size=UDim2.fromOffset(38,38) close.Position=UDim2.new(1,-54,0,16) w.Theme:Bind(close,'BackgroundColor3','SurfaceHover') d.CloseButton=close
   local content=E.scroll(panel) content.Position=UDim2.fromOffset(0,66) content.Size=UDim2.new(1,0,1,-78) d.Content=content
   d.Body=E.text(content,'',14) d.Body.Size=UDim2.new(1,0,0,0) d.Body.AutomaticSize=Enum.AutomaticSize.Y w.Theme:Bind(d.Body,'TextColor3','MutedText')
   d.Actions=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},content) E.list(d.Actions,10)
   d.ActionCleanup=Cleanup.new()
   local function layout()
    local viewport=w.Gui.AbsoluteSize
    panel.Size=UDim2.fromOffset(math.max(1,math.min(520,viewport.X-24)),math.max(1,math.min(460,viewport.Y-24)))
   end
   d.Cleanup:Add(function() d.ActionCleanup:Destroy() w.Theme:Forget(layer) layer:Destroy() end)
   d.Cleanup:Add(close.Activated:Connect(function() d:Cancel() end))
   d.Cleanup:Add(scrim.Activated:Connect(function() if d.Options.DismissOnOutside and d.Options.Cancellable~=false then d:Cancel() end end))
   d.Cleanup:Add(UIS.InputBegan:Connect(function(input)
    if d.State=='Visible' and input.KeyCode==Enum.KeyCode.Escape and d.Options.Cancellable~=false then d:Cancel() end
   end))
   d.Cleanup:Add(w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout))
   layout() TweenService:Create(panel,TweenInfo.new(.18),{GroupTransparency=0}):Play()
  end
  d.Title.Text=tostring(o.Title or 'Conexão UI') d.Body.Text=tostring(o.Content or '')
  d.CloseButton.Visible=o.Cancellable~=false
  d.ActionCleanup:Destroy() d.ActionCleanup=Cleanup.new()
  for index,entry in ipairs(o.Options) do
   local b=E.button(d.Actions,entry.Name) b.Size=UDim2.new(1,0,0,48)
   w.Theme:Bind(b,'BackgroundColor3',entry.Variant=='Primary' and 'Primary' or 'SurfaceHover') w.Theme:Bind(b,'TextColor3',entry.Variant=='Primary' and 'PrimaryText' or entry.Variant=='Destructive' and 'Error' or 'Text')
   d.ActionCleanup:Add(function() w.Theme:Forget(b) b:Destroy() end)
   d.ActionCleanup:Add(b.Activated:Connect(function()
    if d.State~='Visible' then return end
    local value=entry.Value if value==nil then value=index end
    finish(d,value,entry)
   end))
  end
 end
 pump=function()
  if manager.Dead or manager.Active then return end
  local d=table.remove(manager.Queue,1) if not d then return end
  if w.CloseDropdown then w.CloseDropdown() end
  manager.Active=d d.State='Visible' w.DialogCount=(w.DialogCount or 0)+1
  render(d)
 end
 function manager:Destroy()
  if self.Dead then return end self.Dead=true
  if self.Active then w.DialogCount=math.max(0,(w.DialogCount or 0)-1) end
  for d in pairs(self.Records) do d.State='Closed' d.Cleanup:Destroy() end
  self.Active=nil table.clear(self.Records) table.clear(self.Queue)
 end
 return manager
end
return Dialogs
