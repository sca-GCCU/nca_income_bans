* Title: SIPP Data Prep

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
// cd "/home/scanast/nca_income_bans" // for cluster runs 
capture log close 
log using "logs/prep_sipp.log", replace 
clear all 

set maxvar 20000

* Levels of key variables: 
* - person-month: tehc_st, ejb1_clwrk, tjb1_msum, tjb1_annsal1
* - person: tdob_byear
* - All outcome variables are "person level."


* --- Prep the Individual SIPP Datasets --- 
foreach yr of numlist 2021/2025 {
	use "data/raw_data/sipp/pu`yr'_dta/pu`yr'.dta", clear 
	rename *, lower 
	gen year_svy = `yr'
	gen year_ref = `yr' - 1
	
	* Keep only important variables 
	local tech_var ssuid pnum shhadid monthcode year_svy year_ref swave wpfinwgt
	local demog_var tehc_st tdob_byear ejb1_clwrk rmesr  
	local out_var eecntyn_401 eecntyn_ira /// // any employer contribution 
		emjob_401 emjob_ira emjob_pen /// // any employer provided plan 
		escntyn_401 escntyn_ira escntyn_pen /// any resp. contribution 
		tcntamt /// // employer + resp. contrib.
		tecntamt tecntamt1 tecntamt_401 tecntamt_ira /// // employer contrib.
		tscntamt tscntamt1 tscntamt_401 tscntamt_ira tscntamt_pen /// // resp. contrib.
		tjb1_msum tjb1_annsal1 // earnings: monthly + annual 
	
	* Safety checks 
	foreach v of local tech_var {
		confirm variable `v' // no capture: want to fail if this doesn't exist
	}
	foreach v of local demog_var {
		confirm variable `v'
	}
	foreach v of local out_var {
		capture confirm variable `v'
		if _rc {
			gen `v' = .
			di as error "`v' missing in `yr' - filled with missing"
		}
	}
	
	local keep_var `tech_var' `demog_var' `out_var'
	keep `keep_var'
	order `keep_var'
	
	save "data/clean_data/sipp_`yr'_processed.dta", replace 
}

* --- Appending the Data --- 
use "data/clean_data/sipp_2021_processed.dta", clear
foreach yr of numlist 2022/2025 {
    append using "data/clean_data/sipp_`yr'_processed.dta"
}
save "data/clean_data/sipp_2021_2025_processed.dta", replace 





* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
* -------------------------------- OLD CODE ------------------------------------
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------

// * ----------------------
// * --- 2025 SIPP DATA --- 
// * ----------------------
//
// use "data/raw_data/sipp/pu2025_dta/pu2025.dta", clear 
// rename *, lower // make variables lower case 
//
// * Keep only important variables 
// local tech_var ssuid pnum shhadid monthcode swave wpfinwgt
// local demog_var tehc_st tdob_byear ejb1_clwrk rmesr  
// local out_var eecntyn_401 eecntyn_ira /// // any employer contribution 
// 	emjob_401 emjob_ira emjob_pen /// // any employer provided plan 
// 	escntyn_401 escntyn_ira escntyn_pen /// any resp. contribution 
// 	tcntamt /// // employer + resp. contrib.
// 	tecntamt tecntamt1 tecntamt_401 tecntamt_ira /// // employer contrib.
// 	tscntamt tscntamt1 tscntamt_401 tscntamt_ira tscntamt_pen /// // resp. contrib.
// 	tjb1_msum tjb1_annsal1 // earnings: monthly + annual 
// local keep_var `tech_var' `demog_var' `out_var'
// keep `keep_var'
//
// * Verify all variables exist 
// foreach v of local keep_var {
// 	capture confirm variable `v'
// 	if _rc != 0 {
// 		di as error "Variable `v' does not exist in dataset."
// 	}
// }
//
// * Define year variables 
// gen year_svy = 2025
// gen year = 2024 
//
// * Save data 
// save "data/clean_data/sipp_2025_clean.dta", replace 



log close 