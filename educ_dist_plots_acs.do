* Title: Make Education Distribution Plots from the ACS Data 

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
// cd "/home/scanast/nca_income_bans" // for cluster runs 
log using "logs/educ_dist_plots_acs.log", replace 
clear all 

* Load data 
// use "data/analysis_data/acs_analysis.dta", clear 
use "data/analysis_data/acs_5pct_analysis.dta", clear 


* --- DEFINING NEW EDUC CATEGORICAL VARIABLE --- 
gen educ_cat = .
replace educ_cat = 1 if educd <= 61 // "No Degree" 60 == "grade 12", not in data
replace educ_cat = 2 if educd >= 62 & educd <= 64 // "High School Degree"
replace educ_cat = 3 if educd >= 65 & educd <= 100 // "Some College"
replace educ_cat = 4 if educd == 101 // "Bachelor's Degree"
replace educ_cat = 5 if educd == 114 | educd == 115 | educd == 116 // "Higher Degree"

label define educ_cat_lbl 1 "No Degree" 2 "High School" 3 "Some College" ///
	4 "Bachelor's Degree" 5 "Higher Degree"
label values educ_cat educ_cat_lbl


* ----------------------------------
* -- STATES WITH ONE INCOME BANS ---
* ---------------------------------- 
* ----------------
* --- COLORADO ---
* ----------------
* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "08"
local co_ban_year = r(mean)
summarize inc_threshold1 if statefip == "08"
local co_threshold = r(mean)

twoway (histogram educ_cat if statefip == "08" & year < `co_ban_year', ///
		discrete fraction color(navy%50)) ///
       (histogram educ_cat if statefip == "08" & year >= `co_ban_year', ///
		discrete fraction color(maroon%50)), ///
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "Pre-ban" 2 "Post-ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/co_edudist_prepost.pdf", as(pdf) replace


 * ----------------------------
* --- DISTRICT OF COLUMBIA --- 
* ----------------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "11"
local dc_ban_year = r(mean)
summarize inc_threshold1 if statefip == "11"
local dc_threshold = r(mean)

twoway (histogram educ_cat if statefip == "11" & year < `dc_ban_year', ///
		discrete fraction color(navy%50)) ///
       (histogram educ_cat if statefip == "11" & year >= `dc_ban_year', ///
		discrete fraction color(maroon%50)), ///
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "Pre-ban" 2 "Post-ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/dc_edudist_prepost.pdf", as(pdf) replace

 
 
 * -------------
* --- MAINE ---  
* -------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "23"
local me_ban_year = r(mean)
summarize inc_threshold1 if statefip == "23"
local me_threshold = r(mean)

twoway (histogram educ_cat if statefip == "23" & year < `me_ban_year', ///
		discrete fraction color(navy%50)) ///
       (histogram educ_cat if statefip == "23" & year >= `me_ban_year', ///
		discrete fraction color(maroon%50)), ///
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "Pre-ban" 2 "Post-ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/me_edudist_prepost.pdf", as(pdf) replace



* ---------------------
* --- New Hampshire --- 
* ---------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "33"
local nh_ban_year = r(mean)
summarize inc_threshold1 if statefip == "33"
local nh_threshold = r(mean)

twoway (histogram educ_cat if statefip == "33" & year < `nh_ban_year', ///
		discrete fraction color(navy%50)) ///
       (histogram educ_cat if statefip == "33" & year >= `nh_ban_year', ///
		discrete fraction color(maroon%50)), ///
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "Pre-ban" 2 "Post-ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/nh_edudist_prepost.pdf", as(pdf) replace



* --------------------
* --- RHODE ISLAND --- 
* --------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "44"
local ri_ban_year = r(mean)
summarize inc_threshold1 if statefip == "44"
local ri_threshold = r(mean)

twoway (histogram educ_cat if statefip == "44" & year < `ri_ban_year', ///
		discrete fraction color(navy%50)) ///
       (histogram educ_cat if statefip == "44" & year >= `ri_ban_year', ///
		discrete fraction color(maroon%50)), ///
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "Pre-ban" 2 "Post-ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/ri_edudist_prepost.pdf", as(pdf) replace



