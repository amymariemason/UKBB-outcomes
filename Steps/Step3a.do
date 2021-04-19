* Create matching to death certificate data

use `inputfile', clear
capture rename n_eid eid
keep eid ts_4000* s_4000*

* check variables present
local deathvar ts_40000 s_40001 s_40002 
foreach srnum of local deathvar{
	capture confirm variable `srnum'_0_0
	if _rc!=0 {
		noi di as error "ERROR: variable `srnum' missing"
		error 498
	}
}
macro drop _deathvar

* remove second copy of death date as it adds no data
assert ts_40000_1_0==ts_40000_0_0| ts_40000_1_0==.
drop ts_40000_1_0

****** death report 40001
foreach out of local output{
	gen Deathmatch_`out'=0
	foreach hes of local `out'_Death4000140002{
		foreach i of varlist s_40001*{
			replace Deathmatch_`out'=1 if regexm(`i',"`hes'")
		}
		foreach i of varlist s_40002*{
			replace Deathmatch_`out'=1 if regexm(`i',"`hes'")
		}
		
	}
	* If time to event data is wanted for this variable:
	if ``out'_Pre'==1{
		gen firstdiag_death_`out' =.
		replace firstdiag_death_`out' = ts_40000_0_0 if  Deathmatch_`out'==1
		format firstdiag_death_`out' %td
	}
	* Note: Death is always incident as otherwise could not be recruited. No need to split post/pre
}

* drop to wanted variables

if (`Pre_wanted'==1){
	keep eid Deathmatch_*  firstdiag_death_*
}
if (`Pre_wanted'==0){
	keep eid Deathmatch_* 
}



* save as a temp file for later merge
*tempfile temp_HES9
local temp_death_matched `TEMPSPACE'/Temp_death_match.dta
save `temp_death_matched', replace

