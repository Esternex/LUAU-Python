# Roblox Library

The `roblox` library provides functionality for interacting directly with Roblox from Python-like code.

It allows interpreted scripts to:

* Access existing Roblox instances
* Find instances using paths
* Create new instances
* Read and modify Roblox properties
* Call Roblox methods
* Use Roblox events and APIs
* Require `ModuleScript`s
* Create `Vector3` values
* Create `CFrame` values
* Interact with Roblox functionality directly from interpreted code

The library is designed to make Roblox APIs accessible while still using Python-like syntax.

> **Note:** The Roblox library is still under active development. Some Roblox functionality may not yet behave exactly like native Luau.

---

# Importing

Import the library using:

```python
import roblox
```

You can also import it under an alias:

```python
import roblox as rb

part = rb.get_dir("workspace.Part")
```

The default library name is `roblox`.

---

# Built-in Roblox Variables

The Roblox library automatically exposes two Roblox objects to the Python-like environment.

## `game`

`game` refers to the current Roblox `DataModel`.

```python
print(game)
```

The `game` variable is automatically available and does not need to be imported.

## `workspace`

`workspace` refers to the current Roblox `Workspace`.

```python
print(workspace)
```

It is also automatically available.

You can use it with Roblox operations, for example:

```python
workspace.Name
```

---

# Accessing Roblox Instances

Roblox instances returned by the library can be interacted with directly.

For example:

```python
import roblox

part = roblox.get_dir("workspace.Part")

part.Name = "PythonPart"
part.Anchored = true
part.Position = (0, 10, 0)
```

Roblox instances are not limited to property access.

You can also call their Roblox methods.

For example:

```python
part:Destroy()
```

or:

```python
remote:FireServer("Hello")
```

This means the library can interact with Roblox functionality in much greater depth than simply changing properties.

In general, if the underlying Roblox instance supports a property or method, the goal of the library is to make it accessible from Python-like code.

> **Note:** The exact syntax and supported functionality depend on the current interpreter implementation.

---

# Functions

## `roblox.get_dir()`

Resolves a Roblox instance from a path.

### Syntax

```python
roblox.get_dir(path)
```

### Parameters

| Parameter | Type                      | Description           |
| --------- | ------------------------- | --------------------- |
| `path`    | string or Roblox instance | The object to resolve |

### String Paths

The most common usage is passing a Roblox path as a string:

```python
import roblox

part = roblox.get_dir("workspace.Part")
```

Nested paths are supported:

```python
part = roblox.get_dir("workspace.Map.Spawn.Part")
```

For example, this hierarchy:

```text
Workspace
└── Map
    └── Spawn
        └── Part
```

can be accessed with:

```python
part = roblox.get_dir("workspace.Map.Spawn.Part")
```

### Instance Arguments

`get_dir()` can also work with Roblox instances depending on the current path resolver implementation.

### Errors

Calling the function without an argument produces an error:

```python
roblox.get_dir()
```

```text
roblox.get_dir() expects a path string or instance
```

---

# `roblox.find()`

`find()` resolves a Roblox instance using the Roblox path resolver.

### Syntax

```python
roblox.find(path)
```

### Parameters

| Parameter | Type                      | Description        |
| --------- | ------------------------- | ------------------ |
| `path`    | string or Roblox instance | The object to find |

### Example

```python
import roblox

part = roblox.find("workspace.Part")

part.Name = "FoundPart"
```

Nested paths can also be used:

```python
part = roblox.find("workspace.Map.Spawn.Part")
```

### `find()` vs `get_dir()`

The two functions use the same underlying Roblox path resolver, but `find()` is intended for lookup behavior.

```python
part = roblox.find("workspace.Part")
```

---

# `roblox.create_instance()`

Creates a new Roblox `Instance`.

### Syntax

```python
roblox.create_instance(class)
```

or:

```python
roblox.create_instance(class, parent)
```

### Parameters

| Parameter | Type            | Description                |
| --------- | --------------- | -------------------------- |
| `class`   | string          | The Roblox class to create |
| `parent`  | Roblox instance | Optional parent            |

If `parent` is not provided, the new instance is parented to `workspace`.

### Example

```python
import roblox

part = roblox.create_instance("Part")

part.Name = "PythonPart"
part.Position = (0, 10, 0)
part.Anchored = true
```

This creates:

```text
Workspace
└── PythonPart
```

