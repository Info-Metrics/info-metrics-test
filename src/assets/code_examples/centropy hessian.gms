$offsymxref offsymlist
$ontext
Info-Metrics Tutorial 2014
GAMS code for classical ME and CE
Including  the ME dual case
Compare ME and CE for uniform and for correct priors as well as for incorrect priors.
Compare dual and primal (look at shadow "prices" - moments.m, as well as speed
of convergence and resources used.
Updated September 17, 2014
NOTE:
Can generate monotonically increasing/decreasing prob dist and X's
NOTE: Plots up to 20 observations


$offtext

set  k     index - dimension of probability   /x1*x37/
     t     index - no. of observations        /x1*x1/
     k2    index - Hessian P dimension        /x1*x37/
     t2    index - Hessian lambda dimension   /x2*x2/
;

parameter  phat(k)          estimated values
           X(t,k)           RHS matrix dimension T by K
           ptrue(k)         true (unknown) probabilities
           sump             normalization
           y(t)             moment value
           SEL              Sq. Error Loss
           H_ME             Optimal entropy value - ME case
           H_CE             Optimal entropy value - CE case
           q(k)             priors
           Htrue            Entropy value of true probabilities
           partition        partition function
           est_prob(k)      est prob dual
           pme(k)
           pce(k)
           p_dual_me(k)
           p_dual_ce(k)
           pel(k)
           h_me             Equal to H_ME under ME case
           h_ce             Equal to H_ME under CE case
           h_dual_me        Equal to H_ME under Dual ME case
           h_dual_ce        Equal to H_ME under Dual CE case
           h_el             Equal to H_ME under EL case
           I(k,k)           P information matrix
           Il(t,t)          Lambda information matrix

           Hessian(k,k)     P information matrix
           HessianL(t2,t2)  Lambda information matrix
           dPdL(t,k)        Partial derivative of p with respect to lambda
           ILambda(t,t)     Taylor approximation lambda information matrix

           uniP(k)          Uniform priors for CEntropy function

;
alias(k,j);
alias(t,n);
alias(k2,j2);
alias(t2,n2);

ptrue(k) = uniform(0,10);
sump     = sum(k, ptrue(k));
ptrue(k) = ptrue(k)/sump;

**Generating a monotoinic increasing or decreasing dist
ptrue("x1") = uniform(0, 3);

loop(k,
ptrue(k+1) = ptrue(k) + uniform(0,10);
);

sump     = sum(k, ptrue(k));
ptrue(k) = ptrue(k)/sump;

*Creating the priors
*CASE A: Uniform priors CE=ME
q(k) = 1/card(k);

*CASE B: Random Incorrect priors
*$ontext
q(k) = uniform(0,10);
sump = sum(k, q(k));
q(k) = q(k)/sump;
*$offtext
unip(k)=1/card(k);

*CASE C: Correct priors
*q(k) = ptrue(k);

Htrue = -sum(k,ptrue(k)*log(ptrue(k)));

X(t,k)= normal(0,1) ;
*Generating random increasing X's
*$ontext
X(t,"x1") = uniform(0, 3);

loop(k,
X(t,k+1) = X(t,k) + uniform(0,10);
);

display x;
*$offtext

y(t) = sum(k,X(t,k)*ptrue(k));

*Uniform priors
*q(k) = 1/card(k);
*Correct priors
*q(k) = ptrue(k);

positive variables
       gamsCEp(k)       estimated probabilities from CEntropy function
;

variables

        obj  objective function
*Dual Lagrange multipliers
        lm(t) Lagrange multipliers
;

equations
proper_prob2 The proper prob requirement - normalization
moments2(t) oberved moments
objgams     Gams CEntropy function

;


*Note: GAMS has an entropy function now
proper_prob2..     sum(k,gamscep(k)) =e= 1;

moments2(t)..      y(t) =e= sum(k,X(t,k)*gamscep(k));

objgams..  obj =e= SUM(k, centropy(gamscep(k),unip(k)));

model CE /objgams
           proper_prob2
           moments2
/;

solve CE minimizing obj using nlp;

display gamscep.l;

************Obtain Hessian via Gams
option nlp=convertD;
$onecho > convertD.opt
hessian
$offecho
CE.optfile=1;
solve CE minimizing obj using nlp;

set dummy1 /e1,x1*x37/;

parameter h(*,*,*) 'Hessian Centropy';
execute_load "hessian.gdx",h;
display h;

* Hessian assignment for operations

Hessian(k,j)=h('e1',k,j);
display Hessian;

* Partial derivative of p w.r.t. lambda

dPdL(t,k)=  gamscep.l(k)*x(t,k) - gamscep.l(k)*sum(j,(gamscep.l(j)*x(t,j)));
display dPdL;

* Generate ILambda
ILambda(t,n)= sum(k,dPdL(t,k)*Hessian(k,k)*dPdL(t,k));
display ILambda;


***** Include Information matrices, manually

*** Information matrix for lambdas

Il(t,n) = sum(k,(x(t,k)*x(n,k)*gamscep.l(k)))-(sum(k,(x(t,k)*gamscep.l(k))))*(sum(k,(x(n,k)*gamscep.l(k))));

display Il;



