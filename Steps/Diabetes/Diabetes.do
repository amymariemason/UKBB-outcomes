************************************Variable derivation files from UK Biobank dataset
* unlike original step 1 this includes later survey data


************************************Demographics
*****Sex
gen sex=n_31_0_0 
recode sex 0=2
lab var sex "Sex"
lab def sexlab  1"Male" 2"Female"
lab val sex sexlab
tab sex
drop n_31_0_0

*****Ethnicity - main groups
*(NB this makes some assumptions i.e. British is white European, and does not include mixed, Chinese or other Asian)
gen  ethnic=n_21000_0_0
recode ethnic 1001=1 1002=1 1003=1 3=2 3001=2 3002=2 3003=2 4=3 4001=3 4002=3 4003=3 2=4 2001=4 2002=4 2003=4 2004=4 3004=4 5=4 6=4 -1=. -3=.
lab var ethnic "Ethnicity: main groups"
lab def ethniclab 1"White European" 2"South Asian" 3"African Caribbean" 4"Mixed or other"
lab val ethnic ethniclab
tab ethnic, mis 
drop n_21000*

*****Ethnicity - further sub-divided into South Asian or African Caribbean vs. European or other
* (NB: places all those who did not answer into European/other)
gen ethnic_sa_afc=0
replace ethnic_sa_afc=1 if ethnic==2|ethnic==3
replace ethnic_sa_afc=. if ethnic==.
lab var ethnic_sa_afc"South Asian/ African Caribbean vs European/other ethnicity"
lab def ethnic_sa_afclab 0"European/ other" 1"South Asian/ African Caribbean"
lab val ethnic_sa_afc ethnic_sa_afclab
tab ethnic_sa_afc, mis

********************************************************************************************************************
************************************Touchscreen self-report data
*****Gestational diabetes only self-report - from touchscreen data
gen dm_gdmonly_sr_bl=n_4041_0_0
recode dm_gdmonly_sr_bl -2=0 -3=. -1=.
lab var dm_gdmonly_sr_bl "Gestational diabetes only - denominator women with diabetes, baseline self-report"
lab def dm_gdmonly_sr_bllab 0"No" 1"Yes"
lab val dm_gdmonly_sr_bl dm_gdmonly_sr_bllab
tab dm_gdmonly_sr_bl


** use updated surveys to change if people subsequently said they had non-gestational diabetes
* (i.e. only keep gestational marker if all surveys say gestational only or missing)
gen dm_gdmonly_sr_bl1=n_4041_1_0
recode dm_gdmonly_sr_bl1 -2=0 -3=. -1=.
lab val dm_gdmonly_sr_bl1 dm_gdmonly_sr_bllab

gen dm_gdmonly_sr_bl2=n_4041_2_0
recode dm_gdmonly_sr_bl2 -2=0 -3=. -1=.
lab val dm_gdmonly_sr_bl1 dm_gdmonly_sr_bllab

di "subsequent answers from women who said gestational only at first survey"
noi tab dm_gdmonly_sr_bl1 dm_gdmonly_sr_bl2 if dm_gdmonly_sr_bl==1 

di "number who said yes, then later No to Qu: gestational diabetes only"
gen changed_mind = 1 if dm_gdmonly_sr_bl==1 & (dm_gdmonly_sr_bl1 ==0 | dm_gdmonly_sr_bl2 ==0)
noi list n_eid if changed_mind==1
noi summ changed_mind

replace dm_gdmonly_sr_bl=0 if changed_mind==1
drop dm_gdmonly_sr_bl1 dm_gdmonly_sr_bl2 n_4041* changed_mind


*****Age at diabetes diagnosis
gen dm_agediag_sr_bl0=n_2976_0_0
lab var dm_agediag_sr_bl0 "Age diabetes diagnosed by doctor"
replace dm_agediag_sr_bl0=. if dm_agediag_sr_bl<0
sum dm_agediag_sr_bl0

**** look at differences in subsequent reports

gen dm_agediag_sr_bl1=n_2976_1_0
replace dm_agediag_sr_bl1=. if dm_agediag_sr_bl1<0
gen dm_agediag_sr_bl2=n_2976_2_0
replace dm_agediag_sr_bl2=. if dm_agediag_sr_bl2<0

