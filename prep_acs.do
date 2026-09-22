* Title: Clean ACS Data

* -----------------------------------
* ---------- HOUSEKEEPING -----------
* -----------------------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
// cd "/home/scanast/nca_income_bans" // for cluster runs 
capture log using "logs/prep_acs.log", replace 
clear all 

* --- Drop tracker --- 
capture frame drop dropcounts
frame create dropcounts int step str40 step_label double n_remaining 

capture program drop log_step
program define log_step
	args step step_label 
	frame post dropcounts (`step') ("`step_label'") (_N)
end 


* Load Data
use "data/clean_data/acs_5pct.dta", clear 
// use "data/raw_data/usa_00023.dta", clear 

log_step 0 "Starting sample"


* --------------------------------------
* --- RESTRICT TO WORKING AGE ADULTS ---
* --------------------------------------
keep if age >= 15 & age >= 64

log_step 1 "Age < 15 or age > 64"


* -----------------------------------
* --- RESTRICT TO EMPLOYED PEOPLE ---
* -----------------------------------
keep if classwkr == 2

log_step 2 "Not wage/slary worker"

* ----------------------------
* --- DROP IF INCWAGE == 0 --- 
* ----------------------------
drop if incwage == 0

log_step 3 "Zero wage income"


* -------------------------------------------------
* --- CONVERT NOMINAL EARNINGS TO REAL EARNINGS ---
* -------------------------------------------------

* Merge CPI Data by Year 
merge m:1 year using "data/clean_data/annual_cpi.dta"
drop if _merge == 2
drop _merge

summarize cpi if year == 2024 // base year
scalar cpi_base = r(mean)

gen incwage_real = incwage * (cpi_base / cpi)
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

log_step 4 "Full NCA ban"

drop full_flag

* ---------------------------
* --- (2) DROP HOURLY BAN ---
* ---------------------------
* Create flag 
gen hourly_flag = !missing(eff_hourly_year) & eff_hourly_year <= `last_year'

* Drop affected individuals 
drop if hourly_flag == 1

log_step 5 "Hourly-worker NCA ban"

drop hourly_flag

* --------------------------
* --- (3) DROP OTHER BAN ---
* --------------------------
* Create flag 
gen other_flag = !missing(eff_other_year) & eff_other_year <= `last_year'

* Drop affected individuals 
drop if other_flag == 1

log_step 6 "Other NCA ban"

drop other_flag

* ---------------------------------
* --- (4) DROP INDUSTRY/OCC BAN ---
* ---------------------------------

* --- FIX OCC AND IND CODES IN ACS ---
* Note: OCC and IND are supposed to be a 4-digit codes. But leading zeros appear  
* to have been eliminated. Should add them back in. 

* Convert IND codes to 4-digit strings 
tostring ind, replace format(%04.0f)

* Convert OCC codes to 4-digit strings 
tostring occ, replace format(%04.0f)


* --- DROP LAWYERS --- 
* NOTE: The OCC code for lawyers is always 2100. 
drop if occ == "2100"

log_step 7 "Lawyers"


* --- MERGE OCC-EXCLUSION CROSSWALK DATA --- 
* Tag ACS "occ" vintage
gen str7 occ_vintage = ""
replace occ_vintage = "2005-09" if inrange(year, 2005, 2009)
replace occ_vintage = "2010-11" if inrange(year, 2010, 2011)
replace occ_vintage = "2012-17" if inrange(year, 2012, 2017)
replace occ_vintage = "2018-24" if inrange(year, 2018, 2024)

* Merge on statefip x occ_vintage x occ (UNIQUE!)
merge m:1 statefip occ_vintage occ using "data/clean_data/occ_exclusions.dta", ///
	keep(master match) nogen 

* Drop observations 
drop if drop_occ == 1

log_step 8 "Occupation exclusion"

drop drop_occ // keep occ_vintage for both drop


* --- MERGE IND-EXCLUSION CROSSWALK DATA --- 
* Tag ACS "ind" vintage
gen str7 ind_vintage = ""
replace ind_vintage = "2003-07" if inrange(year, 2003, 2007)
replace ind_vintage = "2008-12" if inrange(year, 2008, 2012)
replace ind_vintage = "2013-17" if inrange(year, 2013, 2017)
replace ind_vintage = "2018-22" if inrange(year, 2018, 2022)
replace ind_vintage = "2023-27" if inrange(year, 2023, 2027)

* Merge on statefip x ind_vintage x ind (UNIQUE!)
merge m:1 statefip ind_vintage ind using "data/clean_data/ind_exclusions.dta", ///
	keep(master match) nogen 

* Drop observations 
drop if drop_ind == 1

log_step 9 "Industry exclusion"

drop drop_ind // keep ind_vintage for both drop 


* --- MERGE BOTH-EXCLUSION CROSSWALK DATA --- 
merge m:1 statefip occ_vintage occ ind_vintage ind using ///
	"data/clean_data/both_exclusions.dta", keep(master match) nogen

drop if drop_both == 1

log_step 10 "Occupation x Industry exclusion"

drop drop_both occ_vintage ind_vintage


* --------------------------
* --- Plotting Drop Info --- 
* --------------------------
* --- Compute drops --- 
frame dropcounts {
	sort step
	gen double n_dropped = n_remaining[_n-1] - n_remaining
	
	quietly summarize n_remaining if step == 0	
	gen double pct_dropped = 100 * n_dropped / r(mean) // precent of original
	
	list step step_label n_remaining n_dropped pct_dropped, noobs sep(0) abbrev(20)

	save "data/analysis_data/acs_drop_counts.dta", replace 
}


* NOTE: Below I an temporarily excluding dropps for "Other ban," since no
* observations are dropped for it. 

* --- Graph: Observations dropped --- 
frame dropcounts {
	graph hbar (asis) n_dropped if step > 0 & step != 6, ///
		over(step_label, sort(step) label(labsize(small))) ///
		bar(1, color(navy)) ///
		blabel(bar, format(%12.0fc) size(vsmall)) ///
		ytitle("Observations dropped") ylabel(, nogrid format(%12.0fc)) ///
		graphregion(margin(r+20))
	graph export "output/figures/acs_drop_counts.pdf", as(pdf) replace
}


* --- Graph: Percent dropped --- 
* NOTE: Currently "precent of original sample." May want to reframe this.
frame dropcounts {
	graph hbar (asis) pct_dropped if step > 0 & step != 6, ///
		over(step_label, sort(step) label(labsize(small))) ///
		bar(1, color(navy)) ///
		blabel(bar, format(%12.0fc) size(vsmall)) ///
		ytitle("Percent dropped") ylabel(, nogrid format(%12.0fc)) ///
		graphregion(margin(r+20))
	graph export "output/figures/acs_drop_pct.pdf", as(pdf) replace 
}


* --- Graph: Remaining Observations --- 
frame dropcounts {
	graph hbar (asis) n_remaining if step > 0 & step != 6, ///
		over(step_label, sort(step) label(labsize(small))) ///
		bar(1, color(navy)) ///
		blabel(bar, format(%12.0fc) size(vsmall)) ///
		ytitle("Observations remaining") ylabel(, nogrid format(%12.0fc)) ///
		graphregion(margin(r+20))
	graph export "output/figures/acs_obs_remaining.pdf", as(pdf) replace
}



* -----------------------------------------------
* --- GENERATE HIGH-VS-LOW NCA INCIDENCE FLAG --- 
* -----------------------------------------------

* NOTE: See "IPUMS_IND_prefix_map_NCA_industries_CLAUDE.xlsx" for mapping of 
* NAICS sectors in Starr et al. (2021) to IPUMS codes. Note that the two-digit
* prefixes do not change across years. 

* Generate 2-digit version of IND code 
gen ind2 = substr(ind, 1, 2)
destring ind2, replace 
order ind2, after(ind)

* Generate High-incidence flag 
gen high_use = (inlist(ind2, 3, 4) | /// // Mining + Extraction 
	inrange(ind2, 10, 45) | /// // Manufacturing; Wholesale 
	inrange(ind2, 64, 69) | /// // Information; Finance, Insurance 
	inrange(ind2, 72, 78)) // Professional...; Adminstrative...; Education...
order high_use, after(ind2)
replace high_use = 0 if ind == "7570"
drop ind2

label define high_use_lbl 0 "Low-Use" 1 "High-Use"
label values high_use high_use_lbl

* --------------------------
* --- SAVE ANALYSIS DATA --- 
* --------------------------
// save "data/analysis_data/acs_analysis.dta", replace 
save "data/analysis_data/acs_5pct_analysis.dta", replace



log close 

