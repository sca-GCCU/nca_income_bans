* Title: Make QWI Analysis Data

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/prep_qwi.log", replace 
clear all 


* ------------------------
* --- PREP OVERALL QWI --- 
* ------------------------
* Some locals for restrictions later
local first_year = 2012 
local last_year = 2024 // eventually 2025, but missing some Q3 & Q4 data now

* Load data 
import delimited "data/raw_data/qwi/qwi_county_overall_2012q1_2025q4.csv", ///
	stringcols(4) clear

* Keep only what I need 
local qwi_var geography year quarter earnhirns searnhirns emp semp emps semps ///
	hirn shirn hirns shirns
keep `qwi_var'

* Create statefip variable 
rename geography countyfip 
gen statefip = substr(countyfip, 1, 2)
order statefip, after(countyfip)

* NOTE: Definitely missing a lot of values for quarter 3 and 4 of the 2025 data.
* So drop 2025 for now when creating annual data. 

* Drop == 2025
drop if year == 2025


* --- Collapse to County-Year + Impose missingness & balance restrictions ---

* Create flags for valid observations 

bysort countyfip year: gen n_qtrs = _N

local out_var earnhirns emp emps hirn hirns

* Count nonmissing, valid entries for each variable 
foreach v in `out_var' {
	bysort countyfip year: egen nonmiss_`v' = total(!missing(`v') & s`v' == 1)
}

* Collapse to county-year 
collapse (sum) hirn hirns ///
		 (mean) emp emps earnhirns ///
		 (first) statefip ///
		 (min) n_qtrs nonmiss_hirn nonmiss_hirns nonmiss_emp nonmiss_emps /// 
			nonmiss_earnhirns, by(countyfip year)

* NOTE: This is nice because I collapse before doing any restrictions, making it 
* easy to interpret how much is being lost when I drop stuff. 
		
* Enforce validity requirements 
foreach v in `out_var' {
	replace `v' = . if !(n_qtrs == 4 & nonmiss_`v' == 4)
}

drop n_qtrs nonmiss_*

* NOTE: Reasonable number of drops. 



* --- Convert Nominal Earnings to Real Earnings --- 

merge m:1 year using "data/clean_data/annual_cpi.dta"
assert _merge != 1 if year <= `last_year' // each year <= 2024 should have match
drop if _merge == 2 
drop _merge 

summarize cpi if year == 2024 // base year 
scalar cpi_base = r(mean)

generate earnhirns_real = earnhirns * (cpi_base / cpi)
order earnhirns_real, after(earnhirns)



* --- Impose Restrictions to Account for Other NCA Bans --- 

* Merge with treatment data 
merge m:1 statefip using "data/clean_data/state_nca_laws.dta"
drop _merge
order statefip state, after(countyfip)

* (1) DROP FULL-BAN OBSERVATIONS 
* Create flag 
gen full_flag = !missing(eff_full_year) & eff_full_year <= `last_year' 

* Drop affected counties 
drop if full_flag == 1
drop full_flag

* (2) DROP HOURLY BAN 
* Create flag 
gen hourly_flag = !missing(eff_hourly_year) & eff_hourly_year <= `last_year'

* Drop affected counties 
drop if hourly_flag == 1
drop hourly_flag

* (3) DROP OTHER BAN 
* Create flag 
gen other_flag = !missing(eff_other_year) & eff_other_year <= `last_year'

* Drop affected counties 
drop if other_flag == 1
drop other_flag