gen diff=  abs(dm_agediag_sr_bl0 - dm_agediag_sr_bl1)
gen diff1=  abs(dm_agediag_sr_bl0 - dm_agediag_sr_bl2)
gen diff2=  abs(dm_agediag_sr_bl1 - dm_agediag_sr_bl2)

noi di "age of diagnosis of diabetes if diffs by > 5 years in subsequent reports"
egen min_all= rowmin (dm_agediag_sr_bl0 dm_agediag_sr_bl1 dm_agediag_sr_bl2)
egen max_all= rowmax (dm_agediag_sr_bl0 dm_agediag_sr_bl1 dm_agediag_sr_bl2)
egen med_all= rowmedian (dm_agediag_sr_bl0 dm_agediag_sr_bl1 dm_agediag_sr_bl2)
egen mean_all = rowmean (dm_agediag_sr_bl0 dm_agediag_sr_bl1 dm_agediag_sr_bl2)
gen morethan5=1 if max_all-min_all>5  & max_all!=.
noi summ morethan5
noi list dm_agediag_sr_bl* med_all mean_all if morethan5==1 &morethan5!=.

* As a judgement call: take median value if multiple reported ages

gen dm_agediag_sr_bl = med_all
drop  dm_agediag_sr_bl1 dm_agediag_sr_bl2 *_all morethan5 diff* 
noi di "age of diagnosis of diabetes original survey"
summ dm_agediag_sr_bl0

noi di "age of diagnosis of diabetes encorporating all surveys (median value)"
summ dm_agediag_sr_bl
lab var dm_agediag_sr_bl "Age diabetes diagnosed by doctor"
drop dm_agediag_sr_bl0
* gain of nearly 1000 values!


********************************************************************************************************************
************************************Touchscreen self-report data: MEDICATIONS
***** Current insulin receipt

* If person says yes diabetes, at any survey -> yes
* If person never says yes, and says none/ selects only other meds -> no
* If person only says do not know/ prefer not to answer/ missing -> missing
**MEN

*original code
gen dm_drug_ins_men_org=0
replace dm_drug_ins_men_org=1 if n_6177_0_0==3|n_6177_0_1==3|n_6177_0_2==3
replace dm_drug_ins_men_org=. if n_6177_0_0==.|n_6177_0_0==-3|n_6177_0_0==-1
tab dm_drug_ins_men, mis

* update for all surveys
egen dm_drug_ins_men= anymatch(n_6177*), values(3) 
egen temp_missing = anycount(n_6177_*_0), values(-1 -3)
egen temp_missing2 = rownonmiss(n_6177_*_0) 
replace dm_drug_ins_men = . if temp_missing==temp_missing2 
drop temp*

noi di "original survey: male current insulin intake"
summ dm_drug_ins_men_org if sex==1

noi di "encorporating all surveys: male current insulin intake"
summ dm_drug_ins_men

tab dm_drug_ins_men_org dm_drug_ins_men if sex==1, miss


**WOMEN

*original code
gen dm_drug_ins_women_org=0
replace dm_drug_ins_women_org=1 if n_6153_0_0==3|n_6153_0_1==3|n_6153_0_2==3
replace dm_drug_ins_women_org=. if n_6153_0_0==.|n_6153_0_0==-3|n_6153_0_0==-1
tab dm_drug_ins_women, mis

* update for all surveys
egen dm_drug_ins_women= anymatch(n_6153*), values(3) 
egen temp_missing = anycount(n_6153_*_0), values(-1 -3)
egen temp_missing2 = rownonmiss(n_6153_*_0) 
replace dm_drug_ins_women = . if temp_missing==temp_missing2 
drop temp*

noi di "original survey: women current insulin intake"
summ dm_drug_ins_women_org

noi di "encorporating all surveys: women current insulin intake"
summ dm_drug_ins_women

tab dm_drug_ins_women_org dm_drug_ins_women if sex==2, miss

**Combine
gen dm_drug_ins_bl_sr=.
* check no non-missing contractions
assert dm_drug_ins_men==dm_drug_ins_women if dm_drug_ins_women!=. & dm_drug_ins_men!=.

