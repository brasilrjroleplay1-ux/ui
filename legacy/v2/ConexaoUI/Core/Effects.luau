-- One render subscription per window owns the border lights and button glints.
local E=require(script.Parent.Elements)
local Cleanup=require(script.Parent.Cleanup)
local Effects={}
Effects.__index=Effects
local function point(distance,width,height,radius)
 local horizontal=width-2*radius local vertical=height-2*radius local arc=math.pi*radius/2
 local total=2*horizontal+2*vertical+4*arc
 local d=distance%total
 for side=0,3 do
  local length=side%2==0 and horizontal or vertical
  if d<=length then
   if side==0 then return radius+d,0,0
   elseif side==1 then return width,radius+d,90
   elseif side==2 then return width-radius-d,height,180
   else return 0,height-radius-d,270 end
  end
  d-=length
  if d<=arc then
   local angle=(side-1)*math.pi/2+d/radius
   local cx=side<2 and width-radius or radius
   local cy=(side==0 or side==3) and radius or height-radius
   return cx+math.cos(angle)*radius,cy+math.sin(angle)*radius,math.deg(angle)+90
  end
  d-=arc
 end
 return radius,0,0
end
function Effects.new(w,enabled)
 local self=setmetatable({Window=w,Enabled=enabled~=false,Time=0,Buttons={},Trails={},Cleanup=Cleanup.new(),Dead=false},Effects)
 local root=w.Root
 self.Halo=E.new('Frame',{Name='WindowHalo',BackgroundTransparency=.96,BorderSizePixel=0,AnchorPoint=root.AnchorPoint,ZIndex=1,Active=false},w.Gui)
 self.HaloCorner=E.corner(self.Halo,w.Theme.Values.CornerRadius+7)
 local haloStroke=E.new('UIStroke',{Thickness=7,Transparency=.92},self.Halo)
 w.Theme:Bind(self.Halo,'BackgroundColor3','Primary') w.Theme:Bind(haloStroke,'Color','Primary')
 self.Layer=E.new('Frame',{Name='LightPerimeter',BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(2,2),Size=UDim2.new(1,-4,1,-4),ZIndex=25,Active=false},root)
 self.Corner=E.corner(self.Layer,w.Theme.Values.CornerRadius-2)
 self.Edge=E.new('UIStroke',{Thickness=1.2,Transparency=.2,Color=Color3.new(1,1,1)},self.Layer)
 self.Gradient=E.new('UIGradient',{Rotation=0},self.Edge)
 for lane=1,2 do
  local trail={}
  for segment=1,12 do
   local node=E.new('Frame',{Name='BorderLight',AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(segment==1 and 11 or 8,segment==1 and 3 or 2),BorderSizePixel=0,BackgroundTransparency=.08+(segment-1)/12*.86,ZIndex=26,Active=false},self.Layer)
   E.corner(node,3).Name='LightMask' trail[segment]=node
  end
  self.Trails[lane]=trail
 end
 function self:Sync()
  if self.Dead then return end
  local active=self.Enabled and root.Visible~=false and not w.Minimized
  self.Layer.Visible=active self.Halo.Visible=active
  self.Halo.Position=root.Position
  local s=root.Size self.Halo.Size=UDim2.new(s.X.Scale,s.X.Offset+14,s.Y.Scale,s.Y.Offset+14)
  self.Corner.CornerRadius=UDim.new(0,math.max(2,w.Theme.Values.CornerRadius-2))
  self.HaloCorner.CornerRadius=UDim.new(0,math.max(2,w.Theme.Values.CornerRadius+7))
  self.Gradient.Color=ColorSequence.new(w.Theme.Values.Primary,w.Theme.Values.Secondary)
  for lane,trail in ipairs(self.Trails) do for _,sprite in ipairs(trail) do sprite.BackgroundColor3=lane==1 and w.Theme.Values.Secondary or w.Theme.Values.Highlight end end
  if not active then for _,entry in pairs(self.Buttons) do entry.Light.Visible=false end end
 end
 function self:SetEnabled(value) self.Enabled=value==true self:Sync() end
 function self:Step(dt)
  if self.Dead or not self.Enabled or root.Visible==false or w.Minimized then return end
  self.Time+=math.clamp(tonumber(dt) or 0,0,.1)
  self.Gradient.Rotation=(self.Time*28)%360
  local size=root.AbsoluteSize local width=math.max(8,size.X-4) local height=math.max(8,size.Y-4)
  local radius=math.max(1,math.min(w.Theme.Values.CornerRadius-2,width/2-1,height/2-1))
  local perimeter=2*(width+height-4*radius)+2*math.pi*radius
  for lane,trail in ipairs(self.Trails) do
   for index,sprite in ipairs(trail) do
    local x,y,rotation=point(self.Time*320+(lane-1)*perimeter/2-(index-1)*5,width,height,radius)
    sprite.Position=UDim2.fromOffset(x,y) sprite.Rotation=rotation
   end
  end
  for button,entry in pairs(self.Buttons) do
   local visible=button.Visible~=false and (not entry.When or entry.When()) local ancestor=button.Parent
   while visible and ancestor and ancestor~=w.Gui do if ancestor.Visible==false then visible=false end ancestor=ancestor.Parent end
   local sweep=(self.Time+entry.Offset)%4
   entry.Light.Visible=visible and sweep<.9
   if entry.Light.Visible then entry.Light.Position=UDim2.fromOffset(-32+(button.AbsoluteSize.X+64)*sweep/.9,0) end
  end
 end
 function self:RegisterButton(button,cleanup,when)
  button.ClipsDescendants=true
  local light=E.new('Frame',{Name='ButtonLight',Position=UDim2.fromOffset(-32,0),Size=UDim2.new(0,32,1,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.65,BorderSizePixel=0,Visible=false,Active=false},button)
  E.new('UIGradient',{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,.6),NumberSequenceKeypoint.new(1,1)})},light)
  local entry={Light=light,Offset=0,When=when} self.Buttons[button]=entry
  cleanup:Add(function() self.Buttons[button]=nil light:Destroy() end)
 end
 self.Cleanup:Add(game:GetService('RunService').RenderStepped:Connect(function(dt) self:Step(dt) end))
 for _,property in ipairs({'Size','Position','Visible'}) do self.Cleanup:Add(root:GetPropertyChangedSignal(property):Connect(function() self:Sync() end)) end
 self.Cleanup:Add(function() w.Theme:Forget(self.Halo) self.Halo:Destroy() w.Theme:Forget(self.Layer) self.Layer:Destroy() end)
 self:Sync() self:Step(0)
 return self
end
function Effects:Destroy()
 if self.Dead then return end self.Dead=true self.Cleanup:Destroy() table.clear(self.Buttons)
end
return Effects
