  20:29:15.219  SOURCE|local module = {}
local Values = require(script.Parent.Values)

local function rawValue(v)
	if type(v) == "table" then
		return v[1]
	end
	return v
end

local function wrapScalar(raw)
	if type(raw) == "number" then
		return Values.mkNumber(raw)
	elseif type(raw) == "boolean" then
		return Values.mkBool(raw)
	end
	return Values.mkString(tostring(raw))
end

local TableMethods = {
	append = function(self, args)
		table.insert(self[1], args[1])
		return Values.mkNull()
	end,
	clear = function(self, args)
		for i = #self[1], 1, -1 do
			table.remove(self[1])
		end
		return Values.mkNull()
	end,
	copy = function(self, args)
		local c = {}
		for i, v in ipairs(self[1]) do
			c[i] = v
		end
		return Values.mkTable(c)
	end,
	count = function(self, args)
		local target = rawValue(args[1])
		local n = 0
		for _, v in ipairs(self[1]) do
			if rawValue(v) == target then
				n = n + 1
			end
		end
		return Values.mkNumber(n)
	end,
	extend = function(self, args)
		local other = args[1]
		if not other or other[2] ~= "table" then
			error("extend() expects an iterable")
		end
		for _, v in ipairs(other[1]) do
			table.insert(self[1], v)
		end
		return Values.mkNull()
	end,
	index = function(self, args)
		local target = rawValue(args[1])
		for i, v in ipairs(self[1]) do
			if rawValue(v) == target then
				return Values.mkNumber(i)
			end
		end
		error("Element not in list")
	end,
	insert = function(self, args)
		local idx = math.max(1, math.floor(rawValue(args[1]) or 1))
		table.insert(self[1], idx, args[2])
		return Values.mkNull()
	end,
	pop = function(self, args)
		if args[1] then
			return table.remove(self[1], math.floor(rawValue(args[1])))
		end
		return table.remove(self[1])
	end,
	remove = function(self, args)
		local target = rawValue(args[1])
		for i, v in ipairs(self[1]) do
			if rawValue(v) == target then
				table.remove(self[1], i)
				return Values.mkNull()
			end
		end
		error("Element not in list")
	end,
	reverse = function(self, args)
		local t = self[1]
		for i = 1, math.floor(#t / 2) do
			t[i], t[#t - i + 1] = t[#t - i + 1], t[i]
		end
		return Values.mkNull()
	end,
	sort = function(self, args)
		table.sort(self[1], function(a, b)
			return rawValue(a) < rawValue(b)
		end)
		return Values.mkNull()
	end,
}

local DictMethods = {
	clear = function(self, args)
		for k in pairs(self[1]) do
			self[1][k] = nil
		end
		return Values.mkNull()
	end,
	copy = function(self, args)
		local c = {}
		for k, v in pairs(self[1]) do
			c[k] = v
		end
		return Values.mkDict(c)
	end,
	fromkeys = function(self, args)
		local keys = args[1]
		local value = args[2] or Values.mkNull()
		local d = {}
		if keys and keys[2] == "table" then
			for _, k in ipairs(keys[1]) do
				d[rawValue(k)] = value
			end
		end
		return Values.mkDict(d)
	end,
	get = function(self, args)
		local v = self[1][rawValue(args[1])]
		if v ~= nil then
			return v
		end
		return args[2] or Values.mkNull()
	end,
	items = function(self, args)
		local lst = {}
		for k, v in pairs(self[1]) do
			table.insert(lst, Values.mkTable({ wrapScalar(k), v }))
		end
		return Values.mkTable(lst)
	end,
	keys = function(self, args)
		local lst = {}
		for k in pairs(self[1]) do
			table.insert(lst, wrapScalar(k))
		end
		return Values.mkTable(lst)
	end,
	pop = function(self, args)
		local v = self[1][rawValue(args[1])]
		if v ~= nil then
			self[1][rawValue(args[1])] = nil
			return v
		end
		return Values.mkNull()
	end,
	popitem = function(self, args)
		local k = next(self[1])
		if k == nil then
			error("popitem(): dictionary is empty")
		end
		local v = self[1][k]
		self[1][k] = nil
		return Values.mkTable({ wrapScalar(k), v })
	end,
	setdefault = function(self, args)
		local key = rawValue(args[1])
		if self[1][key] ~= nil then
			return self[1][key]
		end
		local value = args[2] or Values.mkNull()
		self[1][key] = val  -  Edit
  20:29:15.219  SOURCE|ue
		return value
	end,
	update = function(self, args)
		local src = args[1]
		if src then
			if src[2] == "dictionary" then
				for k, v in pairs(src[1]) do
					self[1][k] = v
				end
			elseif src[2] == "table" then
				for _, item in ipairs(src[1]) do
					if item and item[2] == "table" and #item[1] >= 2 then
						self[1][rawValue(item[1][1])] = item[1][2]
					end
				end
			end
		end
		return Values.mkNull()
	end,
	values = function(self, args)
		local lst = {}
		for _, v in pairs(self[1]) do
			table.insert(lst, v)
		end
		return Values.mkTable(lst)
	end,
}

local TypeMethods = {}

local function tryCallMember(container, property, args, env)
	if type(container) ~= "table" then
		return nil, false
	end
	local member = container[property]
	if type(member) == "table" and member[2] == "native_function" then
		return member.caller(args, env), true
	end
	return nil, false
end

function module.registerTypeMethod(typeName, methodName, fn)
	TypeMethods[typeName] = TypeMethods[typeName] or {}
	TypeMethods[typeName][methodName] = fn
end

function module.dispatch(receiver, property, args, env)
	if receiver[2] == "roblox" then
		local bridge = require(script.Parent.RobloxBridge)
		return bridge.InvokeMethod(receiver, property, args, env)
	elseif receiver[2] == "table" then
		local m = TableMethods[property]
		if m then
			return m(receiver, args)
		end
	elseif receiver[2] == "dictionary" then
		local m = DictMethods[property]
		if m then
			return m(receiver, args)
		end
	end
	local typeMethods = TypeMethods[receiver[2]]
	if typeMethods then
		local m = typeMethods[property]
		if m then
			return m(receiver, args)
		end
	end
	local res, ok = tryCallMember(receiver[1], property, args, env)
	if ok then
		return res
	end
	error("Type '" .. tostring(receiver[2]) .. "' has no property '" .. tostring(property) .. "'")
end

return module  -  Edit
  20:29:15.219