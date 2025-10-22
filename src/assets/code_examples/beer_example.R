# Load required libraries
library(dplyr)
library(stats)
library(nloptr)

# Load data from CSV into a data frame
dta <- read.table('../../data/beer.csv', header = TRUE, sep = ",")

# Rename 'q' to 'Y'
names(dta)[names(dta) == "q"] <- "Y"

# Drop rows with missing values
dta <- na.omit(dta)

# Take the logarithm of the "Y" column and other selected columns
y <- as.vector(log(dta$Y))
X <- as.matrix(log(dta[, c("pB", "pL", "pR", "income")]))

# Add a constant column for the intercept
X <- cbind(constant = 1, X)

linear_entropy_model <- function(y, X, Z, V) {
  # Get the number of observations and features
  nobs <- nrow(X)
  k <- ncol(X)
  
  # Convert Z and V to vectors
  Z <- as.vector(Z)
  V <- as.vector(V)
  
  # Get the number of elements in Z and V
  m <- length(Z)
  j <- length(V)
  
  # Initial values for probabilities and errors
  prob0 <- c(rep(rep(1 / m, m), k), rep(rep(1 / j, j), nobs))
  
  objective <- function(prob_error) {
    # Extract probabilities and errors from the combined vector
    probs <- matrix(prob_error[1:(k*m)], nrow = k, ncol = m)
    
    # Compute the generalized maximum entropy
    entropy <- -sum(log(probs) * probs)
    return(entropy)
  }
  
  
  constraint <- function(prob_error) {
    # Extract probabilities and errors from the combined vector
    probs <- matrix(prob_error[1:(k*m)], nrow = k, ncol = m)
    errors <- matrix(prob_error[(k*m+1):length(prob_error)], nrow = nobs, ncol = j)
    
    # Calculate beta
    beta <- probs %*% Z
    
    # Calculate Xbeta
    Xbeta <- X %*% beta
    
    # Calculate error term
    error_term <- errors %*% V
    
    # Return the constraint
    return(Xbeta + error_term - y)
  }
  
  # Set up equality constraints for the optimization problem
  eval_g_eq <- function(prob_error) {
    return(constraint(prob_error))
  }
  
  # Set bounds for the variables
  lb <- rep(1e-10, length(prob0))  # Small positive number to avoid log(0)
  ub <- rep(1, length(prob0))
  
  # Solve the optimization problem using COBYLA method
  result <- nloptr(x0 = prob0,
                   eval_f = objective,
                   eval_g_eq = eval_g_eq,
                   lb = lb,
                   ub = ub,
                   opts = list("algorithm" = "NLOPT_LN_COBYLA",
                               "xtol_rel" = 1.0e-8,
                               "maxeval" = 1000))
  
  # Extract probabilities and errors from the result
  probs <- matrix(result$solution[1:(k*m)], nrow = k, ncol = m)
  errors <- matrix(result$solution[(k*m+1):length(result$solution)], nrow = nobs, ncol = j)
  
  return(list(probs = probs, errors = errors, result = result))
}

# Generate sample data for Z and V
Z <- seq(-5, 5, length.out = 5) * 100
V <- seq(-1, 1, length.out = 3) * sd(y) * 3

# Call the linear_entropy_model function
model_results <- linear_entropy_model(y, as.matrix(X), Z, V)

# Calculate beta using the obtained probabilities and Z
beta <- model_results$probs %*% Z

# Print results to screen
col_names <- colnames(X)

for (i in 1:length(col_names)) {
  cat(sprintf("%s:\t%.2e\n", col_names[i], beta[i]))
}