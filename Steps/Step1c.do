*Step1c: create a temp cut down HES sets containing only matches to the superset

* load HES diagnosis set

import delimited `HES_diag', clear 

* check all needed variables present

foreach field of varlist diag_icd9 diag_icd10{
	capture confirm variable `field'
	if _rc!=0 {
		noi di as error "ERROR: variable `field' missing from HES dataset"
		error 498
        }
	}
* create identification variable & match to ICD9/10 macros

gen keep=0
foreach icd of local all_ICD9codes{				
	replace keep =1 if regexm(diag_icd9,"`icd'")			
}
foreach icd of local all_ICD10codes{				
	replace keep =1 if regexm(diag_icd10,"`icd'")			
}

drop if keep!=1

* save as temp file

save `temp_HES', replace



*************************************************************************************

* repeat for procedures

import delimited `HES_oper', clear 

foreach field of varlist oper3 oper4 opdate{
	capture confirm variable `field'
	if _rc!=0 {
		noi di as error "ERROR: variable `field' missing from HES dataset"
		error 498
        }
	}

* insert dates for missing opdates, but matching indexes
gsort eid ins_index -opdate
by eid ins_index: replace opdate = opdate[_n-1] if _n>1 & opdate==""	

* remove events without dates
gen missingdate=1 if opdate==""
noi di "Note: missing dates for these operation codes; these records have been dropped"
noi tab oper4 if missing==1
noi tab oper3 if missing==1
drop if missing==1
drop missing

	
* cut down to matching records only
gen keep=0
foreach icd of local all_ProceduresOPCS3{				
	replace keep =1 if regexm(string(oper3),"`icd'")		
}
foreach icd of local all_ProceduresOPCS4{				
	replace keep =1 if regexm(oper4,"`icd'")		
}
drop if keep!=1

* drop all non-wanted field

keep eid ins_index oper3 oper4 opdate


save `temp_oper', replace

********* create baseline date set for merging

use `inputfile', clear
capture rename n_eid eid
rename n_53_0_0 baseline
keep eid baseline 
save `temp_date', replace

