* Title: Prep State NCA Law Data

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
// cd "/home/scanast/nca_income_bans" // for cluster runs 
log using "logs/prep_state_nca_laws_data.log", replace 
clear all 

* --------------------------------
* --- PREP STATE NCA LAWS DATA --- 
* --------------------------------
* Import 
import delimited "data/raw_data/state_nca_laws.csv", stringcols(1) clear 
drop source* notes

* Keep only what we need 
local keep_vars statefip state eff_full_year eff_hourly_year eff_other_year ///
	enact_inc1_year eff_inc1_year enact_inc2_year eff_inc2_year /// 
	inc_threshold1 inc_threshold2 inc_threshold_2024 ///
	retro_inc1 retro_inc2 /// 
	eff_ind_year ind_coverage eff_health1_year health_coverage1 /// 
	eff_health2_year health_coverage2 eff_health3_year health_coverage3
	
keep `keep_vars'

* Save 
save "data/clean_data/state_nca_laws.dta", replace 

log close 