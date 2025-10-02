clear all
set more off

use "D:\GMES\LINEAR GME\Example2.dta", clear


mata
y=st_data(1,("y"))

x=st_data(.,("x"))

y
x=x'




function example2 (todo, B,Y,X,L,g,H)
{

L = sum(Y':*B)+ln(sum(exp(-(B*X))))

omega=sum(exp(-(B*X)))
p = exp(-(B*X)):/omega

if (todo>=1)
{
g = Y' - p*X'
}
if (todo==2)
{
H=sum(p:*(X:*X))-(sum(p:*X))*(sum(p:*X))
}

}

s=optimize_init()
optimize_init_evaluator(s,&example2())
// d0 Stata gets the hessian
// d2 Stata uses the provided hessian
optimize_init_evaluatortype(s,"d2")  // try d0 and compare hessians 
optimize_init_which(s,"min")
optimize_init_technique(s, "nr")
optimize_init_singularHmethod(s, "hybrid")
optimize_init_argument(s,1,y)
optimize_init_argument(s,2,x)

optimize_init_conv_maxiter(s,1000000)

optimize_init_params(s,J(1,rows(y),0))
b=optimize(s)

H=optimize_result_Hessian(s)

omega=sum(exp(-(b*x)))
p = exp(-(b*x)):/omega

b // Lambdas
p // Probabilities
H //Hessian

end
