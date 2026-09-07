* Title: Clean ACS Data

* -----------------------------------
* ---------- HOUSEKEEPING -----------
* -----------------------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
// cd "/home/scanast/nca_income_bans" // for cluster runs 
log using "logs/prep_acs.log", replace 
clear all 

* Load Data
use "data/clean_data/acs_5pct.dta", clear 
// use "data/raw_data/usa_00023.dta", clear 


* --------------------------------------
* --- RESTRICT TO WORKING AGE ADULTS ---
* --------------------------------------
drop if age < 15
drop if age > 64


* -----------------------------------
* --- RESTRICT TO EMPLOYED PEOPLE ---
* -----------------------------------
keep if classwkr == 2


* ----------------------------
* --- DROP IF INCWAGE == 0 --- 
* ----------------------------
drop if incwage == 0


* -------------------------------------------------
* --- CONVERT NOMINAL EARNINGS TO REAL EARNINGS ---
* -------------------------------------------------

* Merge CPI Data by Year 
merge m:1 year using "data/clean_data/annual_cpi.dta"
drop if _merge == 2
drop _merge

summarize cpi if year == 2024 // base year
scalar cpi2024 = r(mean)

gen incwage_real = incwage * (cpi2024 / cpi)
order incwage_real, after(incwage)


* ----------------------------------------------------
* --- RESTRICTIONS TO ACCOUNT FOR NCA RESTRICTIONS --- 
* ----------------------------------------------------

* Convert State FIPS Variable to str2 
rename statefip statefip_old
tostring statefip_old, gen(statefip) format("%02.0f")
order statefip, after(statefip_old)
drop statefip_old

* Merge State NCA Law Data by State FIPS 
merge m:1 statefip using "data/clean_data/state_nca_laws.dta"
drop _merge
order state, after(statefip)

* Local 
local last_year = 2024


* --------------------------------------
* --- (1) DROP FULL-BAN OBSERVATIONS ---
* --------------------------------------
* Create flag 
gen full_flag = !missing(eff_full_year) & eff_full_year <= `last_year' 

* Drop affected individuals 
drop if full_flag == 1
drop full_flag

* ---------------------------
* --- (2) DROP HOURLY BAN ---
* ---------------------------
* Create flag 
gen hourly_flag = !missing(eff_hourly_year) & eff_hourly_year <= `last_year'

* Drop affected individuals 
drop if hourly_flag == 1
drop hourly_flag

* --------------------------
* --- (3) DROP OTHER BAN ---
* --------------------------
* Create flag 
gen other_flag = !missing(eff_other_year) & eff_other_year <= `last_year'

* Drop affected individuals 
drop if other_flag == 1
drop other_flag

* ---------------------------------
* --- (4) DROP INDUSTRY/OCC BAN ---
* ---------------------------------

* --- MERGE BAN CROSSWALK DATA --- 

* --- FIX OCC AND IND CODES IN ACS ---
* Note: OCC and IND are supposed to be a 4-digit codes. But leading zeros appear  
* to have been eliminated. Should add them back in. 

* --- IMPOSE OCC RESTRICTIONS 

* --- IMPOSE IND RESTRICTIONS 

* --- IMPOSE RESTRICTIONS INVOLVING BOTH OCC & IND 

* --------------------------
* --- SAVE ANALYSIS DATA --- 
* --------------------------
// save "data/analysis_data/acs_analysis.dta", replace 
save "data/analysis_data/acs_5pct_analysis.dta", replace



log close 

