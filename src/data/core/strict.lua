local strict = {}
strict.defined = {}


-- used to define a global variable

--original code
--function global(t)
  --for k, v in pairs(t) do
    --strict.defined[k] = true
    --rawset(_G, k, v)
  --end
--end

function global(arg_1, arg_2)
	arg_2 = arg_2 or nil
	if type(arg_1) == "table" then
		for k, v in pairs(arg_pairs) do
			strict.defined[k] = true
			rawset(_G, k, v)
		end
	elseif type(arg_1) == "string" then
		strict.defined[arg_1] = true
		rawset(_G, arg_1, arg_2)
	end
end


function strict.__newindex(t, k, v)
  error("cannot set undefined variable: " .. k, 2)
end


function strict.__index(t, k)
  if not strict.defined[k] then
    error("cannot get undefined variable: " .. k, 2)
  end
end


setmetatable(_G, strict)
