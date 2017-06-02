"""
Author: Skipper Seabold
License: Modified BSD License
Created: 5-21-2012

Slightly modified by Alan G. isaac 2017-04-13

File Description
----------------
Explore the properties of the Entropy function graphically.
"""

# 3rd-party libraries
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import entropy

# make a grid in [0,.5) that is finer near-zero
prob = np.exp(np.linspace(-15, 0, 1000))

fig, (ax1, ax2) = plt.subplots(2, 1,
                               sharex=True,
                               figsize=(6,6),
                               dpi=300
                               )

ax1.plot(prob, -np.log2(prob))
ax1.set(ylabel="Information", #xlabel is shared
        ylim=(-.1, 22),
        xlim=(-.01, 1.0))

probs = zip(prob, 1-prob) # each row is a Bernoulli probability
entropy2 = lambda prob : entropy(prob, base=2)

ax2.plot(prob, map(entropy2, probs))
ax2.set(ylabel="Entropy",
        xlabel="Probability"
        )

fig.subplots_adjust(bottom=0.1)  #add space for label
plt.show()
