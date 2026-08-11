  15:36:08.042  SOURCE|local module = {}
local Dependencies = script.Parent.Dependencies
local Types = require(Dependencies.Types)
local AST = require(Dependencies.AST)
local lexer = require(script.Parent.lexer)
local tokenize = lexer.Tokenize
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	self.tokens = {}
	self.pos = 1
	return self
end

function module:at()
	return self.tokens[self.pos]
end

function module:eat()
	local prev = self.tokens[self.pos]
	self.pos = self.pos + 1
	return prev
end

function module:expect(tokenType, err)
	local prev = self:eat()
	if not prev or prev[2] ~= tokenType then
		error("Parser error\
"..err.."\
 Expected: "..tokenType.." got: "..tostring(prev and prev[2]))
	end
	return prev
end

function module:not_eof()
	local tk = self:at()
	return tk ~= nil and tk[2] ~= "EOF"
end

function module:skip_trivia()
	while self:at() and (self:at()[2] == "Newline" or self:at()[2] == "Indent" or self:at()[2] == "Dedent") do
		self:eat()
	end
end

local COMPOUND_OPS = {
	["PlusEquals"] = "+",
	["MinusEquals"] = "-",
	["MultiplyEquals"] = "*",
	["DivideEquals"] = "/",
	["ModuloEquals"] = "%",
}

function module:parse_stmt()
	local tk = self:at()
	if tk and tk[2] == "Define" then
		return self:parse_function_declaration()
	end
	if tk and tk[2] == "If" then
		return self:parse_if_statement()
	end
	if tk and tk[2] == "For" then
		return self:parse_for_statement()
	end
	if tk and tk[2] == "While" then
		return self:parse_while_statement()
	end
	if tk and tk[2] == "Global" then
		return self:parse_global_statement()
	end
	if tk and tk[2] == "Import" then
		return self:parse_import_statement()
	end
	if tk and tk[2] == "Break" then
		self:eat()
		return { kind = "BreakStmt" }
	end
	if tk and tk[2] == "Try" then
		return self:parse_try_statement()
	end
	if tk and tk[2] == "Raise" then
		return self:parse_raise_statement()
	end
	if tk and tk[2] == "Continue" then
		self:eat()
		return { kind = "ContinueStmt" }
	end
	if tk and tk[1] == "pass" then
		self:eat()
		return { kind = "PassStmt" }
	end
	if tk and tk[2] == "Class" then
		return self:parse_class_declaration()
	end
	if tk and tk[1] == "return" then
		self:eat()
		local value = nil
		if self:not_eof() and self:at()[2] ~= "Newline" and self:at()[2] ~= "Dedent" then
			value = self:parse_expr()
		end
		return { kind = "ReturnStmt", value = value }
	end
	local expr = self:parse_expr()
	return expr
end

function module:parse_function_declaration()
	self:eat()
	local name = self:expect("Identifier", "Expected function name after 'def'")[1]
	self:expect("OpenParen", "Expected '(' after function name")
	local params = {}
	if self:at()[2] ~= "CloseParen" then
		table.insert(params, self:expect("Identifier", "Expected parameter name")[1])
		if self:at() and self:at()[2] == "Colon" then
			self:eat()
			self:expect("Identifier", "Expected type annotation after ':'")
		end
		while self:at()[1] == "," do
			self:eat()
			table.insert(params, self:expect("Identifier", "Expected parameter name")[1])
			if self:at() and self:at()[2] == "Colon" then
				self:eat()
				self:expect("Identifier", "Expected type annotation after ':'")
			end
		end
	end
	self:expect("CloseParen", "Expected ')' after function parameters")
	self:expect("Colon", "Expected ':' after function signature")
	self:expect("Newline", "Expected newline after function declaration")
	self:expect("Indent", "Expected indented function body")
	local body = {}
	while self:at() and self:at()[2] ~= "Dedent" and self:at()[2] ~= "EOF" do
		local stmt = self:parse_stmt()
		if stmt then
			table.insert(body, stmt)
		end
		if self:at() and self:at()[2] == "Newline" then
			self:eat()
		end
	end
	if self:at() and self:at()[2] == "Dedent" then
		self:eat()
	end
	return {
		kind = "FunctionDeclaration",
		name = name,
		parameters = params,
		body = body
	}
end

