********************************************************************************
* Figure 2; Figure 3; Exhibit A

use "workingdata/sdud1524", clear

gen year = yofd(dofq(time))
drop if year < 2015

gen glpobesity = inlist(drug, "saxenda", "wegovy", "zepbound")
gen glp = inlist(drug, "victoza", "ozempic", "mounjaro")	
gen obesity = inlist(drug, "belviq", "xenical", "qsymia", "contrave")

keep if glpobesity == 1 | glp == 1 | obesity == 1

gen grp = "glpobesity" if glpobesity == 1
replace grp = "glp" if mi(grp) & glp == 1
replace grp = "obesity" if mi(grp) & obesity == 1

collapse (sum) scripts (mean) mcaidenrollees, by(time grp state_ab state) fast
replace scripts = scripts/mcaidenrollees*1000

gen coverage = 2 if inlist(state, "California", "Delaware", "Kansas", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "New Hampshire", "North Carolina")
replace coverage = 2 if inlist(state, "Pennsylvania", "Rhode Island", "Virginia", "Wisconsin")
replace coverage = 1 if inlist(state, "Louisiana", "Texas", "North Dakota", "South Carolina")
replace coverage = 0 if mi(coverage)

replace coverage = . if state == "Florida"

preserve
collapse (mean) scripts, by(time grp)
gen coverage = 4 
tempfile us
save `us', replace

restore
collapse (mean) scripts, by(time grp coverage) fast
append using `us'

twoway (connected scripts time if grp == "glpobesity" & coverage == 4, color(black) ms(+)) (connected scripts time if grp == "glpobesity" & coverage == 0, color(gs7) ms(d)) (connected scripts time if grp == "glpobesity" & coverage == 1, color(sand) ms(t)) (connected scripts time if grp == "glpobesity" & coverage == 2, color(navy) ms(o)), graphregion(color(white)) legend(order(4 "States with GLP-1 Obesity Coverage" 3 "States with Other Obesity Coverage" 2 "States with No Obesity Coverage" 1 "National") col(1) size(small)) xsc(range(220 255)) xlabel(220(4)256, labsize(small)) xtitle("") ytitle("Obesity-related GLP-1 Prescriptions" "per 1,000 Medicaid Enrollees")
graph export "figures/trend_scripts_glpobesity.png", replace

twoway (connected scripts time if grp == "glp" & coverage == 4, color(black) ms(+)) (connected scripts time if grp == "glp" & coverage == 0, color(gs7) ms(d)) (connected scripts time if grp == "glp" & coverage == 1, color(sand) ms(t)) (connected scripts time if grp == "glp" & coverage == 2, color(navy) ms(o)), graphregion(color(white)) legend(order(4 "States with GLP-1 Obesity Coverage" 3 "States with Other Obesity Coverage" 2 "States with No Obesity Coverage" 1 "National") col(1) size(small)) ytitle("Diabetes-related GLP-1 Prescriptions" "per 1,000 Medicaid Enrollees") xsc(range(220 255)) xlabel(220(4)256, labsize(small)) xtitle("")
graph export "figures/trend_scripts_glp.png", replace

twoway (connected scripts time if grp == "obesity" & coverage == 4, color(black) ms(+)) (connected scripts time if grp == "obesity" & coverage == 0, color(gs7) ms(d)) (connected scripts time if grp == "obesity" & coverage == 1, color(sand) ms(t)) (connected scripts time if grp == "obesity" & coverage == 2, color(navy) ms(o)), graphregion(color(white)) legend(order(4 "States with GLP-1 Obesity Coverage" 3 "States with Other Obesity Coverage" 2 "States with No Obesity Coverage" 1 "National") col(1) size(small)) ytitle("Other Obesity Drugs" "per 1,000 Medicaid Enrollees") xsc(range(220 255)) xlabel(220(4)256, labsize(small)) xtitle("")
graph export "figures/trend_scripts_obesity.png", replace

********************************************************************************
* Table 1
use "workingdata/sdud1524", clear

gen glpobesity = inlist(drug, "saxenda", "wegovy", "zepbound")
gen glp = inlist(drug, "victoza", "ozempic", "mounjaro")	
gen obesity = inlist(drug, "belviq", "xenical", "qsymia", "contrave")

