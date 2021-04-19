/* SAS program C:\UKbiobank\20180501_ukb21905\interpolation_set.do created 12 Apr 2019 by ukb2sta.cpp Jun 21 2016 11:23:16 */

clear all

cd "C:\UKbiobank\Helper_Programmes\"
infile using "C:\UKbiobank\20180501_ukb21905\interpolation_set2.dct", using("C:\UKbiobank\20180501_ukb21905\interpolation_set2.raw")
gen double ts_53_0_0 = date(s_53_0_0,"DMY")
format ts_53_0_0 %td
drop s_53_0_0
label variable ts_53_0_0 "Date of attending assessment centre"
gen double ts_53_1_0 = date(s_53_1_0,"DMY")
format ts_53_1_0 %td
drop s_53_1_0
label variable ts_53_1_0 "Date of attending assessment centre"
gen double ts_53_2_0 = date(s_53_2_0,"DMY")
format ts_53_2_0 %td
drop s_53_2_0
label variable ts_53_2_0 "Date of attending assessment centre"

save assess_date, replace



clear all
label define m_0008 12 "December" 10 "October" 7 "July" 1 "January" 4 "April" 9 "September" 3 "March" 8 "August" 11 "November" 6 "June" 2 "February" 5 "May"
label define m_0037 -1 "Time uncertain/unknown" -3 "Preferred not to answer"

cd "C:\UKbiobank\Helper_Programmes\"
infile using "C:\UKbiobank\20180501_ukb21905\interpolation_set.dct", using("C:\UKbiobank\20180501_ukb21905\interpolation_set.raw")
label values n_52_0_0 m_0008
label values n_87_0_0 m_0037
label values n_87_0_1 m_0037
label values n_87_0_2 m_0037
label values n_87_0_3 m_0037
label values n_87_0_4 m_0037
label values n_87_0_5 m_0037
label values n_87_0_6 m_0037
label values n_87_0_7 m_0037
label values n_87_0_8 m_0037
label values n_87_0_9 m_0037
label values n_87_0_10 m_0037
label values n_87_0_11 m_0037
label values n_87_0_12 m_0037
label values n_87_0_13 m_0037
label values n_87_0_14 m_0037
label values n_87_0_15 m_0037
label values n_87_0_16 m_0037
label values n_87_0_17 m_0037
label values n_87_0_18 m_0037
label values n_87_0_19 m_0037
label values n_87_0_20 m_0037
label values n_87_0_21 m_0037
label values n_87_0_22 m_0037
label values n_87_0_23 m_0037
label values n_87_0_24 m_0037
label values n_87_0_25 m_0037
label values n_87_0_26 m_0037
label values n_87_0_27 m_0037
label values n_87_0_28 m_0037
label values n_87_1_0 m_0037
label values n_87_1_1 m_0037
label values n_87_1_2 m_0037
label values n_87_1_3 m_0037
label values n_87_1_4 m_0037
label values n_87_1_5 m_0037
label values n_87_1_6 m_0037
label values n_87_1_7 m_0037
label values n_87_1_8 m_0037
label values n_87_1_9 m_0037
label values n_87_1_10 m_0037
label values n_87_1_11 m_0037
label values n_87_1_12 m_0037
label values n_87_1_13 m_0037
label values n_87_1_14 m_0037
label values n_87_1_15 m_0037
label values n_87_2_0 m_0037
label values n_87_2_1 m_0037
label values n_87_2_2 m_0037
label values n_87_2_3 m_0037
label values n_87_2_4 m_0037
label values n_87_2_5 m_0037
label values n_87_2_6 m_0037
label values n_87_2_7 m_0037
label values n_87_2_8 m_0037
label values n_87_2_9 m_0037
label values n_87_2_10 m_0037
label values n_87_2_11 m_0037
label values n_87_2_12 m_0037
label values n_87_2_13 m_0037
label values n_87_2_14 m_0037
label values n_87_2_15 m_0037
label values n_87_2_16 m_0037
label values n_87_2_17 m_0037
label values n_87_2_18 m_0037
label values n_87_2_19 m_0037
label values n_87_2_20 m_0037
label values n_87_2_21 m_0037
label values n_87_2_22 m_0037
label values n_87_2_23 m_0037
label values n_87_2_24 m_0037
label values n_87_2_25 m_0037
label values n_87_2_26 m_0037
label values n_87_2_27 m_0037
label values n_87_2_28 m_0037

* add assessment dates
merge 1:1 n_eid using assess_date, update
assert _merge==3
drop _merge

* calculate DOB
gen birth_date_string = "1 " +string(n_52) + " " + string(n_34)
gen birth_date = date(birth_date_string, "DMY")
format birth_date %td


* calculate age at report

qui forvalues j=0(2)2 {
forvalues i=0/28 {
gen temp_year = n_87_`j'_`i' if n_87_`j'_`i' > 1000
gen temp_age = n_87_`j'_`i' if n_87_`j'_`i' <= 1000
replace temp_a=. if temp_a<0

gen temp_date_string = "1 July "+string(temp_year) if temp_year!=.
gen temp_date = date(temp_date_string, "DMY")
format temp_date %td
*truncate future dates
replace temp_date = ts_53_`j'_0 if ts_53_`j'_0<temp_date & temp_date!=.

gen age = round((temp_date - birth_date)/365.25,0.25)
*truncate dates before birth
replace age =0 if age<0
replace age=temp_age if temp_age!=.
gen n_20009_`j'_`i' = age
drop age temp*
 label  variable n_20009_`j'_`i' " Extrapolated Age diagnosed"
}
}


qui forvalues i=0/15 {
gen temp_year = n_87_1_`i' if n_87_1_`i' > 1000
gen temp_age = n_87_1_`i' if n_87_1_`i' <= 1000
replace temp_a=. if temp_a<0

gen temp_date_string = "1 July "+string(temp_year) if temp_year!=.
gen temp_date = date(temp_date_string, "DMY")
format temp_date %td
replace temp_date = ts_53_1_0 if ts_53_1_0<temp_date & temp_date!=.

gen age = round((temp_date - birth_date)/365.25,0.25)
replace age =0 if age<0
replace age=temp_age if temp_age!=.
gen n_20009_1_`i' = age
drop age temp*
 label  variable n_20009_1_`i' " Extrapolated Age diagnosed"
}

keep n_eid n_20009*

save "\\me-filer1\home$\am2609\My Documents\Stata_outcomes\interpolated_age.dta", replace
* RULES: If the participant gave a calendar year, then the best-fit time is their age at the mid-point of that year. 
* For example if the year was given as 1970, and the participant was born on 1 April 1950, 
* then their age on 1st July 1970 is 20.25 then the value presented is 1970.5
*Interpolated values before the date of birth were truncated forwards to that time.
*Interpolated values after the time of data acquisition were truncated back to that time







