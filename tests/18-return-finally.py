def test():
    try:
        return 10
    finally:
        print("Finally executed")


result = test()

print("Returned:", str(result))
