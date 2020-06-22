import nstrace as ns
import numpy as np
import matplotlib.pyplot as plt

def find_max_time(events):
    times = []
    for e in events:
        times.append(e[1])
    return max(times)

ns.nsopen('out.tr')

events = []
variables = []

while(not ns.isEOF()):
    if ns.isEvent():
        events.append(ns.getEvent())
    elif ns.isVar():
        variables.append(ns.getVar())

varaibles_types = set()

for v in variables:
    varaibles_types.add(v[5])

#plotting cwnd wrt. time
time = [tup[0] for tup in variables if tup[5]=='cwnd_']
value = [tup[6] for tup in variables if tup[5]=='cwnd_']
plt.xticks(np.arange(0, max(time),1))
plt.yticks(np.arange(0, max(value), 5))
plt.plot(time, value, 'r.')
plt.grid(linestyle='-')
plt.show()

#plotting packet-losses wrt. time
time = np.arange(find_max_time(events), )
# value = 
plt.plot(time, value, 'r.')
plt.grid(linestyle='-')
plt.show()