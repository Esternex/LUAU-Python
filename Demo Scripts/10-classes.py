class Player:
    def __init__(self, name, health):
        self.name = name
        self.health = health

    def damage(self, amount):
        self.health = self.health - amount

    def print_status(self):
        print(self.name, "has", str(self.health), "health")


player = Player("Alice", 100)

player.print_status()

player.damage(25)

player.print_status()
