* Combine all reports into a single set

* open standard data and keep list of eids & survey dates
use `inputfile', clear
capture rename n_eid eid
keep eid ts_53_0_0 n_33_0_0 n_31_0_0 n_54_0_0

* add censor dates

* determine country of origin
rename n_54_0_0 centre
destring centre, replace
gen country = ""
replace country = "England" if inlist(centre, 11012, 11021, 11011,11008, 11024, 11018, 11010, 11016, 11001, 11017, 11009, 11013, 11002, 11007, 11014, 10003, 11006, 11025, 11026, 11027, 11020)
replace country = "Wales" if inlist(centre, 11003, 11022, 11023)
replace country = "Scotland" if inlist(centre, 11005, 11004)

* create censor dates
gen censordate = "`HES_END_ENG'" if country=="England"
replace censordate =  "`HES_END_WALES'" if country=="Wales"
replace censordate =  "`HES_END_SCOT'" if country=="Scotland"

if ("`CENSORTYPE'"=="CANCER"){
gen censordate = "`CANCER_ENG'"
replace censordate = "`CANCER_SCOT'" if country=="Scotland"
}

* merge in HES data
capture confirm file `temp_HES_matched'
if _rc==0 {
	merge 1:1 eid using `temp_HES_matched'
	capture assert inlist(_merge,1,3)
	if _rc!=0{
		noi di as error "Merge with HES data failed uniqueness"
		error 498
	}
	foreach out of local output{
		replace HES_`out' = 0 if _merge==1
	}
	drop _merge
}
if _rc!=0 {
		noi di "NOTE: HES matched data file not found"
		
} 

* merge in procedure data
capture confirm file `temp_proc_matched'
if _rc==0 {
	merge 1:1 eid using `temp_proc_matched'
	capture assert inlist(_merge,1,3)
	if _rc!=0{
		noi di as error "Merge with HES procedure data failed uniqueness"
		error 498
	}
	foreach out of local output{
		replace proc_`out' = 0 if _merge==1
	}
	drop _merge
}
if _rc!=0 {
		noi di "NOTE: proceedure matched data file not found"
		
} 
* merge in death data
capture confirm file `temp_death_matched'
if _rc==0 {
	merge 1:1 eid using `temp_death_matched'
	capture assert inlist(_merge,1,3)
	if _rc!=0{
		noi di as error "Merge with death data failed"
		error 498
	}
	foreach out of local output{
		replace Deathmatch_`out' = 0 if _merge==1
	}
	drop _merge
}
if _rc!=0 {
		noi di "NOTE: Death matched data file not found"
		
} 
* merge in self report data
capture confirm file `temp_SR_matched'
if _rc==0 {
	merge 1:1 eid using `temp_SR_matched'
	capture assert inlist(_merge,1,3)
	if _rc!=0{
		noi di as error "Merge with self report data failed"
		error 498
	}
	drop _merge
}
if _rc!=0 {
		noi di "NOTE: self report matched data file not found"
		
} 

* if required, merge in cancer data 


capture confirm file `temp_CR_matched'
if _rc==0 {
	merge 1:1 eid using `temp_CR_matched'
	capture assert inlist(_merge,1,3)
	if _rc!=0{
		noi di as error "Merge with cancer data failed"
		error 498
	}
	foreach out of local output{
		replace CRmatch_`out' = 0 if _merge==1
	}
	drop _merge
}
if _rc!=0 {
		noi di "NOTE: cancer matched data file not found"
		
} 
* remove withdrawals
capture confirm file `temp_withdrawn'
if _rc==0 {
merge 1:1 eid using `temp_withdrawn'
summ _merge if _merge==3
noi di r(N) " dropped as withdrawn from UK Biobank"
drop if _merge!=1
drop _merge
}
if _rc!=0 {
		noi di "NOTE: withdrawal matched data file not found"
		
} 

* Loop over outcomes 
**Determine who is a case (inc. excluding SR)
foreach out of local output{
	if ("`cancercheck'"=="1"){
		egen `out' = rowmax (HES_`out' proc_`out' Deathmatch_`out' SRmatch_`out')
		egen `out'_nSR = rowmax (HES_`out' proc_`out' Deathmatch_`out')

	}
	else{
		egen `out' = rowmax (HES_`out' proc_`out' Deathmatch_`out' SRmatch_`out' CRmatch_`out')
		egen `out'_nSR = rowmax (HES_`out' proc_`out' Deathmatch_`out' CRmatch_`out')	
	}
	label variable `out' ``out'_name'
	label variable `out'_nSR ``out'_name_nSR'
}
	