replace dm_drug_ins_bl_sr=0 if dm_drug_ins_men==0|dm_drug_ins_women==0
replace dm_drug_ins_bl_sr=1 if dm_drug_ins_men==1|dm_drug_ins_women==1

lab var dm_drug_ins_bl_sr "On insulin"
labe def dm_drug_ins_bl_srlab 0"No" 1"Yes"
lab val dm_drug_ins_bl_sr dm_drug_ins_bl_srlab

noi display "insulin usage by sex"
tab dm_drug_ins_bl_sr sex, miss
drop dm_drug_ins_men* dm_drug_ins_women*



*****Insulin receipt within 12 months of diagnosis

*original code
gen dm_insat1yr=n_2986_0_0 
recode dm_insat1yr -3=. -1=.
lab var dm_insat1yr "First survey Insulin started within 1 yr of diagnosis"
lab def dm_insat1yrlab 0"No" 1"Yes" 
lab val dm_insat1yr dm_insat1yrlab
tab dm_insat1yr
rename dm_insat1yr dm_insat1yr_org

* update
egen temp_yes= anymatch(n_2986*), values(1) 
egen temp_no= anymatch(n_2986*), values(0)
egen temp_missing = anycount(n_2986_*_0), values(-1 -3)
egen temp_missing2 = rownonmiss(n_2986_*_0) 

gen dm_insat1yr=0 if temp_no==1
replace dm_insat1yr=1 if temp_yes==1
assert dm_insat1yr==. if temp_missing==temp_missing2

noi di "original survey: insulin intake within 12 month of diagnosis"
summ dm_insat1yr_org

noi di "encorporating all surveys: insulin intake within 12 month of diagnosis"
summ dm_insat1yr

lab var dm_insat1yr "Insulin started within 1 yr of diagnosis"

tab dm_insat1yr_org dm_insat1yr, miss
drop temp* dm_insat1yr_org

********************************************************************************************************************
************************************Nurse interview self-report data
*****Non-type-specific self-report of diabetes + age of non-type-specific diabetes - from nurse interview 


*create variable for all surveys
gen temp_0=.
gen temp_age_0=.
forvalues i=0/28 {
replace temp_0=1 if n_20002_0_`i'==1220
replace temp_age_0= n_20009_0_`i' if n_20002_0_`i'==1220
}

gen temp_1=.
gen temp_age_1=.
forvalues i=0/15 {
replace temp_1=1 if n_20002_1_`i'==1220
replace temp_age_1= n_20009_1_`i' if n_20002_1_`i'==1220
}

gen temp_2=.
gen temp_age_2=.
forvalues i=0/20 {
replace temp_2=1 if n_20002_2_`i'==1220
replace temp_age_2= n_20009_2_`i' if n_20002_2_`i'==1220
}


egen dm_alldm_ni_bl= rowmin(temp_1 temp_2 temp_0)
egen dm_agediag_alldm_ni_bl= rowmedian(temp_age*)

lab var dm_alldm_ni_bl "Diabetes non-specified, baseline nurse interview"
lab def dm_alldm_ni_bllab 1"Diabetes present"
lab val dm_alldm_ni_bl dm_alldm_ni_bllab
lab var dm_agediag_alldm_ni_bl "Age (median) at diagnosis non-specified diabetes, baseline nurse interview"

noi di "number of people with Diabetes non-specified on first survey"
summ temp_0

noi di "number of people with Diabetes non-specified on first survey"
summ dm_alldm_ni_bl if temp_0!=1


drop temp* 


*****Gestational diabetes self-report + age of gestational diabetes - from nurse interview

*create variable for all surveys
gen temp_0=.
gen temp_age_0=.
forvalues i=0/28 {
replace temp_0=1 if n_20002_0_`i'==1221
replace temp_age_0= n_20009_0_`i' if n_20002_0_`i'==1221
}

gen temp_1=.
gen temp_age_1=.
forvalues i=0/15 {
replace temp_1=1 if n_20002_1_`i'==1221
replace temp_age_1= n_20009_1_`i' if n_20002_1_`i'==1221
}

gen temp_2=.
gen temp_age_2=.
forvalues i=0/20 {
replace temp_2=1 if n_20002_2_`i'==1221
replace temp_age_2= n_20009_2_`i' if n_20002_2_`i'==1221
}

