* Title: Create OCC- and IND-Ban Crosswalks

* -----------------------------------------
* ----------- HOUSEKEEPING ----------------
* -----------------------------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/ban_crosswalks.log", replace 
clear all 


* ------------------------------------------------
* ----------- IDENTIFY BAN COVERAGE --------------
* ------------------------------------------------
* Load State Laws Spreadsheet 
import delimited "data/raw_data/state_nca_laws.csv", clear 

* Keep Only Required Variables
local ind_var statefip state ind_coverage ///
	health_coverage1 health_coverage2 health_coverage3
keep `ind_var'

* Reshape Data 
rename ind_coverage coverage1
rename health_coverage1 coverage2
rename health_coverage2 coverage3
rename health_coverage3 coverage4

split coverage1, parse(";")
drop coverage1

split coverage2, parse(";")
drop coverage2

split coverage3, parse(";")
drop coverage3

split coverage4, parse(";")
drop coverage4

reshape long coverage, i(statefip) j(temp_var)
drop if missing(coverage)

* Tidying up
order state, after(statefip)
replace coverage = trim(coverage)

* Create Ban-Type Variable 
gen ban_type = 1 if inrange(temp_var, 11, 19)
replace ban_type = 2 if inrange(temp_var, 21, 49)
label define ban_type_lbl 1 "IND-OCC" 2 "HEALTH"
label values ban_type ban_type_lbl
drop temp_var

* Drop rows that say "See ban_ind and ind_coverage."
drop if coverage == "See ban_ind and ind_coverage."
drop if coverage == "Government Contractors"

* Save current dataset
save "data/clean_data/ban_coverage.dta", replace 

* Create a coverage spreadsheet that I will use to make a coverage crosswalk
drop statefip state ban_type
duplicates drop

export excel "data/clean_data/ban_coverage_unique.xls", firstrow(variables) replace

* NOTE: Constructing crosswalk from ban coverage directly to OCC and IND in 
* another excel file titled "ban_coverage_crosswalk.xls." 



* ---------------------------------------------
* --- CREATE OCC-EXCLUSIONS "LOOK-UP" TABLE --- 
* ---------------------------------------------
* --- Prep occ-ban crosswalk tempfile --- 
import excel using "data/clean_data/ban_coverage_crosswalk.xls", firstrow clear
keep if inlist(excl_type, "occ") & !missing(occ)
keep coverage occ_vintage occ
duplicates drop // zero observations dropped (as expected)
tempfile occ_crosswalk
save `occ_crosswalk'

* --- Prep state NCA law data ---
import delimited "data/raw_data/state_nca_laws.csv", stringcols(1) clear 
keep statefip state /// 
	ban_ind 	ind_coverage ///
	ban_health1 health_coverage1 ///
	ban_health2 health_coverage2 ///
	ban_health3 health_coverage3

* Guard against stray text
rename health_coverage1 coverage_health1
rename health_coverage2 coverage_health2
rename health_coverage3 coverage_health3 
rename ind_coverage coverage_ind

local cov_type ind health1 health2 health3

foreach v in `cov_type' {
	replace coverage_`v' = "" if ban_`v' != 1
} // zero changes made; reassuring 

* Zero out "See ban_in..." cells
replace coverage_health1 = "" if coverage_health1 == "See ban_ind and ind_coverage."

* Reshape wide to long: one row per ban type 
reshape long coverage_, i(statefip state) j(ban_type) string
rename coverage_ coverage_raw

* Drop rows without coverage information
drop if missing(coverage_raw) | coverage_raw == ""

* Split semicolon-delimited coverage strings 
split coverage_raw, parse(";") gen(occ) // new variables start with occ 

reshape long occ, i(statefip state ban_type) j(num)
drop if missing(occ)
replace occ = trim(occ) // replace leading and trailing zeroes 
rename occ coverage 
drop num coverage_raw

* --- Merge to crosswalk --- 
merge m:m coverage using `occ_crosswalk'
// tab coverage if _merge == 1
keep if _merge == 3
drop _merge

* Ensure unique triples
// isid statefip occ_vintage occ ban_type // unique id
keep statefip occ_vintage occ // don't need coverage anymore
duplicates drop
gen byte drop_occ = 1 // flag for dropping later
sort statefip occ_vintage occ

save "data/clean_data/occ_exclusions.dta", replace 



* ---------------------------------------------
* --- CREATE IND-EXCLUSIONS "LOOK-UP" TABLE --- 
* ---------------------------------------------
* --- Prep ind-ban crosswalk tempfile --- 
import excel using "data/clean_data/ban_coverage_crosswalk.xls", firstrow clear
keep if inlist(excl_type, "ind") & !missing(ind)
keep coverage ind_vintage ind
duplicates drop // zero observations dropped (as expected)
tempfile ind_crosswalk
save `ind_crosswalk'

