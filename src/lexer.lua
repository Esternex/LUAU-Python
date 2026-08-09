  20:44:12.748  SOURCE|local module = {}
local Dependencies = script.Parent.Dependencies
local Types = require(Dependencies.Types)

local KEYWORDS = {
	["null"] = "Null",
	["def"] = "Define",
	["if"] = "If",
	["elif"] = "Elif",
	["else"] = "Else",
	["for"] = "For",
	["in"] = "In",
	["while"] = "While",
	["global"] = "Global",
	["import"] = "Import",
	["class"] = "Class",
	["not"] = "Not",
	["and"] = "And",
	["or"] = "Or",
	["break"] = "Break",
	["try"] = "Try",
	["except"] = "Except",
	["finally"] = "Finally",
	["raise"] = "Raise",
	["as"] = "As",
	["continue"] = "Continue",
}

local function isAlpha(letter: string): boolean
	return letter:match("[%a_]") ~= nil
end

local function isInt(char: string): boolean
	return char:match("[%d]") ~= nil
end

local function isSkippable(char: string): boolean
	return char == " " or char == "\t"
end

local function getLineIndent(line: string): number
	local count = 0
	for i = 1, #line do
		local char = line:sub(i, i)
		if char == "\t" then
			count = count + 4
		elseif char == " " then
			count = count + 1
		else
			break
		end
	end
	return count
end

local function stripTripleComments(source: string): string
	local out = {}
	local i = 1
	local len = #source
	while i <= len do
		if source:sub(i, i + 2) == '"""' then
			local j = i + 3
			local closeAt
			local found = false
			while j <= len - 2 do
				if source:sub(j, j + 2) == '"""' then
					closeAt = j + 2
					found = true
					break
				end
				j = j + 1
			end
			if found then
				for k = i, closeAt do
					local c = source:sub(k, k)
					if c == "\
" or c == "\" then
						table.insert(out, c)
					else
						table.insert(out, " ")
					end
				end
				i = closeAt + 1
			else
				for k = i, len do
					local c = source:sub(k, k)
					if c == "\
" or c == "\" then
						table.insert(out, c)
					end
				end
				break
			end
		else
			table.insert(out, source:sub(i, i))
			i = i + 1
		end
	end
	return table.concat(out)
end

