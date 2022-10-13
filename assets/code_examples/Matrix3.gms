$offsymxref offsymlist
$ontext
  Info-Metrics Class AU, Fall/2013
  Classical ME CE and Dual and GME/GCE formulations for the Matrix Balancing problem:
  y=Ax where A is a i by i matrix and coefficients of each one of the i
  columns sum up to 1 (i.e., proper distribution).

  Example 3: Create your own matrix, data and priors
             And solve also the Generalized ME (GME)
             Compare the mean sq errors for ME and GME
             Investigate sensitivity for number of errors' supports

 Updated on January 19th, 2014
$offtext

SET i      Matrix dimension /1*10/
;

set
     h     Error support index /1*3/
;

alias (j,i);

parameter
           q(i,j)                Real flows
           q0(i,j)               Prior flows
           q1(i,j)               Prior coefficients
           Y(i)                  Row totals
           X(j)                  Column totals
           X1(j)                 Column totals for priors
           omeg(j)               Partition function for dual
           recparam(i,j)         Recovered coeff dual CE
           recparam1(i,j)        Recovered coeff dual CE
           sumdiff
           expa(i,j)
           maxx
           pureq(i,j)            Pure data
           w0(i,h)               Priors for noise probabilities GCE
           bound                 Lower and upper bound for error supports
           dist                  Distance between estimated and predicted
           MSECE                 Mean Sq error CE
           MSEGCE                Mean Sq error GCE
           Xpure(j)
           correctp(i,j)         Correct coefficients before noise is added
           alphae(h)             Error supports
;

*Create the priors
q0(i,j)=normal(20,10);
q0(i,j)$(q0(i,j) lt 0) = 0.1;
*q0(i,j)$(q0(i,j) lt 0) = uniform(0,1);
display q0;

*Create the Data
pureq(i,j)    = q0(i,j);
Xpure(j)      = sum(i,pureq(i,j));
correctp(i,j) = pureq(i,j)/Xpure(j);

**Add noise to Pure data
*Normal noise
q(i,j)   =  pureq(i,j)+normal(0,5);
display q;

*Uniform noise example
*q(i,j)=pureq(i,j)+uniform(-5,5);

***Example of perfect priors (i.e., priors equal the correct coeff)

**Look at the value of optimal objective here - should be zero
*q0(i,j) = q(i,j);

**Unifot\rm priors example (i.e., CE=ME)
*q0(i,j) = 1/card(i);

**Converting data and prior flows to coefficients/probabilities
*calculating rows totals for data
Y(i) = sum(j,q(i,j));

*calculating columns totals
X(j) = sum(i,q(i,j));

*calculating rows totals for priors
X1(j) = sum(i,q0(i,j));

*calculating prior coefficients
q1(i,j) = q0(i,j)/(X1(j)+1.e-8);

positive variables

   a(i,j)   coefficients
   w(i,h)   noise probabilities for GME
;

variables

        obj   objective function
        lm(i) Lagrange multipliers
        error(i)
;

equations

objective   objective function
objdual     Dual CE objective
objgce      GCE objective
row(i)      row constraint
col(j)      column constraint
add(i,j)    adding up
aij (i,j)   aij coefficients
rowgme(i)   data specification for GME (instead of specification "row")
adde(i)     adding up errors for GME
eqe(i)      errors definition for GME
objdualgce  dual gce objective function
;

*The pure Cross Entropy case
objective..   obj =e= sum(i,sum(j,a(i,j)*log((1.e-7+a(i,j)) / (1.e-7+q1(i,j)))));

**The Dual CE
objdual..     obj =e= sum(i,Y(i)*lm(i)) -
                      sum(j,log(sum(i,(q1(i,j)*exp(lm(i)*X(j))))));

**Clasical ME/CE
col(j)..      sum(i,a(i,j))      =e= 1;
row(i)..      sum(j,a(i,j)*X(j)) =e= Y(i);


*GME formulation (i.e., accomodating for possible noise in data)
*The Generalized Cross Entropy case
objgce..  obj =e= sum(i,sum(j,a(i,j)*log((1.e-6+a(i,j)) / (1.e-6+q1(i,j)))))
               +  sum(i,sum(h,w(i,h)*log((1.e-6+w(i,h)) / (1.e-6+w0(i,h)))));

