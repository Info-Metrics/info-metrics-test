#!/usr/bin/env python
# coding: utf-8

# In[2]:


# 3rd-party libraries
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import entropy

# make a grid in [0,.5) that is finer near-zero
prob = np.exp(np.linspace(-15, 0, 1000))

fig = plt.figure()
ax = fig.add_subplot(111)

ax.plot(prob, -np.log2(prob))
ax.set(ylabel="Information", xlabel="Probability", ylim=(-.1, 22),
       xlim=(-.01, 1.1))
plt.show()

fig = plt.figure(figsize=(8,6))
ax = fig.add_subplot(111)

probs = zip(prob, 1-prob) # each row is a Bernoulli probability
entropy2 = lambda prob : entropy(prob, base=2)
ax.plot(prob, list(map(entropy2, probs))) #add list() before map()
ax.set(ylabel="Entropy", xlabel="Probability")
plt.show()


# In[ ]:




