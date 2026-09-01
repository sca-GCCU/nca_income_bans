* Title: Make QWI Analysis Data

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/clean_qwi.log", replace 
clear all 

* Some locals for restrictions later
local first_year = 2012 
local last_year = 2025 

* ---------------------
* --- PREP CPI DATA --- 
* ---------------------
import excel "data/raw_data/historical-cpi-u-202601.xlsx", ///
	sheet("Index Averages") cellrange(B7:E119) clear 
drop C D
rename B year_string
rename E cpi 
gen year = real(year_string)
drop year_string
order year, before(cpi)
save "data/clean_data/annual_cpi.dta", replace  


* --------------------------------
* --- PREP STATE NCA LAWS DATA --- 
* --------------------------------
import delimited "data/raw_data/state_nca_laws.csv", stringcols(1) clear 
drop source* notes
rename statefip state_fips
save "data/clean_data/state_nca_laws.dta", replace 

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

rename geography county_fips 
gen state_fips = substr(county_fips, 1, 2)
order state_fips, after(county_fips)

* Merge with treatment data 
merge m:1 state_fips using "data/clean_data/state_nca_laws.dta"


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