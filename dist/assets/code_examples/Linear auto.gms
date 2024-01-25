* Primal GME, dual GME, and GCE formulations for linear model with noise
* Program uses the sample auto data set from Stata
* Written on Nov. 30, 2014
* Golan, A., Judge, G. G., & Miller, D. (1996). Maximum entropy econometrics.



set
t      obs number                       /1*74/
m      Number of beta supports          /1*5/
j      Number of error supports         /1*3/
k      Number of independent variables  /1*4/
n      Variables in the data set        /price,mpg,rep78,headroom,trunk, weight,length,turn,displacement,gear_ratio,foreign,lnprice/
;

parameters



Z(M)               Beta support                          /1  -100
                                                          2  -50
                                                          3   0
                                                          4   50
                                                          5   100/

V(j)               Error supports
data(t,n)          Data
y(t)               Dependent variable
x(t,k)             Independent variables
avy                mean value of dependent variable (endogenous error supports)
vary               Variance of depenedent variable
sdy                Standard deviation of dependent variable
gradient(t)        Gradient for dual gme estimation
hessian(t,t)       Hessian for dual gme
LambdasDual(t)     Lambdas for dual gme
LambdasPrimal(t)   Lambdas for primal gme
LambdasCE(t)       Lambdas for cross entropy
LambdasNM(k)       Lambdas for GME-NM
omegadual(k)       Omega for dual gme
omegaprimal(k)     Omega for primal gme
omegace(k)         Omega for cross entropy
omegasNM(k)        Omega for GME-NM
psidual(t)         PSI for dual gme
psiprimal(t)       PSI for primal gme
psiCE(t)           PSI for cross entropy
psiNM(k)           PSI for GME NM
pdual(k,m)         Weigths for beta supports dual
pprimal(k,m)       Weigths for beta supports primal
p_CE(k,m)          Weigths for beta supports cross entropy
p_NM(k,m)          Weights for beta supports GME-NM
wdual(t,j)         Weigths for error supports dual
wprimal(t,j)       Weigths for error supports primal
w_CE(t,j)          Weigths for error supports cross entropy
w_NM(k,j)          Weights for error supports GME-NM
Betadual(k)        Estimated betas for dual
Betaprimal(k)      Estimated betas for primal
BetaCE(k)          Estimated betas for cross entropy
BetaNM(k)          Estimated betas for GME-NM
BetaOLS(k)         Estimated betas for OLS
SE_beta(k)         Standard errors for GME betas (primal)
norment_dual       Normalized entropy for dual
norment_primal     Normalized entropy for primal
norment_ce         Normalized entropy for cross entropy
entropy_0          Restricted entropy (betas=0)
entropy_dual       Entropy of dual gme
entropy_primal     Entropy of primal gme
entropy_ce         Entropy of cross entropy
pseudoR2_dual      Pseudo R sq. for dual gme
pseudoR2_primal    Pseudo R sq. for dual gme
pseudoR2_ce        Pseudo R sq. for cross entropy
sigmaZ(k)          Sigma squared for distribution p
sigmaV(t)          Sigma squared for distribution w
hessian(t,t)       Hessian for the dual gme
puni(k,m)          Uniform priors
wuni(t,j)          Uniform priors
cross(k,k)         X'X
unity(k,k)         Unit matrix for inversion
;

alias(t,i);
alias(k,kk,kt);

*External data
$INCLUDE "D:\GMES\auto.dat";

*display data;

*----------------
* Assign the data
*----------------

y(t)=(data(t,"lnprice"));
x(t,"1")= (data(t,"mpg"));
x(t,"2")= (data(t,"weight"));
x(t,"3")= (data(t,"foreign"));

* Constant term
x(t,"4")=1;

*** X'X
cross(k,kk)=sum(t, x(t,k)*x(t,kk));

*** Unit
unity(k,k)=1

display x,y, unity;

*----------------------------------------
**Calculating endogeoneous error supports
*----------------------------------------
avy = sum(t,y(t))/card(t);
vary = sum(t,(y(t)-avy)*(y(t)-avy))/(card(t)-1);
sdy=sqrt(vary);

V("1")=-3*sdy;
v("2")=0;
V("3")=3*sdy;

*-------------------------------------
** Uniform priors
*-------------------------------------
puni(k,m)  = 1/card(m);
wuni(t,j)  = 1/card(j);


positive variables
    P(K,M)       Parameter probabilities for primal
    W(T,J)       Error probabilities for primal
    PCE(K,M)     Parameter probabilities for GCE
    WCE(T,J)     Error probabilities for GCE
    NM_p(K,M)    Parameter probabilities for GME-NM
    NM_w(k,j)    Error probabilities for GME-NM
