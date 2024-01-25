

proc import out=auto_gme
	datafile = "G:\GME\autosas1.xls"
	dbms=EXCEL4 REPLACE;
	
run;


proc iml;

use auto_gme;
read all var{lnprice} into x;
close auto_gme;
SD=3*std(x);
call symput('sd',left(char(SD)));
print SD;
run;
	




title "GME Estimation 1";
proc entropy data=auto_gme gme outest=param1 outp=lagr;

priors mpg 	    -100 -50 0 50 100;
priors weight       -100 -50 0 50 100;
priors foreign      -100 -50 0 50 100;
priors Intercept    -100 -50 0 50 100;

model lnprice = mpg weight foreign /esupports=(-&sd 0 &sd);

run;

title "OLS Estimation 1";

proc reg data=auto_gme outest=param2;
model lnprice=mpg weight foreign;
run;
