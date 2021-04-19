********************************************
* Create Parental/sibling outcomes in UKBB
* Author: Amy Mason
* Date: Jan 2018
* Input: Run UKBB9202_Amy
* Output: Family outcomes
*********************************************
cap log close
log using familyoutcome.log, replace
noi di "Run by AMM on $S_DATE $S_TIME"

* drop those we wish to be excluded from UKBB research
set more off


* loop over all reported outcomes in family variables		  
foreach x of num 1/13 {
gen father_`x' =0
gen mother_`x'=0
gen sibling_`x'=0

* create markers for fathers illnesses
 foreach i of varlist n_20107* {
replace father_`x'=1 if `i'==`x'
}

* create markers for mothers illnesses
 foreach i of varlist n_20110* {
replace mother_`x'=1 if `i'==`x'
}

* create markers for sibling illnesses
 foreach i of varlist n_20111* {
replace sibling_`x'=1 if `i'==`x'
}

* create markers for parent illnesses
gen parent_`x' = max(father_`x', mother_`x')
gen family_`x'= max(father_`x', mother_`x', sibling_`x')

}

* add value label to variables
 label define bin_label 1 "Yes" 0 "No"
		  
 label values father* mother* sibling* parent* family* bin_label
 
 * add description to variables
 foreach y of newlist father mother sibling parent{
 rename (`y'_1) (`y'_heart)
 label variable `y'_heart "`y' has heart disease"
 rename (`y'_2) (`y'_stroke)
 label variable `y'_stroke "`y' has stroke"
 rename (`y'_3) (`y'_lung)
 label variable `y'_lung "`y' has lung_cancer"
 rename (`y'_4) (`y'_bowel)
 label variable `y'_bowel "`y' has bowel cancer"
 rename (`y'_5) (`y'_breast)
 label variable `y'_breast "`y' has breast cancer"
 rename (`y'_6) (`y'_chronic)
 label variable `y'_chronic "`y' has chronic bronchitis or emphysema"
 rename (`y'_8) (`y'_hbp)
 label variable `y'_hbp "`y' has high blood pressure"
 rename (`y'_9) (`y'_diab)
 label variable `y'_diab "`y' has diabetes"
 rename (`y'_10) (`y'_demen)
 label variable `y'_demen "`y' has Alzheimers disease or dementia"
 rename (`y'_11) (`y'_park)
 label variable `y'_park "`y' has parkisons"
 rename (`y'_12) (`y'_depress)
 label variable `y'_depress "`y' has depression"
 rename (`y'_13) (`y'_pros)
 label variable `y'_pros "`y' has prostate cancer"
 }

 
  foreach y of newlist family{
 rename (`y'_1) (`y'_heart)
 label variable `y'_heart "mother, father or sibling has heart disease"
 rename (`y'_2) (`y'_stroke)
 label variable `y'_stroke "mother, father or sibling has stroke"
 rename (`y'_3) (`y'_lung)
 label variable `y'_lung "mother, father or sibling has lung_cancer"
 rename (`y'_4) (`y'_bowel)
 label variable `y'_bowel "mother, father or sibling has bowel cancer"
 rename (`y'_5) (`y'_breast)
 label variable `y'_breast "mother, father or sibling has breast cancer"
 rename (`y'_6) (`y'_chronic)
 label variable `y'_chronic "mother, father or sibling has chronic bronchitis or emphysema"
 rename (`y'_8) (`y'_hbp)
 label variable `y'_hbp "mother, father or sibling has high blood pressure"
 rename (`y'_9) (`y'_diab)
 label variable `y'_diab "mother, father or sibling has diabetes"
 rename (`y'_10) (`y'_demen)
 label variable `y'_demen "mother, father or sibling has Alzheimers disease or dementia"
 rename (`y'_11) (`y'_park)
 label variable `y'_park "mother, father or sibling has parkisons"
 rename (`y'_12) (`y'_depress)
 label variable `y'_depress "mother, father or sibling has depression"
 rename (`y'_13) (`y'_pros)
 label variable `y'_pros "mother, father or sibling has prostate cancer"
 }

keep n_eid father* mother* sibling* parent* family*
save "C:\UKbiobank\Stata output\Family Outcomes.dta", replace

