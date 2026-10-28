local E=require(script.Parent.Parent.Core.Elements)
local Cleanup=require(script.Parent.Parent.Core.Cleanup)
local Input=require(script.Parent.Parent.Core.Input)
local UIS=game:GetService('UserInputService')
local ColorPanel={}
function ColorPanel.new(w,o)
 local self={Cleanup=nil,Fields={}}
 local close
 function self:Close()
  if not self.Cleanup then return end
  local cleanup=self.Cleanup self.Cleanup=nil self.Fields={}
  if w.CloseDropdown==close then w.CloseDropdown=nil end
  w.DialogCount=math.max(0,(w.DialogCount or 0)-1) cleanup:Destroy()
 end
 close=function() self:Close() end
 function self:Refresh()
  if not self.Cleanup then return end
  local color=o.GetColor() if not color then return end
  self.Preview.BackgroundColor3=color self.Hex.Text='#'..color:ToHex()
  local channels={color.R,color.G,color.B}
  for index,entry in ipairs(self.Fields) do entry.Input.Text=tostring(math.floor(channels[index]*255+.5)) entry.Fill.Size=UDim2.fromScale(channels[index],1) end
 end
 function self:Open()
  if self.Cleanup then self:Close() return end
  if w.CloseDropdown then w.CloseDropdown() end
  self.Cleanup=Cleanup.new() local cleanup=self.Cleanup
  w.CloseDropdown=close w.DialogCount=(w.DialogCount or 0)+1
  local layer=E.new('Frame',{Name='ColorPickerOverlay',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=150},w.Gui)
  local scrim=E.new('TextButton',{Text='',AutoButtonColor=false,Modal=true,BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.45,Size=UDim2.fromScale(1,1),BorderSizePixel=0,ZIndex=150},layer)
  local panel=E.new('Frame',{Active=true,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BorderSizePixel=0,ZIndex=151},layer)
  E.corner(panel,18) w.Theme:Bind(panel,'BackgroundColor3','Background')
  local border=E.new('UIStroke',{Thickness=1,Transparency=.2},panel) w.Theme:Bind(border,'Color','Border')
  local title=E.text(panel,o.Name or 'Selecionar cor',17) title.Position=UDim2.fromOffset(18,14) title.Size=UDim2.new(1,-76,0,36) w.Theme:Bind(title,'TextColor3','Text')
  local exit=E.button(panel,'') exit.Size=UDim2.fromOffset(36,36) exit.Position=UDim2.new(1,-52,0,14) w.Theme:Bind(exit,'BackgroundColor3','Surface')
  local closeIcon=E.icon(exit,'close') closeIcon.AnchorPoint=Vector2.new(.5,.5) closeIcon.Position=UDim2.fromScale(.5,.5) closeIcon.Size=UDim2.fromOffset(18,18) w.Theme:Bind(closeIcon,'TextColor3','Text')
  local body=E.scroll(panel) body.Position=UDim2.fromOffset(0,62) body.Size=UDim2.new(1,0,1,-126)
  self.Preview=E.new('Frame',{Name='ColorPreview',BorderSizePixel=0,Size=UDim2.new(1,0,0,64)},body) E.corner(self.Preview,12)
  self.Hex=E.new('TextBox',{Text='',PlaceholderText='#RRGGBB',ClearTextOnFocus=false,Size=UDim2.new(1,0,0,42),Font=Enum.Font.Gotham,TextSize=14,BorderSizePixel=0},body) E.corner(self.Hex,10)
  w.Theme:Bind(self.Hex,'BackgroundColor3','Surface') w.Theme:Bind(self.Hex,'TextColor3','Text')
  cleanup:Add(self.Hex.FocusLost:Connect(function() o.SetValue(self.Hex.Text) self:Refresh() end))
  for index,name in ipairs({'R','G','B'}) do
   local row=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,46)},body)
   local label=E.text(row,name,13) label.Size=UDim2.fromOffset(20,46) w.Theme:Bind(label,'TextColor3','MutedText')
   local track=E.new('Frame',{BackgroundTransparency=1,Active=true,Position=UDim2.fromOffset(30,0),Size=UDim2.new(1,-104,1,0)},row)
   local rail=E.new('Frame',{BorderSizePixel=0,Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,.5,-3)},track) E.corner(rail,3) w.Theme:Bind(rail,'BackgroundColor3','Border')
   local fill=E.new('Frame',{BorderSizePixel=0,Size=UDim2.fromScale(0,1)},rail) E.corner(fill,3) w.Theme:Bind(fill,'BackgroundColor3','Primary')
   local field=E.new('TextBox',{Text='',ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=13,Size=UDim2.new(0,58,1,0),Position=UDim2.new(1,-58,0,0),BorderSizePixel=0},row) E.corner(field,10) w.Theme:Bind(field,'BackgroundColor3','Surface') w.Theme:Bind(field,'TextColor3','Text')
   local function setChannel(value)
    local color=o.GetColor() local values={color.R*255,color.G*255,color.B*255}
    values[index]=math.clamp(tonumber(value) or values[index],0,255) o.SetValue(values) self:Refresh()
   end
   Input.slider(track,cleanup,function(fraction) setChannel(math.floor(fraction*255+.5)) end)
   cleanup:Add(field.FocusLost:Connect(function() setChannel(field.Text) end))
   table.insert(self.Fields,{Input=field,Fill=fill})
  end
  local footer=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,-32,0,40),Position=UDim2.new(0,16,1,-54)},panel)
  local reset=E.button(footer,'Padrão') reset.Size=UDim2.new(.5,-5,1,0) w.Theme:Bind(reset,'BackgroundColor3','Surface')
  local done=E.button(footer,'Concluir') done.Size=UDim2.new(.5,-5,1,0) done.Position=UDim2.new(.5,5,0,0) w.Theme:Bind(done,'BackgroundColor3','Primary') w.Theme:Bind(done,'TextColor3','PrimaryText')
  cleanup:Add(reset.Activated:Connect(function() o.SetValue(o.Default) self:Refresh() end))
  cleanup:Add(done.Activated:Connect(close)) cleanup:Add(exit.Activated:Connect(close)) cleanup:Add(scrim.Activated:Connect(close))
  cleanup:Add(UIS.InputBegan:Connect(function(input) if input.KeyCode==Enum.KeyCode.Escape then close() end end))
  local function layout() local size=w.Gui.AbsoluteSize panel.Size=UDim2.fromOffset(math.max(1,math.min(420,size.X-24)),math.max(1,math.min(450,size.Y-24))) end
  cleanup:Add(w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout))
  cleanup:Add(function() w.Theme:Forget(layer) layer:Destroy() end)
  layout() self:Refresh()
 end
 function self:Destroy() self:Close() end
 return self
end
return ColorPanel
