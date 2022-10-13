/* Program does a sample experiment
it generates random data and presents
estimates of the MSE for GME multinomial 
logit as well as for the multinomial
logit.

First install gmeMlogit

January 30, 2015 */

** Note for user to control for avg number of cond. freq for each category


**** Data generation 
clear all
set more off

local Obs=100      /// Number of obserations

local loops=100    /// Number of loops

local Seed=1233    /// Initial seed



** Start off counter
local i=1

while `i'<=`loops'{
qui{
clear

set obs `Obs'

local Seed=`Seed'+`i'

set seed `Seed'

***Observable info
gen x1=rnormal(0,2)
gen h=runiform()
gen x2=h>0.8
drop h
gen x3=x1>1
gen h=runiform()
gen x4=h>0.8
drop h
gen x5=3+(18-3)*runiform()

*** Go to mata to obtain p quickly


** Import covariate matrix to mata
mata:x=st_data(.,("x1","x2","x3","x4","x5"))

** Indicate true coefficients
mata:beta=(0,0,0,0,0)\(.2,0,.2,1,-.1)\(0.4,1,.4,.5,-.3)

** Obtain true probabilities
		mata:S=x*beta'
		
		mata:omega=rowsum(exp(-S))
		
		mata:p=exp(-S):/omega
		
		** Send p matrix to stata
		mata:st_matrix("p", p)
		


** Back to stata
	
	*save p's as variables
	svmat p, names(probs)
	
	*** Create choice categories
		gen h=runiform()  

		gen limit=probs2+probs3

		*** categorical Y
		gen y1=h<probs1
		gen y2=h>=probs1 & h<limit
		gen y3=h>=limit
		
		gen Y=.
		
		forvalues c=1/3{
			
			replace Y=`c' if y`c'==1
			
			}
			
mlogit Y x*, nocons base(1)

*** Matrix to keep coefficients of logit
mat A=nullmat(A)\e(b)

*** Indicate equations (categories)
mat eqs=e(k_eq)

*** GME M Logit command
gmeMlogit Y x*, nocons
*** Matrix to keep coefficients of gme logit
mat B=nullmat(B)\e(b)

local i=`i'+1
}
}
*** End of loop



*** Mata to obtain MSE
mata

jay=st_matrix("eqs")
kay=cols(beta)

mlogcoeffs=st_matrix("A")
gmecoeffs=J(rows(mlogcoeffs),cols(beta),0),st_matrix("B")

Betas=J(rows(mlogcoeffs),1,vec(beta')')

MSE_gme=(sum((gmecoeffs-Betas):^2)/((jay-1)*kay))/rows(Betas)

MSE_logit=(sum((mlogcoeffs-Betas):^2)/((jay-1)*kay))/rows(Betas)

MSE_gme
MSE_logit

end


	
