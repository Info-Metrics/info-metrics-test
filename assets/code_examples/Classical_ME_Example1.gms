$offsymxref offsymlist
$ontext
  Info-Metrics Class, Spring, 2014
  GAMS code for classical ME and CE
  Updated January 19th, 2014

The file compares results from primal ME and CE when
the priors used for the CE are the true probabilities.
It solves 2 models, primal maximum entropy and cross entropy.

The file produces outputs an excel file which plots the
different probabilities obtained ("Classical_ME_Example1.xlsx").

$offtext

set  k     index - dimension of probability /1*10/
     t     index - no. of observations /1*1/
     k2    index - Hessian P dimension  /x1*x10/
;

parameter  phat(k)       estimated values
           X(t,k)        RHS matrix dimension T by K
           ptrue(k)      true (unknown) probabilities
           sump          normalization
           y(t)          moment value
           SEL           Sq. Error Loss
           H_ME          Optimal entropy value - ME case
           H_CE          Optimal entropy value - CE case
           q(k)          priors
           Htrue         Entropy value of true probabilities
           pme(k)
           pce(k)
           h_me          Equal to H_ME under ME case
           h_ce          Equal to H_ME under CE case

           I(k,k)          P information matrix
           Il(t,t)         Lambda information matrix

           Hessian(k2,k2)    P information matrix

;
alias(k,j);
alias(t,n);
alias(k2,j2);

*Creating the True - unknown - probabilities and data
ptrue(k) = uniform(0,10);
sump     = sum(k, ptrue(k));
ptrue(k) = ptrue(k)/sump;
X(t,k)   = normal(0,1) ;
y(t)     = sum(k,X(t,k)*ptrue(k));

*Creating the priors
*CASE A: Uniform priors CE=ME
q(k) = 1/card(k);

*CASE B: Random Incorrect priors
$ontext
q(k) = uniform(0,10);
sump = sum(k, q(k));
q(k) = q(k)/sump;
$offtext

*CASE C: Correct priors
q(k) = ptrue(k);

*Case D: 1/x priors
**q(k) = 1/abs(X("1",k));

positive variables
       p(k) probabilities
;
variables
        obj  objective function
;

equations

objective   ME objective function
objectce    CE objective function
moments(t)  The data points - observed moments
proper_prob The proper prob requirement - normalization
;

***Classical ME
objective.. obj =e= - sum(k,p(k)*log((p(k)+1.e-8)));
*Note: GAMS has an entropy function now, used below

proper_prob..      sum(k,p(k)) =e= 1;
moments(t)..       y(t) =e= sum(k,X(t,k)*p(k));

***Classical CE
* Using the centropy  function
objectce..  obj =E= SUM(k, centropy(p(k),q(k)));
* Simiar objective function but without the centropy function
*objectce.. obj =e= sum(k,p(k)*log((p(k)+1.e-8)/q(k)));



model ME /objective
          proper_prob
          moments
/;
model CE /objectce
          proper_prob
          moments
/;


options limrow=0,limcol=0;
options solprint=off;
options decimals=7;
options iterlim=1000;

*initialization
p.l(k)=1/card(k);

solve ME maximizing obj using nlp;

SEL    = sum(k,((p.l(k) - ptrue(k))*(p.l(k) - ptrue(k))));
H_ME   = obj.l;
Htrue  = -sum(k,ptrue(k)*log(ptrue(k)));
pme(k) = p.l(k);
h_me   = H_ME;

display x, y, ptrue, p.l,pme , Htrue, H_ME, h_me, SEL;


*initialization
p.l(k)=1/card(k);

solve CE minimizing obj using nlp;

SEL    = sum(k,((p.l(k) - ptrue(k))*(p.l(k) - ptrue(k))));
H_CE   = obj.l ;
H_ME   = - obj.l + log(card(k));
pce(k) = p.l(k);
h_ce   = H_ME;

display x, y, ptrue, p.l,pce, H_CE, H_ME, h_ce, SEL;



*Writing outputs into excel files
$ontext
execute_unload "Classical_ME_Example1.gdx" pme, pce, h_me, h_ce;
execute 'gdxxrw.exe Classical_ME_Example1.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Example1.xlsx par=pme rng=pme! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Example1.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Example1.xlsx par=pce rng=pce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Example1.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Example1.xlsx par=h_me rng=pme!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Example1.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Example1.xlsx par=h_ce rng=pce!C1 Cdim=0 Rdim=0';
$offtext

* Writing outputs into excel files
* Specify your folder's location

execute_unload "Classical_ME_Example1.gdx" pme, pce, h_me, h_ce;
execute 'gdxxrw.exe Classical_ME_Example1.gdx o=Classical_ME_Example1.xlsx par=pme rng=pme! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Example1.gdx o=Classical_ME_Example1.xlsx par=pce rng=pce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Example1.gdx o=Classical_ME_Example1.xlsx par=h_me rng=pme!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Example1.gdx o=Classical_ME_Example1.xlsx par=h_ce rng=pce!C1 Cdim=0 Rdim=0';


