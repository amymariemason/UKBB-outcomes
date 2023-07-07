* This file switches out 3a and 3a+, for if your data has entirely seperate death fields
* If your death fields in the main input file are up to date, this is not needed - use 3a
import delimited `DEATH_add_date', clear

* reshape to wide: 1 record per eid
keep eid ins date
reshape wide date, i(eid) j(ins)

* check second records of dates don't introduce multiple options for death date
assert date_of_death0 ==date_of_death1 if date_of_death1!=""

* turn into date format
gen ts_40000_2_1 = date(date_of_death0, "DMY")
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


* check variables present
local deathvar ts_40000 s_40001 s_40002 
foreach srnum of local deathvar{
	capture confirm variable `srnum'_2_1
	if _rc!=0 {
		noi di as error "ERROR: variable `srnum' missing"
		error 498
		
	}
}
macro drop _deathvar

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
	keep eid ts_4000* Deathmatch_*  firstdiag_death_*
}
if (`Pre_wanted'==0){
	keep eid ts_4000* Deathmatch_* 
}



* save as a temp file for later merge
tempfile  temp_death_matched 
save `temp_death_matched', replace

