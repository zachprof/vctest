*! Title:       vctest_regress.ado   
*! Author:      Zachary King 
*! Email:       me@zach.prof
*! Description: vctest support program that runs the regress regression command

program define vctest_regress

	syntax [if] [in], model(string) [quietly]
	
	* Run model a if model a specified; suppress output if `quietly' specified
	
	if "`model'" == "a" {
		`quietly' di ""
		`quietly' di "Regression output for model a:"
		`quietly' $vctest_model_a
	}
	
	* Run model b if model b specified; suppress output if `quietly' specified
	
	if "`model'" == "b" {
		`quietly' di ""
		`quietly' di "Regression output for model b:"
		`quietly' $vctest_model_b
	}
	
	* Save # of obs if model a specified, else verify # of obs same as model a
	
	if "`model'" == "a" global vctest_n = e(N)
	else if e(N) != $vctest_n {
		di as error "Number of nonmissing values differs across models"
		exit 416
	}
	
	* Save sample-wide sigma squared suggested by Dechow (1994, 38-39)
	
	global vctest_sigma2_`model' = e(rss) / e(N)
	
	* Save number of estimated parameters
	
	global vctest_params_`model' = e(rank)
	
	* Save R2
	
	global vctest_r2_`model' = e(r2) 
	
	* Save adjusted R2
	
	global vctest_adjr2_`model' = e(r2_a) 
	
	* Save residuals
	
	tempvar resid
	qui: predict double `resid' `if' `in' , residuals
	mkmat `resid', mat(vctest_residuals_`model')
	
end