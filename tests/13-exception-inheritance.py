try:
    raise ZeroDivisionError("test")
except ArithmeticError as error:
    print("Caught through ArithmeticError:", str(error))
