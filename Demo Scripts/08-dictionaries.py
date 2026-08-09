player = {
    "name": "Alice",
    "level": 25,
    "health": 100
}

print("Name:", player["name"])
print("Level:", str(player["level"]))
print("Health:", str(player["health"]))

player["health"] = 75

print("Updated health:", str(player["health"]))
