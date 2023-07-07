* Create Primary Care report
* find the primary care cut down data
use `temp_Prim', clear

* add baseline date
merge m:1 eid using `temp_date', assert(match using) keep(match)

* create variable for keeping track of whether person meets diagnosis criteria
gen keep =0

* destring date variable
gen date = date(event_dt, "DMY")
format date %td

* loop over required outcomes 
foreach out of local output{
	* open fresh copy of primary care data
	* This identifies individuals with any report, ignores time			
	replace keep=0
	foreach icd of local `out'_ReadV2{				
		replace keep =1 if regexm(read_2,"`icd'")			
	}
	foreach icd of local `out'_ReadV3{				
		replace keep =1 if regexm(read_3,"`icd'")			
	}	
	
	gsort eid -keep date
	gen PCmatch_`out' = 0
	by eid: replace PCmatch_`out' = keep[1]
	* sort pre and post (as time variable always needed for PC variables.
	gen type_`out'=.
	replace type_`out'= 1 if PCmatch_`out'==1 & date< baseline
	replace type_`out'= 3 if PCmatch_`out'==1 & date>= baseline
	replace type_`out'= 2 if PCmatch_`out'==0
	capture label define typevalues 1 "Pre" 3 "Post" 2 "No event"
	label values type_`out' typevalues
	* create an any event first date (pre and post)
	gsort eid type_`out' date
	gen firstdiag_PC_`out' =.
	by eid: replace firstdiag_PC_`out' = date[1] if PCmatch_`out'==1
	format firstdiag_PC_`out' %td
	* create first date post baseline
	gen post_`out'= (type_`out'==3)
	gsort eid -post_`out' date
	gen firstinc_PC_`out' =.
	by eid: replace firstinc_PC_`out' = date[1] if PCmatch_`out'==1 & type_`out'[1]==3
	format firstinc_PC_`out' %td	
}

keep eid first* PC*
bysort eid: keep if _n==1

*tempfile temp_PC_match
tempfile temp_PC_matched
save `temp_PC_matched', replace

