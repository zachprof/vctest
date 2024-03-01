*! Title:       vctest.ado   
*! Version:     1.1 published February 25, 2024
*! Author:      Zachary King 
*! Email:       me@zach.prof
*! Description: Vuong and Clarke tests for nonnested model selection

program define vctest

	* Ensure Stata runs vctest using version 18 syntax
	
	version 18
	
	* Define syntax
	
	syntax anything [if] [in] [, SHOWreg NOCONStant SUCCESSB ///
	SUCCESSPCT(numlist max=1 >=0 <=6)                       /// 
	Roundto(numlist max=1 >=0 <=6)                         ///  
	RSQRound(numlist max=1 >=0 <=6)                          ///  
	LLRound(numlist max=1 >=0 <=6)   					    /// 
	ZRound(numlist max=1 >=0 <=6)                          ///  
	PRound(numlist max=1 >=0 <=6)]
	
	* Delete colon if specified at beginning of `anything'
	
	if substr("`anything'",1,1) == ":" local anything = subinstr("`anything'",":","",1) 
	
	* Parse `anything' for regression command
	
	tempname reg_cmd
	local `reg_cmd' = word("`anything'",1)
	
	* Parse `anything' for dependent variable
	
	tempname depvar
	local `depvar' = word("`anything'",2)
	
	* Parse `anything' for right-hand side variables in model a
	
	if ~regexm("`anything'","\([ a-zA-Z1-9_*~?-]*\)") {
		di as error "{bf:indepvars_a} or {bf:indepvars_b} not found"
		exit 111
	}
	
	tempname rhs_a
	local `rhs_a' = substr(regexs(0),2,strlen(regexs(0))-2)
	
	* Parse `anything' for right-hand side variables in model b
	
	if ~regexm("`anything'","\)[ ]*\([ a-zA-Z1-9_*~?-]*\)") {
		di as error "{bf:indepvars_a} or {bf:indepvars_b} not found"
		exit 111
	}
	
	tempname rhs_b
	local `rhs_b' = substr(regexs(0),strpos(regexs(0),"(")+1,strlen(regexs(0))-(strpos(regexs(0),"(")+1))
	
	* Redefine showreg to work with quietly command
	
	if "`showreg'" != "" local showreg = ""
	else local showreg = "quietly"
	
	* Set default rounding if not specified
	
	if "`roundto'" == "" local roundto = 2           // default rounding
	if "`llround'" == "" local llround = `roundto'   // log-likelihood functions
	if "`rsqround'" == "" local rsqround = `roundto' // R-squared	
	if "`zround'" == "" local zround = `roundto'     // z-statistic
	if "`pround'" == "" local pround = `roundto'     // p-values
	
	* Set option successpct to -1 if not specified
	
	if "`successpct'" == "" local successpct = -1
	
	* Add "model(theta) from(0.1 0.1, copy)" to opts if boxcox
	
	if "``reg_cmd''" == "boxcox" local opts = "model(theta) from(0.1 0.1, copy) `opts'"
	
	* Add "noconstant" to opts if noconstant specified
	
	if "`noconstant'" != "" local opts = "`opts' `noconstant'"
	
	* Save fully specified regression commands for both models
	
	if "`opts'" != "" | "`aopts'" != "" global vctest_model_a = "``reg_cmd'' ``depvar'' ``rhs_a'' `if' `in', `opts' `aopts'"
	else global vctest_model_a = "``reg_cmd'' ``depvar'' ``rhs_a'' `if' `in'"
	if "`opts'" != "" | "`bopts'" != "" global vctest_model_b = "``reg_cmd'' ``depvar'' ``rhs_b'' `if' `in', `opts' `bopts'"
	else global vctest_model_b = "``reg_cmd'' ``depvar'' ``rhs_b'' `if' `in'"
	
	* Determine if regression command is regress or an acceptable abbreviation
	
	if substr("``reg_cmd''",1,3) == "reg" &              ///
	   substr("regress",    1,strlen("``reg_cmd''")) ==  ///
	   substr("``reg_cmd''",1,strlen("``reg_cmd''")) {
	   	
		* If command is regress, calculate relevant statistics for both models
		
		vctest_regress `if' `in' , model(a) `showreg' // estimate model a and save relevant regression outputs
		ols_log_likelihood , model(a)                 // estimate log-likelihood function for model a
		vctest_regress `if' `in' , model(b) `showreg' // estimate model b and save relevant regression outputs
		ols_log_likelihood , model(b)                 // estimate log-likelihood function for model b
		
	}
	
	* Determine if regression command is boxcox
	
	else if "``reg_cmd''" == "boxcox" {
	   	
		* If command is boxcox, calculate relevant statistics for both models
		
		vctest_boxcox ``depvar'' ``rhs_a'' `if' `in' , model(a) `showreg' // estimate model a and save relevant regression outputs
		boxcox_log_likelihood ``depvar'', model(a)                        // estimate log-likelihood function for model a
		vctest_boxcox ``depvar'' ``rhs_b'' `if' `in' , model(b) `showreg' // estimate model b and save relevant regression outputs
		boxcox_log_likelihood ``depvar'', model(b)                        // estimate log-likelihood function for model b
		local nor2 = "nor2"
		
	}
	
	* If regression command not recognized above, exit and display error message
	
	else {
		di as error "{bf:``reg_cmd''} not a regression command supported by {bf:vctest};"
		exit 198
	}
	
	* Run Vuong and Clarke tests
		
	vuong_and_clarke_tests
	
	* Display estimates of explanatory power and results of Vuong and Clarke tests
	
	vctest_print, r2round(`rsqround') llround(`llround') zround(`zround') ///
	pround(`pround') successpct(`successpct') `nor2' `successb' 
	
	* Save all global macros to e()
	
	vctest_save, `nor2'
	
	* Drop global macros associated with vctest
	
	macro drop vctest_*
	
	* Drop mata matrices associated with vctest
	
	mata: mata drop vctest_*
	
end

program define ols_log_likelihood

	syntax , model(string)
	
	* Reinstate residual matrix as a temporary variable
	
	tempvar resid
	quietly getmata `resid'=vctest_residuals_`model'
	
	* Save observation-level log-likelihood suggested by Dechow (1994, eqs. A.3-A.4)
	
	tempvar lnL_oblev
	if "`model'" == "a" quietly generate double `lnL_oblev' = -0.5*ln( 2*_pi*$vctest_sigma2_a ) - (`resid'^2)/( 2*$vctest_sigma2_a )
	if "`model'" == "b" quietly generate double `lnL_oblev' = -0.5*ln( 2*_pi*$vctest_sigma2_b ) - (`resid'^2)/( 2*$vctest_sigma2_b )
	quietly putmata vctest_lnL_oblev_`model'=`lnL_oblev'
	
	* Save sample-wide log-likelihood
	
	quietly total `lnL_oblev'
	global vctest_lnL_`model' = e(b)[1,1]
	
	* Save observation-level log-likelihood with Schwarz (1978) adjustment suggested by Clarke and Signorino (2010, p. 378)
	
	tempvar lnLadj_oblev
	if "`model'" == "a" qui: gen double `lnLadj_oblev' = `lnL_oblev' - ( $vctest_params_a / (2*$vctest_n ))*ln( $vctest_n )
	if "`model'" == "b" qui: gen double `lnLadj_oblev' = `lnL_oblev' - ( $vctest_params_b / (2*$vctest_n ))*ln( $vctest_n )
	quietly putmata vctest_lnLadj_oblev_`model'=`lnLadj_oblev'
	
	* Save sample-wide log-likelihood with Schwarz (1978) adjustment
	
	qui: total `lnLadj_oblev'
	global vctest_lnLadj_`model' = e(b)[1,1]

end

program define boxcox_log_likelihood

	syntax varname, model(string)
	
	* Reinstate residual matrix as a temporary variable
	
	tempvar resid 
	quietly getmata `resid'=vctest_residuals_`model'
	
	* Save observation-level log-likelihood suggested in King (2024, Eqs. D.3A and D.3B)
	
	tempvar lnL_oblev
	if "`model'" == "a" qui: gen double `lnL_oblev' = -0.5*ln( 2*_pi*$vctest_sigma2_a ) + ( $vctest_theta_a - 1)*ln(`varlist') - (`resid'^2)/( 2*$vctest_sigma2_a )
	if "`model'" == "b" qui: gen double `lnL_oblev' = -0.5*ln( 2*_pi*$vctest_sigma2_b ) + ( $vctest_theta_b - 1)*ln(`varlist') - (`resid'^2)/( 2*$vctest_sigma2_b )
	quietly putmata vctest_lnL_oblev_`model'=`lnL_oblev'
	
	* Save sample-wide log-likelihood
	
	qui: total `lnL_oblev'
	global vctest_lnL_`model' = e(b)[1,1]
	
	* Save observation-level log-likelihood with Schwarz (1978) adjustment suggested by Clarke and Signorino (2010, p. 378)
	
	tempvar lnLadj_oblev
	if "`model'" == "a" qui: gen double `lnLadj_oblev' = `lnL_oblev' - ( $vctest_params_a / (2*$vctest_n ))*ln( $vctest_n )
	if "`model'" == "b" qui: gen double `lnLadj_oblev' = `lnL_oblev' - ( $vctest_params_b / (2*$vctest_n ))*ln( $vctest_n )
	quietly putmata vctest_lnLadj_oblev_`model'=`lnLadj_oblev'
	
	* Save sample-wide log-likelihood with Schwarz (1978) adjustment
	
	qui: total `lnLadj_oblev'
	global vctest_lnLadj_`model' = e(b)[1,1]
	
