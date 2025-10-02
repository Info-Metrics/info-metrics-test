
clear all
set more off
mata


x=1,2,3,4,5,6
y=4\3
tosses=2000\1000


// Error support adjusted by # tosses
sqrt(variance(y))
mY=mean(y)

//Increment
inc=.1
//bound
bound=1.5

//Hold results for p and w
probs=J(rows(x),cols(x),0)
errors=0
//Hold results for lambda
lambda=J(1,6,0)

void mydice(todo, b, x, y,v, L, g, H)
{
L = b*y + ln(rowsum(exp(colsum(-b'x))))+sum(ln(rowsum(exp(-b':*v))))
}


while (bound<=9){
//bound=3

v=(tosses[2]/tosses[1])*(-bound*sqrt(variance(y)),0,bound*sqrt(variance(y)))\(-bound*sqrt(variance(y)),0,bound*sqrt(variance(y)))


//Initiate optimization
s=optimize_init()
optimize_init_evaluator(s,&mydice())
optimize_init_evaluatortype(s,"d0")
optimize_init_which(s,"min")
optimize_init_argument(s,2,y)
optimize_init_argument(s,1,x)
optimize_init_argument(s,3,v)

optimize_init_params(s,(0,0))  //Lambdas
b=optimize(s)

p=exp(colsum(-b'x)):/sum(exp(colsum(-b'x)))
probs=probs\p

w=(exp(-b':*v)):/rowsum(exp(-b':*v))

Hp=-sum(p:*ln(p))
Hw=-sum(w:*ln(w))
lambda=lambda\(b,v[1,3],v[2,3],Hp,Hw)




bound=bound+inc
}
//

st_matrix("lambda",lambda)

end

svmat lambda
rename lambda3 bound1
rename lambda4 bound2
rename lambda5 Hp
rename lambda6 Hw
drop in 1

//Compare data to the one provided by Gams
