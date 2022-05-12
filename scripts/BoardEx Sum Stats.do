global data_directory "/export/home/dor/nloreedwards/Documents/BoardEx/data/"
global export_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex/output"
global working_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex"

cd "$working_directory"


*** Tabulate Different C-Suit Positions over time
** ALL COMPANIES
use "$data_directory/c_suite_data", clear
drop if RowType == "Disclosed Earner"

* Prevalence of positions
gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

collapse (rawsum) pos*, by(year BoardID)

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos

scatter percent_with_pos year if position == "COO", connect(L) || scatter percent_with_pos year if position == "CTO", connect(L) || scatter percent_with_pos year if position == "CFO", connect(L) legend(label(1 "% of Companies with COO") label(2 "% of Companies with CTO") label(3 "% of Companies with CFO"))
graph export "$export_directory/figs/percent_COO_CTO_CFO.png", replace

replace position = "Chief administration officer" if position == "CAO"
replace position = "Chief compliance officer" if position == "CCO_comp"
replace position = "Chief content office" if position == "CCO_cont"
replace position = "Chief data officer" if position == "CDO"
replace position = "Chief executive officer" if position == "CEO"
replace position = "Chief financial officer" if position == "CFO"
replace position = "Chief human resources officer" if position == "CHRO"
replace position = "Chief information officer" if position == "CIO"
replace position = "Chief knowledge officer" if position == "CKO"
replace position = "Chief marketing officer" if position == "CMO"
replace position = "Chief operating officer" if position == "COO"
replace position = "Chief product officer" if position == "CPO"
replace position = "Chief security officer" if position == "CSO_sec"
replace position = "Chief sustainability officer" if position == "CSO_sus"
replace position = "Chief technology officer" if position == "CTO"

eststo clear
eststo: estpost tabstat percent_with_pos if year == 2000, stats(mean) by(position) nototal
eststo: estpost tabstat percent_with_pos if year == 2020, stats(mean) by(position) nototal
eststo: estpost tabstat change_20yr if year == 2020, stats(mean) by(position) nototal

esttab, not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") title(Percent of firms with each position) varlabels(`e(labels)') label
esttab using "$export_directory/tables/change_positions.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position\label{tab98}) replace booktabs

* Average number of positions
use "$data_directory/c_suite_data", clear
drop if RowType == "Disclosed Earner"

* Prevalence of positions
gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

collapse (rawsum) pos*, by(year BoardID)
local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"
foreach position in `positions' {
	
	replace pos_`position' = 1 if pos_`position' > 0
	
}

gen num_positions = pos_CEO+pos_COO+pos_CFO+pos_CIO+pos_CTO+pos_CCO_comp+pos_CKO+pos_CDO+pos_CMO+pos_CSO_sec+pos_CSO_sus+pos_CAO+pos_CPO+pos_CCO_cont+pos_CHRO

collapse num_positions, by(year)
tsset year
tsline num_positions, ytitle("Average Number of C-Suite Positions per Company") xtitle("Year")
graph export "$export_directory/figs/num_positions_over_time.png", replace



** BALANCED SET
use "$data_directory/c_suite_data", clear
drop if RowType == "Disclosed Earner"

* Prevalence of positions
gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

collapse (rawsum) pos*, by(year BoardID)
bysort BoardID: gen num_years = _N
keep if num_years == 21
gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos

scatter percent_with_pos year if position == "COO", connect(L) || scatter percent_with_pos year if position == "CTO", connect(L) || scatter percent_with_pos year if position == "CFO", connect(L) legend(label(1 "% of Companies with COO") label(2 "% of Companies with CTO") label(3 "% of Companies with CFO"))
graph export "$export_directory/figs/percent_COO_CTO_CFO_bal.png", replace

replace position = "Chief administration officer" if position == "CAO"
replace position = "Chief compliance officer" if position == "CCO_comp"
replace position = "Chief content office" if position == "CCO_cont"
replace position = "Chief data officer" if position == "CDO"
replace position = "Chief executive officer" if position == "CEO"
replace position = "Chief financial officer" if position == "CFO"
replace position = "Chief human resources officer" if position == "CHRO"
replace position = "Chief information officer" if position == "CIO"
replace position = "Chief knowledge officer" if position == "CKO"
replace position = "Chief marketing officer" if position == "CMO"
replace position = "Chief operating officer" if position == "COO"
replace position = "Chief product officer" if position == "CPO"
replace position = "Chief security officer" if position == "CSO_sec"
replace position = "Chief sustainability officer" if position == "CSO_sus"
replace position = "Chief technology officer" if position == "CTO"

