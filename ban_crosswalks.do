* Title: Create OCC- and IND-Ban Crosswalks

* ----------- HOUSEKEEPING ----------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/ban_crosswalks.log", replace 
clear all 


* ------------- LOAD 1990 CODE CROSSWALK ------------
import delimited "data/raw_data/coverage_occ1990_ind1990_crosswalk.csv", ///
	varnames(1) clear 

split occ1990, parse(";")
drop occ1990

split ind1990, parse(";")
drop ind1990

reshape long occ1990 ind1990, i(coverage) j(temp_var)

local drop_var notes temp_var
drop `drop_var'

drop if missing(occ1990) & missing(ind1990)

replace occ1990 = trim(occ1990)
replace ind1990 = trim(ind1990)

gen rule = 1 if match_rule == "occ1990" 
replace rule = 2 if match_rule == "ind1990"
replace rule = 3 if match_rule == "intersection"

label define rule_lbl 1 "occ1990" 2 "ind1990" 3 "intersection"
label values rule rule_lbl

drop match_rule

gen confidence_flag = 1 if confidence == "high"
replace confidence_flag = 2 if confidence == "medium"
replace confidence_flag = 3 if confidence == "low"

label define confidence_flag_lbl 1 "high" 2 "medium" 3 "low"
label value confidence_flag confidence_flag_lbl

drop confidence

save "data/clean_data/coverage_occ1990_ind1990_crosswalk.dta", replace


* ----------- IDENTIFY BAN COVERAGE --------------
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

* Drop rows that say "See ban_ind and ind_coverage."
drop if coverage == "See ban_ind and ind_coverage."

* Save current dataset
save "data/clean_data/ban_coverage.dta", replace 


* ----------- MERGE ------------------
merge m:m coverage using "data/clean_data/coverage_occ1990_ind1990_crosswalk.dta"

* NOTE: There are some that are not matched. So I need to go update the 1990
* crosswalk to cover them. 


* Export to excel for further editing
export excel "data/clean_data/ban_coverage.xls", firstrow(variables) replace 




log close 