;

variables

OBJ               Objective
lm(t)             Lagrange multipliers for dual
Bols(k)           Betas for OLS

;

equations
objdualm         objective for dual
objprimal        objective for primal
objCE            objective for GCE
objNM            objective for GME NM
objOLS           objective for OLS
add1(k)          Parameter additiveity constraints
add2(T)          Error additiveity constraints
add1CE(k)        Parameter additiveity constraints GCE
add2CE(t)        Error additiveity constraints GCE
con(T)           Consistency constraints (lambdas)
conCE(T)         Consistency constraints (lambdas) GCE
nm_add1(k)       Parameter additiveity constraints GME-NM
nm_add2(k)       Error additiveity constraints GME-NM
nm_con(k)        Consistency constraints (lambdas) GME-NM
;

*****************************************
*---------------
*Dual GME
*---------------
*****************************************

* Objective function
objdualm..   obj =e= sum(t,y(t)*lm(t))
            + sum(k,log(sum(m,exp(-sum(t,x(t,k)*Z(m)*lm(t))))))
            + sum(t,log(sum(j,exp(-V(j)*lm(t)))));

model dualgme Dual GME   /
                          objdualm
                         /;

solve dualgme minimizing obj using nlp;

lambdasdual(t)    = lm.l(t);
omegadual(k)      = sum(m,exp(-sum(t,lm.l(t)*X(t,k)*z(m))));
pdual(k,m)        = exp(-sum(t,lm.l(t)*X(t,k)*z(m)))/omegadual(k);
betadual(k)       = sum(m, pdual(k,m)*z(m));
psidual(t)        = sum(j,exp(-lm.l(t)*v(j)));
wdual(t,j)        = exp(-lm.l(t)*v(j))/psidual(t);

display   lambdasdual, pdual, betadual;

*---------------------------
* Statistics of the GME dual
*---------------------------

norment_dual      = -sum(k, sum(m, pdual(k,m)*log(pdual(k,m))))/(card(k)*log(card(m)));
entropy_dual      = -sum(k, sum(m, pdual(k,m)*log(pdual(k,m))))
                    -sum(t, sum(j, wdual(t,j)*log(wdual(t,j))));
entropy_0         = -sum(k, sum(m, puni(k,m)*log(puni(k,m))))
                    -sum(t, sum(j, wuni(t,j)*log(wuni(t,j))));
pseudoR2_dual     = 1-(entropy_dual/entropy_0);

sigmaZ(k)         = sum(m, pdual(k,m)*z(m)*z(m))-(sum(m, pdual(k,m)*z(m)))*(sum(m, pdual(k,m)*z(m)));
sigmaV(t)         = sum(j, wdual(t,j)*v(j)*v(j))-(sum(j, wdual(t,j)*v(j)))*(sum(j, wdual(t,j)*v(j)));
hessian(t,i)      = -sum(k, x(t,k)*x(i,k)*sigmaz(k))-sigmav(t) ;

display   obj.l, norment_dual, pseudoR2_dual;


***************************************************************
*------------------
* Primal GME
*------------------
***************************************************************
* initialize obj
obj.l=0;

*** Objective function
objprimal..     obj =e= -sum((k,m), p(k,m)*log(p(k,m)+1.e-8))
                        -sum((t,j), w(t,j)*log(w(t,j)+1.e-8));

*** Constraints
add1(k)..                sum(m, p(k,m))=e=1;
add2(t)..                sum(j, w(t,j))=e=1;

con(t)..                 sum(k, x(t,k)*sum(m, p(k,m)*z(m)))
                         + sum(j, w(t,j)*v(j)) =e= y(t);

model primalgme Primal GME  /
                                 objprimal
                                 con
                                 add1
                                 add2
                            /;

Solve primalgme maximizing obj using nlp;

lambdasprimal(t)    = con.m(t);
omegaprimal(k)      = sum(m,exp(-sum(t,con.m(t)*X(t,k)*z(m))));
pprimal(k,m)        = p.l(k,m);
betaprimal(k)       = sum(m, pprimal(k,m)*z(m));
psiprimal(t)        = sum(j,exp(-con.m(t)*v(j)));
wprimal(t,j)        = w.l(t,j);

display   lambdasprimal, pprimal, betaprimal;

*-------------------------------
* Statistics of the GME primal
*-------------------------------

norment_primal      = -sum(k, sum(m, pprimal(k,m)*log(pprimal(k,m))))/(card(k)*log(card(m)));
entropy_primal      = -sum(k, sum(m, pprimal(k,m)*log(pprimal(k,m))))
                      -sum(t, sum(j, wprimal(t,j)*log(wprimal(t,j))));
