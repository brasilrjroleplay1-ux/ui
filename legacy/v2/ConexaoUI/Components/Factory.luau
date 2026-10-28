local E=require(script.Parent.Parent.Core.Elements)
local Cleanup=require(script.Parent.Parent.Core.Cleanup)
local Input=require(script.Parent.Parent.Core.Input)
local Animate=require(script.Parent.Parent.Core.Animation)
local UIS=game:GetService('UserInputService')
local DropdownPanel=require(script.Parent.DropdownPanel)
local Options=require(script.Parent.Parent.Core.Options)
local RowLayout=require(script.Parent.RowLayout)
local ColorPanel=require(script.Parent.ColorPanel)
local Factory={}
function Factory.create(tab,kind,o)
 o=Options.normalize(o)
 assert(not tab.Dead,'Aba ou grupo destruído.')
 local w=tab.Window
 assert(not w.Destroyed,'Janela destruída.')
 local id=o.Id or tab.Id..'/'..(o.Name or kind)
 local persistent=o.Persistent~=false and (kind=='Toggle' or kind=='Slider' or kind=='Dropdown' or kind=='Textbox' or kind=='Keybind' or kind=='ColorPicker')
 if persistent then assert(not w.Ids[id], 'Id duplicado: '..id) end
 local clean=Cleanup.new()
 tab.Cleanup:Add(clean)
 local dead=false
 local row=E.new('Frame',{Name=kind,BackgroundTransparency=w.Transparency,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},tab.Page)
 E.corner(row,w.Theme.Values.CornerRadius) local padding=E.pad(row,12) local rowList=E.list(row,8)
 w.Theme:Bind(row,'BackgroundColor3','Surface')
 local title=E.text(row,o.Name or kind,15) title.Size=UDim2.new(1,0,0,0) title.AutomaticSize=Enum.AutomaticSize.Y w.Theme:Bind(title,'TextColor3','Text')
 local c={Instance=row,Disabled=o.Disabled==true,Kind=kind,Name=o.Name or kind,Group=tab.IsGroup and tab or nil}
 c.Persistent=persistent c.Id=id
 c.Default=o.Default
 if c.Default==nil then
  if kind=='Slider' then c.Default=o.Min or 0 elseif kind=='Toggle' then c.Default=false elseif kind=='Textbox' then c.Default='' elseif kind=='Keybind' then c.Default=o.Key or 'RightControl' elseif kind=='ColorPicker' then c.Default='#9070F7' end
 end
 if persistent then w.Ids[id]=true end
 clean:Add(function() dead=true local index=table.find(tab.Controls,c) if index then table.remove(tab.Controls,index) end if tab.Members then local at=table.find(tab.Members,c) if at then table.remove(tab.Members,at) end end if persistent then w.Ids[id]=nil end w.Theme:Forget(row) row:Destroy() end)
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
 function c:SetDisabled(value) self.Disabled=value==true if self.Disabled and self.Popup then self.Popup:Close() end row.BackgroundTransparency=self.RowTransparent and 1 or (self.Disabled and .55 or w.Transparency) end
 function c:Destroy() if dead then return end dead=true clean:Destroy() end
 function c:Update(props)
  props=Options.normalize(props)
  if props.Name then self.Name=props.Name title.Text=props.Name end
  if props.Disabled~=nil then self:SetDisabled(props.Disabled) end
  if props.Value~=nil then self:SetValue(props.Value,props.Silent) end
  if kind=='Button' and props.Name and not self.RowTransparent then self:SetValue(props.Name) end
  if w.ApplySearch then w:ApplySearch() end
 end
 local initial=if persistent then w.Storage.Values[id] else nil
 if initial==nil then initial=o.Default end
 local function button(text)
  local b=E.button(row,text) if not c.Widget then c.Widget=b end b.BackgroundTransparency=.12 w.Theme:Bind(b,'BackgroundColor3','SurfaceHover') w.Theme:Bind(b,'TextColor3','Text')
  clean:Add(b.MouseEnter:Connect(function() if not c.Disabled and not c.Unpainted then Animate(b,{BackgroundTransparency=0}) end end))
  clean:Add(b.MouseLeave:Connect(function() if not c.Unpainted then Animate(b,{BackgroundTransparency=.12}) end end))
  clean:Add(b.MouseButton1Down:Connect(function() if not c.Disabled and not c.Unpainted then Animate(b,{BackgroundTransparency=.25},.08) end end))
  clean:Add(b.MouseButton1Up:Connect(function() if not c.Unpainted then Animate(b,{BackgroundTransparency=0},.08) end end))
  return b
 end
 if kind=='Button' then
  title.Visible=false
  local b=button(o.Name or 'Button')
  local filled=o.Variant==nil or o.Variant=='Primary'
  w.Theme:Bind(b,'BackgroundColor3',filled and 'Primary' or 'SurfaceHover')
  w.Theme:Bind(b,'TextColor3',filled and 'PrimaryText' or o.Variant=='Destructive' and 'Error' or 'Text')
  if filled then b.Font=Enum.Font.GothamBold if w.Effects then w.Effects:RegisterButton(b,clean,function() return not c.Disabled end) end end
  if o.Variant=='Destructive' then local stroke=b:FindFirstChildOfClass('UIStroke') if stroke then w.Theme:Bind(stroke,'Color','Error') stroke.Transparency=.35 end end
  if o.Icon then
   local compact=o.Compact==true or (o.Compact==nil and tab.Compact)
   local icon=E.icon(compact and row or b,o.Icon)
   if compact then c.LeadingIcon=icon else
    E.new('UIPadding',{PaddingLeft=UDim.new(0,40),PaddingRight=UDim.new(0,12)},b)
    -- Keep the icon in the inset reserved before the button text.
    icon.Position=UDim2.new(0,-28,.5,-12)
   end
   w.Theme:Bind(icon,icon:IsA('ImageLabel') and 'ImageColor3' or 'TextColor3','Secondary')
  end
  clean:Add(b.Activated:Connect(function() if not c.Disabled then callback() end end))
  function c:SetValue(value) b.Text=tostring(value) end
 elseif kind=='Toggle' then
  local b=button('')
  if o.Compact==true or (o.Compact==nil and tab.Compact) then
   c.Unpainted=true b.BackgroundTransparency=1
   local stroke=b:FindFirstChildOfClass('UIStroke') if stroke then stroke.Transparency=1 end
  end
  local indicator=E.new('Frame',{Size=UDim2.fromOffset(48,28),Position=UDim2.new(1,-48,.5,-14),BorderSizePixel=0},b) E.corner(indicator,14)
  E.new('UIGradient',{Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(235,241,255)),Rotation=90},indicator)
  local knob=E.new('Frame',{Size=UDim2.fromOffset(22,22),BackgroundColor3=Color3.fromRGB(218,238,255),BorderSizePixel=0},indicator) E.corner(knob,11)
  E.new('UIStroke',{Thickness=1,Transparency=.5,Color=Color3.fromRGB(255,255,255)},knob)
  function c:SetValue(value,silent)
   value=value==true
   w.Theme:Bind(indicator,'BackgroundColor3',value and 'Primary' or 'Border')
   Animate(knob,{Position=UDim2.fromOffset(value and 23 or 3,3)})
   b.Text=(o.Compact==true or (o.Compact==nil and tab.Compact)) and '' or (value and 'Ativado' or 'Desativado') commit(value,silent)
  end
  clean:Add(b.Activated:Connect(function() if not c.Disabled then c:SetValue(not c.Value) end end))
  c:SetValue(initial==true,true)
 elseif kind=='Slider' or kind=='ProgressBar' then
  local minimum,maximum=o.Min or 0,o.Max or 100
  local step=o.Increment or o.Step or 1
  assert(maximum>minimum and step>0,'Intervalo ou incremento inválido')
  local line=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,44)},row) c.Widget=line
  local valueLabel=E.new(kind=='Slider' and 'TextBox' or 'TextLabel',{Text='',Font=Enum.Font.RobotoMono,TextSize=14,BorderSizePixel=0,Size=UDim2.new(0,64,1,0),Position=UDim2.new(1,-64,0,0)},line)
  E.corner(valueLabel,10) w.Theme:Bind(valueLabel,'TextColor3','Text') w.Theme:Bind(valueLabel,'BackgroundColor3','SurfaceHover')
  local track=E.new('Frame',{Active=true,Size=UDim2.new(1,-82,1,0),BackgroundTransparency=1},line)
  local rail=E.new('Frame',{Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,.5,-2),BorderSizePixel=0},track) E.corner(rail,3) w.Theme:Bind(rail,'BackgroundColor3','Border')
  local fill=E.new('Frame',{Size=UDim2.fromScale(0,1),BorderSizePixel=0},rail) E.corner(fill,3) w.Theme:Bind(fill,'BackgroundColor3','Primary')
  local knob
  if kind=='Slider' then
   knob=E.new('Frame',{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(23,23),Position=UDim2.fromScale(0,.5),BorderSizePixel=0},rail) E.corner(knob,12) knob.BackgroundColor3=Color3.fromRGB(218,238,255)
   local stroke=E.new('UIStroke',{Thickness=2,Transparency=.15},knob) w.Theme:Bind(stroke,'Color','Primary')
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
  local b=button('Selecionar')
  b.TextXAlignment=Enum.TextXAlignment.Left
  E.new('UIPadding',{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,30)},b)
  local arrow=E.icon(b,'chevron') arrow.AnchorPoint=Vector2.new(.5,.5) arrow.Position=UDim2.new(1,15,.5,0) arrow.Size=UDim2.fromOffset(14,14) w.Theme:Bind(arrow,'TextColor3','MutedText')
  local popup
  function c:SetValue(value,silent)
   if o.Multi then
    local selected={}
    if type(value)=='table' then for _,v in ipairs(value) do if table.find(options,v) and not table.find(selected,v) then table.insert(selected,v) end end end
    value=selected b.Text=(#selected>0 and table.concat(selected,', ') or 'Selecionar')
   else
    value=table.find(options,value) and value or nil b.Text=tostring(value or 'Selecionar')
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
  c.Widget=box
  E.corner(box) w.Theme:Bind(box,'BackgroundColor3','Background') w.Theme:Bind(box,'TextColor3','Text')
  local errorText=E.text(row,'',12) c.ErrorLabel=errorText errorText.Visible=false w.Theme:Bind(errorText,'TextColor3','Error')
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
  local preview=button('')
  preview.Text=''
  local swatch=E.new('Frame',{Name='ColorSwatch',Size=UDim2.fromOffset(18,18),Position=UDim2.new(0,10,.5,-9),BorderSizePixel=0},preview) E.corner(swatch,5)
  c.Swatch=swatch
  local colorText=E.text(preview,'',12) colorText.Font=Enum.Font.RobotoMono colorText.Position=UDim2.fromOffset(36,0) colorText.Size=UDim2.new(1,-42,1,0) w.Theme:Bind(colorText,'TextColor3','Text')
  local function parse(value)
   if typeof(value)=='Color3' then return value end
   if type(value)=='string' and value:match('^#?%x%x%x%x%x%x$') then return Color3.fromHex(value:gsub('#','')) end
   if type(value)=='table' then
    local r,g,b=tonumber(value[1]),tonumber(value[2]),tonumber(value[3])
    if r and g and b and r==r and g==g and b==b then return Color3.fromRGB(math.clamp(r,0,255),math.clamp(g,0,255),math.clamp(b,0,255)) end
   end
  end
  function c:SetValue(value,silent)
   value=parse(value) if not value then return false end
   self.Color=value self.Value='#'..value:ToHex()
   swatch.BackgroundColor3=value colorText.Text=self.Value
   save(self.Value) if not silent then callback(value) end
   if self.Popup then self.Popup:Refresh() end
   return true
  end
  c.Popup=ColorPanel.new(w,{Name=o.Name,Default=o.Default or '#9070F7',GetColor=function() return c.Color end,SetValue=function(value) if not dead and not c.Disabled then c:SetValue(value) end end})
  clean:Add(c.Popup)
  function c:Open() if not dead and not self.Disabled then self.Popup:Open() end end
  function c:Close() self.Popup:Close() end
  clean:Add(preview.Activated:Connect(function() c:Open() end))
  if not c:SetValue(initial,true) then if not c:SetValue(o.Default,true) then c:SetValue('#9070F7',true) end end

 else
  local body=E.text(row,o.Content or o.Text or '',14) body.AutomaticSize=Enum.AutomaticSize.Y body.Size=UDim2.new(1,0,0,0) w.Theme:Bind(body,'TextColor3','MutedText')
  if kind=='Divider' then title.Visible=false body.Visible=false row.Size=UDim2.new(1,0,0,2) row.AutomaticSize=Enum.AutomaticSize.None end
  if kind=='Badge' then w.Theme:Bind(row,'BackgroundColor3',o.Color or 'Primary') end
  function c:SetValue(value) self.Value=value body.Text=tostring(value) end
 end
 RowLayout.apply(c,tab,kind,o,row,title,rowList,padding,clean)
 if not c.RowTransparent and kind~='Divider' then E.fit(row,rowList,clean,24) end
 c:SetDisabled(c.Disabled)
 if persistent and o.FireOnInit~=false and o.Callback and kind~='Keybind' then callback(kind=='ColorPicker' and c.Color or c:GetValue()) end
 table.insert(tab.Controls,c)
 if tab.Members then table.insert(tab.Members,c) end
 if w.ApplySearch then w:ApplySearch() end
 return c
end
return Factory
