**********************************************************Diabetes unlikely; sr_unlikely_diabetes
generate sr_unlikely_diabetes=fc1_no_diabetes
replace sr_unlikely_diabetes=1 if fc3_no_diabetes==1
label variable sr_unlikely_diabetes "Diabetes unlikely"
label define sr_unlikely_diabeteslabel 1"Diabetes unlikely" 0"Possible diabetes"
label value  sr_unlikely_diabetes sr_unlikely_diabeteslabel
tab sr_unlikely_diabetes


**********************************************************Uncertain diabetes status; sr_uncertain_diabetes
generate sr_uncertain_diabetes=fc1_uncertain_diabetes
label variable sr_uncertain_diabetes "Uncertain diabetes status"
label define sr_uncertain_diabeteslabel 1"Uncertain diabetes status" 0"Possible diabetes, all types"
label value  sr_uncertain_diabetes sr_uncertain_diabeteslabel
tabulate sr_uncertain_diabetes

**********************************************************Possible gestational diabetes;sr_poss_gest_diabetes
generate sr_poss_gest_diabetes=fc1_poss_gdm
label variable sr_poss_gest_diabetes "Possible gestational diabetes"
label define sr_poss_gest_diabeteslabel 0"Gestational diabetes unlikely/impossible" 1"Possible gestational diabetes"
label value  sr_poss_gest_diabetes sr_poss_gest_diabeteslabel
tabulate sr_poss_gest_diabetes, missing

**********************************************************Possible type 2 diabetes;sr_poss_t2_diabetes
generate sr_poss_t2_diabetes=fc3_poss_t2dm
label variable sr_poss_t2_diabetes "Possible type 2 diabetes"
label define sr_poss_t2_diabeteslabel 0"Type 2 diabetes unlikely" 1"Possible type 2 diabetes"
label value  sr_poss_t2_diabetes sr_poss_t2_diabeteslabel
tabulate sr_poss_t2_diabetes, missing

**********************************************************Probable type 2 diabetes;sr_prob_t2_diabetes
generate sr_prob_t2_diabetes=fc3_prob_t2dm
label variable sr_prob_t2_diabetes "Probable type 2 diabetes"
label define sr_prob_t2_diabeteslabel 0"Type 2 diabetes unlikely" 1"Probable type 2 diabetes"
label value  sr_prob_t2_diabetes sr_prob_t2_diabeteslabel
tabulate sr_prob_t2_diabetes, missing

**********************************************************Possible type 1 diabetes;sr_poss_t1_diabetes
generate sr_poss_t1_diabetes=fc2_poss_t1dm
label variable sr_poss_t1_diabetes "Possible type 1 diabetes"
label define sr_poss_t1_diabeteslabel 0"Type 1 diabetes unlikely" 1"Possible type 1 diabetes"
label value  sr_poss_t1_diabetes sr_poss_t1_diabeteslabel
tabulate sr_poss_t1_diabetes, missing

**********************************************************Probable type 1 diabetes;sr_prob_t1_diabetes
generate sr_prob_t1_diabetes=fc2_prob_t1dm
replace sr_prob_t1_diabetes=1 if fc3_prob_t1dm==1
label variable sr_prob_t1_diabetes "Probable type 1 diabetes"
label define sr_prob_t1_diabeteslabel 0"Type 1 diabetes unlikely" 1"Probable type 1 diabetes"
label value  sr_prob_t1_diabetes sr_prob_t1_diabeteslabel
tabulate sr_prob_t1_diabetes, missing