*GME reformulation and equations
rowgme(i)..         sum(j,a(i,j)*X(j)) + error(i) =e= Y(i);
adde(i)..           sum(h,w(i,h)) =e= 1;
eqe(i)..            sum(h,alphae(h) * w(i,h)) =e= error(i);

**The Dual GCE
objdualgce..    obj =e= sum(i,Y(i)*lm(i))
                     -  sum(j,log(sum(i,(q1(i,j)*exp(lm(i)*X(j))))))
                     -  sum(i,log(sum(h,(w0(i,h)*exp(alphae(h)*lm(i))))));


*initialization
a.l(i,j)   = 1/card(i);
w.l(i,h)   = 1/card(h);

model PRIMAL  primal classical CE/
  objective
  col
  row
/;

model DUAL  dual CE /
  objdual
/;

model GCE  /
  objgce
  rowgme
  col
  adde
  eqe
/;

model DUALGCE  dual CE /
objdualgce
/;

***Another solver
options nlp      = minos5;
options limrow   = 0,limcol=0;
options solprint = off;
options decimals = 7;
options iterlim  = 2500;
options domlim   = 5000;

*q1(i,j) = 1/card(i);

**Classical primal CE
solve PRIMAL minimizing obj using nlp;
display q1, a.l, Y, X, row.m, col.m;

recparam1(i,j)=a.l(i,j);

dist(i,j) = recparam1(i,j) - correctp(i,j);
*MSECE = sum(i,sum(j,dist(i,j)*dist(i,j)));
MSECE=sum(i,sum(j,power((a.l(i,j)-correctp(i,j)),2)));

display dist, msece;


*Normalizing data for dual CE
maxx = smax((i),x(i) );
Y(i) = Y(i)/maxx;
X(j) = X(j)/maxx;

*Initializing starting values
lm.l(i) = 0;

**Dual CE
solve DUAL maximizing obj using nlp;

omeg(j)       = sum(i,(q1(i,j)*exp(lm.l(i)*X(j))));
recparam(i,j) = q1(i,j)*exp(lm.l(i)*X(j))/omeg(j);
display recparam, lm.l;

expa(i,j) = 0;
expa(i,j) = recparam(i,j) - q1(i,j);
sumdiff=sum(i,sum(j,abs(expa(i,j))));
display expa;
display sumdiff;

expa(i,j) = 0;
expa(i,j) = recparam(i,j)-recparam1(i,j);
display expa;
sumdiff   = sum(i,sum(j,abs(expa(i,j))));
display sumdiff;

MSECE     = sum(i,sum(j,power((a.l(i,j)-correctp(i,j)),2)));

display  msece;

**GCE primal model

**Uniform noise prior probabilities
w0(i,h)   = 1/card(h);

**creating the bounds on errors support
bound     = card(i);

alphae(h)    = 0;
alphae("1")  = -(1/bound);
*alphae("2") = -(1/(bound*2));
*alphae("4") =  (1/(bound*2));
alphae("3")  =  (1/bound);

*alphae("1") = -1;
*alphae("3") = 1;
display alphae;

a.l(i,j) = 1/card(i);
w.l(i,h) = 1/ card(h);
solve GCE minimizing obj using nlp;

MSEGCE   = sum(i,sum(j,power((a.l(i,j)-correctp(i,j)),2)));

display a.l, error.l, rowgme.m, col.m, msegce;

recparam1(i,j)= a.l(i,j);
expa(i,j)     = recparam1(i,j) - q1(i,j);
sumdiff       = sum(i,sum(j,abs(expa(i,j))));
display expa;
display sumdiff;

**Dual GCE
*Initializing starting values
lm.l(i)  = 0;
a.l(i,j) = 1/card(i);
w.l(i,h) = 1/ card(h);
solve DUALGCE maximizing obj using nlp;

omeg(j)       = sum(i,(q1(i,j)*exp(lm.l(i)*X(j))));
recparam(i,j) = q1(i,j)*exp(lm.l(i)*X(j))/omeg(j);
MSEGCE        = sum(i,sum(j,power((recparam(i,j)-correctp(i,j)),2)));

display recparam, lm.l,  msegce;
