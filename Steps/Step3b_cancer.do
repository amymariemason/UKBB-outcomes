* Create selt report variables
** NB careful with dates and multiple reports here!
** CONCEPT: rewrite this so that it opens the set for each disease/timepoint type rather than looping? Then all the merging ever to get back together?
** CONCEPT2: rewrite to output: "eid, event, date, place of report" for each event then sort, reshape and merge?

use `inputfile', clear
gen baseline = ts_53_0_0
format baseline %td
gen baseline_year = ts_53_0_0/365.25 + 1960
gen baseline_age = (ts_53_0_0-n_33_0_0)/365.25

* The self report variables are:	20002,	20004,	6150,					6152 ,			6153 & 6177
* The matching time variables are: 	20008,	20010,	3627 & 3894 & 2966 & 4056, 	
*																			4012 & 4022 & 3786 & 3992 & 3761,		
*																							53 (survey date)


* list all self report variables to check 
local selfreports 20001 20002 20004 6150 6152 6153 6177
foreach srnum of local selfreports{
	capture confirm variable n_`srnum'_0_0
	if _rc!=0 {
		noi di  as error "ERROR: variable `srnum' missing"
		error 498
    }
 }
 
* NB: self report in first report _0 MUST be prevalent by definition
* However self report in later dates -> may be incident; need to treat seperately. 

* count number of surveys & find the midpoints between each survey and last recorded survey response
*i.e. midpoint_m is the midpoint between survey date of survey m (if that date exists) and the last survey date recorded
ds ts_53_*_0
macro drop _survey
local survey :  word count `r(varlist)'
local survey =  `survey'-1
* find survey midpoint dates (useful later to avoid having to recalculate them over and over
gen midpoint_0 = ts_53_0
format midpoint_0 %td
forval m=1(1)`survey' {
gen midpoint_`m' =(ts_53_`m'+ ts_53_0)/2 if ts_53_`m'!=.
format midpoint_`m' %td
local tempval = `m'-1
	forval k=1(1)`tempval'{
	replace midpoint_`m'= (ts_53_`m'+ ts_53_`k')/2 if ts_53_`k'!=. & ts_53_`m'_0!=. & midpoint_`m'< (ts_53_`m'+ ts_53_`k')/2
	
	}
 }
 
	
* loop rounds each required output, checking the self report variables
foreach out of local output{
* This identifies individuals with any report, ignores time			
	gen SRmatch_`out'=0				
	*loop rounds all self report variables
	foreach srnum of local selfreports{
		* loop round all specific values for that self report variable
		foreach sr of local `out'_Selfreport`srnum'{
		*if non empty values in the specification file, this finds the people who have that code
			foreach i of varlist n_`srnum'*{
				replace SRmatch_`out'=1 if regexm(string(`i'),"`sr'")
			}
		}
	}
}


if `Pre_wanted'==1{
	* check self report age files exist if pre/primary care data wanted
	local selfreports 20006 20008 20010 3627 3894 2966 4056 4012 4022 3786 3992 3761 33 53
	foreach srnum of local selfreports{
	capture confirm variable n_`srnum'_0_0
	if _rc!=0 {
		noi di  as error "ERROR: variable `srnum' missing"
			error 498
		}
	}
}

* This identifies first date of an event	
foreach out of local output{
	* create a time report variable for SR reports
	gen SRdate_`out'= .
	format SRdate_`out' %td
	gen SR_inc_date_`out'= .
	format SR_inc_date_`out' %td
	* some variables are reported in year fractions - use below variable to find earliest and then convert at end
	gen SRyear_`out'=. 
	gen SR_inc_year_`out'=. 
	* some variables reported as ages - use below var to find approx date
	gen SRage_`out' = .
	gen SR_inc_age_`out' = .
}		

	* take each SR individually
	* 1) variables that have date variable with point by point matching
	* these dates are given in fractional calender years	
	* loop over each survey & output
