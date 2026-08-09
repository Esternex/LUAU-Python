# Custom Libraries

The interpreter supports custom libraries written entirely in Luau.

Custom libraries allow you to extend the Python-like environment with your own functionality, including Roblox-specific features, APIs, utilities, and other functionality that would not normally be available to interpreted Python-like code.

> **Important:** Custom libraries execute as Luau code and therefore have access to the Roblox environment outside the interpreter's sandbox. Only use libraries you trust.

---

## Creating a Library

Custom libraries are located in:

```text
src/Libraries
```

To create a library, create a new `ModuleScript` inside this folder.

For example:

```text
src/
└── Libraries/
    ├── Roblox
    ├── Math
    ├── Random
    ├── Time
    └── Special
```

The name and structure of the `ModuleScript` can be chosen based on how you want to organize your library.

---

## Library Structure

A library should return a table containing an `import` function.

A basic library looks like this:

```lua
local module = {}

function module.import(env, special)
    -- Library setup
end

return module
```

The `import` function receives two arguments:

| Argument  | Description                                              |
| --------- | -------------------------------------------------------- |
| `env`     | The environment used by the interpreted Python-like code |
| `special` | The name or alias used when importing the library        |

---

## The `special` Argument

The `special` argument represents the name that the user imported the library as.

For example:

```python
import special
```

would normally result in:

```text
special
```

being used as the library name.

An alias can also be used:

```python
import special as test
```

In this case, the library can be registered using the provided alias.

You can provide a default name if no alias is supplied:

```lua
function module.import(env, special)
    if not special then
        special = "special"
    end

    -- ...
end
```

---

# Registering a Library

To expose your library to Python-like code, require the main interpreter module and call `registerLibrary()`.

For example:

```lua
local module = {}

function module.import(env, special)
    if not special then
        special = "special"
    end

    local main = require(script.Parent.Parent.Parent.main)

    main.registerLibrary(env, special, {
        -- Functions go here
    })
end

return module
```

The `env` and `special` values passed to `registerLibrary()` are the same values received by `import()`.

---

# The Values System

One of the most important things to understand when creating custom libraries is the interpreter's **Values system**.

Python-like values are not passed directly to your Luau functions.

Instead, they are represented internally as two-element tables:

```lua
{
    value,
    type
}
```

For example:

```lua
{ 123, "number" }
```

represents the Python-like number:

```python
123
```

And:

```lua
{ "Hello", "string" }
```

represents:

```python
"Hello"
```

The second element identifies the interpreter's runtime type.

---

## Value Structure

The basic structure is:

```text
value[1] = actual value
value[2] = interpreter type
```

For example:

```lua
local value = { 123, "number" }

print(value[1]) -- 123
print(value[2]) -- number
```

This means that when receiving an argument from Python-like code, you generally need to access:

```lua
args[1][1]
```

for the actual value, and:

```lua
args[1][2]
```

for its interpreter type.

---

# Built-in Value Constructors

The interpreter provides a `Values` module for creating properly formatted runtime values.

The module is located at:

```text
game.ReplicatedStorage.Python.Runtime.Values
```

You can require it from a custom library with:

```lua
local Values = require(game.ReplicatedStorage.Python.Runtime.Values)
```

Or, depending on your library's location:

```lua
local Values = require(script.Parent.Parent.Parent.Runtime.Values)
```

The `Values` module provides constructors for the interpreter's supported runtime types.

---

## Numbers

Create a Python-like number using:

```lua
Values.mkNumber(123)
```

This produces:

```lua
{ 123, "number" }
```

For example:

```lua
local Values = require(script.Parent.Parent.Parent.Runtime.Values)

local number = Values.mkNumber(50)

return number
```

---

## Strings

Create a Python-like string using:

```lua
Values.mkString("Hello")
```

This produces:

```lua
{ "Hello", "string" }
```

---

## Booleans

Create a Python-like boolean using:

```lua
Values.mkBool(true)
```

