# Load necessary libraries
library(dplyr)
library(stats)
library(pracma)

# Load data from CSV into a data frame
dta <- read.csv('beer.csv', col.names=c("Y", "P_B", "P_L", "P_R", "Income"))

# Convert "Y" column to numeric values
dta$Y <- as.numeric(dta$Y)

# Drop rows with missing values
dta <- na.omit(dta)

# Take the logarithm of the "Y" column and other selected columns
y <- log(dta$Y)
X <- log(dta %>% select(P_B, P_L, P_R, Income))

# Add a constant column for the intercept
X <- cbind(constant=1, X)

linear_entropy_model <- function(y, X, Z, V) {
  # Get the number of observations and features
  nobs <- nrow(X)
  k <- ncol(X)
  
  # Convert Z and V to matrices
  Z <- as.matrix(Z)
  V <- as.matrix(V)
  
  # Get the number of elements in Z and V
  m <- length(Z)
  j <- length(V)
  
  # Initial values for probabilities and errors
  prob0 <- c(rep(1.0 / m, m * k), rep(1.0 / j, j * nobs))
  
  objective <- function(prob_error) {
    # Extract probabilities and errors from the combined array
    probs <- matrix(prob_error[1:(k*m)], nrow=k)
    errors <- matrix(prob_error[(k*m + 1):length(prob_error)], nrow=nobs)
    
    # Compute the generalized maximum entropy
    entropy <- -sum(log(probs) * probs)
    
    # Print the gradient
    cat("Gradient Length:", length(prob_error), "\n")
    cat("Gradient:", prob_error, "\n")
    
    return(entropy)
  }
  
  constraint <- function(prob_error) {
    # Extract probabilities and errors from the combined array
    probs <- matrix(prob_error[1:(k*m)], nrow=k)
    errors <- matrix(prob_error[(k*m + 1):length(prob_error)], nrow=nobs)
    
    # Constraint: sum(X * sum(Z, prob, 1), 1) + sum(V * error, 1) == y
    return(rowSums(X * (probs %*% Z)) + (errors %*% V) - y)
  }
  
  # Solve the optimization problem using the SLSQP method
  result <- optim(prob0, objective, constraint, method='L-BFGS-B', lower=0)
  
  # Extract probabilities and errors from the result
  probs <- matrix(result$par[1:(k*m)], nrow=k)
  errors <- matrix(result$par[(k*m + 1):length(result$par)], nrow=nobs)
  
  return(list(probs=probs, errors=errors, result=result))
}

# Generate sample data for Z and V
Z <- seq(-5, 5, length.out=5) * 100
V <- seq(-1, 1, length.out=3) * sd(y) * 3

# Ensure dimensions of Z and V
stopifnot(length(Z) == 5)
stopifnot(length(V) == 3)

# Call the linear_entropy_model function
model_result <- linear_entropy_model(y, X, Z, V)

# Calculate beta using the obtained probabilities and Z
beta <- model_result$probs %*% Z

# Print results to screen
print(beta)
