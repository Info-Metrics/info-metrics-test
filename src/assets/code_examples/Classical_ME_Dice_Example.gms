$offsymxref offsymlist
$ontext
 Info-metrics Class, Spring 2014
 GAMS code for the simple six sided die problem - classical ME and CE
 Updated September 17th, 2014

This file generates the probabilities of each side coming up,
using the observed mean. The code generates the primal generalized
maximum entropy probabilities, as well as the dual ME probabilities.
The files additionally generate the probabilities from the cross
entropy given a set of priors. Other estimators are also included
such as p-squared, where the objective function is the squared
probabilities. Empirical likelihood is also included.

The file produces an output excel file which plots the different
probabilities obtained.

$offtext

set  k     index - dimension of probability /1*6/
     t     index - no. of observations /1*1/
;

parameter  phat(k)  estimated values
           X(t,k)   RHS matrix dimension T by K
           sump     normalization
           y(t)     observed (mean) moment
           H_ME     Optimal entropy value - ME case
           H_CE     Optimal entropy value - CE case
           q(k)     priors
           Max_H    Maximum possible value of entropy (uniform)
           Sumq     for normalization of priors
           pme(k)
           pce(k)
           pel(k)
           pce1(k)
           h_me     Equal to H_ME under ME case
           h_ce     Equal to H_ME under CE case
           h_el     Equal to H_ME under EL case
           h_ce1    Equal to H_ME under CE1 case

obj_P2 objective value of p squared case
pe2(k) estimated probs for p squared case
h_me2 entropy of p squared case
;

*Creating the X
X(t,"1")=1 ;
X(t,"2")=2 ;
X(t,"3")=3 ;
X(t,"4")=4 ;
X(t,"5")=5 ;
X(t,"6")=6 ;


*The mean value - first moment
** Try 3.5, 4, 5.7
y(t) = 5.7;

*Creating the priors
*CASE A: Uniform priors CE=ME
q(k) = 1/card(k);

*CASE B: Random "Incorrect" priors
*$ontext
q(k) = uniform(0,10);
sump = sum(k, q(k));
q(k) = q(k)/sump;
*$offtext

*CASE C: Correct priors
*q(k) = ptrue(k);

* CASE D: 1/X priors
q(k) = 1/X("1",k) ;
sump = sum(k, q(k));
q(k) = q(k)/sump;

display q;


* Actual optimization
positive variables
       p(k) estimated probabilities

;
variables
        obj  objective function
;

equations

object_me   ME objective function
object_me_base_2 ME objective function in base 2
object_ce   CE objective function
object_el   EL objective function
moments(t)  The data points - observed moments
proper_prob The proper prob requirement - normalization
centropyeq  cross entropy obj function
object_p2   p squared objective case
;
***

***Classical ME
* Base 2
object_me_base_2..  obj =e= - sum(k,p(k)*log2((p(k)+1.e-8)));
* ln
object_me..  obj =e= - sum(k,p(k)*log((p(k)+1.e-8)));

*** pi squared case for chapter 5
object_p2..  obj =e=  sum(k,(p(k)*p(k)) );
*Note: GAMS has an entropy function now
*** Empirical Likelihood Objective
object_el..  obj =e=  sum(k,log((p(k)+1.e-8)));

proper_prob..          sum(k,p(k)) =e= 1;
moments(t)..  y(t) =e= sum(k,X(t,k)*p(k));
***Classical CE
object_ce.. obj =e= sum(k,p(k)*log((p(k)+1.e-16)/q(k)));

*Note: GAMS has an entropy function now
* Using the GAMS Entropy function
centropyeq..    obj =E= SUM(k, centropy(p(k),q(k)));


model ME /object_me
          proper_prob
          moments
/;

* Maximum entropy using base 2
model ME_2 /object_me
          proper_prob
          moments
/;
model PSQUARED /object_p2
          proper_prob
          moments
/;
model EL /object_el
          proper_prob
          moments
/;
model CE /object_ce
          proper_prob
          moments
/;
model CE1 /centropyeq
          proper_prob
          moments
/;
options limrow=0,limcol=0;
options solprint=off;
options decimals=8;
options iterlim=1000;

q(k)=1/card(k);
*initialization
p.l(k)=1/card(k);
*Max_H = log2(card(k));
Max_H = log(card(k));

solve ME maximizing obj using nlp;
H_ME = obj.l;
pme(k)=p.l(k);
h_me=H_ME;
display  'Classical MaxEnt using natural log', y, p.l , pme,  moments.m, H_ME, h_me, Max_H;