** if required to find earliest outcome
* give as years since baseline
foreach out of local output_Pre{
	* create time to event from baseline in years 	
	if ("`cancercheck'"!="1"){
		egen `out'_date = rowmin (firstdiag_HES_`out' firstdiag_proc_`out' firstdiag_death_`out' SRdate_`out' CRdate_`out')
	}
	else{
		egen `out'_date = rowmin (firstdiag_HES_`out' firstdiag_proc_`out' firstdiag_death_`out' SRdate_`out')
	}
	label variable `out'_date "date of first `out' event or censor"
	format `out'_date %td
	replace `out'_date = date(censordate,"DMY") if `out'==0
	replace `out'_date = ts_40000 if ts_40000 < `out'_date
	gen `out'_years = (`out'_date - ts_53_0_0)/365.25
	label variable `out'_years "years since baseline for `out' event or censor"
	
	* repeat excluding SR dates
	if ("`cancercheck'"!="1"){
		egen `out'_nSR_date = rowmin (firstdiag_HES_`out' firstdiag_proc_`out' firstdiag_death_`out' CRdate_`out')
	}
	else{
		egen `out'_nSR_date = rowmin (firstdiag_HES_`out' firstdiag_proc_`out' firstdiag_death_`out')
	}
	label variable `out'_nSR_date "date of first `out' event excluding self reported data"
	format `out'_nSR_date %td
	replace `out'_nSR_date = date(censordate,"DMY") if `out'_nSR==0
	replace `out'_nSR_date = ts_40000 if ts_40000 < `out'_nSR_date
	gen `out'_nSR_years = (`out'_nSR_date - ts_53_0_0)/365.25
	label variable `out'_nSR_years "years since baseline for `out' event or censor (excludes self report)"
	
	* repeat using only incident events
	if ("`cancercheck'"!="1"){
		egen `out'_inc_date = rowmin (firstinc_HES_`out' firstinc_proc_`out' firstdiag_death_`out' SR_inc_date_`out' CR_inc_date_`out')
	}
	else{
		egen `out'_inc_date = rowmin (firstinc_HES_`out' firstinc_proc_`out' firstdiag_death_`out' SR_inc_date_`out')
	}
	label variable `out'_inc_date "first `out' event post baseline"
	
	* Pre/Post variable 
	gen `out'_inc = 0
	replace `out'_inc=1 if `out'==1& `out'_inc_date!=.
	label variable `out'_inc "`out' event post baseline"
	gen `out'_pre = 0
	replace `out'_pre=1 if `out'==1 & `out'_date<=ts_53_0_0
	label variable `out'_pre "`out' event prior to baseline"
	
	* finish off incident event
	format `out'_inc_date %td
	replace `out'_inc_date = date(censordate,"DMY") if `out'_inc==0
	replace `out'_inc_date = ts_40000 if ts_40000 < `out'_inc_date
	gen `out'_inc_years = (`out'_inc_date - ts_53_0_0)/365.25
	label variable `out'_inc_years "years since baseline for incident `out' event only or censor"
	
	
	
	*relabel date variables
	label variable firstdiag_HES_`out'  "date of first `out' event in HES"
	rename firstdiag_HES_`out' `out'_HES_date
	
	label variable firstdiag_death_`out'  "date of first `out' event in Death Certificates"
	rename firstdiag_death_`out' `out'_death_date
	
	label variable firstdiag_proc_`out'  "date of first `out' event in procedures"
	rename firstdiag_proc_`out' `out'_proc_date
	
	label variable SRdate_`out'  "date of first `out' event in self reporting"
	rename SRdate_`out' `out'_SR_date
	
	label variable firstinc_HES_`out'  "date of first `out' event in HES post baseline"
	rename firstinc_HES_`out' `out'_HES_inc_date

	label variable firstinc_proc_`out'  "date of first `out' event in procedures post baseline"
	rename firstinc_proc_`out' `out'_proc_inc_date
	
	label variable SR_inc_date_`out'  "date of first `out' event in self reporting post baseline"
	rename SR_inc_date_`out' `out'_SR_inc_date
	
	if ("`cancercheck'"!="1"){
	
		label variable CRdate_`out'  "date of first `out' event in cancer registry "
		rename CRdate_`out' `out'_CR_date
	
		label variable CR_inc_date_`out'  "date of first `out' event in cancer registry post baseline"
		rename CR_inc_date_`out' `out'_CR_inc_date
		
	}

}

* add age at baseline in years

gen age_baseline = (ts_53_0_0 - n_33_0_0)/365.25
label variable age_baseline "age at baseline in years"
rename n_31_0_0 sex
rename ts_53_0_0 baseline
rename n_33_0_0 dateofbirth
rename ts_40000 dateofdeath

* If time to event wanted 
if (`Pre_wanted'==1){
	* save all earliest dates sets for time to event variables
	preserve
	if ("`cancercheck'"!="1"){
		keep eid `output_Pre' *_HES_date *_death_date *_proc_date *_SR_date *_SR_inc_date *_CR_date *_CR_inc_date *_HES_inc_date *_proc_inc_date baseline dateofbirth dateofdeath
		order eid `output_Pre' baseline dateofbirth dateofdeath *_date
	}
	else{
		keep eid `output_Pre' *_HES_date *_death_date *_proc_date *_SR_date *_SR_inc_date *_HES_inc_date *_proc_inc_date baseline dateofbirth dateofdeath
		order eid `output_Pre' baseline dateofbirth dateofdeath *_date
	}
	
	if ("`diabetescheck'"=="1"){
	merge 1:1 eid using `temp_diabetes', update
	drop if _merge==2
	drop _merge
	}

	save `outfiles'/`outfilename'_alldates, replace
	restore

		* save date set 
		* keep age at survey (years) & time to event since baseline

		keep eid `output' baseline dateofbirth dateofdeath age_baseline age sex *_nSR *_inc *_pre *_years *_inc_years *_nSR_years
		order eid `output' baseline dateofbirth  dateofdeath age_baseline age sex *_nSR *_inc *_pre  *_years 	
	
	
}


* Otherwise 
if (`Pre_wanted'==0){
	* keep age at survey (years) 

	keep eid `output' age sex *_nSR 
	order eid `output' age sex *_nSR 
	
	if ("`diabetescheck'"=="1"){
	merge 1:1 eid using `temp_diabetes', update
	drop if _merge==2
	drop _merge
	}
}



* Final save as stata set and csv
* stata
save `outfiles'/`outfilename', replace
* csv
export delimited `outfiles'/`outfilename', replace
