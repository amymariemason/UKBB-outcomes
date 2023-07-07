 // This is an automatically genetated Settings file for running Master.do created with Make_Settings
// Please read the readme file or the header of Master.do for more info
clear all
macro drop _all
set more off 
local outfilename CVD_Oct22
local outfiles /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/outcome_requests/
 local output_org  "aa aaa af ast cad_int ckd dvt haem hf ischtia pe pvd_simple taa tia ukb_ich ukb_sah ukb_stri ukb_stroke vte" 
local instructionfile /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/Code/Stata_outcomes/bespoke_outcome_v2.1.xls 
local LOCATION /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/Code/Stata_outcomes/Steps/ 
local out_diabetes 0 
cd /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/Code/Stata_outcomes/Steps/ 
noi include Master.do 