* (4) Impose always treated restriction 
* NOTE: Just Oregon. 
gen always_trt_flag = !missing(eff_inc1_year) & eff_inc1_year <= `first_year'
drop if always_trt_flag == 1
drop always_trt_flag



* --- Create treatment variables --- 
* treat: ever treated 
gen treat = !missing(eff_inc1_year)

* cohort: year treated; 0 for control 
gen cohort = eff_inc1_year
replace cohort = 0 if missing(eff_inc1_year)

* event time 
gen event_time = year - eff_inc1_year
replace event_time = . if missing(eff_inc1_year)

* NOTE: Retain eff_inc1_year. 

* ALSO NOTE: May need to balance panels. But I could do this on a variable-by-
* variable basis to avoid dropping a ton. 


* --- Save Analysis Data --- 
save "data/analysis_data/qwi_overall_analysis.dta", replace 



* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------

* ------------------------------------
* --- PREP OVERALL BY INDUSTRY QWI ---
* ------------------------------------
* Some locals for restrictions later
local first_year = 2012 
local last_year = 2024 // eventually 2025, but missing some Q3 & Q4 data now

* Load data 
import delimited "data/raw_data/qwi/qwi_county_ind_2012q1_2025q4.csv", ///
	stringcols(4) clear

* Keep only what I need 
local qwi_var geography industry year quarter earnhirns searnhirns emp semp ///
	emps semps hirn shirn hirns shirns
keep `qwi_var'

* Create statefip variable 
rename geography countyfip 
gen statefip = substr(countyfip, 1, 2)
order statefip, after(countyfip)

* Drop == 2025
drop if year == 2025


* --- Collapse to County-Year + Impose missingness & balance restrictions ---

* Create flags for valid observations 

bysort countyfip industry year: gen n_qtrs = _N

local out_var earnhirns emp emps hirn hirns

* Count nonmissing, valid entries for each variable 
foreach v in `out_var' {
	bysort countyfip industry year: egen nonmiss_`v' = total(!missing(`v') & /// 
		s`v' == 1)
}

* Collapse to county-year 
collapse (sum) hirn hirns ///
		 (mean) emp emps earnhirns ///
		 (first) statefip ///
		 (min) n_qtrs nonmiss_hirn nonmiss_hirns nonmiss_emp nonmiss_emps /// 
			nonmiss_earnhirns, by(countyfip industry year)

* NOTE: This is nice because I collapse before doing any restrictions, making it 
* easy to interpret how much is being lost when I drop stuff. 
		
* Enforce validity requirements 
foreach v in `out_var' {
	replace `v' = . if !(n_qtrs == 4 & nonmiss_`v' == 4)
}

drop n_qtrs nonmiss_*

* NOTE: Reasonable number of drops. 



* --- Convert Nominal Earnings to Real Earnings --- 

merge m:1 year using "data/clean_data/annual_cpi.dta"
assert _merge != 1 if year <= `last_year' // each year <= 2024 should have match
drop if _merge == 2 
drop _merge 

summarize cpi if year == 2024 // base year 
scalar cpi_base = r(mean)

generate earnhirns_real = earnhirns * (cpi_base / cpi)
order earnhirns_real, after(earnhirns)



* --- Impose Restrictions to Account for Other NCA Bans --- 

* Merge with treatment data 
merge m:1 statefip using "data/clean_data/state_nca_laws.dta"
drop _merge
order statefip state, after(countyfip)

* (1) DROP FULL-BAN OBSERVATIONS 
* Create flag 
gen full_flag = !missing(eff_full_year) & eff_full_year <= `last_year' 

* Drop affected counties 
drop if full_flag == 1
drop full_flag

* (2) DROP HOURLY BAN 
* Create flag 
gen hourly_flag = !missing(eff_hourly_year) & eff_hourly_year <= `last_year'

* Drop affected counties 
drop if hourly_flag == 1
drop hourly_flag

* (3) DROP OTHER BAN 
* Create flag 
gen other_flag = !missing(eff_other_year) & eff_other_year <= `last_year'

* Drop affected counties 
drop if other_flag == 1
drop other_flag

* (4) Impose always treated restriction 
* NOTE: Just Oregon. 
gen always_trt_flag = !missing(eff_inc1_year) & eff_inc1_year <= `first_year'
drop if always_trt_flag == 1
drop always_trt_flag



* --- Create treatment variables --- 
* treat: ever treated 
gen treat = !missing(eff_inc1_year)

* cohort: year treated; 0 for control 
gen cohort = eff_inc1_year
replace cohort = 0 if missing(eff_inc1_year)

* event time 
gen event_time = year - eff_inc1_year
replace event_time = . if missing(eff_inc1_year)

* NOTE: Retain eff_inc1_year. 

* ALSO NOTE: May need to balance panels. But I could do this on a variable-by-
* variable basis to avoid dropping a ton. 


* --- Save Analysis Data --- 
save "data/analysis_data/qwi_ind_analysis.dta", replace 




* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------

* --------------------
* --- PREP AGE QWI --- 
* --------------------
* Some locals for restrictions later
local first_year = 2012 
local last_year = 2024 // eventually 2025, but missing some Q3 & Q4 data now

* Load data 
import delimited "data/raw_data/qwi/qwi_county_age_2012q1_2025q4.csv", ///
	stringcols(4) clear

* Keep only what I need 
local qwi_var geography agegrp year quarter earnhirns searnhirns emp semp ///
	emps semps hirn shirn hirns shirns
keep `qwi_var'

