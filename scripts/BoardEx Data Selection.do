global data_directory "/export/home/dor/nloreedwards/Documents/BoardEx/data/"
global export_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex/output"
global working_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex"

cd "$working_directory"

* Compare classification methods
use "$data_directory/c_suite_data", clear

* Prevalence of positions
gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos

gen data_type = "Strict"

save "$data_directory/strict_data", replace

* Flexible Method
use "$data_directory/c_suite_data_expanded", clear

* Prevalence of positions
gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos

gen data_type = "Flexible"

save "$data_directory/flexible_data", replace

append using "$data_directory/strict_data"

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
eststo: estpost tabstat percent_with_pos if year == 2020 & data_type == "Strict", stats(mean) by(position) nototal
eststo: estpost tabstat percent_with_pos if year == 2020 & data_type == "Flexible", stats(mean) by(position) nototal
*eststo: estpost tabstat change_20yr if year == 2020, stats(mean) by(position) nototal

esttab, not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") title(Percent of firms with each position) varlabels(`e(labels)') label
esttab using "$export_directory/tables/change_positions_2methods.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("\% 2020 (Strict)" "\% 2020 (Flexible)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position, using two data classification methods\label{tab98}) replace booktabs

** Part 2: Subsamples
* Has Ticker
use "$data_directory/c_suite_data", clear

gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

drop if Ticker == ""

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos
replace change_20yr = -999 if position == "Obs"

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
esttab using "$export_directory/tables/change_positions_ticker.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position [Has Ticker]\label{tab98}) replace booktabs


* No. Emp > 1000
use "$data_directory/c_suite_data", clear

gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen num_positions = pos_CEO+pos_COO+pos_CFO+pos_CIO+pos_CTO+pos_CCO_comp+pos_CKO+pos_CDO+pos_CMO+pos_CSO_sec+pos_CSO_sus+pos_CAO+pos_CPO+pos_CCO_cont+pos_CHRO

merge m:1 BoardID using "$data_directory/company_size_data"
drop if _merge == 2
drop _merge

