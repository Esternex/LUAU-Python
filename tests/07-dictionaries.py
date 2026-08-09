player = {
    "name": "TestPlayer",
    "health": 100,
    "level": 5
}

print("Name:", player["name"])
print("Health:", str(player["health"]))
print("Level:", str(player["level"]))

player["health"] = player["health"] - 25

print("New health:", str(player["health"]))
