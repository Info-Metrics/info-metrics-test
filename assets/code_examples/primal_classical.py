#!/usr/bin/env python
# coding: utf-8

# In[1]:


# 3rd-party libraries
import numpy as np
from scipy.optimize import minimize
from scipy.stats import entropy

# Pretty-print numpy arrays
def pprint(x):
    print(np.array_str(x, precision=4, suppress_small=True))


# In[2]:


# Create data
np.random.seed(12345)

k = 10 # Number of parameters to be estimated
t = 8 # Number of observations

# Create true, unknown probabilities

alpha = np.repeat(k,k)
ptrue = np.random.dirichlet(alpha)

print("True Probabilities:")
pprint(ptrue)


X = np.random.normal(size=(t,k))
y = np.dot(X, ptrue)


# In[3]:


def classical_me_scipy(y, X, prob0=None):
    k = X.shape[1]

    # Objective function (to be minimized)
    def objective(p):
        return -entropy(p)  # negative because scipy.optimize.minimize performs minimization

    # Constraints
    cons = ({'type': 'eq', 'fun': lambda p: np.dot(X, p) - y},
            {'type': 'eq', 'fun': lambda p: np.sum(p) - 1})

    # Bounds
    bounds = [(0, 1) for _ in range(k)]

    # Initial guess
    if prob0 is None:
        prob0 = np.full(k, 1/k)

    # Solving the problem
    result = minimize(objective, prob0, method='SLSQP', bounds=bounds, constraints=cons) #sequential least squares programming algorithm

    if not result.success:
        raise ValueError("The problem was found to be infeasible")

    return result.x


# In[4]:


# Classical ME results
results_me_scipy = classical_me_scipy(y, X)
pprint(results_me_scipy)


# In[4]:


def classical_ce_scipy(prior, y, X, prob0=None):
    k = X.shape[1]

    # Objective function (to be minimized)
    def objective(p):
        return entropy(p, prior)

    # Constraints and bounds are the same as ME
    cons = ({'type': 'eq', 'fun': lambda p: np.dot(X, p) - y},
            {'type': 'eq', 'fun': lambda p: np.sum(p) - 1})
    bounds = [(0, 1) for _ in range(k)]

    # Initial guess
    if prob0 is None:
        prob0 = np.full(k, 1/k)

    # Solving the problem
    result = minimize(objective, prob0, method='SLSQP', bounds=bounds, constraints=cons)

    if not result.success:
        raise ValueError("The problem was found to be infeasible")

    return result.x


# In[5]:


# minimize cross-entropy

# Case A Uniform Priors CE = ME
prior1 = np.repeat(1/k, k)
results_ce1 = classical_ce_scipy(prior1, y, X)
pprint(results_ce1)

# Case B Random Incorrect Priors
prior2 = np.array([0.11, 0.10, 0.09, 0.07, 0.14, 0.13, 0.09, 0.11, 0.07, 0.09])
results_ce2 = classical_ce_scipy(prior2, y, X)
pprint(results_ce2)

# Case C Correct priors
prior3 = ptrue
results_ce3 = classical_ce_scipy(prior3, y, X)
pprint(results_ce3)


# In[ ]:




