forval y = 2024(-1)2010 {
	
	import delimited "data/sdud/sdud_`y'.csv", clear
	drop if state == "XX"

	loc names1 "unitsreimbursed numberofprescriptions medicaidamountreimbursed"
	loc names2 "units scripts mcaidamt"
	for zz in any `names1' \ yy in any `names2': ren zz yy

	replace productname = lower(productname)
	gen drug = ""
	
	destring labelercode productcode, force replace
	
	* saxenda wegovy zepbound
	* victoza(liraglutide) ozempic mounjaro
	* belviq(lorcaserin) xenical(orlistat) qsymia(phentermine-topiramate) contrave
	
	* code with national drug codes
	foreach var in saxenda wegovy zepbound victoza liraglutide ozempic mounjaro xenical orlistat qsymia phentermine_and_topiramate contrave {
		merge m:1 labelercode productcode using "data/ndc_`var'", nogen keep(1 3)
	}
	
	* code from name
	foreach var in saxenda wegovy zepbound victoza liraglutide ozempic mounjaro belviq lorcaserin xenical orlistat qsymia phentermine_and_topiramate contrave {
		cap gen `var' = .
		replace `var' = 1 if strpos(productname, "`var'") > 0
	}
	
	replace liraglutide = 0 if saxenda == 1
	replace victoza = 1 if liraglutide == 1
	replace xenical = 1 if orlistat == 1
	replace qsymia = 1 if phentermine_and_topiramate == 1
	replace belviq = 1 if lorcaserin == 1
	
	foreach var in saxenda wegovy zepbound victoza ozempic mounjaro belviq xenical qsymia contrave {
		replace drug = "`var'" if `var' == 1
	}
	
	* if found from name generalize to ndc
	foreach var in saxenda wegovy zepbound victoza ozempic mounjaro belviq xenical qsymia contrave {
		bysort labelercode productcode: egen check`var' = max(`var')
		replace drug = "`var'" if check`var' == 1
		drop check`var'
	}
	
	keep if !mi(drug)

	g miss = 0
	replace miss = 1 if scripts == .
	replace scripts = 5 if scripts == . // suppression means 10 or fewer
		
	collapse (sum) scripts units mcaidamt (mean) miss, by(state year quarter drug utilizationtype) fast

	tempfile temp`y'
	save `temp`y'' 
}

clear all

forval y = 2024(-1)2015 {
	append using `temp`y''
}

rename state state_ab
merge m:1 state_ab using "data/usgeo/fips", nogen keep(3) keepusing(state)

merge m:1 state year quarter using "data/medicaid/mcaidenrollees20142024", nogen
gen time = yq(year, quarter)
format time %tq

drop state_ab
merge m:1 state using "data/usgeo/fips", nogen keep(3) keepusing(state_ab)

* create observations for missing state-year
drop year quarter
reshape wide scripts mcaidenrollees miss units mcaidamt, i(drug state_ab state utilizationtype) j(time)
reshape long
replace scripts = 0 if mi(scripts)
format time %tq

drop state
reshape wide scripts mcaidenrollees miss units mcaidamt, i(drug utilizationtype time) j(state_ab) string
reshape long
replace scripts = 0 if mi(scripts)

* fill mcaid enrollees for new observations
bysort state_ab time: egen temp = max(mcaidenrollees)
replace mcaidenrollees = temp
drop temp

* fill RI 2024Q4 enrollees
gen temp = mcaidenrollees if state == "RI" & time == 258
egen temp2 = max(temp)
replace mcaidenrollees = temp2 if state == "RI" & time == 259
drop temp*

* create year/month/state again
merge m:1 state_ab using "data/usgeo/fips", keepusing(state) nogen

gen year = yofd(dofq(time))
gen quarter = quarter(dofq(time))

save "workingdata/sdud1524", replace

********************************************************************************
clear all

forval y = 2024(-1)2015 {
	append using `temp`y''
}
	
gen time = yq(year, quarter)
format time %tq

drop units miss
reshape wide scripts, i(state year quarter time) j(utilization) string

gen anyFFSU = !mi(scriptsFFSU) & scriptsFFSU != 0
gen anyMCOU = !mi(scriptsMCOU) & scriptsMCOU != 0

rename state state_ab

tempfile all
save `all', replace

use "workingdata/sdud1524", clear

keep if inlist(drug, "saxenda", "wegovy", "zepbound", "victoza", "ozempic", "mounjaro")	

gen glp = "obesity" if inlist(drug, "saxenda", "wegovy", "zepbound")
replace glp = "diabetes" if inlist(drug, "victoza", "ozempic", "mounjaro")

collapse (sum) scripts, by(state year quarter time utilization glp)
reshape wide scripts, i(state year quarter time glp) j(utilization) string
reshape wide scriptsFFSU scriptsMCOU, i(state year quarter time) j(glp) string

merge m:1 state using "data/usgeo/fips", keepusing(state_ab fips) nogen
drop if mi(fips)
merge 1:1 state_ab year quarter time using `all', nogen keep(3)

merge m:1 state year quarter using "data/medicaid/mcaidenrollees20142024", nogen keep(3)

gen temp = mcaidenrollees if state == "Rhode Island" & year == 2024 & quarter == 3
egen temp2 = max(temp)
replace mcaidenrollees = temp2 if state == "Rhode Island" & year == 2024 & quarter == 4 // RI did not report 2024Q4
drop temp temp2

save `all', replace

use "hearingaidpolicy_2026.03.dta", clear
keep state year quarter mcaidpen_st
rename state fips
merge 1:1 fips year quarter using `all', nogen keep(2 3)

sort state year quarter

drop if time < 220

save "wprkingdata/sdud1524_mcoffs", replace