egen dm_gdm_ni_bl= rowmin(temp_1 temp_2 temp_0)
egen dm_agediag_gdm_ni_bl=rowmedian(temp_age*)

lab var dm_gdm_ni_bl "GDM, baseline nurse interview"
lab def dm_gdm_ni_bllab 1"GDM present"
lab val dm_gdm_ni_bl dm_gdm_ni_bllab
lab var dm_agediag_gdm_ni_bl"Age (median) at GDM diagnosis, baseline nurse interview"

noi di "number of people with Gestational diabetes on first survey"
summ temp_0

noi di "number of people with Gestational diabetes on later survey"
summ dm_gdm_ni_bl if temp_0!=1

drop temp*

*****Type 1 diabetes self-report + age of type 1 diabetes - from nurse interview

*create variable for all surveys
gen temp_0=.
gen temp_age_0=.
forvalues i=0/28 {
replace temp_0=1 if n_20002_0_`i'==1222
replace temp_age_0= n_20009_0_`i' if n_20002_0_`i'==1222
}

gen temp_1=.
gen temp_age_1=.
forvalues i=0/15 {
replace temp_1=1 if n_20002_1_`i'==1222
replace temp_age_1= n_20009_1_`i' if n_20002_1_`i'==1222
}

gen temp_2=.
gen temp_age_2=.
forvalues i=0/20 {
replace temp_2=1 if n_20002_2_`i'==1222
replace temp_age_2= n_20009_2_`i' if n_20002_2_`i'==1222
}


egen dm_t1dm_ni_bl= rowmin(temp_1 temp_2 temp_0)
egen dm_agediag_t1dm_ni_bl=rowmedian(temp_age*)

lab var dm_t1dm_ni_bl "T1DM, baseline nurse interview"
lab def dm_t1dm_ni_bllabe 1"T1DM present"
lab val dm_t1dm_ni_bl dm_t1dm_ni_bllabe
lab var dm_agediag_t1dm_ni_bl "Age (median) at T1DM diagnosis, baseline nurse interview"


noi di "number of people with T1 diabetes on first survey"
summ temp_0

noi di "number of people with T1 diabetes on later survey"
summ dm_t1dm_ni_bl if temp_0!=1

drop temp*

*****Type 2 diabetes self-report + age of type 2 diabetes  - from nurse interview

*create variable for all surveys
gen temp_0=.
gen temp_age_0=.
forvalues i=0/28 {
replace temp_0=1 if n_20002_0_`i'==1223
replace temp_age_0= n_20009_0_`i' if n_20002_0_`i'==1223
}

gen temp_1=.
gen temp_age_1=.
forvalues i=0/15 {
replace temp_1=1 if n_20002_1_`i'==1223
replace temp_age_1= n_20009_1_`i' if n_20002_1_`i'==1223
}

gen temp_2=.
gen temp_age_2=.
forvalues i=0/20 {
replace temp_2=1 if n_20002_2_`i'==1223
replace temp_age_2= n_20009_2_`i' if n_20002_2_`i'==1223
}


egen dm_t2dm_ni_bl=rowmin(temp_1 temp_2 temp_0)
egen dm_agediag_t2dm_ni_bl=rowmedian(temp_age*)

tab dm_t2dm_ni_bl
lab var dm_t2dm_ni_bl "T2DM, baseline nurse interview"
lab def dm_t2dm_ni_bllab 1"T2DM present"
lab val dm_t2dm_ni_bl dm_t2dm_ni_bllab
lab var dm_agediag_t2dm_ni_bl "Age (median) at T2DM diagnosis, baseline nurse interview"

noi di "number of people with T2 diabetes on first survey"
summ temp_0

noi di "number of people with T2 diabetes on later survey"
summ dm_t2dm_ni_bl if temp_0!=1

drop temp*

*****Non-type-specific / gestational/ type 1/ type 2 diabetes self-report  - from nurse interview
gen dm_anynsgt1t2_ni_bl=.
replace dm_anynsgt1t2_ni_bl=1 if dm_alldm_ni_bl==1|dm_gdm_ni_bl==1|dm_t1dm_ni_bl==1|dm_t2dm_ni_bl==1
lab var dm_anynsgt1t2_ni_bl "Nurse interview: non-specific/ GDM/ T1DM/ T2DM reported"
tab dm_anynsgt1t2_ni_bl