* ----------------
* --- VIRGINIA --- 
* ----------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "51"
local va_ban_year = r(mean)
summarize inc_threshold1 if statefip == "51"
local va_threshold = r(mean)

twoway (histogram educ_cat if statefip == "51" & year < `va_ban_year', ///
		discrete fraction color(navy%50)) ///
       (histogram educ_cat if statefip == "51" & year >= `va_ban_year', ///
		discrete fraction color(maroon%50)), ///
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "Pre-ban" 2 "Post-ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/va_edudist_prepost.pdf", as(pdf) replace



* ------------------
* --- WASHINGTON --- 
* ------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "53"
local wa_ban_year = r(mean)
summarize inc_threshold1 if statefip == "53"
local wa_threshold = r(mean)

twoway (histogram educ_cat if statefip == "53" & year < `wa_ban_year', ///
		discrete fraction color(navy%50)) ///
       (histogram educ_cat if statefip == "53" & year >= `wa_ban_year', ///
		discrete fraction color(maroon%50)), ///
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "Pre-ban" 2 "Post-ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/wa_edudist_prepost.pdf", as(pdf) replace



* ----------------------------------
* -- STATES WITH TWO INCOME BANS ---
* ---------------------------------- 
* ----------------
* --- ILLINOIS ---
* ----------------
* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "17"
local il_ban_year1 = r(mean)
summarize inc_threshold1 if statefip == "17"
local il_threshold1 = r(mean)
summarize eff_inc2_year if statefip == "17"
local il_ban_year2 = r(mean)
summarize inc_threshold2 if statefip == "17"
local il_threshold2 = r(mean)

twoway (histogram educ_cat if statefip == "17" & year < `il_ban_year1', ///
		discrete fraction color(navy%30)) ///
       (histogram educ_cat if statefip == "17" & year >= `il_ban_year1' /// 
		& year < `il_ban_year2', ///
		discrete fraction color(maroon%30)) ///
	   (histogram educ_cat if statefip == "17" & year >= `il_ban_year2', ///
	    discrete fraction color(green%30)), /// 
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/il_edudist_prepost.pdf", as(pdf) replace



* ----------------
* --- MARYLAND --- 
* ----------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "24"
local md_ban_year1 = r(mean)
summarize inc_threshold1 if statefip == "24"
local md_threshold1 = r(mean)
summarize eff_inc2_year if statefip == "24"
local md_ban_year2 = r(mean)
summarize inc_threshold2 if statefip == "24"
local md_threshold2 = r(mean)

twoway (histogram educ_cat if statefip == "24" & year < `md_ban_year1', ///
		discrete fraction color(navy%30)) ///
       (histogram educ_cat if statefip == "24" & year >= `md_ban_year1' /// 
		& year < `md_ban_year2', ///
		discrete fraction color(maroon%30)) ///
	   (histogram educ_cat if statefip == "24" & year >= `md_ban_year2', ///
	    discrete fraction color(green%30)), /// 
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/md_edudist_prepost.pdf", as(pdf) replace



* --------------
* --- OREGON ---   
* --------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "41"
local or_ban_year1 = r(mean)
summarize inc_threshold1 if statefip == "41"
local or_threshold1 = r(mean)
summarize eff_inc2_year if statefip == "41"
local or_ban_year2 = r(mean)
summarize inc_threshold2 if statefip == "41"
local or_threshold2 = r(mean)

twoway (histogram educ_cat if statefip == "41" & year < `or_ban_year1', ///
		discrete fraction color(navy%30)) ///
       (histogram educ_cat if statefip == "41" & year >= `or_ban_year1' /// 
		& year < `or_ban_year2', ///
		discrete fraction color(maroon%30)) ///
	   (histogram educ_cat if statefip == "41" & year >= `or_ban_year2', ///
	    discrete fraction color(green%30)), /// 
	xlabel(1 2 3 4 5, valuelabel angle(45) nogrid) ///
	legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) ///
	ytitle("Fraction") ///
	xtitle("Education") ///
	ylabel(, nogrid) 
graph export "output/figures/or_edudist_prepost.pdf", as(pdf) replace





log close 