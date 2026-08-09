# Creating Custom Libraries

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

The name of the `ModuleScript` determines the library's default name.

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

being passed as the `special` argument.

An alias can also be used:

```python
import special as test
```

In this case, the library can be registered using the provided alias.

You can also provide a default name:

```lua
function module.import(env, special)
    if not special then
        special = "special"
    end

    -- ...
end
```

---

## Registering a Library

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

The first two arguments passed to `registerLibrary()` should be the `env` and `special` values received by `import()`.

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

The function can then be called from Python-like code:

```python
import special

special.hello()
```

---

# Function Arguments

Arguments passed from Python-like code are provided to the Luau function through an `args` table.

Arguments are stored by position, starting at `args[1]`.

For example:

```python
special.add(10, 20, 30)
```

would provide:

```lua
args[1] = 10
args[2] = 20
args[3] = 30
```

A function could therefore be written as:

```lua
add = function(args)
    local a = args[1]
    local b = args[2]
    local c = args[3]

    return a + b + c
end
```

The Python-like code could then use the returned value:

```python
import special

result = special.add(10, 20, 30)

print(str(result))
```

---

# Argument Types

Arguments retain their Python-like values when passed to a custom library.

For example:

```python
special.test(
    "Hello",
    123,
    true,
    [1, 2, 3]
)
```

The corresponding Luau function receives the values through `args`:

```lua
test = function(args)
    local text = args[1]
    local number = args[2]
    local boolean = args[3]
    local list = args[4]
end
```

The interpreter handles the conversion between its runtime values and values exposed to custom libraries.

---

# Returning Values

Custom library functions can return values back to the Python-like environment.

For example:

```lua
getNumber = function(args)
    return 123
end
```

Python-like code can then receive the result:

```python
import special

number = special.getNumber()

print(str(number))
```

You can return values such as:

* Numbers
* Strings
* Booleans
* Lists/tables supported by the runtime
* Roblox instances
* Other supported interpreter values

---

# Roblox Integration

One of the main advantages of custom libraries is that they can directly interact with Roblox.

Unlike interpreted Python-like code, which runs inside the interpreter's controlled environment, custom Luau libraries have access to the normal Roblox API.

For example:

```lua
getPart = function(args)
    local part = workspace:FindFirstChild("Part")

    if not part then
        error("Part was not found")
    end

    return part
end
```

Python-like code can then use the returned Roblox instance:

```python
import special

part = special.getPart()

part.Name = "ChangedPart"
part.Anchored = true
```

---

# Calling Roblox APIs

Custom libraries can use normal Roblox APIs.

For example:

```lua
createPart = function(args)
    local part = Instance.new("Part")

    part.Name = "PythonPart"
    part.Parent = workspace

    return part
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

# Multiple Functions

A library can expose as many functions as necessary.

For example:

```lua
main.registerLibrary(env, special, {
    createPart = function(args)
        local part = Instance.new("Part")
        part.Parent = workspace

        return part
    end,

    destroyPart = function(args)
        local part = args[1]

        if not part then
            error("destroyPart requires an instance")
        end

        part:Destroy()
    end,

    getWorkspace = function(args)
        return workspace
    end,
})
```

Python-like code:

```python
import special

part = special.createPart()

part.Name = "TestPart"

special.destroyPart(part)
```

---

# Errors

Custom libraries can raise errors using normal Luau `error()` calls.

For example:

```lua
divide = function(args)
    local a = args[1]
    local b = args[2]

    if b == 0 then
        error("Cannot divide by zero")
    end

    return a / b
end
```

The Python-like code can handle the resulting error using the interpreter's exception system where supported:

```python
import special

try:
    result = special.divide(10, 0)
except Exception as error:
    print(str(error))
```

---

# Complete Example

Here is a complete custom library called `special`:

```lua
local module = {}

function module.import(env, special)
    if not special then
        special = "special"
    end

    local main = require(script.Parent.Parent.Parent.main)

    main.registerLibrary(env, special, {

        add = function(args)
            local a = args[1]
            local b = args[2]

            return a + b
        end,

        createPart = function(args)
            local part = Instance.new("Part")

            part.Name = "PythonPart"
            part.Parent = workspace

            return part
        end,

        destroy = function(args)
            local object = args[1]

            if not object then
                error("destroy requires an instance")
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
        ├── init
        ├── Functions
        ├── Utilities
        └── ...
```

The exact structure is up to you, but keeping larger libraries separated into logical components can make them easier to maintain.

---

# Summary

Custom libraries provide a way to extend the interpreter beyond its built-in functionality.

The basic process is:

1. Create a `ModuleScript` inside `src/Libraries`.
2. Create an `import(env, special)` function.
3. Require the main interpreter module.
4. Register your functions with `main.registerLibrary()`.
5. Access arguments through `args[1]`, `args[2]`, `args[3]`, etc.
6. Return values when necessary.
7. Use normal Luau/Roblox APIs when building Roblox-specific functionality.

The basic template is:

```lua
local module = {}

function module.import(env, special)
    if not special then
        special = "mylibrary"
    end

    local main = require(script.Parent.Parent.Parent.main)

    main.registerLibrary(env, special, {

        myFunction = function(args)
            local value = args[1]

            -- Your code here

            return value
        end,

    })
end

return module
```

Custom libraries are one of the main ways to extend the interpreter and allow Python-like code to interact with functionality that would otherwise be unavailable.