*****Age at diabetes (all types) diagnosis - touchscreen or nurse interview (nurse interview supercedes)
gen dm_agedm_ts_or_ni= dm_agediag_alldm_ni_bl
replace dm_agedm_ts_or_ni=dm_agediag_sr_bl if dm_agediag_alldm_ni_bl==. & dm_agediag_t1dm_ni_bl==. & dm_agediag_t2dm_ni_bl==. & dm_gdmonly_sr_bl!=1
replace dm_agedm_ts_or_ni=dm_agediag_t1dm_ni_bl if dm_t1dm_ni_bl==1
replace dm_agedm_ts_or_ni=dm_agediag_t2dm_ni_bl if dm_t2dm_ni_bl==1
replace dm_agedm_ts_or_ni=. if dm_agediag_sr_bl==. &  dm_agediag_alldm_ni_bl==. & dm_agediag_t1dm_ni_bl==. & dm_agediag_t2dm_ni_bl==. 
replace dm_agedm_ts_or_ni=. if dm_agedm_ts_or_ni<0
noi di "Age at diabetes (all types) diagnosis"
sum dm_agedm_ts_or_ni


********************************************************************************************************************
************************************Nurse interview self-report data: MEDICATIONS - see further explanation below for how these were derived - if interested only!
*****Current insulin receipt
gen dm_drug_ins_ni_bl=.
forvalues i=0/47 {
replace dm_drug_ins_ni_bl=1 if n_20003_0_`i'==1140883066
}
forvalues i=0/27 {
replace dm_drug_ins_ni_bl=1 if n_20003_1_`i'==1140883066
}
forvalues i=0/29 {
replace dm_drug_ins_ni_bl=1 if n_20003_2_`i'==1140883066
}

*
lab var dm_drug_ins_ni_bl "Taking insulin, baseline nurse interview"
recode dm_drug_ins_ni_bl .=0
lab def dm_drug_ins_ni_bllab 0"No insulin" 1"On insulin"
lab val dm_drug_ins_ni_bl dm_drug_ins_ni_bllab
tab dm_drug_ins_ni_bl


*****Current metformin receipt
gen dm_drug_metf_ni_bl=.
forvalues i=0/47 {
replace dm_drug_metf_ni_bl=1 if n_20003_0_`i'==1140884600 
replace dm_drug_metf_ni_bl=1 if n_20003_0_`i'==1140874686
replace dm_drug_metf_ni_bl=1 if n_20003_0_`i'==1141189090
}
forvalues i=0/27 {
replace dm_drug_metf_ni_bl=1 if n_20003_1_`i'==1140884600 
replace dm_drug_metf_ni_bl=1 if n_20003_1_`i'==1140874686
replace dm_drug_metf_ni_bl=1 if n_20003_1_`i'==1141189090
}

forvalues i=0/29 {
replace dm_drug_metf_ni_bl=1 if n_20003_2_`i'==1140884600 
replace dm_drug_metf_ni_bl=1 if n_20003_2_`i'==1140874686
replace dm_drug_metf_ni_bl=1 if n_20003_2_`i'==1141189090
}

lab var dm_drug_metf_ni_bl "Taking metformin, baseline nurse interview"
recode dm_drug_metf_ni_bl .=0
lab def dm_drug_metf_ni_bllab 0"No metformin" 1"On metformin"
lab val dm_drug_metf_ni_bl dm_drug_metf_ni_bllab
tab dm_drug_metf_ni_bl

