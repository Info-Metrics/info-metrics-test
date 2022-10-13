$ontext
Dice example with noise
$offtext
set  k     index - dimension of probability /1*6/
     t     index - no. of observations /1*2/
     m     index for error suppport space /1*3/
;

parameter  phat(k)  estimated values
           X(k)   RHS matrix dimension T by K
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

           obj_P2   objective value of p squared case
           pe2(k)   estimated probs for p squared case
           h_me2    entropy of p squared case
           v(t,m)     Error supports
           mean_y
           var_y
           sd_y
p_1(k)
omega
hp
hw


;

*Creating the X
X("1")=1 ;
X("2")=2 ;
X("3")=3 ;
X("4")=4 ;
X("5")=5 ;
X("6")=6 ;

*The mean value - first moment
** Try 3.5, 4, 5.7
y("1") = 4;
y("2") = 3;

*** Error supports
Mean_Y = sum(t,Y(t))/(card(t));
Var_Y=sum(t,((y(t) - Mean_Y)*(y(t) - Mean_Y)) ) /(card(t) - 1);
SD_Y = sqrt(Var_Y);
v("2","1") = -(3*SD_Y);
v("2","3") = (3*SD_Y);
v("1","1") = -(3*SD_Y)/2;
v("1","3") = (3*SD_Y)/2;
display mean_y, var_y, sd_y;

* Actual optimization
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

solve ME maximizing obj using nlp;

H_ME = obj.l;
pme(k)=p.l(k);
h_me=H_ME;
Max_H = log(card(k));
omega=sum(k,exp(sum(t, moments.m(t)*x(k))))  ;

p_1(k)=exp(sum(t, moments.m(t)*x(k)))/omega;
hp= -sum(k,p.l(k)*log((p.l(k)))) ;
hw= -sum(t,sum(m,w.l(m,t)*log(w.l(m,t))))  ;

display  y, p.l, w.l, v, moments.m, H_ME, h_me, Max_H, p_1, p.l, hp, hw;



