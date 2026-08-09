try:
    try:
        raise ValueError("inner error")
    except TypeError:
        print("Wrong exception type")
except ValueError as error:
    print("Outer handler caught:", str(error))
