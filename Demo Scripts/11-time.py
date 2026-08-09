import time

print("Starting timer...")

start = time.time()

total = 0

for i in range(1000):
    total = total + i

finish = time.time()

print("Calculation result:", str(total))
print("Elapsed time:", str(finish - start))
