
**** Model replication of Optimal Portfolio Diversification Using the Maximum
**** Entropy Principle by Bera, A.K. and Park, S.Y.
**** SHORT SELLING ALLOWED
*Short sale portfolio,  this file corresponds to the model in page 501, eq. 23
* (although CE is not included)

set      i   Portfolios           /health, utility, other/
         k   # of observations    /1*1/
         m   support index        /1*11/
;

alias (j,i);

parameter    share(i)     estimated shares
             muhat        estimated mean return
             sigmahat     estimated SD of return
             xihat        Estimated utility
             mu0          Portfolio mean
             sd           Standard deviation of asset returns
             return(i)    Return on asset
             q(i)         Priors
             cov(i,i)     Covarianve matrix
             sigma        SD
             lambda       Risk aversion parameter
             ximax        Shrinkage parameter


             Z(M)         Beta support     /1  -1
                                            2  -0.8
                                            3  -0.6
                                            4  -0.4
                                            5  -0.2
                                            6   0
                                            7   0.2
                                            8   0.4
                                            9   0.6
                                            10  0.8
                                            11  1/


;

return("health")  =  1.551 ;
return("utility") =  1.156 ;
return("other")   =  1.215 ;


**** Priors
*q(i)                 = 1/card(i);

*** Cov matrix
table cov(i,i) covariance matrix

                 health    utility  other
health           57.298    12.221   33.026
utility          12.221    13.168   11.814
other            33.026    11.814   27.952 ;

*** Risk aversion parameter
lambda=0.06;

positive variables
       p(i,m)  estimated shares
       pmax(i) p for max utility
       pi(i)   shares from minimum variance

;

variables
        obj1  objective function
        obj2  objective function
        obj3  objective function
;



equations

object_me         ME objective function
object_ce         CE objective function
proper_prob (i)   The proper prob requirement - normalization
proper_prob_max   The proper prob requirement - normalization
ShareC            Share constraint
Shrink            The shrinkage
Shrink2           The shrinkage moment constraint
MV                ME objective function
Ereturn           Expected return equation
sumi              Proper prob for MV
;

**** Solve for maximum XI
Shrink.. obj1 =e=   sum(i,return(i)*pmax(i)) - (lambda/2)*(sum(i,sum(j,pmax(i)*pmax(j)*cov(i,j))));
proper_prob_max.. sum(i,pmax(i)) =e= 1;

model uno /Shrink
          proper_prob_max
/;

solve uno maximizing obj1 using nlp;

ximax = sum(i,return(i)*pmax.l(i)) - (lambda/2)*(sum(i,sum(j,pmax.l(i)*pmax.l(j)*cov(i,j))));

display ximax, pmax.l;

**** We need the MV to use as priors

MV..  obj2 =e= sum(i,sum(j,pi(i)*pi(j)*cov(i,j))) ;
Ereturn.. 1.37 =e= sum(i, pi(i)*return(i));
sumi..    1 =e= sum(i, pi(i));

model M_v /MV
          Ereturn
          sumi
/;

solve M_v minimizing obj2 using nlp;
muhat = sum(i, pi.l(i)*return(i));

display pi.l, muhat;


**** Set up the ME estimation


***** Solve ME problem
object_me..    obj3    =e= sum((i,m), p(i,m)*log(p(i,m) + 1.e-8)) ;

*** Constraints
Shrink2..      ximax  =l= sum(i,(sum(m, p(i,m)*Z(m))*return(i))) -
               (lambda/2)*(sum(i, sum(j, (sum(m, p(i,m)*Z(m)))*(sum(m, p(j,m)*Z(m)))*cov(i,j))))
               ;

ShareC..       1 =e= sum(i,(sum(m, p(i,m)*Z(m))));
proper_prob (i)..  1 =e= sum(m, p(i,m)) ;


model dos /object_me
           proper_prob
           ShareC
           Shrink2
/;

solve dos maximizing obj3 using nlp;

*** Results
share(i) = sum(m, p.l(i,m)*Z(m));
xihat = sum(i,return(i)*share(i)) - (lambda/2)*(sum(i,sum(j,share(i)*share(j)*cov(i,j))));



display share, xihat, ximax;



