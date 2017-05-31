proc import out=smoke_gme
	datafile = "G:\SAS discret\smoking1.xls"
	dbms=EXCEL4 REPLACE;
	
run;


proc iml;

use smoke_gme;
read all var{smkban} into x;

T=1/sqrt(nrow(x));

call symput('support',left(char(T)));
print T;

run;


title "GME Estimation 1";
proc entropy data=smoke_gme gmed outest=param1 outp=lagr;

model smoker=smkban female age hsdrop hsgrad colsome colgrad black hispanic/esupports=(-&support 0 &support);
run;