function module.Tokenize(sourceCode: string)
	sourceCode = stripTripleComments(sourceCode)
	local tokens = {}
	local pos = 1
	local len = #sourceCode
	local indentStack = {0}
	local bracketDepth = 0

	local lines = {}
	local currentLineContent = ""

	while pos <= len do
		local char = sourceCode:sub(pos, pos)
		
		if char == "\
" then
			table.insert(lines, currentLineContent)
			currentLineContent = ""
			pos = pos + 1
		elseif char == "\" then
			if pos < len and sourceCode:sub(pos + 1, pos + 1) == "\
" then
				table.insert(lines, currentLineContent)
				currentLineContent = ""
				pos = pos + 2
			else
				pos = pos + 1
			end
		else
			currentLineContent = currentLineContent .. char
			pos = pos + 1
		end
	end
	if currentLineContent ~= "" then
		table.insert(lines, currentLineContent)
	end

	for _, line in ipairs(lines) do
		local stripped = line:gsub("^%s+", "")
		if stripped == "" or stripped:sub(1, 1) == "#" then
			continue
		end
		
		local indent = getLineIndent(line)
		
		if bracketDepth == 0 then
			if indent > indentStack[#indentStack] then
				table.insert(tokens, {"", "Indent"})
				table.insert(indentStack, indent)
			else
				while indent < indentStack[#indentStack] do
					table.remove(indentStack)
					table.insert(tokens, {"", "Dedent"})
				end
			end
		end
		
		local lineLen = #line
		local i = 1
		while i <= lineLen do
			local char = line:sub(i, i)
			
			if isSkippable(char) then
				i = i + 1
			elseif char == "(" then
				table.insert(tokens, {char, "OpenParen"})
				bracketDepth = bracketDepth + 1
				i = i + 1
			elseif char == ")" then
				table.insert(tokens, {char, "CloseParen"})
				bracketDepth = math.max(0, bracketDepth - 1)
				i = i + 1
			elseif char == "," then
				table.insert(tokens, {char, "Comma"})
				i = i + 1
			elseif char == "." then
				if i < lineLen and line:sub(i + 1, i + 1) == "." then
					table.insert  -  Edit
  20:44:12.748  SOURCE|(tokens, {"..", "Concat"})
					i = i + 2
				else
					table.insert(tokens, {char, "Dot"})
					i = i + 1
				end
			elseif char == "[" then
				table.insert(tokens, {char, "OpenBracket"})
				bracketDepth = bracketDepth + 1
				i = i + 1
			elseif char == "]" then
				table.insert(tokens, {char, "CloseBracket"})
				bracketDepth = math.max(0, bracketDepth - 1)
				i = i + 1
			elseif char == "{" then
				table.insert(tokens, {char, "OpenCurly"})
				bracketDepth = bracketDepth + 1
				i = i + 1
			elseif char == "}" then
				table.insert(tokens, {char, "CloseCurly"})
				bracketDepth = math.max(0, bracketDepth - 1)
				i = i + 1
			elseif char == ":" then
				table.insert(tokens, {char, "Colon"})
				i = i + 1
			elseif char == '"' then
				local str = ""
				i = i + 1
				while i <= lineLen and line:sub(i, i) ~= '"' do
					local ch = line:sub(i, i)
					if ch == "\\" and i < lineLen then
						local nextChar = line:sub(i + 1, i + 1)
						if nextChar == "n" then
							str = str .. "\
"
							i = i + 2
						elseif nextChar == "t" then
							str = str .. "\t"
							i = i + 2
						elseif nextChar == "r" then
							str = str .. "\"
							i = i + 2
						elseif nextChar == "\\" then
							str = str .. "\\"
							i = i + 2
						elseif nextChar == '"' then
							str = str .. '"'
							i = i + 2
						else
							str = str .. nextChar
							i = i + 2
						end
					else
						str = str .. ch
						i = i + 1
					end
				end
				i = i + 1
				table.insert(tokens, {str, "String"})
			elseif char == "=" then
				if i < lineLen and line:sub(i + 1, i + 1) == "=" then
					local nextChar = i + 1 < lineLen and line:sub(i + 2, i + 2) or ""
					if nextChar == "=" then
						table.insert(tokens, {"==", "Compare"})
						i = i + 3
					else
						table.insert(tokens, {"==", "Compare"})
						i = i + 2
					end
				else
					table.insert(tokens, {char, "Equals"})
					i = i + 1
				end
			elseif char == "!" then
				if i < lineLen and line:sub(i + 1, i + 1) == "=" then
					table.insert(tokens, {"!=", "Compare"})
					i = i + 2
				else
					error("Unknown character '" .. char .. "'")
				end
			elseif char == "<" then
				local nextChar = i < lineLen and line:sub(i + 1, i + 1) or ""
				if nextChar == "=" then
					table.insert(tokens, {"<=", "Compare"})
					i = i + 2
				else
					table.insert(tokens, {char, "Compare"})
					i = i + 1
				end
			elseif char == ">" then
				local nextChar = i < lineLen and line:sub(i + 1, i + 1) or ""
				if nextChar == "=" then
					table.insert(tokens, {">=", "Compare"})
					i = i + 2
				else
					table.insert(tokens, {char, "Compare"})
					i = i + 1
				end
			elseif char == ";" then
				table.insert(tokens, {char, "Semicolon"})
				i = i + 1
			elseif char == "+" or char == "-" or char == "*" or char == "/" or char == "%" then
				local nextChar = i < lineLen and line:sub(i + 1, i + 1) or ""
				if char == "*" and nextChar == "*" then
					table.insert(tokens, {"**", "Power"})
					i = i + 2
				elseif nextChar == "=" then
					local op = char .. "="
					local tokenType
					if op == "+=" then tokenType = "PlusEquals"
					elseif op == "-=" then tokenType = "MinusEquals"
					elseif op == "*=" then tokenType = "MultiplyEquals"
					elseif op == "/=" then tokenType = "DivideEquals"
					elseif op == "%=" then tokenType = "ModuloEquals"
					end
					table.insert(tokens, {op, tokenType})
					i = i + 2
				else
					table.insert(tokens, {char, "BinaryOperator"})
					i = i + 1
				end
			elseif char == "f" and i < lineLen and line:sub(i + 1, i + 1) == '"' then
				local parts = {}
				local str = ""
				i = i + 2
				while i <= lineLen and line:sub(i, i) ~= '"' do
					local ch = line:sub(i, i)
					if ch == "{" then
						if str ~= "" then
							table.insert(parts, { lit = str })
							str = ""
						end
						i = i + 1
						local exprSrc = ""  -  Edit
  20:44:12.748  SOURCE|
						local depth = 1
						while i <= lineLen and depth > 0 do
							local c = line:sub(i, i)
							if c == "{" then
								depth = depth + 1
								exprSrc = exprSrc .. c
							elseif c == "}" then
								depth = depth - 1
								if depth > 0 then
									exprSrc = exprSrc .. c
								end
							else
								exprSrc = exprSrc .. c
							end
							i = i + 1
						end
						table.insert(parts, { expr = exprSrc })
					elseif ch == "\\" and i < lineLen then
						local nextChar = line:sub(i + 1, i + 1)
						if nextChar == "n" then
							str = str .. "\
"
							i = i + 2
						elseif nextChar == "t" then
							str = str .. "\t"
							i = i + 2
						elseif nextChar == "r" then
							str = str .. "\"
							i = i + 2
						elseif nextChar == "\\" then
							str = str .. "\\"
							i = i + 2
						elseif nextChar == '"' then
							str = str .. '"'
							i = i + 2
						else
							str = str .. nextChar
							i = i + 2
						end
					else
						str = str .. ch
						i = i + 1
					end
				end
				if str ~= "" then
					table.insert(parts, { lit = str })
				end
				i = i + 1
				table.insert(tokens, { parts, "FString" })
			elseif isInt(char) then
				local start = i
				while i <= lineLen and isInt(line:sub(i, i)) do
					i = i + 1
				end
				if i < lineLen and line:sub(i, i) == "." and isInt(line:sub(i + 1, i + 1)) then
					i = i + 1
					while i <= lineLen and isInt(line:sub(i, i)) do
						i = i + 1
					end
				end
				local numStr = line:sub(start, i - 1)
				local value = tonumber(numStr)
				if value == nil then
					error("Invalid number: " .. numStr)
				end
				table.insert(tokens, {numStr, "Number"})
			elseif isAlpha(char) then
				local start = i
				while i <= lineLen and (isAlpha(line:sub(i, i)) or isInt(line:sub(i, i))) do
					i = i + 1
				end
				local ident = line:sub(start, i - 1)
				local keywordType = KEYWORDS[ident]
				if keywordType then
					table.insert(tokens, {ident, keywordType})
				else
					table.insert(tokens, {ident, "Identifier"})
				end
			elseif char == "#" then
				i = lineLen + 1
			else
				error("unknown character " .. char)
			end
		end
		
		if bracketDepth == 0 then
			table.insert(tokens, {"", "Newline"})
		end
	end

	while #indentStack > 1 do
		table.remove(indentStack)
		table.insert(tokens, {"", "Dedent"})
	end

	table.insert(tokens, {"EndOfFile", "EOF"})
	return tokens
end

return module
  -  Edit
  20:44:12.748