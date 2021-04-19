*********************** add dates to HES file if time to event wanted

 import delimited `HES', clear 


merge 1:m eid ins_index using `temp_HES', replace update
keep if inlist(_merge,2,3)
assert _merge==3

keep eid ins_index arr_index level diag_icd9 diag_icd10 epistart epiend admidate disdate
* pick first existing date from: start of episode, admission, end of episode, discharge
     foreach v of varlist epistart epiend admidate disdate{
                capture confirm numeric variable `v'
                if !_rc {
                       tostring `v', force replace
                }
}
gen diag_date = date(epistart, "DMY")
replace diag_date = date(admidate, "DMY") if diag_date==.
replace diag_date = date(epiend, "DMY") if diag_date==.
replace diag_date = date(disdate, "DMY") if diag_date==.


keep eid ins_index diag_date diag_icd9 diag_icd10 
format diag_date %td

capture assert diag_date!=.
	if _rc!=0 {
	noi di as error "Warning: diagnosis dates missing for following"
	noi list eid ins_index diag_date if diagdate==.
	}

keep eid diag_date diag_icd9 diag_icd10

*save file for later loading  *

save `temp_HES2', replace


