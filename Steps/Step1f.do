* Create accurate censor dates and inclusion list for primary care dates

* This is a method developed by Tom Bolton and Amy Mason

* overall stats
import delimited `PRIMARY_REG', clear

* drop english(Vision) data

drop if data_pro==1 

* change dates
* correct end/start dates
gen enddate=   date(deduct_date,"DMY")
gen startdate=   date(reg_date,"DMY")
format %td enddate startdate
replace enddate= date("31/12/2099","DMY") if enddate==. 

replace enddate= date("19/04/2017","DMY") if enddate>date("19/04/2017","DMY") & data_provider==2
replace enddate= date("18/09/2017","DMY") if enddate> date("18/09/2017","DMY") & data_provider==4
replace enddate= date("14/06/2016","DMY") if enddate>date("14/06/2016","DMY") & data_provider==3



* drop duplicates by reg_date and deduct_date
duplicates drop eid startdate enddate, force

* drop duplicates by reg_date (keeping max deduct_date)
gsort eid -enddate
duplicates drop eid startdate, force

* drop duplicates by deduct_date (keeping min reg_date)
gsort eid startdate
duplicates drop eid enddate, force

* drop if reg_date==.

drop if startdate==.

* drop if reg_date > deduct_date

drop if startdate> enddate

* merge into main data to get dos
merge m:1 eid using `temp_date'
merge m:1 eid using `temp_withdrawn', gen(withdrawn)
drop if _merge==1 & withdrawn==3
drop if withdrawn==2
assert inlist(_merge,2,3) 
rename baseline dos 
keep _merge eid data_provider reg_date deduct_date enddate startdate dos
drop if _merge==2
drop _merge

* drop records spanning before baseline (ie, reg_date < dos & deduct_date < dos) 

drop if enddate< dos

* drop if all records for participants that do not have at least one record starting within 1 week of baseline (at least one record with reg_date <= dos + 7)
bysort eid (startdate): gen firststart=startdate[1]
drop if firststart> dos+7

tempfile tom_temp
save `tom_temp', replace

* arrange to single record

keep eid startdate enddate
sort eid startdate
by eid: gen episode=_n
by eid: gen firststart=startdate[1]
gen startminus7= startdate-7
egen startminusmax = rowmax(firststart startminus7)
by eid: replace startdate=startminusmax if _n>1 
drop startminusmax firststart startminus7

*   ARRANGE DATA TO A SINGLE TIME VARIABLE
*   WITH START AND END AS A SEPARATE VARIABLE (RESHAPE LONG)
rename *date time*
reshape long time, i(eid episode) j(start_end) string

*    TRACK IN AND OUT OF PROCEDURE OVER TIME
gsort eid time -start_end
* note this change above ensures same date changes are not considered breaks. 
by eid (time): gen int in_data = sum(start_end == "start") - sum(start_end == "end")
*   A BLOCK OF CONTINUING TIME IN THE DATA BEGINS WITH IN_DATA == 1
*   AND ENDS WHEN IT RETURNS TO ZERO
replace in_data = 1 if in_data > 1

*   NOW IDENTIFY THOSE BLOCKS OF CONTINUING PROCEDURE TIME AND
*   ASSIGN EACH A NUMBER (WITHIN ID)
by eid (time): gen block_num = 1 if in_data == 1 & in_data[_n-1] != 1
by eid (time): replace block_num = sum(block_num)

*   NOW REDUCE DATA TO JUST BEGINNING AND END OF EACH BLOCK
by eid block_num (time), sort: assert start_end == "start" if _n == 1
by eid block_num (time): assert start_end == "end" if _n == _N
by eid block_num (time): keep if _n == 1 | _n == _N
*   NOW REDUCE TO ONE OBSERVATION PER BLOCK BY RESHAPING WIDE
drop episode in_data
reshape wide time, i(eid block_num) j(start_end) string
rename time* *
order start, before(end)

* merge back to dataset
keep if block_num==1
drop block_num
merge 1:m eid using `tom_temp', update
drop if _merge!=3
drop _merge

* keep single record per person

keep eid start end
format %td start end

duplicates drop 

save `temp_primary_censor', replace
