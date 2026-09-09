* Title: Make Income Distribution Plots from the ACS Data 

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
// cd "/home/scanast/nca_income_bans" // for cluster runs 
log using "logs/inc_dist_plots_acs.log", replace 
clear all 

* Load data 
// use "data/analysis_data/acs_analysis.dta", clear 
use "data/analysis_data/acs_5pct_analysis.dta", clear 


* Winsorize incwage  
winsor2 incwage, cuts(1 99) by(statefip year)



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

* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "08" & year < `co_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "08" & year >= `co_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`co_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/co_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "08" & year < `co_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "08" & year >= `co_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`co_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/co_incdist_w_prepost.pdf", as(pdf) replace


* --- TREAT/CONTROL --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip != "08" & year >= `co_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "08" & year >= `co_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`co_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Colorado")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/co_incdist_vcontrol.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip != "08" & year >= `co_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "08" & year >= `co_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`co_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Colorado")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/co_incdist_w_vcontrol.pdf", as(pdf) replace



* ----------------------------
* --- DISTRICT OF COLUMBIA --- 
* ----------------------------
 
* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "11"
local dc_ban_year = r(mean)
summarize inc_threshold1 if statefip == "11"
local dc_threshold = r(mean)

* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "11" & year < `dc_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "11" & year >= `dc_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`dc_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/dc_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "11" & year < `dc_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "11" & year >= `dc_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`dc_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/dc_incdist_w_prepost.pdf", as(pdf) replace


* --- TREAT/CONTROL --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip != "11" & year >= `dc_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "11" & year >= `dc_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`dc_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "D.C.")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/dc_incdist_vcontrol.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip != "11" & year >= `dc_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "11" & year >= `dc_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`dc_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "D.C.")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/dc_incdist_w_vcontrol.pdf", as(pdf) replace



* -------------
* --- MAINE ---  
* -------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "23"
local me_ban_year = r(mean)
summarize inc_threshold1 if statefip == "23"
local me_threshold = r(mean)

* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "23" & year < `me_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "23" & year >= `me_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`me_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/me_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "23" & year < `me_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "23" & year >= `me_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`me_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/me_incdist_w_prepost.pdf", as(pdf) replace


* --- TREAT/CONTROL --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip != "23" & year >= `me_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "23" & year >= `me_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`me_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Maine")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/me_incdist_vcontrol.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip != "23" & year >= `me_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "23" & year >= `me_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`me_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Maine")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/me_incdist_w_vcontrol.pdf", as(pdf) replace



* ---------------------
* --- New Hampshire --- 
* ---------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "33"
local nh_ban_year = r(mean)
summarize inc_threshold1 if statefip == "33"
local nh_threshold = r(mean)

* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "33" & year < `nh_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "33" & year >= `nh_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`nh_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/nh_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "33" & year < `nh_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "33" & year >= `nh_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`nh_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/nh_incdist_w_prepost.pdf", as(pdf) replace


* --- TREAT/CONTROL --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip != "33" & year >= `nh_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "33" & year >= `nh_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`nh_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "New Hampshire")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/nh_incdist_vcontrol.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip != "33" & year >= `nh_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "33" & year >= `nh_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`nh_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "New Hampshire")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/nh_incdist_w_vcontrol.pdf", as(pdf) replace



* --------------------
* --- RHODE ISLAND --- 
* --------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "44"
local ri_ban_year = r(mean)
summarize inc_threshold1 if statefip == "44"
local ri_threshold = r(mean)

* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "44" & year < `ri_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "44" & year >= `ri_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`ri_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/ri_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "44" & year < `ri_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "44" & year >= `ri_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`ri_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/ri_incdist_w_prepost.pdf", as(pdf) replace


* --- TREAT/CONTROL --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip != "44" & year >= `ri_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "44" & year >= `ri_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`ri_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Rhode Island")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/ri_incdist_vcontrol.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip != "44" & year >= `ri_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "44" & year >= `ri_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`ri_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Rhode Island")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/ri_incdist_w_vcontrol.pdf", as(pdf) replace



* ----------------
* --- VIRGINIA --- 
* ----------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "51"
local va_ban_year = r(mean)
summarize inc_threshold1 if statefip == "51"
local va_threshold = r(mean)

* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "51" & year < `va_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "51" & year >= `va_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`va_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/va_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "51" & year < `va_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "51" & year >= `va_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`va_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/va_incdist_w_prepost.pdf", as(pdf) replace


