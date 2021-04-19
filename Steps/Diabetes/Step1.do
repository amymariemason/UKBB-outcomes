************************************Variable derivation files from UK Biobank dataset


********************************************************************************************************************
************************************Demographics
*****Sex
gen sex=n_31_0_0 
recode sex 0=2
lab var sex "Sex"
lab def sexlab  1"Male" 2"Female"
lab val sex sexlab
tab sex

*****Ethnicity - main groups
///(NB this makes some assumptions i.e. British is white European, and does not include mixed, Chinese or other Asian)
gen  ethnic=n_21000_0_0
recode ethnic 1001=1 1002=1 1003=1 3=2 3001=2 3002=2 3003=2 4=3 4001=3 4002=3 4003=3 2=4 2001=4 2002=4 2003=4 2004=4 3004=4 5=4 6=4 -1=. -3=.
lab var ethnic "Ethnicity: main groups"
lab def ethniclab 1"White European" 2"South Asian" 3"African Caribbean" 4"Mixed or other"
lab val ethnic ethniclab
tab ethnic, mis 

*****Ethnicity - further sub-divided into South Asian or African Caribbean vs. European or other
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
tab dm_gdmonly_sr_bl

*****Age at diabetes diagnosis
gen dm_agediag_sr_bl=n_2976_0_0
lab var dm_agediag_sr_bl "Age diabetes diagnosed by doctor"
replace dm_agediag_sr_bl=. if dm_agediag<0
sum dm_agediag_sr_bl

********************************************************************************************************************
************************************Touchscreen self-report data: MEDICATIONS
*****Current insulin receipt
gen dm_drug_ins_men=0
replace dm_drug_ins_men=1 if n_6177_0_0==3|n_6177_0_1==3|n_6177_0_2==3
replace dm_drug_ins_men=. if n_6177_0_0==.|n_6177_0_0==-3|n_6177_0_0==-1
tab dm_drug_ins_men, mis
gen dm_drug_ins_women=0
replace dm_drug_ins_women=1 if n_6153_0_0==3|n_6153_0_1==3|n_6153_0_2==3
replace dm_drug_ins_women=. if n_6153_0_0==.|n_6153_0_0==-3|n_6153_0_0==-1
tab dm_drug_ins_women, mis
gen dm_drug_ins_bl_sr=.
replace dm_drug_ins_bl_sr=0 if dm_drug_ins_men==0|dm_drug_ins_women==0
replace dm_drug_ins_bl_sr=1 if dm_drug_ins_men==1|dm_drug_ins_women==1
tab dm_drug_ins_bl_sr, mis
lab var dm_drug_ins_bl_sr "On insulin"
labe def dm_drug_ins_bl_srlab 0"No" 1"Yes"
lab val dm_drug_ins_bl_sr dm_drug_ins_bl_srlab
tab dm_drug_ins_bl_sr
drop dm_drug_ins_men dm_drug_ins_women

*****Insulin receipt within 12 months of diagnosis
gen dm_insat1yr=n_2986_0_0 
recode dm_insat1yr -3=. -1=.
lab var dm_insat1yr "Insulin started within 1 yr of diagnosis"
lab def dm_insat1yrlab 0"No" 1"Yes" 
lab val dm_insat1yr dm_insat1yrlab
tab dm_insat1yr

********************************************************************************************************************
************************************Nurse interview self-report data
*****Non-type-specific self-report of diabetes + age of non-type-specific diabetes - from nurse interview 
gen dm_alldm_ni_bl=.
gen dm_agediag_alldm_ni_bl=.
forvalues i=0/28 {
replace dm_alldm_ni_bl=1 if n_20002_0_`i'==1220
replace dm_agediag_alldm_ni_bl= n_20009_0_`i' if n_20002_0_`i'==1220
}

lab var dm_alldm_ni_bl "Diabetes non-specified, baseline nurse interview"
lab def dm_alldm_ni_bllab 1"Diabetes present"
lab val dm_alldm_ni_bl dm_alldm_ni_bllab
lab var dm_agediag_alldm_ni_bl "Age at diagnosis non-specified diabetes, baseline nurse interview"

*****Gestational diabetes self-report + age of gestational diabetes - from nurse interview
gen dm_gdm_ni_bl=.
gen dm_agediag_gdm_ni_bl=.
forvalues i=0/28 {
replace dm_gdm_ni_bl=1 if n_20002_0_`i'==1221
replace dm_agediag_gdm_ni_bl= n_20009_0_`i' if n_20002_0_`i'==1221
}