* --- Prep state NCA law data ---
import delimited "data/raw_data/state_nca_laws.csv", stringcols(1) clear 
keep statefip state /// 
	ban_ind 	ind_coverage ///
	ban_health1 health_coverage1 ///
	ban_health2 health_coverage2 ///
	ban_health3 health_coverage3

* Guard against stray text
rename health_coverage1 coverage_health1
rename health_coverage2 coverage_health2
rename health_coverage3 coverage_health3 
rename ind_coverage coverage_ind

local cov_type ind health1 health2 health3

foreach v in `cov_type' {
	replace coverage_`v' = "" if ban_`v' != 1
} // zero changes made; reassuring 

* Zero out "See ban_in..." cells
replace coverage_health1 = "" if coverage_health1 == "See ban_ind and ind_coverage."

* Reshape wide to long: one row per ban type 
reshape long coverage_, i(statefip state) j(ban_type) string
rename coverage_ coverage_raw

* Drop rows without coverage information
drop if missing(coverage_raw) | coverage_raw == ""

* Split semicolon-delimited coverage strings 
split coverage_raw, parse(";") gen(ind) // new variables start with ind 

reshape long ind, i(statefip state ban_type) j(num)
drop if missing(ind)
replace ind = trim(ind) // replace leading and trailing zeroes 
rename ind coverage 
drop num coverage_raw

* --- Merge to crosswalk --- 
merge m:m coverage using `ind_crosswalk'
// tab coverage if _merge == 1
keep if _merge == 3
drop _merge

* Ensure unique triples
// isid statefip ban_type ind_vintage ind // unique id
keep statefip ind_vintage ind // don't need coverage anymore
duplicates drop
gen byte drop_ind = 1 // flag for dropping later
sort statefip ind_vintage ind

save "data/clean_data/ind_exclusions.dta", replace 



* ------------------------------------------------
* --- CREATE "BOTH"-EXCLUSIONS "LOOK-UP" TABLE --- 
* ------------------------------------------------
* --- Prep occ-ban crosswalk tempfile --- 
import excel using "data/clean_data/ban_coverage_crosswalk.xls", firstrow clear
keep if inlist(excl_type, "both") 
keep coverage occ_vintage occ ind_vintage ind 
duplicates drop // zero observations dropped (as expected)
tempfile both_crosswalk
save `both_crosswalk'

* --- Prep state NCA law data ---
import delimited "data/raw_data/state_nca_laws.csv", stringcols(1) clear 
keep statefip state /// 
	ban_ind 	ind_coverage ///
	ban_health1 health_coverage1 ///
	ban_health2 health_coverage2 ///
	ban_health3 health_coverage3

* Guard against stray text
rename health_coverage1 coverage_health1
rename health_coverage2 coverage_health2
rename health_coverage3 coverage_health3 
rename ind_coverage coverage_ind

local cov_type ind health1 health2 health3

foreach v in `cov_type' {
	replace coverage_`v' = "" if ban_`v' != 1
} // zero changes made; reassuring 

* Zero out "See ban_in..." cells
replace coverage_health1 = "" if coverage_health1 == "See ban_ind and ind_coverage."

* Reshape wide to long: one row per ban type 
reshape long coverage_, i(statefip state) j(ban_type) string
rename coverage_ coverage_raw

* Drop rows without coverage information
drop if missing(coverage_raw) | coverage_raw == ""

* Split semicolon-delimited coverage strings 
split coverage_raw, parse(";") gen(work) // new variables start with work 

reshape long work, i(statefip state ban_type) j(num)
drop if missing(work)
replace work = trim(work) // replace leading and trailing zeroes 
rename work coverage 
drop num coverage_raw

* --- Merge to crosswalk --- 
merge m:m coverage using `both_crosswalk'
// tab coverage if _merge == 1
keep if _merge == 3
drop _merge

* Ensure unique triples
// isid statefip occ_vintage occ ind_vintage ind // unique id
keep statefip occ_vintage occ ind_vintage ind // don't need coverage anymore
duplicates drop
gen byte drop_both = 1 // flag for dropping later
sort statefip occ_vintage occ ind_vintage ind

save "data/clean_data/both_exclusions.dta", replace 




log close 