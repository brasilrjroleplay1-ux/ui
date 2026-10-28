local Icons=require(script.Parent.Icons)
local Theme = {}
Theme.Default = {
 Background = Color3.fromRGB(13,10,28), Surface = Color3.fromRGB(29,25,56),
 SurfaceHover = Color3.fromRGB(47,36,82), Primary = Color3.fromRGB(160,80,255), PrimaryText = Color3.new(1,1,1),
 Secondary = Color3.fromRGB(197,139,255), Highlight = Color3.fromRGB(89,196,245), Text = Color3.fromRGB(251,247,255),
 MutedText = Color3.fromRGB(179,170,207), Border = Color3.fromRGB(130,96,180),
 Success = Color3.fromRGB(105,221,160), Warning = Color3.fromRGB(245,199,100),
 Error = Color3.fromRGB(255,118,151), CornerRadius = 20,
}
local function primaryText(color) return (color.R*.299+color.G*.587+color.B*.114)>.6 and Color3.fromRGB(28,27,31) or Color3.new(1,1,1) end
function Theme.new(overrides)
 local self = {Values = table.clone(Theme.Default), Bindings = {}}
 if type(overrides) == 'table' then for k,v in pairs(overrides) do self.Values[k] = v end end
 if type(overrides)~='table' or overrides.PrimaryText==nil then self.Values.PrimaryText=primaryText(self.Values.Primary) end
 function self:Bind(instance, property, key)
  instance[property] = self.Values[key]
  Icons.paint(instance,property,self.Values[key])
  self.Bindings[instance] = self.Bindings[instance] or {}
  self.Bindings[instance][property] = key
 end
 function self:Apply(values)
  if values.Primary and values.PrimaryText==nil then self.Values.PrimaryText=primaryText(values.Primary) end
  for k,v in pairs(values) do if self.Values[k] ~= nil then self.Values[k] = v end end
  for instance, props in pairs(self.Bindings) do
   if instance.Parent == nil then self.Bindings[instance] = nil else
    for property,key in pairs(props) do instance[property] = self.Values[key] Icons.paint(instance,property,self.Values[key]) end
   end
  end
 end
 function self:Forget(root)
  for instance in pairs(self.Bindings) do if instance == root or instance:IsDescendantOf(root) then self.Bindings[instance] = nil end end
 end
 return self
end
return Theme
