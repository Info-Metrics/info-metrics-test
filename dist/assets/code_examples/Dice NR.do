clear all
set more off

mata


/*Parameters*/
x=1,2,3,4,5,6

y=1  //this is the observed mean

y=y+1e-15 //in order to achieve convergence (p!=0 but close to 0)
P=J(cols(x),1,.)
b=0

/*Construct P numerator*/

for (a=1; a<=6; a++) {
P[a,1]=exp(-x[1,a]*b)
}

/*Starting parameters, initial lambda*/
b=0
/* hessian*/

h=J(rows(y),rows(y),.)


/* Cha measures the change between the new estimated lambda and the old one*/
cha=1

/* iterations counter*/
iter = 1

/** OUR MAIN FUNCTION **/

while (abs(cha)>1e-15) { //So while the change between the old beta and new one is greater than the value we continue looping

for (a=1; a<=6; a++) {  //generate the numerator using the given beta
P[a,1]=exp(-x[1,a]*b)
}

omega=sum(P)  // our omega is just the sum of the numerators



for (a=1; a<=6; a++) {
P[a,1]=(exp(-x[1,a]*b))/omega  //Our probability vector
}


grad=y-x*P  // Our gradient Vector (Tx1)


hes=sum((x':*x'):*P)-(sum((x':*P))^2)  // Hessian Matrix (TxT), the : is an element by element operator


iter = iter+1  //Count number of iterations
bold=b	//set b old equal to the current b in order to estimate the new b

b = bold - cholinv(hes)*grad  // This is the essence of the Newton Rhapson

cha = b-bold 	// Change between the old beta and new

} 

iter  //number of iterations until convergence
b     //lambdas
P     //Probabilities
end






