*! Title:       vctest_save.ado   
*! Author:      Zachary King 
*! Email:       me@zach.prof
*! Description: vctest support program that saves results in e()

program define vctest_save, eclass

	syntax [, NOR2]

	ereturn clear

	ereturn scalar N = $vctest_n
	macro drop vctest_n
	
	if "`nor2'" == "" {
	
		ereturn scalar r2a = $vctest_r2_a
		macro drop vctest_r2_a
	
		ereturn scalar r2b = $vctest_r2_b
		macro drop vctest_r2_b
	
		ereturn scalar adjr2a = $vctest_adjr2_a
		macro drop vctest_adjr2_a
	
		ereturn scalar adjr2b = $vctest_adjr2_b
		macro drop vctest_adjr2_b
		
	}

	ereturn scalar lnLa = $vctest_lnL_a
	macro drop vctest_lnL_a
	
	ereturn scalar lnLb = $vctest_lnL_b
	macro drop vctest_lnL_b
	
	ereturn scalar lnLadja = $vctest_lnLadj_a
	macro drop vctest_lnLadj_a
	
	ereturn scalar lnLadjb = $vctest_lnLadj_b
	macro drop vctest_lnLadj_b
	
	ereturn scalar LR = $vctest_LR
	macro drop vctest_LR
	
	ereturn scalar LRadj = $vctest_LRadj
	macro drop vctest_LRadj
	
	ereturn scalar z = $vctest_z
	macro drop vctest_z
	
	ereturn scalar vp2 = $vctest_vptwo
	macro drop vctest_vptwo
	
	ereturn scalar vp1a = $vctest_vponea
	macro drop vctest_vponea
	
	ereturn scalar vp1b = $vctest_vponeb
	macro drop vctest_vponeb
	
	ereturn scalar successes = $vctest_csuccesses
	macro drop vctest_csuccesses
	
	ereturn scalar cp2 = $vctest_cptwo
	macro drop vctest_cptwo
	
	ereturn scalar cp1a = $vctest_cponea
	macro drop vctest_cponea
	
	ereturn scalar cp1b = $vctest_cponeb
	macro drop vctest_cponeb
	
end