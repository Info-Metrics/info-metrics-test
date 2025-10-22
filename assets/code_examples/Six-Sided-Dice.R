# Load necessary libraries
library(stats)
library(pracma)
library(ggplot2)

# Set a seed for the random number generator
set.seed(12345)

# Create the x's
x <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
x

entropy <- function(p, base=exp(1)) {
  return(-sum(ifelse(p > 0, p * log(p, base = base), 0)))
}

# Define the objective
obj <- function(p) {
  return(-entropy(p, base = exp(1)))
}

# Interested in various values of y (the observed mean)
list <- c(2, 3.5, 5)
print(list)

# Run: 
results <- data.frame()
for (y in list) {
  # constraints
  cons <- function(p) {
    return(c(sum(p) - 1, sum(p * x) - y))
  }
  # optimize and save results
  res <- fmincon(x0 = rep(1/6, 6), fn = obj, gr = NULL, Aeq = NULL, beq = NULL, lb = rep(0, 6), ub = rep(1, 6), heq = cons)
  p <- res$par
  print(p)
  temp_df <- data.frame(x = x, p = p, y_value = as.factor(y))
  results <- rbind(results, temp_df)
}

# Plot the results
ggplot(results, aes(x = x, y = p, color = y_value, linetype = y_value)) + 
  geom_point() + 
  geom_line() + 
  labs(title = "Probability Distributions for Different y Values", color = "Observed Mean (y)", linetype = "Observed Mean (y)") + 
  ylim(0, 1) + 
  theme_minimal()
