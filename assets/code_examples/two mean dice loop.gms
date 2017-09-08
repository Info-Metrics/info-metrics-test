$ontext
Dice example with noise, examines the relationship between H(p),
H(w) as the bounds on the error supports change

$offtext

set  k     index - dimension of probability /1*6/
     t     index - no. of observations /1*2/
     m     index for error suppport space /1*3/
;

parameter  pme(k)   estimated values
           X(k)     RHS matrix dimension T by K
           y(t)     observed (mean) moment
           h_me     Equal to H_ME under ME case
           v(t,m)   Error supports
           mean_y   Mean value for Y
           var_y    Variance of Y
           sd_y     Standard deviation of Y
           hp       Entropy for dice probabilities
           hw       Entropy for error probabilities
           bound    Bound for error supports
           Sp       Normalized entropy for probabilites
           Sw       Normalized entropy for error support weigths
           STotal   Total normalized entropy
;

*Creating the X
X("1")=1 ;
X("2")=2 ;
X("3")=3 ;
X("4")=4 ;
X("5")=5 ;
X("6")=6 ;

*The mean value - first moment and initial bound
y("1") = 3;
y("2") = 4;
bound=1.5;

positive variables
       p(k)   estimated probabilities
       w(m,t) weight for errors

;
variables
        obj  objective function
;

equations

object_me       ME objective function
moments(t)      The data points - observed moments
proper_prob     The proper prob requirement - normalization
proper_prob2(t) The proper prob requirement - normalization

;

object_me..  obj =e= - sum(k,p(k)*log((p(k)+1.e-8)))-sum(t,sum(m,w(m,t)*log(w(m,t)+1.e-8)));

moments(t)..  y(t) =e= sum(k,X(k)*p(k))+sum(m, w(m,t)*v(t,m));

proper_prob..          sum(k,p(k)) =e= 1;
proper_prob2(t)..      sum(m,w(m,t)) =e= 1;

model ME /object_me
          proper_prob
          proper_prob2
          moments
/;

file data /d:data.txt/;
data.pc = 5;
put data;
data.ND=5;
put "bound1","bound2", "y1","lambda1", "y2", "lambda2", "hp", "hw", "Sp", "Sw", "STotal"/;

** Initialize loop
while(bound <=9,
*** Error supports
Mean_Y = sum(t,Y(t))/(card(t));
Var_Y=sum(t,((y(t) - Mean_Y)*(y(t) - Mean_Y)) ) /(card(t) - 1);
SD_Y = sqrt(Var_Y);
v("1","1") = -(bound*SD_Y);
v("1","3") = (bound*SD_Y);
v("2","1") = -(bound*SD_Y)/2;
v("2","3") = (bound*SD_Y)/2;
*display mean_y, var_y, sd_y;



solve ME maximizing obj using nlp;

H_ME = obj.l;
pme(k)=p.l(k);
hp= -sum(k,p.l(k)*log((p.l(k)))) ;
hw= -sum(t,sum(m,w.l(m,t)*log(w.l(m,t))))  ;
Sp = hp/(log(card(k)));
Sw = hw/(card(t) * (log(card(m))) );
STotal = obj.l/(log(card(k)) + (card(t) * log(card(m))) );

bound=bound+.1

put v("2","3"),v("1","3"),y("1"), moments.m("1"), y("2"), moments.m("2"), hp, hw, Sp, Sw, STotal/;
**End loop
)

putclose;

* Case 2, change y1=2 and y2=5

y("1") = 2;
y("2") = 5;

file data2 /d:data2.txt/;
data2.pc = 5;
put data2;
data2.ND=5;
put "bound1","bound2", "y1","lambda1", "y2", "lambda2", "hp", "hw", "Sp", "Sw", "STotal"/;

bound=1.5;

*** Initialize loop
while(bound <=9,
*** Error supports
Mean_Y = sum(t,Y(t))/(card(t));
Var_Y=sum(t,((y(t) - Mean_Y)*(y(t) - Mean_Y)) ) /(card(t) - 1);
SD_Y = sqrt(Var_Y);
v("1","1") = -(bound*SD_Y);
v("1","3") = (bound*SD_Y);
v("2","1") = -(bound*SD_Y)/2;
v("2","3") = (bound*SD_Y)/2;
*display mean_y, var_y, sd_y;



solve ME maximizing obj using nlp;

H_ME = obj.l;
pme(k)=p.l(k);
hp= -sum(k,p.l(k)*log((p.l(k)))) ;
hw= -sum(t,sum(m,w.l(m,t)*log(w.l(m,t))))  ;
Sp = hp/(log(card(k)));
Sw = hw/(card(t) * (log(card(m))) );
STotal = obj.l/(log(card(k)) + (card(t) * log(card(m))) );

bound=bound+.1

put v("2","3"),v("1","3"),y("1"), moments.m("1"), y("2"), moments.m("2"), hp, hw, Sp, Sw, STotal/;
*Finalize loop
)

putclose;

