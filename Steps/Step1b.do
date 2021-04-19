*Step1b: create combined variable for each outcome type


* dummy lists
local start "start"
local empty "NO_CODES"

rename UsePrimaryCare Use
rename PrevalentIncident Pre

foreach field of varlist ICD9codes ICD10codes Death4000140002 Cancer Selfreport* ProceduresOPCS* Read* Use Pre{
	* loops over each type of field list
	local all_`field' "start"
	* creates a combined list with a dummy start value
	foreach v of local output{
		* loops over all outcomes requested, adding their values to all_field
		local all_`field': list all_`field' |`v'_`field'  
	}
	* clean up lists
	local all_`field': list clean all_`field' 
	*remove start
	local all_`field': list all_`field' - start


	*remove "NO CODES" if there are other values
	local value1: list empty in all_`field'
	local value2: list empty === all_`field'
	if (`value1'==1 & `value2'==0){
		local all_`field': list all_`field' - empty 
	}
}

rename Use UsePrimaryCare
rename Pre PrevalentIncident 

* create time to event output list

macro drop _output_Use
foreach out of local output{
	if ``out'_Pre'==1{
		local output_Pre "`output_Pre' `out'"
	}
}
local output_Pre: list clean output_Pre
local output_Pre: list uniq output_Pre

* create Primary care set

* create time to event output list
macro drop _output_Use
foreach out of local output{
	if ``out'_Use'==1{
		local output_Use "`output_Use' `out'"
	}
}

local output_Use: list clean output_Use
local output_Use: list uniq output_Use
