$offsymxref offsymlist
$ontext
Info-Metrics Tutorial 2014
GAMS code for classical ME
Obtains hessian from gams. Includes lambda information
matrix, using Taylor approximation as well as formula.

The file uses the same data generated in
"Classical_Dual_ME_Example2.gms" and obtains the numerical hessian
for the primal problem given by gams. Additionally the lambda
information matrix is estimated using the hessian given by gams as
well as the partial derivatives of the probabilities with respect to lambda.

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


display ptrue;

X(t,k)= normal(0,1) ;
display x;
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
       p(k) prob

;

variables

        obj  objective function
*Dual Lagrange multipliers
        lm(t) Lagrange multipliers
;


equations

objective   ME objective function
proper_prob The proper prob requirement - normalization
moments(t)  oberved moments
;
***Classical ME
objective.. obj =e= - sum(k,p(k)*log((p(k)+1.e-16)));

proper_prob..      sum(k,p(k)) =e= 1;

moments(t)..       y(t) =e= sum(k,X(t,k)*p(k));

model ME /objective
          proper_prob
          moments
         /;

solve ME maximizing obj using nlp;

SEL    = sum(k,((p.l(k) - ptrue(k))*(p.l(k) - ptrue(k))));
H_ME   = obj.l;
pme(k) = p.l(k);
h_me   = H_ME;


********************************************************
* Get hessian for for ME
********************************************************
option nlp=convertD;
$onecho > convertD.opt
hessian
$offecho
ME.optfile=1;
solve ME maximizing obj using nlp;

*
* gams cannot add elements at runtime so we declare the necessary elements here
*
set dummy2/e1,x1*x37/;

parameter h(*,*,*) 'Hessian Primal';
execute_load "hessian.gdx",h;
display h;
display pme;

* Hessian assignment for operations

Hessian(k,j)=h('e1',k,j);
display Hessian;

* Partial derivative of p w.r.t. lambda

dPdL(t,k)=  pme(k)*x(t,k) - pme(k)*sum(j,(pme(j)*x(t,j)));
display dPdL;

* Generate ILambda
ILambda(t,n)= sum(k,dPdL(t,k)*Hessian(k,k)*dPdL(t,k));
display ILambda;


***** Include Information matrices, manually

*** Information matrix for lambdas

Il(t,n) = sum(k,(x(t,k)*x(n,k)*pme(k)))-(sum(k,(x(t,k)*pme(k))))*(sum(k,(x(n,k)*pme(k))));

display Il;
