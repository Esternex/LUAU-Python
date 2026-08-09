# Python-like Interpreter in Luau

A lightweight Python-like interpreter written entirely in [Luau](https://luau.org/).

This project brings Python-inspired syntax and runtime behavior to Roblox/Luau, including variables, functions, control flow, exceptions, classes, built-in libraries, custom libraries, and Roblox integration.

> **Note:** This project is still under active development and is not currently a 1:1 implementation of Python.

## Usage

### Installation

Download the latest `.rbxm` release from the [Latest Release](https://github.com/Esternex/LUAU-Python/releases/tag/release).

Import the `.rbxm` file into your Roblox game. The imported folder contains the interpreter source.

Move the imported folder into `ReplicatedStorage`.

I recommend naming the folder `Python`, but you can use any name you want.

Your project should look something like:

```text
ReplicatedStorage
└── Python
    ├── main
    ├── Lexer
    ├── Parser
    ├── Interpreter
    └── ...
```

### Running Python-like Code

Create a `LocalScript` or `Script` and require the `main` module:

```lua
local main = require(game.ReplicatedStorage.Python.main)
```

Then provide your Python-like code as a string and run it using `main.run()`:

```lua
local main = require(game.ReplicatedStorage.Python.main)

local code = [[
print("Hello from Python!")
]]

local ok, err = pcall(function()
    main.run(code)
end)

if ok then
    -- Code ran successfully.
else
    -- Code failed to run.
    warn("Executing Python code failed: " .. err)
end
```

`main.run()` executes the provided Python-like source code inside the interpreter.

Using `pcall()` is recommended if you want to safely handle errors produced while executing interpreted code.

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

## Built-in Libraries

The interpreter currently includes four built-in libraries:

* `roblox`
* `random`
* `math`
* `time`

The `random`, `math`, and `time` libraries are designed to provide functionality similar to their Python counterparts. Some features are currently unavailable or have been omitted.

Detailed documentation for each library can be found in the [`Documentation/Libraries`](Documentation/Libraries/) directory.

## Roblox Integration

The built-in `roblox` library allows Python-like scripts to directly interact with Roblox objects.

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

> **Note:** This example requires a `Part` named `Part` to exist inside `Workspace`.

For complete documentation of the Roblox library, see [`Documentation/Libraries/Roblox.md`](Documentation/Libraries/Roblox.md).

## Custom Libraries

The interpreter supports custom libraries written in Luau.

Custom libraries can expose functionality to Python-like code while still having access to the full Roblox/Luau environment.

For detailed information about creating custom libraries, see [`Documentation/Custom-Libraries.md`](Documentation/Custom-Libraries.md).

> **Security note:** Custom libraries execute as Luau code and therefore have access to Roblox functionality outside the interpreted Python-like sandbox. Only install or use libraries that you trust.

## Exception Handling

The interpreter supports Python-style exception handling, including `try`, `except`, `else`, and `finally`.

```python
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")
finally:
    print("Finished")
```

It also supports exception propagation, re-raising, and exception inheritance.

```python
try:
    raise ValueError("Something went wrong")
except ValueError as error:
    print(str(error))
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
    print(str(result))
except ValueError as error:
    print(str(error))
```

## Demo Scripts

The [`Demo Scripts`](Demo%20Scripts/) folder contains example Python-like programs demonstrating different features of the interpreter.

These examples are intended to help users understand the syntax and capabilities of the interpreter.

Some demos may require Roblox objects to be present in the game. Any such requirements are documented inside the individual scripts.

## Project Structure

The project structure may change as development continues.

```text
src/
├── Lexer
├── Parser
├── Interpreter
├── Runtime
├── Exceptions
└── Libraries

Demo Scripts/
└── ...

tests/
└── ...

Documentation/
├── Libraries/
└── Custom-Libraries.md
```

The main components are responsible for different stages of the interpreter, including parsing source code, executing code, managing runtime behavior, handling exceptions, and providing libraries.

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

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md) for the complete version history.

## License

This project is licensed under the **MIT License**.

See `LICENSE` for the full license text.

---

### Disclaimer

This project is an independent Python-like interpreter implemented in Luau. It is not affiliated with or endorsed by the Python Software Foundation.

---

## Contact

If you have questions, suggestions, or want to discuss the project, you can contact me through:

* **Discord:** `esternex_`
* **GitHub:** [esternex](https://github.com/Esternex)

For bugs and feature requests, please use the [GitHub Issues](https://github.com/esternex/LUAU-Python/issues) page instead.
