-- Local outline paths in a shared 24 x 24 coordinate space. No font glyphs or HTTP assets.
local Icons={}
local aliases={home='house'}
local known={house=true,settings=true,user=true,star=true,search=true,palette=true,info=true,warning=true,bolt=true,chevron=true,check=true,close=true,minus=true,arrow=true}
function Icons.create(E,parent,value)
 local name=aliases[value] or value
 if not known[name] then return nil end
 -- TextColor3 is the existing public tint channel; the holder itself has no text.
 local root=E.new('TextLabel',{Name='Icon/'..name,Text='',BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),Size=UDim2.fromOffset(24,24)},parent)
 local paths=E.new('Frame',{Name='IconPaths',BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},root)
 local function mask(node,radius)
  E.new('UICorner',{Name='IconMask',CornerRadius=UDim.new(radius or 1,0)},node)
 end
 local function line(x1,y1,x2,y2,weight)
  local dx,dy=x2-x1,y2-y1
  local node=E.new('Frame',{Name='Ink',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale((x1+x2)/48,(y1+y2)/48),Size=UDim2.new(math.sqrt(dx*dx+dy*dy)/24,0,0,weight or 1.8),Rotation=math.deg(math.atan2(dy,dx)),BorderSizePixel=0,BackgroundColor3=Color3.new(1,1,1)},paths)
  mask(node)
 end
 local function ring(x,y,size,weight)
  local node=E.new('Frame',{Name='Ring',BackgroundTransparency=1,Position=UDim2.fromScale(x/24,y/24),Size=UDim2.fromScale(size/24,size/24),BorderSizePixel=0},paths)
  mask(node)
  E.new('UIStroke',{Name='InkStroke',Thickness=weight or 1.8,Color=Color3.new(1,1,1)},node)
 end
 local function dot(x,y,size)
  local node=E.new('Frame',{Name='Ink',Position=UDim2.fromScale(x/24,y/24),Size=UDim2.fromScale(size/24,size/24),BorderSizePixel=0,BackgroundColor3=Color3.new(1,1,1)},paths)
  mask(node)
 end
 if name=='house' then
  line(3,10,12,3) line(12,3,21,10) line(5,9,5,21) line(5,21,19,21) line(19,21,19,9)
  line(10,21,10,14) line(10,14,14,14) line(14,14,14,21)
 elseif name=='settings' then
  ring(5.5,5.5,13) ring(9,9,6)
  for i=0,7 do local a=i*math.pi/4 line(12+math.cos(a)*7,12+math.sin(a)*7,12+math.cos(a)*10,12+math.sin(a)*10,2.4) end
 elseif name=='user' then
  ring(8,2.5,8) line(4,21,4,18) line(4,18,7,14) line(7,14,17,14) line(17,14,20,18) line(20,18,20,21)
 elseif name=='star' then
  line(12,2,15,9) line(15,9,22,12) line(22,12,15,15) line(15,15,12,22)
  line(12,22,9,15) line(9,15,2,12) line(2,12,9,9) line(9,9,12,2)
 elseif name=='search' then ring(3,3,13) line(15,15,21,21,2.2)
 elseif name=='palette' then
  ring(2.5,2.5,19) dot(7,7,2.5) dot(13,5.5,2.5) dot(16.5,10,2.5) dot(6,13,2.5)
 elseif name=='info' then ring(2.5,2.5,19) dot(11,6,2) line(12,11,12,18,2)
 elseif name=='warning' then line(12,3,22,21) line(22,21,2,21) line(2,21,12,3) line(12,9,12,14,2) dot(11,17,2)
 elseif name=='bolt' then
  line(13,2,5,13) line(5,13,12,13) line(12,13,10,22) line(10,22,20,10) line(20,10,13,10) line(13,10,13,2)
 elseif name=='chevron' then line(6,9,12,15) line(12,15,18,9)
 elseif name=='check' then line(4,12,9,17,2.2) line(9,17,20,6,2.2)
 elseif name=='close' then line(6,6,18,18) line(18,6,6,18)
 elseif name=='minus' then line(5,12,19,12)
 elseif name=='arrow' then line(4,12,20,12,2) line(14,6,20,12,2) line(14,18,20,12,2)
 end
 return root
end
function Icons.paint(instance,property,color)
 if property~='TextColor3' then return end
 local paths=instance:FindFirstChild('IconPaths')
 if not paths then return end
 for _,node in ipairs(paths:GetDescendants()) do
  if node.Name=='Ink' then node.BackgroundColor3=color elseif node.Name=='InkStroke' then node.Color=color end
 end
end
return Icons