entropy_0           = -sum(k, sum(m, puni(k,m)*log(puni(k,m))))
                      -sum(t, sum(j, wuni(t,j)*log(wuni(t,j))));
pseudoR2_primal     = 1-(entropy_primal/entropy_0);

display obj.l, norment_primal, entropy_primal, pseudoR2_primal;

***************************************************************
*---------------------------
* Generalized Cross Entropy
*---------------------------
***************************************************************
* initialize obj
obj.l=0;

objCE..        obj=e= sum((k,m), centropy(pce(k,m),puni(k,m)))+
                      sum((t,j), centropy(wce(t,j),wuni(t,j)));

*** Constraints
add1CE(k)..                sum(m, pce(k,m))=e=1;
add2CE(t)..                sum(j, wce(t,j))=e=1;

conCE(t)..                 sum(k, x(t,k)*sum(m, pce(k,m)*z(m)))
                         + sum(j, wce(t,j)*v(j)) =e= y(t);

model GCE Gen. cross entropy   /
                                 objce
                                 conce
                                 add1ce
                                 add2ce
                               /;

solve GCE minimizing obj using nlp;

lambdasce(t)        = conce.m(t);
omegace(k)          = sum(m,exp(-sum(t,conce.m(t)*X(t,k)*z(m))));
p_ce(k,m)           = pce.l(k,m);
betace(k)           = sum(m, p_ce(k,m)*z(m));
psice(t)            = sum(j,exp(-conce.m(t)*v(j)));
w_ce(t,j)           = wce.l(t,j);

display   lambdasce, p_ce, betace, obj.l;

***************************************************************
*--------------------------------------------------------------
* Generalized Maximum Entropy - NM                             |
*--------------------------------------------------------------
***************************************************************
* initialize obj
obj.l=0;

*** Objective function
objNM..     obj =e= -sum((k,m), nm_p(k,m)*log(nm_p(k,m)+1.e-8))
                    -sum((k,j), nm_w(k,j)*log(nm_w(k,j)+1.e-8));

*** Constraints
nm_add1(k)..                sum(m, nm_p(k,m))=e=1;
nm_add2(k)..                sum(j, nm_w(k,j))=e=1;

nm_con(k)..                ((cross(k,k))/card(t))*sum(m, nm_p(k,m)*z(m))
                         + ((sum((t), x(t,k)* (sum(j, nm_w(k,j)*v(j)))))/card(t)) =e=
                           ((sum((t), x(t,k)*y(t)))/card(t));

model GMENM  GME NM /
                                 objNM
                                 nm_con
                                 nm_add1
                                 nm_add2
                    /;

Solve GMENM maximizing obj using nlp;

lambdasNM(k)        = nm_con.m(k);
omegasNM(k)         = sum(m,exp(-sum(t,nm_con.m(k)*X(t,k)*z(m))));
p_nm(k,m)           = nm_p.l(k,m);
betanm(k)           = sum(m, p_nm(k,m)*z(m));
psinm(k)            = sum(j,exp(-lambdasnm(k)*v(j)));
w_nm(k,j)           = nm_w.l(k,j);

display   lambdasnm, p_nm, betanm, obj.l;

******************************************************
*-----------------------------------------------------
* Ordinary least squares (OLS)
*-----------------------------------------------------
******************************************************
* initialize obj
obj.l=0;

* Objective

objOLS..     obj =e= sum(i, (y(i)-sum(k, x(i,k)*bols(k)))*(y(i)-sum(k, x(i,k)*bols(k))));

model OLS  OLS /
                 objOLS
               /;

solve OLS minimizing obj using nlp;

betaols(k)        =bols.l(k);

display betaols;

******************************************
*-----------------------------------------
*Standard Errors for GME estimated Betas
*-----------------------------------------
******************************************
parameter omega2;
parameter sigma2;
parameter varB(k,kk);


sigma2=(sum(t, lambdasprimal(t)*lambdasprimal(t)))/card(t);

omega2=power(((1/card(t))*sum(t,power((sum(j, v(j)*v(j)*wprimal(t,j))-(sum(j, v(j)*wprimal(t,j)))*(sum(j, v(j)*wprimal(t,j)))),-1))),2);


*obtain inverse of X'X
variable inv(k,kk);
variable obj2;
equation inverse(k,kk);
equation eobj;

eobj..obj=e=0;

inverse(k,kk).. sum(kt, inv(k,kt)*cross(kt,kk))=e=unity(k,kk);

model invmat /
             eobj
             inverse
             /;
solve invmat minimizing obj using nlp;



varB(k,kk)=(sigma2/omega2)*inv.l(k,kk);
SE_beta(k)=sqrt(varB(k,k));


display varB, SE_beta, sigma2, omega2;
