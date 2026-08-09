  20:44:12.752  SOURCE|local module = {}
local Values = require(script.Parent.Parent.Parent.Runtime.Values)
local RobloxBridge = require(script.Parent.Parent.Parent.Runtime.RobloxBridge)

function module.import(env, special)
	if not special then
		special = "roblox"
	end

	local main = require(script.Parent.Parent.Parent.main)

	env:DeclareVar("game", Values.mkRoblox(game), true)
	env:DeclareVar("workspace", Values.mkRoblox(workspace), true)

	main.registerLibrary(env, special, {
		getdir = function(args)
			if not args[1] then
				error("roblox.getdir() expects a path string or instance")
			end
			return RobloxBridge.ResolvePath(args[1])
		end,

		find = function(args)
			return RobloxBridge.ResolvePath(args[1])
		end,
	})
end

return module
  -  Edit
  20:44:12.752