functi  -  Edit
  15:36:08.042  SOURCE|on module:parse_global_statement()
	self:eat()
	local names = { self:expect("Identifier", "Expected a variable name after 'global'")[1] }
	while self:at()[1] == "," do
		self:eat()
		table.insert(names, self:expect("Identifier", "Expected a variable name after ','")[1])
	end
	return { kind = "GlobalStmt", names = names }
end

function module:parse_import_statement()
	self:eat()
	local name = self:expect("Identifier", "Expected a library name after 'import'")[1]
	local rtVal = { kind = "ImportStmt", name = name }
	if self:at() and self:at()[2] ~= "Newline" and self:at()[2] ~= "EOF" then
		self:expect("Identifier", "Expected 'as' or new line after import")
		rtVal["specialName"] = self:at()[1]
	end
	return rtVal
end

function module:parse_while_statement()
	self:eat()
	local condition = self:parse_expr()
	self:expect("Colon", "Expected ':' after while condition")
	self:expect("Newline", "Expected newline after while condition")
	self:expect("Indent", "Expected indented while body")
	local body = {}
	while self:at() and self:at()[2] ~= "Dedent" and self:at()[2] ~= "EOF" do
		local stmt = self:parse_stmt()
		if stmt then
			table.insert(body, stmt)
		end
		if self:at() and self:at()[2] == "Newline" then
			self:eat()
		end
	end
	if self:at() and self:at()[2] == "Dedent" then
		self:eat()
	end
	return {
		kind = "WhileStatement",
		condition = condition,
		body = body,
	}
end

function module:parse_for_statement()
	self:eat()
	local variable = self:expect("Identifier", "Expected a variable name after 'for'")[1]
	self:expect("In", "Expected 'in' after the loop variable")
	local iterable = self:parse_expr()
	self:expect("Colon", "Expected ':' after the for loop condition")
	self:expect("Newline", "Expected newline after the for loop condition")
	self:expect("Indent", "Expected indented for loop body")
	local body = {}
	while self:at() and self:at()[2] ~= "Dedent" and self:at()[2] ~= "EOF" do
		local stmt = self:parse_stmt()
		if stmt then
			table.insert(body, stmt)
		end
		if self:at() and self:at()[2] == "Newline" then
			self:eat()
		end
	end
	if self:at() and self:at()[2] == "Dedent" then
		self:eat()
	end
	return {
		kind = "ForStatement",
		variable = variable,
		iterable = iterable,
		body = body,
	}
end

