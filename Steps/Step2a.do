******Step 2a: Match HES data to create binary variable
if (`Pre_wanted'==1){
	use `temp_HES2', clear
}
if (`Pre_wanted'==0){
	use `temp_HES', clear
}
merge m:1 eid using `temp_date', generate(_merge1)
merge m:1 eid using `temp_withdrawn', generate(_merge2)
assert _merge2==3 if _merge1==1
keep if _merge1==3
drop _merge*



foreach out of local output{
	gen HESmatch_`out' =0
	*match to ICD 9 values
	foreach icd of local `out'_ICD9codes{				
		replace HESmatch_`out' =1 if regexm(diag_icd9,"`icd'")			
	}
	foreach icd of local `out'_ICD10codes{				
		replace HESmatch_`out' =1 if regexm(diag_icd10,"`icd'")			
	}

	* sort so first instance is on top for each participant
	
	gsort eid -HESmatch_`out' 
	by eid: gen HES_`out' = HESmatch_`out'[1]
	
}	
	* If time to event data is wanted for this variable:
if `Pre_wanted'==1{
	foreach out of local output{	
		if ``out'_Pre'==1{
			* sort pre and post
			gen type_`out'=.
			replace type_`out'= 1 if HESmatch_`out'==1 & diag_date< baseline
			replace type_`out'= 3 if HESmatch_`out'==1 & diag_date>= baseline
			replace type_`out'= 2 if HESmatch_`out'==0
			capture label define typevalues 1 "Pre" 3 "Post" 2 "No event"
			label values type_`out' typevalues
			* create an any event first date (pre and post)
			gsort eid type_`out' diag_date
			gen firstdiag_HES_`out' =.
			by eid: replace firstdiag_HES_`out' = diag_date[1] if HES_`out'==1
			format firstdiag_HES_`out' %td
			* create first date post baseline
			gen post_`out'= (type_`out'==3)
			gsort eid -post_`out' diag_date
			gen firstinc_HES_`out' =.
			by eid: replace firstinc_HES_`out' = diag_date[1] if HES_`out'==1 & type_`out'[1]==3
			format firstinc_HES_`out' %td
		}
	}
}
* drop to one record per person
sort eid
by eid: drop if _n>1

if (`Pre_wanted'==1){
	keep eid HES_* first*
}
if (`Pre_wanted'==0){
	keep eid HES_* 
}



* save as a temp file for later merge
save `temp_HES_matched', replace


