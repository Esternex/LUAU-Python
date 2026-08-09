# This script requires a Part to be placed in workspace.

import roblox

part = roblox.getdir("workspace.Part")

part.Name = "PythonPart"
part.Color = (0, 255, 0)
part.Position = (0, 10, 0)
part.Anchored = true

print("Created PythonPart!")
