local Object = {}
Object.__index = Object


-- called hiddenly when object instantinates, ex. local var = Object()
function Object:new()
end


function Object:extend()
	local cls = {}
	for k, v in pairs(self) do
		if k:find("__") == 1 then
			cls[k] = v
		end
	end
	cls.__index = cls
	cls.super = self
	setmetatable(cls, self)
	return cls
end

function Object:is(T)
	local mt = getmetatable(self)
	while mt do
		if mt == T then
			return true
		end
		mt = getmetatable(mt)
	end
	return false
end --Object:is


--function Object:implement(...)
  --for _, cls in pairs({...}) do
    --for k, v in pairs(cls) do
      --if self[k] == nil and type(v) == "function" then
        --self[k] = v
      --end
    --end
  --end
--end

--function Object:__tostring()
	--return "Object"
--end

function Object.get_obj( arg_mod )
	local obj
	obj = require(arg_mod)
	return obj()
end --common.get_obj

function Object:__call(...) -- when table called directly, ex. Object()
	local obj = setmetatable({}, self)
	obj:new(...)
	return obj
end


return Object
