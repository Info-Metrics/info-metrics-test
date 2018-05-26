$offsymxref offsymlist
$ontext
  Info-Metrics Tutorial AU 4/8/2013
  Classical ME CE and Dual formulations for the Matrix Balancing problem:
  y=Ax where A is a K by K matrix and coefficients of each one of the K
  columns sum up to 1 (i.e., proper distribution).
  Example 1: an 11 by 11 SAM of the US
  Comparing the primal and concentrated (dual) models
  Try with the given priors and with uniform priors
  Reference: Golan, Judge, Robinson, RESTAT 1994
  Updated on January 19th, 2014
$offtext

SET i index for columns and rows /
      cows
      foodg
      feedg
      otherag
      foodmfg
      resource
      intermed
      finalmfg
      construct
      services
      valadd /
;

alias (j,i);

parameter  q(i,j)                Real flows
           q0(i,j)               Prior flows
           q1(i,j)               Prior coefficients
           Y(i)                  rows totals
           X(j)                  columns totals
           X1(j)                 columns totals for priors
           omeg(j)               Partition function for dual
           recparam(i,j)         Recovered coeff primal CE
           recparam1(i,j)        Recovered coeff dual CE
           sumdiff               Sum of absolute values of expa
           expa(i,j)             Difference between parameters
           maxx                  Max value

;

Table  q0(i,j)   The priors:  IO flows in 1977


                FOODG       FEEDG     OTHERAG    RESOURCE   CONSTRUCT

FOODG        3400.585       2.768       3.832      13.788      32.054
FEEDG           1.330    8159.198       9.370      32.629      65.398
OTHERAG         5.740    1636.609   11838.931     736.287     822.594
RESOURCE     3939.811   15927.017   11664.995  740920.816   96203.784
CONSTRUCT     663.000    2944.000    3141.000   40397.000    3035.000
COWS         1247.538    9135.935    3011.039     136.517     162.425
FOODMFG        19.290     115.997      70.744    1214.368     472.293
INTERMED     6864.175   40022.758   27269.133  105920.165  765717.475
FINALMFG      604.906    3857.617    4505.117   20440.629  148758.170
SERVICES    15683.624   64427.101   70104.839  231639.800  511924.809
VALADD      23936.000  104283.000  212243.000  672510.990 1116143.998

        +        COWS     FOODMFG    INTERMED    FINALMFG    SERVICES

FOODG        1138.828   23100.777      59.475      46.912     638.660
FEEDG      136349.935   33835.192     480.827     105.587    9686.176
OTHERAG       241.788  100117.004    5336.764   44149.629   12099.850
RESOURCE     5490.389   24782.036  278837.090   54663.185  500883.002
CONSTRUCT    3259.000    8646.000   49038.000   21188.000  442935.000
COWS        89046.713  367459.472     959.932    1981.632   13545.080
FOODMFG    110713.855  325389.664   15064.502    9877.317  278911.638
INTERMED    11142.860  137829.169 1842082.908  919000.504  288804.624
FINALMFG     3625.258   71416.153  232971.258 1413705.430  437633.826
SERVICES    81627.375  290621.532  872981.242  686026.812 3635846.128
VALADD      80283.001  508803.997 2202783.012 2017540.057 1.296087E+7

        +      VALADD

FOODG       27928.322
FEEDG       61786.358
OTHERAG    166876.802
RESOURCE    80650.865
CONSTRUCT 2068092.000
COWS        36232.720
FOODMFG   1150151.328
INTERMED  1355941.238
FINALMFG  2830766.700
SERVICES  1.212097E+7
;

Table q(i,j)  The data: IO flows in 1982


                FOODG       FEEDG     OTHERAG    RESOURCE   CONSTRUCT

FOODG        5192.270      10.376       9.206      67.071     171.567
FEEDG           5.503    8122.971      22.569     160.849     409.607
OTHERAG         8.911    2665.170   15022.278    1069.184    1094.426
RESOURCE    11058.366   33261.514   22376.086 1608606.011  193431.637
CONSTRUCT     927.000    3805.000    3687.000   52901.000    4518.000
COWS         1828.320   11124.340    2864.119     311.497     146.106
FOODMFG        17.499      94.352      49.496    2193.996     256.701
INTERMED     8921.537   47210.092   30317.526  129333.474 1009579.809
FINALMFG      958.265    3673.509    9756.187   25773.982  239366.936
SERVICES    23390.328   88567.674   92691.532  635879.967  878859.211
VALADD      63719.000  195569.000  270268.001 1597840.996 2060076.999

        +        COWS     FOODMFG    INTERMED    FINALMFG    SERVICES

