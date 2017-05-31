$offsymxref offsymlist
$ontext
Info-Metrics Tutorial 2014
GAMS code for classical ME and CE
Including  the ME dual case
Compare ME and CE for uniform and for correct priors as well as for
incorrect priors.
Compare dual and primal (look at shadow "prices" - moments.m, as well as speed
of convergence and resources used.
Updated September 17, 2014
NOTE:
Can generate monotonically increasing/decreasing prob dist and X's
NOTE: Plot is up to 20 observatins

Compare results with Stata file "Example 2 Dual ME STATA"
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
variables

        obj  objective function
*Dual Lagrange multipliers
        lm(t) Lagrange multipliers
;

equations


*Dual model
medual      Dual concentrated ME

;

**The Dual-concentrated ME
medual..       obj =e= sum(t,y(t)*lm(t)) + log(sum(k,exp(-sum(t,lm(t)*X(t,k)))));

model DUAL_ME /
        medual
/;

solve DUAL_ME minimizing obj using nlp;

H_ME             = obj.l;
Htrue            = -sum(k,ptrue(k)*log(ptrue(k)));
partition        = sum(k,exp(-sum(t,lm.l(t)*X(t,k))));
est_prob(k)      = exp(-sum(t,lm.l(t)*X(t,k)))/partition;
SEL              = sum(k,((est_prob(k) - ptrue(k))*(est_prob(k) - ptrue(k))));
p_dual_me(k)     = est_prob(k);
h_dual_me        = H_ME;

********************************************************
* Get hessian for for DUAL ME
********************************************************
option nlp=convertD;
$onecho > convertD.opt
hessian
$offecho
DUAL_ME.optfile=1;
solve DUAL_ME minimizing obj using nlp;

*
* gams cannot add elements at runtime so we declare the necessary elements here
*
set dummy/e1,x1/;

parameter h(*,*,*) 'Hessian Lambda';
execute_load "hessian.gdx",h;
display h;
display p_dual_me;

* Hessian assignment

HessianL(t2,t2)=-h('e1',t2,t2);
display HessianL;