### Specifying a Parent

A parent can be provided as the second argument:

```python
folder = roblox.get_dir("workspace.MyFolder")

part = roblox.create_instance("Part", folder)

part.Name = "PythonPart"
```

The resulting hierarchy is:

```text
Workspace
└── MyFolder
    └── PythonPart
```

### Return Value

The newly created instance is returned as a Roblox value.

This allows you to immediately interact with it:

```python
part = roblox.create_instance("Part")

part.Name = "Test"
part.Size = (5, 5, 5)
part.Position = (0, 10, 0)
part.Anchored = true
```

---

# `roblox.require()`

The `require()` function allows Python-like code to require a Roblox `ModuleScript`.

### Syntax

```python
roblox.require(module)
```

The module can be provided as a Roblox instance or as a path.

### Using a Path

```python
import roblox

my_module = roblox.require("workspace.MyModule")
```

### Using an Instance

```python
import roblox

module = roblox.get_dir("workspace.MyModule")
my_module = roblox.require(module)
```

The target must be a `ModuleScript`.

The required ModuleScript must return a table.

For example, a Roblox ModuleScript could contain:

```lua
return {
    Add = function(a, b)
        return a + b
    end,

    Message = function()
        return "Hello from Roblox!"
    end,
}
```

Python-like code can then access the returned functions:

```python
import roblox

module = roblox.require("workspace.MyModule")

result = module["Add"](10, 20)
print(str(result))
```

Functions returned by the ModuleScript are converted into callable native functions that can be used by the interpreter.

Arguments passed to those functions are converted from interpreter values into their corresponding Roblox/Luau values.

Return values are converted back into interpreter values.

### Errors

`roblox.require()` requires a ModuleScript.

If the target is not a ModuleScript, an error is produced.

The ModuleScript must also return a table.

---

# `roblox.Vector3()`

Creates a Roblox `Vector3`.

### Syntax

```python
roblox.Vector3(x, y, z)
```

### Parameters

| Parameter | Type   | Description  |
| --------- | ------ | ------------ |
| `x`       | number | X coordinate |
| `y`       | number | Y coordinate |
| `z`       | number | Z coordinate |

### Example

```python
import roblox

position = roblox.Vector3(0, 10, 0)
```

The resulting value can be assigned to Roblox properties:

```python
part.Position = roblox.Vector3(0, 10, 0)
```

### Passing a Tuple

The constructor also supports tuple-style arguments:

```python
part.Position = roblox.Vector3((0, 10, 0))
```

### Passing an Existing Vector3

A Roblox `Vector3` can also be passed directly:

```python
vector = roblox.Vector3(0, 10, 0)

other = roblox.Vector3(vector)
```

---

# `roblox.CFrame()`

Creates a Roblox `CFrame`.

The constructor supports several forms.

## Empty CFrame

```python
cf = roblox.CFrame()
```

This creates:

```lua
CFrame.new()
```

## Position

A `Vector3` can be provided:

```python
position = roblox.Vector3(0, 10, 0)
cf = roblox.CFrame(position)
```

This is equivalent to:

```lua
CFrame.new(Vector3.new(0, 10, 0))
```

## Position and LookAt

Two `Vector3` values can be provided:

```python
position = roblox.Vector3(0, 10, 0)
look_at = roblox.Vector3(0, 0, 0)

cf = roblox.CFrame(position, look_at)
```

This creates a CFrame using the position and look-at vectors.

## X, Y, Z

Three numbers can be provided:

```python
cf = roblox.CFrame(0, 10, 0)
```

This is equivalent to:

```lua
CFrame.new(0, 10, 0)
```

## Quaternion Form

The constructor also supports the Roblox quaternion form:

```python
cf = roblox.CFrame(
    0, 10, 0,
    0, 0, 0, 1
)
```

The arguments are:

```text
x, y, z, qx, qy, qz, qw
```

All seven arguments must be numbers.

---

# Roblox Properties

Roblox instances returned by the library can be accessed directly.

For example:

```python
import roblox

part = roblox.get_dir("workspace.Part")

part.Name = "PythonPart"
part.Anchored = true
part.Transparency = 0.5
part.Position = (0, 10, 0)
part.Size = (5, 5, 5)
```

The interpreter supports conversion of supported Python-like values into Roblox values.

For example:

```python
part.Position = (0, 10, 0)
```