or:

```lua
Values.mkBool(false)
```

---

## Null

Create the interpreter's null value using:

```lua
Values.mkNull()
```

---

## Lists

Create a Python-like list using:

```lua
Values.mkTable(list)
```

For example:

```lua
local list = {
    Values.mkNumber(1),
    Values.mkNumber(2),
    Values.mkNumber(3)
}

return Values.mkTable(list)
```

---

## Dictionaries

Create a Python-like dictionary using:

```lua
Values.mkDict(dict)
```

---

## Ranges

Create a Python-like range using:

```lua
Values.mkRange(start, stop, step)
```

For example:

```lua
return Values.mkRange(0, 10, 1)
```

---

## Tuples

Create a Python-like tuple using:

```lua
Values.mkTuple(items)
```

For example:

```lua
return Values.mkTuple({
    Values.mkNumber(10),
    Values.mkNumber(20),
    Values.mkNumber(30)
})
```

---

## Roblox Instances

Roblox objects are represented using:

```lua
Values.mkRoblox(instance)
```

For example:

```lua
local part = workspace.Part

return Values.mkRoblox(part)
```

This allows the returned object to be used by the Python-like runtime as a Roblox value.

---

# Function Arguments

When a Python-like function calls a custom library function, the arguments are provided through an `args` table.

However, **the arguments are Values, not raw Luau values**.

For example, this Python-like code:

```python
import special

special.add(10, 20)
```

does **not** provide:

```lua
args[1] = 10
args[2] = 20
```

Instead, it provides:

```lua
args[1] = { 10, "number" }
args[2] = { 20, "number" }
```

Therefore, to access the actual numbers:

```lua
local a = args[1][1]
local b = args[2][1]
```

The runtime types can be accessed using:

```lua
local aType = args[1][2]
local bType = args[2][2]
```

---

# Example: Adding Two Numbers

A complete example:

```lua
local module = {}

local Values = require(script.Parent.Parent.Parent.Runtime.Values)

function module.import(env, special)
    if not special then
        special = "special"
    end

    local main = require(script.Parent.Parent.Parent.main)

    main.registerLibrary(env, special, {

        add = function(args)
            local a = args[1][1]
            local b = args[2][1]

            return Values.mkNumber(a + b)
        end,

    })
end

return module
```

The Python-like code:

```python
import special

result = special.add(10, 20)

print(str(result))
```

passes:

```lua
args[1] = { 10, "number" }
args[2] = { 20, "number" }
```

The function extracts the actual values:

```lua
local a = args[1][1]
local b = args[2][1]
```

and returns a properly formatted interpreter value:

```lua
return Values.mkNumber(a + b)
```

---

# Checking Argument Types

Because every argument contains its interpreter type, you can inspect the type using `[2]`.

For example:

```lua
local value = args[1]

if value[2] ~= "number" then
    error("Expected a number")
end

local number = value[1]
```

This allows custom libraries to perform their own type validation.

For example:

```lua
divide = function(args)
    if not args[1] or not args[2] then
        error("divide() expects two arguments")
    end

    if args[1][2] ~= "number" or args[2][2] ~= "number" then
        error("divide() expects numbers")
    end

    local a = args[1][1]
    local b = args[2][1]

    if b == 0 then
        error("Cannot divide by zero")
    end

    return Values.mkNumber(a / b)
end
```

---

# Returning Values

Custom library functions **must return interpreter Values** when returning a value to Python-like code.

Do not do this:

```lua
return 123
```

Instead, use:

```lua
return Values.mkNumber(123)
```

Likewise, do not do:

```lua
return "Hello"
```

Use:

```lua
return Values.mkString("Hello")
```

And for booleans:

```lua
return Values.mkBool(true)
```

This is important because the interpreter needs both the value and its runtime type.

---

# Returning Roblox Instances

Roblox instances should be wrapped using `Values.mkRoblox()`.

For example:

```lua
getPart = function(args)
    local part = workspace:FindFirstChild("Part")

    if not part then
        error("Part was not found")
    end

    return Values.mkRoblox(part)
end
```

Python-like code can then use the returned Roblox object:

```python
import special

part = special.getPart()

part.Name = "ChangedPart"
part.Anchored = true
```

---

# Returning Lists

Lists also need to contain interpreter Values.

For example:

```lua
getNumbers = function(args)
    local list = {
        Values.mkNumber(1),
        Values.mkNumber(2),
        Values.mkNumber(3)
    }

    return Values.mkTable(list)
end
```

Python-like code:

```python
import special

numbers = special.getNumbers()

print(str(numbers))
```

---

# Returning Tuples

Tuples can be created with `Values.mkTuple()`:

```lua
getPosition = function(args)
    return Values.mkTuple({
        Values.mkNumber(0),
        Values.mkNumber(10),
        Values.mkNumber(0)
    })
end
```

Python-like code:

```python
import special

position = special.getPosition()

print(str(position))
```

---

# Adding Functions

Functions are added to the table passed to `registerLibrary()`.

For example:

```lua
main.registerLibrary(env, special, {
    hello = function(args)
        print("Hello from Luau!")
    end,
})
```

The Python-like code can then call:

```python
import special

special.hello()
```

Functions that don't need to return anything do not need to return a Value.

---

# Roblox Integration

One of the main advantages of custom libraries is that they can directly interact with Roblox.

Unlike interpreted Python-like code, custom Luau libraries have access to the normal Roblox API.

For example:

```lua
createPart = function(args)
    local part = Instance.new("Part")

    part.Name = "PythonPart"
    part.Parent = workspace

    return Values.mkRoblox(part)
end
```

Python-like code:

```python
import special

part = special.createPart()

part.Position = (0, 10, 0)
part.Anchored = true
```

Custom libraries can therefore act as a bridge between the Python-like runtime and Roblox.

---

# Calling Roblox APIs

Custom libraries can use normal Roblox APIs.

For example:

```lua
destroyPart = function(args)
    local part = args[1][1]

    if not part then
        error("destroyPart requires an instance")
    end

    part:Destroy()
end
```

Python-like code:

```python
import special

part = special.createPart()

special.destroyPart(part)
```

Custom libraries can use Roblox functionality such as:

```lua
Instance.new()
part:Destroy()
remote:FireServer()
workspace:FindFirstChild()
game:GetService()
```

and other Roblox APIs available to the script's execution context.

---

# Complete Example

Here is a complete custom library called `special`:

```lua
local module = {}

local Values = require(script.Parent.Parent.Parent.Runtime.Values)

function module.import(env, special)
    if not special then
        special = "special"
    end

    local main = require(script.Parent.Parent.Parent.main)

    main.registerLibrary(env, special, {

        add = function(args)
            if not args[1] or not args[2] then
                error("add() expects two arguments")
            end

            if args[1][2] ~= "number" or args[2][2] ~= "number" then
                error("add() expects two numbers")
            end

            local a = args[1][1]
            local b = args[2][1]

            return Values.mkNumber(a + b)
        end,

        createPart = function(args)
            local part = Instance.new("Part")

            part.Name = "PythonPart"
            part.Parent = workspace

            return Values.mkRoblox(part)
        end,

        destroy = function(args)
            if not args[1] then
                error("destroy() expects an instance")
            end

            local object = args[1][1]

            if not object then
                error("destroy() received an invalid instance")
            end

            object:Destroy()
        end,

    })
end

return module
```

Python-like code:

```python
import special

result = special.add(10, 20)

print(str(result))

part = special.createPart()

part.Position = (0, 10, 0)
part.Anchored = true

special.destroy(part)
```

---

# Available Value Constructors

The `Runtime.Values` module currently provides the following constructors:

