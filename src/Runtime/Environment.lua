  20:29:15.218  SOURCE|local module = {}
local Values = require(script.Parent.Values)
module.__index = module

function module.new(parentEnv)
	local self = setmetatable({}, module)
	self.store = {}
	self.globalNames = {}
	self.parent = parentEnv or nil
	self.loopDepth = 0
	return self
end

function module:DeclareVar(name, value, constant)
	self.store[name] = { value = value, constant = constant }
	return value
end

function module:DeclareGlobal(name)
	self.globalNames[name] = true
	return name
end

function module:DeclareNativeFn(name, caller)
	self.store[name] = { value = Values.mkNativeFunction(name, caller), constant = true }
	return self.store[name].value
end

function module:AssignVar(name, value)
	local scope = self
	while scope do
		if scope.globalNames[name] then
			local root = self
			while root.parent do
				root = root.parent
			end
			if root.store[name] and root.store[name].constant then
				error("Cannot reassign constant: " .. name)
			end
			if root.store[name] then
				root.store[name].value = value
			else
				root.store[name] = { value = value, constant = false }
			end
			return value
		end
		scope = scope.parent
	end
	if self.store[name] and self.store[name].constant then
		error("Cannot reassign constant: " .. name)
	end
	if self.store[name] then
		self.store[name].value = value
	else
		self.store[name] = { value = value, constant = false }
	end
	return value
end

function module:LookupVar(name)
	local env = self
	while env do
		if env.store[name] ~= nil then
			return env.store[name].value
		end
		env = env.parent
	end
	error("Cannot resolve: " .. name)
end

return module
  -  Edit
  20:29:15.218