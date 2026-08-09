  20:44:12.751  SOURCE|local module = {}

local values = require(script.Parent.Parent.Parent.Runtime.Values)

function module.import(env, special)
	if not special then
		special = "random"
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

	local function optionalArg(args, index, expected)
		local value = args[index]

		if not value then
			return nil
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

	local function table(t)
		return values.mkTable(t)
	end

	main.registerLibrary(env, special, {

		random = function(args)
			return num(math.random())
		end,

		uniform = function(args)
			local a = arg(args, 1, "number")
			local b = arg(args, 2, "number")

			return num(
				a + math.random() * (b - a)
			)
		end,

		randint = function(args)
			local a = arg(args, 1, "number")
			local b = arg(args, 2, "number")

			return num(math.random(a, b))
		end,

		randrange = function(args)
			local start = arg(args, 1, "number")
			local stop = arg(args, 2, "number")

			local step = optionalArg(args, 3, "number")
				or 1

			local count = math.ceil(
				(stop - start) / step
			)

			if count <= 0 then
				error("empty range")
			end

			return num(
				start + (math.random(0, count - 1) * step)
			)
		end,

		choice = function(args)
			local list = arg(args, 1, "table")

			if #list == 0 then
				error("cannot choose from empty sequence")
			end

			return list[
			math.random(1, #list)
			]
		end,

		choices = function(args)
			local list = arg(args, 1, "table")
			local count = optionalArg(args, 2, "number")
				or 1

			local result = {}

			for i = 1, count do
				result[i] = list[
				math.random(1, #list)
				]
			end

			return table(result)
		end,

		shuffle = function(args)
			local list = arg(args, 1, "table")

			for i = #list, 2, -1 do
				local j = math.random(1, i)

				list[i], list[j] =
					list[j], list[i]
			end

			return values.mkNull()
		end,

		sample = function(args)
			local list = arg(args, 1, "table")
			local count = arg(args, 2, "number")

			if count > #list then
				error("sample larger than population")
			end

			local copy = {}

			for i, v in ipairs(list) do
				copy[i] = v
			end

			local result = {}

			for i = 1, count do
				local index = math.random(1, #copy)

				result[i] = copy[index]

				table.remove(copy, index)
			end

			return table(result)
		end,

		seed = function(args)
			local seed = optionalArg(args, 1, "number")

			if seed then
				math.randomseed(seed)
			else
				math.randomseed(os.time())
			end

			return values.mkNull()
		end,

		getrandbits = function(args)
			local bits = arg(args, 1, "number")

			local max = 2 ^ bits - 1

			return num(
				math.random(0, max)
			)
		end,

		betavariate = function(args)
			local alpha = arg(args, 1, "number")
			local beta = arg(args, 2, "number")

			local x = math.random()

			return num(
				x ^ (1 / alpha)
					/
					(
						x ^ (1 / alpha)
						+
						(1 - x) ^ (1 / beta)
					)
			)
		end,

		expovariate = function(args)
			local lambd = arg(args, 1, "number")

			return num(
				-math.log(1 - math.random())
					/
					lambd
			)
		end,

		gauss = function(args)
			local mu = arg(args, 1, "number")
			local sigma = arg(args, 2, "number")

			local u1 = math.random()
			local u2 = math.random()

			local z =  -  Edit
  20:44:12.751  SOURCE| math.sqrt(
				-2 * math.log(u1)
			)
				*
				math.cos(
					2 * math.pi * u2
				)

			return num(
				mu + z * sigma
			)
		end,

		normalvariate = function(args)
			local mu = arg(args, 1, "number")
			local sigma = arg(args, 2, "number")

			local u1 = math.random()
			local u2 = math.random()

			local z = math.sqrt(
				-2 * math.log(u1)
			)
				*
				math.cos(
					2 * math.pi * u2
				)

			return num(
				mu + z * sigma
			)
		end,
	})
end

return module  -  Edit
  20:44:12.752