# Python-like Interpreter in Luau

A lightweight Python-like interpreter written entirely in [Luau](https://luau.org/).

This project brings Python-inspired syntax and runtime behavior to Roblox/Luau, including variables, functions, control flow, exceptions, classes, built-in libraries, custom libraries, and Roblox integration.

> **Note:** This project is still under active development and is not currently a 1:1 implementation of Python.

## Features

* Python-like syntax
* Variables and expressions
* Functions
* Classes
* `if` / `elif` / `else`
* `while` loops
* `for` loops
* `break` and `continue`
* `try` / `except` / `else` / `finally`
* `raise` and exception propagation
* Exception inheritance
* Built-in exception types
* Lists
* Dictionaries
* Basic type handling
* Built-in functions
* Arithmetic and comparisons
* Custom libraries
* Roblox integration

## Roblox Integration

This project includes a built-in `roblox` library specifically designed to interact directly with Roblox objects.

For example:

```python
import roblox

part = roblox.getdir("workspace.Part")
part.Name = "Test1"
part.Color = (0, 255, 0)
part.Position = (0, 10, 0)
part.Anchored = true
```

This allows Python-like scripts to interact with Roblox instances without requiring the equivalent functionality to be written directly in Luau.

The Roblox library is an important part of the project and will continue to expand as more functionality is implemented.

## Libraries

The interpreter currently includes four built-in libraries:

* `roblox`
* `random`
* `math`
* `time`

The `random`, `math`, and `time` libraries are designed to provide functionality similar to their Python counterparts. Some features are currently unavailable or have been omitted.

### Creating a Custom Library

Creating a custom library is relatively simple.

Navigate to:

```text
src/Libraries
```

and create a new `ModuleScript`.

Your library must contain a function named `Import` with two parameters:

```lua
local module = {}
function module.Import(env, special)
    -- Library registration
end
return module
```

The parameters are:

* `env` — The environment used to create functions and expose functionality to the Python-like runtime.
* `special` — The alias provided by the user when importing the library. This determines how the library is referenced from Python-like code.

The library must also require the main interpreter module so that it can register itself.

A library is registered using:

```lua
main.registerLibrary(env, special, {
    -- Library functions
})
```

The `env` and `special` values passed to `registerLibrary` are the same values received by the `Import` function.

### Library Functions

Library functions are written entirely in Luau.

This means custom libraries have access to the full Roblox/Luau environment rather than being restricted to the sandboxed environment used by interpreted Python-like code.

For example, a library named `special` could register a `ChangeColor` function:

```lua
main.registerLibrary(env, special, {
    ChangeColor = function(args)
        --[[
            Args format:

            args[1] = The first argument
            args[2] = The second argument
            args[3] = The third argument
            args[4] = The fourth argument

            Additional arguments continue as:
            args[5], args[6], args[7], etc.

            Expected arguments:

            args[1] = Roblox object path
            args[2] = Red value   (0-255)
            args[3] = Green value (0-255)
            args[4] = Blue value  (0-255)

            Arguments retain their normal Python-like values.

            For example:

            "workspace.Part" -> string
            255               -> number
            true              -> boolean

            Types can be inspected from Python-like code
            using the built-in type() function.
        ]]

        local path = args[1]
        local red = args[2]
        local green = args[3]
        local blue = args[4]

        local object = game

        -- Resolve the Roblox object path.
        for name in string.gmatch(path, "[^%.]+") do
            object = object:FindFirstChild(name)

            if not object then
                error("Could not find Roblox object: " .. path)
            end
        end

        -- Make sure the object is a BasePart.
        if not object:IsA("BasePart") then
            error("Object must be a BasePart")
        end

        -- Convert 0-255 RGB values to Roblox's Color3 format.
        object.Color = Color3.fromRGB(red, green, blue)
    end,
})
```

The `args` table contains the arguments passed to the function from the Python-like script.

Arguments are stored by position, starting at `args[1]`.

For example, the following Python-like code:

```python
import special

special.ChangeColor("workspace.Part", 0, 255, 0)
```

provides these arguments to the Luau function:

```text
args[1] = "workspace.Part"
args[2] = 0
args[3] = 255
args[4] = 0
```

The example above changes `workspace.Part` to green.

Custom library functions can accept any values supported by the interpreter.

> **Security note:** Custom libraries execute as Luau code and therefore have access to Roblox functionality outside the interpreted Python-like sandbox. Only install or use libraries that you trust.

## Exception Handling

The interpreter supports Python-style exception handling, including `try`, `except`, `else`, and `finally`.

For example:

```python
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")
finally:
    print("Finished")
```

The interpreter also supports exception propagation, re-raising, and exception inheritance.

For example:

```python
try:
    raise ValueError("Something went wrong")
except ValueError as error:
    print(error)
```

## Example

A simple function with validation and exception handling:

```python
def calculate(energy):
    if energy <= 0:
        raise ValueError("Energy must be positive")

    return energy * 2


try:
    result = calculate(50)
    print(result)
except ValueError as error:
    print(error)
```

## Project Structure

The project structure may change as development continues, but the interpreter is organized around components such as:

```text
src/
├── Lexer
├── Parser
├── Interpreter
├── Runtime
├── Exceptions
└── Libraries

tests/
└── ...
```

The main components are responsible for different stages of the interpreter, including parsing source code, executing it, managing runtime behavior, handling exceptions, and providing libraries.

## Running

This project is designed to run within a Roblox/Luau environment.

Place the interpreter scripts into your Roblox project and provide Python-like source code to the interpreter.

> Setup instructions will be expanded as the project develops.

## Compatibility

The long-term goal of this project is to implement as much of Python as possible and eventually work towards a 1:1 implementation of Python's syntax and behavior.

The interpreter is **not currently 1:1 with Python**. Many Python features are still being implemented, and some behavior may differ from the official Python implementation.

The project is being developed incrementally, with compatibility improving over time.

## Testing

The interpreter includes tests for important runtime behavior, including:

* Exception handling
* Exception propagation
* Exception inheritance
* `finally`
* `raise`
* `return` with `finally`
* `break` / `continue` with `finally`
* `IndexError`
* `KeyError`
* `TypeError`
* `ValueError`
* `ZeroDivisionError`

The interpreter is tested directly inside Roblox to verify that its behavior matches the expected Python-like behavior.

## Contributing

Contributions, bug reports, and suggestions are welcome.

If you find a bug:

1. Check whether it has already been reported.
2. Open an issue with a minimal example that reproduces the problem.
3. Include the expected behavior and the actual behavior.
4. Include any relevant error messages or output.

Pull requests are also welcome.

If you want to contribute a new Python feature, please try to match the behavior of standard Python as closely as practical.

## License

This project is licensed under the **MIT License**.

See [`LICENSE`](LICENSE) for the full license text.

---

### Disclaimer

This project is an independent Python-like interpreter implemented in Luau. It is not affiliated with or endorsed by the Python Software Foundation.

---

## Contact

If you have questions, suggestions, or want to discuss the project, you can contact me through:

* **Discord:** `esternex_`
* **GitHub:** [esternex](https://github.com/Esternex)

For bugs and feature requests, please use the [GitHub Issues](https://github.com/esternex/LUAU-Python/issues) page instead.