* Create statefip variable 
rename geography countyfip 
gen statefip = substr(countyfip, 1, 2)
order statefip, after(countyfip)

* Drop == 2025
drop if year == 2025


* --- Collapse to County-Year + Impose missingness & balance restrictions ---

* Create flags for valid observations 

bysort countyfip agegrp year: gen n_qtrs = _N

local out_var earnhirns emp emps hirn hirns

* Count nonmissing, valid entries for each variable 
foreach v in `out_var' {
	bysort countyfip agegrp year: egen nonmiss_`v' = total(!missing(`v') & /// 
		s`v' == 1)
}

* Collapse to county-year 
collapse (sum) hirn hirns ///
		 (mean) emp emps earnhirns ///
		 (first) statefip ///
		 (min) n_qtrs nonmiss_hirn nonmiss_hirns nonmiss_emp nonmiss_emps /// 
			nonmiss_earnhirns, by(countyfip agegrp year)

* NOTE: This is nice because I collapse before doing any restrictions, making it 
* easy to interpret how much is being lost when I drop stuff. 
		
* Enforce validity requirements 
foreach v in `out_var' {
	replace `v' = . if !(n_qtrs == 4 & nonmiss_`v' == 4)
}

drop n_qtrs nonmiss_*

* NOTE: Reasonable number of drops. 



* --- Convert Nominal Earnings to Real Earnings --- 

merge m:1 year using "data/clean_data/annual_cpi.dta"
assert _merge != 1 if year <= `last_year' // each year <= 2024 should have match
drop if _merge == 2 
drop _merge 

summarize cpi if year == 2024 // base year 
scalar cpi_base = r(mean)

generate earnhirns_real = earnhirns * (cpi_base / cpi)
order earnhirns_real, after(earnhirns)



* --- Impose Restrictions to Account for Other NCA Bans --- 

* Merge with treatment data 
merge m:1 statefip using "data/clean_data/state_nca_laws.dta"
drop _merge
order statefip state, after(countyfip)

* (1) DROP FULL-BAN OBSERVATIONS 
* Create flag 
gen full_flag = !missing(eff_full_year) & eff_full_year <= `last_year' 

* Drop affected counties 
drop if full_flag == 1
drop full_flag

* (2) DROP HOURLY BAN 
* Create flag 
gen hourly_flag = !missing(eff_hourly_year) & eff_hourly_year <= `last_year'

* Drop affected counties 
drop if hourly_flag == 1
drop hourly_flag

* (3) DROP OTHER BAN 
* Create flag 
gen other_flag = !missing(eff_other_year) & eff_other_year <= `last_year'

* Drop affected counties 
drop if other_flag == 1
drop other_flag

* (4) Impose always treated restriction 
* NOTE: Just Oregon. 
gen always_trt_flag = !missing(eff_inc1_year) & eff_inc1_year <= `first_year'
drop if always_trt_flag == 1
drop always_trt_flag



* --- Create treatment variables --- 
* treat: ever treated 
gen treat = !missing(eff_inc1_year)

* cohort: year treated; 0 for control 
gen cohort = eff_inc1_year
replace cohort = 0 if missing(eff_inc1_year)

* event time 
gen event_time = year - eff_inc1_year
replace event_time = . if missing(eff_inc1_year)

* NOTE: Retain eff_inc1_year. 

* ALSO NOTE: May need to balance panels. But I could do this on a variable-by-
* variable basis to avoid dropping a ton. 


* --- Save Analysis Data --- 
save "data/analysis_data/qwi_age_analysis.dta", replace 




* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------

* --------------------------------
* --- PREP AGE BY INDUSTRY QWI --- 
* --------------------------------
* Some locals for restrictions later
local first_year = 2012 
local last_year = 2024 // eventually 2025, but missing some Q3 & Q4 data now

* Load data 
import delimited "data/raw_data/qwi/qwi_county_age_ind_2012q1_2025q4.csv", ///
	stringcols(4) clear

* Keep only what I need 
local qwi_var geography industry agegrp year quarter earnhirns searnhirns ///
	emp semp emps semps hirn shirn hirns shirns
keep `qwi_var'

