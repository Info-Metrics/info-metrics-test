#!/usr/bin/env python
# coding: utf-8

# In[32]:


import numpy as np
import pandas as pd
import statsmodels.api as sm
from scipy.optimize import minimize

# Load data from CSV into a pandas DataFrame
dta = pd.read_table('beer.csv', delimiter=" ",
                    names=["Y", "P_B", "P_L", "P_R", "Income"])

# Convert "Y" column to numeric values
dta["Y"] = pd.to_numeric(dta["Y"], errors='coerce')

# Drop rows with missing values
dta = dta.dropna()

# Take the logarithm of the "Y" column and other selected columns
y = np.log(dta["Y"])
X = np.log(dta[["P_B", "P_L", "P_R", "Income"]])

# Insert a constant column at the beginning for the intercept
X.insert(0, "constant", 1)

def linear_entropy_model(y, X, Z, V):
    # Get the number of observations and features
    nobs, k = X.shape

    # Convert Z and V to numpy arrays
    Z = np.array(Z)
    V = np.array(V)

    # Get the number of elements in Z and V
    m = len(Z)
    j = len(V)

    # Generate names for probability and error variables
    prob_names = ['prob%d' % d for d in range(k)]
    error_names = ["error%d" % d for d in range(nobs)]

    # Initial values for probabilities and errors
    prob0 = np.concatenate([np.repeat(1.0 / m, m)] * k + [np.repeat(1.0 / j, j)] * nobs)

    def objective(prob_error):
        # Extract probabilities and errors from the combined array
        probs = prob_error[:k*m].reshape((k, m))
        errors = prob_error[k*m:].reshape((nobs, j))
        
        # Compute the generalized maximum entropy
        entropy = -np.sum(np.log(probs) * probs)
        return entropy

    def constraint(prob_error):
        # Extract probabilities and errors from the combined array
        probs = prob_error[:k*m].reshape((k, m))
        errors = prob_error[k*m:].reshape((nobs, j))
        
        # Constraint: sum(X * sum(Z, prob, 1), 1) + sum(V * error, 1) == y
        return np.sum(X * np.dot(Z, probs), axis=1) + np.dot(V, errors.T) - y

    # Set up equality constraints for the optimization problem
    constraints = [{'type': 'eq', 'fun': constraint}]
    
    # Set bounds for the variables
    bounds = [(0, None)] * len(prob0)

    # Solve the optimization problem using the SLSQP method
    result = minimize(objective, prob0, constraints=constraints, bounds=bounds, method='SLSQP')

    # Extract probabilities and errors from the result
    probs = result.x[:k*m].reshape((k, m))
    errors = result.x[k*m:].reshape((nobs, j))

    return probs, errors, result

# Generate sample data for Z and V
Z = np.linspace(-5, 5, 5) * 100
V = np.linspace(-1, 1, 3) * y.std() * 3

# Call the linear_entropy_model function
probs, errors, res = linear_entropy_model(y, X, Z, V)

# Calculate beta using the obtained probabilities and Z
beta = np.dot(probs, Z)


# In[ ]:




