* Title: Create Raw Mean Plots from QWI Data 

* DONE: 
* (1) Do event_time plots but with a panel that is balanced in event-time. 
* (2) Plot each ban cohort vs. control states on new hires and earnings of new
* 	  hires. 
* (3) Plot new hires and new hires' earnings for the age and education samples
* 	  restricting to the "young" bucket in the former case, and to bachelors or
* 	  higher in the latter case. May consider constructing fractions too.

* NOTE: 
* (1) Need to restrict to high-incidence industries and see what I find there. 
* (2) Need to plot for just the states with the most salient bans (CO, DC, WA, 
* 	  OR) and plot dotted line for ban date too. 


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

* Create balanced panel: Event time (-5, 2)
cap drop temp*
sort statefip countyfip year
gen temp = 1 if inrange(event_time, -5, 2)
egen temptot = total(temp), by(statefip countyfip)
gen balanced = 1 if temptot == 8
drop temp*

* --- EVENT TIME --- 
* New Hires 
binscatter hirn event_time, line(connect) discrete
binscatter hirn event_time if balanced == 1 & inrange(event_time, -5, 2) ///
	, line(connect) discrete

// stable
binscatter hirns event_time, line(connect) discrete
binscatter hirns event_time if balanced == 1 & inrange(event_time, -5, 2) ///
	, line(connect) discrete

	
* Earnings of New Hires 
binscatter earnhirns event_time, line(connect) discrete 
binscatter earnhirns event_time if balanced == 1 & inrange(event_time, -5, 2) ///
	, line(connect) discrete 


binscatter earnhirns_real event_time, line(connect) discrete 
binscatter earnhirns_real event_time if balanced == 1 & inrange(event_time, -5, 2) ///
	, line(connect) discrete 


* --- CALENDAR TIME --- 
* New Hires 
binscatter hirn year, ///
	line(connect) discrete by(cohort)

// stable
binscatter hirns year, ///
	line(connect) discrete by(cohort)
	
	
* Earnings of New Hires 
binscatter earnhirns year, /// 
	line(connect) discrete by(cohort)

binscatter earnhirns_real year, /// 
	line(connect) discrete by(cohort)


* ------------------------------------------------------------------------------
* ------------------------------- AGE QWI PLOTS --------------------------------
* ------------------------------------------------------------------------------
* Load Age QWI Data
use "data/analysis_data/qwi_age_analysis.dta", clear 

* Sanity checks: A00 first, and present for each county-year 
// tab agegrp
// bysort countyfip year: gen n_A00 = (agegrp=="A00")
// bysort countyfip year: egen has_A00 = max(n_A00)
// tab has_A00

* Define Fraction of Workers in Age Bins
bysort countyfip year (agegrp): gen hirn_total = hirn[1]
order hirn_total, after(hirn)
gen hirn_frac = hirn / hirn_total

* Create balanced panel: Event time (-5, 2)
cap drop temp*
sort statefip countyfip agegrp year
gen temp = 1 if inrange(event_time, -5, 2)
egen temptot = total(temp), by(statefip countyfip agegrp)
gen balanced = 1 if temptot == 8
drop temp*


* --- EVENT TIME --- 
* New Hires - Young (14-24)
binscatter hirn event_time if balanced == 1 & inrange(event_time, -5, 2) & ///
	inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete

* Fraction New Hires Who are Young (22-24)
binscatter hirn_frac event_time if balanced == 1 & inrange(event_time, -5, 2) & ///
	agegrp == "A03", ///
	line(connect) discrete

* Earnings of New Hires - Young (14-24)
binscatter earnhirns event_time if balanced == 1 & inrange(event_time, -5, 2) & ///
	inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete

	
* --- CALENDAR TIME --- 
* New Hires - Young (14-24)
binscatter hirn year if inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete by(cohort)

* Fraction New Hires Who are Young 
// (19-21)
binscatter hirn_frac year if agegrp == "A02", ///
	line(connect) discrete by(cohort)
	
// (22-24)
binscatter hirn_frac year if agegrp == "A03", ///
	line(connect) discrete by(cohort)

// (25-34) 
binscatter hirn_frac year if agegrp == "A04", ///
	line(connect) discrete by(cohort)

	
* Earnings of New Hires - Young (14-24)
binscatter earnhirns year if inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete by(cohort)

binscatter earnhirns_real year if inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete by(cohort)

	
* --- HISTOGRAM BY AGE BIN --- 



* ------------------------------------------------------------------------------
* ------------------------------- EDUC QWI PLOTS -------------------------------
* ------------------------------------------------------------------------------
* Load Education Data 
use "data/analysis_data/qwi_educ_analysis.dta", clear 

* Define Fraction of Workers in Educ Bins 
bysort countyfip year (education): gen hirn_total = hirn[1]
order hirn_total, after(hirn)
gen hirn_frac = hirn / hirn_total

* Create balanced panel: Event time (-5, 2)
cap drop temp*
sort statefip countyfip education year
gen temp = 1 if inrange(event_time, -5, 2)
egen temptot = total(temp), by(statefip countyfip education)
gen balanced = 1 if temptot == 8
drop temp*

* Drop all education 
drop if education == "E0"
drop if education == "E5"

* --- EVENT TIME --- 
* New Hires - By Education
binscatter hirn event_time if balanced == 1 & inrange(event_time, -5, 2), ///
	line(connect) discrete by(education)

* Fraction New Hires - By Education
binscatter hirn_frac event_time if balanced == 1 & inrange(event_time, -5, 2), ///
	line(connect) discrete by(education)

* Earnings of New Hires - By Education
binscatter earnhirns event_time if balanced == 1 & inrange(event_time, -5, 2), ///
	line(connect) discrete by(education)

	
* --- CALENDAR TIME --- 
* New Hires 
// High School or Less
binscatter hirn year if inlist(education, "E1", "E2"), ///
	line(connect) discrete by(cohort)

// Some College 
binscatter hirn year if inlist(education, "E3"), ///
	line(connect) discrete by(cohort)
	
// Bachelor's or Higher
binscatter hirn year if inlist(education, "E4"), ///
	line(connect) discrete by(cohort)
	
	
* Fraction New Hires  
// High School or Less
binscatter hirn_frac year if inlist(education, "E1", "E2"), ///
	line(connect) discrete by(cohort)
	
// Some College 
binscatter hirn_frac year if education == "E3", ///
	line(connect) discrete by(cohort)

// Bachelor's or Higher
binscatter hirn_frac year if education == "E4", ///
	line(connect) discrete by(cohort)

	
* Earnings of New Hires
// High School or Less
binscatter earnhirns year if inlist(education, "E1", "E2"), ///
	line(connect) discrete by(cohort)

// Some College 
binscatter earnhirns year if education == "E3", ///
	line(connect) discrete by(cohort)

// Bachelor's or Higher
binscatter earnhirns year if education == "E4", ///
	line(connect) discrete by(cohort)
* NOTE: One of the "better" pictures. Seems to suggest that the wage gains may 
* have been more concentrated on those with higher degrees. 

	




* ------------------------------------------------------------------------------
* ------------------------- HIGH-USE INDUSTRY ANALYSIS -------------------------
* ------------------------------------------------------------------------------
* Load Industry Data 
use "data/analysis_data/qwi_ind_analysis.dta", clear 

* Drop Public Administration 
drop if industry == "92"

* High incidence industries

	* Administrative, Support, Waste Management (.19); SECTOR CODE: 56
	* Wholesale Trade (.20); SECTOR CODE: 42
	* Education Services (.22); SECTOR CODE: 61
	* Manufacturing*** (.23); SECTOR CODE: 31-33
	* Finance, Insruance (.25); SECTOR CODE: 52
	* Professional, Scientific, Technical (.31); SECTOR CODE: 54
	* Mining, Extraction (.31); SECTOR CODE: 21
	* Information (.32); SECTOR CODE: 51 

keep if inlist(industry, "56", "42", "61", "31-33", "52", "54", "21", "51")

