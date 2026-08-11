  15:36:08.049  SOURCE|local module = {}

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
		get_dir = function(args, env)
			if not args[1] then
				error("roblox.get_dir() expects a path string or instance")
			end
			return RobloxBridge.ResolvePath(args[1], false, env)
		end,

		find = function(args, env)
			return RobloxBridge.ResolvePath(args[1], true, env)
		end,
		
		create_instance = function(args)
			local class = RobloxBridge.unbox(args[1])
			local parent = RobloxBridge.unbox(args[2])
			if not parent then
				parent = workspace
			end
			
			if class then
				local inst = Instance.new(class, parent)
				return Values.mkRoblox(inst)
			else
				error("create_instance requires a class and parent")
			end
		end,

		require = function(args, env)
			if not args[1] then
				error("roblox.require() expects a ModuleScript instance or path")
			end
			local raw
			if type(args[1]) == "table" and args[1][2] == "roblox" then
				raw = args[1][1]
			else
				local resolved = RobloxBridge.ResolvePath(args[1][1], true, env)
				raw = resolved[1]
			end
			if not (typeof(raw) == "Instance" and raw:IsA("ModuleScript")) then
				error("roblox.require() expects a ModuleScript, got " .. (typeof(raw) == "Instance" and raw.ClassName or typeof(raw)))
			end
			local name = raw.Name
			local required = require(raw)
			if typeof(required) ~= "table" then
				error("roblox.require(): module '" .. raw:GetFullName() .. "' does not return a table")
			end
			local members = {}
			for fnName, fn in pairs(required) do
				if type(fn) == "function" then
					members[fnName] = Values.mkNativeFunction(fnName, function(callArgs, callEnv)
						local rawArgs = {}
						for i, a in ipairs(callArgs) do
							rawArgs[i] = RobloxBridge.unbox(a, callEnv)
						end
						local ok, result = pcall(function()
							return fn(unpack(rawArgs))
						end)
						if not ok then
							error("roblox.require: '" .. name .. "." .. tostring(fnName) .. "' failed: " .. tostring(result))
						end
						return RobloxBridge.box(result)
					end)
				end
			end
			return Values.mkDict(members)
		end,

		Vector3 = function(args)
			local params = {}
			for _, a in ipairs(args) do
				local u = RobloxBridge.unbox(a)
				if type(u) == "table" then
					for _, v in ipairs(u) do
						table.insert(params, v)
					end
				else
					table.insert(params, u)
				end
			end
			if #params == 1 and typeof(params[1]) == "Vector3" then
				return Values.mkRoblox(params[1])
			elseif #params == 3 then
				if type(params[1]) == "number" and type(params[2]) == "number" and type(params[3]) == "number" then
					return Values.mkRoblox(Vector3.new(params[1], params[2], params[3]))
				end
				error("roblox.Vector3 expects (x, y, z) numbers")
			end
			error("roblox.Vector3 expects (x, y, z) numbers or a single vector")
		end,

		CFrame = function(args)
			local params = {}
			for _, a in ipairs(args) do
				local u = RobloxBridge.unbox(a)
				if type(u) == "table" then
					for _, v in ipairs(u) do
						table.insert(params, v)
					end
				else
					table.insert(params, u)
				end
			end
			if #params == 0 then
				return Values.mkRoblox(CFrame.new())
			elseif #params == 1 and typeof(params[1]) == "Vector3" then
				return Values.mkRoblox(CFrame.new(params[1]))
			elseif #params == 2 and typeof(params[1]) == "Vector3" and typeof(params[2]) == "Vector3" then
				return Values.mkRoblox(CFrame.new(params[1], params[2]))
			elseif #params == 3 then
				if type(params[1]) == "number" and type(params[2]) ==  -  Edit
  15:36:08.049  SOURCE| "number" and type(params[3]) == "number" then
					return Values.mkRoblox(CFrame.new(params[1], params[2], params[3]))
				end
				error("roblox.CFrame with 3 arguments expects x, y, z numbers")
			elseif #params <= 7 then
				local x, y, z = params[1], params[2], params[3]
				local qx, qy, qz, qw = params[4] or 0, params[5] or 0, params[6] or 0, params[7] or 1
				if type(x) == "number" and type(y) == "number" and type(z) == "number"
					and type(qx) == "number" and type(qy) == "number" and type(qz) == "number" and type(qw) == "number" then
					return Values.mkRoblox(CFrame.new(x, y, z, qx, qy, qz, qw))
				end
				error("roblox.CFrame quaternion form expects numbers")
			end
			error("roblox.CFrame: too many arguments")
		end,
	})
end

return module
  -  Edit
  15:36:08.049