*****Current non-metformin oral anti-diabetic receipt
///Sulfonylureas
gen dm_drug_su_ni_bl=.
forvalues i=0/47 {
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1140874718 
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1140874744
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1140874746
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1141152590 
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1141156984
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1140874646
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1141157284 
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1140874652
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1140874674
replace dm_drug_su_ni_bl=1 if n_20003_0_`i'==1140874728 
}
forvalues i=0/27 {
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1140874718 
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1140874744
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1140874746
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1141152590 
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1141156984
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1140874646
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1141157284 
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1140874652
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1140874674
replace dm_drug_su_ni_bl=1 if n_20003_1_`i'==1140874728 
}
forvalues i=0/29 {
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1140874718 
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1140874744
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1140874746
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1141152590 
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1141156984
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1140874646
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1141157284 
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1140874652
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1140874674
replace dm_drug_su_ni_bl=1 if n_20003_2_`i'==1140874728 
}


lab var dm_drug_su_ni_bl "Taking sulfonylurea, baseline nurse interview"
recode dm_drug_su_ni_bl  .=0
lab def dm_drug_su_ni_bllab 0"No sulfonylurea" 1"On sulfonylurea"
lab val dm_drug_su_ni_bl dm_drug_su_ni_bllab
tab dm_drug_su_ni_bl

///Other, more obscure, OADs
gen dm_drug_other_oad_ni_bl=.
forvalues i=0/47 {
replace dm_drug_other_oad_ni_bl=1 if n_20003_0_`i'==1140868902 
replace dm_drug_other_oad_ni_bl=1 if n_20003_0_`i'==1140868908
replace dm_drug_other_oad_ni_bl=1 if n_20003_0_`i'==1140857508
}

forvalues i=0/27 {
replace dm_drug_other_oad_ni_bl=1 if n_20003_1_`i'==1140868902 
replace dm_drug_other_oad_ni_bl=1 if n_20003_1_`i'==1140868908
replace dm_drug_other_oad_ni_bl=1 if n_20003_1_`i'==1140857508
}

forvalues i=0/29 {
replace dm_drug_other_oad_ni_bl=1 if n_20003_2_`i'==1140868902 
replace dm_drug_other_oad_ni_bl=1 if n_20003_2_`i'==1140868908
replace dm_drug_other_oad_ni_bl=1 if n_20003_2_`i'==1140857508
}

lab var dm_drug_other_oad_ni_bl "Taking other oral anti-diabetic (acarbose, guar gum), baseline nurse interview"
recode dm_drug_other_oad_ni_bl .=0
lab def dm_drug_other_oad_ni_bllab 0"Not on other oral anti-diabetic" 1"On other oral anti-diabetic"
lab val dm_drug_other_oad_ni_bl dm_drug_other_oad_ni_bllab
tab dm_drug_other_oad_ni_bl

///Meglitinides
gen dm_drug_meglit_ni_bl=.
forvalues i=0/47 {
replace dm_drug_meglit_ni_bl=1 if n_20003_0_`i'==1141173882 
replace dm_drug_meglit_ni_bl=1 if n_20003_0_`i'==1141173786
replace dm_drug_meglit_ni_bl=1 if n_20003_0_`i'==1141168660
}

forvalues i=0/27 {
replace dm_drug_meglit_ni_bl=1 if n_20003_1_`i'==1141173882 
replace dm_drug_meglit_ni_bl=1 if n_20003_1_`i'==1141173786
replace dm_drug_meglit_ni_bl=1 if n_20003_1_`i'==1141168660
}

forvalues i=0/29 {
replace dm_drug_meglit_ni_bl=1 if n_20003_2_`i'==1141173882 
replace dm_drug_meglit_ni_bl=1 if n_20003_2_`i'==1141173786
replace dm_drug_meglit_ni_bl=1 if n_20003_2_`i'==1141168660
}

lab var dm_drug_meglit_ni_bl "Taking meglitinide, baseline nurse interview"
recode dm_drug_meglit_ni_bl .=0
lab def dm_drug_meglit_ni_bllab 0"No meglitinide" 1"On meglitinide"
lab val dm_drug_meglit_ni_bl dm_drug_meglit_ni_bllab
tab dm_drug_meglit_ni_bl

///Glitazones
gen dm_drug_glitaz_ni_bl=.
forvalues i=0/47 {
replace dm_drug_glitaz_ni_bl=1 if n_20003_0_`i'==1141171646 
replace dm_drug_glitaz_ni_bl=1 if n_20003_0_`i'==1141171652
replace dm_drug_glitaz_ni_bl=1 if n_20003_0_`i'==1141153254
replace dm_drug_glitaz_ni_bl=1 if n_20003_0_`i'==1141177600
replace dm_drug_glitaz_ni_bl=1 if n_20003_0_`i'==1141177606
}

