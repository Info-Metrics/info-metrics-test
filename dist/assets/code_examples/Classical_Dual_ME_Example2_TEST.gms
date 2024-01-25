$offsymxref offsymlist
$ontext
Info-Metrics Tutorial 2014
GAMS code for classical ME and CE
Including  the ME dual case
Compare ME and CE for uniform and for correct priors as well as for incorrect priors.
Compare dual and primal (look at shadow "prices" - moments.m, as well as speed of convergence and resources used.
Updated September 17, 2014
NOTE:
Can generate monotonically increasing/decreasing prob dist and X's
NOTE: Plot is up to 20 observatins
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

positive variables
       p(k) prob
       gamsCEp(k)       estimated probabilities from CEntropy function
;

variables

        obj  objective function
*Dual Lagrange multipliers
        lm(t) Lagrange multipliers
;

equations

objective   ME objective function
objectce    CE objective function
object_el   EL objective function
moments(t)  oberved moments
moments2(t) oberved moments
proper_prob The proper prob requirement - normalization
proper_prob2 The proper prob requirement - normalization
*Dual model
medual      Dual concentrated ME
cedual      Dual concentrated CE
** additional info
eq_p15      p_15=ptrue_15
** Gams CEntropy function
objgams     Gams CEntropy function

;

***Classical ME
objective.. obj =e= - sum(k,p(k)*log((p(k)+1.e-16)));

proper_prob..      sum(k,p(k)) =e= 1;
proper_prob2..     sum(k,gamscep(k)) =e= 1;
moments(t)..       y(t) =e= sum(k,X(t,k)*p(k));
moments2(t)..      y(t) =e= sum(k,X(t,k)*gamscep(k));

***Classical CE
objectce.. obj =e= sum(k,p(k)*log((p(k)+1.e-8)/(q(k)+1.e-16)) );

**The Dual-concentrated ME
medual..       obj =e= sum(t,y(t)*lm(t)) + log(sum(k,exp(-sum(t,lm(t)*X(t,k)))));
**The Dual - concentrated CE
cedual..       obj =e= sum(t,y(t)*lm(t)) - log(sum(k,q(k)*exp(sum(t,lm(t)*X(t,k)))));

*** Empirical Likelihood Objective
object_el..  obj =e=  sum(k,log((p(k)+1.e-8)));

**Additional info
eq_p15..     ptrue("x15") =e= p("x15");

*Note: GAMS has an entropy function now
unip(k)=1/card(k);
objgams..  obj =e= SUM(k, centropy(gamscep(k),unip(k)));




model ME /objective
          proper_prob
          moments
*          eq_p15
/;
model CE /objectce
          proper_prob
          moments
/;

model DUAL_ME /
        medual
/;

model DUAL_CE /
        cedual
/;
model EL /object_el
          proper_prob
          moments
/;
model GCE /objgams
           proper_prob2
           moments2
/;



options limrow  =0,limcol=0;
options solprint=off;
options decimals=7;
options iterlim =1000;

*initialization
p.l(k) = 1/card(k);
*q(k) = ptrue(k);

solve ME maximizing obj using nlp;

SEL    = sum(k,((p.l(k) - ptrue(k))*(p.l(k) - ptrue(k))));
H_ME   = obj.l;
pme(k) = p.l(k);
h_me   = H_ME;

display y, ptrue, p.l , pme, Htrue, moments.m, H_ME, h_me, SEL;

*initialization
p.l(k) = 1/card(k);

solve CE minimizing obj using nlp;

SEL    = sum(k,((p.l(k) - ptrue(k))*(p.l(k) - ptrue(k))));
H_CE   = obj.l ;
H_ME   = - obj.l + log(card(k));
pce(k) = p.l(k);
h_ce   = H_ME;

display y, q, p.l , pce, H_ME, h_ce, H_CE, SEL;

*Dual ME
lm.l(t)     = 0;
est_prob(k) = 0;

solve DUAL_ME minimizing obj using nlp;

H_ME             = obj.l;
Htrue            = -sum(k,ptrue(k)*log(ptrue(k)));
partition        = sum(k,exp(-sum(t,lm.l(t)*X(t,k))));
est_prob(k)      = exp(-sum(t,lm.l(t)*X(t,k)))/partition;
SEL              = sum(k,((est_prob(k) - ptrue(k))*(est_prob(k) - ptrue(k))));
p_dual_me(k)     = est_prob(k);
h_dual_me        = H_ME;

display y, ptrue, est_prob, p_dual_me, lm.l, Htrue, H_ME, h_dual_me, sel;

*Dual CE
lm.l(t)     = 0;
est_prob(k) = 0;

solve DUAL_CE maximizing obj using nlp;

H_CE         = obj.l ;
H_ME         = - obj.l + log(card(k));
Htrue        = -sum(k,ptrue(k)*log(ptrue(k)));
partition    = sum(k,q(k)*exp(sum(t,lm.l(t)*X(t,k))));
est_prob(k)  = q(k)*exp(sum(t,lm.l(t)*X(t,k)))/partition;
SEL          = sum(k,((est_prob(k) - ptrue(k))*(est_prob(k) - ptrue(k))));
p_dual_ce(k) = est_prob(k);
h_dual_ce    = H_ME;

display y, q, ptrue, est_prob, p_dual_ce, lm.l, Htrue, H_ME, h_dual_ce, H_CE, sel;

*EL

p.l(k)       = 1/card(k);

solve EL maximizing obj using nlp;

H_ME         = - sum(k,p.l(k)*log((p.l(k))) )      ;
pel(k)       = p.l(k);
SEL          = sum(k,((pel(k) - ptrue(k))*(pel(k) - ptrue(k))));
h_el         = H_ME;

display  y, p.l , pel,  moments.m, H_ME, h_el, sel;

solve GCE minimizing obj using nlp;

display gamscep.l;

************Remove this text afterwards
option nlp=convertD;
$onecho > convertD.opt
hessian
$offecho
GCE.optfile=1;
solve GCE minimizing obj using nlp;

set dummy1 /e1,x1*x37/;

parameter h(*,*,*) 'Hessian Centropy';
execute_load "hessian.gdx",h;
display h;

display gamscep.l, p_dual_me, unip;



*******************************************************
*******************************************************

** Include Hessians for dual ME, and ME

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
set dummy3 /e1,x1/;

parameter h(*,*,*) 'Hessian Lambda';
execute_load "hessian.gdx",h;
display h;
display p_dual_me;

* Hessian assignment

HessianL(t2,t2)=-h('e1',t2,t2);
display HessianL;



***** Include Information matrices, manually

*** Information matrix for lambdas

Il(t,n) = sum(k,(x(t,k)*x(n,k)*p_dual_me(k)))-(sum(k,(x(t,k)*p_dual_me(k))))*(sum(k,(x(n,k)*p_dual_me(k))));

display Il;

*******************************************************************************

display x, y;

execute_unload "Classical_Dual_ME_Example2_new.gdx" pme, x, y;
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2_new.xlsx par=pme rng=pme! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2_new.xlsx par=x rng=x! Cdim=1 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2_new.xlsx par=y rng=y! Cdim=1 Rdim=1';




*Writing outputs into excel files
* Make sure to place your file locations
$ontext
execute_unload "Classical_Dual_ME_Example2.gdx" pme, pce, p_dual_me, p_dual_ce, pel, q, h_me, h_ce, h_dual_me, h_dual_ce, h_el;
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=pme rng=pme! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=pce rng=pce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=p_dual_me rng=p_dual_me! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=p_dual_ce rng=p_dual_ce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=pel rng=pel! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=q rng=q! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=h_me rng=pme!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=h_ce rng=pce!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=h_dual_me rng=p_dual_me!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=h_dual_ce rng=p_dual_ce!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_Dual_ME_Example2.xlsx par=h_el rng=pel!C1 Cdim=0 Rdim=0';

$offtext

$ontext
execute_unload "Classical_Dual_ME_Example2.gdx" pme, pce, p_dual_me, p_dual_ce, pel, q, h_me, h_ce, h_dual_me, h_dual_ce, h_el;
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=pme rng=pme! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=pce rng=pce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=p_dual_me rng=p_dual_me! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=p_dual_ce rng=p_dual_ce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=pel rng=pel! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=q rng=q! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=h_me rng=pme!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=h_ce rng=pce!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=h_dual_me rng=p_dual_me!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=h_dual_ce rng=p_dual_ce!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_Dual_ME_Example2.gdx o=output\Classical_Dual_ME_Example2.xlsx par=h_el rng=pel!C1 Cdim=0 Rdim=0';
$offtext