end

program define vuong_and_clarke_tests

	* Calculate likelihood ratio suggested in Vuong (1989)
	
	global vctest_LR = $vctest_lnL_a - $vctest_lnL_b
	
	* Calculate likelihood ratio with Schwarz (1978) adjustment suggested in Vuong (1989, p. 318)
	
	global vctest_LRadj = $vctest_lnLadj_a - $vctest_lnLadj_b
	
	* Reinstate observation-level log-likelihood matrices as temporary variables
	
	tempvar lnL_oblev_a lnL_oblev_b
	quietly getmata `lnL_oblev_a'=vctest_lnL_oblev_a
	quietly getmata `lnL_oblev_b'=vctest_lnL_oblev_b
	
	* Calculate sum of squared observation-level log-likelihood ratios (used below in variance calculation)
	
	tempvar LR2_oblev
	quietly generate double double `LR2_oblev' = (`lnL_oblev_a' - `lnL_oblev_b')^2
	quietly total `LR2_oblev'
	
	* Calculate variance of likelihood ratio as defined in Vuong (1989, eq. 4.2)
	
	global vctest_w2 = e(b)[1,1]/$vctest_n - ($vctest_LR /$vctest_n )^2
	
	* Calculate z-stat. with Schwarz (1978) adjustment following Vuong (1989, pp. 318-319)
	* Simplifies to Dechow (1994, eq. A.7) if both models OLS with same # of rhs variables
	
	global vctest_z = ( 1 / sqrt( $vctest_n )) * ( $vctest_LRadj / sqrt( $vctest_w2 ) )
	
	* Calculate p-values for Vuong test
	
	global vctest_vptwo  = normal( -1*abs( $vctest_z ) )*2
	global vctest_vponea = normal( -1*     $vctest_z )
	global vctest_vponeb = normal(         $vctest_z )
	
	* Reinstate observation-level log-likelihood matrices with Schwarz (1978) adjustment as temporary variables for Clarke tests
	
	tempvar lnLadj_oblev_a lnLadj_oblev_b
	quietly getmata `lnLadj_oblev_a'=vctest_lnLadj_oblev_a
	quietly getmata `lnLadj_oblev_b'=vctest_lnLadj_oblev_b
	
	* Calculate number of Clarke successes with Schwarz (1978) adjustment following Clarke and Signorino (2010, p. 378)
	
	* Define successes in terms of whether model a is better than model b:
	tempvar csucces_oblev_a
	quietly generate double `csucces_oblev_a' = (`lnLadj_oblev_a'-`lnLadj_oblev_b')>0 & `lnLadj_oblev_a'!=. & `lnLadj_oblev_b'!=.
	quietly total `csucces_oblev_a' `if' `in'
	global vctest_csuccesses_a = e(b)[1,1]
	
	* Define successes in terms of whether model b is better than model a:
	tempvar csucces_oblev_b
	quietly generate double `csucces_oblev_b' = (`lnLadj_oblev_b'-`lnLadj_oblev_a')>0 & `lnLadj_oblev_a'!=. & `lnLadj_oblev_b'!=.
	quietly total `csucces_oblev_b' `if' `in'
	global vctest_csuccesses_b = e(b)[1,1]
	
	* Identify number of ties to allocate evenly across models for two-sided p-value:
	tempvar csucces_ties
	quietly generate double `csucces_ties' = `lnLadj_oblev_a'==`lnLadj_oblev_b' & `lnLadj_oblev_a'!=. & `lnLadj_oblev_b'!=.
	quietly total `csucces_ties' `if' `in'
	global vctest_cties = e(b)[1,1]
	
	* Calculate one-sided p-values:
	global vctest_cponea = binomialtail( $vctest_n , $vctest_csuccesses_a , 0.5) - (binomialp( $vctest_n , $vctest_csuccesses_a , 0.5) / 2)
	global vctest_cponeb = binomialtail( $vctest_n , $vctest_csuccesses_b , 0.5) - (binomialp( $vctest_n , $vctest_csuccesses_b , 0.5) / 2)
	
	* Calculate two-sided p-value (take minimum if ties exist and adjust for even v. odd sample size so max p-value = 1):
	global vctest_csuccesses_tt_u = max( $vctest_csuccesses_a + ceil( $vctest_cties / 2 ) , $vctest_csuccesses_b + floor( $vctest_cties / 2 ) )
	global vctest_csuccesses_tt_l = min( $vctest_csuccesses_a + ceil( $vctest_cties / 2 ) , $vctest_csuccesses_b + floor( $vctest_cties / 2 ) )
	if floor( $vctest_n / 2) == $vctest_n / 2 {
		global vctest_ttadj_u = (binomialp( $vctest_n , $vctest_csuccesses_tt_u , 0.5) / 2)
		global vctest_ttadj_l = (binomialp( $vctest_n , $vctest_csuccesses_tt_l , 0.5) / 2)
	}
	else {
		global vctest_ttadj_u = 0
		global vctest_ttadj_l = 0
	}
	global vctest_cptwo_u = (binomialtail( $vctest_n , $vctest_csuccesses_tt_u , 0.5) - $vctest_ttadj_u )*2
	global vctest_cptwo_l = (binomial( $vctest_n , $vctest_csuccesses_tt_l , 0.5) - $vctest_ttadj_l )*2
	global vctest_cptwo = min( $vctest_cptwo_u , $vctest_cptwo_l )

end