**** Model replication of Optimal Portfolio Diversification Using the Maximum
**** Entropy Principle by Bera, A.K. and Park, S.Y.
** Inequality portfolio, this file corresponds to the model in 493, eq. 12

set      i   Portfolios           /health, utility, other/
         k   # of observations    /1*1/
;
alias (j,i);

parameter    phat(i)      estimated shares
             muhat(k)
             sigmahat(k)
             mu0(k)       Portfolio mean
             sd(k)        Standard deviation of asset returns
             return(k,i)  Return on asset
             q(i)         Priors
             cov(i,i)     Covarianve matrix
             sigma(k)     SD




;

return(k, "health")  =  1.551 ;
return(k, "utility") =  1.156 ;
return(k, "other")   =  1.215 ;

**** Priors
q(i)                 = 1/card(i);

*** Mean of portfolio
mu0(k)               =  1.35   ;

*** Cov matrix of different investment options
table cov(i,i) covariance matrix

                 health    utility  other
health           57.298    12.221   33.026
utility          12.221    13.168   11.814
other            33.026    11.814   27.952 ;

*****
sigma(k)   =   sqrt(sum(i,sum(j,q(i)*q(j)*cov(i,j))))
*sigma(k) = 3.9408451


display sigma;


positive variables
       p(i) estimated probabilities

;

variables
        obj  objective function
;

equations

object_me   ME objective function
object_ce   CE objective function
proper_prob The proper prob requirement - normalization
moments(k)  The data points - observed moments
covar(k)  The data points - observed covariance
;

object_me..  obj =e= - sum(i,p(i)*log((p(i)+1.e-8)));
proper_prob.. sum(i,p(i)) =e= 1;
moments(k)..  mu0(k) =l= sum(i,return(k,i)*p(i));
covar(k)..  sigma(k) =g= sqrt(sum(i,sum(j,p(i)*p(j)*cov(i,j))));

model Uno /object_me
           proper_prob
           moments
           covar
/;

solve Uno maximizing obj using nlp;

phat(i) = p.l(i)  ;
muhat(k)= sum(i,return(k,i)*p.l(i));
sigmahat(k)= sqrt(sum(i,sum(j,p.l(i)*p.l(j)*cov(i,j)))) ;

display phat,muhat ,sigmahat, sigma, mu0;

