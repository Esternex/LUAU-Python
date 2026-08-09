try:
    try:
        raise ValueError("original error")
    except ValueError:
        print("Inner handler")
        raise
except ValueError as error:
    print("Outer handler:", str(error))
