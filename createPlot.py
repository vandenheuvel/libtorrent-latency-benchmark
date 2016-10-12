import sys
import numpy as np
import matplotlib.pyplot as plt

numVars = 3
if len(sys.argv) != numVars + 1:
    print("Give me", numVars, "arguments!")

fileName = sys.argv[1]
testDuration = int(sys.argv[2])
latencyIntervals = int(sys.argv[3])

data = np.genfromtxt(fileName, delimiter=',')
delays = [latencyIntervals * step for step in range(len(data))]
lines = plt.plot(np.linspace(0, testDuration, len(data)), data)

for index, line in enumerate(lines):
    line.set_label(str(delays[index]) + "ms")

plt.ylabel("Download speed [kb / s]")
plt.xlabel("Time [s]")

plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0))

plt.legend()
plt.show()
