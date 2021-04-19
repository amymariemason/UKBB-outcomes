*********************************************************Diabetes diagnostic algorithms for self-report data in whole UKB dataset

**********************************************************Flowchart 3:Type 2 categories  for Diabetes Classification

*Starting point (from FC1): fc1_poss_t2dm==1

**********Rule 3.1
generate rule_3_1_exit=0
replace rule_3_1_exit=1 if dm_drug_metf_ni_bl==1
replace rule_3_1_exit=0 if dm_drug_ins_bl_sr==1 |dm_drug_ins_ni_bl==1|dm_drug_nonmetf_oad_ni_bl==1
replace rule_3_1_exit=. if fc1_poss_t2dm!=1
tabulate rule_3_1_exit, missing

generate rule_3_1_continue=rule_3_1_exit
recode rule_3_1_continue 0=1 1=0
tabulate rule_3_1_continue, missing

**********Rule 3.2
generate rule_3_2_exit=0
replace rule_3_2_exit=1 if dm_anynsgt1t2_ni_bl!=1
replace rule_3_2_exit=. if rule_3_1_exit!=1
tabulate rule_3_2_exit, missing

generate rule_3_2_continue=rule_3_2_exit
recode rule_3_2_continue 0=1 1=0
tabulate rule_3_2_continue, missing

**********Rule 3.3
generate rule_3_3_exit=.
replace rule_3_3_exit=0 if rule_3_1_continue==1|rule_3_2_continue==1
replace rule_3_3_exit=1 if dm_drug_nonmetf_oad_ni_bl==1
tabulate rule_3_3_exit, missing

generate rule_3_3_continue=rule_3_3_exit
recode rule_3_3_continue 0=1 1=0
tabulate rule_3_3_continue, missing

**********Rule 3.4
generate rule_3_4_exit=0
replace rule_3_4_exit=1 if dm_drug_ins_bl_sr!=1 & dm_drug_ins_ni_bl!=1
replace rule_3_4_exit=. if rule_3_3_continue!=1
tabulate rule_3_4_exit, missing

generate rule_3_4_continue=rule_3_4_exit
recode rule_3_4_continue 0=1 1=0
tabulate rule_3_4_continue, missing

**********Rule 3.5
generate rule_3_5_poss_t1=0
replace rule_3_5_poss_t1=1 if dm_t1dm_ni_bl==1
replace rule_3_5_poss_t1=. if rule_3_4_continue!=1
tabulate rule_3_5_poss_t1, missing

generate rule_3_5_poss_t2=rule_3_5_poss_t1
recode rule_3_5_poss_t2 0=1 1=0
tabulate rule_3_5_poss_t2, missing


*****************************Creating post-flowchart 3 variables

generate fc3_no_diabetes=rule_3_2_exit
label variable fc3_no_diabetes "Diabetes unlikely"
label define fc3_no_diabeteslab 1"Diabetes unlikely" 0"Possible diabetes"
label value  fc3_no_diabetes fc3_no_diabeteslab
tabulate fc3_no_diabetes, missing

generate fc3_prob_t2dm=0
replace fc3_prob_t2dm=1 if rule_3_3_exit==1
replace fc3_prob_t2dm=1 if rule_3_4_exit==1
label variable fc3_prob_t2dm "Probable type 2 diabetes, post-flowchart 3"
label define fc3_prob_t2dmlab 0"T2DM unlikely" 1"Probable T2DM"
label value  fc3_prob_t2dm fc3_prob_t2dmlab
tabulate fc3_prob_t2dm

generate fc3_poss_t2dm=0
replace fc3_poss_t2dm=1 if rule_3_5_poss_t2==1
label variable fc3_poss_t2dm "Possible type 2 diabetes, post-flowchart 3"
label define fc3_poss_t2dmlabel 0"T2DM unlikely" 1"Possible T2DM"
label value fc3_poss_t2dm fc3_poss_t2dmlabel
tabulate fc3_poss_t2dm

generate fc3_prob_t1dm=0
replace fc3_prob_t1dm=1 if rule_3_5_poss_t1==1
label variable fc3_prob_t1dm "Probable type 1 diabetes, post-flowchart 3"
label define fc3_prob_t1dmlabel 0"T1DM unlikely" 1"Probable T1DM"
label value fc3_prob_t1dm fc3_prob_t1dmlabel
tabulate fc3_prob_t1dm
*NB/ In theory, these people (n=122 in whole UKB dataset)should feed back into flowchart 2, where they will all be re-classified
* as "Probable type 1 diabetes" by rule 2.1
************************************************************************************************************


