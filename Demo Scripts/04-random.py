import random

print("Rolling a dice...")

roll = random.randint(1, 6)

print("You rolled:", str(roll))

if roll == 6:
    print("Critical roll!")
else:
    print("Better luck next time.")
