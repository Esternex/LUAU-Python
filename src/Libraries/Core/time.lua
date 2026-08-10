  20:29:15.215  SOURCE|local module = {}

function module.import(env, special)
	if not special then
		special = "time"
	end

	local main = require(script.Parent.Parent.Parent.main)
	local values = require(script.Parent.Parent.Parent.Runtime.Values)

	local function arg(args, index, expected)
		local value = args[index]

		if not value then
			error(
				"missing argument: expected "
					.. expected
					.. " at position "
					.. index
			)
		end

		if value[2] ~= expected then
			error(
				"Invalid argument: expected "
					.. expected
					.. ", got "
					.. tostring(value[2])
			)
		end

		return value[1]
	end

	local function optionalArg(args, index, expected, default)
		local value = args[index]

		if not value then
			return default
		end

		if value[2] ~= expected then
			error(
				"Invalid argument: expected "
					.. expected
					.. ", got "
					.. tostring(value[2])
			)
		end

		return value[1]
	end

	local function rawNow()
		return os.time()
	end

	local function rawMonotonic()
		return os.clock()
	end

	local function now()
		return values.mkNumber(rawNow())
	end

	local function monotonic()
		return values.mkNumber(rawMonotonic())
	end

	main.registerLibrary(env, special, {

		time = function(args)
			return now()
		end,

		time_ns = function(args)
			return values.mkNumber(math.floor(rawNow() * 1000000000))
		end,

		sleep = function(args)
			local seconds = arg(args, 1, "number")

			if seconds < 0 then
				error("sleep length must be non-negative")
			end

			task.wait(seconds)


			return values.mkNull()
		end,

		monotonic = function(args)
			return monotonic()
		end,

		monotonic_ns = function(args)
			return values.mkNumber(math.floor(rawMonotonic() * 1000000000))
		end,

		perf_counter = function(args)
			return monotonic()
		end,

		perf_counter_ns = function(args)
			return values.mkNumber(math.floor(rawMonotonic() * 1000000000))
		end,

		process_time = function(args)
			return values.mkNumber(os.clock())
		end,

		process_time_ns = function(args)
			return values.mkNumber(math.floor(os.clock() * 1000000000))
		end,

		thread_time = function(args)
			return values.mkNumber(os.clock())
		end,

		thread_time_ns = function(args)
			return values.mkNumber(math.floor(os.clock() * 1000000000))
		end,

		localtime = function(args)
			local seconds = optionalArg(
				args,
				1,
				"number",
				rawNow()
			)

			local t = os.date("*t", seconds)

			return values.mkDict({
				year = values.mkNumber(t.year),
				month = values.mkNumber(t.month),
				day = values.mkNumber(t.day),
				hour = values.mkNumber(t.hour),
				minute = values.mkNumber(t.min),
				second = values.mkNumber(t.sec),
				weekday = values.mkNumber(t.wday),
				yearday = values.mkNumber(t.yday),
				isdst = values.mkBool(t.isdst),
			})
		end,

		gmtime = function(args)
			local seconds = optionalArg(
				args,
				1,
				"number",
				rawNow()
			)

			local t = os.date("!*t", seconds)

			return values.mkDict({
				year = values.mkNumber(t.year),
				month = values.mkNumber(t.month),
				day = values.mkNumber(t.day),
				hour = values.mkNumber(t.hour),
				minute = values.mkNumber(t.min),
				second = values.mkNumber(t.sec),
				weekday = values.mkNumber(t.wday),
				yearday = values.mkNumber(t.yday),
				isdst = values.mkBool(false),
			})
		end,

		difftime = function(args)
			local t2 = arg(args, 1, "number")
			local t1 = arg(args, 2, "number")

			return values.mkNumber(t2 - t1)
		end,

		ctime = function(args)
			local seconds = optionalArg(
				args,
				1,
				"number",
				rawNow()
			)

			return values.mkString(os.date("%a %b %d %H:%M:%S %Y", seconds))
		end,

		asctime = function(args)
			if not args[1] then
				return values.mkString(os.date("%a %b %d %H:%M:%S %Y"))
			end

			local value = args[1]

			if value[2] ~= "table" then
				error(
					"In  -  Edit
  20:29:15.215  SOURCE|valid argument to time.asctime: expected tuple"
				)
			end

			local t = value[1]

			local timestamp = os.time({
				year = t[1],
				month = t[2],
				day = t[3],
				hour = t[4],
				min = t[5],
				sec = t[6],
			})

			return values.mkString(os.date(
				"%a %b %d %H:%M:%S %Y",
				timestamp
				))
		end,

		strftime = function(args)
			local format = arg(args, 1, "string")

			if not args[2] then
				return values.mkString(os.date(format))
			end

			local tuple = arg(args, 2, "table")

			local timestamp = os.time({
				year = tuple[1],
				month = tuple[2],
				day = tuple[3],
				hour = tuple[4],
				min = tuple[5],
				sec = tuple[6],
			})

			return values.mkString(os.date(format, timestamp))
		end,

		mktime = function(args)
			local tuple = arg(args, 1, "table")

			return values.mkNumber(os.time({
				year = tuple[1],
				month = tuple[2],
				day = tuple[3],
				hour = tuple[4],
				min = tuple[5],
				sec = tuple[6],
			}))
		end,

		get_clock_info = function(args)
			local name = arg(args, 1, "string")

			if name == "time" then
				return values.mkDict({
					implementation = values.mkString("os.time"),
					monotonic = values.mkBool(false),
					adjustable = values.mkBool(true),
					resolution = values.mkNumber(1),
				})
			end

			if name == "monotonic"
				or name == "perf_counter"
				or name == "process_time"
				or name == "thread_time"
			then
				return values.mkDict({
					implementation = values.mkString("os.clock"),
					monotonic = values.mkBool(true),
					adjustable = values.mkBool(false),
					resolution = values.mkNumber(0.000001),
				})
			end

			error("unknown clock: " .. name)
		end,

		strptime = function(args)
			error(
				"time.strptime is not implemented yet"
			)
		end,

		clock_getres = function(args)
			error(
				"time.clock_getres is not available in Luau"
			)
		end,

		clock_gettime = function(args)
			error(
				"time.clock_gettime is not available in Luau"
			)
		end,

		clock_gettime_ns = function(args)
			error(
				"time.clock_gettime_ns is not available in Luau"
			)
		end,

		clock_settime = function(args)
			error(
				"time.clock_settime is not available in Luau"
			)
		end,

		clock_settime_ns = function(args)
			error(
				"time.clock_settime_ns is not available in Luau"
			)
		end,

		pthread_getcpuclockid = function(args)
			error(
				"time.pthread_getcpuclockid is not available in Luau"
			)
		end,

		tzset = function(args)
			error(
				"time.tzset is not available in Luau"
			)
		end,
	})
end

return module  -  Edit
  20:29:15.215