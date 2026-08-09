players = ["Alice", "Bob", "Charlie"]

print("Players:")

for player in players:
    print(player)

print("First player:", players[0])

players.append("David")

print("After adding David:")

for player in players:
    print(player)
