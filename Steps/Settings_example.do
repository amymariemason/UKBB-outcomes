clear all
macro drop _all
set more off 
local outfilename test_11Jan
local outfiles /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/outcome_requests
local output_org "af"
local instructionfile /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/bespoke_outcome_v2.1.xls
local LOCATION /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/Steps
* include diabetes variables *
local out_diabetes 0 
cd `LOCATION'
include Master.do
