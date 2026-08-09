  21:53:30.991  SOURCE|local module = {}
local Values = require(script.Parent.Values)
local Environment = require(script.Parent.Environment)

local NON_LANG_TAG = {
	number = true,
	boolean = true,
	string = true,
	null = true,
	roblox = true,
}

local function box(v)
	if v == nil then
		return Values.mkNull()
	end
	local t = typeof(v)
	if t == "number" then
		return Values.mkNumber(v)
	elseif t == "boolean" then
		return Values.mkBool(v)
	elseif t == "string" then
		return Values.mkString(v)
	elseif t == "Instance" or t == "EnumItem" then
		return Values.mkRoblox(v)
	elseif t == "table" then
		local tagged = type(v[2]) == "string" and NON_LANG_TAG[v[2]]
		if tagged then
			return v
		end
		local rawItems = {}
		local dict = true
		local count = 0
		for k, item in pairs(v) do
			count += 1
			if type(k) == "number" and k >= 1 then
				rawItems[k] = box(item)
				dict = false
			end
		end
		if count == 0 then
			return Values.mkTable({})
		end
		if dict then
			local d = {}
			for k, item in pairs(v) do
				d[k] = box(item)
			end
			return Values.mkDict(d)
		end
		return Values.mkTable(rawItems)
	end
	return Values.mkRoblox(v)
end

local function wrapCallback(fnVal, env)
	if fnVal == nil then
		return nil
	end
	if fnVal[2] == "native_function" then
		return function(...)
			local args = { ... }
			for i, a in ipairs(args) do
				args[i] = box(a)
			end
			return fnVal.caller(args)
		end
	end
	return function(...)
		local Interpreter = require(script.Parent.Interpreter)
		local funcEnv = Environment.new(env)
		local args = { ... }
		local langArgs = {}
		for i, a in ipairs(args) do
			langArgs[i] = box(a)
		end
		local params = fnVal.params or {}
		for i, param in ipairs(params) do
			funcEnv:DeclareVar(param, langArgs[i] or Values.mkNull(), false)
		end
		local result = Values.mkNull()
		for _, stmt in ipairs(fnVal.body) do
			local r = Interpreter.evaluate(stmt, funcEnv)
			if type(r) == "table" and r.__isReturn then
				result = r.retval
				break
			end
		end
		return result
	end
end

local Box = box
local WrapCallback = wrapCallback

local BRIDGE_METHODS = {}

function BRIDGE_METHODS.GetAncestors(raw)
	local out = {}
	local cur = raw.Parent
	while cur do
		table.insert(out, cur)
		cur = cur.Parent
	end
	return out
end

function BRIDGE_METHODS.GetChildrenWithClass(raw, className)
	local out = {}
	for _, c in ipairs(raw:GetChildren()) do
		if c:IsA(className) then
			table.insert(out, c)
		end
	end
	return out
end

function module.unbox(v, env)
	if type(v) ~= "table" then
		return v
	end
	local kind = v[2]
	if kind == "number" or kind == "boolean" or kind == "string" then
		return v[1]
	elseif kind == "null" then
		return nil
	elseif kind == "roblox" then
		return v[1]
	elseif kind == "table" then
		local out = {}
		for i, item in ipairs(v[1]) do
			out[i] = module.unbox(item, env)
		end
		return out
	elseif kind == "dictionary" then
		local out = {}
		for k, item in pairs(v[1]) do
			out[k] = module.unbox(item, env)
		end
		return out
	elseif kind == "function" or kind == "native_function" then
		return WrapCallback(v, env)
	elseif kind == "tuple" then
		local out = {}
		for i, item in ipairs(v[1]) do
			out[i] = module.unbox(item, env)
		end
		return out
	end
	return v[1]
end

function module.getMember(rbxVal, property)
	local raw = rbxVal[1]
	property = tostring(property)
	if typeof(raw) == "Instance" then
		local child = raw:FindFirstChild(property)
		if child then
			return Values.mkRoblox(child)
		end
		local ok, v = pcall(function()
			return raw[property]
		end)
		if ok then
			return Box(v)
		end
		error("Roblox instance '" .. raw:GetFullName() .. "' has no child or property '" .. property .. "'")
	end
	local ok, v = pcall(function()
		return raw[property]
	end)
	if not ok then
		error("Cannot read member '" .. property .. "' on Roblox value " .. typeof(raw))
	end
	re  -  Edit
  21:53:30.992  SOURCE|turn Box(v)
