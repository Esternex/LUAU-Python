print("Testing ZeroDivisionError:")

try:
    result = 10 / 0
    print(str(result))
except ZeroDivisionError as error:
    print("Caught:", str(error))

print("Testing ValueError:")

try:
    raise ValueError("Test value error")
except ValueError as error:
    print("Caught:", str(error))

print("Finished.")
