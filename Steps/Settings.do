 // This is an automatically genetated Settings file for running Master.do created with Make_Settings
// Please read the readme file or the header of Master.do for more info
clear all
macro drop _all
set more off 
local outfilename maria_mi
local outfiles /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/outcome_requests/
 local output_org  "ukb_mi maria_mi" 
local instructionfile /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/Code/Stata_outcomes/bespoke_outcome_v2.1.xls 
local LOCATION /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/Code/Stata_outcomes/Steps/ 
local out_diabetes 0 
cd /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/Code/Stata_outcomes/Steps/ 
include Master.do 