end

function module.SetMember(rbxVal, property, langVal, env)
	local raw = rbxVal[1]
	if typeof(raw) ~= "Instance" then
		error("Cannot set member '" .. tostring(property) .. "' on a non-instance Roblox value")
	end
	property = tostring(property)
	local rawVal = module.unbox(langVal, env)
	-- Tuples are positional component lists: convert them to the datatype the
	-- property currently holds (Vector3, Color3, UDim2, CFrame, etc.).
	if langVal and langVal[2] == "tuple" and type(rawVal) == "table" then
		local currentOk, current = pcall(function()
			return raw[property]
		end)
		local t = currentOk and typeof(current) or "nil"
		if t == "Vector3" then
			rawVal = Vector3.new(rawVal[1], rawVal[2], rawVal[3])
		elseif t == "Vector3int16" then
			rawVal = Vector3int16.new(rawVal[1], rawVal[2], rawVal[3])
		elseif t == "Color3" then
			if (rawVal[1] or 0) > 1 or (rawVal[2] or 0) > 1 or (rawVal[3] or 0) > 1 then
				rawVal = Color3.fromRGB(rawVal[1], rawVal[2], rawVal[3])
			else
				rawVal = Color3.new(rawVal[1], rawVal[2], rawVal[3])
			end
		elseif t == "UDim2" then
			rawVal = UDim2.new(UDim.new(rawVal[1], rawVal[2]), UDim.new(rawVal[3], rawVal[4]))
		elseif t == "UDim" then
			rawVal = UDim.new(rawVal[1], rawVal[2])
		elseif t == "CFrame" then
			rawVal = CFrame.new(table.unpack(rawVal))
		elseif t == "PhysicalProperties" then
			rawVal = PhysicalProperties.new(table.unpack(rawVal))
		end
	end
	raw[property] = rawVal
	return langVal
end

function module.FindChild(rbxVal, name)
	local raw = rbxVal[1]
	if typeof(raw) ~= "Instance" then
		error("Cannot index a non-instance Roblox value")
	end
	local child = raw:FindFirstChild(tostring(name))
	if child then
		return Values.mkRoblox(child)
	end
	return Values.mkNull()
end

function module.InvokeMethod(rbxVal, method, args, env)
	local raw = rbxVal[1]
	local okGet, fn = pcall(function()
		return raw[tostring(method)]
	end)
	if not okGet then
		error("Roblox value " .. typeof(raw) .. " has no member '" .. tostring(method) .. "'")
	end
	if type(fn) ~= "function" then
		local m = tostring(method)
		local isEvent = false
		if typeof(raw) == "RBXScriptSignal" then
			isEvent = true
		elseif typeof(raw) == "Instance" and m:match("^On") ~= nil then
			isEvent = true
		end
		if not isEvent then
			error("'" .. m .. "' is not a method on " .. typeof(raw))
		end
		local okProp, ev = pcall(function()
			return raw[m]
		end)
		if okProp then
			return Box(ev)
		end
		error("'" .. m .. "' is not available on " .. typeof(raw))
	end
	local callArgs = {}
	for i, a in ipairs(args) do
		callArgs[i] = module.unbox(a, env)
	end
	local ok, result = pcall(fn, raw, unpack(callArgs))
	if not ok then
		error("Roblox method '" .. tostring(method) .. "' failed: " .. tostring(result))
	end
	return Box(result)
end

function module.ResolvePath(path)
	if type(path) == "table" then
		if path[2] == "roblox" then
			return path
		end
		path = path[1]
	end
	if typeof(path) == "Instance" then
		return Values.mkRoblox(path)
	end
	path = tostring(path):gsub("^%s+", ""):gsub("%s+$", "")
	if path == "" then
		return Values.mkRoblox(game)
	end
	local current = game
	for seg in path:gmatch("[^%.]+") do
		local segLower = seg:lower()
		if segLower == "game" or segLower == "datamodel" then
			continue
		end
		local child = current:FindFirstChild(seg)
		if not child then
			for _, c in ipairs(current:GetChildren()) do
				if c.Name:lower() == segLower then
					child = c
					break
				end
			end
		end
		if not child then
			error("getdir: Cannot resolve '" .. seg .. "' in " .. current:GetFullName())
		end
		current = child
	end
	return Values.mkRoblox(current)
end

return module  -  Edit
  21:53:30.992