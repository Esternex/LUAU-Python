print("Test 1")

try:
    print("Inside try")
finally:
    print("Finally executed")


print("Test 2")

try:
    raise ValueError("test")
except ValueError:
    print("Exception caught")
finally:
    print("Finally executed")
