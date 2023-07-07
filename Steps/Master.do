***********************************************************
* Add multiple binary UKBB outcomes
***********************************************************
* Author: Amy Mason 
* Report bugs to: am2609@medschl.cam.ac.uk 
* Date: Updated Oct 2022
************************************************

* Input: 
** inputfile: stata dta file with input fields: must contain n_eid variable and fields: 
** ****    20002,20004, 6150, (40001, 40002 -> have been moved to seperate death files) 
** ****	   6152, 6153, 6177, 54, 53, 33, 31  [NB: 33 Date of birth is not available in general] 
** ****    20008, 20010, 3627, 3894, 2966, 4056, 4012, 4022  (if doing time to event data)
** *****   21000, 4041, 2976, 6177, 6153, 2986, 20002, 20003, 20009 (if doing diabetes)

** instructionfile: csv file containing instructions for each outcome, should be contained in the UKBB drive & called bespoke_outcome_current.csv
** **** NOTE: this program matches those outcomes as an OR check. Anyone who matches in any field will be marked case, all others control. 

** output_org: replace this text with a space seperated list of the outcomes you want to generate

** HES: Biobank HES outcomes dataset with n_eid linked to inputfile. must contain n_eid, diag_icd9, diag_icd10, oper4

** withdrawn: this is a stata file with a list of all the people who have withdrawn consent. It should be on the Biobank drive

** outputfilename: replace this text with the suggested variable name of the variable you want to add
*
* Output:
*  outputfilename_binary : this contains any binary outcomes created
** **** All outcomes will be given up to three forms: 	{outcome} 0 = control 1= case  
** **** 						{outcome}_nSR 0 = control & self-reported 1= case, excluding self report data
** ****							{outcome}_pri 0 = control, 1 = case 2 = excluded from primary care analysis
*  outputfilename_pi : this contains any prevalence and incident data
** **** All outcomes will be given as a pair (P/I variable & a date) for each column type filled in on instructions sheet: HES, Death, Primary, Cancer, Self report & All
** ****							{outcome}_{type} 0 = control 1 = incident event 2 = prevalent event 
** ****							{outcome}_{type}_date earliest date event occurs
* 
* outputfilename : merge of both files
*********************************************

******************************************************
* COMMON USER INPUTS moved to settings.do 
******************************************************

**********************************************************

* create log

********
cap log close
local time_string = "$S_DATE"+"_" +"$S_TIME"
local time_string = subinstr("`time_string'", ":", "_", .)
local time_string = subinstr("`time_string'", " ", "_", .)
local logname ="`outfiles'"+"/"+"`outfilename'"+"`time_string'"+".log"
log using "`logname'", replace
noi di "Run on $S_DATE $S_TIME"



************************************************************
* RARELY CHANGED USER INPUTS GO HERE 
***********************************************************




* CREATED DATA FILES (see read me)
* stata dta file extracted from UKBioBank
local inputfile /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/Input/allfields_PC_20210825.dta

* RAW DATA FILES

* locations of the HES outcomes 

local HES `""/rds/project/asb38/rds-asb38-ceu-ukbiobank/phenotype/P7439/pre_qc_data/HES/hesin_20230510.txt""'
local HES_diag `""/rds/project/asb38/rds-asb38-ceu-ukbiobank/phenotype/P7439/pre_qc_data/HES/hesin_diag_20230510.txt""'
local HES_oper `""/rds/project/asb38/rds-asb38-ceu-ukbiobank/phenotype/P7439/pre_qc_data/HES/hesin_oper_20230510.txt""'

* location of primary care data
local PRIMARY `""/rds/project/asb38/rds-asb38-ceu-ukbiobank/phenotype/P7439/pre_qc_data/PrimaryCare/gp_clinical_20230510.txt""'
local PRIMARY_REG `""/rds/project/asb38/rds-asb38-ceu-ukbiobank/phenotype/P7439/pre_qc_data/PrimaryCare/gp_registrations_20230510.txt""'

* withdrawal location
local WITHDRAWN `""/rds/project/asb38/rds-asb38-ceu-ukbiobank/phenotype/P7439/pre_qc_data/Withdrawals/w7439_2023-04-25.csv""'


* location of additional death data
local DEATH_add_cause `""/rds/project/asb38/rds-asb38-ceu-ukbiobank/phenotype/P7439/pre_qc_data/Death/death_cause_20230510.txt""'
local DEATH_add_date `""/rds/project/asb38/rds-asb38-ceu-ukbiobank/phenotype/P7439/pre_qc_data/Death/death_20230510.txt""'


