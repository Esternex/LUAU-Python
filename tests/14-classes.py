class Counter:
    def __init__(self, value):
        self.value = value

    def increment(self):
        self.value = self.value + 1

    def get_value(self):
        return self.value


counter = Counter(0)

counter.increment()
counter.increment()
counter.increment()

print("Counter:", str(counter.get_value()))
