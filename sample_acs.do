* Title: Create 5% Sample of ACS Data

* ---------- HOUSEKEEPING -----------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/sample_acs.log", replace 
clear all 

* Load Data
use "data/raw_data/usa_00023.dta", clear 

* --------- CREATE SAMPLE -----------
set seed 9853
sample 5, by(year statefip) 
save "data/clean_data/acs_5pct.dta", replace 

log close