* Create statefip variable 
rename geography countyfip 
gen statefip = substr(countyfip, 1, 2)
order statefip, after(countyfip)

* Drop == 2025
drop if year == 2025


* --- Collapse to County-Year + Impose missingness & balance restrictions ---

* Create flags for valid observations 

bysort countyfip industry agegrp year: gen n_qtrs = _N

local out_var earnhirns emp emps hirn hirns

* Count nonmissing, valid entries for each variable 
foreach v in `out_var' {
	bysort countyfip industry agegrp year: egen nonmiss_`v' = /// 
		total(!missing(`v') & s`v' == 1)
}

* Collapse to county-year 
collapse (sum) hirn hirns ///
		 (mean) emp emps earnhirns ///
		 (first) statefip ///
		 (min) n_qtrs nonmiss_hirn nonmiss_hirns nonmiss_emp nonmiss_emps /// 
			nonmiss_earnhirns, by(countyfip industry agegrp year)

* NOTE: This is nice because I collapse before doing any restrictions, making it 
* easy to interpret how much is being lost when I drop stuff. 
		
* Enforce validity requirements 
foreach v in `out_var' {
	replace `v' = . if !(n_qtrs == 4 & nonmiss_`v' == 4)
}

drop n_qtrs nonmiss_*

* NOTE: Reasonable number of drops. 



* --- Convert Nominal Earnings to Real Earnings --- 

merge m:1 year using "data/clean_data/annual_cpi.dta"
assert _merge != 1 if year <= `last_year' // each year <= 2024 should have match
drop if _merge == 2 
drop _merge 

summarize cpi if year == 2024 // base year 
scalar cpi_base = r(mean)

generate earnhirns_real = earnhirns * (cpi_base / cpi)
order earnhirns_real, after(earnhirns)



* --- Impose Restrictions to Account for Other NCA Bans --- 

* Merge with treatment data 
merge m:1 statefip using "data/clean_data/state_nca_laws.dta"
drop _merge
order statefip state, after(countyfip)

* (1) DROP FULL-BAN OBSERVATIONS 
* Create flag 
gen full_flag = !missing(eff_full_year) & eff_full_year <= `last_year' 

* Drop affected counties 
drop if full_flag == 1
drop full_flag

* (2) DROP HOURLY BAN 
* Create flag 
gen hourly_flag = !missing(eff_hourly_year) & eff_hourly_year <= `last_year'

* Drop affected counties 
drop if hourly_flag == 1
drop hourly_flag

* (3) DROP OTHER BAN 
* Create flag 
gen other_flag = !missing(eff_other_year) & eff_other_year <= `last_year'

* Drop affected counties 
drop if other_flag == 1
drop other_flag

* (4) Impose always treated restriction 
* NOTE: Just Oregon. 
gen always_trt_flag = !missing(eff_inc1_year) & eff_inc1_year <= `first_year'
drop if always_trt_flag == 1
drop always_trt_flag



* --- Create treatment variables --- 
* treat: ever treated 
gen treat = !missing(eff_inc1_year)

* cohort: year treated; 0 for control 
gen cohort = eff_inc1_year
replace cohort = 0 if missing(eff_inc1_year)

* event time 
gen event_time = year - eff_inc1_year
replace event_time = . if missing(eff_inc1_year)

* NOTE: Retain eff_inc1_year. 

* ALSO NOTE: May need to balance panels. But I could do this on a variable-by-
* variable basis to avoid dropping a ton. 


* --- Save Analysis Data --- 
save "data/analysis_data/qwi_age_ind_analysis.dta", replace 






* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------

* ---------------------
* --- PREP EDUC QWI --- 
* ---------------------

* Some locals for restrictions later
local first_year = 2012 
local last_year = 2024 // eventually 2025, but missing some Q3 & Q4 data now

* Load data 
import delimited "data/raw_data/qwi/qwi_county_educ_2012q1_2025q4.csv", ///
	stringcols(4) clear

* Keep only what I need 
local qwi_var geography education year quarter earnhirns searnhirns emp semp ///
	emps semps hirn shirn hirns shirns
keep `qwi_var'

