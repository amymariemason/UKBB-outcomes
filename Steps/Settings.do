 // This is an automatically genetated Settings file for running Master.do created with Make_Settings
// Please read the readme file or the header of Master.do for more info
clear all
macro drop _all
set more off 
local outfilename femur_fracture
local outfiles /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/outcome_requests
 local output_org  "fof" 
local instructionfile /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/bespoke_outcome_v2.1.xls 
local LOCATION /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/Steps 
local out_diabetes 0 
cd /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/Steps 
qui include Master.do 
