local core

local function app_run()
	SCALE = tonumber(os.getenv("LITE_SCALE")) or SCALE
	PATHSEP = package.config:sub(1, 1)
	EXEDIR = EXEFILE:match("^(.+)[/\\\\].*$")
	package.path = EXEDIR .. '/data/?.lua;' .. package.path
	package.path = EXEDIR .. '/data/?/init.lua;' .. package.path
	core = require('core')
	core.init()
	core.run()
end

local function error_handler(arg_err)
	print('Error: ' .. tostring(arg_err))
	print(debug.traceback(nil, 2))
	if core and core.on_error then
		pcall(core.on_error, arg_err)
	end
	os.exit(1)
end

xpcall(app_run, error_handler)
--EXEDIR = EXEFILE:match("^(.+)[/\\\\].*$")
--print("EXEFILE: " .. tostring(EXEFILE) )
--print("EXEDIR: " .. tostring(EXEDIR) )
