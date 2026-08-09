  20:44:12.748  SOURCE|local module = {}

local OP = {
	LOAD_CONST = "LOAD_CONST",
	LOAD_NULL = "LOAD_NULL",
	LOAD_VAR = "LOAD_VAR",
	STORE_VAR = "STORE_VAR",
	DECLARE_VAR = "DECLARE_VAR",
	DECLARE_FN = "DECLARE_FN",
	BINARY_OP = "BINARY_OP",
	UNARY_OP = "UNARY_OP",
	LOAD_TABLE = "LOAD_TABLE",
	LOAD_DICT = "LOAD_DICT",
	CALL = "CALL",
	RETURN_JMP = "RETURN_JMP",
	IF_FALSE = "IF_FALSE",
	JUMP = "JUMP",
	HALT = "HALT",
}

module.OP = OP

local function newCompiler()
	return {
		instructions = {},
		constants = {},
		labels = {},
		patches = {},
	}
end

function module.addConstant(self, value)
	table.insert(self.constants, value)
	return #self.constants
end

function module.emit(self, opcode, operand)
	local instr = { opcode = opcode, operand = operand }
	table.insert(self.instructions, instr)
	return #self.instructions
end

function module.patchHere(self, address)
	self.instructions[address].operand = #self.instructions + 1
end

function module.compile(self, ast, env)
	if ast.kind == "Program" then
		module.compileProgram(self, ast, env)
	elseif ast.kind == "NumericLiteral" then
		module.compileNumericLiteral(self, ast, env)
	elseif ast.kind == "StringLiteral" then
		module.compileStringLiteral(self, ast, env)
	elseif ast.kind == "NullLiteral" then
		module.compileNullLiteral(self, ast, env)
	elseif ast.kind == "Identifier" then
		module.compileIdentifier(self, ast, env)
	elseif ast.kind == "AssignmentExpr" then
		module.compileAssignment(self, ast, env)
	elseif ast.kind == "BinaryExpr" then
		module.compileBinaryExpr(self, ast, env)
	elseif ast.kind == "UnaryExpr" then
		module.compileUnaryExpr(self, ast, env)
	elseif ast.kind == "CallExpr" then
		module.compileCallExpr(self, ast, env)
	elseif ast.kind == "TableLiteral" then
		module.compileTableLiteral(self, ast, env)
	elseif ast.kind == "DictLiteral" then
		module.compileDictLiteral(self, ast, env)
	elseif ast.kind == "FunctionDeclaration" then
		module.compileFunctionDeclaration(self, ast, env)
	elseif ast.kind == "IfStatement" then
		module.compileIfStatement(self, ast, env)
	elseif ast.kind == "ReturnStmt" then
		module.compileReturn(self, ast, env)
	end
end

function module.compileProgram(self, ast, env)
	for _, stmt in ipairs(ast.body) do
		module.compile(self, stmt, env)
	end
	module.emit(self, OP.HALT, nil)
end

function module.compileNumericLiteral(self, ast, env)
	local idx = module.addConstant(self, ast.value)
	module.emit(self, OP.LOAD_CONST, idx)
end

function module.compileStringLiteral(self, ast, env)
	local idx = module.addConstant(self, ast.value)
	module.emit(self, OP.LOAD_CONST, idx)
end

function module.compileNullLiteral(self, ast, env)
	module.emit(self, OP.LOAD_NULL, nil)
end

function module.compileIdentifier(self, ast, env)
	module.emit(self, OP.LOAD_VAR, ast.symbol)
end

function module.compileAssignment(self, ast, env)
	module.compile(self, ast.value, env)
	if ast.assigne.kind == "Identifier" then
		module.emit(self, OP.STORE_VAR, ast.assigne.symbol)
	end
end

function module.compileBinaryExpr(self, ast, env)
	module.compile(self, ast.left, env)
	module.compile(self, ast.right, env)
	module.emit(self, OP.BINARY_OP, ast.operator)
end

function module.compileUnaryExpr(self, ast, env)
	module.compile(self, ast.operand, env)
	module.emit(self, OP.UNARY_OP, ast.operator)
end