foreach out of local output{
if ``out'_Pre'==1{
	forval m=0(1)`survey' {
		* create temporary midpoint year from mindpoint date
		gen tempyear = midpoint_`m'/365.25 + 1960
		* 20002 (date variable is 20008)
		ds n_20002_`m'*
		macro drop _count
		local count :  word count `r(varlist)'
		local count =  `count'-1
		* loop over the records in the survey
		* select matching date for events and compare to current earliest recorded event
		forval i= 0(1)`count'{
			foreach code of local `out'_Selfreport20002{
				replace SRmatch_`out'=1 if regexm(string(n_20002_`m'_`i'),"`code'")	
				replace SRyear_`out'=n_20008_`m'_`i' if regexm(string(n_20002_`m'_`i'),"`code'") & !(n_20008_`m'_`i'==.|n_20008_`m'_`i'==-1)& n_20008_`m'_`i' < SRyear_`out'
				replace SR_inc_year_`out'=n_20008_`m'_`i' if regexm(string(n_20002_`m'_`i'),"`code'") & !(n_20008_`m'_`i'==.|n_20008_`m'_`i'==-1) & n_20008_`m'_`i' < SR_inc_year_`out' & n_20008_`m'_`i'>= baseline_year & `m'>0
				* if match present but date missing, replace with midpoint of last two surveys (tempyear)
				replace SRyear_`out'= tempyear if (n_20008_`m'_`i'==.|n_20008_`m'_`i'==-1) & regexm(string(n_20002_`m'_`i'),"`code'") & tempyear < SRyear_`out'
				* ditto for inc event IFF m>0
				replace SR_inc_year_`out'= tempyear if regexm(string(n_20002_`m'_`i'),"`code'") & (n_20008_`m'_`i'==.|n_20008_`m'_`i'==-1) & tempyear < SR_inc_year_`out' & tempyear > baseline_year &`m'>0
			}
		}
		* 20004 (date variable is 20010)
		ds n_20004_`m'*
		macro drop _count
		local count :  word count `r(varlist)'
		local count =  `count'-1
		* loop over the records in the survey
		* select matching date for events and compare to current earliest recorded event
		forval i= 0(1)`count'{
			foreach code of local `out'_Selfreport20004{
				replace SRmatch_`out'=1 if regexm(string(n_20004_`m'_`i'),"`code'")	
				replace SRyear_`out'=n_20010_`m'_`i' if regexm(string(n_20004_`m'_`i'),"`code'") & !(n_20010_`m'_`i'==.|n_20010_`m'_`i'==-1) & n_20010_`m'_`i' < SRyear_`out'
				replace SR_inc_year_`out'=n_20010_`m'_`i' if regexm(string(n_20004_`m'_`i'),"`code'") & !(n_20010_`m'_`i'==.|n_20010_`m'_`i'==-1)& n_20010_`m'_`i' < SR_inc_year_`out' & n_20010_`m'_`i' >= baseline_year & `m'>0
				* if match present but date missing, replace with midpoint of last two surveys
				replace SRyear_`out'=tempyear if regexm(string(n_20004_`m'_`i'),"`code'") & (n_20010_`m'_`i'==.|n_20010_`m'_`i'==-1) & tempyear < SRyear_`out'
				replace SR_inc_year_`out'= tempyear if regexm(string(n_20004_`m'_`i'),"`code'") & (n_20010_`m'_`i'==.|n_20010_`m'_`i'==-1) & tempyear < SR_inc_year_`out' & tempyear > baseline_year &`m'>0

			}
		}
		
		* 20001 (date variable is 20006)
		ds n_20001_`m'*
		macro drop _count
		local count :  word count `r(varlist)'
		local count =  `count'-1
		* loop over the records in the survey
		* select matching date for events and compare to current earliest recorded event
		forval i= 0(1)`count'{
			foreach code of local `out'_Selfreport20001{
				replace SRmatch_`out'=1 if regexm(string(n_20001_`m'_`i'),"`code'")	
				replace SRyear_`out'=n_20006_`m'_`i' if regexm(string(n_20001_`m'_`i'),"`code'") & !(n_20006_`m'_`i'==.|n_20006_`m'_`i'==-1) & n_20006_`m'_`i' < SRyear_`out'
				replace SR_inc_year_`out'=n_20006_`m'_`i' if regexm(string(n_20001_`m'_`i'),"`code'") & !(n_20006_`m'_`i'==.|n_20006_`m'_`i'==-1) & n_20006_`m'_`i' < SR_inc_year_`out' & n_20006_`m'_`i' >= baseline_year & `m'>0
				* if match present but date missing, replace with midpoint of last two surveys
				replace SRyear_`out'=tempyear if regexm(string(n_20001_`m'_`i'),"`code'") &(n_20006_`m'_`i'==.|n_20006_`m'_`i'==-1)& tempyear < SRyear_`out'
				replace SR_inc_year_`out'= tempyear if regexm(string(n_20001_`m'_`i'),"`code'") & (n_20006_`m'_`i'==.|n_20006_`m'_`i'==-1) & tempyear < SR_inc_year_`out' & tempyear > baseline_year &`m'>0

			}
		}
		
		*convert SRyear and compare to earliest SRdate_`out
		gen tempdate = (SRyear_`out' -1960)*365.25
		format tempdate %td
		replace SRdate_`out' = tempdate if tempdate<SRdate_`out'
		
		replace tempdate = (SR_inc_year_`out' -1960)*365.25
		format tempdate %td
		replace SR_inc_date_`out' = tempdate if tempdate<SR_inc_date_`out' 
		drop tempdate 
		drop tempyear	
	}	
}
}	

* 2) variables that have a date variable for each outcome
* these dates are only given as ages	
* loop over each survey & output
foreach out of local output{
if ``out'_Pre'==1{
	forval m=0(1)`survey' {

		* 6150 
		* Note 6150 only has two not three repeats, so without the if `m'<= `tempcount'{ loop, this throws an error
		ds n_6150_*_0
		macro drop _tempcount
		local tempcount :  word count `r(varlist)'
		local tempcount = `tempcount'-1
		if `m'<= `tempcount'{
			ds n_6150_`m'*
			macro drop _count
			local count :  word count `r(varlist)'
			local count =  `count'-1
			* loop over the records in the survey
			* select matching date for events and compare to current earliest recorded event
			forval i= 0(1)`count'{
				foreach code of local `out'_Selfreport6150{ 
					if "`code'"!="NO CODES"{
						*1	Heart attack : matches 3894
						if regexm("1","`code'"){
							replace SRmatch_`out'=1 if  (n_6150_`m'_`i'==1)
							gen tempage = n_3894_`m'_0 if  (n_6150_`m'_`i'==1) & n_3894_`m'_0 >=0
							replace SRage_`out'=tempage if tempage!=. & tempage < SRage_`out' & tempage >-1 & (n_6150_`m'_`i'==1)
							replace SR_inc_age_`out'=tempage if tempage!=. & tempage < SR_inc_age_`out' & tempage >-1 & tempage>= baseline_age & (n_6150_`m'_`i'==1)
							drop tempage
							* if age missing or not given, use midpoint of this survey and last survey
							replace SRdate_`out'= midpoint_`m' if  SRage_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SRdate_`out' & (n_6150_`m'_`i'==1)
							replace SR_inc_date_`out'= midpoint_`m' if  SR_inc_age_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SR_inc_date_`out' & midpoint_`m'> baseline & (n_6150_`m'_`i'==1) & `m'>0
						}
						*2	Angina : matches 3627
						if regexm("2","`code'"){
							replace SRmatch_`out'=1 if (n_6150_`m'_`i'==2)
							gen tempage = n_3627_`m'_0 if (n_6150_`m'_`i'==2) & n_3627_`m'_0 >=0
							replace SRage_`out'=tempage if tempage!=. & tempage < SRage_`out' & tempage >-1 &(n_6150_`m'_`i'==2)
							replace SR_inc_age_`out'=tempage if tempage!=. & tempage < SR_inc_age_`out' & tempage >-1 & tempage>= baseline_age &(n_6150_`m'_`i'==2)
							drop tempage
							* if age missing or not given, use midpoint of this survey and last survey
							replace SRdate_`out'= midpoint_`m' if  SRage_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SRdate_`out' &(n_6150_`m'_`i'==2)
							replace SR_inc_date_`out'= midpoint_`m' if  SR_inc_age_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SR_inc_date_`out' & midpoint_`m'> baseline &(n_6150_`m'_`i'==2) & `m'>0
						}				
						*3	Stroke: 4056
						if regexm("3","`code'"){
							replace SRmatch_`out'=1 if (n_6150_`m'_`i'==3)
							gen tempage = n_4056_`m'_0 if (n_6150_`m'_`i'==3) & n_4056_`m'_0 >=0
							replace SRage_`out'=tempage if tempage!=. & tempage < SRage_`out' & tempage >-1 & (n_6150_`m'_`i'==3)
							replace SR_inc_age_`out'=tempage if tempage!=. & tempage < SR_inc_age_`out' & tempage >-1 & tempage>= baseline_age & (n_6150_`m'_`i'==3)
							drop tempage
							* if age missing or not given, use midpoint of this survey and last survey
							replace SRdate_`out'= midpoint_`m' if  SRage_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SRdate_`out' & (n_6150_`m'_`i'==3)
							replace SR_inc_date_`out'= midpoint_`m' if  SR_inc_age_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SR_inc_date_`out' & midpoint_`m'> baseline & (n_6150_`m'_`i'==3) & `m'>0
						}	
						*4	High blood pressure : 2966
						if regexm("4","`code'"){
							replace SRmatch_`out'=1 if (n_6150_`m'_`i'==4)
							gen tempage = n_2966_`m'_0 if (n_6150_`m'_`i'==4) & n_2966_`m'_0 >=0
							replace SRage_`out'=tempage if tempage!=. & tempage < SRage_`out' & tempage >-1 & (n_6150_`m'_`i'==4)
							replace SR_inc_age_`out'=tempage if tempage!=. & tempage < SR_inc_age_`out' & tempage >-1 & tempage>= baseline_age & (n_6150_`m'_`i'==4)
							drop tempage
							* if age missing or not given, use midpoint of this survey and last survey
							replace SRdate_`out'= midpoint_`m' if  SRage_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SRdate_`out' & (n_6150_`m'_`i'==4)
							replace SR_inc_date_`out'= midpoint_`m' if  SR_inc_age_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SR_inc_date_`out' & midpoint_`m'> baseline & (n_6150_`m'_`i'==4) & `m'>0
						}	
					}
				}
			}
		}
		macro drop _tempcount	
		
		* 6152 
		ds n_6152_`m'*
		macro drop _count
		local count :  word count `r(varlist)'
		local count =  `count'-1
		* loop over the records in the survey
		* select matching date for events and compare to current earliest recorded event
		forval i= 0(1)`count'{
			* compare to each wanted code
			foreach code of local `out'_Selfreport6152{ 
				if "`code'"!="NO CODES"{
					*5	Blood clot in the leg (DVT) : 4012
					if regexm("5","`code'"){
						replace SRmatch_`out'=1 if (n_6152_`m'_`i'==5)
						gen tempage = n_4012_`m'_0  if  n_4012_`m'_0 >=0 & (n_6152_`m'_`i'==5)
						replace SRage_`out'=tempage if tempage!=. & tempage < SRage_`out' & tempage >-1 &(n_6152_`m'_`i'==5)
						replace SR_inc_age_`out'=tempage if tempage!=. & tempage < SR_inc_age_`out' & tempage >-1 & tempage>= baseline_age &(n_6152_`m'_`i'==5)
						drop tempage
						* if age missing or not given, use midpoint of this survey and last survey
						replace SRdate_`out'= midpoint_`m' if  SRage_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SRdate_`out' &(n_6152_`m'_`i'==5)
						replace SR_inc_date_`out'= midpoint_`m' if  SR_inc_age_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SR_inc_date_`out' & midpoint_`m'> baseline &(n_6152_`m'_`i'==5) & `m'>0
					}	
					*7	Blood clot in the lung: 4022
					if regexm("7","`code'"){
						replace SRmatch_`out'=1 if (n_6152_`m'_`i'==7)
						gen tempage = n_4022_`m'_0 if (n_6152_`m'_`i'==7) if n_4022_`m'_0 >=0
						replace SRage_`out'=tempage if tempage!=. & tempage < SRage_`out' & tempage >-1 &(n_6152_`m'_`i'==7)
						replace SR_inc_age_`out'=tempage if tempage!=. & tempage < SR_inc_age_`out' & tempage >-1 & tempage>= baseline_age &(n_6152_`m'_`i'==7)
						drop tempage
						* if age missing or not given, use midpoint of this survey and last survey
						replace SRdate_`out'= midpoint_`m' if  SRage_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SRdate_`out' &(n_6152_`m'_`i'==7)
						replace SR_inc_date_`out'= midpoint_`m' if  SR_inc_age_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SR_inc_date_`out' & midpoint_`m'> baseline &(n_6152_`m'_`i'==7) & `m'>0
					}	
					*6	Emphysema/chronic bronchitis: 3992
					if regexm("6","`code'"){
						replace SRmatch_`out'=1 if (n_6152_`m'_`i'==6)
						gen tempage = n_3992_`m'_0 if (n_6152_`m'_`i'==6) & n_3992_`m'_0  >=0
						replace SRage_`out'=tempage if tempage!=. & tempage < SRage_`out' & tempage >-1 &(n_6152_`m'_`i'==6)
						replace SR_inc_age_`out'=tempage if tempage!=. & tempage < SR_inc_age_`out' & tempage >-1 & tempage>= baseline_age &(n_6152_`m'_`i'==6)
						drop tempage
						* if age missing or not given, use midpoint of this survey and last survey
						replace SRdate_`out'= midpoint_`m' if  SRage_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SRdate_`out' &(n_6152_`m'_`i'==6)
						replace SR_inc_date_`out'= midpoint_`m' if  SR_inc_age_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SR_inc_date_`out' & midpoint_`m'> baseline &(n_6152_`m'_`i'==6) & `m'>0
					}	
					*8	Asthma : matches 3786
					if regexm("8","`code'"){
						replace SRmatch_`out'=1 if (n_6152_`m'_`i'==8)
						gen tempage = n_3786_`m'_0 if (n_6152_`m'_`i'==8) &  n_3786_`m'_0  >=0
						replace SRage_`out'=tempage if tempage!=. & tempage < SRage_`out' & tempage >-1 &(n_6152_`m'_`i'==8)
						replace SR_inc_age_`out'=tempage if tempage!=. & tempage < SR_inc_age_`out' & tempage >-1 & tempage>= baseline_age &(n_6152_`m'_`i'==8)
						drop tempage
						* if age missing or not given, use midpoint of this survey and last survey
						replace SRdate_`out'= midpoint_`m' if  SRage_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SRdate_`out' &(n_6152_`m'_`i'==8)
						replace SR_inc_date_`out'= midpoint_`m' if  SR_inc_age_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SR_inc_date_`out' & midpoint_`m'> baseline &(n_6152_`m'_`i'==8) & `m'>0
					}	
					*9	Hayfever, allergic rhinitis or eczema: 3761
					if regexm("9","`code'"){
						replace SRmatch_`out'=1 if (n_6152_`m'_`i'==9)
						gen tempage = n_3761_`m'_0 if (n_6152_`m'_`i'==9) &  n_3761_`m'_0  >=0
						replace SRage_`out'=tempage if tempage!=. & tempage < SRage_`out' & tempage >-1 &(n_6152_`m'_`i'==9)
						replace SR_inc_age_`out'=tempage if tempage!=. & tempage < SR_inc_age_`out' & tempage >-1 & tempage>= baseline_age &(n_6152_`m'_`i'==9)
						drop tempage
						* if age missing or not given, use midpoint of this survey and last survey
						replace SRdate_`out'= midpoint_`m' if  SRage_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SRdate_`out' &(n_6152_`m'_`i'==9)
						replace SR_inc_date_`out'= midpoint_`m' if  SR_inc_age_`out'==. & SRmatch_`out'==1 & midpoint_`m'< SR_inc_date_`out' & midpoint_`m'> baseline &(n_6152_`m'_`i'==9) & `m'>0
					}	
				}
			}
		}
	
	
		* covert SRage and compare to earliest SRdate
		* RECALL: 	If the participant gave their age then the value presented is the fractional year corresponding to the mid-point of that age. For example, if the participant said they were 30 years old then the value is the date at which they were 30years+6months.
		gen dob = n_33_0_0
		format dob %td
		gen tempdate = dob+(SRage_`out'+0.5)*365.25 if SRage_`out'!=.
		format tempdate %td	
		*Interpolated values before the date of birth were truncated forwards to that time.
		replace tempdate = dob if dob>tempdate & tempdate!=.
		*Interpolated values after the time of data acquisition were truncated back to that time.
		replace tempdate = ts_53_`m'_0 if ts_53_`m'_0 !=. & tempdate!=. & ts_53_`m'_0 < tempdate
		* finally update SR date
		replace SRdate_`out' = tempdate if tempdate<SR_inc_date_`out' & tempdate!=.
		* repeat for incident events
		replace tempdate=.
		replace tempdate = dob+(SR_inc_age_`out'+0.5)*365.25 if SR_inc_age_`out'!=.
		format tempdate %td	
		* all dates are after baseline, so post birth by definition
		*Interpolated values after the time of data acquisition were truncated back to that time.
		replace tempdate = ts_53_`m'_0 if ts_53_`m'_0 !=. & tempdate!=. & ts_53_`m'_0 < tempdate
		* finally update SR date
		replace SR_inc_date_`out' = tempdate if tempdate < SR_inc_date_`out' & tempdate!=. & tempdate >= baseline
		drop tempdate dob
		* end of loop over surveys		
	}
}
}


