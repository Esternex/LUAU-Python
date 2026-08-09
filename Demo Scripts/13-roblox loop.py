# This script requires a Part to be placed in workspace.

import roblox
import time

part = roblox.getdir("workspace.Part")

part.Anchored = true

for i in range(10):
    part.Position = (i, 10, 0)

    print("Moved part to:", str(i))

    time.sleep(0.1)

print("Finished!")
