
**** Model replication of Optimal Portfolio Diversification Using the Maximum
**** Entropy Principle by Bera, A.K. and Park, S.Y.
** 1) Simple case portfolio, this file corresponds to the model in page 492, eq.9 

set      i   Portfolios           /health, utility, other/
         k   # of observations    /1*1/
;
alias (j,i);

parameter    phat(i)      estimated shares
             mu0(k)       Portfolio mean
             sd(k)        Standard deviation of asset returns
             return(k,i)  Return on asset
             q(i)         Priors
             muhat(k)     Portfolio ME return


;

return(k, "health")  =  1.551 ;
return(k, "utility") =  1.156 ;
return(k, "other")   =  1.215 ;

*** Mean of portfolio
mu0(k)               =  1.2   ;

q(i)                 = 1/card(i);


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
;

object_me..  obj =e= - sum(i,p(i)*log((p(i)+1.e-8)));
proper_prob..          sum(i,p(i)) =e= 1;
moments(k)..  mu0(k) =e= sum(i,return(k,i)*p(i));

model Uno /object_me
           proper_prob
           moments
/;

solve Uno maximizing obj using nlp;

phat(i) = p.l(i)  ;
muhat(k) =  sum(i,return(k,i)*p.l(i)) ;

display phat, muhat;