keep if glpobesity == 1

gen grp = "glpobesity" if glpobesity == 1
replace grp = "glp" if mi(grp) & glp == 1
replace grp = "obesity" if mi(grp) & obesity == 1

collapse (sum) scripts (mean) mcaidenrollees, by(time grp state_ab state) fast
replace scripts = scripts/mcaidenrollees*1000

gen coverage = 2 if inlist(state, "California", "Delaware", "Kansas", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "New Hampshire", "North Carolina")
replace coverage = 2 if inlist(state, "Pennsylvania", "Rhode Island", "Virginia", "Wisconsin")
replace coverage = 1 if inlist(state, "Louisiana", "Texas", "North Dakota", "South Carolina")
replace coverage = 0 if mi(coverage)

drop if state == "Florida"

keep if coverage == 2
keep if time == 259
drop if state == "North Carolina"

* prior authorisation
preserve 
	gen restriction = 0
	replace restriction = 1 if inlist(state, "Delaware", "Kansas", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "New Hampshire", "Pennsylvania")
	replace restriction = 1 if inlist(state, "Rhode Island", "Virginia", "Wisconsin")
		
	ttest scripts, by(restriction) unequal

restore

* bmi requirement
preserve 
	gen restriction = 0
	replace restriction = 1 if inlist(state, "California", "Delaware", "Kansas", "Massachusetts", "Michigan", "Mississippi", "New Hampshire", "Pennsylvania")
	replace restriction = 1 if inlist(state, "Rhode Island", "Virginia", "Wisconsin")

	ttest scripts, by(restriction) unequal

restore

* comorbidity requirement
preserve 
	gen restriction = 0
	replace restriction = 1 if inlist(state, "Kansas", "Massachusetts", "Michigan", "Mississippi", "New Hampshire", "Pennsylvania")
	replace restriction = 1 if inlist(state, "Rhode Island", "Virginia", "Wisconsin")
	
	ttest scripts, by(restriction) unequal

restore

* step therapy
preserve 
	gen restriction = 0
	replace restriction = 1 if inlist(state, "Kansas", "Massachusetts", "Pennsylvania", "Virginia")

	ttest scripts, by(restriction) unequal

restore

* other
preserve 
	gen restriction = 0
	replace restriction = 1 if inlist(state, "California", "Kansas", "Massachusetts", "New Hampshire", "Rhode Island")

	ttest scripts, by(restriction) unequal
	
restore

********************************************************************************
* Exhibit B: Obesity-related GLP-1s, Diabetes-related GLP-1s, Other Obesity Drugs
use "workingdata/sdud1524", clear

gen glpobesity = inlist(drug, "saxenda", "wegovy", "zepbound")
gen glp = inlist(drug, "victoza", "ozempic", "mounjaro")	
gen obesity = inlist(drug, "belviq", "xenical", "qsymia", "contrave")

keep if glpobesity == 1 | glp == 1 | obesity == 1
gen grp = "glpobesity" if glpobesity == 1
replace grp = "glp" if mi(grp) & glp == 1
replace grp = "obesity" if mi(grp) & obesity == 1

collapse (sum) scripts (mean) mcaidenrollees, by(time grp state_ab state) fast
replace scripts = scripts/mcaidenrollees*1000

gen coverage = 2 if inlist(state, "California", "Delaware", "Kansas", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "New Hampshire", "North Carolina")
replace coverage = 2 if inlist(state, "Pennsylvania", "Rhode Island", "Virginia", "Wisconsin")
replace coverage = 1 if inlist(state, "Louisiana", "Texas", "North Dakota", "South Carolina")
replace coverage = 0 if mi(coverage)
replace coverage = . if state == "Florida"

* 2024Q4
keep if time == 259

* average in 2024
preserve
collapse (mean) scripts, by(state_ab state grp coverage)
reshape wide scripts, i(state) j(grp) string
order coverage state_ab state scriptsglpobesity scriptsglp scriptsobesity
sort coverage state
restore

