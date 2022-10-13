
**** Model replication of Optimal Portfolio Diversification Using the Maximum
**** Entropy Principle by Bera, A.K. and Park, S.Y.
** Utility portfolio, this file corresponds to the model in page 496, eq. 21 (although CE is not included) 

set      i   Portfolios           /health, utility, other/
         k   # of observations    /1*1/
;
alias (j,i);

parameter    phat(i)      estimated shares
             muhat        estimated mean return
             sigmahat     estimated SD of return
             mu0          Portfolio mean
             sd           Standard deviation of asset returns
             return(i)    Return on asset
             q(i)         Priors
             cov(i,i)     Covarianve matrix
             sigma        SD
             lambda       Risk aversion parameter
             ximax           Shrinkage parameter


;

return("health")  =  1.551 ;
return("utility") =  1.156 ;
return("other")   =  1.215 ;

**** Priors
q(i)                 = 1/card(i);

*** Cov matrix
table cov(i,i) covariance matrix

                 health    utility  other
health           57.298    12.221   33.026
utility          12.221    13.168   11.814
other            33.026    11.814   27.952 ;

*** Risk aversion parameter
lambda=0.06;

positive variables
       p(i)    estimated probabilities
       pmax(i) p for max utility

;

variables
        obj  objective function
;



equations

object_me         ME objective function
object_ce         CE objective function
proper_prob       The proper prob requirement - normalization
proper_prob_max   The proper prob requirement - normalization
Shrink            The shrinkage moment
Shrink2           The shrinkage moment
;

**** Solve for maximum XI
Shrink.. obj =e=   sum(i,return(i)*pmax(i)) - (lambda/2)*(sum(i,sum(j,pmax(i)*pmax(j)*cov(i,j))));
proper_prob_max.. sum(i,pmax(i)) =e= 1;

model uno /Shrink
          proper_prob_max
/;

solve uno maximizing obj using nlp;

ximax = sum(i,return(i)*pmax.l(i)) - (lambda/2)*(sum(i,sum(j,pmax.l(i)*pmax.l(j)*cov(i,j))));

display ximax, pmax.l;

***** Solve ME problem

object_me..   obj =e= - sum(i,p(i)*log((p(i)+1.e-8)));
proper_prob.. sum(i,p(i)) =e= 1;
Shrink2..     ximax=l= sum(i,return(i)*p(i)) - (lambda/2)*(sum(i,sum(j,p(i)*p(j)*cov(i,j))));

model dos /object_me
           proper_prob
           Shrink2
/;

solve dos maximizing obj using nlp;

display p.l, pmax.l;








