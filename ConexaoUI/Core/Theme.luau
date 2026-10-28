local Theme = {}
Theme.Default = {
 Background = Color3.fromRGB(17,19,23), Surface = Color3.fromRGB(26,29,34),
 SurfaceHover = Color3.fromRGB(38,41,47), Primary = Color3.fromRGB(228,195,123), PrimaryText = Color3.fromRGB(28,27,31),
 Secondary = Color3.fromRGB(179,165,228), Text = Color3.fromRGB(238,241,246),
 MutedText = Color3.fromRGB(154,161,174), Border = Color3.fromRGB(85,91,103),
 Success = Color3.fromRGB(105,221,160), Warning = Color3.fromRGB(245,199,100),
 Error = Color3.fromRGB(242,113,131), CornerRadius = 14,
}
local function primaryText(color) return (color.R*.299+color.G*.587+color.B*.114)>.6 and Color3.fromRGB(28,27,31) or Color3.new(1,1,1) end
function Theme.new(overrides)
 local self = {Values = table.clone(Theme.Default), Bindings = {}}
 if type(overrides) == 'table' then for k,v in pairs(overrides) do self.Values[k] = v end end
 if type(overrides)~='table' or overrides.PrimaryText==nil then self.Values.PrimaryText=primaryText(self.Values.Primary) end
 function self:Bind(instance, property, key)
  instance[property] = self.Values[key]
  self.Bindings[instance] = self.Bindings[instance] or {}
  self.Bindings[instance][property] = key
 end
 function self:Apply(values)
  if values.Primary and values.PrimaryText==nil then self.Values.PrimaryText=primaryText(values.Primary) end
  for k,v in pairs(values) do if self.Values[k] ~= nil then self.Values[k] = v end end
  for instance, props in pairs(self.Bindings) do
   if instance.Parent == nil then self.Bindings[instance] = nil else
    for property,key in pairs(props) do instance[property] = self.Values[key] end
   end
  end
 end
 function self:Forget(root)
  for instance in pairs(self.Bindings) do if instance == root or instance:IsDescendantOf(root) then self.Bindings[instance] = nil end end
 end
 return self
end
return Theme
