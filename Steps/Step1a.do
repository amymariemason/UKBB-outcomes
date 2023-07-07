**** STEP 1a: create local macros containing variables to match from csv instruction file
* input used: instructionfile, 

local loop_count 1

foreach v of local output_org{
	import excel using `instructionfile', sheet("Definitions")  firstrow allstring clear
* check there are instructions for the requested file
* if there are not, or they are not unique reports this and does not create an output for them
	gen check =1 if  Suggestedvariablename=="`v'"
	summ check
	capture assert r(sum)==1
	if _rc!=0 {
		noi display as error "ERROR: no instructions matching `v' in csv file"
		error 498
		}
	keep if check==1
	capture assert _N==1
	if _rc!=0 {
		noi display as error "ERROR: multiple instructions matching `v' in csv file"
		error 498
	}
	noi di as text " `v' in instruction file"
	* move loop count on
	if `loop_count'!=1{
		local output_add `v'
		local output "`output' `output_add'"
	}
	if `loop_count'==1{
		local output `v'
		local loop_count 2
	}

	drop check

	* create the name values
	noi di "Creating variables for:"
	noi levelsof  Outcomename, local("`v'_name")
	gen name2= Outcomename + " excluding self report"
	levelsof name2, local("`v'_name_nSR")
	gen name3= Outcomename + " including primary care"
	levelsof name3, local("`v'_name_PC")

	* subset only to needed variables
	keep ICD9codes ICD10codes Selfreport* ProceduresOPCS* Death Cancer Use Match Read* Prevalent
	rename *PrimaryCareCodes *

	* loop round all report fields to create macro lists of the values wanted
	foreach field of varlist ICD9codes ICD10codes Death4000140002 Selfreport* ProceduresOPCS* Cancer{
		di "`field'"
		preserve
		if inlist(`field', "-", ""){
			local `v'_`field' `" "NO_CODES" "'
		}
		if !inlist(`field', "-", ""){ 
			replace `field' = subinstr(`field' , " ", "",.)
			split `field', p(",")
								drop `field'
			keep `field'*
			gen ID=1
			reshape long `field', i(ID) j(count)
			drop if inlist(`field', "-", "")

			* turn values into regular expressions for partial matching
			replace `field'=upper(`field')
			replace `field' = subinstr(`field' , ".X", "[0-9]*",.)
			replace `field'=subinstr(`field', ".", "",.)
			replace `field'= "^"+`field'+"$"
			levelsof `field', local("`v'_`field'") 
		}
		restore
	}	
* Create Prevalent report variable 
	if (Prevalent!="YES"){
		noi di as text "Prevalence/Incidence reporting not required for `v'"
		noi di as text "If this is an error, review control file & ensure you have written YES in the Prevalence/Incidence Column"
		local `v'_Pre 0
	}

	if (Prevalent=="YES"){
		local `v'_Pre 1
	}

* Create the primary care match set

	* First check if primary care data is required
	if (Use!="YES"){
		noi di as text "Primary Care data not required for `v'"
		noi di as text "If this is an error, review control file & ensure you have written YES in the Use Primary Care Column"
		local `v'_Use 0
		local `v'_ReadV2 `" "NO_CODES" "'
		local `v'_ReadV3 `" "NO_CODES" "'
	}

	if (Use=="YES"){
		local `v'_Use 1
		* Primary care requires keeping event dates due to the reduced censor dates on many participants
		local `v'_Pre 1
		* Check instruction present if required       
		if (Match!="YES"&(inlist(ReadV3,"-", "")&inlist(ReadV2,"-", ""))){  
			noi display as error "ERROR: Primary care data instruction missing for `v'"
			error 498 
		}         
		* Otherwise, if match ICD10 is selected, match ICD10 HES codes to Read codes using the UK Biobank matching  
		if (Match=="YES"){
			* Check instruction is unambigeous.
			if (!inlist(ReadV3,"-", "")|!inlist(ReadV2,"-", "")){
			noi display as error "ERROR: Ambigeous primary care instructions matching `v' in csv file"
			noi display as error "Check that only one of Match ICD10 or Read Codes V2&V3 is used"
			error 498 
			}
			preserve	
			* Read codes V2       
			import excel using `instructionfile', sheet("Read_V2") firstrow allstring clear
			* match ICD10 codes to ReadV2 codes 
			gen readmatch=0
			foreach icd of local `v'_ICD10codes{				
				replace readmatch =1 if regexm(icd10_code,"`icd'")			
			}
			keep if readmatch==1
			drop readmatch
			* create regular expressions for the chosen codes
			gen readkeep=read_code	
			replace readkeep = subinstr(readkeep , ".", "[a-zA-Z0-9]",.)
			replace readkeep= "^"+readkeep+"$"
			if (_N>0) {
				levelsof readkeep, local("`v'_ReadV2") 
			}
			if (_N==0){
				local `v'_ReadV2  `" "NO_CODES" "'
			}

			* Read codes V3      
			import excel using `instructionfile', sheet("Read_V3") firstrow allstring clear
			* match ICD10 codes to ReadV2 codes 
			gen readmatch=0
			foreach icd of local `v'_ICD10codes{				
				replace readmatch =1 if regexm(icd10_code,"`icd'")			
			}
			keep if readmatch==1
			drop readmatch
			* create regular expressions for the chosen codes
			gen readkeep=read_code	
			replace readkeep = subinstr(readkeep , ".", "[a-zA-Z0-9]",.)
			replace readkeep= "^"+readkeep+"$"
			if (_N>0){
				levelsof readkeep, local("`v'_ReadV3") 
			}
			if (_N==0){
				local `v'_ReadV3  `" "NO_CODES" "'
			}
			restore	
		}
		if (Match!="YES"){
		* Otherwise take read code values from fields
			foreach field of varlist ReadV2 ReadV3{
				preserve
				if inlist(`field', "-", ""){
					local `v'_`field' `" "NO_CODES" "'
				}
				if !inlist(`field', "-", ""){ 
					replace `field' = subinstr(`field' , " ", "",.)
					split `field', p(",")
					drop `field'
					keep `field'*
					gen ID=1
					reshape long `field', i(ID) j(count)
					drop if inlist(`field', "-", "")
					* turn values into regular expressions for partial matching
					replace `field'=upper(`field')
					replace `field' = subinstr(`field' , ".X", "[a-zA-Z0-9]*",.)
					replace `field'=subinstr(`field', ".", "",.)
					replace `field'= "^"+`field'+"$"
					levelsof `field', local("`v'_`field'") 	
				}
				restore
			}
		}
	}
}
	


