clear all
sysuse auto, clear

gen lnprice=ln(price)

mat support=(-100,-50,0,50,100)\(-100,-50,0,50,100)\(-100,-50,0,50,100)\(-100,-50,0,50,100)

gmentropylinear lnprice mpg weight foreign, sup(support)  

*reg lnprice mpg weight foreign

