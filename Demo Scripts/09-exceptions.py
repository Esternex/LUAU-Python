def divide(a, b):
    if b == 0:
        raise ZeroDivisionError("Cannot divide by zero")

    return a / b


try:
    result = divide(10, 0)
    print(str(result))

except ZeroDivisionError as error:
    print("Caught exception:", str(error))

finally:
    print("Finished calculation.")
