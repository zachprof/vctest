*! Title:       vctest_print.ado   
*! Author:      Zachary King 
*! Email:       me@zach.prof
*! Description: vctest support programs for printing test outputs to Stata

program define vctest_print

	syntax , r2round(numlist max=1) llround(numlist max=1)    ///
	         zround(numlist max=1)  pround(numlist max=1)     ///
			 successpct(numlist max=1) [NOR2 SUCCESSB]
	
	* Define Clarke test successes depending on if option successb specified
	if "`successb'" != "" global vctest_csuccesses = $vctest_csuccesses_b
	else global vctest_csuccesses = $vctest_csuccesses_a
	
	* Define successes as % if option successpct specified
	if `successpct' > -1 global vctest_csuccesses = ( $vctest_csuccesses / $vctest_n ) * 100
	
	* Declare temporary local macros used throughout
	tempname colnum diff
	
/*
    5   10   15   20   25   30   35   40   45   50
++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|++
Vuong and Clarke tests for nonested model selection:

 Number of obs  =  123456789.........20
 Model a:
 Model b:
*/

	* Skip line
	di
	
	* Title
	di "Vuong and Clarke tests for nonnested model selection:"
	
	* Skip line
	di
	
	* Number of observations
	di as text in smcl _continue " Number of obs  ="
	format_stat_vctest, unformattedval( $vctest_n ) roundto(0) maxlength(20)
	di as result in smcl _col(20) "$vctest_formattedstat"
	
	* Model a
	di as text in smcl " Model a: {stata $vctest_model_a}"
	
	* Model b
	di as text in smcl " Model b: {stata $vctest_model_b}"
	
/* Output for regress
    5   10   15   20   25   30   35   40   45   50   55   60   65   70   
++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|+++
                                                     Log-likelihood after
 Model |        R2     Adj R2        Log-likelihood    Schwarz adjustment
-------+-----------------------------------------------------------------
     a | 123456789  123456789  123456789.........20  123456789.........20
     b | 123456789  123456789  123456789.........20  123456789.........20
-------+-----------------------------------------------------------------
  diff | 123456789  123456789  123456789.........20  123456789.........20
*/

/* Output for boxcox
    5   10   15   20   25   30   35   40   45   50  
++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|+
                               Log-likelihood after
 Model |       Log-likelihood    Schwarz adjustment
-------+-------------------------------------------
     a | 123456789.........20  123456789.........20
     b | 123456789.........20  123456789.........20
-------+-------------------------------------------
  diff | 123456789.........20  123456789.........20
*/

	* Skip line
	di
	
	* Header
	if "`nor2'" == "" {
		di as text in smcl _col(54) "Log-likelihood after"
		di as text in smcl " Model {c |}" _col(17) "R2" _col(24) "Adj R2" _col(38) "Log-likelihood" _col(56) "Schwarz adjustment"
	}
	else {
		di as text in smcl _col(32) "Log-likelihood after"
		di as text in smcl " Model {c |}" _col(16) "Log-likelihood" _col(34) "Schwarz adjustment"
	}
	
	* Divider
	if "`nor2'" == "" di as text in smcl "{hline 7}{c +}{hline 65}"
	else di as text in smcl "{hline 7}{c +}{hline 43}"
	
	* Explanatory power estimates for model a
	di as text in smcl _continue _col(6) "a {c |}"
	
	if "`nor2'" == "" {
		
		format_stat_vctest, unformattedval( $vctest_r2_a ) roundto(`r2round') maxlength(9)
		local colnum = 18 - $vctest_col_adj
		di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
		format_stat_vctest, unformattedval( $vctest_adjr2_a ) roundto(`r2round') maxlength(9)
		local colnum = 29 - $vctest_col_adj
		di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
		
	}
	
	format_stat_vctest, unformattedval( $vctest_lnL_a ) roundto(`llround') maxlength(20)
	if "`nor2'" == "" local colnum = 51 - $vctest_col_adj
	else local colnum = 29 - $vctest_col_adj
	di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
	format_stat_vctest, unformattedval( $vctest_lnLadj_a ) roundto(`llround') maxlength(20)
	if "`nor2'" == "" local colnum = 73 - $vctest_col_adj
	else local colnum = 51 - $vctest_col_adj
	di as result in smcl _col(`colnum') "$vctest_formattedstat"
	
	* Explanatory power estimates for model b
	di as text in smcl _continue _col(6) "b {c |}"
	
	if "`nor2'" == "" {
	
		format_stat_vctest, unformattedval( $vctest_r2_b ) roundto(`r2round') maxlength(9)
		local colnum = 18 - $vctest_col_adj
		di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
		format_stat_vctest, unformattedval( $vctest_adjr2_b ) roundto(`r2round') maxlength(9)
		local colnum = 29 - $vctest_col_adj
		di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
		
	}
	
	format_stat_vctest, unformattedval( $vctest_lnL_b ) roundto(`llround') maxlength(20)
	if "`nor2'" == "" local colnum = 51 - $vctest_col_adj
	else local colnum = 29 - $vctest_col_adj
	di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
	format_stat_vctest, unformattedval( $vctest_lnLadj_b ) roundto(`llround') maxlength(20)
	if "`nor2'" == "" local colnum = 73 - $vctest_col_adj
	else local colnum = 51 - $vctest_col_adj
	di as result in smcl _col(`colnum') "$vctest_formattedstat"
	
	* Divider
	if "`nor2'" == "" di as text in smcl "{hline 7}{c +}{hline 65}"
	else di as text in smcl "{hline 7}{c +}{hline 43}"
	
	* Differences in explanatory power estimates (model a - model b)
	di as text in smcl _continue "  diff {c |}"
	
	if "`nor2'" == "" {
	
		local `diff' = $vctest_r2_a - $vctest_r2_b
		format_stat_vctest, unformattedval( ``diff'' ) roundto(`r2round') maxlength(9)
		local colnum = 18 - $vctest_col_adj
		di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
		local `diff' = $vctest_adjr2_a - $vctest_adjr2_b
		format_stat_vctest, unformattedval( ``diff'' ) roundto(`r2round') maxlength(9)
		local colnum = 29 - $vctest_col_adj
		di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
		
	}
	
	format_stat_vctest, unformattedval( $vctest_LR ) roundto(`llround') maxlength(20)
	if "`nor2'" == "" local colnum = 51 - $vctest_col_adj
	else local colnum = 29 - $vctest_col_adj
	di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
	format_stat_vctest, unformattedval( $vctest_LRadj ) roundto(`llround') maxlength(20)
	if "`nor2'" == "" local colnum = 73 - $vctest_col_adj
	else local colnum = 51 - $vctest_col_adj
	di as result in smcl _col(`colnum') "$vctest_formattedstat"
	
/*
    5   10   15   20   25   30   35   40   45   50   55   60   65   70   
++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|++++|+++
-------------------------------------------------------------------------
             Vuong test                          Clarke test              
 ----------------------------------   ----------------------------------
 z-statistic              123456789   successes                123456789
 p-value (Ha: diff != 0)  123456789   p-value (Ha: diff != 0)  123456789
 p-value (Ha: diff > 0)   123456789   p-value (Ha: diff > 0)   123456789
 p-value (Ha: diff < 0)   123456789   p-value (Ha: diff < 0)   123456789
-------------------------------------------------------------------------
Vuong and Clarke tests above compare differences in log-likelihoods after
Schwarz adjustment; this adjustment does not affect test outcomes if # of
independent variables is same in both models; Clarke test successes equal
the number of observations for which model a/b outperformed model b/a
*/

	* Skip line
	di
	
	* Header
	di as text in smcl "{hline 73}"
	di as text in smcl _col(14) "Vuong test" _col(50) "Clarke test"
	di as text in smcl _col(2) "{hline 34}" _col(39) "{hline 34}"
	
	* z-statistic and successes
	di as text in smcl _continue " z-statistic"
	
	format_stat_vctest, unformattedval( $vctest_z ) roundto(`zround') maxlength(20)
	local colnum = 35 - $vctest_col_adj
	di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
	if `successpct' == -1 {
		if "`successb'" == "" di as text in smcl _continue _col(39) "successes (diff > 0)"
		else di as text in smcl _continue _col(39) "successes (diff < 0)"
		format_stat_vctest, unformattedval( $vctest_csuccesses ) roundto(0) maxlength(20)
	}
	
	else {
		if "`successb'" == "" di as text in smcl _continue _col(39) "successes (diff > 0) (%)"
		else di as text in smcl _continue _col(39) "successes (diff < 0) (%)"
		format_stat_vctest, unformattedval( $vctest_csuccesses ) roundto(`successpct') maxlength(20)
	}
	
	local colnum = 72 - $vctest_col_adj
	di as result in smcl _col(`colnum') "$vctest_formattedstat"
	
	* p-value (Ha: diff != 0)
	di as text in smcl _continue " p-value (Ha: diff != 0)"
	
	format_stat_vctest, unformattedval( $vctest_vptwo ) roundto(`pround') maxlength(9)
	local colnum = 35 - $vctest_col_adj
	di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
	di as text in smcl _continue _col(39) "p-value (Ha: diff != 0)"
	
	format_stat_vctest, unformattedval( $vctest_cptwo ) roundto(`pround') maxlength(9)
	local colnum = 72 - $vctest_col_adj
	di as result in smcl _col(`colnum') "$vctest_formattedstat"
	
	* p-value (Ha: diff > 0)
	di as text in smcl _continue " p-value (Ha: diff > 0)"
	
	format_stat_vctest, unformattedval( $vctest_vponea ) roundto(`pround') maxlength(9)
	local colnum = 35 - $vctest_col_adj
	di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
	di as text in smcl _continue _col(39) "p-value (Ha: diff > 0)"
	
	format_stat_vctest, unformattedval( $vctest_cponea ) roundto(`pround') maxlength(9)
	local colnum = 72 - $vctest_col_adj
	di as result in smcl _col(`colnum') "$vctest_formattedstat"
	
	* p-value (Ha: diff < 0)
	di as text in smcl _continue " p-value (Ha: diff < 0)"
	
	format_stat_vctest, unformattedval( $vctest_vponeb ) roundto(`pround') maxlength(9)
	local colnum = 35 - $vctest_col_adj
	di as result in smcl _continue _col(`colnum') "$vctest_formattedstat"
	
	di as text in smcl _continue _col(39) "p-value (Ha: diff < 0)"
	
	format_stat_vctest, unformattedval( $vctest_cponeb ) roundto(`pround') maxlength(9)
	local colnum = 72 - $vctest_col_adj
	di as result in smcl _col(`colnum') "$vctest_formattedstat"
	
	* Horizontal line
	di as text in smcl "{hline 73}"
	
	* Note
	di "Vuong and Clarke tests above compare differences in log-likelihoods after"
	di "Schwarz adjustment; this adjustment does not affect test outcomes if # of"
	if "`successb'" == "" {
		di "independent variables is same in both models; Clarke test successes equal"
		if `successpct' == -1 di "the number of observations for which model a outperformed model b"
		else di "the percent of observations for which model a outperformed model b"
	}
	else {
		di "independent variables is same in both models; Clarke test successes equal"
		if `successpct' == -1 di "the number of observations for which model b outperformed model a"
		else di "the percent of observations for which model b outperformed model a"
	}
		
end

program define format_stat_vctest

	syntax , unformattedval(numlist max=1 missingokay) roundto(numlist max=1) maxlength(numlist max=1)
	
	if missing(`unformattedval') {
		global vctest_formattedstat = "."
		global vctest_col_adj = 2
		exit
	}
	
	tempname int_length
	local `int_length' = length(strofreal(int(abs(`unformattedval'))))
	
	tempname total_length
	local `total_length' = `roundto' + ``int_length'' + ceil(``int_length''/3)
	
	if `unformattedval' < 0 local `total_length' = ``total_length'' + 1
	
	if ``total_length'' > `maxlength' {
		global vctest_formattedstat : di %-`maxlength'.4e `unformattedval'
		global vctest_col_adj = strlen(strtrim("$vctest_formattedstat")) - 1
	}
	
	else {
		global vctest_formattedstat : di %-``total_length''.`roundto'fc `unformattedval'
		global vctest_col_adj = ``total_length'' - 1
	}
	
	if `roundto'==0 global vctest_col_adj = $vctest_col_adj - 1

end