forvalues i=0/27 {
replace dm_drug_glitaz_ni_bl=1 if n_20003_1_`i'==1141171646 
replace dm_drug_glitaz_ni_bl=1 if n_20003_1_`i'==1141171652
replace dm_drug_glitaz_ni_bl=1 if n_20003_1_`i'==1141153254
replace dm_drug_glitaz_ni_bl=1 if n_20003_1_`i'==1141177600
replace dm_drug_glitaz_ni_bl=1 if n_20003_1_`i'==1141177606
}
forvalues i=0/29 {
replace dm_drug_glitaz_ni_bl=1 if n_20003_2_`i'==1141171646 
replace dm_drug_glitaz_ni_bl=1 if n_20003_2_`i'==1141171652
replace dm_drug_glitaz_ni_bl=1 if n_20003_2_`i'==1141153254
replace dm_drug_glitaz_ni_bl=1 if n_20003_2_`i'==1141177600
replace dm_drug_glitaz_ni_bl=1 if n_20003_2_`i'==1141177606
}
*
lab var dm_drug_glitaz_ni_bl "Taking glitazone, baseline nurse interview"
recode dm_drug_glitaz_ni_bl .=0
lab def dm_drug_glitaz_ni_bllab 0"No glitazone" 1"On glitazone"
lab val dm_drug_glitaz_ni_bl dm_drug_glitaz_ni_bllab
tab dm_drug_glitaz_ni_bl
*******Non-metformin OADs (including above 4 drug classes)
gen dm_drug_nonmetf_oad_ni_bl=.
replace dm_drug_nonmetf_oad_ni_bl=1 if dm_drug_su_ni_bl==1 | dm_drug_other_oad_ni_bl==1==1 | dm_drug_meglit_ni_bl==1 | dm_drug_glitaz_ni_bl==1
lab var dm_drug_nonmetf_oad_ni_bl "Taking non-metformin oral anti-diabetic drug, baseline nurse interview"
recode dm_drug_nonmetf_oad_ni_bl .=0
lab def dm_drug_nonmetf_oad_ni_bllab 0"No non-metformin oral anti-diabetic drug" 1"On non-metformin oral anti-diabetic drug"
lab val dm_drug_nonmetf_oad_ni_bl dm_drug_nonmetf_oad_ni_bllab
tab dm_drug_nonmetf_oad_ni_bl

*****Any current medication receipt
gen dm_anydmrx_ni_sr_bl=0
replace dm_anydmrx_ni_sr_bl=1 if dm_drug_ins_ni_bl==1|dm_drug_metf_ni_bl==1|dm_drug_nonmetf_oad_ni_bl==1|dm_drug_ins_bl_sr==1
lab var dm_anydmrx_ni_sr_bl "Any reported diabetes medication: nurse interview"
tab dm_anydmrx_ni_sr_bl

***********************************************************************************************************************
*

********************************************************************************************************************
************************************Nurse interview self-report data: MEDICATIONS: HOW THEY WERE DERIVED (following syntax not necessary for derivation)

******Derived from "parent" medication variables from self-report nurse interview data 
*n_20003_0_0 to n_20003_0_47

******Codes used to define the different classes of medication(contained in the above variables in wide format):
///Insulins (all, non-specified): 1140883066

///Metformin (generic name, trade name, combinations): 1140884600 | 1140874686 | 1141189090

///Sulfonylureas (generic names, trade names): 1140874718 | 1140874744 | 1140874746 | 1141152590 | 1141156984 | 1140874646 | 1141157284 | 1140874652 | 1140874674 | 1140874728

///Others (acarbose generic, acarbose trade, Glucotard trade): 1140868902 |1140868908 | 1140857508 

///Meglitinides (generic names, trade names):1141173882 | 1141173786 | 1141168660

///Glitazones (generic names, trade names): 1141171646 | 1141171652 | 1141153254 | 1141177600 | 1141177606

///Non-metformin OADs (including above 4 drug classes):
*1140874718 | 1140874744 | 1140874746 | 1141152590 | 1141156984 | 1140874646 | 1141157284 | 1140874652 | 1140874674 | 1140874728 |
*1140868902 |1140868908 | 1140857508 | 1141173882 | 1141173786 | 1141168660 | 1141171646 | 1141171652 | 1141153254 | 1141177600 | 1141177606