* average in 2024 by coverage
preserve
collapse (mean) scripts, by(grp coverage)
reshape wide scripts, i(coverage) j(grp) string
order coverage scriptsglpobesity scriptsglp scriptsobesity
restore

* average in 2024 national
preserve
collapse (mean) scripts, by(grp)
restore

********************************************************************************
* Exhibit B: Obesity-related GLP-1s FFS/MCO
use "workingdata/sdud1524_mcoffs", clear

gen temp1 = mcaidenrollees if year == 2024 & quarter == 4
bysort state: egen temp2 = max(temp1)
replace mcaidenrollees = temp2 if year == 2025
drop temp1 temp2

gen temp1 = mcaidpen if year == 2022 & quarter == 4
bysort state: egen temp2 = max(temp1)
replace mcaidpen = temp2 if inrange(year, 2023, 2025)
drop temp1 temp2

gen mcaidMCOU = mcaidenrollees*mcaidpen/100
gen mcaidFFSU = mcaidenrollees*(100-mcaidpen)/100

foreach var in scriptsFFSUobesity scriptsMCOUobesity scriptsFFSUdiabetes scriptsMCOUdiabetes scriptsFFSU scriptsMCOU {
	replace `var' = 0 if mi(`var')
}

egen scriptsobesity = rowtotal(scriptsFFSUobesity scriptsMCOUobesity)
egen scriptsdiabetes = rowtotal(scriptsFFSUdiabetes scriptsMCOUdiabetes)
egen scripts = rowtotal(scriptsFFSU scriptsMCOU)

gen pcFFSU = scriptsFFSU/mcaidFFSU*1000
gen pcMCOU = scriptsMCOU/mcaidMCOU*1000
gen pcFFSUobesity = scriptsFFSUobesity/mcaidFFSU*1000
gen pcMCOUobesity = scriptsMCOUobesity/mcaidMCOU*1000
gen pcFFSUdiabetes = scriptsFFSUdiabetes/mcaidFFSU*1000
gen pcMCOUdiabetes = scriptsMCOUdiabetes/mcaidMCOU*1000
gen pcobesity = scriptsobesity/mcaidenrollees*1000
gen pcdiabetes = scriptsdiabetes/mcaidenrollees*1000

foreach var in scripts scriptsFFSU scriptsMCOU {
	replace `var' = `var'/1000
}

gen carvein = .
replace carvein = 1 if inlist(state_ab, "WA", "OR", "NV", "UT", "AZ", "CO", "NM", "NE", "KS")
replace carvein = 1 if inlist(state_ab, "TX", "MN", "IA", "AR", "LA", "IL", "MS", "MI", "IN")
replace carvein = 1 if inlist(state_ab, "KY", "GA", "FL", "SC", "NC", "VA", "MD", "PA", "NJ") // OK NC
replace carvein = 1 if inlist(state_ab, "DE", "NH", "DC", "RI", "MA", "HI")
replace carvein = 0 if inlist(state_ab, "CA", "ND", "MO", "WI", "TN", "OH", "WV", "NY")
drop if state_ab == "NC"

gen coverage = 2 if inlist(state, "California", "Delaware", "Kansas", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "New Hampshire", "North Carolina")
replace coverage = 2 if inlist(state, "Pennsylvania", "Rhode Island", "Virginia", "Wisconsin")
replace coverage = 1 if inlist(state, "Louisiana", "Texas", "North Dakota", "South Carolina")
replace coverage = 0 if mi(coverage)
replace coverage = . if state == "Florida"

keep if year == 2024 & quarter == 4

preserve
collapse (mean) pcFFSU pcMCOU mcaidpen pcFFSUdiabetes pcMCOUdiabetes pcFFSUobesity pcMCOUobesity, by(coverage state carvein)
bro if carvein == 1
restore

preserve
collapse (mean) pcFFSU pcMCOU mcaidpen pcFFSUdiabetes pcMCOUdiabetes pcFFSUobesity pcMCOUobesity, by(coverage carvein)
bro if carvein == 1
restore

preserve
collapse (mean) pcFFSU pcMCOU mcaidpen pcFFSUdiabetes pcMCOUdiabetes pcFFSUobesity pcMCOUobesity, by(carvein)
bro if carvein == 1
