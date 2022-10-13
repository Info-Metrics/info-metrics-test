*Minimum variance portfolio
* Minimum variance portfolio selection from Bera, A.K. and Park, S.Y. paper
set      i   Portfolios           /health, utility, other/
         k   # of observations    /1*1/
;

alias (j,i);

parameter
             return(i)    Return on asset
             cov(i,i)     Covarianve matrix
             muhat



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


positive variables
       pi(i)   shares from minimum variance

;

variables
        obj1  objective function

;

equations
MV                ME objective function
Ereturn           Expected return equation
sumi              Proper prob for MV
;



**** We need the MV to use as priors

MV..  obj1 =e= sum(i,sum(j,pi(i)*pi(j)*cov(i,j))) ;
Ereturn.. 1.37  =e= sum(i, pi(i)*return(i));
sumi..    1 =e= sum(i, pi(i));

model M_v /MV
          Ereturn
          sumi
/;

solve M_v minimizing obj1 using nlp;
muhat = sum(i, pi.l(i)*return(i));

display pi.l, muhat, obj1.l;
