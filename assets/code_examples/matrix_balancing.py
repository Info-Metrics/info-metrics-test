"""
Author: Skipper Seabold
License: Modified BSD License
Created: 06-10-2012

File Description
----------------
Classical ME CE and Dual formulations for the Matrix Balancing problem:
  y=Ax where A is a K by K matrix and coefficients of each one of the K
  columns sum up to 1 (i.e., proper distribution).
  Example 1: an 11 by 11 SAM of the US
  Comparing the primal and concentrated (dual) models
  Try with the given priors and with uniform priors
"""
import numpy as np
import pandas
import openopt

# IO flows in 1977
q0 = pandas.read_csv('./data/io1977.csv')
q0.index = q0.columns # index and columns are the same

q = pandas.read_csv('./data/io1982.csv')
q.index = q.columns

# Convert data and prior flows to coefficients/probabilities

# row totals of data
Y = q.sum(1)
# column totals of data
X = q.sum(0)

# prior coefficients, columns add to 1
q1 = q0 / q0.sum(1)

q0_uniform = np.ones_like(q1) / len(q1)

# prediof for each a[i,j]

alpha = np.linspace(0,1,6)

# Positive variables
# p[k, i, j]
# a[i, j]
# Variables
# lm(i)


def entropy(prob, prior):
    return np.sum(prob * np.log(prob/prior))

def classical_ce(objective, a0, prob0, X, Y):
    """
    The pure Cross Entropy case

    In order to put the problem in the form expected by openopt, we have
    to solve in terms of a.T
    """
    k = a0.shape[0]
    Aeq = np.vstack((X, np.ones(k)))
    beq = np.vstack((Y, np.ones(k)))
    lb = [[0] * k] * k
    ub = [[1] * k] * k

    problem = openopt.NLP(objective, a0, Aeq=Aeq, beq=beq, lb=lb,
                          ub=ub, ftol=1e-12, iprint=-1, goal='min')
    problem.args.f = prob0

    solver = 'ralg'
    results = problem.solve(solver)
    try:
        assert result.isFeasible
    except:
        raise ValueError("The problem was found to be infeasible")
    return result

a_init = np.ones((11,11))/11
uniform = a_init.copy()
result_ce = classical_ce(entropy, a_init, uniform, X, Y)
