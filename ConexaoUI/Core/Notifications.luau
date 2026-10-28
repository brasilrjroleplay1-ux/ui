-- Notification queue, timers and UI are owned by the window, not application code.
local E = require(script.Parent.Elements)
local Cleanup = require(script.Parent.Cleanup)
local TweenService = game:GetService('TweenService')
local Notifications = {}
local kinds = {Info='Primary', Success='Success', Warning='Warning', Error='Error'}
local symbols = {Info='info', Success='✓', Warning='!', Error='×'}
local function duration(value)
 local n=tonumber(value)
 if not n or n~=n then return 5 end
 return math.clamp(n,0,86400)
end
local function validateActions(actions)
 assert(type(actions)=='table' and #actions<=5,'Actions aceita até 5 botões.')
 for _,entry in ipairs(actions) do
  assert(type(entry)=='table' and type(entry.Name)=='string','Cada ação precisa de Name.')
  assert(entry.Callback==nil or type(entry.Callback)=='function','Callback de ação inválido.')
 end
end
function Notifications.new(w,config)
 config=config or {}
 local manager={Records={},Queue={},Active={},Dead=false,Sequence=0,Cleanup=Cleanup.new()}
 local maxVisible=math.clamp(math.floor(tonumber(config.MaxVisible) or 3),1,5)
 local maxQueue=math.clamp(math.floor(tonumber(config.MaxQueue) or 50),1,200)
 local layer=E.new('ScrollingFrame',{Name='Notifications',ZIndex=50,BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-12,1,-12)},w.Gui)
 local list=E.list(layer,10) list.VerticalAlignment=Enum.VerticalAlignment.Bottom
 E.pad(layer,4)
 manager.Layer=layer
 manager.Cleanup:Add(function() w.Theme:Forget(layer) layer:Destroy() end)
 local capacity=maxVisible
 local pump,render,finish
 local function safe(callback,...)
  if not callback then return end
  local args=table.pack(...)
  task.spawn(function()
   if manager.Dead or w.Destroyed then return end
   local ok,err=pcall(callback,table.unpack(args,1,args.n))
   if not ok then warn('[Conexão UI / notification] '..tostring(err)) end
  end)
 end
 function manager:Notify(options)
  assert(not self.Dead,'Janela destruída.')
  local o=table.clone(options or {})
  o.Actions=o.Actions or {} validateActions(o.Actions)
  assert(#self.Queue<maxQueue,'Fila de notificações cheia.')
  self.Sequence+=1
  local n={State='Queued',Options=o,Duration=duration(o.Duration),Remaining=duration(o.Duration),Paused=false,Cleanup=Cleanup.new(),TimerRevision=0,Sequence=self.Sequence}
  self.Records[n]=true
  local function stopTimer()
   n.TimerRevision+=1
   if n.Timer then pcall(task.cancel,n.Timer) n.Timer=nil end
   if n.ProgressTween then n.ProgressTween:Cancel() n.ProgressTween=nil end
  end
  function n:Pause()
   if self.State~='Visible' or self.Paused then return end
   if self.Started then self.Remaining=math.max(0,self.Remaining-(os.clock()-self.Started)) self.Started=nil end
   self.Paused=true stopTimer()
  end
  function n:Resume()
   if self.State~='Visible' then return end
   self.Paused=false stopTimer()
   if self.Duration==0 then return end
   self.Started=os.clock()
   local revision=self.TimerRevision
   if self.Fill then
    self.Fill.Size=UDim2.fromScale(math.clamp(self.Remaining/math.max(self.Duration,.001),0,1),1)
    self.ProgressTween=TweenService:Create(self.Fill,TweenInfo.new(self.Remaining,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(0,1)}) self.ProgressTween:Play()
   end
   self.Timer=task.delay(self.Remaining,function()
    self.Timer=nil
    if self.State=='Visible' and self.TimerRevision==revision then self:Close('timeout') end
   end)
  end
  function n:Close(reason)
   if self.State=='Closed' or self.State=='Closing' then return end
   reason=reason or 'dismiss' self.CloseReason=reason
   stopTimer()
   if self.State=='Queued' then finish(self,reason) return end
   self.State='Closing'
   if self.Card then TweenService:Create(self.Card,TweenInfo.new(.14),{GroupTransparency=1}):Play() end
   self.Exit=task.delay(.14,function() self.Exit=nil finish(self,reason) end)
  end
  function n:Destroy() self:Close('destroy') end
  function n:SetValue(value) return self:Update({Content=tostring(value)}) end
  function n:Update(values)
   if self.State=='Closed' or self.State=='Closing' then return false end
   if values.Actions~=nil then validateActions(values.Actions) end
   for key,value in pairs(values) do self.Options[key]=value end
   if values.Duration~=nil then
    stopTimer() self.Duration=duration(values.Duration) self.Remaining=self.Duration self.Started=nil
   end
   if self.State=='Visible' then
    render(self)
    if values.Duration~=nil and not self.Paused then self:Resume()
    elseif values.PauseOnHover==false and self.Paused then self:Resume() end
   end
   return true
  end
  function n:Dispose()
   stopTimer()
   if self.Exit then pcall(task.cancel,self.Exit) self.Exit=nil end
   self.Cleanup:Destroy()
  end
  table.insert(self.Queue,n) pump()
  return n
 end
 finish=function(n,reason)
  if n.State=='Closed' then return end
  n.State='Closed' n:Dispose()
  manager.Records[n]=nil
  local i=table.find(manager.Active,n) if i then table.remove(manager.Active,i) end
  i=table.find(manager.Queue,n) if i then table.remove(manager.Queue,i) end
  safe(n.Options.OnClose,reason)
  if not manager.Dead then pump() end
 end
 render=function(n)
  local o=n.Options local semantic=kinds[o.Kind] or 'Primary'
  if not n.Card then
   local card=E.new('CanvasGroup',{Name='Notification',LayoutOrder=n.Sequence,GroupTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,-8,0,0),AutomaticSize=Enum.AutomaticSize.Y},layer)
   n.Card=card E.corner(card,16) E.pad(card,14) E.list(card,10)
   w.Theme:Bind(card,'BackgroundColor3','Surface')
   local border=E.new('UIStroke',{Thickness=1,Transparency=.2},card) w.Theme:Bind(border,'Color','Border')
   local header=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,36)},card) n.Header=header
   n.Title=E.text(header,'',14) n.Title.Position=UDim2.fromOffset(34,0) n.Title.Size=UDim2.new(1,-74,1,0) w.Theme:Bind(n.Title,'TextColor3','Text')
   local close=E.button(header,'×') close.Size=UDim2.fromOffset(32,32) close.Position=UDim2.new(1,-32,0,0) w.Theme:Bind(close,'BackgroundColor3','SurfaceHover')
   n.Body=E.text(card,'',13) n.Body.Size=UDim2.new(1,0,0,0) n.Body.AutomaticSize=Enum.AutomaticSize.Y w.Theme:Bind(n.Body,'TextColor3','MutedText')
   n.Actions=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},card) E.list(n.Actions,8)
   n.ActionCleanup=Cleanup.new()
   local rail=E.new('Frame',{BorderSizePixel=0,Size=UDim2.new(1,0,0,3)},card) E.corner(rail,2) w.Theme:Bind(rail,'BackgroundColor3','Border') n.Rail=rail
   n.Fill=E.new('Frame',{BorderSizePixel=0,Size=UDim2.fromScale(1,1)},rail) E.corner(n.Fill,2)
   n.Cleanup:Add(function() n.ActionCleanup:Destroy() w.Theme:Forget(card) card:Destroy() end)
   n.Cleanup:Add(close.Activated:Connect(function() n:Close('dismiss') end))
   n.Cleanup:Add(card.MouseEnter:Connect(function() if n.Options.PauseOnHover~=false then n:Pause() end end))
   n.Cleanup:Add(card.MouseLeave:Connect(function() if n.Options.PauseOnHover~=false then n:Resume() end end))
   TweenService:Create(card,TweenInfo.new(.18),{GroupTransparency=0}):Play()
  end
  n.Title.Text=tostring(o.Title or 'Conexão UI') n.Body.Text=tostring(o.Content or '')
  n.Body.Visible=n.Body.Text~='' n.Rail.Visible=n.Duration>0
  w.Theme:Bind(n.Fill,'BackgroundColor3',semantic)
  if n.Icon then w.Theme:Forget(n.Icon) n.Icon:Destroy() end
  n.Icon=E.icon(n.Header,o.Icon or symbols[o.Kind] or 'info') n.Icon.Position=UDim2.fromOffset(0,6)
  w.Theme:Bind(n.Icon,n.Icon:IsA('ImageLabel') and 'ImageColor3' or 'TextColor3',semantic)
  n.ActionCleanup:Destroy() n.ActionCleanup=Cleanup.new()
  n.Actions.Visible=#o.Actions>0
  for _,entry in ipairs(o.Actions) do
   local b=E.button(n.Actions,entry.Name) w.Theme:Bind(b,'BackgroundColor3',semantic) w.Theme:Bind(b,'TextColor3','Text')
   n.ActionCleanup:Add(function() w.Theme:Forget(b) b:Destroy() end)
   n.ActionCleanup:Add(b.Activated:Connect(function()
    if n.State~='Visible' then return end
    safe(entry.Callback,n)
    if entry.Close~=false then n:Close('action') end
   end))
  end
 end
 pump=function()
  if manager.Dead then return end
  while #manager.Active<capacity and #manager.Queue>0 do
   local n=table.remove(manager.Queue,1)
   if n.State=='Queued' then n.State='Visible' table.insert(manager.Active,n) render(n) n:Resume() end
  end
 end
 local function layout()
  local viewport=w.Gui.AbsoluteSize
  layer.Size=UDim2.fromOffset(math.max(1,math.min(tonumber(config.Width) or 360,viewport.X-24)),math.max(1,viewport.Y-24))
  capacity=(viewport.Y<600 or viewport.X<600) and 1 or maxVisible
  for index=#manager.Active,capacity+1,-1 do
   local n=manager.Active[index]
   if n.State=='Visible' then
    table.remove(manager.Active,index)
    n:Pause() n.Cleanup:Destroy() n.Cleanup=Cleanup.new() n.Card=nil n.Icon=nil n.State='Queued'
    table.insert(manager.Queue,1,n)
   end
  end
  pump()
 end
 manager.Cleanup:Add(w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout))
 function manager:Destroy()
  if self.Dead then return end self.Dead=true
  for n in pairs(self.Records) do n.State='Closed' n:Dispose() end
  table.clear(self.Records) table.clear(self.Queue) table.clear(self.Active)
  self.Cleanup:Destroy()
 end
 layout()
 return manager
end
return Notifications
