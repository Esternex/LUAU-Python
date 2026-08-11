# Changelog

## version 0.2.0
* Added new roblox methods
* roblox.Vector3() - Creates a Vector3 object
* roblox.CFrame() - Creates a CFrame object with near-exact syntax to roblox
* roblox.require() - Requires any module and lets you use functions

* Changed some naming to use python naming conventions
* roblox.getdir -> roblox.get_dir
* roblox.createinstance -> roblox.create_instance

- Note: You can still use tuples for setting Size, Position and CFrame

## version 0.1.3
* Modified the roblox library
* Added support for creating UI elements
* You can now use variables inside roblox.getdir() and roblox.find()
* roblox.find() now searches through the properties instead of just being a direct roblox.getdir() clone (e.g. .find() can get LocalPlayer but .getdir() cannot)

## version 0.1.2
* Added tuples for modifying color, size and position of parts instead of Vector3 and such.
* Added roblox.createinstance()

## version 0.1.1
* Added interpreter tests.
* Added example/demo scripts.

## version 0.1.0
* Initial public release.
* Added the core Python-like lexer and parser.
* Added variables, expressions, and basic types.
* Added functions and classes.
* Added if / elif / else.
* Added while and for loops.
* Added break and continue.
* Added try / except / else / finally.
* Added exception propagation and inheritance.
* Added lists and dictionaries.
* Added built-in functions.
* Added random, math, and time libraries.
* Added the roblox library.
* Added support for custom libraries.
* Added initial Roblox integration.
