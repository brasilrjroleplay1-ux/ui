-- Compact rows inside grouped cards. Small screens stack labels above touch controls.
local E = require(script.Parent.Parent.Core.Elements)
local RowLayout = {}
function RowLayout.apply(c,tab,kind,o,row,title,list,padding,cleanup)
 local compact=o.Compact
 if compact==nil then compact=tab.Compact end
 if not compact or not c.Widget or o.MultiLine then return end
 local w=tab.Window
 list:Destroy()
 for _,property in ipairs({'PaddingTop','PaddingBottom','PaddingLeft','PaddingRight'}) do padding[property]=UDim.new() end
 c.RowTransparent=true row.BackgroundTransparency=1 row.AutomaticSize=Enum.AutomaticSize.None
 title.AutomaticSize=Enum.AutomaticSize.None title.TextYAlignment=Enum.TextYAlignment.Center
 local separator=E.new('Frame',{Name='Separator',Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BorderSizePixel=0,BackgroundTransparency=.6},row)
 w.Theme:Bind(separator,'BackgroundColor3','Border')
 if kind=='Button' then title.Visible=true c.Widget.Text=o.Text or 'Executar' end
 local function layout()
  if not row.Parent then return end
  local width=row.AbsoluteSize.X
  local stacked=width<360
  local base=stacked and 86 or 54
  title.Size=stacked and UDim2.new(1,0,0,28) or UDim2.new(.42,-12,0,54)
  title.Position=UDim2.fromOffset(0,0)
  c.Widget.Position=stacked and UDim2.fromOffset(0,32) or UDim2.new(.42,0,0,5)
  c.Widget.Size=stacked and UDim2.new(1,0,0,44) or UDim2.new(.58,0,0,44)
  if kind=='Toggle' and not stacked then
   c.Widget.Position=UDim2.new(1,-64,0,5) c.Widget.Size=UDim2.fromOffset(64,44)
   title.Size=UDim2.new(1,-80,0,54)
  end
  if c.Expansion then
   c.Expansion.Position=UDim2.fromOffset(0,base+4)
   if c.Expansion.Visible then base+=c.Expansion.AbsoluteSize.Y+12 end
  end
  if c.ErrorLabel then
   c.ErrorLabel.Position=UDim2.fromOffset(0,base)
   if c.ErrorLabel.Visible then base+=28 end
  end
  row.Size=UDim2.new(1,0,0,base)
 end
 cleanup:Add(row:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout))
 if c.Expansion then
  cleanup:Add(c.Expansion:GetPropertyChangedSignal('Visible'):Connect(layout))
  cleanup:Add(c.Expansion:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout))
 end
 if c.ErrorLabel then cleanup:Add(c.ErrorLabel:GetPropertyChangedSignal('Visible'):Connect(layout)) end
 c.Relayout=layout layout()
end
return RowLayout
