$offsymxref offsymlist
$ontext
  Info-Metrics Tutorial AU 4/8/2013
  Classical ME CE and Dual formulations for the Matrix Balancing problem:
  y=Ax where A is a I by I matrix and coefficients of each one of the I
  columns sum up to 1 (i.e., proper distribution).

  Example 2: Creating your own matrix, data and priors
  Try with different priors and matrix size
  Updated on November 21, 2014
$offtext

set i dimension of matrix /1*4/
;
alias (j,i);

parameter
           q(i,j)            Real flows
           q0(i,j)           Prior flows
           q1(i,j)           Prior coefficients
           Y(i)              Row totals
           X(j)              Column totals
           X1(j)             Column totals for priors
           n                 Number of states (i squared)
           m                 Number of param in prob space MINUS one
           omeg(j)           Paretition function for dual
           recparam(i,j)     Recovered coeff dual CE
           recparam1(i,j)    Recovered coeff dual CE
           sumdiff           Sum of absolute values of expa
           expa(i,j)         Difference between parameters
           maxx              Max value
;

*Create the priors
q0(i,j)=uniform(0,10);

*Create the Data
q(i,j)=normal(20,3);
display q;

***Example of perfect priors (i.e., priors equal the correct coeff)
**Look at the value of optimal objective here - should be zero
*q0(i,j) = q(i,j);
**Uniform priors example (i.e., CE=ME)
*q0(i,j) = 1/card(i);

**Converting data and prior flows to coefficients/probabilities
*calculating row totals for data
Y(i) = sum(j,q(i,j));

*calculating column totals
X(j) = sum(i,q(i,j));

*calculating row totals for priors
X1(j) = sum(i,q0(i,j));

*calculating prior coefficients
q1(i,j) = q0(i,j)/(X1(j)+1.e-8);
*q1(i,j) = 1/card(i);

positive variables

   a(i,j)    Coefficients
;
variables

        obj   Objective function
        lm(i) Lagrange multipliers
;

equations

objective   Objective function
objdual     Dual CE objective
row(i)      Row constraint
col(j)      Column constraint
add(i,j)    Adding up
aij(i,j)    aij coefficients
;

*The pure Cross Entropy case
objective..   obj =e= sum(i,sum(j,a(i,j)*log((1.e-7+a(i,j)) / (1.e-7+q1(i,j)))));

**The Dual CE
objdual..     obj =e= sum(i,Y(i)*lm(i)) -
                      sum(j,log(sum(i,(q1(i,j)*exp(lm(i)*X(j))))));

**Constraints for Clasical ME/CE
col(j)..      sum(i,a(i,j))      =e= 1;
row(i)..      sum(j,a(i,j)*X(j)) =e= Y(i);

model PRIMAL  primal classical CE/
  objective
  col
  row
/;

model DUAL  dual CE /
objdual
/;

***Another solver
*options nlp=minos5;
options limrow   =0,limcol=0;
options solprint =off;
options decimals =7;
options iterlim  =25000;
options domlim   =5000;

**Classical primal CE
solve PRIMAL minimizing obj using nlp;
display q1, a.l, Y, X, row.m, col.m;

recparam1(i,j) = a.l(i,j);
expa(i,j)      = recparam1(i,j) - q1(i,j);
sumdiff        = sum(i,sum(j,abs(expa(i,j))));
display expa;
display sumdiff;

*Normalizing data for dual CE
maxx = smax((i),x(i));
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
sumdiff   = sum(i,sum(j,abs(expa(i,j))));

*** Difference between recovered parameters from DUAL and priors
display expa;
display sumdiff;


expa(i,j) = 0;
expa(i,j) = recparam(i,j)-recparam1(i,j);
sumdiff   = sum(i,sum(j,abs(expa(i,j))));

*** Difference between recovered parameters from DUAL and Primal
display expa;
display sumdiff;
