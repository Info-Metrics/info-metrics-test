#!/usr/bin/env python
# coding: utf-8

# In[9]:


import numpy as np
from scipy import optimize
from scipy.special import logsumexp #import logsumexp from a different package in scipy instead of scipy.misc

np.random.seed(12345)
k = 10
t = 1

alpha = np.repeat(k,k)
ptrue = np.random.dirichlet(alpha)

X = np.random.normal(size=(t,k))
y = np.dot(X, ptrue)

def objective_me_dual(lm, y, X):
    """
    The dual concentrated maximum entropy

    Parameters
    ----------
    lm : array-like
        The unknown Langrage multipliers
    y : array
        The value of the moment
    X : array
        The data
    """
    return np.dot(y, lm) + logsumexp(-np.dot(lm, X))

lm0 = np.array([0.1])
result_me = optimize.minimize(objective_me_dual, lm0, args=(y,X),
                              method="BFGS", options=dict(gtol=1e-12))
lm_res = result_me['x']

p = np.exp(-np.dot(lm_res,X))

partition = p.sum()

p = p / partition

print(p) #Add parenthesis

def logsumexp_b(a, b, axis=None):
    """
    Compute the log of the sum of scaled exponentials of inputs.

    Parameters
    ----------
    a : array-like
        Input array
    b : array-like
        Scaling factor for exp(`a`) must be of the same shape as `a` or
        broadcastable to `a`.
    axis : int, optional
        Axis over which the sum is taken. By default `axis` is None, and
        all elements are summed.

    Returns
    -------
    res : ndarray
        The result, ``np.log(np.sum(b*np.exp(a)))`` calculated in a numerically
        more stable way.

    Examples
    --------
    >>> import numpy as np
    >>> from scipy.misc import logsumexp_b
    >>> a = np.arange(10)
    >>> b = np.arange(10, 0, -1)
    >>> logsumexp_b(a, b)
    9.9170178533034665
    >>> np.log(np.sum(b*np.exp(a)))
    9.9170178533034647
    """
    a = np.asarray(a) #add np. before asarray when defining both a and b
    b = np.asarray(b)
    if axis is None:
        a = a.ravel()
        b = b.ravel()
    else:
        a = rollaxis(a, axis)
        b = rollaxis(b, axis)
    a_max = a.max(axis=0)
    out = np.log(np.sum(b * np.exp(a - a_max), axis=0)) #add np. before log, sum and exp
    out += a_max
    return out

def objective_ce_dual(lm, prior, y, X):
    """
    The dual concentrated cross entropy

    Parameters
    ----------
    lm : array-like
        The unknown Langrage multipliers
    y : array
        The value of the moment
    X : array
        The data
    """
    return -(np.dot(y, lm) - logsumexp_b(np.dot(lm, X), prior))

lm0 = np.array([0.1])
prior = np.repeat(1./k, k)
result_ce = optimize.minimize(objective_ce_dual, lm0, args=(prior, y, X),
                                method="BFGS",  options=dict(gtol=1e-12))
lm_res_ce = result_ce['x']

p_ce = np.exp(-np.dot(lm_res_ce, X))

partition = p_ce.sum()

p_ce = p_ce / partition


# In[ ]:




