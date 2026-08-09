def test(value):
    if value == 0:
        raise ZeroDivisionError("zero")

    if value < 0:
        raise ValueError("negative")

    return value


try:
    print(str(test(10)))
except ZeroDivisionError:
    print("Zero error")
except ValueError:
    print("Value error")


try:
    print(str(test(0)))
except ZeroDivisionError:
    print("Zero error")
except ValueError:
    print("Value error")


try:
    print(str(test(-10)))
except ZeroDivisionError:
    print("Zero error")
except ValueError:
    print("Value error")
