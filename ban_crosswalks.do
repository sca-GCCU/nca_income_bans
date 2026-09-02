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





log close 