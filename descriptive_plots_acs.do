* Title: Make Descriptive Plots of ACS Data 

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/descriptive_plots_acs.log", replace 
clear all 

* Load data 
// use "acs_analysis.dta", clear 
use "data/analysis_data/acs_5pct_analysis.dta", clear 

* --- COLORADO --- 

summarize eff_inc1_year if statefip == "08"
local co_ban_year = r(mean)

summarize inc_threshold1 if statefip == "08"
local co_threshold = r(mean)

* Before vs. After Histogram 

twoway ///
	(kdensity incwage if statefip == "08" & year < `co_ban_year', lpattern(solid)) /// 
	(kdensity incwage if statefip == "08" & year >= `co_ban_year', lpattern(dash)) /// 
	, xline(`co_threshold', lpattern(dash) lcolor(black)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Density")


summarize eff_inc1_year if statefip == "08"
local co_ban_year = r(mean)

summarize inc_threshold1 if statefip == "08"
local co_threshold = r(mean)

twoway /// 
	(histogram incwage if statefip == "08" & year < `co_ban_year', ///
		width(5000) fraction color(navy%30)) ///
	(histogram incwage if statefip == "08" & year >= `co_ban_year', ///
		width(5000) fraction color(maroon%30)) ///
	, xline(`co_threshold', lpattern(dash) lcolor(black)) ///
		legend(order(1 "Before ban" 2 "After ban")) /// 
		xtitle("Annual Earnings") ///
		ytitle("Density")	
	
* NOTES: (1) Drop zero income (if they still exist); (2) Winsorize. 

	

* --- DISTRICT OF COLUMBIA --- 













log close 