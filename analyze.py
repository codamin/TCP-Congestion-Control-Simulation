import nstrace as ns
import matplotlib.pyplot as plt

ns.nsopen('out.tr')

events = []
variables = []

while(not ns.isEOF()):
    if ns.isEvent():
        events.append(ns.getEvent())
    elif ns.isVar():
        variables.append(ns.getVar())

#plotting cwnd wrt. time
time = [tup[0] for tup in variables]
value = [tup[6] for tup in variables]
plt.plot(time, value, 'g--')
plt.show()