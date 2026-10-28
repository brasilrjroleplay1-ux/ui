local Http = game:GetService('HttpService')
local Storage = {}
local function copy(value)
 if type(value)~='table' then return value end
 local result={} for k,v in pairs(value) do result[k]=copy(v) end return result
end
local function validName(value)
 return type(value)=='string' and #value>0 and #value<=48 and value:match('^[%w _%-]+$')~=nil
end
function Storage.new(options)
 options = options or {}
 local self = {Values={}, Enabled=options.Enabled ~= false, Available=false, LastError=nil, Revision=0, Dead=false}
 self.Active='Default' self.AutoLoad=true self.Profiles={Default=self.Values} self.Deleted={} self.SessionOnly=false
 local env = getfenv()
 local read,write,exists,mkdir,isfolder = env.readfile,env.writefile,env.isfile,env.makefolder,env.isfolder
 local adapter = options.Adapter
 local folder = options.Folder or 'ConexaoUI'
 local name = options.Name or 'default'
 assert(folder:match('^[%w_-]+$') and name:match('^[%w_-]+$'),'Use apenas letras, números, _ e - em Folder/Name')
 local path = folder..'/'..name..'.json'
 if adapter then
  self.Read = function() return adapter:Read(name) end
  self.Write = function(data) adapter:Write(name,data) end
  self.Available = true
 elseif type(read)=='function' and type(write)=='function' and type(exists)=='function' and type(mkdir)=='function' then
  self.Read = function() if exists(path) then return read(path) end return nil end
  self.Write = function(data)
   if type(isfolder)=='function' then if not isfolder(folder) then mkdir(folder) end
   else
    -- Some implementations raise when the directory already exists. The write
    -- below remains authoritative and propagates permission errors.
    pcall(mkdir,folder)
   end
   write(path,data)
  end
  self.Available = true
 end
 function self:Report(err)
  self.LastError=tostring(err) warn('[Conexão UI / storage] '..self.LastError)
  if options.OnError then pcall(options.OnError,self.LastError) end
 end
 if self.Enabled and self.Available then
  local ok,result=pcall(self.Read)
  if ok and result then
   local decoded,data=pcall(function() return Http:JSONDecode(result) end)
   if decoded and type(data)=='table' and data.Version==1 and type(data.Values)=='table' then
    if type(data.Profiles)=='table' then
     local profiles={}
     for key,values in pairs(data.Profiles) do if validName(key) and type(values)=='table' then profiles[key]=values end end
     profiles.Default=profiles.Default or {}
     self.Profiles=profiles
     if type(data.Active)=='string' and profiles[data.Active] then self.Active=data.Active end
     if type(data.Deleted)=='table' then
      for key,values in pairs(data.Deleted) do if validName(key) and type(values)=='table' and not profiles[key] then self.Deleted[key]=values end end
     end
     self.AutoLoad=data.AutoLoad~=false
     self.SessionOnly=not self.AutoLoad
     self.Values=self.AutoLoad and profiles[self.Active] or {}
    else self.Values=data.Values self.Profiles={Default=self.Values} end
   else self:Report('Configuração inválida; valores padrão serão usados.') end
  elseif not ok then self:Report(result) end
 end
 function self:Set(id,value)
  self.Values[id]=value self.Revision+=1
  local revision=self.Revision
  task.delay(.3,function() if not self.Dead and revision==self.Revision then self:Flush() end end)
 end
 function self:Flush(force)
  if (not self.Enabled and not force) or not self.Available then return false end
  local ok,err=pcall(function() self.Write(Http:JSONEncode({Version=1,Values=self.Profiles[self.Active],Profiles=self.Profiles,Active=self.Active,Deleted=self.Deleted,AutoLoad=self.AutoLoad})) end)
  if not ok then self:Report(err) end return ok
 end
 function self:SaveProfile()
  self.SessionOnly=false self.Profiles[self.Active]=self.Values
  return self:Flush(true)
 end
 function self:ListProfiles(deleted)
  local result={} for key in pairs(deleted and self.Deleted or self.Profiles) do table.insert(result,key) end table.sort(result) return result
 end
 function self:CreateProfile(profileName)
  if profileName==nil or profileName=='' then
   local number=1 repeat profileName='Perfil '..number number+=1 until not self.Profiles[profileName] and not self.Deleted[profileName]
  end
  assert(validName(profileName),'Nome inválido: use até 48 letras, números, espaços, _ ou -.')
  assert(not self.Profiles[profileName] and not self.Deleted[profileName],'Este nome já existe ou está na lixeira.')
  assert(#self:ListProfiles()<50,'Limite de 50 perfis.')
  self.Profiles[profileName]=copy(self.Values) return profileName
 end
 function self:ActivateProfile(profileName)
  assert(self.Profiles[profileName],'Perfil não encontrado.')
  self.Active=profileName self.Values=self.Profiles[profileName] self.SessionOnly=false
 end
 function self:DeleteProfile(profileName)
  assert(profileName~='Default' and profileName~=self.Active,'O perfil padrão e o ativo não podem ser excluídos.')
  assert(self.Profiles[profileName],'Perfil não encontrado.')
  assert(#self:ListProfiles(true)<50,'Lixeira cheia: restaure um perfil antes de excluir outro.')
  self.Deleted[profileName]=self.Profiles[profileName] self.Profiles[profileName]=nil
 end
 function self:RestoreProfile(profileName)
  assert(self.Deleted[profileName] and not self.Profiles[profileName],'Perfil não disponível para restauração.')
  assert(#self:ListProfiles()<50,'Limite de 50 perfis.')
  self.Profiles[profileName]=self.Deleted[profileName] self.Deleted[profileName]=nil
 end
 function self:ExportProfile(profileName)
  local values=profileName and self.Profiles[profileName] or self.Values
  assert(values,'Perfil não encontrado.')
  return Http:JSONEncode({Version=1,Values=values})
 end
 function self:ImportProfile(text,profileName)
  assert(type(text)=='string' and #text<=262144,'Importação limitada a 256 KiB de JSON.')
  local data=Http:JSONDecode(text)
  assert(type(data)=='table' and data.Version==1 and type(data.Values)=='table','JSON de configuração inválido.')
  local created=self:CreateProfile(profileName)
  self.Profiles[created]=copy(data.Values) return created
 end
 function self:Destroy() self:Flush() self.Dead=true end
 return self
end
return Storage
