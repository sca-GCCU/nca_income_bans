* Title: Make QWI Analysis Data

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/prep_qwi.log", replace 
clear all 

* Some locals for restrictions later
local first_year = 2012 
local last_year = 2025 


* ------------------------
* --- PREP OVERALL QWI --- 
* ------------------------

* Load data 
import delimited "data/raw_data/qwi/qwi_county_overall_2012q1_2025q4.csv", ///
	stringcols(4) clear

* Keep only what I need 
local qwi_var geography year quarter earnhirns searnhirns emp semp emps semps ///
	hirn shirn hirns shirns
keep `qwi_var'

rename geography countyfip 
gen statefip = substr(countyfip, 1, 2)
order statefip, after(countyfip)

* Merge with treatment data 
merge m:1 statefip using "data/clean_data/state_nca_laws.dta"
drop _merge

* Impose ban restrictions 

* Impose always treated restriction 

* Convert to real values 

* Impose missingness & balance restrictions 



* --- PREP OVERALL BY INDUSTRY QWI --- 
* Load data 

* Impose ban restrictions 

* Impose always treated restriction 

* Convert to real values 

* Impose missingness & balance restrictions 



* --- PREP AGE QWI --- 


* --- PREP AGE BY INDUSTRY QWI --- 


* --- PREP EDUC QWI --- 


* --- PREP EDUC BY INDUSTRY QWI --- 





log close 