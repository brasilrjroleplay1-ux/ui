local E = {}
function E.new(class, props, parent)
 local o = Instance.new(class)
 for k,v in pairs(props or {}) do o[k] = v end
 o.Parent = parent
 return o
end
function E.corner(o, radius) return E.new('UICorner', {CornerRadius = UDim.new(0,radius or 12)}, o) end
function E.pad(o, n) return E.new('UIPadding',{PaddingTop=UDim.new(0,n),PaddingBottom=UDim.new(0,n),PaddingLeft=UDim.new(0,n),PaddingRight=UDim.new(0,n)},o) end
function E.list(o, gap)
 return E.new('UIListLayout',{Padding=UDim.new(0,gap or 10),SortOrder=Enum.SortOrder.LayoutOrder},o)
end
function E.text(parent, text, size)
 return E.new('TextLabel',{BackgroundTransparency=1,Text=text or '',TextSize=size or 14,Font=Enum.Font.GothamMedium,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Size=UDim2.new(1,0,0,24)},parent)
end
function E.button(parent, text)
 local b = E.new('TextButton',{Text=text or '',Font=Enum.Font.GothamMedium,TextSize=14,TextColor3=Color3.new(1,1,1),AutoButtonColor=false,TextTruncate=Enum.TextTruncate.AtEnd,BorderSizePixel=0,Size=UDim2.new(1,0,0,44)},parent)
 E.corner(b)
 return b
end
function E.scroll(parent)
 local f=E.new('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Size=UDim2.fromScale(1,1),ScrollingDirection=Enum.ScrollingDirection.Y},parent)
 E.pad(f,12) E.list(f,10)
 return f
end
local icons = {house='⌂',home='⌂',settings='⚙',user='○',star='✦',search='⌕',palette='◈',info='i',bolt='ϟ'}
function E.icon(parent, value)
 if type(value)=='number' or (type(value)=='string' and (value:match('^rbxassetid://') or value:match('^%d+$'))) then
  return E.new('ImageLabel',{BackgroundTransparency=1,Image=tostring(value):match('^rbxassetid://') and value or 'rbxassetid://'..tostring(value),Size=UDim2.fromOffset(22,22)},parent)
 end
 local t=E.text(parent,icons[value] or value or '◈',22) t.Size=UDim2.fromOffset(24,24) t.TextXAlignment=Enum.TextXAlignment.Center return t
end
return E
