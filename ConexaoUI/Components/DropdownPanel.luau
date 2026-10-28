local E=require(script.Parent.Parent.Core.Elements)
local Cleanup=require(script.Parent.Parent.Core.Cleanup)
local UIS=game:GetService('UserInputService')
local Panel={}
function Panel.new(w,o)
 local self={Options=table.clone(o.Options),Cleanup=nil,Buttons={}}
 local close
 function self:Close()
  if not self.Cleanup then return end
  local cleanup=self.Cleanup self.Cleanup=nil self.Buttons={}
  if w.CloseDropdown==close then w.CloseDropdown=nil end
  w.DialogCount=math.max(0,(w.DialogCount or 0)-1)
  cleanup:Destroy()
 end
 close=function() self:Close() end
 function self:RefreshSelection()
  local value=o.GetValue()
  for _,entry in ipairs(self.Buttons) do
   local selected=if o.Multi then table.find(value or {},entry.Value)~=nil else value==entry.Value
   entry.Button.Text=(selected and '✓  ' or '')..tostring(entry.Value)
   w.Theme:Bind(entry.Button,'BackgroundColor3',selected and 'Primary' or 'SurfaceHover')
   w.Theme:Bind(entry.Stroke,'Color',selected and 'Primary' or 'Border')
  end
 end
 function self:SetOptions(values)
  self.Options=table.clone(values)
  if self.Rebuild then self.Rebuild() end
 end
 function self:Open()
  if self.Cleanup then self:Close() return end
  if w.CloseDropdown then w.CloseDropdown() end
  local cleanup=Cleanup.new() self.Cleanup=cleanup
  w.CloseDropdown=close w.DialogCount=(w.DialogCount or 0)+1
  local layer=E.new('Frame',{Name='DropdownOverlay',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=150},w.Gui)
  local scrim=E.new('TextButton',{Text='',AutoButtonColor=false,Modal=true,BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.75,Size=UDim2.fromScale(1,1),ZIndex=150,BorderSizePixel=0},layer)
  local panel=E.new('Frame',{Name='Options',Active=true,BorderSizePixel=0,ZIndex=151},layer)
  E.corner(panel,20) w.Theme:Bind(panel,'BackgroundColor3','Background')
  local stroke=E.new('UIStroke',{Thickness=1,Transparency=.15},panel) w.Theme:Bind(stroke,'Color','Border')
  local title=E.text(panel,o.Title or 'Selecionar',18) title.Position=UDim2.fromOffset(18,14) title.Size=UDim2.new(1,-80,0,26) title.ZIndex=152 w.Theme:Bind(title,'TextColor3','Text')
  local subtitle=E.text(panel,o.Multi and 'Selecione uma ou mais opções' or 'Selecione uma opção',12) subtitle.Position=UDim2.fromOffset(18,42) subtitle.Size=UDim2.new(1,-36,0,22) subtitle.ZIndex=152 w.Theme:Bind(subtitle,'TextColor3','MutedText')
  local exit=E.button(panel,'×') exit.Size=UDim2.fromOffset(42,42) exit.Position=UDim2.new(1,-56,0,12) exit.ZIndex=152 w.Theme:Bind(exit,'BackgroundColor3','Surface')
  local query=E.new('TextBox',{Text='',PlaceholderText='⌕  Pesquisar opções…',ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=14,BorderSizePixel=0,Size=UDim2.new(1,-32,0,44),Position=UDim2.fromOffset(16,78),Visible=o.Searchable,ZIndex=152},panel)
  E.corner(query,12) E.pad(query,12) w.Theme:Bind(query,'BackgroundColor3','Surface') w.Theme:Bind(query,'TextColor3','Text')
  local listTop=o.Searchable and 134 or 78
  local list=E.new('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,Position=UDim2.fromOffset(16,listTop),Size=UDim2.new(1,-32,1,-listTop-80),ZIndex=152},panel)
  local grid=E.new('UIGridLayout',{CellPadding=UDim2.fromOffset(10,10),SortOrder=Enum.SortOrder.LayoutOrder},list)
  local empty=E.text(panel,'Nenhuma opção encontrada.',14) empty.Position=UDim2.fromOffset(18,listTop+10) empty.Size=UDim2.new(1,-36,0,30) empty.Visible=false empty.ZIndex=153 w.Theme:Bind(empty,'TextColor3','MutedText')
  local footer=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,-32,0,48),Position=UDim2.new(0,16,1,-64),ZIndex=152},panel)
  local actions={{'Padrão',function() o.SetValue(o.Default) end},{'Limpar',function() o.SetValue(o.Multi and {} or nil) end}}
  if o.Multi then table.insert(actions,{'Selecionar tudo',function() o.SetValue(table.clone(self.Options)) end}) end
  for index,entry in ipairs(actions) do
   local b=E.button(footer,entry[1]) b.Size=UDim2.new(1/#actions,-8*(#actions-1)/#actions,1,0) b.Position=UDim2.new((index-1)/#actions,8*(index-1)/#actions,0,0) b.ZIndex=153
   w.Theme:Bind(b,'BackgroundColor3',index==#actions and o.Multi and 'Primary' or 'SurfaceHover')
   cleanup:Add(b.Activated:Connect(entry[2]))
  end
  local items=Cleanup.new()
  cleanup:Add(function() items:Destroy() self.Rebuild=nil w.Theme:Forget(layer) layer:Destroy() end)
  local function rebuild()
   items:Destroy() items=Cleanup.new() self.Buttons={}
   list.CanvasPosition=Vector2.new(0,0)
   for index,value in ipairs(self.Options) do
    if tostring(value):lower():find(query.Text:lower(),1,true) then
     local b=E.button(list,tostring(value)) b.LayoutOrder=index b.ZIndex=153 b.TextWrapped=true b.TextTruncate=Enum.TextTruncate.None
     local border=E.new('UIStroke',{Thickness=1,Transparency=.15},b)
     table.insert(self.Buttons,{Value=value,Button=b,Stroke=border})
     items:Add(function() w.Theme:Forget(b) b:Destroy() end)
     items:Add(b.Activated:Connect(function()
      if o.Multi then
       local values=table.clone(o.GetValue() or {}) local at=table.find(values,value)
       if at then table.remove(values,at) else table.insert(values,value) end o.SetValue(values)
      else o.SetValue(value) self:Close() end
     end))
    end
   end
   empty.Visible=#self.Buttons==0 self:RefreshSelection()
  end
  self.Rebuild=rebuild
  local function layout()
   local viewport=w.Gui.AbsoluteSize
   local width=math.max(1,math.min(560,viewport.X-24)) local height=math.max(1,math.min(660,viewport.Y-24))
   local columns=width>=420 and 2 or 1
   grid.CellSize=UDim2.new(1/columns,-(10*(columns-1)+4)/columns,0,56)
   panel.Size=UDim2.fromOffset(width,height)
   local preferred=w.Root.AbsolutePosition.X+w.Root.AbsoluteSize.X-width-12
   panel.Position=UDim2.fromOffset(math.clamp(preferred,12,math.max(12,viewport.X-width-12)),math.max(0,(viewport.Y-height)/2))
  end
  cleanup:Add(scrim.Activated:Connect(close)) cleanup:Add(exit.Activated:Connect(close))
  cleanup:Add(query:GetPropertyChangedSignal('Text'):Connect(rebuild))
  cleanup:Add(w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout))
  cleanup:Add(UIS.InputBegan:Connect(function(input)
   if input.KeyCode==Enum.KeyCode.Escape then self:Close() end
  end))
  layout() rebuild()
 end
 function self:Destroy() self:Close() end
 return self
end
return Panel
