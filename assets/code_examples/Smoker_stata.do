* Discrete GME expample
* Written on Dec. 20, 2014
/* Golan, A., Judge, G., & Perloff, J. M. (1996).
A Maximum Entropy Approach to Recovering Information From Multinomial 
Response Data. Journal of the American Statistical Association, 
91(434), 841-853. doi: 10.2307/2291679 */

* Estimation using smoker data set 

clear all
use "D:\Documents\INFO METRICS\SMKban.dta", clear

local X smkban female age hsdrop hsgrad colsome colgrad black hispanic
local Y smoker

** Basic estimation
gmentropylogit `Y' `X'

** Estimated Marginal effects
gmentropylogit `Y' `X', mfx

** Predicted probabilities
gmentropylogit `Y' `X', gen(pred)
