********************************************
* Add diabetes outcomes to UKBB
* Author: Amy Mason
* Date: April 2019
* Input: 
** inputfile: stata dta file with input fields: must contain n_eid variable and fields: 
**     must contain 31, 21000, 4041, 2976, 6177, 6153, 2986, 20002, 20003, 20009
** HES: Biobank HES outcomes dataset with n_eid linked to inputfile. must contain n_eid, diag_icd9, diag_icd10, oper4
** output: replace this text with the suggested variable name of the variable you want to add
** death
*
* Output:
*  list of n_eids with outcomes requested, as stata and csv file
* 
* *********************************************
* NOTE: this is a wrapper to implement the algorithm here: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0162388
* and compare it to outcomes from HES
* The files Step1, Step2, Step3, Step4 were written Sophie Eastwood and detect prevalence of diabetes
* This adaption to those files was written by Amy Mason, and updates with later available HES data to detect incidence
* classifies all diabetes cases without considerations of whether prevalent or incident
* **********************************************************

* CONFIG HEADER if not called within main outcomes file
* USERS EDIT HERE
if missing("`out_diabetes'"){



macro drop _all

* file name for output of participant outcomes 
local diabetesout ukb_diabetes_Oct_2019
 
* location for output
local outfiles /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/outcome_requests

* stata dta file extracted from UKBioBank
local inputfile /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/allfields.dta

* locations of the HES outcomes 
local HES_diag `""/rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/hesin_diag_20191011.txt""'

* withdrawal location
local WITHDRAWN `""/rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/withdrawals_20200204.csv""'

* location of step do files 
local LOCATION /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/Steps

* location of temporary staging files (these can be deleted once run is complete)
local TEMPSPACE /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Temp

* date of extraction of data from biobank (used as censoring endpoint for controls)
* see: http://biobank.ndph.ox.ac.uk/showcase/exinfo.cgi?src=Data_providers_and_dates* NB: I am ignoring the different enddate for primary care for England vision, as they are censored from the final dataset anyway. Endpoints are applied based on country of recruitment.  
* enddates are censored to HES (if hes data only used), Prim (if primary data used), Cancer (if running cancer specific algorithm)
local HES_END_ENG "30Jun2020"
local HES_END_SCOT "31Oct2016"
local HES_END_WALES "29Feb2016"
local PRIM_END_SCOT "31Mar2017"
local PRIM_END_WALES "31Aug2017"
local PRIM_END_ENG "31May2016"
local CANCER_ENG "31March2016"
local CANCER_SCOT "31Oct2015"

* what censoring to apply to controls; options = "HES", "PRIMARY", "CANCER"
local CENSORTYPE "HES"

* Do you want to run the original Eastwood et al algorithm only? 0 is no, 1 is yes
local original_diabetes 0

* clear data & log
clear
set more off
cap log close

local time_string = "$S_DATE"+"_" +"$S_TIME"
local time_string = subinstr("`time_string'", ":", "_", .)
local time_string = subinstr("`time_string'", " ", "_", .)
local logname ="`outfiles'"+"/"+"`outfilename'"+"`time_string'"+"diabetes.log"
log using "`logname'", replace
noi di "Run on $S_DATE $S_TIME"
}
** CONFIG HEADER IF CALLED WITHIN MAIN FILE
else{
	if ("`out_diabetes'"=="1"){
		* file name for output of participant outcomes 
		tempfile temp_diabetes
	}
	else{
		di "ERROR: Diabetes algorithm run with out_diabetes marker present but not equal to 1"
	}
}


**************
* Algorithm should run without further edits 




****** Run original STEP 1 & save 
* 
* stata dta file extracted from UKBioBank
use `inputfile', clear
* 

qui do `LOCATION'/Diabetes/Step1.do
qui do `LOCATION'/Diabetes/Step2.do
qui do `LOCATION'/Diabetes/Step3.do
qui do `LOCATION'/Diabetes/Step4.do
qui do `LOCATION'/Diabetes/Step5.do

gen summary = 1* sr_unlikely_diabetes + 2* sr_poss_gest_diabetes + 3* sr_poss_t2_diabetes + 4* sr_prob_t2_diabetes + 5* sr_poss_t1_diabetes +6* sr_prob_t1_diabetes
lab def summary_def 0 "uncertain diabetes status" 1 "diabetes unlikely" 2 "possible gestestional diabetes" 3 "possible Type 2 diabetes" 4"probable Type 2 diabetes" 5"possible type1 diabetes" 6 "probably type 1 diabetes"
lab val summary summary_def

keep n_eid summary
tempfile diabetesout_org
save `diabetesout_org', replace
if ("`original_diabetes'"=="1"){
save `outfiles'/`diabetesout'_org.dta, replace
log close
}
else{

******* Adapted Step 1 to contain later surveys

* stata dta file extracted from UKBioBank
use `inputfile', clear
* 
do `LOCATION'/Diabetes/Step1_Diabetes_all.do
do `LOCATION'/Diabetes/Step2.do
do `LOCATION'/Diabetes/Step3.do
do `LOCATION'/Diabetes/Step4.do
do `LOCATION'/Diabetes/Step5.do

gen summary_all = 1* sr_unlikely_diabetes + 2* sr_poss_gest_diabetes + 3* sr_poss_t2_diabetes + 4* sr_prob_t2_diabetes + 5* sr_poss_t1_diabetes +6* sr_prob_t1_diabetes
lab def summary_def 0 "uncertain diabetes status" 1 "diabetes unlikely" 2 "possible gestestional diabetes" 3 "possible Type 2 diabetes" 4"probable Type 2 diabetes" 5"possible type1 diabetes" 6 "probably type 1 diabetes"
lab val summary_all summary_def

merge 1:1 n_eid using `diabetesout_org', update
assert _merge==3
drop _merge
noi di " comparision of original survey assignment vs. all survey assignment"
noi tab summary_all summary

keep n_eid summary_all summary

tempfile temp_dia2
save `temp_dia2', replace

********add HES and death info

include `LOCATION'/Diabetes/StepHES.do

merge 1:1 n_eid using `temp_dia2', update
assert inlist(_merge,1,2,3)
drop if _merge==1
drop _merge
noi di " comparision of original survey assignment vs. HES&Death assignment"
noi tab summary_all summary_HESDeath

keep n_eid summary*

lab var summary "intake self-reporting"
lab var summary_all "all self-reporting"
lab var summary_HES "all HES and Death reports"

gen Type2_con = (summary_all==4)
gen Type2_lib = (summary_all==4)|(summary_all==3)| (summary_HESDeath==4)

gen Type1_con= (summary_all==6)
gen Type1_lib = (summary_all==6)|(summary_all==5)| (summary_HESDeath==6)

lab var Type2_con "conservative Type 2 Diabetes marker (sr only)"
lab var Type2_lib "liberal Type 2 Diabetes marker (sr&HES&Death)"

lab var Type1_con "conservative Type 1 Diabetes marker (sr only)"
lab var Type1_lib "liberal Type 1 Diabetes marker (sr&HES&Death)"

save `temp_dia2', replace

import delimited `WITHDRAWN', clear
rename v1 n_eid

merge 1:1 n_eid using `temp_dia2', update
drop if inlist(_merge,1,3)
assert inlist(_merge,2)
drop _merge

rename summary* diabetes*
rename Type* diabetes_Type*
rename n_eid eid

if missing("`out_diabetes'"){
	save `outfiles'/`diabetesout'.dta, replace
	export delimited using `outfiles'/`diabetesout'.csv, replace
	log close
}
else{
		save `temp_diabetes', replace
	}



}


