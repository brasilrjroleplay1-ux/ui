local Icons=require(script.Parent.Icons)
local E = {}
local order=setmetatable({}, {__mode="k"})
function E.new(class, props, parent)
 local o = (class=='UIStroke' and parent and parent:FindFirstChildOfClass('UIStroke')) or Instance.new(class)
 if class=='UIStroke' and (not props or props.ApplyStrokeMode==nil) then o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border end
 if parent and o:IsA('GuiObject') then
  order[parent]=(order[parent] or 0)+1
  if not props or props.LayoutOrder==nil then o.LayoutOrder=order[parent] end
 end
 for k,v in pairs(props or {}) do o[k] = v end
 o.Parent = parent
 return o
end
function E.corner(o, radius)
 local corner=o:FindFirstChildOfClass('UICorner') or E.new('UICorner',{},o)
 corner.CornerRadius=UDim.new(0,radius or 12) return corner
end
-- Explicit stack heights: only leaf text uses AutomaticSize. No circular auto-height stacks.
function E.fit(parent,layout,cleanup,padding)
 parent.AutomaticSize=Enum.AutomaticSize.None
 local function update()
  if not parent.Parent then return end
  local content=layout.AbsoluteContentSize
  local height=math.ceil(content and content.Y or 0)+(padding or 0)
  local size=parent.Size
  if size.Y.Scale~=0 or size.Y.Offset~=height then parent.Size=UDim2.new(size.X.Scale,size.X.Offset,0,height) end
 end
 local connection=layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(update)
 if cleanup then cleanup:Add(connection) end
 update() return update
end
function E.pad(o, n) return E.new('UIPadding',{PaddingTop=UDim.new(0,n),PaddingBottom=UDim.new(0,n),PaddingLeft=UDim.new(0,n),PaddingRight=UDim.new(0,n)},o) end
function E.list(o, gap)
 return E.new('UIListLayout',{Padding=UDim.new(0,gap or 10),SortOrder=Enum.SortOrder.LayoutOrder},o)
end
function E.text(parent, text, size)
 return E.new('TextLabel',{BackgroundTransparency=1,Text=text or '',TextSize=size or 14,Font=Enum.Font.GothamMedium,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Size=UDim2.new(1,0,0,24)},parent)
end
function E.button(parent, text)
 local b = E.new('TextButton',{Text=text or '',Font=Enum.Font.GothamMedium,TextSize=15,TextColor3=Color3.new(1,1,1),AutoButtonColor=false,TextTruncate=Enum.TextTruncate.AtEnd,BorderSizePixel=0,Size=UDim2.new(1,0,0,44)},parent)
 E.corner(b,12)
 E.new('UIStroke',{Thickness=1,Transparency=.3,Color=Color3.fromRGB(118,139,186)},b)
 E.new('UIGradient',{Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(235,241,255)),Rotation=90},b)
 return b
end
function E.scroll(parent)
 local f=E.new('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=Color3.fromRGB(144,152,166),ScrollBarImageTransparency=.2,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.None,Size=UDim2.fromScale(1,1),ScrollingDirection=Enum.ScrollingDirection.Y},parent)
 E.pad(f,12) local layout=E.list(f,10)
 local function canvas()
  local content=layout.AbsoluteContentSize
  f.CanvasSize=UDim2.fromOffset(0,(content and content.Y or 0)+24)
 end
 layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(canvas) canvas()
 return f
end
function E.icon(parent, value)
 if type(value)=='number' or (type(value)=='string' and (value:match('^rbxassetid://') or value:match('^%d+$'))) then
  return E.new('ImageLabel',{BackgroundTransparency=1,BorderSizePixel=0,Image=tostring(value):match('^rbxassetid://') and value or 'rbxassetid://'..tostring(value),Size=UDim2.fromOffset(24,24)},parent)
 end
 local vector=Icons.create(E,parent,value or 'star') if vector then return vector end
 local t=E.text(parent,value or '',22) t.Size=UDim2.fromOffset(24,24) t.TextXAlignment=Enum.TextXAlignment.Center return t
end
function E.tint(icon,color)
 local property=icon:IsA('ImageLabel') and 'ImageColor3' or 'TextColor3'
 icon[property]=color Icons.paint(icon,property,color)
end
return E
