**Add diabetes info from HES

* Definitions for purpose of HES/Death

* any: 
**** ICD-9:  250+ 
**** ICD-10: E10+  E11+ O24.429 

* Gest 
**** ICD-10: O24.429

*Type 1
**** ICD-10: E10+

* Type 2
**** ICD-10: E11+


* SETUP
**************************************************

* want 4 variables: HES_any, HES_T2, HES_T1, HES_gest

********************************************
*HES data

import delimited `HES_diag', clear
rename eid n_eid

* match to ICD 10 values

foreach out of newlist gest T1 T2 any{
gen HESmatch_`out' =0
}

* match to ICD 10 values
replace HESmatch_any =1 if regexm(diag_icd10,"E10[0-9]*")
replace HESmatch_any =1 if regexm(diag_icd10,"E11[0-9]*")
replace HESmatch_any =1 if regexm(diag_icd10,"O244")
replace HESmatch_gest =1 if regexm(diag_icd10,"O244")
replace HESmatch_T1 =1 if regexm(diag_icd10,"E10[0-9]*")
replace HESmatch_T2 =1 if regexm(diag_icd10,"E11[0-9]*")

* keep 1 record per person			
keep n_eid HESmatch*
sort n_eid 
foreach out of newlist any gest T1 T2{
by n_eid: egen HES_`out' = max (HESmatch_`out')
}
drop HESmatch*
rename HES* HESmatch*
by n_eid: drop if _n>1


*************************************STEP 3: death fields data set

merge 1:1 n_eid using `inputfile', update
assert inlist(_merge,1,2,3)
drop _merge

keep n_eid HES* s_40001* s_40002*

****** death report 40001

gen Deathmatch_any =0
gen Deathmatch_gest =0
gen Deathmatch_T1=0
gen Deathmatch_T2=0

*match to ICD 10 values
foreach i of varlist s_40001* s_40002*{
replace Deathmatch_any =1 if regexm(`i',"E10[0-9]*")
replace Deathmatch_any =1 if regexm(`i',"E11[0-9]*")
replace Deathmatch_any =1 if regexm(`i',"O244")
replace Deathmatch_gest =1 if regexm(`i',"O244")
replace Deathmatch_T1 =1 if regexm(`i',"E10[0-9]*")
replace Deathmatch_T2 =1 if regexm(`i',"E11[0-9]*")
}


drop s*

* combine death and HES
gen HESDeath_dia_any = Deathmatch_any
replace HESDeath_dia_any = 1 if HESmatch_any==1

gen HESDeath_dia_gest = Deathmatch_gest
replace HESDeath_dia_gest = 1 if HESmatch_gest==1

gen HESDeath_dia_T1 = Deathmatch_T1
replace HESDeath_dia_T1 = 1 if HESmatch_T1==1

gen HESDeath_dia_T2 = Deathmatch_T2
replace HESDeath_dia_T2 = 1 if HESmatch_T2==1

* create single variable

gen summary_HESDeath = 1 if HESDeath_dia_any==0
replace summary_HESDeath = 0 if HESDeath_dia_any==1
replace summary_HESDeath = 2 if HESDeath_dia_gest == 1 & HESDeath_dia_T1 ==0 & HESDeath_dia_T2 ==0 
replace summary_HESDeath = 6 if HESDeath_dia_T1 ==1 & HESDeath_dia_T2 ==0 
replace summary_HESDeath = 4 if HESDeath_dia_T1 ==0 & HESDeath_dia_T2 ==1 
lab val summary_H summary_def

noi di "HES and DEath info"
noi tab summary

keep n_eid summary_HESDeath


