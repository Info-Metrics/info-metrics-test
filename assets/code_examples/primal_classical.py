"""
Author: Skipper Seabold
License: Modified BSD License
Created:

File Description
----------------
"""
from __future__ import division # force floating point division

# 3rd-party libraries
import openopt
import numpy as np
np.random.seed(12345)

k = 10
t = 1

# Create the True, unknown, probabilities

alpha = np.repeat(k,k)
ptrue = np.random.dirichlet(alpha)

X = np.random.normal(size=(t,k))
y = np.dot(X, ptrue) # no noise

# Solve the problem in the primal form using OpenOpt

def classical_me(objective, y, X, prob0=None):
    """
    Maximize the classical Maximum Entropy in terms of p with the moment
    constraint given below.

    Parameters
    ----------
    objective : func
        The objective function
    y : array
        The value of the moment
    X : array
        The data
    prob0 : array, optional
        A first guess on the probabilities for the optimizer. If not given,
        uniform probabilities are given.

    Model:

    max = p * log(p)
     p

    s.t.

    p > 0
    sum(p) == 1
    y == dot(X,p)

    Notes
    -----

    To specify NLP programming problems in OpenOpt the constraints
    have to be put in the following algebraic form. See
    http://openopt.org/NLP

	min/max obj function

	subjected to

	# lb<= x <= ub:
 	# Ax <= b
 	# Aeq x = beq
 	# c(x) <= 0
 	# h(x) = 0
    """
    k = X.shape[1]
    Aeq = np.vstack((np.atleast_2d(X), np.ones(k)))
    beq = np.hstack((y, 1))
    lb = np.zeros(k)
    ub = np.ones(k)
    if prob0 is None:
        prob0 = np.repeat(1/k, k)

    problem = openopt.NLP(objective, prob0, Aeq=Aeq, beq=beq, lb=lb,
                          ub=ub, ftol=1e-12, _print=-1, goal='max')
    #use the best solver you have installed, if you
    #if you haven't built the other optional installers, use
    solver = 'ralg'
    result = problem.solve(solver)
    try:
        assert result.isFeasible # make sure everything is okay
    except:
        raise ValueError("The problem was found to be infeasible")
    return result

# Use the entropy function from scipy.stats
from scipy.stats import entropy

# maximize classical ME
results_me = classical_me(entropy, y, X)
print results_me.xf

def classical_ce(objective, prior, y, X, prob0=None):
    """
    Maximize the classical Maximum Entropy in terms of p with the moment
    constraint given below.

    Parameters
    ----------
    objective : func
        The objective function
    y : array
        The value of the moment
    X : array
        The data
    prob0 : array, optional
        A first guess on the probabilities for the optimizer. If not given,
        uniform probabilities are given.
    prior : array, optional
        The prior for the classical cross-entropy model.

    Model:

    max = p * log(p/prior)
     p

    s.t.

    p > 0
    sum(p) == 1
    y == dot(X, p)

    Notes
    -----

    To specify NLP programming problems in OpenOpt the constraints
    have to be put in the following algebraic form. See
    http://openopt.org/NLP

	min/max obj function

	subjected to

	# lb<= x <= ub:
 	# Ax <= b
 	# Aeq x = beq
 	# c(x) <= 0
 	# h(x) = 0
    """
    k = X.shape[1]
    Aeq = np.vstack((X, np.ones(k)))
    beq = np.hstack((y,1))
    lb = np.zeros(k)
    ub = np.ones(k)
    if prob0 is None:
        prob0 = np.repeat(1/k, k)

    problem = openopt.NLP(objective, prob0, Aeq=Aeq, beq=beq, lb=lb,
                          ub=ub, ftol=1e-12, iprint=-1, goal='min')
    problem.args.f = prior
    #use the best solver you have installed, if you
    #if you haven't built the other optional installers, use
    solver = 'ralg'
    result = problem.solve(solver)
    try:
        assert result.isFeasible # make sure everything is okay
    except:
        raise ValueError("The problem was found to be infeasible")
    return result

# minimize cross-entropy

# Case A Uniform Priors CE = ME
prior1 = np.repeat(1/k, k)
results_ce1 = classical_ce(entropy, prior1, y, X)
print results_ce1.xf

# Case B Random Incorrect Priors
prior2 = np.random.dirichlet(alpha)
results_ce2 = classical_ce(entropy, prior2, y, X)
print results_ce2.xf

# Case C Correct priors
prior3 = ptrue
results_ce3 = classical_ce(entropy, prior3, y, X)
print results_ce3.xf
