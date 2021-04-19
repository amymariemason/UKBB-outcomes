* Step 2b: Match proceedure data

use `temp_oper', clear

merge m:1 eid using `temp_date', assert(match using) keep(match)

* reformat opdate
gen op_date = date(opdate, "DMY")
format op_date %td

foreach out of local output{
	gen procmatch_`out' =0
	*match to ICD 9 values
	foreach proc of local `out'_ProceduresOPCS4{				
		replace procmatch_`out' =1 if regexm(oper4,"`proc'")			
	}
	foreach proc of local all_ProceduresOPCS3{				
		replace procmatch_`out' =1 if regexm(string(oper3),"`proc'")		
	}	
	* sort so first instance is on top for each participant
	gsort eid -procmatch_`out' op_date
	gen proc_`out' = 0
	by eid: replace proc_`out' = procmatch_`out'[1]
		* If time to event data is wanted for this variable:
	if ``out'_Pre'==1{
		* sort pre and post
		gen type_`out'=.
		replace type_`out'= 1 if procmatch_`out'==1 & op_date< baseline
		replace type_`out'= 3 if procmatch_`out'==1 & op_date>= baseline
		replace type_`out'= 2 if procmatch_`out'==0
		capture label define typevalues 1 "Pre" 3 "Post" 2 "No event"
		label values type_`out' typevalues
		* create an any event first date (pre and post)
		gsort eid type_`out' op_date
		gen firstdiag_proc_`out' =.
		by eid: replace firstdiag_proc_`out' = op_date[1] if procmatch_`out'[1]==1
		format firstdiag_proc_`out' %td
		* create first date post baseline (post only)
		gen post_`out'= (type_`out'==3)
		gsort eid -post_`out' op_date
		gen firstinc_proc_`out' =.
		by eid: replace firstinc_proc_`out' = op_date[1] if procmatch_`out'[1]==1 & type_`out'[1]==3
		format firstinc_proc_`out' %td
	}
}

* drop to one record per person
sort eid
by eid: drop if _n>1

* drop to wanted variables

if (`Pre_wanted'==1){
	keep eid proc_* first*
}
if (`Pre_wanted'==0){
	keep eid proc_*
}

* save as a temp file for later merge
save `temp_proc_matched', replace

******

