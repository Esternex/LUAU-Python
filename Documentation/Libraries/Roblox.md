# Roblox Library

The `roblox` library provides functionality for interacting directly with Roblox instances from Python-like code.

It allows interpreted scripts to access existing Roblox objects, search for instances, create new instances, and interact with Roblox properties and methods.

## Importing

Import the library using:

```python
import roblox
```

By default, the library is available under the name `roblox`.

If your interpreter supports importing it under a different alias, the alias can be used instead:

```python
import roblox as rb

part = rb.getdir("workspace.Part")
```

---

## Built-in Roblox Variables

The Roblox library automatically exposes two Roblox objects to the Python-like environment.

### `game`

`game` refers to the current Roblox `DataModel`.

```python
print(game)
```

This can also be used when accessing Roblox objects.

For example:

```python
part = game.Workspace.Part
```

### `workspace`

`workspace` refers to the current Roblox `Workspace`.

```python
part = workspace.Part
```

This is equivalent to accessing the Workspace through `game`:

```python
part = game.Workspace.Part
```

Both `game` and `workspace` are automatically available and do not need to be imported separately.

---

# Functions

## `roblox.getdir()`

Resolves a Roblox object from a path.

### Syntax

```python
roblox.getdir(path)
```

### Parameters

| Parameter | Type                        | Description                  |
| --------- | --------------------------- | ---------------------------- |
| `path`    | `string` or Roblox instance | The Roblox object to resolve |

### Examples

Using a string path:

```python
import roblox

part = roblox.getdir("workspace.Part")

part.Name = "TestPart"
```

You can then interact with the returned Roblox instance:

```python
part.Position = (0, 10, 0)
part.Anchored = true
```

### Errors

Calling `getdir()` without an argument raises an error:

```python
roblox.getdir()
```

The resulting error is:

```text
roblox.getdir() expects a path string or instance
```

---

## `roblox.find()`

Resolves a Roblox object from a path.

### Syntax

```python
roblox.find(path)
```

### Parameters

| Parameter | Type                        | Description                  |
| --------- | --------------------------- | ---------------------------- |
| `path`    | `string` or Roblox instance | The Roblox object to resolve |

### Example

```python
import roblox

part = roblox.find("workspace.Part")

part.Name = "FoundPart"
```

`find()` currently uses the same path resolution system as `getdir()`.

For example:

```python
part = roblox.find("workspace.Folder.Part")
```

will resolve the object at:

```text
Workspace
└── Folder
    └── Part
```

---

## `roblox.createinstance()`

Creates a new Roblox `Instance`.

### Syntax

```python
roblox.createinstance(class)
```

or:

```python
roblox.createinstance(class, parent)
```

### Parameters

| Parameter | Type            | Description                    |
| --------- | --------------- | ------------------------------ |
| `class`   | `string`        | The Roblox class to create     |
| `parent`  | Roblox instance | The parent of the new instance |

The `parent` parameter is optional.

If no parent is provided, the instance is parented to `workspace`.

### Example

Create a Part inside Workspace:

```python
import roblox

part = roblox.createinstance("Part")

part.Name = "TestPart"
part.Position = (0, 10, 0)
part.Anchored = true
```

Because no parent was provided, the resulting Part is parented to `workspace`.

### Specifying a Parent

A parent can be provided as the second argument:

```python
folder = roblox.getdir("workspace.MyFolder")

part = roblox.createinstance("Part", folder)

part.Name = "MyPart"
```

The resulting hierarchy will be:

```text
Workspace
└── MyFolder
    └── MyPart
```

### Return Value

`createinstance()` returns the newly created Roblox instance.

This means you can immediately modify it:

```python
part = roblox.createinstance("Part")

part.Name = "Test"
part.Size = (5, 5, 5)
part.Position = (0, 10, 0)
part.Anchored = true
```

### Errors

Calling `createinstance()` without a class raises an error.

```python
roblox.createinstance()
```

The resulting error is:

```text
createinstance requires a class and parent
```

---

# Roblox Properties

Roblox instances returned by the library can be used directly from Python-like code.

For example:

```python
import roblox

part = roblox.getdir("workspace.Part")

part.Name = "MyPart"
part.Anchored = true
part.Transparency = 0.5
part.Position = (0, 10, 0)
```

The interpreter converts supported Python-like values into the corresponding Roblox values where appropriate.

For example, tuples can be used for properties such as position and size:

```python
part.Position = (0, 10, 0)
part.Size = (5, 5, 5)
```

RGB tuples can also be used for color:

```python
part.Color = (255, 0, 0)
```

---

# Creating Instances

A complete example using `createinstance()`:

