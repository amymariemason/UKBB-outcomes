*********************************************************Diabetes diagnostic algorithms for self-report data in whole UKB dataset

**********************************************************Flowchart 2:Type 1 categories  for Diabetes Classification

*Starting point (from FC1): fc1_poss_t1dm==1

**********Rule 2.1
generate rule_2_1_exit=0
replace rule_2_1_exit=1 if dm_t1dm_ni_bl==1
replace rule_2_1_exit=. if rule_1_6_poss_t1!=1
tabulate rule_2_1_exit, missing

generate rule_2_1_continue=rule_2_1_exit
recode rule_2_1_continue 0=1 1=0
tabulate rule_2_1_continue, missing

**********Rule 2.2
generate rule_2_2_prob_t1=0
replace rule_2_2_prob_t1=1 if dm_drug_ins_bl_sr==1 & dm_drug_ins_ni_bl==1
replace rule_2_2_prob_t1=1 if dm_drug_ins_bl_sr==1 & dm_insat1yr==1 
replace rule_2_2_prob_t1=1 if dm_drug_ins_ni_bl==1 & dm_insat1yr==1 
replace rule_2_2_prob_t1=. if rule_2_1_continue!=1
tabulate rule_2_2_prob_t1, missing

generate rule_2_2_poss_t1=rule_2_2_prob_t1
recode rule_2_2_poss_t1 0=1 1=0
tabulate rule_2_2_poss_t1, missing

*****************************Creating post-flowchart 2 variables
generate fc2_prob_t1dm=0
replace fc2_prob_t1dm=1 if rule_2_1_exit==1
replace fc2_prob_t1dm=1 if rule_2_2_prob_t1==1
label variable fc2_prob_t1dm "Probable type 1 diabetes, post-flowchart 2"
label define fc2_prob_t1dmlabel 0"T1DM unlikely" 1"Probable T1DM"
label value fc2_prob_t1dm fc2_prob_t1dmlabel
tabulate fc2_prob_t1dm

generate fc2_poss_t1dm=0
replace fc2_poss_t1dm=1 if rule_2_2_poss_t1==1
label variable fc2_poss_t1dm "Possible type 1 diabetes, post-flowchart 2"
label define fc2_poss_t1dmlabel 0"T1DM unlikely/ definite" 1"Possible T1DM"
label value fc2_poss_t1dm fc2_poss_t1dmlabel
tabulate fc2_poss_t1dm
