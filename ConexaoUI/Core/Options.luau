-- Public properties accept Name/name, Callback/callback, etc.; explicit capitalized keys win.
local Options = {}
function Options.normalize(value)
 if value==nil then return {} end
 if type(value)=='string' then return {Name=value} end
 assert(type(value)=='table','As opções devem ser uma tabela ou um nome.')
 local result=table.clone(value)
 for key,item in pairs(value) do
  if type(key)=='string' then
   local canonical=key:sub(1,1):upper()..key:sub(2)
   if result[canonical]==nil then result[canonical]=item end
  end
 end
 return result
end
return Options