* --- TREAT/CONTROL --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip != "51" & year >= `va_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "51" & year >= `va_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`va_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Virginia")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/va_incdist_vcontrol.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip != "51" & year >= `va_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "51" & year >= `va_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`va_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Virginia")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/va_incdist_w_vcontrol.pdf", as(pdf) replace



* ------------------
* --- WASHINGTON --- 
* ------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "53"
local wa_ban_year = r(mean)
summarize inc_threshold1 if statefip == "53"
local wa_threshold = r(mean)

* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "53" & year < `wa_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "53" & year >= `wa_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`wa_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/wa_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "53" & year < `wa_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "53" & year >= `wa_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`wa_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/wa_incdist_w_prepost.pdf", as(pdf) replace


* --- TREAT/CONTROL --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip != "53" & year >= `wa_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "53" & year >= `wa_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`wa_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Washington")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/wa_incdist_vcontrol.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip != "53" & year >= `wa_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "53" & year >= `wa_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`wa_threshold', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "Control States" 2 "Washington")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") /// 
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/wa_incdist_w_vcontrol.pdf", as(pdf) replace



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


* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "17" & year < `il_ban_year1', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "17" & year >= `il_ban_year1' ///
		& year < `il_ban_year2', ///
		width(5000) fraction color(maroon%30)) ///
	(histogram incwage if statefip == "17" & year >= `il_ban_year2', ///
		width(5000) fraction color(green%30)) ///
	, xline(`il_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
	xline(`il_ban_year2', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/il_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "17" & year < `il_ban_year1', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "17" & year >= `il_ban_year1' ///
		& year < `il_ban_year2', ///
		width(5000) fraction color(maroon%30)) ///
	(histogram incwage_w if statefip == "17" & year >= `il_ban_year2', ///
		width(5000) fraction color(green%30)) ///
	, xline(`il_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
	xline(`il_ban_year2', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/il_incdist_w_prepost.pdf", as(pdf) replace

* DIDN'T DO TREATED V. CONTROL YET, DUE TO MESSINESS



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


* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "24" & year < `md_ban_year1', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "24" & year >= `md_ban_year1' ///
		& year < `md_ban_year2', ///
		width(5000) fraction color(maroon%30)) ///
	(histogram incwage if statefip == "24" & year >= `md_ban_year2', ///
		width(5000) fraction color(green%30)) ///
	, xline(`md_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
	xline(`md_ban_year2', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/md_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "24" & year < `md_ban_year1', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "24" & year >= `md_ban_year1' ///
		& year < `md_ban_year2', ///
		width(5000) fraction color(maroon%30)) ///
	(histogram incwage_w if statefip == "24" & year >= `md_ban_year2', ///
		width(5000) fraction color(green%30)) ///
	, xline(`md_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
	xline(`md_ban_year2', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/md_incdist_w_prepost.pdf", as(pdf) replace

* DIDN'T DO TREATED V. CONTROL YET, DUE TO MESSINESS



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


* --- PRE/POST --- 
* Normal incwage
twoway /// 
	(histogram incwage if statefip == "41" & year < `or_ban_year1', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "41" & year >= `or_ban_year1' ///
		& year < `or_ban_year2', ///
		width(5000) fraction color(maroon%30)) ///
	(histogram incwage if statefip == "41" & year >= `or_ban_year2', ///
		width(5000) fraction color(green%30)) ///
	, xline(`or_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
	xline(`or_ban_year2', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/or_incdist_prepost.pdf", as(pdf) replace

* Winsorized incwage 
twoway /// 
	(histogram incwage_w if statefip == "41" & year < `or_ban_year1', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage_w if statefip == "41" & year >= `or_ban_year1' ///
		& year < `or_ban_year2', ///
		width(5000) fraction color(maroon%30)) ///
	(histogram incwage_w if statefip == "41" & year >= `or_ban_year2', ///
		width(5000) fraction color(green%30)) ///
	, xline(`or_threshold1', lpattern(dash) lcolor(black) lwidth(thin)) ///
	xline(`or_ban_year2', lpattern(dash) lcolor(black) lwidth(thin)) ///
		legend(order(1 "No ban" 2 "First ban" 3 "Second ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Fraction") ///
		xlabel(, nogrid) /// 
		ylabel(, nogrid) 
graph export "output/figures/or_incdist_w_prepost.pdf", as(pdf) replace

* DIDN'T DO TREATED V. CONTROL YET, DUE TO MESSINESS




log close 