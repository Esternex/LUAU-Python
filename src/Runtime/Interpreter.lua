  15:36:08.050  SOURCE|local module = {}
local Values = require(script.Parent.Values)
local Environment = require(script.Parent.Environment)

local evalFolder = script.Parent.eval
local Compiler = require(script.Parent.Parent.compiler)
local OP = Compiler.OP

local function getEvalExpression()
	return require(evalFolder.Expressions)
end

local function getEvalStatements()
	return require(evalFolder.Statements)
end

function module.evaluate(astNode, env)
	if astNode.kind == "NumericLiteral" then
		return { astNode.value, "number" }
	elseif astNode.kind == "StringLiteral" then
		return Values.mkString(astNode.value)
	elseif astNode.kind == "FStringLiteral" then
		return getEvalExpression().eval_fstring(astNode, env)
	elseif astNode.kind == "NullLiteral" then
		return Values.mkNull()
	elseif astNode.kind == "TableLiteral" then
		return getEvalExpression().eval_table_literal(astNode, env)
	elseif astNode.kind == "ListComprehension" then
		return getEvalExpression().eval_list_comprehension(astNode, env)
	elseif astNode.kind == "DictLiteral" then
		return getEvalExpression().eval_dict_literal(astNode, env)
	elseif astNode.kind == "TupleLiteral" then
		return getEvalExpression().eval_tuple_literal(astNode, env)
	elseif astNode.kind == "IndexExpr" then
		return getEvalExpression().eval_index_expr(astNode, env)
	elseif astNode.kind == "Identifier" then
		return getEvalExpression().evaluate_identifier(astNode, env)
	elseif astNode.kind == "BinaryExpr" then
		return getEvalExpression().evaluate_binary_expr(astNode, env)
	elseif astNode.kind == "UnaryExpr" then
		return getEvalExpression().eval_unary_expr(astNode, env)
	elseif astNode.kind == "VarDeclaration" then
		return getEvalStatements().eval_var_declaration(astNode, env)
	elseif astNode.kind == "Program" then
		return getEvalStatements().eval_program(astNode, env)
	elseif astNode.kind == "AssignmentExpr" then
		return getEvalExpression().eval_assignment(astNode, env)
	elseif astNode.kind == "FunctionDeclaration" then
		return getEvalStatements().eval_function_declaration(astNode, env)
	elseif astNode.kind == "CallExpr" then
		return getEvalExpression().eval_call_expr(astNode, env)
	elseif astNode.kind == "ReturnStmt" then
		return { __isReturn = true, retval = astNode.value and module.evaluate(astNode.value, env) or Values.mkNull() }
	elseif astNode.kind == "WhileStatement" then
		return getEvalStatements().eval_while_statement(astNode, env)
	elseif astNode.kind == "BreakStmt" then
		if (env.loopDepth or 0) == 0 then
			error("Cannot use 'break' outside of a loop")
		end
		error({ __pb_break = true })
	elseif astNode.kind == "ContinueStmt" then
		if (env.loopDepth or 0) == 0 then
			error("Cannot use 'continue' outside of a loop")
		end
		error({ __pb_continue = true })
	elseif astNode.kind == "PassStmt" then
		return Values.mkNull()
	elseif astNode.kind == "IfStatement" then
		return getEvalStatements().eval_if_statement(astNode, env)
	elseif astNode.kind == "ForStatement" then
		return getEvalStatements().eval_for_statement(astNode, env)
	elseif astNode.kind == "RaiseStmt" then
		return getEvalStatements().eval_raise_statement(astNode, env)
	elseif astNode.kind == "TryStatement" then
		return getEvalStatements().eval_try_statement(astNode, env)
	elseif astNode.kind == "GlobalStmt" then
		return getEvalStatements().eval_global_statement(astNode, env)
	elseif astNode.kind == "ImportStmt" then
		return getEvalStatements().eval_import_statement(astNode, env)
	elseif astNode.kind == "ClassDeclaration" then
		return getEvalStatements().eval_class_declaration(astNode, env)
	elseif astNode.kind == "MemberExpr" then
		return getEvalExpression().eval_member(astNode, env)
	else
		return Values.mkNull()
	end
end