* NOTE: Run analysis on these, higher incidence occupations. Later run for just
* Manufacturing and Mining/Extraction (as per Mike's request).

* Create balanced panel: Event time (-5, 2)
cap drop temp*
sort statefip countyfip industry year
gen temp = 1 if inrange(event_time, -5, 2)
egen temptot = total(temp), by(statefip countyfip industry)
gen balanced = 1 if temptot == 8
drop temp*


* --- EVENT TIME --- 
* New Hires - By Industry
binscatter hirn event_time, line(connect) discrete by(industry)
binscatter hirn event_time if balanced == 1 & inrange(event_time, -5, 2) ///
	, line(connect) discrete by(industry)

// stable
binscatter hirns event_time, line(connect) discrete by(industry)
binscatter hirns event_time if balanced == 1 & inrange(event_time, -5, 2) ///
	, line(connect) discrete by(industry)

	
* Earnings of New Hires - By Industry
binscatter earnhirns event_time, line(connect) discrete by(industry)
binscatter earnhirns event_time if balanced == 1 & inrange(event_time, -5, 2) ///
	, line(connect) discrete by(industry)


binscatter earnhirns_real event_time, line(connect) discrete by(industry)
binscatter earnhirns_real event_time if balanced == 1 & ///
	inrange(event_time, -5, 2), line(connect) discrete by(industry)

	
* --- CALENDAR TIME --- 
* New Hires 
binscatter hirn year, ///
	line(connect) discrete by(cohort)

// stable
binscatter hirns year, ///
	line(connect) discrete by(cohort)
	
	
* Earnings of New Hires 
binscatter earnhirns year, /// 
	line(connect) discrete by(cohort)

binscatter earnhirns_real year, /// 
	line(connect) discrete by(cohort)

	

* ------------------------------------------------------------------------------
* --------------------- HIGH USE INDUSTRY BY AGE ANALYSIS ---------------------- 
* ------------------------------------------------------------------------------
* Load Industry by Age Data 
use "data/analysis_data/qwi_age_ind_analysis.dta", clear 


* Drop Public Administration 
drop if industry == "92"

* High incidence industries

	* Administrative, Support, Waste Management (.19); SECTOR CODE: 56
	* Wholesale Trade (.20); SECTOR CODE: 42
	* Education Services (.22); SECTOR CODE: 61
	* Manufacturing*** (.23); SECTOR CODE: 31-33
	* Finance, Insruance (.25); SECTOR CODE: 52
	* Professional, Scientific, Technical (.31); SECTOR CODE: 54
	* Mining, Extraction (.31); SECTOR CODE: 21
	* Information (.32); SECTOR CODE: 51 

keep if inlist(industry, "56", "42", "61", "31-33", "52", "54", "21", "51")

* NOTE: Run analysis on these, higher incidence occupations. Later run for just
* Manufacturing and Mining/Extraction (as per Mike's request).

* Create balanced panel: Event time (-5, 2)
cap drop temp*
sort statefip countyfip industry agegrp year
gen temp = 1 if inrange(event_time, -5, 2)
egen temptot = total(temp), by(statefip countyfip industry agegrp)
gen balanced = 1 if temptot == 8
drop temp*


* Define Fraction of Workers in Age Bins
//sanity check first 
// bysort countyfip industry year: gen n_A00 = (agegrp=="A00")
// bysort countyfip industry year: egen has_A00 = max(n_A00)
// tab has_A00

gen hirn_A00 = hirn if agegrp == "A00"
bysort countyfip industry year (hirn_A00): replace hirn_A00 = hirn_A00[1]
gen hirn_frac = hirn / hirn_A00

order hirn_A00, after(hirn)
* NOTE: Different approach than earlier age section. May adopt throughout. 


* --- EVENT TIME --- 
* New Hires - Young (14-24)
binscatter hirn event_time if balanced == 1 & inrange(event_time, -5, 2) & ///
	inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete

* Fraction New Hires Who are Young (22-24)
binscatter hirn_frac event_time if balanced == 1 & inrange(event_time, -5, 2) & ///
	agegrp == "A03", ///
	line(connect) discrete

* Earnings of New Hires - Young (14-24)
binscatter earnhirns event_time if balanced == 1 & inrange(event_time, -5, 2) & ///
	inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete

	
* --- CALENDAR TIME --- 
* New Hires - Young (14-24)
binscatter hirn year if inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete by(cohort)

* Fraction New Hires Who are Young 
// (19-21)
binscatter hirn_frac year if agegrp == "A02", ///
	line(connect) discrete by(cohort)
	
// (22-24)
binscatter hirn_frac year if agegrp == "A03", ///
	line(connect) discrete by(cohort)

// (25-34) 
binscatter hirn_frac year if agegrp == "A04", ///
	line(connect) discrete by(cohort)

	
* Earnings of New Hires - Young (14-24)
binscatter earnhirns year if inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete by(cohort)

binscatter earnhirns_real year if inlist(agegrp, "A01", "A02", "A03"), ///
	line(connect) discrete by(cohort)

	
* --- HISTOGRAM BY AGE BIN --- 






* ------------------------------------------------------------------------------
* ------------------ HIGH USE INDUSTRY BY EDUCATION ANALYSIS ------------------- 
* ------------------------------------------------------------------------------
* Load Industry by Edcuation Data 







* ------------------------------------------------------------------------------
* ---------------------------- SALIENT BAN ANALYSIS ----------------------------
* ------------------------------------------------------------------------------






* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------
* ------------------------------------------------------------------------------

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