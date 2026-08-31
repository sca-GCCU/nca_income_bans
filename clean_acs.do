* Title: Clean ACS Data

* ---------- HOUSEKEEPING -----------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/clean_acs.log", replace 
clear all 

* Load Data
use "data/clean_data/acs_5pct.dta", clear 

* ---------- RESTRICT TO WORKING AGE ADULTS -----------
drop if age < 15
drop if age > 64

* ---------- RESTRICT TO EMPLOYED PEOPLE --------------
keep if classwkr == 2

* ---------- DROP FULL-BAN OBSERVATIONS ---------------

* ----------- DROP HOURLY BAN --------------

* ------------ DROP OTHER BAN ---------------

* ------------ DROP INDUSTRY/OCC BAN -------------




log close 

