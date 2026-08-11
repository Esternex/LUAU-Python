  15:36:08.052  SOURCE|local module = {}
local Values = require(script.Parent.Parent.Values)

local function eval_program(program, env)
	local result = Values.mkNull()
	for _, statement in ipairs(program.body) do
		result = require(script.Parent.Parent.Interpreter).evaluate(statement, env)
	end
	return result
end

local function eval_var_declaration(VarDeclaration, env)
	local value = VarDeclaration.value and require(script.Parent.Parent.Interpreter).evaluate(VarDeclaration.value, env) or Values.mkNull()
	return env:DeclareVar(VarDeclaration.identifier, value, VarDeclaration.constant)
end

local function eval_function_declaration(funcDecl, env)
	local funcVal = Values.mkFunction(funcDecl.name, funcDecl.parameters, funcDecl.body)
	return env:DeclareVar(funcDecl.name, funcVal, false)
end

local function eval_class_declaration(classDecl, env)
	local methods = {}
	for _, stmt in ipairs(classDecl.methods) do
		if stmt.kind == "FunctionDeclaration" then
			methods[stmt.name] = Values.mkFunction(stmt.name, stmt.parameters, stmt.body)
		end
	end
	local classVal = Values.mkClass(classDecl.name, methods)
	return env:DeclareVar(classDecl.name, classVal, false)
end

local function eval_if_statement(ifStmt, env)
	local result = Values.mkNull()

	for i, condition in ipairs(ifStmt.conditions) do
		local body = ifStmt.bodies[i]

		if condition and condition.kind == "ElseCondition" then
			for _, stmt in ipairs(body) do
				result = require(script.Parent.Parent.Interpreter).evaluate(stmt, env)
				if type(result) == "table" and result.__isReturn then
					return result
				end
			end
			return result
		else
			local condResult = require(script.Parent.Parent.Interpreter).evaluate(condition, env)
			if Values.isTruthy(condResult) then
				for _, stmt in ipairs(body) do
					result = require(script.Parent.Parent.Interpreter).evaluate(stmt, env)
					if type(result) == "table" and result.__isReturn then
						return result
					end
				end
				return result
			end
		end
	end

	return result
end