function module.runBytecode(bytecode, env)
	local instructions = bytecode.instructions
	local constants = bytecode.constants
	local stack = {}
	
	local i = 1
	while i <= #instructions do
		local instr = instruc  -  Edit
  15:36:08.050  SOURCE|tions[i]
		local op = instr.opcode
		local operand = instr.operand
		
		if op == OP.LOAD_CONST then
			local val = constants[operand]
			if type(val) == "table" and val.bytecode then
				stack[#stack + 1] = Values.mkFunction(val.name, val.params, val.bytecode)
			else
				stack[#stack + 1] = val
			end
		elseif op == OP.LOAD_NULL then
			stack[#stack + 1] = Values.mkNull()
		elseif op == OP.LOAD_VAR then
			stack[#stack + 1] = env:LookupVar(operand)
		elseif op == OP.STORE_VAR then
			local val = stack[#stack]
			stack[#stack] = nil
			env:AssignVar(operand, val)
		elseif op == OP.ASSIGN_VAR then

		elseif op == OP.DECLARE_VAR then
			local val = stack[#stack]
			stack[#stack] = nil
			local name = operand.name
			local constant = operand.constant
			env:DeclareVar(name, val, constant)
		elseif op == OP.DECLARE_FN then
			local fnData = constants[operand]
			local fnVal = Values.mkNativeFunction(fnData.name, function(args)
				local funcEnv = Environment.new(env)
				for idx, param in ipairs(fnData.params or {}) do
					funcEnv:DeclareVar(param, args[idx] or Values.mkNull(), false)
				end
				return module.runBytecode({
					instructions = fnData.bytecode,
					constants = fnData.constants
				}, funcEnv)
			end)
			env:DeclareVar(fnData.name, fnVal, fnData.constant or false)
		elseif op == OP.BINARY_OP then
			local rhs = stack[#stack]
			stack[#stack] = nil
			local lhs = stack[#stack]
			stack[#stack] = nil
			
			if operand == "+" then
				if lhs[2] == "string" or rhs[2] == "string" then
					stack[#stack + 1] = Values.mkString(tostring(lhs[1]) .. tostring(rhs[1]))
				elseif lhs[2] == "number" and rhs[2] == "number" then
					stack[#stack + 1] = Values.mkNumber(lhs[1] + rhs[1])
				end
			elseif operand == "-" then
				stack[#stack + 1] = Values.mkNumber(lhs[1] - rhs[1])
			elseif operand == "*" then
				stack[#stack + 1] = Values.mkNumber(lhs[1] * rhs[1])
			elseif operand == "/" then
				stack[#stack + 1] = Values.mkNumber(lhs[1] / rhs[1])
			elseif operand == "%" then
				stack[#stack + 1] = Values.mkNumber(lhs[1] % rhs[1])
			elseif operand == "==" then
				stack[#stack + 1] = Values.mkBool(lhs[1] == rhs[1])
			elseif operand == "!=" then
				stack[#stack + 1] = Values.mkBool(lhs[1] ~= rhs[1])
			elseif operand == "<" then
				stack[#stack + 1] = Values.mkBool(lhs[1] < rhs[1])
			elseif operand == ">" then
				stack[#stack + 1] = Values.mkBool(lhs[1] > rhs[1])
			elseif operand == "<=" then
				stack[#stack + 1] = Values.mkBool(lhs[1] <= rhs[1])
			elseif operand == ">=" then
				stack[#stack + 1] = Values.mkBool(lhs[1] >= rhs[1])
			end
		elseif op == OP.UNARY_OP then
			local val = stack[#stack]
			stack[#stack] = nil
			if operand == "-" then
				stack[#stack + 1] = Values.mkNumber(-val[1])
			elseif operand == "!" then
				stack[#stack + 1] = Values.mkBool(not Values.isTruthy(val))
			end
		elseif op == OP.CALL then
			local argCount = operand
			local args = {}
			for j = argCount, 1, -1 do
				args[j] = stack[#stack]
				stack[#stack] = nil
			end
			local callee = stack[#stack]
			stack[#stack] = nil
			
			if callee[2] == "native_function" then
				stack[#stack + 1] = callee.caller(args)
			elseif callee[2] == "function" then
				local funcEnv = Environment.new(env)
				local params = callee.params or {}
				for idx, param in ipairs(params) do
					funcEnv:DeclareVar(param, args[idx] or Values.mkNull(), false)
				end
				local result = Values.mkNull()
				for _, stmt in ipairs(callee.body) do
					local stmtResult = module.evaluate(stmt, funcEnv)
					if type(stmtResult) == "table" and stmtResult.__isReturn then
						result = stmtResult.retval
						break
					end
				end
				stack[#stack + 1] = result
			end
		elseif op == OP.LOAD_TABLE then
			local count = operand
			local items = {}
			for j = count, 1, -1 do
				items[j] = stack[#stack]
				stack[#stack] = nil
			end
			stack[#stack + 1]   -  Edit
  15:36:08.050  SOURCE|= Values.mkTable(items)
		elseif op == OP.LOAD_DICT then
			local count = operand
			local dict = {}
			for _ = 1, count do
				local value = stack[#stack]
				stack[#stack] = nil
				local key = stack[#stack]
				stack[#stack] = nil
				dict[key[1]] = value
			end
			stack[#stack + 1] = Values.mkDict(dict)
		elseif op == OP.IF_FALSE then
			local val = stack[#stack]
			stack[#stack] = nil
			if not Values.isTruthy(val) then
				i = operand - 1
			end
		elseif op == OP.JUMP then
			i = operand - 1
		elseif op == OP.RETURN_JMP then
			local val = stack[#stack]
			stack[#stack] = nil
			return { __isReturn = true, retval = val }
		elseif op == OP.HALT then
			break
		end
		
		i = i + 1
	end
	if #stack > 0 then
		return stack[#stack]
	end
	return Values.mkNull()
end

return module
  -  Edit
  15:36:08.050