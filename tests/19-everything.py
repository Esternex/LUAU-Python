def calculate(value):
    if value < 0:
        raise ValueError("Value cannot be negative")

    return value * 2


numbers = [10, 20, 30]

total = 0

for number in numbers:
    total = total + number


print("Total:", str(total))


try:
    result = calculate(50)

    print("Calculation:", str(result))

except ValueError as error:
    print("Error:", str(error))

finally:
    print("Calculation finished")


try:
    result = calculate(-1)

    print("Calculation:", str(result))

except ValueError as error:
    print("Caught expected error:", str(error))

finally:
    print("Error test finished")