| Constructor                              | Runtime type      |
| ---------------------------------------- | ----------------- |
| `Values.mkNumber(value)`                 | `number`          |
| `Values.mkString(value)`                 | `string`          |
| `Values.mkNull()`                        | `null`            |
| `Values.mkBool(value)`                   | `boolean`         |
| `Values.mkTable(value)`                  | `table`           |
| `Values.mkDict(value)`                   | `dictionary`      |
| `Values.mkRange(start, stop, step)`      | `range`           |
| `Values.mkTuple(value)`                  | `tuple`           |
| `Values.mkFunction(name, params, body)`  | `function`        |
| `Values.mkNativeFunction(name, caller)`  | `native_function` |
| `Values.mkClass(name, methods)`          | `class`           |
| `Values.mkInstance(classValue)`          | `instance`        |
| `Values.mkRoblox(value)`                 | `roblox`          |
| `Values.mkExceptionType(name, parent)`   | `exception_type`  |
| `Values.mkException(typeValue, message)` | `exception`       |

Most custom libraries will primarily use:

```lua
Values.mkNumber()
Values.mkString()
Values.mkBool()
Values.mkTable()
Values.mkDict()
Values.mkTuple()
Values.mkRoblox()
Values.mkNull()
```

---

# Value Internals

For advanced library development, Values can be inspected directly.

A typical Value looks like:

```lua
{
    actualValue,
    "type"
}
```

For example:

```lua
{
    123,
    "number"
}
```

The actual value is:

```lua
value[1]
```

and the interpreter type is:

```lua
value[2]
```

Some runtime values contain additional fields.

For example, functions may contain:

```lua
{
    name,
    "function",
    params = params,
    body = body
}
```

Native functions may contain:

```lua
{
    name,
    "native_function",
    caller = caller
}
```

Classes and instances also contain additional runtime information.

Unless you are specifically working with interpreter internals, it is recommended to use the provided `Values` constructors rather than manually constructing these tables.

---

# Security

Custom libraries are **not sandboxed in the same way as interpreted Python-like code**.

A custom library is Luau code running inside Roblox.

This means it can potentially:

* Access Roblox services
* Create and destroy Instances
* Modify the game
* Access objects in the DataModel
* Call Roblox APIs
* Execute arbitrary Luau logic
* Interact with functionality available to the script's execution context

Because of this, you should only install custom libraries from sources you trust.

A custom library should be treated similarly to installing another Luau script into your Roblox game.

---

# Recommended Structure

For larger libraries, you may want to organize the code into multiple modules.

For example:

```text
src/
└── Libraries/
    └── Special/
        ├── Main
        ├── Functions
        ├── Utilities
        └── ...
```

The exact structure is up to you, but keeping larger libraries separated into logical components can make them easier to maintain.

---

# Summary

Creating a custom library generally involves:

1. Create a `ModuleScript` inside `src/Libraries`.
2. Create an `import(env, special)` function.
3. Require `Runtime.Values`.
4. Require the main interpreter module.
5. Register your functions using `main.registerLibrary()`.
6. Read arguments from `args`.
7. Remember that arguments are **Values**, not raw Luau values.
8. Access the actual argument with `args[index][1]`.
9. Access the interpreter type with `args[index][2]`.
10. Use `Values.mk*()` when returning values.
11. Use `Values.mkRoblox()` when returning Roblox instances.
12. Use normal Luau/Roblox APIs when implementing your library.

A minimal library template is:

```lua
local module = {}

local Values = require(script.Parent.Parent.Parent.Runtime.Values)

function module.import(env, special)
    if not special then
        special = "mylibrary"
    end

    local main = require(script.Parent.Parent.Parent.main)

    main.registerLibrary(env, special, {

        myFunction = function(args)
            local value = args[1][1]
            local valueType = args[1][2]

            -- Your code here

            return Values.mkString("Hello from my library!")
        end,

    })
end

return module
```

Custom libraries are one of the main ways to extend the interpreter and allow Python-like code to interact with functionality that would otherwise be unavailable.
