  21:53:30.987  SOURCE|local module = {}

function module.run(input)
	local Parser = require(script.Parent.parser)
	local Interpreter = require(script.Parent.Runtime.Interpreter)
	local Environment = require(script.Parent.Runtime.Environment)
	local Values = require(script.Parent.Runtime.Values)

	local parser = Parser.new()
	local env = Environment.new()


	env:DeclareVar("True", Values.mkBool(true), true)
	env:DeclareVar("False", Values.mkBool(false), true)
	env:DeclareVar("None", Values.mkNull(), true)

	local Exceptions = require(script.Parent.Runtime.Exceptions)
	Exceptions.registerBuiltins(env)

	module.registerCoreFunctions(env)

	local program = parser:ProduceAST(input)
	local result = Interpreter.evaluate(program, env)

	return result
end

local function GetDictionaryLength(dict)
	local count = 0
	for i, v in pairs(dict) do
		count += 1
	end
	
	return count
end

function module.registerCoreFunctions(env)
	local Values = require(script.Parent.Runtime.Values)
	local Exceptions = require(script.Parent.Runtime.Exceptions)

	local function raiseException(excType, message)
		error({ __pb_exception = true, value = Values.mkException(excType, message) })
	end

	if module._nativeFns then
		for name, caller in pairs(module._nativeFns) do
			env:DeclareNativeFn(name, caller)
		end
	end

	local function renderValue(arg)
		if type(arg) == "table" then
			if arg[2] == "table" then
				local parts = {}
				for i, item in ipairs(arg[1]) do
					parts[i] = renderValue(item)
				end
				return "[" .. table.concat(parts, ", ") .. "]"
			elseif arg[2] == "dictionary" then
				local parts = {}
				for k, v in pairs(arg[1]) do
					table.insert(parts, tostring(k) .. ": " .. renderValue(v))
				end
				return "{" .. table.concat(parts, ", ") .. "}"
			elseif arg[2] == "range" then
				return "range(" .. tostring(arg[1].start) .. ", " .. tostring(arg[1].stop) .. ")"
			elseif arg[2] == "exception" then
				return tostring(arg.message or "")
			elseif arg[2] == "exception_type" then
				return tostring(arg[1])
			else
				return tostring(arg[1])
			end
		else
			return tostring(arg)
		end
	end

	env:DeclareNativeFn("print", function(args)
		local values = {}
		for i, arg in ipairs(args) do
			if arg[2] ~= "string" then
				error("print() expects a string. Got "..arg[2]..", at index "..i..".")
			end
			values[i] = renderValue(arg)
		end
		print(table.concat(values, "\t"))
		return Values.mkNull()
	end)
	
	env:DeclareNativeFn("round", function(args)
		local number = args[1]
		local roundDecimals = args[2]
		if type(number) ~= "table" or number[2] ~= "number" then
			error("round() expects a number. Got " .. (number and number[2] or "nil"))
		end
		local decimals = 0
		if roundDecimals ~= nil then
			if type(roundDecimals) ~= "table" or roundDecimals[2] ~= "number" then
				error(
					"round() expects a number. Got "
						.. (roundDecimals and roundDecimals[2] or "nil")
						.. " for the number of decimals."
				)
			end
			decimals = roundDecimals[1]
		end
		local multiplier = 10 ^ decimals
		return Values.mkNumber(
			math.round(number[1] * multiplier) / multiplier
		)
	end)
	
	env:DeclareNativeFn("sum", function(args)
		local arg = args[1]
		if type(arg) == "table" and arg[2] == "table" then
			local sum = 0
			for _, item in ipairs(arg[1]) do
				if type(item) == "table" and item[2] == "number" then
					sum = sum + item[1]
				else
					error("sum() expects a list of numbers. Found "..item[2].." in list.")
				end
			end
			return Values.mkNumber(sum)
		else
			error("sum() expects a list. Got "..(arg and arg[2] or "nil"))
		end
	end)
	
	env:DeclareNativeFn("max", function(args)
		local arg = args[1]
		if type(arg) == "table" and arg[2] == "table" then
			local max = nil
			for _, item in ipairs(arg[1]) do
				if type(item) == "table" and item[2] == "number" then
					if not max or item[1] > max[1] then
						max = item
		  -  Edit
  21:53:30.987  SOURCE|			end
				else
					error("max() expects a list of numbers. Found "..item[2].." in list.")
				end
			end
			if max then
				return max
			else
				error("max() expects a non-empty list.")
			end
		else
			error("max() expects a list. Got "..(arg and arg[2] or "nil"))
		end
	end)
	
	env:DeclareNativeFn("min", function(args)
		local arg = args[1]
		if type(arg) == "table" and arg[2] == "table" then
			local min = nil
			for _, item in ipairs(arg[1]) do
				if type(item) == "table" and item[2] == "number" then
					if not min or item[1] < min[1] then
						min = item
					end
				else
					error("min() expects a list of numbers. Found "..item[2].." in list.")
				end
			end
			if min then
				return min
			else
				error("min() expects a non-empty list.")
			end
		else
			error("min() expects a list. Got "..(arg and arg[2] or "nil"))
		end
	end)
	
	env:DeclareNativeFn("str", function(args)
		local arg = args[1]
		return Values.mkString(renderValue(arg))
	end)

	env:DeclareNativeFn("int", function(args)
		local arg = args[1]
		if arg == nil then
			return Values.mkNumber(0)
		end
		if arg[2] == "number" then
			return arg
		elseif arg[2] == "string" then
			local n = tonumber(arg[1])
			if n == nil then
				raiseException(Exceptions.types.ValueError, "invalid literal for int(): '" .. arg[1] .. "'")
			end
			return Values.mkNumber(n)
		else
			raiseException(Exceptions.types.TypeError, "int() argument must be a number or a string, not '" .. tostring(arg[2]) .. "'")
		end
	end)

	env:DeclareNativeFn("len", function(args)
		local arg = args[1]
		if type(arg) == "table" and arg[2] == "string" then
			return Values.mkNumber(#arg[1])
		elseif type(arg) == "table" and arg[2] == "table" then
			return Values.mkNumber(GetDictionaryLength(arg[1]))
		elseif type(arg) == "table" and arg[2] == "dictionary" then
			return Values.mkNumber(GetDictionaryLength(arg[1]))
		elseif type(arg) == "table" and arg[2] == "range" then
			local r = arg[1]
			return Values.mkNumber(math.max(0, math.floor((r.stop - r.start) / r.step + 1)))
		else
			return Values.mkNumber(0)
		end
	end)
	
	env:DeclareNativeFn("abs", function(args)
		local arg = args[1]
		if type(arg) == "table" and arg[2] == "number" then
			return Values.mkNumber(math.abs(arg[1]))
		else
			warn("Invalid arguments passed in to abs.")
		end
	end)	
	
	env:DeclareNativeFn("range", function(args)
		local start = args[1]
		local stop
		if not args[2] then
			stop = start
			start = Values.mkNumber(1)
		else
			stop = args[2]
		end

		if not (type(start) == "table" and start[2] == "number") or not (type(stop) == "table" and stop[2] == "number") then
			warn("Invalid arguments passed in to range()")
			return Values.mkNull()
		end

		local step = args[3] and args[3][1] or 1
		return Values.mkRange(start[1], stop[1], step)
	end)
	
	env:DeclareNativeFn("type", function(args)
		local arg = args[1]
		if type(arg) == "table" then
			return arg[2]
		else
			return "unknown"
		end
	end)
	
	module.registerTypeMethod("string", "upper", function(self, args)
		return Values.mkString(string.upper(self[1]))
	end)
	module.registerTypeMethod("string", "lower", function(self, args)
		return Values.mkString(string.lower(self[1]))
	end)
	module.registerTypeMethod("string", "len", function(self, args)
		return Values.mkNumber(#self[1])
	end)
	module.registerTypeMethod("string", "sub", function(self, args)
		local len = #self[1]
		local startIdx = args[1] and args[1][1] or 1
		local endIdx = args[2] and args[2][1] or -1
		local a = startIdx < 0 and len + startIdx + 1 or startIdx + 1
		local b = endIdx < 0 and len + endIdx + 1 or endIdx + 1
		a = math.max(1, math.min(a, len + 1))
		b = math.max(1, math.min(b, len + 1))
		return Values.mkString(self[1]:sub(a, b))
	end)
	module.registerTypeMethod("string", "join", function(self, args)
		local list = args[1]
		if not list or list[2] ~= "  -  Edit
  21:53:30.988  SOURCE|table" then
			error("join() expects a list")
		end
		local parts = {}
		for i, item in ipairs(list[1]) do
			parts[i] = tostring(item[1])
		end
		return Values.mkString(table.concat(parts, self[1]))
	end)
end

function module.registerTypeMethod(typeName, methodName, fn)
	local CollectionMethods = require(script.Parent.Runtime.CollectionMethods)
	CollectionMethods.registerTypeMethod(typeName, methodName, fn)
	return methodName
end

function module.registerLibrary(env, name, members)
	local Values = require(script.Parent.Runtime.Values)
	local lib = {}
	for fnName, caller in pairs(members) do
		lib[fnName] = Values.mkNativeFunction(fnName, caller)
	end
	env:DeclareVar(name, Values.mkDict(lib), true)
	return name
end

function module.importLibrary(env, name, specialName)
	local Libraries = script.Parent.Libraries
	if not Libraries then
		error("No Libraries folder is available for importing")
	end
	local found
	for _, desc in ipairs(Libraries:GetDescendants()) do
		if desc:IsA("ModuleScript") and desc.Name == name then
			found = desc
			break
		end
	end
	if not found then
		error("No library named '" .. tostring(name) .. "'")
	end
	local lib = require(found)
	if type(lib) == "table" and lib.import then
		lib.import(env, specialName)
		return true
	end
	return false
end

module._nativeFns = {}

function module.functionCreate(name, caller)
	module._nativeFns[name] = caller
	return name
end

module["function"] = {
	Create = module.functionCreate,
}

function module.registerNativeFn(name, caller)
	module._nativeFns[name] = caller
end

return module
  -  Edit
  21:53:30.988