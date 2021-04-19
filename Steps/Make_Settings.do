********** Make settings file from within Stata*********
** Author: Amy Mason
** Date: Jan 2021
** inputs : excel instruction sheet bespoke_outcome_v2.1.xls
** outputs: settings.do file for running stata outcomes algorithm in code directory (
** USER INPUT

* CODE to run in slurm

* stata -b do /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/Steps/Make_Settings.do  "/rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/bespoke_outcome_v2.1.xls"

* CODE to run in stata
* do /rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/Steps/Make_Settings.do  "/rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/Code/Stata_outcomes/bespoke_outcome_v2.1.xls"
args input1

* clear stata
set more off 
clear all
macro drop set*

* import instruction sheet
import excel using `input1', sheet("Settings") firstrow allstring clear

* create local variables
local set_outputfolder1=Value[2]
local set_outputname1 = Value[1]
local set_instructionfile1 = Value[4]
local set_LOCATION1 = Value[3]
local set_SETTING = Value[5]

* create list of variables
keep Variable Includethis
keep if Includethis!=""
if Variable[1]=="diabetes" {
local set_out_diabetes1=1
}
else{
local set_out_diabetes1=0
}

drop if Variable=="diabetes"
levelsof Variable, local(set_outcome1) clean

* make Settings.do
di  "`set_SETTING'.do"
file open dofile using "`set_SETTING'.do", write replace
* TEXT OF FILE
file write dofile " // This is an automatically genetated Settings file for running Master.do created with Make_Settings" _n
file write dofile "// Please read the readme file or the header of Master.do for more info" _n
file write dofile  "clear all" _n 
file write dofile	"macro drop _all" _n 
file write dofile	"set more off " _n 
file write dofile 	"local outfilename `set_outputname1'" _n 
file write dofile 	"local outfiles `set_outputfolder1'" _n 
file write dofile 	`" local output_org  "`set_outcome1'" "' _n  
file write dofile	"local instructionfile `set_instructionfile1' " _n 
file write dofile	"local LOCATION `set_LOCATION1' " _n 
file write dofile	"local out_diabetes `set_out_diabetes1' " _n 
file write dofile	"cd `set_LOCATION1' " _n 
file write dofile	"qui include Master.do " _n

file close dofile

end