function module.compileCallExpr(self, ast, env)
	module.compile(self, ast.callee, env)
	local argCount = 0
	if ast.args then
		argCount = #ast.args
		for _, arg in ipairs(ast.args) do
			module.compile(self, arg, env)
		end
	end
	module.emit(self, OP.CALL, argCount)
end

function module.compileTableLiteral(self, ast, env)
	local count = #ast.list
	for _, item in ipairs(ast.list) do
		module.compile(self, item, env)
	end
	module.emit(self, OP.LOAD_TABLE, count)
end

function module.compileDictLiteral(self, ast, env)
	local count = #ast.entries
	for _, entry in ipairs  -  Edit
  20:44:12.748  SOURCE|(ast.entries) do
		module.compile(self, entry[1], env)
		module.compile(self, entry[2], env)
	end
	module.emit(self, OP.LOAD_DICT, count)
end

function module.compileFunctionDeclaration(self, ast, env)
	local subCompiler = newCompiler()
	for _, stmt in ipairs(ast.body) do
		module.compile(subCompiler, stmt, env)
	end
	local fnData = {
		name = ast.name,
		params = ast.parameters,
		bytecode = subCompiler.instructions,
		constants = subCompiler.constants,
	}
	local fnIdx = module.addConstant(self, fnData)
	module.emit(self, OP.DECLARE_FN, fnIdx)
end

function module.compileIfStatement(self, ast, env)
	module.compile(self, ast.conditions[1], env)
	local ifFalseJumps = {}
	module.emit(self, OP.IF_FALSE, nil)
	table.insert(ifFalseJumps, #self.instructions)

	for _, stmt in ipairs(ast.bodies[1]) do
		module.compile(self, stmt, env)
	end
	local exitJump = #self.instructions + 1
	module.emit(self, OP.JUMP, nil)
	module.patchHere(self, ifFalseJumps[1])

	for i = 2, #ast.conditions do
		local condition = ast.conditions[i]
		if condition.kind == "ElseCondition" then
			module.patchHere(self, exitJump)
			for _, stmt in ipairs(ast.bodies[i]) do
				module.compile(self, stmt, env)
			end
		else
			module.compile(self, condition, env)
			table.insert(ifFalseJumps, #self.instructions + 1)
			module.emit(self, OP.IF_FALSE, nil)
			for _, stmt in ipairs(ast.bodies[i]) do
				module.compile(self, stmt, env)
			end
			exitJump = #self.instructions + 1
			module.emit(self, OP.JUMP, nil)
			module.patchHere(self, ifFalseJumps[#ifFalseJumps])
		end
	end

	if #ifFalseJumps > 0 then
		module.patchHere(self, exitJump)
	end
end

function module.compileReturn(self, ast, env)
	module.compile(self, ast.value, env)
	module.emit(self, OP.RETURN_JMP, nil)
end

function module.compileSource(sourceCode)
	local Parser = require(script.Parent.parser)
	local parser = Parser.new()
	local ast = parser:ProduceAST(sourceCode)
	local self = newCompiler()
	module.compileProgram(self, ast, nil)
	return {
		instructions = self.instructions,
		constants = self.constants,
	}
end

return {
	new = newCompiler,
	addConstant = module.addConstant,
	emit = module.emit,
	patchHere = module.patchHere,
	compile = module.compile,
	compileProgram = module.compileProgram,
	compileNumericLiteral = module.compileNumericLiteral,
	compileStringLiteral = module.compileStringLiteral,
	compileNullLiteral = module.compileNullLiteral,
	compileIdentifier = module.compileIdentifier,
	compileAssignment = module.compileAssignment,
	compileBinaryExpr = module.compileBinaryExpr,
	compileUnaryExpr = module.compileUnaryExpr,
	compileCallExpr = module.compileCallExpr,
	compileTableLiteral = module.compileTableLiteral,
	compileDictLiteral = module.compileDictLiteral,
	compileFunctionDeclaration = module.compileFunctionDeclaration,
	compileIfStatement = module.compileIfStatement,
	compileReturn = module.compileReturn,
	compileSource = module.compileSource,
	OP = OP,
}
  -  Edit
  20:44:12.748