```python
import roblox

part = roblox.createinstance("Part")

part.Name = "PythonPart"
part.Position = (0, 10, 0)
part.Size = (5, 5, 5)
part.Color = (0, 255, 0)
part.Anchored = true
```

This creates a green, anchored Part above the Workspace origin.

> **Note:** This example requires Roblox instance creation and property assignment to be supported by the current interpreter version.

---

# Complete Example

The following example demonstrates finding an existing Part and modifying it:

```python
import roblox

part = roblox.getdir("workspace.Part")

part.Name = "PythonPart"
part.Position = (0, 10, 0)
part.Size = (5, 5, 5)
part.Color = (0, 255, 0)
part.Anchored = true

print("Part modified successfully")
```

> **Requirement:** This script requires a `Part` named `Part` to be placed in `Workspace`.

---

# Creating a Part from Scratch

You can also create a Part without having one already in Workspace:

```python
import roblox

part = roblox.createinstance("Part")

part.Name = "PythonPart"
part.Position = (0, 10, 0)
part.Size = (5, 5, 5)
part.Color = (0, 255, 0)
part.Anchored = true

print("Created " + str(part.Name))
```

The resulting hierarchy is:

```text
Workspace
└── PythonPart
```

---

# Function Summary

| Function                               | Description                                             |
| -------------------------------------- | ------------------------------------------------------- |
| `roblox.getdir(path)`                  | Resolves a Roblox object from a path                    |
| `roblox.find(path)`                    | Resolves a Roblox object using the Roblox path resolver |
| `roblox.createinstance(class, parent)` | Creates and returns a new Roblox instance               |

## Automatically Available Variables

| Variable    | Description                  |
| ----------- | ---------------------------- |
| `game`      | The current Roblox DataModel |
| `workspace` | The current Roblox Workspace |

---

# Roblox Methods

Roblox objects returned by the `roblox` library are not limited to property access.

You can also interact with Roblox Instances by calling their methods from Python-like code.

This means Roblox functionality such as `Destroy()`, `FireServer()`, `Clone()`, and other Instance methods can be used directly from interpreted code, provided the method is supported by the current interpreter and the Roblox object provides it.

For example:

```python
import roblox

part = roblox.getdir("workspace.Part")

part.Destroy()
```

This is equivalent to calling:

```lua
part:Destroy()
```

in Luau.

## Calling Methods

Methods are called using normal Python-like function-call syntax:

```python
part.Destroy()
```

rather than Luau's `:` syntax:

```lua
part:Destroy()
```

The interpreter handles the Roblox method call internally.

### Example: Destroying an Instance

```python
import roblox

part = roblox.getdir("workspace.Part")

part.Destroy()
```

> **Requirement:** This script requires a `Part` named `Part` to be placed in `Workspace`.

### Example: Cloning an Instance

Roblox methods that return another Instance can also be used:

```python
import roblox

part = roblox.getdir("workspace.Part")

clone = part.Clone()
clone.Name = "PartClone"
clone.Parent = workspace
```

### Example: RemoteEvents

Methods such as `FireServer()` can also be called on supported Roblox objects:

```python
import roblox

remote = roblox.getdir("game.ReplicatedStorage.RemoteEvent")

remote.FireServer("Hello from Python!")
```

> **Note:** `FireServer()` can only be called from a client in the same situations where Roblox normally permits `RemoteEvent:FireServer()` to be called.

## Roblox API Access

The Roblox integration is designed to provide access to Roblox Instance functionality rather than creating a separate, limited API for every individual Roblox class.

As a result, Python-like code can interact with Roblox objects using their properties and methods.

For example:

```python
import roblox

part = roblox.getdir("workspace.Part")

part.Name = "Example"
part.Position = (0, 10, 0)
part.Anchored = true

part.Destroy()
```

The goal is for Python-like scripts to be able to interact with Roblox in much the same way that normal Luau code can.

This includes functionality such as:

* Reading Instance properties
* Setting Instance properties
* Calling Instance methods
* Creating Instances
* Destroying Instances
* Cloning Instances
* Firing RemoteEvents
* Interacting with Roblox services and objects
* Passing values between the Python-like runtime and Roblox
* Using Roblox APIs exposed by the underlying Instance

The exact functionality available depends on the capabilities currently implemented by the interpreter's Roblox bridge.

> **Note:** Roblox APIs that have special restrictions, such as client-only or server-only operations, still follow Roblox's normal execution rules. The interpreter does not bypass Roblox's security or replication model.

---

## Notes

The Roblox library is still under active development.

Additional functionality may be added in future versions, including additional Roblox-specific operations and improved support for interacting with Instances.

For the most accurate information, refer to the implementation in:

```text
src/Libraries/Roblox
```

and check the project's changelog for changes between versions.