eststo clear
eststo: estpost tabstat percent_with_pos if year == 2000, stats(mean) by(position) nototal
eststo: estpost tabstat percent_with_pos if year == 2020, stats(mean) by(position) nototal
eststo: estpost tabstat change_20yr if year == 2020, stats(mean) by(position) nototal

esttab, not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") title(Percent of firms with each position) varlabels(`e(labels)') label
esttab using "$export_directory/tables/change_positions_bal.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position (Balanced Sample)\label{tab98}) replace booktabs


* Average number of positions
use "$data_directory/c_suite_data", clear
drop if RowType == "Disclosed Earner"

* Prevalence of positions
gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

collapse (rawsum) pos*, by(year BoardID)

bysort BoardID: gen num_years = _N
keep if num_years == 21

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"
foreach position in `positions' {
	
	replace pos_`position' = 1 if pos_`position' > 0
	
}

gen num_positions = pos_CEO+pos_COO+pos_CFO+pos_CIO+pos_CTO+pos_CCO_comp+pos_CKO+pos_CDO+pos_CMO+pos_CSO_sec+pos_CSO_sus+pos_CAO+pos_CPO+pos_CCO_cont+pos_CHRO

collapse num_positions, by(year)
tsset year
tsline num_positions, ytitle("Average Number of C-Suite Positions per Company") xtitle("Year")
graph export "$export_directory/figs/num_positions_over_time_bal.png", replace

/*
local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	
	label var pos_`position' "Number of Companies with `position'"
	gen p_w_`position' = (pos_`position' / count) * 100
	label var p_w_`position' "% of Companies with `position'"
}

tsset year 
tsline p_w_CEO

tsline p_w_COO || tsline p_w_CTO || tsline p_w_CFO
*/


*** Look for Characteristics associated with each position
/*
import delimited "$data_directory/orbis_data_ISIN.csv", varnames(1) clear
rename isin ISIN
drop if ISIN == ""
*drop if Ticker == ""
save "$data_directory/orbis_data", replace
*/
** ALL COMPANIES
use "$data_directory/c_suite_data", clear
drop if RowType == "Disclosed Earner"

* Prevalence of positions
gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

collapse (rawsum) pos*, by(year BoardID Sector ISIN)

replace Sector = subinstr(Sector, "&", "+", .)
encode Sector, gen(sector1)

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
	label var pos_`position' "`position'"
}

sort BoardID year
bysort BoardID : gen age = _n

label var age "Age"

eststo clear
foreach pos in CEO COO CFO CTO {
	eststo: probit pos_`pos' age i.sector1 if year == 2020, vce(robust)
}
esttab, label title(Percent of firms with each C-Suite position (Balanced Sample)\label{tab98}) replace
esttab using "$export_directory/tables/probit_reg1.tex", label title(Probit reg of probability of having a C-Suite position in 2020 based on firm characteristics\label{tab1}) star(* 0.10 ** 0.05 *** 0.01) eqlabels("Probit") replace booktabs longtable nogaps not compress

merge m:1 BoardID using "$data_directory/company_size_data"
drop if _merge == 2
drop _merge

gen ln_Revenue = ln(Revenue)

label var ln_Revenue "Log(Rev)"

eststo clear
foreach pos in CEO COO CFO CTO {
	eststo: probit pos_`pos' ln_Revenue age i.sector1 if year == 2020, vce(robust)
	estadd local age_control "Y"
	estadd local sector_control "Y"
}
esttab, label title(Percent of firms with each C-Suite position (Balanced Sample)\label{tab98}) replace
esttab using "$export_directory/tables/probit_reg2.tex", label keep(ln_Revenue) s(N age_control sector_control, label("N" "Age Control?" "Sector Control?")) title(Probit reg of probability of having a C-Suite position in 2020 based on firm characteristics\label{tab1}) star(* 0.10 ** 0.05 *** 0.01) eqlabels("Probit") replace booktabs
