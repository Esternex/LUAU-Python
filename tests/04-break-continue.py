print("Break test:")

for i in range(10):
    if i == 5:
        break

    print(str(i))

print("Continue test:")

for i in range(10):
    if i % 2 == 0:
        continue

    print(str(i))
