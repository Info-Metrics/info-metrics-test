import numpy as np
import pandas
import statsmodels.api as sm
import openopt
from FuncDesigner import oovars, sum, log, dot
dta = pandas.read_table('./data/beer.csv', delimiter=" ",
                        names=["Y", "P_B", "P_L", "P_R", "Income"])
y = np.log(dta["Y"])
X = np.log(dta[["P_B", "P_L", "P_R", "Income"]])
X.insert(0, "constant", 1)
def linear_entropy_model(y, X, Z, V):
    """
    """
    nobs, k = X.shape
    Z = np.array(Z)
    V = np.array(V)
    m = len(Z)
    j = len(V)
    prob_names = ['prob%d' % d for d in range(k)]
    error_names = ["error%d" % d for d in range(nobs)]
    variables = oovars(*(prob_names + error_names))
    generalized_maximum_entropy = -sum(sum(var*log(var)) for var in variables)
    prob0 = dict(zip(variables[:k], [np.repeat(1./m, m)]*k) + \
                 zip(variables[k:], [np.repeat(1./j, j)]*nobs))
    problem = openopt.NLP(generalized_maximum_entropy, prob0)
    # each variable must sum to 1
    constraints = [vector.sum() == 1 for vector in variables]
    # sum(X * sum(Z, prob, 1), 1) + sum(V * error, 1) == y
    constraints += [sum(X[i] * [sum(Z * variables[d]) for d in range(m)]) +\
                    sum(V*variables[k+i]) == y[i] for i in range(nobs)]
    # each variable must be positive
    constraints += [vector > 0 for vector in variables]
    problem.constraints = constraints
    result = problem.maximize('scipy_slsqp')
    # pull the results out of the dictionary
    keys = {}
    for key, vector in res.xf.iteritems():
        keys.update({str(key) : key})
    probs = np.vstack([res.xf[keys['prob%d' % d]] for d in range(5)])
    errors = np.vstack([res.xf[keys['error%d' % d]] for d in range(30)])
    return probs, errors, result

Z = np.linspace(-5, 5, 5) * 100
V = np.linspace(-1, 1, 3) * y.std() * 3
probs, errors, res = linear_entropy_model(y, X, Z, V)
beta = np.dot(probs, Z)
