data GME (keep=x1 x2 x3 x4 y);
call streaminit(4321);
do i = 1 to 74;
   x1= rand("Uniform",0,10);
   x2=x1+rand("Normal",0,0.3);
   x3=rand("Uniform",0,10);
   x4=1;
   y=2*x1+1*x2-3*x3+2*x4+rand('cauchy');
output;
end;
run;

proc iml;

use GME;
read all var{y} into x;
close GME;
SD=3*std(x);
call symput('sd',left(char(SD)));
print SD;
run;

title "GME Estimation 1";
proc entropy data=GME gme outest=param1 outp=lagr;

priors x1 	    -100 -50 0 50 100;
priors x2           -100 -50 0 50 100;
priors x3           -100 -50 0 50 100;
priors Intercept    -100 -50 0 50 100;

model y = x1 x2 x3 /esupports=(-&sd 0 &sd);

run;


title "OLS Estimation 1";

proc reg data=GME outest=param2;
model y = x1 x2 x3;
run;

