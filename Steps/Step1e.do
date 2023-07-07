**** create a cut down Primary Care subset

* analyze size of Primary data file

chunky using `PRIMARY', analyze

local lines = r(lnum) 
*saves number of lines in files
local chunk_size = 1000000
local chunk_no = floor(`lines'/`chunk_size')

*open first set and save to temp, append if in other loops

forvalues i = 1(`chunk_size')`lines' {
 local j = `i'+`chunk_size' -1
 di `i'
 di `j'
import delimited `PRIMARY', rowrange(`i':`j') colrange(1:5) stringcols(4 5) clear
	
	
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
if `i' == 1 {
tempfile temp_Prim 
save `temp_Prim', replace
}
else {
append using `temp_Prim'
save `temp_Prim', replace
}

}
