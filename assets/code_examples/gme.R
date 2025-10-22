library(numDeriv)
library(stats)

GMELogit <- R6::R6Class("GMELogit",
                        public = list(
                          beta = NULL,
                          vcov = NULL,
                          N = NULL,
                          K = NULL,
                          lnf = NULL,
                          lnf0 = NULL,
                          Sp = NULL,
                          S = NULL,
                          
                          f = function(x) {
                            ifelse(x == 0, 0, x * log(x))
                          },
                          
                          fit = function(X, y) {
                            self$N <- nrow(X)
                            self$K <- ncol(X)
                            
                            v1 <- c(-1/sqrt(self$N), 0, 1/sqrt(self$N))
                            
                            initial_params <- rep(0, self$K)
                            result_int <- optim(initial_params, self$objective, X = X, y = y, v1 = v1, method = "Nelder-Mead",
                                                control = list(maxit = 1000))
                            init <- result_int$par
                            result <- optim(init, self$objective, X = X, y = y, v1 = v1, method = "BFGS",
                                            control = list(maxit = 1000), hessian = TRUE)
                            
                            self$beta <- result$par
                            self$vcov <- solve(result$hessian)
                            self$lnf <- -result$value
                            self$lnf0 <- self$objective(rep(0, self$K), X, y, v1)
                            
                            P <- self$calculate_probabilities(X)
                            self$S <- -sum(self$f(P) + self$f(1 - P))
                            self$Sp <- self$S / (self$N * log(2))
                          },
                          
                          objective = function(params, X, y, v1) {
                            predictions <- 1 / (1 + exp(-X %*% params))
                            -sum(y * log(predictions) + (1 - y) * log(1 - predictions))
                          },
                          
                          calculate_probabilities = function(X) {
                            1 / (1 + exp(-X %*% self$beta))
                          },
                          
                          predict_proba = function(X) {
                            self$calculate_probabilities(X)
                          },
                          
                          summary = function() {
                            cat("Generalized Maximum Entropy (Logit)\n")
                            cat("Number of obs:", self$N, "\n")
                            cat("Degrees of freedom:", self$K, "\n")
                            cat("Entropy for probs:", sprintf("%.1f", self$S), "\n")
                            cat("Normalized entropy:", sprintf("%.4f", self$Sp), "\n")
                            
                            ERS <- 2 * self$N * log(2) * (1 - self$Sp)
                            p_value <- pchisq(ERS, self$K, lower.tail = FALSE)
                            
                            cat("Ent. ratio stat:", sprintf("%.1f", ERS), "\n")
                            cat("P Val for LR:", sprintf("%.4f", p_value), "\n")
                            cat("Criterion F (log L) =", sprintf("%.4f", self$lnf), "\n")
                            cat("Pseudo R2:", sprintf("%.4f", 1 - self$Sp), "\n")
                            
                            cat("\nCoefficients:\n")
                            for (i in 1:length(self$beta)) {
                              coef <- self$beta[i]
                              std_err <- sqrt(self$vcov[i, i])
                              t_stat <- coef / std_err
                              p_value <- 2 * (1 - pchisq(t_stat^2, 1))
                              cat(sprintf("X%d: %.4f (std err: %.4f, t-stat: %.4f, p-value: %.4f)\n",
                                          i-1, coef, std_err, t_stat, p_value))
                            }
                          }
                        )
)

# Usage example
# set.seed(0)
# X <- matrix(rnorm(5000), nrow = 1000)
# true_beta <- c(0.5, -0.3, 0.7, -0.2, 0.1, 0.6)  # including intercept
# y <- as.integer((1 / (1 + exp(-X %*% true_beta[-length(true_beta)] - true_beta[length(true_beta)]))) > 0.5)
# 
# # Fit the model
# model <- GMELogit$new()
# model$fit(X, y)
# 
# # Print summary
# model$summary()

# Make predictions
# X_new <- matrix(rnorm(50), nrow = 10)
# predictions <- model$predict_proba(X_new)
# cat("\nPredictions for new data:\n")
# print(predictions)