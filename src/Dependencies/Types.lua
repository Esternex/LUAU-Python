  15:36:08.048  SOURCE|local module = {}

export type TokenType = {
	Null: nil,
	Number: string,
	String: string,
	Identifier: string,
	Equals: string,
	Compare: string,
	PlusEquals: string,
	MinusEquals: string,
	MultiplyEquals: string,
	DivideEquals: string,
	ModuloEquals: string,
	OpenParen: string,
	CloseParen: string,
	OpenBracket: string,
	CloseBracket: string,
	OpenCurly: string,
	CloseCurly: string,
	BinaryOperator: string,
	Semicolon: string,
	Colon: string,
	Comma: string,
	Define: string,
	If: string,
	Elif: string,
	Else: string,
	For: string,
	In: string,
	Global: string,
	Indent: string,
	Dedent: string,
	Newline: string,
	EOF: string,
}

export type Token = {
	value: string,
	type: TokenType
}

export type NodeType = 
	"Program"
	| "VarDeclaration"
	| "NumericLiteral"
	| "StringLiteral"
	| "Identifier"
	| "AssignmentExpr"
	| "NullLiteral"
	| "BinaryExpr"
	| "CallExpr"
	| "UnaryExpr"
	| "TableLiteral"
	| "DictLiteral"
	| "FunctionDeclaration"
	| "IfStatement"
	| "ForStatement"
	| "GlobalStmt"
	| "ReturnStmt"

export type Stmt = {
	kind: NodeType
}

export type Program = Stmt & {
	kind: NodeType,
	body: {Stmt}
}

export type VarDeclaration = Stmt & {
	kind: "VarDeclaration",
	constant: boolean,
	identifier: string,
	value: Expr
}

export type FunctionDeclaration = Stmt & {
	kind: "FunctionDeclaration",
	name: string,
	parameters: {string},
	body: {Stmt}
}

export type IfStatement = Stmt & {
	kind: "IfStatement",
	conditions: {Expr},
	bodies: {{Stmt}},
}

export type ForStatement = Stmt & {
	kind: "ForStatement",
	variable: string,
	iterable: Expr,
	body: {Stmt},
}

export type GlobalStmt = Stmt & {
	kind: "GlobalStmt",
	names: {string},
}

export type Expr = Stmt & {}

export type CallExpr = Expr & {
	kind: "CallExpr",
	callee: Expr,
	args: {Expr}
}

export type BinaryExpr = Expr & {
	kind: "BinaryExpr",
	left: Expr,
	right: Expr,
	operator: string
}

export type AssignmentExpr = Expr & {
	kind: "AssignmentExpr",
	assigne: Expr,
	value: Expr
}

export type Identifier = Expr & {
	kind: "Identifier",
	symbol: string
}

export type NumericLiteral = Expr & {
	kind: "NumericLiteral",
	value: number
}

export type StringLiteral = Expr & {
	kind: "StringLiteral",
	value: string
}

export type NullLiteral = Expr & {
	kind: "NullLiteral",
	value: "null"
}

export type TableLiteral = Expr & {
	kind: "TableLiteral",
	list: {Expr}
}

export type DictEntry = {
	key: Expr,
	value: Expr,
}

export type DictLiteral = Expr & {
	kind: "DictLiteral",
	entries: { DictEntry }
}

export type ReturnStmt = Stmt & {
	kind: "ReturnStmt",
	value: Expr
}

return module
  -  Edit
  15:36:08.048