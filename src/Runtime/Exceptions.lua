  20:29:15.219  SOURCE|local module = {}
local Values = require(script.Parent.Values)

local types = {}

local function add(name, parent)
	local t = Values.mkExceptionType(name, parent)
	types[name] = t
	return t
end

local BaseException = add("BaseException", nil)

add("KeyboardInterrupt", BaseException)
add("SystemExit", BaseException)
add("GeneratorExit", BaseException)

local Exception = add("Exception", BaseException)

local ArithmeticError = add("ArithmeticError", Exception)
add("ZeroDivisionError", ArithmeticError)
add("OverflowError", ArithmeticError)
add("FloatingPointError", ArithmeticError)

local LookupError = add("LookupError", Exception)
add("IndexError", LookupError)
add("KeyError", LookupError)

add("TypeError", Exception)
add("ValueError", Exception)

local NameError = add("NameError", Exception)
add("UnboundLocalError", NameError)
add("AttributeError", Exception)

local ImportError = add("ImportError", Exception)
add("ModuleNotFoundError", ImportError)

local RuntimeError = add("RuntimeError", Exception)
add("NotImplementedError", RuntimeError)
add("RecursionError", RuntimeError)

local OSError = add("OSError", Exception)
add("FileNotFoundError", OSError)
add("PermissionError", OSError)
add("IsADirectoryError", OSError)
add("NotADirectoryError", OSError)

add("EOFError", Exception)
add("TimeoutError", Exception)
add("MemoryError", Exception)

function module.registerBuiltins(env)
	for name, t in pairs(types) do
		env:DeclareVar(name, t, true)
	end
end

module.types = types

return module  -  Edit
  20:29:15.219