* Create statefip variable 
rename geography countyfip 
gen statefip = substr(countyfip, 1, 2)
order statefip, after(countyfip)

* Drop == 2025
drop if year == 2025


* --- Collapse to County-Year + Impose missingness & balance restrictions ---

* Create flags for valid observations 

bysort countyfip education year: gen n_qtrs = _N

local out_var earnhirns emp emps hirn hirns

* Count nonmissing, valid entries for each variable 
foreach v in `out_var' {
	bysort countyfip education year: egen nonmiss_`v' = total(!missing(`v') & /// 
		s`v' == 1)
}

* Collapse to county-year 
collapse (sum) hirn hirns ///
		 (mean) emp emps earnhirns ///
		 (first) statefip ///
		 (min) n_qtrs nonmiss_hirn nonmiss_hirns nonmiss_emp nonmiss_emps /// 
			nonmiss_earnhirns, by(countyfip education year)

* NOTE: This is nice because I collapse before doing any restrictions, making it 
* easy to interpret how much is being lost when I drop stuff. 
		
* Enforce validity requirements 
foreach v in `out_var' {
	replace `v' = . if !(n_qtrs == 4 & nonmiss_`v' == 4)
}

drop n_qtrs nonmiss_*

* NOTE: Reasonable number of drops. 



* --- Convert Nominal Earnings to Real Earnings --- 

merge m:1 year using "data/clean_data/annual_cpi.dta"
assert _merge != 1 if year <= `last_year' // each year <= 2024 should have match
drop if _merge == 2 
drop _merge 

summarize cpi if year == 2024 // base year 
scalar cpi_base = r(mean)

generate earnhirns_real = earnhirns * (cpi_base / cpi)
order earnhirns_real, after(earnhirns)



* --- Impose Restrictions to Account for Other NCA Bans --- 

* Merge with treatment data 
merge m:1 statefip using "data/clean_data/state_nca_laws.dta"
drop _merge
order statefip state, after(countyfip)

* (1) DROP FULL-BAN OBSERVATIONS 
* Create flag 
gen full_flag = !missing(eff_full_year) & eff_full_year <= `last_year' 

* Drop affected counties 
drop if full_flag == 1
drop full_flag

* (2) DROP HOURLY BAN 
* Create flag 
gen hourly_flag = !missing(eff_hourly_year) & eff_hourly_year <= `last_year'

* Drop affected counties 
drop if hourly_flag == 1
drop hourly_flag

* (3) DROP OTHER BAN 
* Create flag 
gen other_flag = !missing(eff_other_year) & eff_other_year <= `last_year'

* Drop affected counties 
drop if other_flag == 1
drop other_flag

* (4) Impose always treated restriction 
* NOTE: Just Oregon. 
gen always_trt_flag = !missing(eff_inc1_year) & eff_inc1_year <= `first_year'
drop if always_trt_flag == 1
drop always_trt_flag



* --- Create treatment variables --- 
* treat: ever treated 
gen treat = !missing(eff_inc1_year)

* cohort: year treated; 0 for control 
gen cohort = eff_inc1_year
replace cohort = 0 if missing(eff_inc1_year)

* event time 
gen event_time = year - eff_inc1_year
replace event_time = . if missing(eff_inc1_year)

* NOTE: Retain eff_inc1_year. 

* ALSO NOTE: May need to balance panels. But I could do this on a variable-by-
* variable basis to avoid dropping a ton. 


* --- Save Analysis Data --- 
save "data/analysis_data/qwi_educ_analysis.dta", replace 





* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------

* ---------------------------------
* --- PREP EDUC BY INDUSTRY QWI --- 
* ---------------------------------
* Some locals for restrictions later
local first_year = 2012 
local last_year = 2024 // eventually 2025, but missing some Q3 & Q4 data now

* Load data 
import delimited "data/raw_data/qwi/qwi_county_educ_ind_2012q1_2025q4.csv", ///
	stringcols(4) clear

* Keep only what I need 
local qwi_var geography industry education year quarter earnhirns searnhirns ///
	emp semp emps semps hirn shirn hirns shirns
keep `qwi_var'

