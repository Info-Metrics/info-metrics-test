clear all
mata

x=1,2,3,4,5,6
y=1

void mydice(todo, b, x, y, L, g, H)
{
L = b*y + ln(sum(exp(-x:*b)))
}

s=optimize_init()
optimize_init_evaluator(s,&mydice())
optimize_init_evaluatortype(s,"d0")
optimize_init_which(s,"min")
optimize_init_argument(s,2,y)
optimize_init_argument(s,1,x)

optimize_init_params(s,0)
b=optimize(s)
b

x

p=exp(-b*x):/sum(exp(-b*x))

p


end