lab var dm_gdm_ni_bl "GDM, baseline nurse interview"
lab def dm_gdm_ni_bllab 1"GDM present"
lab val dm_gdm_ni_bl dm_gdm_ni_bllab
lab var dm_agediag_gdm_ni_bl"Age at GDM diagnosis, baseline nurse interview"

*****Type 1 diabetes self-report + age of type 1 diabetes - from nurse interview
gen dm_t1dm_ni_bl=.
gen dm_agediag_t1dm_ni_bl=.
forvalues i=0/28 {
replace dm_t1dm_ni_bl=1 if n_20002_0_`i'==1222
replace dm_agediag_t1dm_ni_bl= n_20009_0_`i' if n_20002_0_`i'==1222
}

tab dm_t1dm_ni_bl
lab var dm_t1dm_ni_bl "T1DM, baseline nurse interview"
lab def dm_t1dm_ni_bllabe 1"T1DM present"
lab val dm_t1dm_ni_bl dm_t1dm_ni_bllabe
lab var dm_agediag_t1dm_ni_bl "Age at T1DM diagnosis, baseline nurse interview"

*****Type 2 diabetes self-report + age of type 2 diabetes  - from nurse interview
gen dm_t2dm_ni_bl=.
gen dm_agediag_t2dm_ni_bl=.
forvalues i=0/28 {
replace dm_t2dm_ni_bl=1 if n_20002_0_`i'==1223
replace dm_agediag_t2dm_ni_bl= n_20009_0_`i' if n_20002_0_`i'==1223
}

tab dm_t2dm_ni_bl
lab var dm_t2dm_ni_bl "T2DM, baseline nurse interview"
lab def dm_t2dm_ni_bllab 1"T2DM present"
lab val dm_t2dm_ni_bl dm_t2dm_ni_bllab
lab var dm_agediag_t2dm_ni_bl "Age at T2DM diagnosis, baseline nurse interview"

*****Non-type-specific / gestational/ type 1/ type 2 diabetes self-report  - from nurse interview
gen dm_anynsgt1t2_ni_bl=.
replace dm_anynsgt1t2_ni_bl=1 if dm_alldm_ni_bl==1|dm_gdm_ni_bl==1|dm_t1dm_ni_bl==1|dm_t2dm_ni_bl==1
lab var dm_anynsgt1t2_ni_bl"Nurse interview: non-specific/ GDM/ T1DM/ T2DM reported"
tab dm_anynsgt1t2_ni_bl

*****Age at diabetes (all types) diagnosis - touchscreen or nurse interview (nurse interview supercedes)
gen dm_agedm_ts_or_ni= dm_agediag_alldm_ni_bl
replace dm_agedm_ts_or_ni=dm_agediag_sr_bl if dm_agediag_alldm_ni_bl==. & dm_agediag_t1dm_ni_bl==. & dm_agediag_t2dm_ni_bl==. & dm_gdmonly_sr_bl!=1
replace dm_agedm_ts_or_ni=dm_agediag_t1dm_ni_bl if dm_t1dm_ni_bl==1
replace dm_agedm_ts_or_ni=dm_agediag_t2dm_ni_bl if dm_t2dm_ni_bl==1
replace dm_agedm_ts_or_ni=. if dm_agediag_sr_bl==. &  dm_agediag_alldm_ni_bl==. & dm_agediag_t1dm_ni_bl==. & dm_agediag_t2dm_ni_bl==. 
replace dm_agedm_ts_or_ni=. if dm_agedm_ts_or_ni<0
sum dm_agedm_ts_or_ni

********************************************************************************************************************
************************************Nurse interview self-report data: MEDICATIONS - see further explanation below for how these were derived - if interested only!
*****Current insulin receipt
gen dm_drug_ins_ni_bl=.
forvalues i=0/47 {
replace dm_drug_ins_ni_bl=1 if n_20003_0_`i'==1140883066
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

*
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

*
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

*
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

*
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

*
lab var dm_drug_glitaz_ni_bl "Taking glitazone, baseline nurse interview"
recode dm_drug_glitaz_ni_bl .=0
lab def dm_drug_glitaz_ni_bllab 0"No glitazone" 1"On glitazone"
lab val dm_drug_glitaz_ni_bl dm_drug_glitaz_ni_bllab
tab dm_drug_glitaz_ni_bl
///Non-metformin OADs (including above 4 drug classes)
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

