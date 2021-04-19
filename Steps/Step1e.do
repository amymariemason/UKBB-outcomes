**** create a cut down Primary Care subset
import delimited `PRIMARY', clear 


* check all needed variables present

foreach field of varlist read_2 read_3{
	capture confirm variable `field'
	if _rc!=0 {
		noi di as error "ERROR: variable `field' missing from Primary Care dataset"
		error 498
        }
	}
* remove dots from read 2/3

replace read_2 = subinstr(read_2, ".","",.)
replace read_3 = subinstr(read_3, ".","",.)

* create identification variable & match to ICD9/10 macros

gen keep=0
foreach icd of local all_ReadV2{				
	replace keep =1 if regexm(read_2,"`icd'")			
}
foreach icd of local all_ReadV3{				
	replace keep =1 if regexm(read_3,"`icd'")			
}

drop if keep!=1
drop keep

* merge to main file 
*tempfile temp_P
local temp_Prim `TEMPSPACE'/Temp_Primary.dta
save `temp_Prim', replace
