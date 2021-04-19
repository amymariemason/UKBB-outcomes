*********************************************************Diabetes diagnostic algorithms for self-report data in whole UKB dataset
**********************************************************Flowchart 1:Starting categories  for Diabetes Classification

*************************1.1
generate rule_1_1_continue=0
replace rule_1_1_continue=1 if dm_gdmonly_sr_bl==1 | dm_alldm_ni_bl==1 | dm_gdm_ni_bl==1| dm_t1dm_ni_bl==1 |dm_t2dm_ni_bl==1 | dm_drug_ins_ni_bl==1 |dm_drug_ins_bl_sr==1 | dm_drug_metf_ni_bl==1|dm_drug_nonmetf_oad_ni_bl==1
tabulate rule_1_1_continue, missing

generate rule_1_1_exit=rule_1_1_continue
recode rule_1_1_exit 1=0 0=1
tabulate rule_1_1_exit, missing

*************************1.2
generate rule_1_2_exit=0
replace rule_1_2_exit=1 if sex==1 &  dm_gdm_ni_bl==1 & dm_anydmrx_ni_sr_bl!=1 & dm_t1dm_ni_bl!=1 & dm_t2dm_ni_bl!=1
replace rule_1_2_exit=. if rule_1_1_continue!=1
tabulate rule_1_2_exit 

generate rule_1_2_continue=rule_1_2_exit
recode rule_1_2_continue 1=0 0=1
tabulate rule_1_2_continue, missing

*************************1.3
generate rule_1_3_exit=0
replace rule_1_3_exit=1 if dm_gdmonly_sr_bl==1 & dm_anydmrx_ni_sr_bl!=1 & dm_t1dm_ni_bl!=1 & dm_t2dm_ni_bl!=1
replace rule_1_3_exit=1 if dm_gdm_ni_bl==1 & dm_agediag_gdm_ni_bl<50 & dm_anydmrx_ni_sr_bl!=1 & dm_t1dm_ni_bl!=1 & dm_t2dm_ni_bl!=1
replace rule_1_3_exit=. if rule_1_2_continue!=1
tabulate rule_1_3_exit, missing

generate rule_1_3_continue=rule_1_3_exit
recode rule_1_3_continue 0=1 1=0
tabulate rule_1_3_continue, missing

*************************1.4
generate rule_1_4_exit=0
replace rule_1_4_exit=1 if dm_drug_nonmetf_oad_ni_bl==1
replace rule_1_4_exit=. if rule_1_3_continue!=1
tabulate rule_1_4_exit, missing

generate rule_1_4_continue=rule_1_4_exit
recode rule_1_4_continue 0=1 1=0
tabulate rule_1_4_continue, missing

*************************1.5 
generate rule_1_5_continue=0
replace rule_1_5_continue=1 if dm_agedm_ts_or_ni!=. & dm_agedm_ts_or_ni>0 & dm_agedm_ts_or_ni<31 & ethnic_sa_afc==1
replace rule_1_5_continue=1 if dm_agedm_ts_or_ni!=. & dm_agedm_ts_or_ni>0 & dm_agedm_ts_or_ni<37 & ethnic_sa_afc==0
replace rule_1_5_continue=. if rule_1_4_continue!=1
tabulate rule_1_5_continue, missing

generate rule_1_5_exit=rule_1_5_continue
recode rule_1_5_exit 1=0 0=1
tabulate rule_1_5_exit, missing

*************************1.6
generate rule_1_6_poss_t1=0
replace rule_1_6_poss_t1=1 if dm_drug_ins_bl_sr==1 |  dm_drug_ins_ni_bl==1 | dm_insat1yr==1 | dm_t1dm_ni_bl==1
replace rule_1_6_poss_t1=. if rule_1_5_continue!=1
tabulate rule_1_6_poss_t1, missing

generate rule_1_6_poss_t2=rule_1_6_poss_t1
recode rule_1_6_poss_t2 1=0 0=1
tabulate rule_1_6_poss_t2, missing

*****************************Creating post-flowchart 1 variables

generate fc1_no_diabetes=rule_1_1_exit
label variable fc1_no_diabetes "Diabetes unlikely"
label define fc1_no_diabeteslabel 1"Diabetes unlikely" 0"Possible diabetes"
label value  fc1_no_diabetes fc1_no_diabeteslabel
tabulate fc1_no_diabetes, missing

generate fc1_uncertain_diabetes=rule_1_2_exit
label variable fc1_uncertain_diabetes "Uncertain diabetes status"
label define fc1_uncertain_diabeteslabel 1"Uncertain diabetes status" 0"Possible diabetes, all types"
label value  fc1_uncertain_diabetes fc1_uncertain_diabeteslabel
tabulate fc1_uncertain_diabetes, missing

generate fc1_poss_gdm=rule_1_3_exit
label variable fc1_poss_gdm "Possible gestational diabetes"
recode fc1_poss_gdm .=0
label define fc1_poss_gdmlabel 0"Gestational diabetes unlikely/impossible" 1"Possible gestational diabetes"
label value  fc1_poss_gdm fc1_poss_gdmlabel
tabulate fc1_poss_gdm, missing

generate fc1_poss_t2dm=0
replace fc1_poss_t2dm=1 if rule_1_4_exit==1
replace fc1_poss_t2dm=1 if rule_1_5_exit==1
replace fc1_poss_t2dm=1 if rule_1_6_poss_t2==1
label variable fc1_poss_t2dm "Possible type 2 diabetes, post-flowchart 1"
label define fc1_poss_t2dmlabel 0"T2DM unlikely" 1"Possible T2DM"
label value  fc1_poss_t2dm fc1_poss_t2dmlabel
tabulate fc1_poss_t2dm

generate fc1_poss_t1dm=0
replace fc1_poss_t1dm=1 if rule_1_6_poss_t1==1
label variable fc1_poss_t1dm "Possible type 1 diabetes, post-flowchart 1"
label define fc1_poss_t1dmlabel 0"T1DM unlikely" 1"Possible T1DM"
label value fc1_poss_t1dm fc1_poss_t1dmlabel
tabulate fc1_poss_t1dm

************************************************************************************************************