local function eval_for_statement(forStmt, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local iterable = parent.evaluate(forStmt.iterable, env)
	local result = Values.mkNull()

	env.loopDepth = (env.loopDepth or 0) + 1

	local ok, iterResult = pcall(function()
		local function runBody(item)
			local hadPrev = env.store[forStmt.variable] ~= nil
			local prev = env.store[forStmt.variable]
			env.store[forStmt.variable] = { value = item, constant = false }
			local bodyOk, bodyErr = pcall(function()
				local ret
				for _, stmt in ipairs(forStmt.body) do
					local stmtResult = parent.evaluate(stmt, env)
					if type(stmtResult) == "table" and stmtResult.__isReturn then
						ret = { __isReturn = true, retval = stmtResult.retval }
						break
					end
				end
				return ret
			end)
			if hadPrev then
				env.store[forStmt.variable] = prev
			else
				env.store[forStmt.variable] = nil
			end
			return bodyOk, bodyErr
		end

		local function processItem(item)
			local bodyOk, bodyErr = runBody(item)
			if not bodyOk then
				if type(bodyErr) == "table" and bodyErr.__pb_break then
					return "break"
				elseif type(bodyErr) == "table" and bodyErr.__pb_continue then
					return nil
				else
					error(bodyErr)
				end
			end
			if bodyErr then
				return bodyErr
			end
			return nil
		end

		if iterable[2] == "table" then
			for _, item in ipairs(iterable[1]) do
				local r = processItem(item)
				if r then
					return r
				end
			end
		elseif iterable[2] == "range" then
			local rangeObj = iterable[1]
			for i = rangeObj.start, rangeObj.stop, rangeObj.step do
				local r = processItem(Values.mkNumber(i))
				if r then
					return r
				end
			end
		elseif iterable[2] == "dictionary" then
			for k, _ in pairs(iterable[1]) do
				local keyVal = if type(k) == "number" then Values.mkNumber(k) else Values.mkString(tostring(k))
				local r =   -  Edit
  15:36:08.052  SOURCE|processItem(keyVal)
				if r then
					return r
				end
			end
		else
			error("Cannot iterate over value of type " .. tostring(iterable[2]))
		end
		return nil
	end)

	env.loopDepth = (env.loopDepth or 0) - 1

	if not ok then
		error(iterResult)
	end
	if type(iterResult) == "table" and iterResult.__isReturn then
		return iterResult
	end
	return result
end

local function eval_global_statement(stmt, env)
	for _, name in ipairs(stmt.names) do
		env:DeclareGlobal(name)
	end
	return Values.mkNull()
end

local function eval_import_statement(stmt, env)
	if not stmt.specialName then stmt.specialName = stmt.name end
	local main = require(script.Parent.Parent.Parent.main)
	main.importLibrary(env, stmt.name, stmt.specialName)
	return Values.mkNull()
end

local function eval_while_statement(whileStmt, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local result = Values.mkNull()

	env.loopDepth = (env.loopDepth or 0) + 1

	local ok, iterResult = pcall(function()
		while true do
			local condition = parent.evaluate(whileStmt.condition, env)
			if not Values.isTruthy(condition) then
				return nil
			end
			local bodyOk, bodyErr = pcall(function()
				local ret
				for _, stmt in ipairs(whileStmt.body) do
					local stmtResult = parent.evaluate(stmt, env)
					if type(stmtResult) == "table" and stmtResult.__isReturn then
						ret = { __isReturn = true, retval = stmtResult.retval }
						break
					end
				end
				return ret
			end)
			if not bodyOk then
				if type(bodyErr) == "table" and bodyErr.__pb_break then
					return nil
				elseif type(bodyErr) == "table" and bodyErr.__pb_continue then
				else
					error(bodyErr)
				end
			elseif bodyErr then
				return bodyErr
			end
		end
	end)

	env.loopDepth = (env.loopDepth or 0) - 1

	if not ok then
		error(iterResult)
	end
	if type(iterResult) == "table" and iterResult.__isReturn then
		return iterResult
	end
	return result
end

local function eval_raise_statement(stmt, env)
	if stmt.value == nil then
		local current = env.currentException
		if not current then
			error("Cannot re-raise: no active exception")
		end
		error({ __pb_exception = true, value = current })
	end

	local parent = require(script.Parent.Parent.Interpreter)
	local value = parent.evaluate(stmt.value, env)
	local exc
	if value[2] == "exception" then
		exc = value
	elseif value[2] == "exception_type" then
		exc = Values.mkException(value, "")
	else
		error("Cannot raise value of type '" .. tostring(value[2]) .. "'")
	end
	error({ __pb_exception = true, value = exc })
end

local function eval_try_statement(tryStmt, env)
	local parent = require(script.Parent.Parent.Interpreter)

	local function runBlock(body)
		local ret
		for _, stmt in ipairs(body) do
			local stmtResult = parent.evaluate(stmt, env)
			if type(stmtResult) == "table" and stmtResult.__isReturn then
				ret = { __isReturn = true, retval = stmtResult.retval }
				break
			end
		end
		return ret
	end

	local pendingError
	local pendingReturn

	local ok, tryResult = pcall(runBlock, tryStmt.body or {})

	if not ok then
		local err = tryResult
		if type(err) == "table" and err.__pb_exception then
			local handled = false
			for _, handler in ipairs(tryStmt.handlers or {}) do
				local matches = false
				if handler.excType == nil then
					matches = true
				else
					local handlerTypeVal = parent.evaluate(handler.excType, env)
					matches = Values.exceptionMatches(err.value, handlerTypeVal)
				end
				if matches then
					handled = true

					local hadPrev
					local prev
					if handler.name then
						hadPrev = env.store[handler.name] ~= nil
						prev = env.store[handler.name]
						env.store[handler.name] = { value = err.value, constant = false }
				end
					local prevCurrent = env.currentException
					env.currentException = err.value

					local hOk, hResult = pcall(runBlock, handler.bod  -  Edit
  15:36:08.053  SOURCE|y or {})
					if not hOk then
						pendingError = hResult
					elseif hResult then
						pendingReturn = hResult
					end

					env.currentException = prevCurrent
					if handler.name then
						if hadPrev then
							env.store[handler.name] = prev
						else
							env.store[handler.name] = nil
						end
					end
					break
				end
			end
			if not handled then
				pendingError = err
			end
		else
			pendingError = err
		end
	elseif tryResult then
		pendingReturn = tryResult
	else
		local elseOk, elseResult = pcall(runBlock, tryStmt.elseBody or {})
		if not elseOk then
			pendingError = elseResult
		elseif elseResult then
			pendingReturn = elseResult
		end
	end

	local finOk, finResult = pcall(runBlock, tryStmt.finallyBody or {})
	if not finOk then
		error(finResult)
	end
	if finResult then
		return finResult
	end

	if pendingError then
		error(pendingError)
	end
	if pendingReturn then
		return pendingReturn
	end
	return Values.mkNull()
end

return {
	eval_program = eval_program,
	eval_var_declaration = eval_var_declaration,
	eval_function_declaration = eval_function_declaration,
	eval_class_declaration = eval_class_declaration,
	eval_if_statement = eval_if_statement,
	eval_for_statement = eval_for_statement,
	eval_while_statement = eval_while_statement,
	eval_global_statement = eval_global_statement,
	eval_import_statement = eval_import_statement,
	eval_raise_statement = eval_raise_statement,
	eval_try_statement = eval_try_statement,
}
  -  Edit
  15:36:08.053