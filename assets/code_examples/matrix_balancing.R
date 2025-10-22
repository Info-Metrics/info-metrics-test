library(tidyverse)
library(nloptr)

# Read data
q0 <- read.csv('../../data/io1977.csv')
q <- read.csv('../../data/io1982.csv')

# Convert data and prior flows to coefficients/probabilities
Y <- rowSums(q)
X <- colSums(q)

# Prior coefficients, columns add to 1
q1 <- q0 / rowSums(q0)
q0_uniform <- matrix(1/nrow(q1), nrow(q1), ncol(q1))

# R: Modified entropy function
entropy <- function(prob, prior) {
  epsilon <- 1e-12
  sum(prob * log((prob + epsilon) / (prior + epsilon)), na.rm = TRUE)
}


# Classical Cross Entropy function
classical_ce <- function(a0, prob0, X, Y) {
  k <- nrow(a0)
  
  objective <- function(params) {
    a <- matrix(params, k, k)
    entropy(a, prob0)
  }
  
  constraint_row <- function(params) {
    a <- matrix(params, k, k)
    rowSums(a * matrix(X, k, k, byrow = TRUE)) - Y
  }
  
  constraint_col <- function(params) {
    a <- matrix(params, k, k)
    colSums(a) - 1
  }
  
  result <- nloptr(x0 = as.vector(a0),
                   eval_f = objective,
                   lb = rep(0, k*k),
                   ub = rep(1, k*k),
                   eval_g_eq = function(x) c(constraint_row(x), constraint_col(x)),
                   opts = list(algorithm = "NLOPT_LN_COBYLA",
                               maxeval = 1000,
                               xtol_rel = 1e-12))
  
  final_a <- matrix(result$solution, k, k)
  
  return(list(final_a = final_a, result = result))
}

# Initialize
a_init <- matrix(1/11, 11, 11)
uniform <- a_init

# Solve
solution <- classical_ce(a_init, q0_uniform, X, Y)
final_a <- solution$final_a
colnames(final_a) <- colnames(q1)
rownames(final_a) <- rownames(q1)
result <- solution$result

# Print results
print(final_a)
