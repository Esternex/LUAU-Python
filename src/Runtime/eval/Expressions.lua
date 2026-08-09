  20:44:12.753  SOURCE|local module = {}
local Values = require(script.Parent.Parent.Values)
local Environment = require(script.Parent.Parent.Environment)
local RobloxBridge = require(script.Parent.Parent.RobloxBridge)
local Exceptions = require(script.Parent.Parent.Exceptions)

local function eval_number_binary_expr(lhs, rhs, operator)
	local result = 0
	if operator == "+" then
		result = lhs[1] + rhs[1]
	elseif operator == "-" then
		result = lhs[1] - rhs[1]
	elseif operator == "*" then
		result = lhs[1] * rhs[1]
	elseif operator == "/" then
		if rhs[1] == 0 then
			local exc = Values.mkException(Exceptions.types.ZeroDivisionError, "division by zero")
			error({ __pb_exception = true, value = exc })
		end
		result = lhs[1] / rhs[1]
	elseif operator == "%" then
		if rhs[1] == 0 then
			local exc = Values.mkException(Exceptions.types.ZeroDivisionError, "integer division or modulo by zero")
			error({ __pb_exception = true, value = exc })
		end
		result = lhs[1] % rhs[1]
	elseif operator == "**" then
		result = lhs[1] ^ rhs[1]
	end
	return Values.mkNumber(result)
end

local function eval_comparison_expr(lhs, rhs, operator)
	local result = false
	if operator == "==" then
		result = lhs[1] == rhs[1]
	elseif operator == "!=" then
		result = lhs[1] ~= rhs[1]
	elseif operator == "<" then
		result = lhs[1] < rhs[1]
	elseif operator == ">" then
		result = lhs[1] > rhs[1]
	elseif operator == "<=" then
		result = lhs[1] <= rhs[1]
	elseif operator == ">=" then
		result = lhs[1] >= rhs[1]
	end
	return Values.mkBool(result)
end

local function eval_string_concat_expr(lhs, rhs)
	return Values.mkString(tostring(lhs[1]) .. tostring(rhs[1]))
end

