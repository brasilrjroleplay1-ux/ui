local E = require(script.Parent.Parent.Core.Elements)
local Cleanup = require(script.Parent.Parent.Core.Cleanup)
local Options = require(script.Parent.Parent.Core.Options)
local Factory = require(script.Parent.Factory)
local Group = {}
function Group.new(tab,options,parent)
 local o=Options.normalize(options)
 local w=tab.Window
 local id=o.Id or o.Name or 'Group'..tostring(#tab.Groups+1)
 for _,existing in ipairs(tab.Groups) do assert(existing.Id~=tab.Id..'/'..id,'Id de grupo duplicado: '..id) end
 local group={Window=w,Id=tab.Id..'/'..id,Name=o.Name or 'Grupo',Cleanup=Cleanup.new(),Members={},Controls=tab.Controls,Compact=o.Compact~=false,IsGroup=true,Collapsed=o.Collapsed==true,Dead=false}
 tab.Cleanup:Add(group.Cleanup)
 local root=E.new('Frame',{Name=group.Name,BackgroundTransparency=w.Transparency,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},parent or tab.Page)
 E.corner(root,20) E.pad(root,16) local rootLayout=E.list(root,6) E.fit(root,rootLayout,group.Cleanup,32) w.Theme:Bind(root,'BackgroundColor3','Surface')
 local border=E.new('UIStroke',{Thickness=1,Transparency=.5},root) w.Theme:Bind(border,'Color','Border')
 group.Instance=root
 local header=E.button(root,'') header.Name='GroupHeader' header.Size=UDim2.new(1,0,0,38) header.BackgroundTransparency=1 local headerStroke=header:FindFirstChildOfClass('UIStroke') if headerStroke then headerStroke:Destroy() end
 local icon=E.icon(header,o.Icon or 'star') icon.Position=UDim2.fromOffset(0,7)
 w.Theme:Bind(icon,icon:IsA('ImageLabel') and 'ImageColor3' or 'TextColor3','Secondary')
 local label=E.text(header,group.Name,13) label.Font=Enum.Font.GothamBold label.Position=UDim2.fromOffset(32,0) label.Size=UDim2.new(1,-60,1,0) w.Theme:Bind(label,'TextColor3','Text')
 local arrow=E.text(header,'⌄',18) arrow.Position=UDim2.new(1,-22,0,0) arrow.Size=UDim2.new(0,22,1,0) w.Theme:Bind(arrow,'TextColor3','MutedText')
 local body=E.new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},root) local bodyLayout=E.list(body,0) E.fit(body,bodyLayout,group.Cleanup,0)
 group.Page=body
 if o.Description then
  local description=E.text(body,o.Description,12) description.AutomaticSize=Enum.AutomaticSize.Y description.Size=UDim2.new(1,0,0,0) w.Theme:Bind(description,'TextColor3','MutedText')
 end
 function group:SetCollapsed(value)
  if self.Dead then return end self.Collapsed=value==true
  body.Visible=not self.Collapsed arrow.Text=self.Collapsed and '›' or '⌄'
  if self.Collapsed then for _,control in ipairs(self.Members) do if control.Popup then control:Close() end end end
 end
 function group:SetValue(value) self.Name=tostring(value) label.Text=self.Name end
 function group:Update(values)
  if values.Name then self:SetValue(values.Name) end
  if values.Collapsed~=nil then self:SetCollapsed(values.Collapsed) end
 end
 function group:Filter(query)
  local titleMatch=self.Name:lower():find(query,1,true)~=nil
  local any=false
  for _,control in ipairs(self.Members) do
   local match=query=='' or titleMatch or control.Name:lower():find(query,1,true)~=nil
   control.Instance.Visible=match if match then any=true end
  end
  root.Visible=query=='' or titleMatch or any
  body.Visible=not self.Collapsed or query~=''
  arrow.Text=body.Visible and '⌄' or '›'
 end
 function group:Destroy()
  if self.Dead then return end self.Dead=true self.Cleanup:Destroy()
  local index=table.find(tab.Groups,self) if index then table.remove(tab.Groups,index) end
 end
 for _,kind in ipairs({'Button','Toggle','Slider','Dropdown','Textbox','Keybind','ColorPicker','Paragraph','Label','Divider','Section','Badge','ProgressBar'}) do
  group['Create'..kind]=function(_,props) assert(not group.Dead,'Grupo destruído.') return Factory.create(group,kind,props) end
 end
 group.Cleanup:Add(function() w.Theme:Forget(root) root:Destroy() end)
 group.Cleanup:Add(header.Activated:Connect(function() group:SetCollapsed(not group.Collapsed) end))
 group:SetCollapsed(group.Collapsed)
 table.insert(tab.Groups,group)
 return group
end
return Group
