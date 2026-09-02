* Title: Prep CPI Data

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/prep_cpi.log", replace 
clear all 

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

log close 