local function eval_fstring(node, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local Parser = require(script.Parent.Parent.Parent.parser)
	local out = {}
	for _, part in ipairs(node.parts) do
		if part.expr then
			local program = Parser.new():ProduceAST(part.expr)
			local stmt = program.body[1]
			if stmt then
				local v = parent.evaluate(stmt, env)
				out[#out + 1] = tostring(v[1])
			end
		else
			out[#out + 1] = part.lit
		end
	end
	return Values.mkString(table.concat(out))
end

local function eval_unary_expr(unaryNode, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local operand = parent.evaluate(unaryNode.operand, env)
	if unaryNode.operator == "-" then
		if operand[2] == "number" then
			return Values.mkNumber(-operand[1])
		end
	elseif unaryNode.operator == "+" then
		if operand[2] == "number" then
			return Values.mkNumber(operand[1])
		end
	elseif unaryNode.operator == "!" then
		return Values.mkBool(not Values.isTruthy(operand))
	end
	return Values.mkNull()
end

local function evaluate_binary_expr(binop, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local leftHandSide = parent.evaluate(binop.left, env)
	local rightHandSide = parent.evaluate(binop.right, env)

	local function raiseTypeError()
		error({
			__pb_exception = true,
			value = Values.mkException(
				Exceptions.types.TypeError,
				"unsupported operand type(s) for " .. binop.operator .. ": '" .. tostring(leftHandSide[2]) .. "' and '" .. tostring(rightHandSide[2]) .. "'"
			),
		})
	end

	if binop.operator == ".." then
		return Values.mkString(tostring(leftHandSide[1]) .. tostring(rightHandSide[1]))
	end

	if binop.operator == "and" then
		if not Values.isTruthy(leftHandSide) then
			return leftHandSide
		end
		return rightHandSide
	elseif binop.operator == "or" then
		if Values.isTruthy(leftHandSide) then
			return leftHandSide
		end
		return rightHandSide
	end

	local lhsType = leftHandSide[2]
	local rhsType = rightHandSide[2]

	if binop.operator == "+" then
		if lhsType == "number" and rhsType == "number" then
			return eval_number_binary_expr(leftHandSide, rightHandSide, "+")
		elseif lhsType == "string" and rhsType == "string" then
			return eval_string_concat_expr(l  -  Edit
  20:44:12.753  SOURCE|eftHandSide, rightHandSide)
		end
		raiseTypeError()
	end

	if binop.operator == "-" or binop.operator == "*" or binop.operator == "/" or binop.operator == "%" or binop.operator == "**" then
		if lhsType == "number" and rhsType == "number" then
			return eval_number_binary_expr(leftHandSide, rightHandSide, binop.operator)
		end
		raiseTypeError()
	end

	if (lhsType == "string" or rhsType == "string") and (binop.operator == "==" or binop.operator == "!=") then
		return eval_comparison_expr(leftHandSide, rightHandSide, binop.operator)
	end

	if lhsType == "number" and rhsType == "number" then
		return eval_comparison_expr(leftHandSide, rightHandSide, binop.operator)
	end

	if binop.operator == "==" then
		return Values.mkBool(leftHandSide[1] == rightHandSide[1])
	elseif binop.operator == "!=" then
		return Values.mkBool(leftHandSide[1] ~= rightHandSide[1])
	end

	return Values.mkNull()
end

local function evaluate_identifier(astNode, env)
	return env:LookupVar(astNode.symbol)
end

local function eval_table_literal(node, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local list = {}
	for i, item in ipairs(node.list) do
		list[i] = parent.evaluate(item, env)
	end
	return Values.mkTable(list)
end

local function eval_list_comprehension(node, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local out = {}

	local function runClause(i, iterEnv)
		if i > #node.clauses then
			table.insert(out, parent.evaluate(node.value, iterEnv))
			return
		end
		local clause = node.clauses[i]
		local iterable = parent.evaluate(clause.iterable, iterEnv)

		local function processItem(item)
			local hadPrev = iterEnv.store[clause.variable] ~= nil
			local prev = iterEnv.store[clause.variable]
			iterEnv.store[clause.variable] = { value = item, constant = false }
			if not clause.filter or Values.isTruthy(parent.evaluate(clause.filter, iterEnv)) then
				runClause(i + 1, iterEnv)
			end
			if hadPrev then
				iterEnv.store[clause.variable] = prev
			else
				iterEnv.store[clause.variable] = nil
			end
		end

		if iterable[2] == "table" then
			for _, item in ipairs(iterable[1]) do
				processItem(item)
			end
		elseif iterable[2] == "range" then
			local r = iterable[1]
			for n = r.start, r.stop, r.step do
				processItem(Values.mkNumber(n))
			end
		elseif iterable[2] == "dictionary" then
			for k, _ in pairs(iterable[1]) do
				local keyVal = if type(k) == "number" then Values.mkNumber(k) else Values.mkString(tostring(k))
				processItem(keyVal)
			end
		else
			error("Cannot iterate over value of type " .. tostring(iterable[2]))
		end
	end

	local iterEnv = Environment.new(env)
	runClause(1, iterEnv)
	return Values.mkTable(out)
end

local function eval_dict_literal(node, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local dict = {}
	for _, entry in ipairs(node.entries) do
		local keyVal = parent.evaluate(entry[1], env)
		dict[keyVal[1]] = parent.evaluate(entry[2], env)
	end
	return Values.mkDict(dict)
end

local function listIndexPos(list, indexVal)
	if indexVal[2] ~= "number" then
		error({
			__pb_exception = true,
			value = Values.mkException(Exceptions.types.TypeError, "list indices must be integers, not " .. tostring(indexVal[2])),
		})
	end
	local raw = indexVal[1]
	if math.floor(raw) ~= raw then
		error({
			__pb_exception = true,
			value = Values.mkException(Exceptions.types.TypeError, "list indices must be integers, not " .. tostring(raw)),
		})
	end
	local len = #list
	local pos = raw < 0 and (len + raw + 1) or (raw + 1)
	return pos, len
end

local function eval_index_expr(node, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local receiver = parent.evaluate(node.object, env)
	local index = parent.evaluate(node.index, env)
	if receiver[2] == "roblox" then
		return RobloxBridge.FindChild(receiver, index[1])
	elseif receiver[2] == "table" then
		lo  -  Edit
  20:44:12.753  SOURCE|cal pos, len = listIndexPos(receiver[1], index)
		if pos < 1 or pos > len then
			error({
				__pb_exception = true,
				value = Values.mkException(Exceptions.types.IndexError, "list index out of range"),
			})
		end
		return receiver[1][pos]
	elseif receiver[2] == "dictionary" then
		local v = receiver[1][index[1]]
		if v ~= nil then
			return v
		end
		error({
			__pb_exception = true,
			value = Values.mkException(Exceptions.types.KeyError, "key '" .. tostring(index[1]) .. "' not found"),
		})
	end
	error("Cannot index value of type '" .. tostring(receiver[2]) .. "'")
end

local function eval_index_write(receiver, index, value)
	if receiver[2] == "table" then
		local pos, len = listIndexPos(receiver[1], index)
		if pos < 1 or pos > len + 1 then
			error({
				__pb_exception = true,
				value = Values.mkException(Exceptions.types.IndexError, "list assignment index out of range"),
			})
		end
		receiver[1][pos] = value
		return value
	elseif receiver[2] == "dictionary" then
		receiver[1][index[1]] = value
		return value
	end
	error("Cannot index value of type '" .. tostring(receiver[2]) .. "'")
end

local function invoke_user_function(fnVal, evaluatedArgs, callingEnv, keywordArgs)
	local parent = require(script.Parent.Parent.Interpreter)
	local funcEnv = Environment.new(callingEnv)
	local params = fnVal.params or {}
	for i, param in ipairs(params) do
		local value
		if keywordArgs and keywordArgs[param] ~= nil then
			value = keywordArgs[param]
		else
			value = evaluatedArgs[i]
		end
		funcEnv:DeclareVar(param, value or Values.mkNull(), false)
	end
	local result = Values.mkNull()
	for _, stmt in ipairs(fnVal.body) do
		local stmtResult = parent.evaluate(stmt, funcEnv)
		if type(stmtResult) == "table" and stmtResult.__isReturn then
			result = stmtResult.retval
			break
		end
	end
	return result
end

local function eval_assignment(node, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local value = parent.evaluate(node.value, env)
	local assigne = node.assigne
	if assigne.kind == "Identifier" then
		return env:AssignVar(assigne.symbol, value)
	elseif assigne.kind == "IndexExpr" then
		local receiver = parent.evaluate(assigne.object, env)
		local index = parent.evaluate(assigne.index, env)
		return eval_index_write(receiver, index, value)
	elseif assigne.kind == "MemberExpr" then
		local receiver = parent.evaluate(assigne.object, env)
		if receiver[2] == "instance" then
			receiver.fields[assigne.property] = value
			return value
		elseif receiver[2] == "roblox" then
			return RobloxBridge.SetMember(receiver, assigne.property, value, env)
		end
		error("Cannot assign property on value of type '" .. tostring(receiver[2]) .. "'")
	else
		error("Invalid assignment target.")
	end
end

local function eval_member(node, env)
	local parent = require(script.Parent.Parent.Interpreter)
	local receiver = parent.evaluate(node.object, env)
	if receiver[2] == "instance" then
		local v = receiver.fields[node.property]
		if v ~= nil then
			return v
		end
		return Values.mkNull()
	elseif receiver[2] == "roblox" then
		return RobloxBridge.getMember(receiver, node.property)
	end
	error("Property '" .. tostring(node.property) .. "' must be called as a method (obj." .. tostring(node.property) .. "(...))")
end

local function eval_call_expr(node, env)
	local parent = require(script.Parent.Parent.Interpreter)

	local function evaluateArgs()
		local posArgs = {}
		local kwArgs = {}
		for _, argNode in ipairs(node.args) do
			if argNode.kind == "KeywordArgument" then
				kwArgs[argNode.name] = parent.evaluate(argNode.value, env)
			else
				table.insert(posArgs, parent.evaluate(argNode, env))
			end
		end
		return posArgs, kwArgs
	end

	if node.callee.kind == "MemberExpr" then
		local receiver = parent.evaluate(node.callee.object, env)
		local args, kwArgs = evaluateArgs()
		if receiver[2] == "instance" then
			local  -  Edit
  20:44:12.754  SOURCE| method = receiver[1].methods[node.callee.property]
			if not method then
				error("Method '" .. tostring(node.callee.property) .. "' not found on class")
			end
			local callArgs = { receiver }
			for i = 1, #args do
				callArgs[i + 1] = args[i]
			end
			return invoke_user_function(method, callArgs, env, kwArgs)
		end
		if next(kwArgs) ~= nil then
			error("Keyword arguments are not supported for this call")
		end
		local Methods = require(script.Parent.Parent.CollectionMethods)
		return Methods.dispatch(receiver, node.callee.property, args, env)
	end

	local calleeVal = parent.evaluate(node.callee, env)
	local args, kwArgs = evaluateArgs()

	if calleeVal[2] == "class" then
		local instance = Values.mkInstance(calleeVal)
		local init = calleeVal.methods.__init__ or calleeVal.methods.init
		if init then
			local initArgs = { instance }
			for i = 1, #args do
				initArgs[i + 1] = args[i]
			end
			invoke_user_function(init, initArgs, env, kwArgs)
		end
		return instance
	end

	if calleeVal[2] == "exception_type" then
		local message = args[1] and args[1][1] or ""
		return Values.mkException(calleeVal, tostring(message))
	end

	if not Values.isFunction(calleeVal) then
		error("Attempted to call non-function value")
	end

	if calleeVal[2] == "native_function" then
		if next(kwArgs) ~= nil then
			error("Keyword arguments are not supported for native functions")
		end
		return calleeVal.caller(args)
	end

	return invoke_user_function(calleeVal, args, env, kwArgs)
end

return {
	evaluate_binary_expr = evaluate_binary_expr,
	evaluate_identifier = evaluate_identifier,
	eval_number_binary_expr = eval_number_binary_expr,
	eval_comparison_expr = eval_comparison_expr,
	eval_string_concat_expr = eval_string_concat_expr,
	eval_fstring = eval_fstring,
	eval_unary_expr = eval_unary_expr,
	eval_assignment = eval_assignment,
	eval_call_expr = eval_call_expr,
	eval_member = eval_member,
	eval_index_expr = eval_index_expr,
	eval_table_literal = eval_table_literal,
	eval_list_comprehension = eval_list_comprehension,
	eval_dict_literal = eval_dict_literal,
}
  -  Edit
  20:44:12.754