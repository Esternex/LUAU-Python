  20:44:12.751  SOURCE|local module = {}

local values = require(script.Parent.Parent.Parent.Runtime.Values)

function module.import(env, special)
	if not special then
		special = "math"
	end

	local main = require(script.Parent.Parent.Parent.main)

	local function arg(args, index, expected)
		local value = args[index]

		if not value then
			error("missing argument " .. index)
		end

		if value[2] ~= expected then
			error(
				"expected "
					.. expected
					.. ", got "
					.. tostring(value[2])
			)
		end

		return value[1]
	end

	local function num(n)
		return values.mkNumber(n)
	end

	local function bool(b)
		return values.mkBool(b)
	end

	main.registerLibrary(env, special, {

		abs = function(args)
			return num(math.abs(arg(args, 1, "number")))
		end,

		ceil = function(args)
			return num(math.ceil(arg(args, 1, "number")))
		end,

		floor = function(args)
			return num(math.floor(arg(args, 1, "number")))
		end,

		trunc = function(args)
			local n = arg(args, 1, "number")
			return num(n >= 0 and math.floor(n) or math.ceil(n))
		end,

		sqrt = function(args)
			return num(math.sqrt(arg(args, 1, "number")))
		end,

		pow = function(args)
			return num(
				math.pow(
					arg(args, 1, "number"),
					arg(args, 2, "number")
				)
			)
		end,

		exp = function(args)
			return num(math.exp(arg(args, 1, "number")))
		end,

		log = function(args)
			local x = arg(args, 1, "number")

			if args[2] then
				return num(
					math.log(x)
						/
						math.log(arg(args, 2, "number"))
				)
			end

			return num(math.log(x))
		end,

		log10 = function(args)
			return num(math.log10(arg(args, 1, "number")))
		end,

		sin = function(args)
			return num(math.sin(arg(args, 1, "number")))
		end,

		cos = function(args)
			return num(math.cos(arg(args, 1, "number")))
		end,

		tan = function(args)
			return num(math.tan(arg(args, 1, "number")))
		end,

		asin = function(args)
			return num(math.asin(arg(args, 1, "number")))
		end,

		acos = function(args)
			return num(math.acos(arg(args, 1, "number")))
		end,

		atan = function(args)
			return num(math.atan(arg(args, 1, "number")))
		end,

		atan2 = function(args)
			return num(
				math.atan2(
					arg(args, 1, "number"),
					arg(args, 2, "number")
				)
			)
		end,

		sinh = function(args)
			return num(math.sinh(arg(args, 1, "number")))
		end,

		cosh = function(args)
			return num(math.cosh(arg(args, 1, "number")))
		end,

		tanh = function(args)
			return num(math.tanh(arg(args, 1, "number")))
		end,

		degrees = function(args)
			return num(
				math.deg(arg(args, 1, "number"))
			)
		end,

		radians = function(args)
			return num(
				math.rad(arg(args, 1, "number"))
			)
		end,

		fmod = function(args)
			return num(
				arg(args, 1, "number")
					%
					arg(args, 2, "number")
			)
		end,

		modf = function(args)
			local n = arg(args, 1, "number")

			local integer = math.floor(n)
			local fraction = n - integer

			return values.mkTable({
				values.mkNumber(integer),
				values.mkNumber(fraction),
			})
		end,

		isfinite = function(args)
			local n = arg(args, 1, "number")

			return bool(
				n ~= math.huge
					and n ~= -math.huge
					and n == n
			)
		end,

		isinf = function(args)
			local n = arg(args, 1, "number")

			return bool(
				n == math.huge
					or n == -math.huge
			)
		end,

		isnan = function(args)
			local n = arg(args, 1, "number")

			return bool(n ~= n)
		end,

		factorial = function(args)
			local n = arg(args, 1, "number")

			if n < 0 or n % 1 ~= 0 then
				error("factorial requires non-negative integer")
			end

			local result = 1

			for i = 2, n do
				result *= i
			end

			return num(result)
		end,

		gcd = function(args)
			local a = arg(args, 1, "number")
			local b = arg(args, 2, "number")

			while b ~= 0 do
				a, b = b, a % b
			end

			ret  -  Edit
  20:44:12.751  SOURCE|urn num(math.abs(a))
		end,

		lcm = function(args)
			local a = arg(args, 1, "number")
			local b = arg(args, 2, "number")

			local x = a
			local y = b

			while y ~= 0 do
				x, y = y, x % y
			end

			return num(math.abs(a * b) / math.abs(x))
		end,

		pi = values.mkNumber(math.pi),

		e = values.mkNumber(math.exp(1)),

		tau = values.mkNumber(math.pi * 2),

		inf = values.mkNumber(math.huge),

		nan = values.mkNumber(0 / 0),
	})
end

return module  -  Edit
  20:44:12.751