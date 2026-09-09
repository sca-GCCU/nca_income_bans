* Title: Create Raw Mean Plots from QWI Data 

* NOTES: 
* (1) Do event_time plots but with a panel that is balanced in event-time. 
* (2) Plot each ban state vs. control states on new hires and earnings of new
* 	  hires. 
* (3) Plot new hires and nwe hires' earnings for the age and education samples
* 	  restricting to the "young" bucket in the former case, and to bachelors or
* 	  higher in the latter case. May consider constructing fractions too.

* --------------------
* --- HOUSEKEEPING ---
* --------------------
cd "C:\Users\scana\OneDrive\Documents\research\projects\nca_income_bans"
log using "logs/raw_mean_plots_qwi.log", replace 
clear all 

* ------------------------------------------------------------------------------
* ---------------------------- OVERALL QWI PLOTS -------------------------------
* ------------------------------------------------------------------------------
* Load Overall QWI Data 
use "data/analysis_data/qwi_overall_analysis.dta", clear 


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

* --- New Hires --- 
binscatter hirn event_time, line(connect) discrete


* --- Earnings of New Hires --- 
binscatter earnhirns event_time, line(connect) discrete 

binscatter earnhirns_real event_time, line(connect) discrete 




 * ----------------------------
* --- DISTRICT OF COLUMBIA --- 
* ----------------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "11"
local dc_ban_year = r(mean)
summarize inc_threshold1 if statefip == "11"
local dc_threshold = r(mean)


 
 
 * -------------
* --- MAINE ---  
* -------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "23"
local me_ban_year = r(mean)
summarize inc_threshold1 if statefip == "23"
local me_threshold = r(mean)




* ---------------------
* --- New Hampshire --- 
* ---------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "33"
local nh_ban_year = r(mean)
summarize inc_threshold1 if statefip == "33"
local nh_threshold = r(mean)



* --------------------
* --- RHODE ISLAND --- 
* --------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "44"
local ri_ban_year = r(mean)
summarize inc_threshold1 if statefip == "44"
local ri_threshold = r(mean)




* ----------------
* --- VIRGINIA --- 
* ----------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "51"
local va_ban_year = r(mean)
summarize inc_threshold1 if statefip == "51"
local va_threshold = r(mean)



* ------------------
* --- WASHINGTON --- 
* ------------------

* Storing ban year and income threshold 
summarize eff_inc1_year if statefip == "53"
local wa_ban_year = r(mean)
summarize inc_threshold1 if statefip == "53"
local wa_threshold = r(mean)



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








log close 