FOODG        3098.868   32959.806     241.178     221.096    6621.753
FEEDG      242666.214   32998.797     578.874     528.303   15327.966
OTHERAG       278.064  126816.495    5293.691   48000.979   29507.458
RESOURCE    11561.902   44349.841  328086.882  111307.838 1182309.024
CONSTRUCT    7109.000    5081.000   54090.000   32168.000  701832.000
COWS       163596.715  557281.812    1341.247    1743.756   20024.762
FOODMFG    116596.800  482382.342   12598.577   10957.177  452060.338
INTERMED    11925.888  219530.746 2257681.720 1120084.317  517009.053
FINALMFG     4185.948  103070.988  292916.308 1906202.492  819689.384
SERVICES   133472.603  458772.176 1389641.547 1218327.026 6815858.391
VALADD     108835.004  710713.994 2738469.975 2991522.026 2.157768E+7

        +      VALADD

FOODG       67433.809
FEEDG       93282.346
OTHERAG    217307.345
RESOURCE   507788.926
CONSTRUCT 3521793.000
COWS        43064.330
FOODMFG   1696750.719
INTERMED  1729345.837
FINALMFG  4035469.010
SERVICES  2.040246E+7
;

**Converting data and prior flows to coefficients/probabilities

*calculating rows totals for data
Y(i) = sum(j,q(i,j));

*calculating columns totals
X(j) = sum(i,q(i,j));

*calculating rows totals for priors
X1(j) = sum(i,q0(i,j));

*calculating prior coefficients
q1(i,j) = q0(i,j)/(X1(j)+1.e-8);

**Uniform priors
q1(i,j)=1/card(i);

display Y, X, q1;

positive variables
   a(i,j)    coefficients
;

variables

        obj  objective function
        lm(i) Lagrange multipliers
;

equations

objective   objective function
objdual     Dual CE objective
row(i)      row constraint
col(j)      column constraint
;

*The pure Cross Entropy case
objective..   obj =e= sum(i,sum(j,a(i,j)*log((1.e-7+a(i,j)) / (1.e-7+q1(i,j)))));

** Using the centropy function
*objective..   obj =e= sum(i,sum(j,centropy(a(i,j),q1(i,j) )));

**The Dual CE
objdual..       obj =e= sum(i,Y(i)*lm(i)) -
                       sum(j,log(sum(i,(q1(i,j)*exp(lm(i)*X(j))))));

**Clasical ME/CE
col(j)..      sum(i,a(i,j)) =e= 1;
row(i)..      sum(j,a(i,j)*X(j)) =e= Y(i);


*initialization
a.l(i,j) = 1/card(i);


model PRIMAL  primal classical CE/
  objective
  col
  row
/;

model DUAL  dual CE /objdual
/;

***Another solver
*options nlp=minos5;
options limrow=0,limcol=0;
options solprint=off;
options decimals=7;
options iterlim=2500;
options domlim=5000;

**Classical primal CE
solve PRIMAL minimizing obj using nlp;

display q1, a.l, Y, X, row.m, col.m;

recparam1(i,j)=a.l(i,j);
expa(i,j) = recparam1(i,j) - q1(i,j);
sumdiff=sum(i,sum(j,abs(expa(i,j))));

** Difference between recovered parameters and priors
display expa;
display sumdiff;

*Normalizing data for dual CE
maxx = smax((i),x(i) );
display maxx;

Y(i) = Y(i)/maxx;
X(j) = X(j)/maxx;

*Initializing starting values
lm.l(i) = 0;

**Dual CE
solve DUAL maximizing obj using nlp;

omeg(j) = sum(i,(q1(i,j)*exp(lm.l(i)*X(j))));
recparam(i,j) = q1(i,j)*exp(lm.l(i)*X(j))/omeg(j);
display recparam, lm.l;

********** Difference between primal parameters and dual parameters
expa(i,j)=recparam(i,j)-recparam1(i,j);
display expa;
sumdiff=sum(i,sum(j,abs(expa(i,j))));
display sumdiff;
**********

**********Difference between dual parameters and priors
expa(i,j) = recparam(i,j) - q1(i,j);
sumdiff=sum(i,sum(j,abs(expa(i,j))));
display expa;
display sumdiff;
**********

recparam(i,j)=recparam(i,j)*maxx;
display recparam, q;

expa(i,j)=0;
expa(i,j) = recparam(i,j) - q1(i,j);
sumdiff=sum(i,sum(j,abs(expa(i,j))));
display expa;
display sumdiff;

expa(i,j)=0;
expa(i,j)=recparam(i,j)-recparam1(i,j);
display expa;
sumdiff=sum(i,sum(j,abs(expa(i,j))));
display sumdiff;

