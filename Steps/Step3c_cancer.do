* Create cancer registry variables
** NB careful with dates and multiple reports here!

*** THINK MORE ABOUT CENSOR DATES
*** need date for every type of information


use `inputfile', clear
gen baseline = n_53_0_0
format baseline %td
gen baseline_year = n_53_0_0/365.25 + 1960
gen baseline_age = (n_53_0_0-n_33_0_0)/365.25

* The additional variables for cancer are 40011 (hist of tumour),  40013 (icd9), 40006 (icd10)
* the additional time details are: *40005 (date of cancer diagnosis)  - this is for 40011, 40013 & 40006
* 															

* NOTE: National cancer registries centralise information received from separate regional cancer centres around the UK. 
* The completeness of follow-up can vary between cancer registries and this should be considered in analyses when determining dates of complete follow-up for censoring purposes.
* see: http://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=100092 for more details


* list all cancer report variables to check 

local cancerreports 40013 
local cancerreports10 40006 
local cancerhist 40011

capture confirm variable ts_40005_0_0
	if _rc!=0 {
		noi di  as error "ERROR: variable 40005 missing"
		error 498
		}
capture confirm variable s_40006_0_0
	if _rc!=0 {
		noi di  as error "ERROR: variable 40006 missing"
		error 498
		}
capture confirm variable n_40011_0_0
	if _rc!=0 {
		noi di  as error "ERROR: variable 40011 missing"
		error 498
		}
capture confirm variable s_40013_0_0
	if _rc!=0 {
		noi di  as error "ERROR: variable 40013 missing"
		error 498
		}


* this is better and faster done as a reshape, not a loop

keep n_eid baseline *40005* *40006* *40013*  *40011*
rename *_0 *
reshape long ts_40005_ s_40013_ s_40006_ n_40011_, i(n_eid) j(instance)

 * loop rounds each required output, checking the cancer variables
foreach out of local output{
* This identifies individuals with any report, ignores time			
	gen CR_`out'=0				
	* loop round all specific values for each cancer report and check for values
	*40006
	foreach sr of local `out'_ICD10codes{
		*if non empty values in the specification file, this finds the people who have that code
	
		replace CR_`out'=1 if regexm(s_40006,"`sr'")
	
	}
	
	*40013
	foreach sr of local `out'_ICD9codes{
		*if non empty values in the specification file, this finds the people who have that code
	
		replace CR_`out'=1 if regexm(s_40013,"`sr'")
	
	}
	*40011
	foreach sr of local `out'_CancerHistology{
		*if non empty values in the specification file, this finds the people who have that code
		replace CR_`out'=1 if regexm(string(n_40011),"`sr'")
	
	}		
	
* consolidate to a single value for each eid
	gsort n_eid -CR_`out' 	
	by n_eid: gen CRmatch_`out' = CR_`out'[1]
}




foreach out of local output{ 
if ``out'_Pre'==1{
gen date_`out'=.
format date_`out' %td
gen inc_date_`out'=.
format inc_date_`out' %td

	* check dates for cancer diagnosis file

	replace date_`out'=ts_40005 if CR_`out'==1 & ts_40005!=. 
	replace inc_date_`out'=ts_40005 if CR_`out'==1 & ts_40005!=. & ts_40005> baseline

	* sort to find earliest diagnosis dates
	
	gsort n_eid -CR_`out' date_`out'
	by n_eid: gen CRdate_`out' = date_`out'[1] if CR_`out'[1]==1
	format CRdate_`out' %td
	
	gsort n_eid -CR_`out' inc_date_`out'
	by n_eid: gen CR_inc_date_`out' = inc_date_`out'[1] if CR_`out'[1]==1
	format CR_inc_date_`out' %td
	
	* drop temp variables
	 drop date_`out'
	 drop inc_date_`out'
	}

}


capture rename n_eid eid

* drop to wanted variables

if (`Pre_wanted'==1){
	keep eid CRmatch* CRdate* CR_inc_date*
}
if (`Pre_wanted'==0){
	keep eid CRmatch*
}

duplicates drop

* save as a temp file for later merge
tempfile temp_CR_matched 
save `temp_CR_matched', replace

