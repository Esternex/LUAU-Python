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