* date of extraction of data from biobank (used as censoring endpoint for controls)
* see: http://biobank.ndph.ox.ac.uk/showcase/exinfo.cgi?src=Data_providers_and_dates* NB: I am ignoring the different enddate for primary care for England vision, as they are censored from the final dataset anyway. Endpoints are applied based on country of recruitment.  
* enddates are censored to HES (if hes data only used), Prim (if primary data used), Cancer (if running cancer specific algorithm)
local HES_END_ENG "31Oct2022"
local HES_END_SCOT "31July2021"
local HES_END_WALES "28Feb2018"
local PRIM_END_SCOT "31Mar2017"
local PRIM_END_WALES "31Aug2017"
local PRIM_END_ENG "31May2016"
local CANCER_ENG "31Dec2020"
local CANCER_SCOT "30Nov2021"
local DEATH_ENG "30Nov2022"
local DEATH_SCOT "30Nov2022"

* what censoring to apply to controls; options = "HES", "PRIMARY", "CANCER"
local CENSORTYPE "HES"


****************************************************
* NO USER INPUT NEEDED BEYOND THIS POINT
****************************************************



* create locations of temporary files
tempfile temp_HES_matched 
tempfile temp_PC_matched 
tempfile temp_proc_matched 
tempfile temp_death_matched 
tempfile temp_SR_matched 
tempfile temp_HES 
tempfile temp_HES2 
tempfile temp_date 
tempfile temp_oper 
tempfile temp_withdrawn 
tempfile temp_primary_censor 



*****************************************
* Warmup Code


* move to location of programs 
cd `LOCATION'






* Alternative input for using test file
* location of test file
* comment out next two lines if not testing program.
*local TEST /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/Test
*qui include test.do


***** STEP 1: SETUP *****

	*step1a: create all the variables pulled from the table, including pulling in primary care code lists
	qui include Step1a.do

	* Step1b: create superset of all these variables
	qui include Step1b.do



	*make withdrawn list into a stata data set so can merge it later
	qui import delimited `WITHDRAWN', clear
	qui rename v1 eid
	qui save `temp_withdrawn', replace



*Step1c: create a temp cut down HES set containing only matches to the superset
qui include Step1c.do
	
***** Note: these next two steps require loading large files, so are optional to speed up overall algorithm.
***** If program is running slow consider seperating out requests requiring primary care or time to event and running seperately

* Step 1d (If prevalence/incidence wanted, add dates to the diagnosis set)
** is time to event data wanted for any variable?
qui local wanted 1
local Pre_wanted : list wanted in all_Pre
if (`Pre_wanted'==1){
qui include Step1d.do
}

* Step1e: (If PC selected for any variable) create a temp cut down primary care set containing only matches to the superset
** is Primary Care wanted for any variables?
qui local PC_wanted : list wanted in all_Use
** if so run Step 1e 
if (`PC_wanted'==1){
qui include Step1e.do


* Step1f: makes accurate censor list for primary care registrations
qui include Step1f.do
}
*NB: due to different censor times, time to event is essential if Primary care is wanted. 



***** STEP 2: Match HES data *****

*Step 2a: Match HES data to create binary variable NB:  if prevalence/incidence also creates event of first date variable 
qui include Step2a.do 

* Step 2b: Match proceedure data
qui include Step2b.do


*STEP 3: Match Death data & self reports

* Step3a: Death data
* NB: the additional  file manages the additional death data that came in after the last major extract. 
* If your death fields in the main input file are up to date, this is not needed - uncomment step3 and use that instead
* If your death data is in both the main file (40000,40001,40002) AND a seperate file, use step3a_additional
*qui include Step3a.do 
* qui include Step3a_additional
qui include Step3a_alternate.do

local empty "NO_CODES"
local cancercheck: list empty === all_Selfreport20001
* 1 means true ie do not check for cancer specifically
if (`cancercheck'==1){
* Self-report data
noi include Step3b.do
}
else{
* If cancer specific data needed
	noi include Step3b_cancer.do
	noi include Step3c_cancer.do
}

* Diabetes specific data
local diabetescheck: list wanted == out_diabetes
if (`diabetescheck'==1){
	qui include Diabetes/Master.do
}

****** STEP 4: Match Primary Care data 
if (`PC_wanted'==1){
qui include Step4a.do
}

****** STEP 5:  Combine results

*Step 5a: Combine all reports for binary outcomes; create outfile of all binary outcomes

qui include Step5a.do


*Step 5b: Add Primary Care data, & form primary care subset
if (`PC_wanted'==1){
qui include Step5b.do
}

qui log close