solve ME_2 maximizing obj using nlp;
H_ME = obj.l;
pme(k)=p.l(k);
h_me=H_ME;
display 'Maximum Entropy Using base 2 logarithm',  y, p.l , pme,  moments.m, H_ME, h_me, Max_H;

*** P squared objective case
p.l(k)=1/card(k);

solve PSQUARED minimizing obj using nlp;
obj_P2 = obj.l;
pe2(k)=p.l(k);
*pce1(k)=p.l(k);
h_me2=-sum(k, p.l(k)*log(p.l(k)+1e-8));
display  y, p.l , pe2,  moments.m, obj_p2, H_ME2, Max_H;

*initialization
p.l(k)=1/card(k);
**q(k) = 1/card(k);
solve CE minimizing obj using nlp;
H_CE = obj.l ;
H_ME = - obj.l + log(card(k));
pce(k)=p.l(k);
h_ce=H_ME;
display  y, p.l, pce, moments.m, q, H_CE, h_ce, H_ME, Max_H;
*****
****

*EL
p.l(k)=1/card(k);
solve EL maximizing obj using nlp;
H_ME = - sum(k,p.l(k)*log((p.l(k))) )      ;
pel(k)=p.l(k);
h_el=H_ME;
display  y, p.l , pel,  moments.m, H_ME, h_el, Max_H;


*initialization
p.l(k)=1/card(k);
***q(k) = 1/card(k);
solve CE1 minimizing obj using nlp;
H_CE = obj.l ;
H_ME = - obj.l + log(card(k));
pce1(k)=p.l(k);
h_ce1=H_ME;
display  y, p.l, pce1, moments.m, q, H_CE, H_ME, h_ce1, Max_H;

*Writing outputs into excel files
$ontext
execute_unload "Classical_ME_Dice_Example.gdx" pme, pce, pel, pce1, h_me, h_ce, h_el, h_ce1;
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pme rng=pme! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pce rng=pce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pel rng=pel! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pce1 rng=pce1! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_me rng=pme!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_ce rng=pce!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_el rng=pel!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_ce1 rng=pce1!C1 Cdim=0 Rdim=0';
$offtext
*Laptop
$ontext
execute_unload "Classical_ME_Dice_Example.gdx" pme, pce, pel, pce1, q, h_me, h_ce, h_el, h_ce1;
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pme rng=pme! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pce rng=pce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pel rng=pel! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pce1 rng=pce1! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=q rng=q! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_me rng=pme!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_ce rng=pce!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_el rng=pel!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=C:\Users\AGolan\Desktop\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_ce1 rng=pce1!C1 Cdim=0 Rdim=0';
*$offtext
*Office
$ontext
execute_unload "Classical_ME_Dice_Example.gdx" pme, pce, pel, pce1, q, h_me, h_ce, h_el, h_ce1;
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=D:\MyDocuments\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pme rng=pme! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=D:\MyDocuments\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pce rng=pce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=D:\MyDocuments\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pel rng=pel! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=D:\MyDocuments\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=pce1 rng=pce1! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=D:\MyDocuments\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=q rng=q! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=D:\MyDocuments\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_me rng=pme!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=D:\MyDocuments\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_ce rng=pce!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=D:\MyDocuments\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_el rng=pel!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=D:\MyDocuments\Tutorial_January_2014\Codes_2014\Info-Metrics_Tutorial_Codes\GAMS\ME\Classical_ME_Dice_Example.xlsx par=h_ce1 rng=pce1!C1 Cdim=0 Rdim=0';
$offtext

$ontext
Make sure to have your directory in the file locations below
$offtext

execute_unload "Classical_ME_Dice_Example.gdx" pme, pce, pel, pce1, q, h_me, h_ce, h_el, h_ce1;
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=Classical_ME_Dice_Example.xlsx par=pme rng=pme! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=Classical_ME_Dice_Example.xlsx par=pce rng=pce! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=Classical_ME_Dice_Example.xlsx par=pel rng=pel! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=Classical_ME_Dice_Example.xlsx par=pce1 rng=pce1! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=Classical_ME_Dice_Example.xlsx par=q rng=q! Cdim=0 Rdim=1';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=Classical_ME_Dice_Example.xlsx par=h_me rng=pme!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=Classical_ME_Dice_Example.xlsx par=h_ce rng=pce!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=Classical_ME_Dice_Example.xlsx par=h_el rng=pel!C1 Cdim=0 Rdim=0';
execute 'gdxxrw.exe Classical_ME_Dice_Example.gdx o=Classical_ME_Dice_Example.xlsx par=h_ce1 rng=pce1!C1 Cdim=0 Rdim=0';

display pce1, pe2;