* Create statefip variable 
rename geography countyfip 
gen statefip = substr(countyfip, 1, 2)
order statefip, after(countyfip)

* Drop == 2025
drop if year == 2025


* --- Collapse to County-Year + Impose missingness & balance restrictions ---

* Create flags for valid observations 

bysort countyfip industry education year: gen n_qtrs = _N

local out_var earnhirns emp emps hirn hirns

* Count nonmissing, valid entries for each variable 
foreach v in `out_var' {
	bysort countyfip industry education year: egen nonmiss_`v' = /// 
		total(!missing(`v') & s`v' == 1)
}

* Collapse to county-year 
collapse (sum) hirn hirns ///
		 (mean) emp emps earnhirns ///
		 (first) statefip ///
		 (min) n_qtrs nonmiss_hirn nonmiss_hirns nonmiss_emp nonmiss_emps /// 
			nonmiss_earnhirns, by(countyfip industry education year)

* NOTE: This is nice because I collapse before doing any restrictions, making it 
* easy to interpret how much is being lost when I drop stuff. 
		
* Enforce validity requirements 
foreach v in `out_var' {
	replace `v' = . if !(n_qtrs == 4 & nonmiss_`v' == 4)
}

drop n_qtrs nonmiss_*

* NOTE: Reasonable number of drops. 



* --- Convert Nominal Earnings to Real Earnings --- 

merge m:1 year using "data/clean_data/annual_cpi.dta"
assert _merge != 1 if year <= `last_year' // each year <= 2024 should have match
drop if _merge == 2 
drop _merge 

summarize cpi if year == 2024 // base year 
scalar cpi_base = r(mean)

generate earnhirns_real = earnhirns * (cpi_base / cpi)
order earnhirns_real, after(earnhirns)



* --- Impose Restrictions to Account for Other NCA Bans --- 

* Merge with treatment data 
merge m:1 statefip using "data/clean_data/state_nca_laws.dta"
drop _merge
order statefip state, after(countyfip)

* (1) DROP FULL-BAN OBSERVATIONS 
* Create flag 
gen full_flag = !missing(eff_full_year) & eff_full_year <= `last_year' 

* Drop affected counties 
drop if full_flag == 1
drop full_flag

* (2) DROP HOURLY BAN 
* Create flag 
gen hourly_flag = !missing(eff_hourly_year) & eff_hourly_year <= `last_year'

* Drop affected counties 
drop if hourly_flag == 1
drop hourly_flag

* (3) DROP OTHER BAN 
* Create flag 
gen other_flag = !missing(eff_other_year) & eff_other_year <= `last_year'

* Drop affected counties 
drop if other_flag == 1
drop other_flag

* (4) Impose always treated restriction 
* NOTE: Just Oregon. 
gen always_trt_flag = !missing(eff_inc1_year) & eff_inc1_year <= `first_year'
drop if always_trt_flag == 1
drop always_trt_flag



* --- Create treatment variables --- 
* treat: ever treated 
gen treat = !missing(eff_inc1_year)

* cohort: year treated; 0 for control 
gen cohort = eff_inc1_year
replace cohort = 0 if missing(eff_inc1_year)

* event time 
gen event_time = year - eff_inc1_year
replace event_time = . if missing(eff_inc1_year)

* NOTE: Retain eff_inc1_year. 

* ALSO NOTE: May need to balance panels. But I could do this on a variable-by-
* variable basis to avoid dropping a ton. 


* --- Save Analysis Data --- 
save "data/analysis_data/qwi_educ_ind_analysis.dta", replace 






log close 