function module:parse_if_statement()
	self:eat()
	local condition = self:parse_expr()
	self:expect("Colon", "Expected ':' after if condition")
	local conditions = {condition}
	local bodies = {}
	self:expect("Newline", "Expected newline after if condition")
	self:expect("Indent", "Expected indented if body")
	local ifBody = {}
	while self:at() and self:at()[2] ~= "Dedent" and self:at()[2] ~= "EOF" do
		local stmt = self:parse_stmt()
		if stmt then
			table.insert(ifBody, stmt)
		end
		if self:at() and self:at()[2] == "Newline" then
			self:eat()
		end
	end
	if self:at() and self:at()[2] == "Dedent" then
		self:eat()
	end
	table.insert(bodies, ifBody)
	while self:at() and (self:at()[2] == "Elif" or self:at()[2] == "Else") do
		if self:at()[2] == "Elif" then
			self:eat()
			local elifCond = self:parse_expr()
			self:expect("Colon", "Expected ':' after elif condition")
			self:expect("Newline", "Expected newline after elif condition")
			self:expect("Indent", "Expected indented elif body")
			local elifBody = {}
			while self:at() and self:at()[2] ~= "Dedent" and self:at()[2] ~= "EOF" do
				local stmt = self:parse_stmt()
				if stmt then
					table.insert(elifBody, stmt)
				end
				if self:at() and self:at()[2] == "Newline" then
					self:eat()
				end
			end
			if self:at() and self:at()[2] == "Dedent" then
				self:eat()
			end
			table.insert(conditions, elifCond)
			table.insert(bodies, elifBody)
		elseif self:at()[2] == "Else" then
			self:eat()
			self:expect("Colon", "Expected ':' after else")
			self:expect("Newline", "Expected newline after else")
			self:expect("Indent", "Expected indented else   -  Edit
  15:36:08.042  SOURCE|body")
			local elseBody = {}
			while self:at() and self:at()[2] ~= "Dedent" and self:at()[2] ~= "EOF" do
				local stmt = self:parse_stmt()
				if stmt then
					table.insert(elseBody, stmt)
				end
				if self:at() and self:at()[2] == "Newline" then
					self:eat()
				end
			end
			if self:at() and self:at()[2] == "Dedent" then
				self:eat()
			end
			table.insert(conditions, {kind = "ElseCondition"})
			table.insert(bodies, elseBody)
		end
	end
	return {
		kind = "IfStatement",
		conditions = conditions,
		bodies = bodies,
	}
end

function module:parse_call_expr(callee)
	self:expect("OpenParen", "Expected '(' after identifier for function call")
	local args = {}
	if self:at()[2] ~= "CloseParen" then
		local nxt = self.tokens[self.pos + 1]
		if self:at()[2] == "Identifier" and nxt and nxt[2] == "Equals" then
			local kwName = self:eat()[1]
			self:eat()
			table.insert(args, { kind = "KeywordArgument", name = kwName, value = self:parse_expr() })
		else
			table.insert(args, self:parse_expr())
		end
		while self:at()[1] == "," do
			self:eat()
			local nx = self.tokens[self.pos + 1]
			if self:at()[2] == "Identifier" and nx and nx[2] == "Equals" then
				local kwName = self:eat()[1]
				self:eat()
				table.insert(args, { kind = "KeywordArgument", name = kwName, value = self:parse_expr() })
			else
				table.insert(args, self:parse_expr())
			end
		end
	end
	self:expect("CloseParen", "Expected ')' after function arguments")
	return { kind = "CallExpr", callee = callee, args = args }
end

function module:parse_class_declaration()
	self:eat()
	local name = self:expect("Identifier", "Expected class name after 'class'")[1]
	self:expect("Colon", "Expected ':' after class name")
	self:expect("Newline", "Expected newline after class declaration")
	self:expect("Indent", "Expected indented class body")
	local methods = {}
	while self:at() and self:at()[2] ~= "Dedent" and self:at()[2] ~= "EOF" do
		local stmt = self:parse_stmt()
		if stmt then
			table.insert(methods, stmt)
		end
		if self:at() and self:at()[2] == "Newline" then
			self:eat()
		end
	end
	if self:at() and self:at()[2] == "Dedent" then
		self:eat()
	end
	return {
		kind = "ClassDeclaration",
		name = name,
		methods = methods,
	}
end

function module:parse_indented_block(expectErr)
	self:expect("Colon", expectErr)
	self:expect("Newline", "Expected newline after " .. expectErr)
	self:expect("Indent", "Expected indented block")
	local body = {}
	while self:at() and self:at()[2] ~= "Dedent" and self:at()[2] ~= "EOF" do
		local stmt = self:parse_stmt()
		if stmt then
			table.insert(body, stmt)
		end
		if self:at() and self:at()[2] == "Newline" then
			self:eat()
		end
	end
	if self:at() and self:at()[2] == "Dedent" then
		self:eat()
	end
	return body
end

function module:parse_raise_statement()
	self:eat()
	local value = nil
	if self:not_eof() and self:at()[2] ~= "Newline" and self:at()[2] ~= "Dedent" then
		value = self:parse_expr()
	end
	return { kind = "RaiseStmt", value = value }
end

function module:parse_try_statement()
	self:eat()
	local body = self:parse_indented_block("'try'")

	local handlers = {}
	while self:at() and self:at()[2] == "Except" do
		self:eat()
		local excType = nil
		if self:at()[2] ~= "Colon" and self:at()[2] ~= "As" then
			local ident = self:expect("Identifier", "Expected exception type after 'except'")[1]
			excType = { kind = "Identifier", symbol = ident }
			while self:at()[1] == "." do
				self:eat()
				local prop = self:expect("Identifier", "Expected property name after '.'")[1]
				excType = { kind = "MemberExpr", object = excType, property = prop }
			end
		end
		local name
		if self:at() and self:at()[2] == "As" then
			self:eat()
			name = self:expect("Identifier", "Expected variable name after 'as'")[1]
		end
		local handlerBody = self:parse_indented_block("'except' clause")
		table.insert(handlers, { ex  -  Edit
  15:36:08.045  SOURCE|cType = excType, name = name, body = handlerBody })
	end

	local elseBody
	if self:at() and self:at()[2] == "Else" then
		self:eat()
		elseBody = self:parse_indented_block("'else'")
	end

	local finallyBody
	if self:at() and self:at()[2] == "Finally" then
		self:eat()
		finallyBody = self:parse_indented_block("'finally'")
	end

	return {
		kind = "TryStatement",
		body = body,
		handlers = handlers,
		elseBody = elseBody,
		finallyBody = finallyBody,
	}
end

function module:parse_postfix(expr)
	while self:at() and (self:at()[1] == "." or self:at()[1] == "(" or self:at()[1] == "[" or self:at()[1] == ":") do
		local tk = self:at()
		if tk[1] == "." then
			self:eat()
			local property = self:expect("Identifier", "Expected a property name after '.'")[1]
			expr = { kind = "MemberExpr", object = expr, property = property }
		elseif tk[1] == "(" then
			expr = self:parse_call_expr(expr)
		elseif tk[1] == "[" then
			self:eat()
			local index = self:parse_expr()
			self:expect("CloseBracket", "Expected ']' after index expression")
			expr = { kind = "IndexExpr", object = expr, index = index }
		elseif tk[1] == ":" then
			local nxt = self.tokens[self.pos + 1]
			local after = self.tokens[self.pos + 2]
			if nxt and nxt[2] == "Identifier" and after and after[2] == "OpenParen" then
				self:eat()
				local property = self:expect("Identifier", "Expected a method name after ':'")[1]
				expr = self:parse_call_expr({ kind = "MemberExpr", object = expr, property = property })
			else
				break
			end
		end
	end
	return expr
end
function module:parse_table_literal()
	self:eat()
	local items = {}
	self:skip_trivia()
	if self:at()[2] ~= "CloseBracket" then
		local first = self:parse_expr()
		self:skip_trivia()
		if self:at() and self:at()[2] == "For" then
			local clauses = {}
			while self:at() and self:at()[2] == "For" do
				self:eat()
				local variable = self:expect("Identifier", "Expected loop variable in comprehension")[1]
				self:expect("In", "Expected 'in' in comprehension")
				local iterable = self:parse_expr()
				local filter
				if self:at() and self:at()[2] == "If" then
					self:eat()
					filter = self:parse_expr()
				end
				table.insert(clauses, { variable = variable, iterable = iterable, filter = filter })
			end
			self:expect("CloseBracket", "Expected ']' after list comprehension")
			return { kind = "ListComprehension", value = first, clauses = clauses }
		end
		table.insert(items, first)
		self:skip_trivia()
		while self:at()[1] == "," do
			self:eat()
			self:skip_trivia()
			if self:at()[2] == "CloseBracket" then
				break
			end
			table.insert(items, self:parse_expr())
			self:skip_trivia()
		end
	end
	self:expect("CloseBracket", "Expected ']' after table literal")
	return { kind = "TableLiteral", list = items }
end

function module:parse_dict_literal()
	self:eat()
	local entries = {}
	self:skip_trivia()
	while self:at()[2] ~= "CloseCurly" do
		local key = self:parse_expr()
		self:skip_trivia()
		self:expect("Colon", "Expected ':' between dictionary key and value")
		local value = self:parse_expr()
		table.insert(entries, { key, value })
		self:skip_trivia()
		if self:at()[1] == "," then
			self:eat()
			self:skip_trivia()
		else
			break
		end
	end
	self:expect("CloseCurly", "Expected '}' after dictionary literal")
	return { kind = "DictLiteral", entries = entries }
end

function module:parse_comparison_expr()
	local left = self:parse_additive_expr()
	if self:at() and self:at()[2] == "Compare" then
		local operator = self:eat()[1]
		local right = self:parse_additive_expr()
		return {
			kind = "BinaryExpr",
			left = left,
			right = right,
			operator = operator
		}
	end
	return left
end

function module:parse_primary_expr()
	local tk = self:at()[2]
	if tk == "BinaryOperator" or tk == "Not" then
		local operator = self:eat()[1]
		if operator == "not" then
			operator = "!"
		en  -  Edit
  15:36:08.045  SOURCE|d
		local operand = self:parse_primary_expr()
		return {
			kind = "UnaryExpr",
			operator = operator,
			operand = operand
		}
	end
	if tk == "Identifier" then
		local identifierNode = {kind = "Identifier", symbol = self:eat()[1]}
		return self:parse_postfix(identifierNode)
	elseif tk == "Number" then
		return self:parse_postfix({kind = "NumericLiteral", value = tonumber(self:eat()[1])})
	elseif tk == "String" then
		return self:parse_postfix({kind = "StringLiteral", value = self:eat()[1]})
	elseif tk == "FString" then
		local parts = self:eat()[1]
		return self:parse_postfix({ kind = "FStringLiteral", parts = parts })
	elseif tk == "Null" then
		self:eat()
		return self:parse_postfix({kind = "NullLiteral", value = "null"})
	elseif tk == "OpenParen" then
		self:eat()
		local first = self:parse_expr()
		if self:at() and self:at()[2] == "Comma" then
			local items = { first }
			while self:at() and self:at()[2] == "Comma" do
				self:eat()
				table.insert(items, self:parse_expr())
			end
			self:expect("CloseParen", "Parser expected ')' to close tuple literal")
			return self:parse_postfix({ kind = "TupleLiteral", items = items })
		end
		self:expect("CloseParen", "Parser expected a closing parenthesis")
		return self:parse_postfix(first)
	elseif tk == "OpenBracket" then
		return self:parse_postfix(self:parse_table_literal())
	elseif tk == "OpenCurly" then
		return self:parse_postfix(self:parse_dict_literal())
	else
		warn("Unknown expression, " .. tostring(self:at()[1]) .. " " .. self:at()[2])
		self:eat()
		return {}
	end
end

function module:parse_power_expr()
	local left = self:parse_primary_expr()
	if self:at() and self:at()[2] == "Power" then
		self:eat()
		local right = self:parse_power_expr()
		return {
			kind = "BinaryExpr",
			left = left,
			right = right,
			operator = "**",
		}
	end
	return left
end

function module:parse_multiplicative_expr()
	local left = self:parse_power_expr()
	while self:at() and (self:at()[1] == "/" or self:at()[1] == "*" or self:at()[1] == "%") do
		local operator = self:eat()[1]
		local right = self:parse_power_expr()
		left = {
			kind = "BinaryExpr",
			left = left,
			right = right,
			operator = operator
		}
	end
	return left
end

function module:parse_additive_expr()
	local left = self:parse_multiplicative_expr()
	while self:at() and (self:at()[1] == "+" or self:at()[1] == "-" or self:at()[1] == "..") do
		local operator = self:eat()[1]
		local right = self:parse_multiplicative_expr()
		left = {
			kind = "BinaryExpr",
			left = left,
			right = right,
			operator = operator
		}
	end
	return left
end

function module:parse_or_expr()
	local left = self:parse_and_expr()
	while self:at() and self:at()[2] == "Or" do
		local operator = self:eat()[1]
		local right = self:parse_and_expr()
		left = {
			kind = "BinaryExpr",
			left = left,
			right = right,
			operator = operator
		}
	end
	return left
end

function module:parse_and_expr()
	local left = self:parse_comparison_expr()
	while self:at() and self:at()[2] == "And" do
		local operator = self:eat()[1]
		local right = self:parse_comparison_expr()
		left = {
			kind = "BinaryExpr",
			left = left,
			right = right,
			operator = operator
		}
	end
	return left
end

function module:parse_assignment_expr()
	local left = self:parse_or_expr()
	local compoundOp = COMPOUND_OPS[self:at() and self:at()[2]]
	if compoundOp then
		self:eat()
		local right = self:parse_assignment_expr()
		return {
			kind = "AssignmentExpr",
			assigne = left,
			value = {
				kind = "BinaryExpr",
				left = left,
				right = right,
				operator = compoundOp
			}
		}
	end
	if self:at()[2] == "Equals" then
		self:eat()
		local right = self:parse_assignment_expr()
		return { kind = "AssignmentExpr", assigne = left, value = right }
	end
	return left
end

function module:parse_expr()
	return self:parse_assignment_expr()
end  -  Edit
  15:36:08.045  SOURCE|

function module:ProduceAST(sourceCode)
	self.tokens = tokenize(sourceCode)
	self.pos = 1
	local program = {
		kind = "Program",
		body = {},
	}
	while (self:not_eof()) do
		if self:at()[2] == "Newline" then
			self:eat()
		elseif self:at()[2] == "Dedent" then
			self:eat()
		else
			local stmt = self:parse_stmt()
			if stmt and stmt.kind then
				table.insert(program.body, stmt)
			end
			if self:at() and self:at()[2] == "Newline" then
				self:eat()
			end
		end
	end
	return program
end

return module
  -  Edit
  15:36:08.045