count if NoEmployees != . & year == 2020
binscatter num_positions NoEmployees if year == 2020, title("Corr between number of C-Suite positions" "and number of employees (2020)") xtitle("Number of employees") ytitle("Average number of positions" " ") note(Observations: `r(N)')
graph export "$export_directory/figs/corr_emp_num.png", replace

count if MktCapitalisation != . & year == 2020
binscatter num_positions MktCapitalisation if year == 2020, title("Corr between number of C-Suite positions" "and market cap (2020)") xtitle("Market Capitalization") ytitle("Average number of positions" " ") note(Observations: `r(N)')
graph export "$export_directory/figs/corr_mktcap_num.png", replace

count if Revenue != . & year == 2020
binscatter num_positions MktCapitalisation if year == 2020, title("Corr between number of C-Suite positions" "and revenue (2020)") xtitle("Revenue") ytitle("Average number of positions" " ") note(Observations: `r(N)')
graph export "$export_directory/figs/corr_rev_num.png", replace

drop if NoEmployees < 1000 | NoEmployees == .

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos
replace change_20yr = -999 if position == "Obs"

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
esttab using "$export_directory/tables/change_positions_emp.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position [No. Emp > 1000]\label{tab98}) replace booktabs


** US Only
use "$data_directory/c_suite_data", clear

gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

keep if HOCountryName == "United States"

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos
replace change_20yr = -999 if position == "Obs"

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
esttab using "$export_directory/tables/change_positions_US.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position [US Only]\label{tab98}) replace booktabs


** Num positions > 2
use "$data_directory/c_suite_data", clear

gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

keep if HOCountryName == "United States"

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen num_positions = pos_CEO+pos_COO+pos_CFO+pos_CIO+pos_CTO+pos_CCO_comp+pos_CKO+pos_CDO+pos_CMO+pos_CSO_sec+pos_CSO_sus+pos_CAO+pos_CPO+pos_CCO_cont+pos_CHRO

drop if num_positions < 2

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos
replace change_20yr = -999 if position == "Obs"

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
esttab using "$export_directory/tables/change_positions_numpos2.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position [Num Positions > 2]\label{tab98}) replace booktabs


********************************************************************************
*** Expanded ***

** Part 3: Subsamples
* Has Ticker
use "$data_directory/c_suite_data_expanded", clear

gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

drop if Ticker == ""

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos
replace change_20yr = -999 if position == "Obs"

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
esttab using "$export_directory/tables/change_positions_ticker_exp.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position [Has Ticker]\label{tab98}) replace booktabs


* No. Emp > 1000
use "$data_directory/c_suite_data_expanded", clear

gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen num_positions = pos_CEO+pos_COO+pos_CFO+pos_CIO+pos_CTO+pos_CCO_comp+pos_CKO+pos_CDO+pos_CMO+pos_CSO_sec+pos_CSO_sus+pos_CAO+pos_CPO+pos_CCO_cont+pos_CHRO

merge m:1 BoardID using "$data_directory/company_size_data"
drop if _merge == 2
drop _merge

count if NoEmployees != . & year == 2020
binscatter num_positions NoEmployees if year == 2020, title("Corr between number of C-Suite positions" "and number of employees (2020)") xtitle("Number of employees") ytitle("Average number of positions" " ") note(Observations: `r(N)')
graph export "$export_directory/figs/corr_emp_num_exp.png", replace

count if MktCapitalisation != . & year == 2020
binscatter num_positions MktCapitalisation if year == 2020, title("Corr between number of C-Suite positions" "and market cap (2020)") xtitle("Market Capitalization") ytitle("Average number of positions" " ") note(Observations: `r(N)')
graph export "$export_directory/figs/corr_mktcap_num_exp.png", replace

count if Revenue != . & year == 2020
binscatter num_positions MktCapitalisation if year == 2020, title("Corr between number of C-Suite positions" "and revenue (2020)") xtitle("Revenue") ytitle("Average number of positions" " ") note(Observations: `r(N)')
graph export "$export_directory/figs/corr_rev_num_exp.png", replace

drop if NoEmployees < 1000 | NoEmployees == .

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos
replace change_20yr = -999 if position == "Obs"

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
esttab using "$export_directory/tables/change_positions_emp_exp.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position [No. Emp > 1000]\label{tab98}) replace booktabs


** US Only
use "$data_directory/c_suite_data_expanded", clear

gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

keep if HOCountryName == "United States"

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos
replace change_20yr = -999 if position == "Obs"

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
esttab using "$export_directory/tables/change_positions_US_exp.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position [US Only]\label{tab98}) replace booktabs


** Num positions > 2
use "$data_directory/c_suite_data_expanded", clear

gen year = year(AnnualReportDate)
keep if year > 1999 & year < 2021
duplicates drop BoardID DirectorID year, force

keep if HOCountryName == "United States"

collapse (rawsum) pos*, by(year BoardID BoardName ISIN)

gen num_positions = pos_CEO+pos_COO+pos_CFO+pos_CIO+pos_CTO+pos_CCO_comp+pos_CKO+pos_CDO+pos_CMO+pos_CSO_sec+pos_CSO_sus+pos_CAO+pos_CPO+pos_CCO_cont+pos_CHRO

drop if num_positions < 2

gen count = 1

local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"

foreach position in `positions'{
	replace pos_`position' = 1 if pos_`position' > 0
}

collapse (rawsum) pos* count, by(year)

gen pos_Obs = count

reshape long pos_, i(year count) j(position) string
rename pos_ number

gen percent_with_pos = (number/count)*100
replace percent_with_pos = count if position == "Obs"
label var percent_with_pos "Percent of firms with position"

encode position, gen(position1)
xtset position1 year

gen change_20yr = percent_with_pos - L20.percent_with_pos
replace change_20yr = -999 if position == "Obs"

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
esttab using "$export_directory/tables/change_positions_numpos2_exp.tex", not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position [Num Positions > 2]\label{tab98}) replace booktabs
