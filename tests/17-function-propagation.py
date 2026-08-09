def level_one():
    level_two()


def level_two():
    level_three()


def level_three():
    raise ValueError("deep error")


try:
    level_one()
except ValueError as error:
    print("Exception propagated:", str(error))
