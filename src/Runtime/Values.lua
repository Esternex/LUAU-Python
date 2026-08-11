  15:36:08.050  SOURCE|local module = {}

function module.mkNumber(nm)
	return { nm, "number" }
end

function module.mkString(str)
	return { str, "string" }
end

function module.mkNull()
	return { "null", "null" }
end

function module.mkBool(b)
	return { b, "boolean" }
end

function module.mkTable(list)
	return { list, "table" }
end

function module.mkDict(dict)
	return { dict, "dictionary" }
end

function module.mkRange(start, stop, step)
	return { { start = start, stop = stop, step = step }, "range" }
end

function module.mkTuple(items)
	return { items, "tuple" }
end

function module.mkFunction(name, params, body)
	return { name, "function", params = params, body = body }
end

function module.mkNativeFunction(name, caller)
	return { name, "native_function", caller = caller }
end

function module.mkClass(name, methods)
	return { name, "class", methods = methods }
end

function module.mkInstance(classVal)
	return { classVal, "instance", fields = {} }
end

function module.mkRoblox(raw)
	if type(raw) == "table" then
		local kind = raw[2]
		if kind == "roblox" then
			return raw
		end
	end
	return { raw, "roblox" }
end

function module.isTruthy(val)
	if val[2] == "boolean" then
		return val[1] == true
	elseif val[2] == "null" then
		return false
	elseif val[2] == "number" then
		return val[1] ~= 0
	elseif val[2] == "string" then
		return val[1] ~= ""
	elseif val[2] == "table" then
		return #val[1] > 0
	elseif val[2] == "dictionary" then
		return next(val[1]) ~= nil
	end
	return true
end

function module.isFunction(val)
	return val[2] == "function" or val[2] == "native_function"
end

function module.mkExceptionType(name, parent)
	return { name, "exception_type", parent = parent }
end

function module.mkException(typeVal, message)
	return { typeVal, "exception", message = message }
end

function module.exceptionMatches(excVal, handlerTypeVal)
	if type(excVal) ~= "table" or excVal[2] ~= "exception" then
		return false
	end
	if type(handlerTypeVal) ~= "table" or handlerTypeVal[2] ~= "exception_type" then
		return false
	end
	local t = excVal[1]
	while t do
		if t == handlerTypeVal then
			return true
		end
		t = t.parent
	end
	return false
end

return module
  -  Edit
  15:36:08.050