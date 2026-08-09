  21:53:30.991  SOURCE|local module = {}
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
		
		createinstance = function(args)
			local class = RobloxBridge.unbox(args[1])
			local parent = RobloxBridge.unbox(args[2])
			if not parent then
				parent = workspace
			end
			
			if class then
				local inst = Instance.new(class, parent)
				return Values.mkRoblox(inst)
			else
				error("createinstance requires a class and parent")
			end
		end,
	})
end

return module
  -  Edit
  21:53:30.991