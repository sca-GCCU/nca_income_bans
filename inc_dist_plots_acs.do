* Title: Make Income Distribution Plots from the ACS Data 

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
// cd "/home/scanast/nca_income_bans" // for cluster runs 
capture log close 
log using "logs/inc_dist_plots_acs.log", replace 
clear all 

* Load data 
// use "data/analysis_data/acs_analysis.dta", clear 
use "data/analysis_data/acs_5pct_analysis.dta", clear 

// * Winsorize incwage  
// winsor2 incwage, cuts(1 99) by(statefip year)

* NOTE: The lower bin edge is inclusive, while the upper bin edge is exclusive
* (i.e., it is the start of the next bin and included there). 
// * Little test of the above: 
// preserve
// clear
// input x
// 0
// 10000
// 25000
// 25000
// 40000
// end
//
// histogram x, start(0) width(25000) frequency addlabels ///
//     xlabel(0(25000)50000) ylabel(0(1)4, grid) name(test_hist, replace)
//
// restore


* ----------------------------------
* -- STATES WITH ONE INCOME BANS ---
* ---------------------------------- 
* ----------------
* --- COLORADO ---
* ----------------
* --- Prep data for CO plots --- 
* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "08"
local co_ban_year = r(mean)
summarize inc_threshold1 if statefip == "08"
local co_threshold = r(mean)
local co_threshold_fmt = strtrim(string(`co_threshold', "%12.0fc"))

* Relative income (Colorado threshold applied to all states)
cap drop inc_rel
gen inc_rel = incwage - `co_threshold'

* Pre/post using Colorado's ban year for all states
cap drop post_co
gen post_co = (year >= `co_ban_year')

* Panel variable: Colorado vs. control states
cap drop co_group
gen co_group = .
replace co_group = 1 if statefip == "08"
replace co_group = 2 if missing(eff_inc1_year) // the never-treated 
label define co_group_lbl 1 "Colorado" 2 "Never-Treated States", replace 
label values co_group co_group_lbl

local co_w  = 25000
local co_lo = -100000
local co_hi = 100000

* --- Relative income dist plot --- 
twoway ///
	(histogram inc_rel if post_co == 0 & inrange(inc_rel, `co_lo', `co_hi'-1), ///
		width(`co_w') start(`co_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post_co == 1 & inrange(inc_rel, `co_lo', `co_hi'-1), ///
		width(`co_w') start(`co_lo') fraction color(maroon%30)) ///
	if !missing(co_group) ///
	, by(co_group, note("") legend(position(6))) ///
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Annual earnings relative to Colorado threshold (\$`co_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`co_lo'(`co_w')`co_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/co_vs_control_rel_incdist_prepost.pdf", as(pdf) replace


* --- Absolute income dist plot --- 
local co_upper = 200000

twoway ///
	(histogram incwage if post_co == 0 & incwage < `co_upper', ///
		width(`co_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post_co == 1 & incwage < `co_upper', ///
		width(`co_w') start(0) fraction color(maroon%30)) ///
	if !missing(co_group) ///
	, by(co_group, note("") legend(position(6))) ///
		xline(`co_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Colorado threshold (\$`co_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`co_w')`co_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/co_vs_control_abs_incdist_prepost.pdf", as(pdf) replace

* Drop variables that are no longer needed 
drop post_co co_group



* ----------------------------
* --- DISTRICT OF COLUMBIA --- 
* ----------------------------
* --- Prep data for DC plots --- 
* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "11"
local dc_ban_year = r(mean)
summarize inc_threshold1 if statefip == "11"
local dc_threshold = r(mean)
local dc_threshold_fmt = strtrim(string(`dc_threshold', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `dc_threshold'

* Pre/post using D.C.'s ban year 
cap drop post_dc
gen post_dc = (year >= `dc_ban_year')

* Panel variable: District of Columbia vs. Never-Treated States
cap drop dc_group
gen dc_group = .
replace dc_group = 1 if statefip == "11"
replace dc_group = 2 if missing(eff_inc1_year) // never-treated states
label define dc_group_lbl 1 "District of Columbia" 2 "Never-Treated States", replace
label values dc_group dc_group_lbl

local dc_w  = 25000
local dc_lo = -150000
local dc_hi = 100000

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post_dc == 0 & inrange(inc_rel, `dc_lo', `dc_hi'-1), ///
		width(`dc_w') start(`dc_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post_dc == 1 & inrange(inc_rel, `dc_lo', `dc_hi'-1), ///
		width(`dc_w') start(`dc_lo') fraction color(maroon%30)) /// 
	if !missing(dc_group) /// 
	, by(dc_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to District of Columbia threshold (\$`dc_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`dc_lo'(`dc_w')`dc_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/dc_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local dc_upper = 250000

twoway ///
	(histogram incwage if post_dc == 0 & incwage < `dc_upper', ///
		width(`dc_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post_dc == 1 & incwage < `dc_upper', ///
		width(`dc_w') start(0) fraction color(maroon%30)) ///
	if !missing(dc_group) ///
	, by(dc_group, note("") legend(position(6))) ///
		xline(`dc_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around District of Columbia threshold (\$`dc_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`dc_w')`dc_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/dc_vs_control_abs_incdist_prepost.pdf", as(pdf) replace

* Drop variables that are no longer needed 
drop post_dc dc_group


* -------------
* --- MAINE ---  
* -------------
* --- Prep data for ME plots ---
* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "23"
local me_ban_year = r(mean)
summarize inc_threshold1 if statefip == "23"
local me_threshold = r(mean)
local me_threshold_fmt = strtrim(string(`me_threshold', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `me_threshold'

* Pre/post using Maine's ban year 
cap drop post_me
gen post_me = (year >= `me_ban_year')

* Panel variable: Maine vs. Never-Treated States
cap drop me_group
gen me_group = .
replace me_group = 1 if statefip == "23"
replace me_group = 2 if missing(eff_inc1_year) // never-treated states
label define me_group_lbl 1 "Maine" 2 "Never-Treated States", replace
label values me_group me_group_lbl

local me_w  = 25000
local me_lo = -50000
local me_hi = 100000

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post_me == 0 & inrange(inc_rel, `me_lo', `me_hi'-1), ///
		width(`me_w') start(`me_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post_me == 1 & inrange(inc_rel, `me_lo', `me_hi'-1), ///
		width(`me_w') start(`me_lo') fraction color(maroon%30)) /// 
	if !missing(me_group) /// 
	, by(me_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Maine threshold (\$`me_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`me_lo'(`me_w')`me_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/me_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local me_upper = 150000

twoway ///
	(histogram incwage if post_me == 0 & incwage < `me_upper', ///
		width(`me_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post_me == 1 & incwage < `me_upper', ///
		width(`me_w') start(0) fraction color(maroon%30)) ///
	if !missing(me_group) ///
	, by(me_group, note("") legend(position(6))) ///
		xline(`me_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Maine threshold (\$`me_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`me_w')`me_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/me_vs_control_abs_incdist_prepost.pdf", as(pdf) replace

* Drop variables that are no longer needed 
drop post_me me_group



* ---------------------
* --- New Hampshire --- 
* ---------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "33"
local nh_ban_year = r(mean)
summarize inc_threshold1 if statefip == "33"
local nh_threshold = r(mean)
local nh_threshold_fmt = strtrim(string(`nh_threshold', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `nh_threshold'

* Pre/post using New Hampshire's ban year 
cap drop post_nh
gen post_nh = (year >= `nh_ban_year')

* Panel variable: New Hampshire vs. Never-Treated States
cap drop nh_group
gen nh_group = .
replace nh_group = 1 if statefip == "33"
replace nh_group = 2 if missing(eff_inc1_year) // never-treated states
label define nh_group_lbl 1 "New Hampshire" 2 "Never-Treated States", replace
label values nh_group nh_group_lbl

local nh_w  = 10000
local nh_lo = -30000
local nh_hi = 100000

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post_nh == 0 & inrange(inc_rel, `nh_lo', `nh_hi'-1), ///
		width(`nh_w') start(`nh_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post_nh == 1 & inrange(inc_rel, `nh_lo', `nh_hi'-1), ///
		width(`nh_w') start(`nh_lo') fraction color(maroon%30)) /// 
	if !missing(nh_group) /// 
	, by(nh_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to New Hampshire threshold (\$`nh_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`nh_lo'(`nh_w')`nh_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/nh_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local nh_upper = 130000

twoway ///
	(histogram incwage if post_nh == 0 & incwage < `nh_upper', ///
		width(`nh_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post_nh == 1 & incwage < `nh_upper', ///
		width(`nh_w') start(0) fraction color(maroon%30)) ///
	if !missing(nh_group) ///
	, by(nh_group, note("") legend(position(6))) ///
		xline(`nh_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around New Hampshire threshold (\$`nh_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`nh_w')`nh_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/nh_vs_control_abs_incdist_prepost.pdf", as(pdf) replace

* Drop variables that are no longer needed 
drop post_nh nh_group




* --------------------
* --- RHODE ISLAND --- 
* --------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "44"
local ri_ban_year = r(mean)
summarize inc_threshold1 if statefip == "44"
local ri_threshold = r(mean)
local ri_threshold_fmt = strtrim(string(`ri_threshold', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `ri_threshold'

* Pre/post using Rhode Island's ban year 
cap drop post_ri
gen post_ri = (year >= `ri_ban_year')

* Panel variable: Rhode Island vs. Never-Treated States
cap drop ri_group
gen ri_group = .
replace ri_group = 1 if statefip == "44"
replace ri_group = 2 if missing(eff_inc1_year) // never-treated states
label define ri_group_lbl 1 "Rhode Island" 2 "Never-Treated States", replace
label values ri_group ri_group_lbl

local ri_w  = 10000
local ri_lo = -30000
local ri_hi = 100000

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post_ri == 0 & inrange(inc_rel, `ri_lo', `ri_hi'-1), ///
		width(`ri_w') start(`ri_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post_ri == 1 & inrange(inc_rel, `ri_lo', `ri_hi'-1), ///
		width(`ri_w') start(`ri_lo') fraction color(maroon%30)) /// 
	if !missing(ri_group) /// 
	, by(ri_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Rhode Island threshold (\$`ri_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`ri_lo'(`ri_w')`ri_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/ri_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local ri_upper = 130000

twoway ///
	(histogram incwage if post_ri == 0 & incwage < `ri_upper', ///
		width(`ri_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post_ri == 1 & incwage < `ri_upper', ///
		width(`ri_w') start(0) fraction color(maroon%30)) ///
	if !missing(ri_group) ///
	, by(ri_group, note("") legend(position(6))) ///
		xline(`ri_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Rhode Island threshold (\$`ri_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`ri_w')`ri_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/ri_vs_control_abs_incdist_prepost.pdf", as(pdf) replace

* Drop variables that are no longer needed 
drop post_ri ri_group



* ----------------
* --- VIRGINIA --- 
* ----------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "51"
local va_ban_year = r(mean)
summarize inc_threshold1 if statefip == "51"
local va_threshold = r(mean)
local va_threshold_fmt = strtrim(string(`va_threshold', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `va_threshold'

* Pre/post using Virginia's ban year 
cap drop post_va
gen post_va = (year >= `va_ban_year')

* Panel variable: Virginia vs. Never-Treated States
cap drop va_group
gen va_group = .
replace va_group = 1 if statefip == "51"
replace va_group = 2 if missing(eff_inc1_year) // never-treated states
label define va_group_lbl 1 "Virginia" 2 "Never-Treated States", replace
label values va_group va_group_lbl

local va_w  = 10000
local va_lo = -60000
local va_hi = 100000

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post_va == 0 & inrange(inc_rel, `va_lo', `va_hi'-1), ///
		width(`va_w') start(`va_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post_va == 1 & inrange(inc_rel, `va_lo', `va_hi'-1), ///
		width(`va_w') start(`va_lo') fraction color(maroon%30)) /// 
	if !missing(va_group) /// 
	, by(va_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Virginia threshold (\$`va_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`va_lo'(`va_w')`va_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/va_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local va_upper = 160000

twoway ///
	(histogram incwage if post_va == 0 & incwage < `va_upper', ///
		width(`va_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post_va == 1 & incwage < `va_upper', ///
		width(`va_w') start(0) fraction color(maroon%30)) ///
	if !missing(va_group) ///
	, by(va_group, note("") legend(position(6))) ///
		xline(`va_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Virginia threshold (\$`va_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`va_w')`va_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/va_vs_control_abs_incdist_prepost.pdf", as(pdf) replace

* Drop variables that are no longer needed 
drop post_va va_group



* ------------------
* --- WASHINGTON --- 
* ------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "53"
local wa_ban_year = r(mean)
summarize inc_threshold1 if statefip == "53"
local wa_threshold = r(mean)
local wa_threshold_fmt = strtrim(string(`wa_threshold', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `wa_threshold'

* Pre/post using Washington's ban year 
cap drop post_wa
gen post_wa = (year >= `wa_ban_year')

* Panel variable: Washington vs. Never-Treated States
cap drop wa_group
gen wa_group = .
replace wa_group = 1 if statefip == "53"
replace wa_group = 2 if missing(eff_inc1_year) // never-treated states
label define wa_group_lbl 1 "Washington" 2 "Never-Treated States", replace
label values wa_group wa_group_lbl

local wa_w  = 25000
local wa_lo = -100000
local wa_hi = 100000

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post_wa == 0 & inrange(inc_rel, `wa_lo', `wa_hi'-1), ///
		width(`wa_w') start(`wa_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post_wa == 1 & inrange(inc_rel, `wa_lo', `wa_hi'-1), ///
		width(`wa_w') start(`wa_lo') fraction color(maroon%30)) /// 
	if !missing(wa_group) /// 
	, by(wa_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Washington threshold (\$`wa_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`wa_lo'(`wa_w')`wa_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/wa_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local wa_upper = 200000

twoway ///
	(histogram incwage if post_wa == 0 & incwage < `wa_upper', ///
		width(`wa_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post_wa == 1 & incwage < `wa_upper', ///
		width(`wa_w') start(0) fraction color(maroon%30)) ///
	if !missing(wa_group) ///
	, by(wa_group, note("") legend(position(6))) ///
		xline(`wa_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Washington threshold (\$`wa_threshold_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`wa_w')`wa_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/wa_vs_control_abs_incdist_prepost.pdf", as(pdf) replace

* Drop variables that are no longer needed 
drop post_wa wa_group






* ----------------------------------
* -- STATES WITH TWO INCOME BANS ---
* ---------------------------------- 
* ----------------
* --- ILLINOIS ---
* ----------------
* Panel variable: Illinois vs. Never-Treated States
cap drop il_group
gen il_group = .
replace il_group = 1 if statefip == "17"
replace il_group = 2 if missing(eff_inc1_year) // never-treated states
label define il_group_lbl 1 "Illinois" 2 "Never-Treated States", replace
label values il_group il_group_lbl

* --- LAW 1 --- 
* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "17"
local il_ban_year1 = r(mean)
summarize inc_threshold1 if statefip == "17"
local il_threshold1 = r(mean)
local il_threshold1_fmt = strtrim(string(`il_threshold1', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `il_threshold1'

* Pre/post using Illinois's ban year 
cap drop post1_il
gen post1_il = (year >= `il_ban_year1')

local il_w  = 5000
local il_lo = -30000
local il_hi = 100000
local il_lab = 2*`il_w'

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post1_il == 0 & inrange(inc_rel, `il_lo', `il_hi'-1), ///
		width(`il_w') start(`il_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post1_il == 1 & inrange(inc_rel, `il_lo', `il_hi'-1), ///
		width(`il_w') start(`il_lo') fraction color(maroon%30)) /// 
	if !missing(il_group) /// 
	, by(il_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Illinois `il_ban_year1' threshold (\$`il_threshold1_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`il_lo'(`il_lab')`il_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/il1_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local il_upper = 130000

twoway ///
	(histogram incwage if post1_il == 0 & incwage < `il_upper', ///
		width(`il_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post1_il == 1 & incwage < `il_upper', ///
		width(`il_w') start(0) fraction color(maroon%30)) ///
	if !missing(il_group) ///
	, by(il_group, note("") legend(position(6))) ///
		xline(`il_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Illinois `il_ban_year1' threshold (\$`il_threshold1_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`il_lab')`il_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/il1_vs_control_abs_incdist_prepost.pdf", as(pdf) replace



* --- LAW 2 --- 
* Storing ban year and income threshold 
summarize eff_inc2_year if statefip == "17"
local il_ban_year2 = r(mean)
summarize inc_threshold2 if statefip == "17"
local il_threshold2 = r(mean)
local il_threshold2_fmt = strtrim(string(`il_threshold2', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `il_threshold2'

* Pre/post using Illinois's ban year 
cap drop post2_il
gen post2_il = (year >= `il_ban_year2')

local il_w  = 5000
local il_lo = -75000
local il_hi = 55000
local il_lab = 2*`il_w'

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post2_il == 0 & inrange(inc_rel, `il_lo', `il_hi'-1), ///
		width(`il_w') start(`il_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post2_il == 1 & inrange(inc_rel, `il_lo', `il_hi'-1), ///
		width(`il_w') start(`il_lo') fraction color(maroon%30)) /// 
	if !missing(il_group) /// 
	, by(il_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Illinois `il_ban_year2' threshold (\$`il_threshold2_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`il_lo'(`il_lab')`il_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/il2_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local il_upper = 130000

twoway ///
	(histogram incwage if post2_il == 0 & incwage < `il_upper', ///
		width(`il_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post2_il == 1 & incwage < `il_upper', ///
		width(`il_w') start(0) fraction color(maroon%30)) ///
	if !missing(il_group) ///
	, by(il_group, note("") legend(position(6))) ///
		xline(`il_threshold2', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Illinois `il_ban_year2' threshold (\$`il_threshold2_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`il_lab')`il_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/il2_vs_control_abs_incdist_prepost.pdf", as(pdf) replace


* Drop variables that are no longer needed 
drop post1_il post2_il il_group





* ----------------
* --- MARYLAND --- 
* ----------------
* Panel variable: Maryland vs. Never-Treated States
cap drop md_group
gen md_group = .
replace md_group = 1 if statefip == "24"
replace md_group = 2 if missing(eff_inc1_year) // never-treated states
label define md_group_lbl 1 "Maryland" 2 "Never-Treated States", replace
label values md_group md_group_lbl

* --- LAW 1 --- 
* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "24"
local md_ban_year1 = r(mean)
summarize inc_threshold1 if statefip == "24"
local md_threshold1 = r(mean)
local md_threshold1_fmt = strtrim(string(`md_threshold1', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `md_threshold1'

* Pre/post using Maryland's ban year 
cap drop post1_md
gen post1_md = (year >= `md_ban_year1')

local md_w  = 10000
local md_lo = -30000
local md_hi = 100000
// local md_lab = 2*`md_w'

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post1_md == 0 & inrange(inc_rel, `md_lo', `md_hi'-1), ///
		width(`md_w') start(`md_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post1_md == 1 & inrange(inc_rel, `md_lo', `md_hi'-1), ///
		width(`md_w') start(`md_lo') fraction color(maroon%30)) /// 
	if !missing(md_group) /// 
	, by(md_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Maryland `md_ban_year1' threshold (\$`md_threshold1_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`md_lo'(`md_w')`md_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/md1_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local md_upper = 130000

twoway ///
	(histogram incwage if post1_md == 0 & incwage < `md_upper', ///
		width(`md_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post1_md == 1 & incwage < `md_upper', ///
		width(`md_w') start(0) fraction color(maroon%30)) ///
	if !missing(md_group) ///
	, by(md_group, note("") legend(position(6))) ///
		xline(`md_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Maryland `md_ban_year1' threshold (\$`md_threshold1_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`md_w')`md_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/md1_vs_control_abs_incdist_prepost.pdf", as(pdf) replace



* --- LAW 2 --- 
* Storing ban year and income threshold 
summarize eff_inc2_year if statefip == "24"
local md_ban_year2 = r(mean)
summarize inc_threshold2 if statefip == "24"
local md_threshold2 = r(mean)
local md_threshold2_fmt = strtrim(string(`md_threshold2', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `md_threshold2'

* Pre/post using Maryland's ban year 
cap drop post2_md
gen post2_md = (year >= `md_ban_year2')

local md_w  = 10000
local md_lo = -40000
local md_hi = 100000
// local md_lab = 2*`md_w'

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post2_md == 0 & inrange(inc_rel, `md_lo', `md_hi'-1), ///
		width(`md_w') start(`md_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post2_md == 1 & inrange(inc_rel, `md_lo', `md_hi'-1), ///
		width(`md_w') start(`md_lo') fraction color(maroon%30)) /// 
	if !missing(md_group) /// 
	, by(md_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Maryland `md_ban_year2' threshold (\$`md_threshold2_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`md_lo'(`md_w')`md_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/md2_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local md_upper = 140000

twoway ///
	(histogram incwage if post2_md == 0 & incwage < `md_upper', ///
		width(`md_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post2_md == 1 & incwage < `md_upper', ///
		width(`md_w') start(0) fraction color(maroon%30)) ///
	if !missing(md_group) ///
	, by(md_group, note("") legend(position(6))) ///
		xline(`md_threshold2', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Maryland `md_ban_year2' threshold (\$`md_threshold2_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`md_w')`md_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/md2_vs_control_abs_incdist_prepost.pdf", as(pdf) replace


* Drop variables that are no longer needed 
drop post1_md post2_md md_group



* --------------
* --- OREGON ---   
* --------------
* Panel variable: Oregon vs. Never-Treated States
cap drop or_group
gen or_group = .
replace or_group = 1 if statefip == "41"
replace or_group = 2 if missing(eff_inc1_year) // never-treated states
label define or_group_lbl 1 "Oregon" 2 "Never-Treated States", replace
label values or_group or_group_lbl

* --- LAW 1 --- 
* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "41"
local or_ban_year1 = r(mean)
summarize inc_threshold1 if statefip == "41"
local or_threshold1 = r(mean)
local or_threshold1_fmt = strtrim(string(`or_threshold1', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `or_threshold1'

* Pre/post using Oregon's ban year 
cap drop post1_or
gen post1_or = (year >= `or_ban_year1')

local or_w  = 10000
local or_lo = -70000
local or_hi = 100000
// local or_lab = 2*`or_w'

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post1_or == 0 & inrange(inc_rel, `or_lo', `or_hi'-1), ///
		width(`or_w') start(`or_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post1_or == 1 & inrange(inc_rel, `or_lo', `or_hi'-1), ///
		width(`or_w') start(`or_lo') fraction color(maroon%30)) /// 
	if !missing(or_group) /// 
	, by(or_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Oregon `or_ban_year1' threshold (\$`or_threshold1_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`or_lo'(`or_w')`or_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/or1_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local or_upper = 170000

twoway ///
	(histogram incwage if post1_or == 0 & incwage < `or_upper', ///
		width(`or_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post1_or == 1 & incwage < `or_upper', ///
		width(`or_w') start(0) fraction color(maroon%30)) ///
	if !missing(or_group) ///
	, by(or_group, note("") legend(position(6))) ///
		xline(`or_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Oregon `or_ban_year1' threshold (\$`or_threshold1_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`or_w')`or_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/or1_vs_control_abs_incdist_prepost.pdf", as(pdf) replace



* --- LAW 2 --- 
* Storing ban year and income threshold 
summarize eff_inc2_year if statefip == "41"
local or_ban_year2 = r(mean)
summarize inc_threshold2 if statefip == "41"
local or_threshold2 = r(mean)
local or_threshold2_fmt = strtrim(string(`or_threshold2', "%12.0fc"))

* Relative income 
cap drop inc_rel
gen inc_rel = incwage - `or_threshold2'

* Pre/post using Oregon's ban year 
cap drop post2_or
gen post2_or = (year >= `or_ban_year2')

local or_w  = 25000
local or_lo = -100000
local or_hi = 100000
// local or_lab = 2*`or_w'

* --- Relative income dist plot --- 
twoway /// 
	(histogram inc_rel if post2_or == 0 & inrange(inc_rel, `or_lo', `or_hi'-1), ///
		width(`or_w') start(`or_lo') fraction color(navy%30)) ///
	(histogram inc_rel if post2_or == 1 & inrange(inc_rel, `or_lo', `or_hi'-1), ///
		width(`or_w') start(`or_lo') fraction color(maroon%30)) /// 
	if !missing(or_group) /// 
	, by(or_group, note("") legend(position(6))) /// 
		xline(0, lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///	
		xtitle("Annual earnings relative to Oregon `or_ban_year2' threshold (\$`or_threshold2_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(`or_lo'(`or_w')`or_hi', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/or2_vs_control_rel_incdist_prepost.pdf", as(pdf) replace 


* --- Absolute income dist plot --- 
local or_upper = 200000

twoway ///
	(histogram incwage if post2_or == 0 & incwage < `or_upper', ///
		width(`or_w') start(0) fraction color(navy%30)) ///
	(histogram incwage if post2_or == 1 & incwage < `or_upper', ///
		width(`or_w') start(0) fraction color(maroon%30)) ///
	if !missing(or_group) ///
	, by(or_group, note("") legend(position(6))) ///
		xline(`or_threshold2', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Pre" 2 "Post") rows(1)) ///
		xtitle("Earnings around Oregon `or_ban_year2' threshold (\$`or_threshold2_fmt')") ///		
		ytitle("Fraction") ///
		xlabel(0(`or_w')`or_upper', labsize(small) angle(45) format(%9.0fc) nogrid) ///
		ylabel(, nogrid)
graph export "output/figures/or2_vs_control_abs_incdist_prepost.pdf", as(pdf) replace


* Drop variables that are no longer needed 
drop post1_or post2_or or_group





* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
* ---------------------------------- OLD CODE ----------------------------------
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------

// * ----------------------------------
// * -- STATES WITH TWO INCOME BANS ---
// * ---------------------------------- 
// * ----------------
// * --- ILLINOIS ---
// * ----------------
//
// * Storing ban year and income threshold 
// summarize eff_inc1_year if statefip == "17"
// local il_ban_year1 = r(mean)
// summarize inc_threshold1 if statefip == "17"
// local il_threshold1 = r(mean)
// summarize eff_inc2_year if statefip == "17"
// local il_ban_year2 = r(mean)
// summarize inc_threshold2 if statefip == "17"
// local il_threshold2 = r(mean)
//
//
// * --- PRE/POST --- 
// * Normal incwage
// twoway /// 
// 	(histogram incwage if statefip == "17" & year < `il_ban_year1' ///
// 		& incwage <= 300000, ///
// 		width(25000) fraction color(navy%30)) ///
// 	(histogram incwage if statefip == "17" & year >= `il_ban_year1' ///
// 		& year < `il_ban_year2' & incwage <= 300000, ///
// 		width(25000) fraction color(maroon%30)) ///
// 	(histogram incwage if statefip == "17" & year >= `il_ban_year2' ///
// 		& incwage <= 300000, ///
// 		width(25000) fraction color(green%30)) ///
// 	, xline(`il_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
// 	xline(`il_ban_threshold2', lpattern(dash) lcolor(black) lwidth(thin)) ///
// 		legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) /// 
// 		xtitle("Annual Earnings") ///
// 		ytitle("Fraction") ///
// 		xlabel(, nogrid) /// 
// 		ylabel(, nogrid) 
// graph export "output/figures/il_incdist_prepost.pdf", as(pdf) replace
//
//
// * ----------------
// * --- MARYLAND --- 
// * ----------------
//
// * Storing ban year and income threshold 
// summarize eff_inc1_year if statefip == "24"
// local md_ban_year1 = r(mean)
// summarize inc_threshold1 if statefip == "24"
// local md_threshold1 = r(mean)
// summarize eff_inc2_year if statefip == "24"
// local md_ban_year2 = r(mean)
// summarize inc_threshold2 if statefip == "24"
// local md_threshold2 = r(mean)
//
//
// * --- PRE/POST --- 
// * Normal incwage
// twoway /// 
// 	(histogram incwage if statefip == "24" & year < `md_ban_year1' ///
// 		& incwage <= 300000, ///
// 		width(25000) fraction color(navy%30)) ///
// 	(histogram incwage if statefip == "24" & year >= `md_ban_year1' ///
// 		& year < `md_ban_year2' & incwage <= 300000, ///
// 		width(25000) fraction color(maroon%30)) ///
// 	(histogram incwage if statefip == "24" & year >= `md_ban_year2' ///
// 		& incwage <= 300000, ///
// 		width(25000) fraction color(green%30)) ///
// 	, xline(`md_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
// 	xline(`md_threshold2', lpattern(dash) lcolor(black) lwidth(thin)) ///
// 		legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) /// 
// 		xtitle("Annual Earnings") ///
// 		ytitle("Fraction") ///
// 		xlabel(, nogrid) /// 
// 		ylabel(, nogrid) 
// graph export "output/figures/md_incdist_prepost.pdf", as(pdf) replace
//
//
//
// * --------------
// * --- OREGON ---   
// * --------------
//
// * Storing ban year and income threshold 
// summarize eff_inc1_year if statefip == "41"
// local or_ban_year1 = r(mean)
// summarize inc_threshold1 if statefip == "41"
// local or_threshold1 = r(mean)
// summarize eff_inc2_year if statefip == "41"
// local or_ban_year2 = r(mean)
// summarize inc_threshold2 if statefip == "41"
// local or_threshold2 = r(mean)
//
//
// * --- PRE/POST --- 
// * Normal incwage
// twoway /// 
// 	(histogram incwage if statefip == "41" & year < `or_ban_year1' ///
// 		& incwage <= 300000, ///
// 		width(25000) fraction color(navy%30)) ///
// 	(histogram incwage if statefip == "41" & year >= `or_ban_year1' ///
// 		& year < `or_ban_year2' & incwage <= 300000, ///
// 		width(25000) fraction color(maroon%30)) ///
// 	(histogram incwage if statefip == "41" & year >= `or_ban_year2' ///
// 		& incwage <= 300000, ///
// 		width(25000) fraction color(green%30)) ///
// 	, xline(`or_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
// 	xline(`or_threshold2', lpattern(dash) lcolor(black) lwidth(thin)) ///
// 		legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) /// 
// 		xtitle("Annual Earnings") ///
// 		ytitle("Fraction") ///
// 		xlabel(, nogrid) /// 
// 		ylabel(, nogrid) 
// graph export "output/figures/or_incdist_prepost.pdf", as(pdf) replace





log close 