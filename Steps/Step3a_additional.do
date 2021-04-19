* NB: this addition file manages the additional death data that came in after the last major extract. 
* If your death fields in the main input file are up to date, this is not needed.  
import delimited `DEATH_add_date', clear

* reshape to wide: 1 record per eid
keep eid ins date
reshape wide date, i(eid) j(ins)

* check second records of dates don't introduce multiple options for death date
assert date_of_death0 ==date_of_death1 if date_of_death1!=""

* turn into date format
gen ts_40000_2_0 = date(date_of_death0, "DMY")
format ts* %td
drop date*
*   
* save in temp file
tempfile deathtemp
save `deathtemp', replace

** load second dataset
import delimited `DEATH_add_cause', clear

* reshape to wide
keep eid level cause
rename cause cause
sort eid level cause
bysort eid level: gen count=_n
reshape wide cause, i(eid level) j(count)
rename cause* cause*_
sort eid level
reshape wide cause*, i(eid) j(level)
rename cause*_1 s_40001_2_*
rename cause*_2 s_40002_2_*


* merge with data dataset
merge 1:1 eid using `deathtemp', update
drop _merge

save `deathtemp', replace


* Create matching to death certificate data

use `inputfile', clear
capture rename n_eid eid
keep eid ts_40000* s_40001* s_40002*
merge 1:1 eid using `deathtemp', update
assert inlist(_merge,1,3)
drop _merge

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
assert abs(ts_40000_2_0 - ts_40000_0_0 <10) | ts_40000_0_0==. |ts_40000_2_0==.
noi display "disagreement in date of death in additional death data: All within 10 days"
noi list eid ts* if ts_40000_2_0 - ts_40000_0_0!=0  &  ts_40000_2_0 - ts_40000_0_0!=. 
replace ts_40000_2_0  =ts_40000_0_0  if ts_40000_2_0==.
drop ts_40000_1_0 ts_40000_0_0

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
		replace firstdiag_death_`out' = ts_40000 if  Deathmatch_`out'==1
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
tempfile  temp_death_matched 
save `temp_death_matched', replace

