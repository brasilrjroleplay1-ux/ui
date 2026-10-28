local E=require(script.Parent.Parent.Core.Elements)
local Cleanup=require(script.Parent.Parent.Core.Cleanup)
local Input=require(script.Parent.Parent.Core.Input)
local Animate=require(script.Parent.Parent.Core.Animation)
local UIS=game:GetService('UserInputService')
local DropdownPanel=require(script.Parent.DropdownPanel)
local Factory={}
function Factory.create(tab,kind,o)
 o=o or {}
 local w=tab.Window
 local clean=Cleanup.new()
 tab.Cleanup:Add(clean)
 local dead=false
 local row=E.new('Frame',{Name=kind,BackgroundTransparency=w.Transparency,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},tab.Page)
 E.corner(row,w.Theme.Values.CornerRadius) E.pad(row,12) E.list(row,8)
 w.Theme:Bind(row,'BackgroundColor3','Surface')
 local title=E.text(row,o.Name or kind,14) title.Size=UDim2.new(1,0,0,0) title.AutomaticSize=Enum.AutomaticSize.Y w.Theme:Bind(title,'TextColor3','Text')
 local c={Instance=row,Disabled=o.Disabled==true,Kind=kind}
 local id=o.Id or tab.Id..'/'..(o.Name or kind)
 local persistent=o.Persistent~=false and (kind=='Toggle' or kind=='Slider' or kind=='Dropdown' or kind=='Textbox' or kind=='Keybind' or kind=='ColorPicker')
 c.Persistent=persistent c.Id=id
 c.Default=o.Default
 if c.Default==nil then
  if kind=='Slider' then c.Default=o.Min or 0 elseif kind=='Toggle' then c.Default=false elseif kind=='Textbox' then c.Default='' elseif kind=='Keybind' then c.Default=o.Key or 'RightControl' elseif kind=='ColorPicker' then c.Default='#9070F7' end
 end
 if persistent then assert(not w.Ids[id], 'Id duplicado: '..id) w.Ids[id]=true end
 clean:Add(function() dead=true local index=table.find(tab.Controls,c) if index then table.remove(tab.Controls,index) end if persistent then w.Ids[id]=nil end w.Theme:Forget(row) row:Destroy() end)
 local function callback(value)
  if dead then return end
  if o.Callback then
   task.spawn(function() if dead then return end local ok,err=pcall(o.Callback,value) if not ok then warn('[Conexão UI callback] '..tostring(err)) end end)
  end
 end
 local function save(value)
  if persistent then
   -- JSON cannot distinguish a missing key from Lua nil; retain explicit clears.
   if kind=='Dropdown' and value==nil then w.Storage:Set(id,{__ConexaoEmptyDropdown=true})
   else w.Storage:Set(id,value) end
  end
 end
 local function commit(value,silent)
  c.Value=value save(value) if not silent then callback(value) end
 end
 function c:GetValue() if type(self.Value)=='table' then return table.clone(self.Value) end return self.Value end
 function c:SetDisabled(value) self.Disabled=value==true if self.Disabled and self.Popup then self.Popup:Close() end row.BackgroundTransparency=self.Disabled and .55 or w.Transparency end
 function c:Destroy() if dead then return end dead=true clean:Destroy() end
 function c:Update(props)
  if props.Name then title.Text=props.Name end
  if props.Disabled~=nil then self:SetDisabled(props.Disabled) end
  if props.Value~=nil then self:SetValue(props.Value,props.Silent) end
  if kind=='Button' and props.Name then self:SetValue(props.Name) end
 end
 local initial=if persistent then w.Storage.Values[id] else nil
 if initial==nil then initial=o.Default end
 local function button(text)
  local b=E.button(row,text) w.Theme:Bind(b,'BackgroundColor3','SurfaceHover') w.Theme:Bind(b,'TextColor3','Text')
  clean:Add(b.MouseEnter:Connect(function() if not c.Disabled then Animate(b,{BackgroundTransparency=.18}) end end))
  clean:Add(b.MouseLeave:Connect(function() Animate(b,{BackgroundTransparency=0}) end))
  clean:Add(b.MouseButton1Down:Connect(function() if not c.Disabled then Animate(b,{BackgroundTransparency=.4},.08) end end))
  clean:Add(b.MouseButton1Up:Connect(function() Animate(b,{BackgroundTransparency=0},.08) end))
  return b
 end
 if kind=='Button' then
  title.Visible=false
  local b=button(o.Name or 'Button')
  w.Theme:Bind(b,'BackgroundColor3',o.Variant=='Destructive' and 'Error' or o.Variant=='Secondary' and 'SurfaceHover' or 'Primary')
  if o.Icon then local icon=E.icon(b,o.Icon) icon.Position=UDim2.new(0,12,.5,-12) end
  clean:Add(b.Activated:Connect(function() if not c.Disabled then callback() end end))
  function c:SetValue(value) b.Text=tostring(value) end
 elseif kind=='Toggle' then
  local b=button('')
  local indicator=E.new('Frame',{Size=UDim2.fromOffset(38,24),Position=UDim2.new(1,-50,.5,-12),BorderSizePixel=0},b) E.corner(indicator,12)
  local knob=E.new('Frame',{Size=UDim2.fromOffset(18,18),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},indicator) E.corner(knob,9)
  function c:SetValue(value,silent)
   value=value==true
   w.Theme:Bind(indicator,'BackgroundColor3',value and 'Primary' or 'Border')
   Animate(knob,{Position=UDim2.fromOffset(value and 17 or 3,3)})
   b.Text=value and 'Ativado' or 'Desativado' commit(value,silent)
  end
  clean:Add(b.Activated:Connect(function() if not c.Disabled then c:SetValue(not c.Value) end end))
  c:SetValue(initial==true,true)
 elseif kind=='Slider' or kind=='ProgressBar' then
  local minimum,maximum=o.Min or 0,o.Max or 100
  local step=o.Increment or o.Step or 1
  assert(maximum>minimum and step>0,'Intervalo ou incremento inválido')
  local line=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,44)},row)
  local valueLabel=E.new(kind=='Slider' and 'TextBox' or 'TextLabel',{Text='',Font=Enum.Font.GothamMedium,TextSize=13,BorderSizePixel=0,Size=UDim2.new(0,76,1,0),Position=UDim2.new(1,-76,0,0)},line)
  E.corner(valueLabel,10) w.Theme:Bind(valueLabel,'TextColor3','Text') w.Theme:Bind(valueLabel,'BackgroundColor3','SurfaceHover')
  local track=E.new('Frame',{Active=true,Size=UDim2.new(1,-94,1,0),BackgroundTransparency=1},line)
  local rail=E.new('Frame',{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,.5,-3),BorderSizePixel=0},track) E.corner(rail,3) w.Theme:Bind(rail,'BackgroundColor3','Border')
  local fill=E.new('Frame',{Size=UDim2.fromScale(0,1),BorderSizePixel=0},rail) E.corner(fill,3) w.Theme:Bind(fill,'BackgroundColor3','Primary')
  local knob
  if kind=='Slider' then
   knob=E.new('Frame',{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(22,22),Position=UDim2.fromScale(0,.5),BorderSizePixel=0},rail) E.corner(knob,11) w.Theme:Bind(knob,'BackgroundColor3','Text')
   local stroke=E.new('UIStroke',{Thickness=1,Transparency=.3},knob) w.Theme:Bind(stroke,'Color','Primary')
  end
  local function display() valueLabel.Text=string.format('%g',c.Value)..(o.Suffix or '') end
  function c:SetValue(value,silent)
   value=math.clamp(tonumber(value) or minimum,minimum,maximum)
   value=math.clamp(minimum+math.floor((value-minimum)/step+.5)*step,minimum,maximum)
   local fraction=(value-minimum)/(maximum-minimum)
   fill.Size=UDim2.fromScale(fraction,1)
   if knob then knob.Position=UDim2.fromScale(fraction,.5) end
   commit(value,silent) display()
  end
  if kind=='Slider' then
   valueLabel.ClearTextOnFocus=false
   clean:Add(valueLabel.Focused:Connect(function() if c.Disabled then valueLabel:ReleaseFocus() end end))
   clean:Add(valueLabel.FocusLost:Connect(function()
    local value=tonumber(valueLabel.Text:match('^[%s]*([%+%-]?[%d%.]+)'))
    if not c.Disabled and value then c:SetValue(value) else display() end
   end))
  end
  if kind=='Slider' then Input.slider(track,clean,function(f) if not c.Disabled then c:SetValue(minimum+f*(maximum-minimum)) end end) end
  c:SetValue(initial or o.Value or minimum,true)
 elseif kind=='Dropdown' then
  local options=table.clone(o.Options or {})
  local b=button('Selecionar  ▾')
  local popup
  function c:SetValue(value,silent)
   if o.Multi then
    local selected={}
    if type(value)=='table' then for _,v in ipairs(value) do if table.find(options,v) and not table.find(selected,v) then table.insert(selected,v) end end end
    value=selected b.Text=(#selected>0 and table.concat(selected,', ') or 'Selecionar')..'  ▾'
   else
    value=table.find(options,value) and value or nil b.Text=tostring(value or 'Selecionar')..'  ▾'
   end
   commit(value,silent)
   if popup then popup:RefreshSelection() end
  end
  popup=DropdownPanel.new(w,{
   Title=o.Name or 'Selecionar',Multi=o.Multi==true,Searchable=o.Searchable~=false,
   Default=type(o.Default)=='table' and table.clone(o.Default) or o.Default,Options=options,
   GetValue=function() return c:GetValue() end,
   SetValue=function(value) if not dead and not c.Disabled then c:SetValue(value) end end,
  })
  clean:Add(popup)
  c.Popup=popup
  function c:Open() if not dead and not self.Disabled then popup:Open() end end
  function c:Close() popup:Close() end
  function c:SetOptions(values) options=table.clone(values) self:SetValue(self.Value,true) popup:SetOptions(options) end
  clean:Add(b.Activated:Connect(function() c:Open() end))
  c:SetValue(initial,true)
 elseif kind=='Textbox' then
  local box=E.new('TextBox',{Text='',PlaceholderText=o.Placeholder or 'Digite aqui…',ClearTextOnFocus=false,MultiLine=o.MultiLine==true,Size=UDim2.new(1,0,0,o.MultiLine and 140 or 44),Font=Enum.Font.Gotham,TextSize=14,BorderSizePixel=0},row)
  E.corner(box) w.Theme:Bind(box,'BackgroundColor3','Background') w.Theme:Bind(box,'TextColor3','Text')
  local errorText=E.text(row,'',12) errorText.Visible=false w.Theme:Bind(errorText,'TextColor3','Error')
  function c:SetValue(value,silent)
   value=tostring(value or '')
   local n=o.MaxLength or 256
   local cut=utf8.offset(value,n+1) if cut then value=value:sub(1,cut-1) end
   if o.Validate then local ok,valid,message=pcall(o.Validate,value) if not ok or valid==false then errorText.Text=tostring(message or 'Valor inválido') errorText.Visible=true box.Text=self.Value or '' return false end end
   errorText.Visible=false box.Text=value commit(value,silent) return true
  end
  clean:Add(box.Focused:Connect(function() if c.Disabled then box:ReleaseFocus() end end))
  clean:Add(box.FocusLost:Connect(function() if not c.Disabled then c:SetValue(box.Text) end end))
  c:SetValue(initial or '',true)
 elseif kind=='Keybind' then
  local b=button('') local capturing=false
  function c:SetValue(value,silent)
   if typeof(value)=='EnumItem' then value=value.Name end
   local valid,key=pcall(function() return Enum.KeyCode[value] end)
   if type(value)~='string' or not valid or not key or value=='Unknown' then value='RightControl' end
   b.Text=value self.Value=value save(value)
   if not silent and o.Changed then pcall(o.Changed,Enum.KeyCode[value]) end
  end
  clean:Add(b.Activated:Connect(function() if not c.Disabled then capturing=true w.Capturing=c b.Text='Pressione uma tecla… (Esc cancela)' end end))
  clean:Add(UIS.InputBegan:Connect(function(i,processed)
   if c.Disabled or (w.DialogCount or 0)>0 or UIS:GetFocusedTextBox() then return end
   if capturing then
    if i.UserInputType~=Enum.UserInputType.Keyboard then return end
    capturing=false w.Capturing=nil
    if i.KeyCode==Enum.KeyCode.Escape then b.Text=c.Value else c:SetValue(i.KeyCode) end
   elseif not processed and not w.Capturing and i.KeyCode.Name==c.Value then callback(i.KeyCode) end
  end))
  clean:Add(function() if w.Capturing==c then w.Capturing=nil end end)
  c:SetValue(initial or o.Key or 'RightControl',true)
 elseif kind=='ColorPicker' then
  local preview=button('') local panel=E.new('Frame',{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),Visible=false},row) E.list(panel,8)
  local fields={}
  local function parse(v)
   if typeof(v)=='Color3' then return v end
   if type(v)=='string' and v:match('^#?%x%x%x%x%x%x$') then return Color3.fromHex(v:gsub('#','')) end
   if type(v)=='table' and tonumber(v[1]) and tonumber(v[2]) and tonumber(v[3]) then return Color3.fromRGB(math.clamp(tonumber(v[1]),0,255),math.clamp(tonumber(v[2]),0,255),math.clamp(tonumber(v[3]),0,255)) end
   return nil
  end
  function c:SetValue(value,silent)
   value=parse(value) if not value then return false end
   self.Color=value self.Value='#'..value:ToHex() preview.BackgroundColor3=value preview.Text=self.Value
   for index,field in ipairs(fields) do local channel=({value.R,value.G,value.B})[index] field.Text=tostring(math.floor(channel*255+.5)) end
   save(self.Value) if not silent then callback(value) end return true
  end
  local hex=E.new('TextBox',{Text='',PlaceholderText='#RRGGBB',Size=UDim2.new(1,0,0,38),Font=Enum.Font.Gotham,TextSize=14,ClearTextOnFocus=false},panel) w.Theme:Bind(hex,'BackgroundColor3','SurfaceHover') w.Theme:Bind(hex,'TextColor3','Text') E.corner(hex)
  clean:Add(hex.FocusLost:Connect(function() if not c.Disabled then c:SetValue(hex.Text) hex.Text=c.Value end end))
  for index,channel in ipairs({'R','G','B'}) do
   local group=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,76)},panel)
   local field=E.new('TextBox',{Text='',PlaceholderText=channel,Size=UDim2.new(1,0,0,36),Font=Enum.Font.Gotham,TextSize=14,ClearTextOnFocus=false},group) fields[index]=field E.corner(field) w.Theme:Bind(field,'BackgroundColor3','SurfaceHover') w.Theme:Bind(field,'TextColor3','Text')
   local rail=E.new('Frame',{Active=true,Size=UDim2.new(1,0,0,32),Position=UDim2.fromOffset(0,40),BorderSizePixel=0},group) E.corner(rail) w.Theme:Bind(rail,'BackgroundColor3','Border')
   local function setChannel(n)
    local color=c.Color local values={color.R*255,color.G*255,color.B*255} values[index]=n c:SetValue(values) hex.Text=c.Value
   end
   Input.slider(rail,clean,function(f) if not c.Disabled then setChannel(math.floor(f*255+.5)) end end)
   clean:Add(field.FocusLost:Connect(function() if not c.Disabled then setChannel(math.clamp(tonumber(field.Text) or 0,0,255)) end end))
  end
  clean:Add(preview.Activated:Connect(function() if not c.Disabled then panel.Visible=not panel.Visible end end))
  if not c:SetValue(initial,true) then if not c:SetValue(o.Default,true) then c:SetValue('#9070F7',true) end end hex.Text=c.Value
 else
  local body=E.text(row,o.Content or o.Text or '',13) body.AutomaticSize=Enum.AutomaticSize.Y body.Size=UDim2.new(1,0,0,0) w.Theme:Bind(body,'TextColor3','MutedText')
  if kind=='Divider' then title.Visible=false body.Visible=false row.Size=UDim2.new(1,0,0,2) row.AutomaticSize=Enum.AutomaticSize.None end
  if kind=='Badge' then w.Theme:Bind(row,'BackgroundColor3',o.Color or 'Primary') end
  function c:SetValue(value) self.Value=value body.Text=tostring(value) end
 end
 c:SetDisabled(c.Disabled)
 if persistent and o.FireOnInit~=false and o.Callback and kind~='Keybind' then callback(kind=='ColorPicker' and c.Color or c:GetValue()) end
 table.insert(tab.Controls,c)
 return c
end
return Factory