*3) only date attached to these is the survey date, so need to consider outside of survey loop
foreach out of local output{
if ``out'_Pre'==1{
		
	* 6153/6177
	
	* did med occur pre-baseline (n_6153_0)
		* how many timepoint 0 records are there
	ds n_6153_0*
	macro drop _count
	local count :  word count `r(varlist)'
	local count =  `count'-1
		* loop over these records
	forval i= 0(1)`count'{
		replace SRmatch_`out'=1 if inlist(string(n_6153_0_`i'),``out'_Selfreport6153')
		replace SRdate_`out'=ts_53_0_0 if inlist(string(n_6153_0_`i'),``out'_Selfreport6153') & 	ts_53_0_0 < SRdate_`out'
		* ignore for incident - cannot possibly occur on first survey
	}
		* repeat for 6177
	ds n_6177_0*
	macro drop _count
	local count :  word count `r(varlist)'
	local count =  `count'-1
	forval i= 0(1)`count'{
		replace SRmatch_`out'=1 if inlist(string(n_6177_0_`i'),``out'_Selfreport6177')
		replace SRdate_`out'=ts_53_0_0 if inlist(string(n_6177_0_`i'),``out'_Selfreport6177') & 	ts_53_0_0 < SRdate_`out'
		*ignore for incident - cannot possibly occur on first survey
	}	
		
	* if no med pre-baseline, is there meds post baseline? (n_6153_1 and onwards)
		* for each survey count how many records
	forval j=1(1)`survey'{
		ds n_6153_`j'_*
		macro drop _count
		local count:  word count `r(varlist)'
		local count =  `count'-1
		forval k=0(1)`count'{
			replace SRmatch_`out'=1 if inlist(string(n_6153_`j'_`k'),``out'_Selfreport6153')
			* replace event date if this is earlier than previous events
			replace SRdate_`out' = midpoint_`j' if midpoint_`j' < SRdate_`out' & inlist(string(n_6153_`j'_`k'),``out'_Selfreport6153')
			replace SR_inc_date_`out' = midpoint_`j' if midpoint_`j' < SR_inc_date_`out' & inlist(string(n_6153_`j'_`k'),``out'_Selfreport6153')
		
		}
		* repeat for 6177
		ds n_6177_`j'_*
		macro drop _count
		local count:  word count `r(varlist)'
		local count =  `count'-1
		forval k=0(1)`count'{
			replace SRmatch_`out'=1 if inlist(string(n_6177_`j'_`k'),``out'_Selfreport6177')
			replace SRdate_`out' = midpoint_`j' if midpoint_`j' < SRdate_`out' & inlist(string(n_6177_`j'_`k'),``out'_Selfreport6177')
			replace SR_inc_date_`out' = midpoint_`j' if midpoint_`j' < SR_inc_date_`out' & inlist(string(n_6177_`j'_`k'),``out'_Selfreport6177')
		}
	}
}
}

capture rename n_eid eid

* drop to wanted variables

if (`Pre_wanted'==1){
	keep eid SRmatch* SRdate* SR_inc_date*
}
if (`Pre_wanted'==0){
	keep eid SRmatch*
}



* save as a temp file for later merge
tempfile temp_SR_matched
save `temp_SR_matched', replace

