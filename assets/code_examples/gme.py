import numpy as np
import pandas as pd
from scipy.optimize import minimize
from scipy.stats import chi2

class GMELogit:
    def __init__(self):
        self.beta = None
        self.vcov = None
        self.N = None
        self.K = None
        self.lnf = None
        self.lnf0 = None
        self.Sp = None
        self.S = None

    def f(self, x):
        """
        Compute f(x) with specified behavior:
        - f(x) = 0 if x is zero
        - f(x) = x * log(x) if x is not zero
        """
        return np.where(x == 0, 0, x * np.log(x))

    def fit(self, X, y):
        self.N, self.K = X.shape
        
        # Create error vector, Symmetric error support vector
        v1 = np.array([-1/np.sqrt(self.N), 0, 1/np.sqrt(self.N)])
        
        # Optimization
        initial_params = np.zeros(self.K)
        result_int = minimize(self._objective, initial_params, args=(X, y, v1), method='Nelder-Mead',
                          options = {'maxiter': 1000, 'disp': False})
        init = result_int.x
        result = minimize(self._objective, initial_params, args=(X, y, v1), method='BFGS',
                          options = {'maxiter': 1000, 'disp': False})
        
        self.beta = result.x
        self.vcov = result.hess_inv
        self.lnf = -result.fun
        self.lnf0 = self._objective(np.zeros_like(self.beta), X, y, v1)
        
        # Calculate normalized entropy
        P = self._calculate_probabilities(X)
        self.S = -np.sum(self.f(P) + self.f(1 - P))
        self.Sp = self.S / (self.N * np.log(2))
        
    def _objective(self, params, X, y, v1):
        # Ensure X is a numpy array
        if isinstance(X, pd.DataFrame):
            X = X.values

        # Ensure y is a numpy array
        if isinstance(y, pd.Series):
            y = y.values

        # Calculate predictions
        predictions = 1 / (1 + np.exp(-np.dot(X, params)))

        # Calculate log likelihood
        log_likelihood = -np.sum(y * np.log(predictions) + (1 - y) * np.log(1 - predictions))
        
        return log_likelihood

    def _calculate_probabilities(self, X):
        return 1 / (1 + np.exp(-X @ self.beta))

    def predict_proba(self, X):
        return self._calculate_probabilities(X)

    def summary(self):
        print("Generalized Maximum Entropy (Logit)")
        print(f"Number of obs: {self.N}")
        print(f"Degrees of freedom: {self.K}")
        print(f"Entropy for probs: {self.S:.1f}")
        print(f"Normalized entropy: {self.Sp:.4f}")
        
        # Calculate Entropy Ratio Statistic
        ERS = 2 * self.N * np.log(2) * (1 - self.Sp)
        p_value = chi2.sf(ERS, self.K)
        
        print(f"Ent. ratio stat: {ERS:.1f}")
        print(f"P Val for LR: {p_value:.4f}")
        print(f"Criterion F (log L) = {self.lnf:.4f}")
        print(f"Pseudo R2: {1 - self.Sp:.4f}")
        
        print("\nCoefficients:")
        for i, coef in enumerate(self.beta):
            std_err = np.sqrt(self.vcov[i, i])
            t_stat = coef / std_err
            p_value = 2 * (1 - chi2.cdf(t_stat**2, 1))
            print(f"X{i}: {coef:.4f} (std err: {std_err:.4f}, t-stat: {t_stat:.4f}, p-value: {p_value:.4f})")

# Usage example
if __name__ == "__main__":
    # Generate some example data
    np.random.seed(0)
    X = np.random.randn(1000, 5)
    true_beta = np.array([0.5, -0.3, 0.7, -0.2, 0.1, 0.6])  # including intercept
    y = (1 / (1 + np.exp(-X @ true_beta[:-1] - true_beta[-1])) > 0.5).astype(int)

    # Fit the model
    model = GMELogit()
    model.fit(X, y)

    # Print summary
    model.summary()

    # Make predictions
    X_new = np.random.randn(10, 5)
    predictions = model.predict_proba(X_new)
    print("\nPredictions for new data:")
    print(predictions)