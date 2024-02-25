*! Title:       vctest_boxcox.ado   
*! Author:      Zachary King 
*! Email:       me@zach.prof
*! Description: vctest support program that runs the boxcox regression command

program define vctest_boxcox

	syntax varlist [if] [in], model(string) [quietly]
	
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
	
	* Save # of obs. if model a specified, else verify # of obs. same as model a
	
	if "`model'" == "a" global vctest_n = e(N)
	else if e(N) != $vctest_n {
		di as error "Number of nonmissing values differs across models"
		exit 416
	}
	
	* Save theta (the reshaping parameter for the dependent variable)
	
	global vctest_theta_`model' = e(b)[1,e(df_m)-1]
	
	* Save sample-wide sigma squared
	
	global vctest_sigma2_`model' = e(b)[1,e(df_m)]^2
	
	* Save number of estimated parameters
	
	global vctest_params_`model' = e(df_m)-1
	
	* Run OLS regression using transformed data
	
	tempname counter transformed_vars
	local `counter' = 1
	
	foreach var of varlist `varlist' {
		local `transformed_vars' = "``transformed_vars'' _var``counter''"
		if ``counter'' == 1 {
			capture quietly generate double _var``counter'' = ((`var'^e(b)[1,e(df_m)-1]) - 1) / e(b)[1,e(df_m)-1] `if' `in'
			if _rc != 0 {
				di as error "variable {bf:_var``counter''} needed for internal computations;"
				di as error "drop {bf:_var``counter''} from data before running {bf:vctest} again"
				exit 110
			}
			local `counter' = ``counter'' + 1
		}
		else {
			capture quietly generate double _var``counter'' = ((`var'^e(b)[1,e(df_m)-2]) - 1) / e(b)[1,e(df_m)-2] `if' `in'
			if _rc != 0 {
				di as error "variable {bf:_var``counter''} needed for internal computations;"
				di as error "drop {bf:_var``counter''} from data before running {bf:vctest} again"
				exit 110
			}
			local `counter' = ``counter'' + 1
		}
	}
	
	quietly regress ``transformed_vars'' `if' `in'
	
	* Save residuals
	
	tempvar resid
	quietly predict double `resid' `if' `in' , residuals
	quietly putmata vctest_residuals_`model'=`resid'
	
	* Drop transformed variables
	
	drop _var*
	
end