print("=== BUILT-IN ERROR TESTS ===")

try:
    items = [1, 2, 3]
    print(items[100])
except IndexError:
    print("PASS: IndexError")

try:
    data = {
        "name": "test"
    }

    print(data["missing"])
except KeyError:
    print("PASS: KeyError")

try:
    result = "hello" + 123
except TypeError:
    print("PASS: TypeError")

try:
    raise ValueError("test")
except ValueError:
    print("PASS: ValueError")
