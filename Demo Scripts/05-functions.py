def calculate_energy(base, multiplier):
    return base * multiplier


def greet(name):
    print("Hello,", name)


greet("World")

energy = calculate_energy(50, 2)

print("Calculated energy:", str(energy))