can be used as a Roblox `Vector3`.

Similarly:

```python
part.Color = (255, 0, 0)
```

can be used as an RGB color.

---

# Roblox Methods

The Roblox library is not restricted to properties.

Roblox instances can also expose their normal Roblox methods.

For example:

```python
import roblox

part = roblox.get_dir("workspace.Part")

part:Destroy()
```

You can also interact with Roblox services and networking objects where supported.

For example:

```python
remote = roblox.get_dir("ReplicatedStorage.RemoteEvent")

remote:FireServer("Hello from Python!")
```

Other Roblox APIs can be accessed in the same general way:

```python
instance:SomeMethod()
```

The purpose of the library is to provide access to Roblox functionality rather than implementing a separate Python-only version of every Roblox API.

This means the library can be used for things such as:

* Destroying instances
* Cloning instances
* Firing RemoteEvents
* Invoking RemoteFunctions
* Calling Roblox methods
* Accessing services
* Modifying properties
* Creating instances
* Working with Roblox objects
* Interacting with Roblox APIs

> **Note:** Whether a particular method works depends on the current interpreter's Roblox bridge and method/property support.

---

# Complete Example — Modifying an Existing Part

```python
import roblox

part = roblox.get_dir("workspace.Part")

part.Name = "PythonPart"
part.Position = (0, 10, 0)
part.Size = (5, 5, 5)
part.Color = (0, 255, 0)
part.Anchored = true

print("Part modified successfully")
```

> **Requirement:** This script requires a `Part` named `Part` to be placed in `Workspace`.

---

# Complete Example — Creating a Part

```python
import roblox

part = roblox.create_instance("Part")

part.Name = "PythonPart"
part.Position = (0, 10, 0)
part.Size = (5, 5, 5)
part.Color = (0, 255, 0)
part.Anchored = true

print("Created " + str(part.Name))
```

This creates:

```text
Workspace
└── PythonPart
```

---

# Complete Example — Using Vector3

```python
import roblox

part = roblox.create_instance("Part")

position = roblox.Vector3(0, 10, 0)

part.Position = position
part.Anchored = true
```

---

# Complete Example — Using CFrame

```python
import roblox

part = roblox.create_instance("Part")

part.CFrame = roblox.CFrame(0, 10, 0)
part.Anchored = true
```

---

# Complete Example — Calling a Roblox Method

```python
import roblox

part = roblox.get_dir("workspace.Part")

part:Destroy()
```

> **Requirement:** This script requires a `Part` named `Part` to be placed in `Workspace`.

---

# Function Summary

| Function                                | Description                                     |
| --------------------------------------- | ----------------------------------------------- |
| `roblox.get_dir(path)`                  | Resolves a Roblox instance from a path          |
| `roblox.find(path)`                     | Finds a Roblox instance using the path resolver |
| `roblox.create_instance(class, parent)` | Creates a new Roblox instance                   |
| `roblox.require(module)`                | Requires a Roblox ModuleScript                  |
| `roblox.Vector3(...)`                   | Creates a Roblox `Vector3`                      |
| `roblox.CFrame(...)`                    | Creates a Roblox `CFrame`                       |

---

# Automatically Available Variables

| Variable    | Description                    |
| ----------- | ------------------------------ |
| `game`      | The current Roblox `DataModel` |
| `workspace` | The current Roblox `Workspace` |

These variables are automatically available and do not require:

```python
import roblox
```

---

# Roblox Value Conversion

The Roblox library automatically converts values between the Python-like runtime and Roblox/Luau where supported.

Common examples include:

| Python-like value | Roblox value      |
| ----------------- | ----------------- |
| `(0, 10, 0)`      | `Vector3`         |
| `(255, 0, 0)`     | RGB color         |
| Roblox instance   | Roblox `Instance` |
| number            | Luau number       |
| string            | Luau string       |
| boolean           | Luau boolean      |

This conversion is handled by the interpreter's Roblox bridge.

---

# Notes

The Roblox library is still under active development.

The goal is to make Roblox APIs usable from Python-like code without requiring users to manually write equivalent Luau code.

As the interpreter develops, additional Roblox functionality and improved compatibility with Roblox APIs will be added.

For the most accurate information about currently supported functionality, refer to:

```text
src/Libraries/Roblox
```

and:

```text
src/Runtime/RobloxBridge
```

You should also check the project's changelog for changes between versions.
