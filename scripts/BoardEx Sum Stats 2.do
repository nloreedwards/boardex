global data_directory "/export/home/dor/nloreedwards/Documents/BoardEx/data/"
global working_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex"
global export_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex/output"

cd "$working_directory"

global positions "pos_Chair pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_COO pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO"

*** Companies over time
use "$data_directory/c_suite_data2_merged", clear

duplicates drop RoleName companyid year, force
keep if compustat == 1

collapse (rawsum) pos* (mean) revt emp at, by(year companyid)

label var revt "Revenue (millions $)"
label var emp "Employees"
label var at "Total Assets (millions $)"

eststo clear
eststo: estpost sum revt emp at if year == 2020, detail
esttab, label cells("count mean(fmt(%9.2f)) sd min p50 max") title("Sum stats of Compustat variables (2020)")
esttab using "$export_directory/tables/compu_sum_stats.tex", label cells("count mean(fmt(%9.2f)) sd min p50 max") title("Sum stats of Compustat variables (2020)") replace booktabs

eststo clear
eststo: estpost tab year
esttab, not noobs nostar nonumber nomtitle cells("b pct") collabels("N" "pct") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position\label{tab98})
esttab using "$export_directory/tables/companies_by_year.tex", not noobs nostar nonumber nomtitle cells("b pct") collabels("N" "pct") varlabels(`e(labels)') label title(Number of companies by year) replace booktabs

bysort companyid: gen company_index = _n
bysort companyid: gen num_years = _N

eststo clear
eststo: estpost tab num_years if company_index == 1
esttab using "$export_directory/tables/companies_num_years.tex", not noobs nostar nonumber nomtitle cells("b pct") collabels("N" "pct") varlabels(`e(labels)') label title(Number of companies by how many years of data we have) replace booktabs



* Number of positions over time
use "$data_directory/c_suite_data2_merged", clear

duplicates drop RoleName companyid year, force
keep if compustat == 1

mark co if strpos(RoleName, "Co-")

mark co_ceo if co == 1 & pos_CEO == 1
mark co_coo if co == 1 & pos_COO == 1
mark co_cfo if co == 1 & pos_CFO == 1

mark co_other if co == 1 & pos_CEO == 0 & pos_COO == 0 & pos_CFO == 0


collapse (rawsum) pos* co co_ceo co_cfo co_coo co_other (mean) revt emp at, by(year companyid)
foreach position in $positions {
	
	replace `position' = 1 if `position' > 0
	
}

egen num_positions = rowtotal($positions pos_Chief)

label var num_positions "Number of C-Suite positions"

gen ln_num_positions = ln(num_positions)
label var ln_num_positions "Log Number of C-Suite positions"

egen min_year = min(year), by(companyid)
egen max_year = max(year), by(companyid)
mark balanced if min_year == 2000 & max_year == 2020

count if year == 2020
local n_2020 = `r(N)'
hist num_positions if year == 2020, width(1) note(Companies: `r(N)') percent
graph export "$export_directory/figs/hist_num-positions2020.png", replace

count if year == 2000
local n_2000 = `r(N)'
hist num_positions if year == 2000, width(1) note(Companies: `r(N)') percent
graph export "$export_directory/figs/hist_num-positions2000.png", replace

twoway (hist num_positions if year == 2020, color(eltblue) width(1) percent) ///
 (hist num_positions if year == 2000, fcolor(none) lcolor(black) width(1) note("Companies (2000): `n_2000'; Companies (2020): `n_2020'") percent legend(label(1 "2020") label(2 "2000")))
graph export "$export_directory/figs/hist_num-positions.png", replace

count if year == 2020 & balanced == 1
twoway (hist num_positions if year == 2020 & balanced == 1, color(eltblue) width(1) percent) ///
 (hist num_positions if year == 2000 & balanced == 1, fcolor(none) lcolor(black) width(1) note("Companies `r(N)'") percent legend(label(1 "2020") label(2 "2000")))
graph export "$export_directory/figs/hist_num-positions_balanced.png", replace


label var revt "Revenue (millions $)"
label var emp "Employees"
label var at "Total Assets (millions $)"

foreach var in emp revt at {
	gen ln_`var' = ln(`var')
	label var ln_`var' "Log `: var label `var''"
}

foreach x in ln_revt ln_emp ln_at {
	binscatter ln_num_positions `x' if year == 2020, xtitle("`: var label `x''") ytitle("Log Number of C-Suite Positions (2020)")
	graph export "$export_directory/figs/corr_`x'_num.png", replace
}

foreach var in co co_ceo co_coo co_cfo co_other {
	mark has_`var' if `var' > 0
	gen has_`var'_bal = has_`var' if balanced == 1
}
mark has_Chief if pos_Chief > 0

gen has_Chief_bal = has_Chief if balanced == 1
gen num_positions_bal = num_positions if balanced == 1

egen num_positions_nonidio = rowtotal($positions)
gen num_positions_bal_nonidio = num_positions_nonidio if balanced == 1

bysort companyid: gen index = _n

replace emp = emp * 1000
egen max_emp = max(emp), by(companyid)

sum max_emp if index == 1, d

gen emp_bucket_max = .
replace emp_bucket_max = 10 if max_emp < r(p10) & max_emp != .
replace emp_bucket_max = 25 if max_emp >= r(p10) & max_emp < r(p25) & max_emp != .
replace emp_bucket_max = 50 if max_emp >= r(p25) & max_emp < r(p50) & max_emp != .
replace emp_bucket_max = 75 if max_emp >= r(p50) & max_emp < r(p75) & max_emp != .
replace emp_bucket_max = 90 if max_emp >= r(p75) & max_emp < r(p90) & max_emp != .
replace emp_bucket_max = 99 if max_emp >= r(p90) & max_emp < r(p99) & max_emp != .
replace emp_bucket_max = 100 if max_emp >= r(p99) & max_emp != .

sum max_emp if index == 1, d

gen emp_bucket = .
forvalues y=2000/2020 {
	
	sum emp if year == `y', d
	replace emp_bucket = 10 if emp < r(p10) & emp != . & year == `y'
	replace emp_bucket = 25 if emp >= r(p10) & emp < r(p25) & emp != . & year == `y'
	replace emp_bucket = 50 if emp >= r(p25) & emp < r(p50) & emp != . & year == `y'
	replace emp_bucket = 75 if emp >= r(p50) & emp < r(p75) & emp != . & year == `y'
	replace emp_bucket = 90 if emp >= r(p75) & emp < r(p90) & emp != . & year == `y'
	replace emp_bucket = 99 if emp >= r(p90) & emp < r(p99) & emp != . & year == `y'
	replace emp_bucket = 100 if emp >= r(p99) & emp != . & year == `y'
}

foreach var in emp_bucket emp_bucket_max {
	preserve
	 collapse num_positions has_co* has_Chief num_positions_bal num_positions_nonidio num_positions_bal_nonidio has_Chief_bal, by(year `var')
	 scatter num_positions year if `var' == 10, connect(L) || ///
	 scatter num_positions year if `var' == 25, connect(L) || ///
	 scatter num_positions year if `var' == 50, connect(L) || ///
	 scatter num_positions year if `var' == 75, connect(L) || ///
	 scatter num_positions year if `var' == 90, connect(L) || ///
	 scatter num_positions year if `var' == 99, connect(L) || ///
	 scatter num_positions year if `var' == 100, connect(L) ///
	 ytitle("Average Number of C-Suite Positions" "per Company") xtitle("Year") legend(label(1 "<10th ptile") label(2 "10-25th ptile") label(3 "25-50th ptile") label(4 "50-75th ptile") label(5 "75-90th ptile") label(6 "90-99th ptile") label(7 "99th ptile")) graphregion(color(white))
	 graph export "$export_directory/figs/num_pos_`var'.png", replace
	 
	 scatter num_positions_bal year if `var' == 10, connect(L) || ///
	 scatter num_positions_bal year if `var' == 25, connect(L) || ///
	 scatter num_positions_bal year if `var' == 50, connect(L) || ///
	 scatter num_positions_bal year if `var' == 75, connect(L) || ///
	 scatter num_positions_bal year if `var' == 90, connect(L) || ///
	 scatter num_positions_bal year if `var' == 99, connect(L) || ///
	 scatter num_positions_bal year if `var' == 100, connect(L) ///
	 ytitle("Average Number of C-Suite Positions" "per Company") xtitle("Year") legend(label(1 "<10th ptile") label(2 "10-25th ptile") label(3 "25-50th ptile") label(4 "50-75th ptile") label(5 "75-90th ptile") label(6 "90-99th ptile") label(7 "99th ptile")) graphregion(color(white))
	 graph export "$export_directory/figs/num_pos_bal_`var'.png", replace
	 
	 scatter num_positions_nonidio year if `var' == 10, connect(L) || ///
	 scatter num_positions_nonidio year if `var' == 25, connect(L) || ///
	 scatter num_positions_nonidio year if `var' == 50, connect(L) || ///
	 scatter num_positions_nonidio year if `var' == 75, connect(L) || ///
	 scatter num_positions_nonidio year if `var' == 90, connect(L) || ///
	 scatter num_positions_nonidio year if `var' == 99, connect(L) || ///
	 scatter num_positions_nonidio year if `var' == 100, connect(L) ///
	 ytitle("Average Number of C-Suite Positions" "per Company") xtitle("Year") legend(label(1 "<10th ptile") label(2 "10-25th ptile") label(3 "25-50th ptile") label(4 "50-75th ptile") label(5 "75-90th ptile") label(6 "90-99th ptile") label(7 "99th ptile")) graphregion(color(white))
	 graph export "$export_directory/figs/num_pos_nonidio_`var'.png", replace

	restore
}
collapse num_positions has_co* has_Chief num_positions_bal num_positions_nonidio num_positions_bal_nonidio has_Chief_bal, by(year)

tsset year
tsline num_positions, ytitle("Average Number of C-Suite Positions per Company") xtitle("Year")
graph export "$export_directory/figs/num_positions_over_time_compu.png", replace

tsline num_positions_bal, ytitle("Average Number of C-Suite Positions per Company") xtitle("Year")
graph export "$export_directory/figs/num_positions_over_time_compu_bal.png", replace

tsline num_positions_nonidio, ytitle("Average Number of C-Suite Positions per Company" "(Excluding Idiosyncratic Titles)") xtitle("Year")
graph export "$export_directory/figs/num_positions_over_time_compu_nonidio.png", replace

tsline num_positions_bal_nonidio, ytitle("Average Number of C-Suite Positions per Company" "(Excluding Idiosyncratic Titles)") xtitle("Year")
graph export "$export_directory/figs/num_positions_over_time_compu_bal_nonidio.png", replace

replace has_Chief = has_Chief * 100
tsline has_Chief, ytitle("Percent of Companies with at least 1 Idiosyncratic Position") xtitle("Year")
graph export "$export_directory/figs/has_chief_over_time_compu.png", replace

replace has_Chief_bal = has_Chief_bal * 100
tsline has_Chief_bal, ytitle("Percent of Companies with at least 1 Idiosyncratic Position") xtitle("Year")
graph export "$export_directory/figs/has_chief_over_time_compu_bal.png", replace

foreach var in co co_ceo co_coo co_cfo co_other {
	replace has_`var' = has_`var' * 100
}
tsline has_co, ytitle("Percent of Companies with at least 1 'Co-' Position") xtitle("Year")
graph export "$export_directory/figs/has_co_over_time_compu.png", replace

tsline has_co_ceo || tsline has_co_coo || tsline has_co_cfo || tsline has_co_other, ytitle("Percent of Companies with" "at least 1 'Co-' Position") xtitle("Year") legend(label(1 "Co-CEO") label(2 "Co-COO") label(3 "Co-CFO") label(4 "Other Co-")) graphregion(color(white))
graph export "$export_directory/figs/has_co_over_time_breakdown.png", replace

foreach var in co co_ceo co_coo co_cfo co_other {
	replace has_`var'_bal = has_`var'_bal * 100
}
tsline has_co_bal, ytitle("Percent of Companies with at least 1 'Co-' Position") xtitle("Year")
graph export "$export_directory/figs/has_co_over_time_compu_bal.png", replace

tsline has_co_ceo_bal || tsline has_co_coo_bal || tsline has_co_cfo_bal || tsline has_co_other_bal, ytitle("Percent of Companies with" "at least 1 'Co-' Position") xtitle("Year") legend(label(1 "Co-CEO") label(2 "Co-COO") label(3 "Co-CFO") label(4 "Other Co-")) graphregion(color(white))
graph export "$export_directory/figs/has_co_over_time_breakdown_bal.png", replace


/*
* Company names
use "$data_directory/c_suite_data2_merged", clear

drop if end_year == year

duplicates drop RoleName companyid year, force
keep if compustat == 1

merge m:1 companyid using "$data_directory/company_names"
drop if _merge == 2
drop _merge

gen num_positions = pos_CEO+pos_COO+pos_CFO+pos_CIO+pos_CTO+pos_CCO_comp+pos_CKO+pos_CDO+pos_CMO+pos_CSO_sec+pos_CSO_sus+pos_CAO+pos_CPO+pos_CCO_cont+pos_CHRO

mark pos_additional if pos_Chief == 0 & num_positions > 0
gen pos_total = pos_Chief
replace pos_total = pos_Chief + num_positions if pos_additional == 1

collapse (rawsum) pos*, by(year companyid CompanyName)
local positions "CEO COO CFO CIO CTO CCO_comp CKO CDO CMO CSO_sec CSO_sus CAO CPO CCO_cont CHRO"
foreach position in `positions' {
	
	replace pos_`position' = 1 if pos_`position' > 0
	
}

gen num_positions = pos_CEO+pos_COO+pos_CFO+pos_CIO+pos_CTO+pos_CCO_comp+pos_CKO+pos_CDO+pos_CMO+pos_CSO_sec+pos_CSO_sus+pos_CAO+pos_CPO+pos_CCO_cont+pos_CHRO

keep if year == 2020

collapse num_positions pos_Chief pos_total, by(CompanyName)

keep CompanyName pos_total
export delimited "$export_directory/company_positions_2020.csv", replace
*/

use "$data_directory/c_suite_data2_merged", clear

duplicates drop RoleName companyid year, force
keep if compustat == 1

/*
mark has_emp if emp != .
mark has_rev if revt != .
mark has_assets if at != .

gen has_total = has_emp + has_rev + has_assets

egen max_has = max(has_total), by(companyid)

keep if max_has > 0
*/

collapse (rawsum) pos*, by(year companyid)

gen count = 1

egen pos_OtherAdmin = rowmax(pos_CAO pos_CGov pos_CDiv pos_CTal pos_CStaff)
egen pos_OtherFin = rowmax(pos_CAE pos_CCredit pos_CInvest pos_CRev pos_CBank pos_CTax)
egen pos_OtherBus = rowmax(pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand)
egen pos_OtherSTEM = rowmax(pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CDigit pos_CInnov)
egen pos_OtherOper = rowmax(pos_CRisk pos_CSO_sec pos_CEthics pos_CProcure pos_CSupp)

drop pos_CRisk pos_CSO_sec pos_CAO pos_CGov pos_CDiv pos_CTal pos_CAE pos_CCredit pos_CInvest pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CEthics pos_CStaff pos_CRev pos_CBank pos_CTax pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand pos_CDigit pos_CInnov pos_CProcure pos_CSupp

local kept_positions "pos_Chair pos_Chief pos_CEO pos_CFO pos_COO pos_CAcc pos_CHRO pos_CIO pos_CTO pos_CCO_comp pos_CMO pos_CLegal pos_CBus pos_CMed pos_CCounsel pos_OtherAdmin pos_OtherFin pos_OtherBus pos_OtherSTEM pos_OtherOper"
foreach position in `kept_positions'{
	replace `position' = 1 if `position' > 0
}

label var pos_Chair "Chairperson/President"
label var pos_CAcc "Chief Accounting Officer"
label var pos_CBus "Chief Business Officer"
label var pos_CCO_comp "Chief Compliance Officer"
label var pos_CCounsel "Chief Counsel / General Counsel"
label var pos_CEO "Chief Executive Officer"
label var pos_CFO "Chief Financial Officer"
label var pos_CHRO "Chief Human Resources Officer"
label var pos_CIO "Chief Investment Officer"
label var pos_CLegal "Chief Legal Officer"
label var pos_CMO "Chief Marketing Officer"
label var pos_CMed "Chief Medical Officer"
label var pos_COO "Chief Operating Officer"
label var pos_CTO "Chief Technology Officer"
label var pos_Chief "Chief (Other)"
label var pos_OtherAdmin "Other (Admin)"
label var pos_OtherFin "Other (Financial)"
label var pos_OtherBus "Other (Business/Marketing)"
label var pos_OtherSTEM "Other (STEM-Related)"
label var pos_OtherOper "Other (Operations)"

estpost corr pos_CEO pos_Chair pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_1.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) title("Correlations of executive positions") booktabs replace

estpost corr pos_CFO pos_CAcc pos_OtherFin pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_2.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of financial positions")

estpost corr pos_COO pos_CMO pos_CBus pos_OtherOper pos_OtherBus pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_3.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of operational positions")

estpost corr pos_CHRO pos_OtherAdmin, matrix listwise
esttab using "$export_directory/tables/corr_3b.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of HR positions")

estpost corr pos_CLegal pos_CCounsel pos_CCO_comp pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_4.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of legal positions")

estpost corr pos_CTO pos_CIO pos_CMed pos_OtherSTEM pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_5.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of technical positions")

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

gen function = 0
replace function = 1 if position == "CEO" | position == "Chair" // executive
replace function = 2 if position == "CFO" | position == "OtherFin" | position == "CAcc"
replace function = 3 if position == "COO" | position == "OtherOper" | position == "CHRO" | position == "OtherBus" | position == "CMO" | position == "CBus" | position == "OtherAdmin"
replace function = 4 if position == "CLegal" | position == "CCounsel" | position == "CCO_comp"
replace function = 5 if position == "OtherSTEM" | position == "CTO" | position == "CIO" | position == "CMed"
replace function = 6 if position == "Chief"
replace function = 7 if position == "Obs"

replace position = "Chief audit executive" if position == "CAE"
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
replace position = "Chief accounting officer" if position == "CAcc"
replace position = "Chief business officer" if position == "CBus"
replace position = "Chief commercial officer" if position == "CComm"
replace position = "Chief medical officer" if position == "CMed"
replace position = "Chief risk officer" if position == "CRisk"
replace position = "Chief scientific officer" if position == "CSci"
replace position = "Chief credit officer" if position == "CCredit"
replace position = "Chief governance officer" if position == "CGov"
replace position = "Chief talent officer" if position == "CTal"
replace position = "Chief counsel / General counsel" if position == "CCounsel"
replace position = "Chief creative officer" if position == "CCreat"
replace position = "Chief strategy officer" if position == "CStrat"
replace position = "Chief legal officer" if position == "CLegal"
replace position = "Chief investment officer" if position == "CInvest"
replace position = "Chief diversity officer" if position == "CDiv"
replace position = "Chief (other)" if position == "Chief"
replace position = "Chairperson/President" if position == "Chair"

replace position = "Other (Risk)" if position == "OtherRisk"
replace position = "Other (Business/Marketing)" if position == "OtherBus"
replace position = "Other (Admin)" if position == "OtherAdmin"
replace position = "Other (Financial)" if position == "OtherFin"
replace position = "Other (STEM-Related)" if position == "OtherSTEM"
replace position = "Other (Operations)" if position == "OtherOper"


myaxis position2020 = position, sort(mean percent_with_pos) subset(year == 2020) descending
myaxis position2020_funct = position2020, sort(mean function) subset(year == 2020)

eststo clear
eststo: estpost tabstat percent_with_pos if year == 2000, stats(mean) by(position2020_funct) nototal
eststo: estpost tabstat percent_with_pos if year == 2020, s(mean) by(position2020_funct) nototal
eststo: estpost tabstat change_20yr if year == 2020, stats(mean) by(position2020_funct) nototal

esttab, not noobs nostar nonumber nomtitle cell(mean(fmt (%2.1f))) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") title(Percent of firms with each position) varlabels(`e(labels)') label
esttab using "$export_directory/tables/change_positions_compu.tex", not noobs nostar nonumber nomtitle cell(mean(fmt (%2.1f))) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position\label{tab98}) replace booktabs addnote("\textbf{Other (Admin):} Chief Administration Officer, Chief Governance Officer, Chief Diversity Officer, Chief Talent Officer, Chief of Staff; /textbf{Other (Finance):} Chief Audit Executive, Chief Credit Officer, Chief Investment Officer, Chief Revenue Officer, Chief Banking Officer, Chief Tax Officer; \textbf{Other (Business/Marketing):} Chief commercial officer, Chief content office, Chief Creative Officer, Chief Product Officer, Chief Strategy Officer, Chief Customer Officer, Chief Communication Officer, Chief Merchandise Officer, Chief Sales Officer, Chief Development Officer, Chief Brand Officer; \textbf{Other (STEM-Related): } Chief Data Officer, Chief Knowledge Officer, Chief Scientific Officer, Chief Sustainability Officer, Chief Digital Officer, Chief Innovation Officer; \textbf{Other (Operations): } Chief Procurement Officer, Chief Supply Chain Officer, Chief Risk Officer, Chief Security Officer, Chief Ethics Officer")

tempfile positions_allfirms
save `positions_allfirms', replace

*** Balanced Sample
use "$data_directory/c_suite_data2_merged", clear

duplicates drop RoleName companyid year, force
keep if compustat == 1

collapse (rawsum) pos*, by(year companyid)

gen count = 1
egen min_year = min(year), by(companyid)
egen max_year = max(year), by(companyid)
mark balanced if min_year == 2000 & max_year == 2020

keep if balanced == 1

egen pos_OtherAdmin = rowmax(pos_CAO pos_CGov pos_CDiv pos_CTal pos_CStaff)
egen pos_OtherFin = rowmax(pos_CAE pos_CCredit pos_CInvest pos_CRev pos_CBank pos_CTax)
egen pos_OtherBus = rowmax(pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand)
egen pos_OtherSTEM = rowmax(pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CDigit pos_CInnov)
egen pos_OtherOper = rowmax(pos_CRisk pos_CSO_sec pos_CEthics pos_CProcure pos_CSupp)

drop pos_CRisk pos_CSO_sec pos_CAO pos_CGov pos_CDiv pos_CTal pos_CAE pos_CCredit pos_CInvest pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CEthics pos_CStaff pos_CRev pos_CBank pos_CTax pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand pos_CDigit pos_CInnov pos_CProcure pos_CSupp

local kept_positions "pos_Chair pos_Chief pos_CEO pos_CFO pos_COO pos_CAcc pos_CHRO pos_CIO pos_CTO pos_CCO_comp pos_CMO pos_CLegal pos_CBus pos_CMed pos_CCounsel pos_OtherAdmin pos_OtherFin pos_OtherBus pos_OtherSTEM pos_OtherOper"
foreach position in `kept_positions'{
	replace `position' = 1 if `position' > 0
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

gen function = 0
replace function = 1 if position == "CEO" | position == "Chair" // executive
replace function = 2 if position == "CFO" | position == "OtherFin" | position == "CAcc"
replace function = 3 if position == "COO" | position == "OtherOper" | position == "CHRO" | position == "OtherBus" | position == "CMO" | position == "CBus" | position == "OtherAdmin"
replace function = 4 if position == "CLegal" | position == "CCounsel" | position == "CCO_comp"
replace function = 5 if position == "OtherSTEM" | position == "CTO" | position == "CIO" | position == "CMed"
replace function = 6 if position == "Chief"
replace function = 7 if position == "Obs"

replace position = "Chief audit executive" if position == "CAE"
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
replace position = "Chief accounting officer" if position == "CAcc"
replace position = "Chief business officer" if position == "CBus"
replace position = "Chief commercial officer" if position == "CComm"
replace position = "Chief medical officer" if position == "CMed"
replace position = "Chief risk officer" if position == "CRisk"
replace position = "Chief scientific officer" if position == "CSci"
replace position = "Chief credit officer" if position == "CCredit"
replace position = "Chief governance officer" if position == "CGov"
replace position = "Chief talent officer" if position == "CTal"
replace position = "Chief counsel / General counsel" if position == "CCounsel"
replace position = "Chief creative officer" if position == "CCreat"
replace position = "Chief strategy officer" if position == "CStrat"
replace position = "Chief legal officer" if position == "CLegal"
replace position = "Chief investment officer" if position == "CInvest"
replace position = "Chief diversity officer" if position == "CDiv"
replace position = "Chief (other)" if position == "Chief"
replace position = "Chairperson/President" if position == "Chair"

replace position = "Other (Risk)" if position == "OtherRisk"
replace position = "Other (Business/Marketing)" if position == "OtherBus"
replace position = "Other (Admin)" if position == "OtherAdmin"
replace position = "Other (Financial)" if position == "OtherFin"
replace position = "Other (STEM-Related)" if position == "OtherSTEM"
replace position = "Other (Operations)" if position == "OtherOper"



myaxis position2020 = position, sort(mean percent_with_pos) subset(year == 2020) descending
myaxis position2020_funct = position2020, sort(mean function) subset(year == 2020)

eststo clear
eststo: estpost tabstat percent_with_pos if year == 2000, stats(mean) by(position2020_funct) nototal
eststo: estpost tabstat percent_with_pos if year == 2020, s(mean) by(position2020_funct) nototal
eststo: estpost tabstat change_20yr if year == 2020, stats(mean) by(position2020_funct) nototal

esttab, not noobs nostar nonumber nomtitle cell(Mean) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") title(Percent of firms with each position) varlabels(`e(labels)') label
esttab using "$export_directory/tables/change_positions_compu_bal.tex", not noobs nostar nonumber nomtitle cell(Mean(fmt (%2.1f))) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position (BALANCED)\label{tab98}) replace booktabs addnote("\textbf{Other (Admin):} Chief Administration Officer, Chief Governance Officer, Chief Diversity Officer, Chief Talent Officer, Chief of Staff; /textbf{Other (Finance):} Chief Audit Executive, Chief Credit Officer, Chief Investment Officer, Chief Revenue Officer, Chief Banking Officer, Chief Tax Officer; \textbf{Other (Business/Marketing):} Chief commercial officer, Chief content office, Chief Creative Officer, Chief Product Officer, Chief Strategy Officer, Chief Customer Officer, Chief Communication Officer, Chief Merchandise Officer, Chief Sales Officer, Chief Development Officer, Chief Brand Officer; \textbf{Other (STEM-Related): } Chief Data Officer, Chief Knowledge Officer, Chief Scientific Officer, Chief Sustainability Officer, Chief Digital Officer, Chief Innovation Officer; \textbf{Other (Operations): } Chief Procurement Officer, Chief Supply Chain Officer, Chief Risk Officer, Chief Security Officer, Chief Ethics Officer")

rename change_20yr change_20yr_bal
rename percent_with_pos percent_with_pos_bal
merge 1:1 year position using `positions_allfirms'

scatter change_20yr_bal change_20yr if year == 2020 & position != "Obs", xtitle("20-Year Change") ytitle("20-Year Change (Balanced)")
graph export "$export_directory/change_20yr_comparison.png", replace

import delimited "$data_directory/isic_naics_taxonomy.csv", clear varnames(1)
drop naics_name
reshape long naics_code, i(isic_name isic_code tech_taxonomy2000 tech_taxonomy2020) j(temp)

drop if naics_code == .
drop temp

rename naics_code naics3

save "$data_directory/isic_naics_taxonomy.dta"

* Linear probability model
use "$data_directory/c_suite_data2_merged", clear

duplicates drop RoleName companyid year, force
keep if compustat == 1

mark co if strpos(RoleName, "Co-")

collapse (rawsum) pos* co (mean) revt emp at, by(year companyid gvkey naics sic)

label var revt "Revenue (millions $)"
label var emp "Employees"
label var at "Total Assets (millions $)"

foreach position in $positions {
	
	replace `position' = 1 if `position' > 0
	
}

egen num_positions = rowtotal($positions pos_Chief)
gen ln_num_positions = ln(num_positions)
label var num_positions "Number of C-Suite positions"
label var ln_num_positions "Log Num of C-Suite positions"


mark has_idio if pos_Chief > 0
label var has_idio "Has Idiosyncratic Title"

mark has_co if co > 0
label var has_co "Has Co- Title"

gen naics_2 = substr(naics, 1,2)
replace naics_2 = "99" if naics_2 == ""
destring naics_2, replace

gen naics_3 = substr(naics, 1,3)
replace naics_3 = "999" if naics_3 == ""

gen naics_5 = substr(naics, 1,5)

gen naics_4 = substr(naics, 1,4)
replace naics_4 = "9999" if naics_4 == ""

foreach var in emp revt at {
	gen ln_`var' = ln(`var')
	label var ln_`var' "Log `: var label `var''"
}

replace naics_2 = 31 if naics_2 == 33 | naics_2 == 32
replace naics_2 = 44 if naics_2 == 45
replace naics_2 = 48 if naics_2 == 49

label define sector 11 "Agriculture, Forestry, Fishing and Hunting" 21 "Mining, Quarrying, and Oil and Gas Extraction" 22 "Utilities" 23 "Construction" 31 "Manufacturing" 42 "Wholesale Trade" 44 "Retail Trade" 48 "Transportation and Warehousing" 51 "Information" 52 "Finance and Insurance" 53 "Real Estate and Rental and Leasing" 54 "Professional, Scientific, and Technical Services" 55 "Management of Companies and Enterprises" 56 "ASWMRS" 61 "Educational Services" 62 "Health Care and Social Assistance" 71 "Arts, Entertainment, and Recreation" 72 "Accommodation and Food Services" 81 "Other Services (except Public Administration)" 92 "Public Administration" 99 "Missing"

gen naics3 = naics_3
replace naics3 = "423" if naics3 == "42"
replace naics3 = "423" if naics3 == "421"
replace naics3 = "515" if naics3 == "513"
replace naics3 = "515" if naics3 == "516"
destring naics3, replace

merge m:1 naics3 using "$data_directory/isic_naics_taxonomy.dta"
drop if _merge == 2
drop _merge

encode tech_taxonomy2020, gen(tech_taxonomy2020_i)

gen knowledge_1 = 0

foreach naics in 334511 334512 {
	
	replace knowledge_1 = 1 if naics == "`naics'"
	
}

foreach naics in 32541 33331 33411 33421 33422 33429 33431 33441 33592 33641 51121 51211 51219 51321 51322 51331 51332 51333 51334 51339 51421 54136 54137 54138 54151 54162 54169 54171 {
	
	replace knowledge_1 = 1 if naics_5 == "`naics'"
	
}


gen knowledge_2 = 0

foreach naics in 221111 221112 221113 221119 221121 221122 324110 324121 324190 325110 325120 325130 325181 325189 325190 325210 325313 325314 325320 325520 325599 325910 325920 325991 325999 332991 333110 333120 333130 33210 333220 333291 333299 333413 333416 333611 333619 333910 333920 333990 335311 335312 335315 336320 486110 486210 486910 486990 541310 541320 541330 541340 {
	
	replace knowledge_2 = 1 if naics == "`naics'"
}

foreach naics in 32411 32419 32511 32512 32513 32519 32521 32532 32552 32591 32592 33311 33312 33313 33210 33322 33391 33392 33399 33632 48611 48621 48691 48699 54131 54132 54133 54134 {
	
	replace knowledge_2 = 1 if naics_5 == "`naics'"
}

destring naics_3, gen(naics_3_int)

replace naics_3 = "23" if naics_3 == "236" | naics_3 == "237" | naics_3 == "238"
replace naics_3 = "52M" if naics_3 == "525" | naics_3 == "523"
replace naics_3 = "53M" if naics_3 == "533"
merge m:1 naics_3 year using "$data_directory/naics_college"
drop if _merge == 2
drop _merge

destring naics_4, replace

merge m:1 naics_4 using "$data_directory/r_and_d"
*drop if _merge == 2

gen ln_r_d_spending_peremp = ln(r_d_spending_peremp)

label var knowledge_1 "Knowledge Intensive (Tier I)"
label var knowledge_2 "Knowledge Intensive (Tier II)"
label var bachelors "Share With Bachelor's \\ Degree (Industry-Level)"
label var r_d_spending_peremp "Domestic R\&D Spending Per Worker (2009)" 
label var share_workers_stem "Share of Industry Workers \\ in STEM Occupations (2012)"
label var ln_r_d_spending_peremp "Log Domestic R\&D \\ Spending Per Worker (2009)" 

*bysort companyid: gen company_index = _n

*sum emp if company_index == 1, detail
*mark above_med_emp if emp > `r(p50)'


label values naics_2 sector

xtset companyid year

forvalues y=2000/2020 {
	
	mark year_`y' if year == `y'
	if `y' == 2001 | `y' == 2003 | `y' == 2005 | `y' == 2007 | `y' == 2009 | `y' == 2011 | `y' == 2013 | `y' == 2015 | `y' == 2017 | `y' == 2019 {
	label var year_`y' "`y'"
	}
}

drop year_2000

drop if companyid == .
drop _merge

save "$data_directory/reg_data.dta", replace

merge m:1 gvkey year using "$data_directory/RD_data_clean"
drop if _merge == 2
drop _merge

gen rd_emp = xrd / emp
gen rd_revt = xrd / revt_rd

replace rd_emp = 0 if rd_emp < 0
replace rd_revt = 0 if rd_revt < 0

save "$data_directory/reg_data.dta", replace


use "$data_directory/reg_data.dta", clear

bysort companyid: gen index = _n

replace emp = emp * 1000
egen max_emp = max(emp), by(companyid)

sum max_emp if index == 1, d

gen emp_bucket_max = .
replace emp_bucket_max = 10 if max_emp < r(p10) & max_emp != .
replace emp_bucket_max = 25 if max_emp >= r(p10) & max_emp < r(p25) & max_emp != .
replace emp_bucket_max = 50 if max_emp >= r(p25) & max_emp < r(p50) & max_emp != .
replace emp_bucket_max = 75 if max_emp >= r(p50) & max_emp < r(p75) & max_emp != .
replace emp_bucket_max = 90 if max_emp >= r(p75) & max_emp < r(p90) & max_emp != .
replace emp_bucket_max = 99 if max_emp >= r(p90) & max_emp < r(p99) & max_emp != .
replace emp_bucket_max = 100 if max_emp >= r(p99) & max_emp != .


reg ln_num_positions ln_emp year_* b31.naics_2 if above_med_emp == 1, cluster(companyid) r
estimates store A
reg ln_num_positions ln_emp year_* b31.naics_2 if above_med_emp == 0, cluster(companyid) r
estimates store B
coefplot A B, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Coefficient on Year Dummies") legend(label(2 "Above median emp") label(4 "Below median emp"))
graph export "$export_directory/figs/year_coefplot.png", replace

* Year FE coefficient plot
reg ln_num_positions year_* if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
reg ln_num_positions year_* b31.naics_2 if naics_2 != 92, cluster(companyid) r
local r2_2 = round(e(r2_a), 0.01)
local f_2 = round(e(F), 1)
estimates store B
coefplot A B, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Coefficient on Year Dummies") legend(label(2 "No controls") label(4 "2-Digit Industry controls")) note("Adj R2s: 0`r2_1', 0`r2_2'" "F-stats: `f_1', `f_2'")
graph export "$export_directory/figs/year_coefplot_comparison.png", replace

* Year FE coefficient plot (Emp controls)
reg ln_num_positions ln_emp year_* if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
reg ln_num_positions ln_emp year_* b31.naics_2 if naics_2 != 92, cluster(companyid) r
local r2_2 = round(e(r2_a), 0.01)
local f_2 = round(e(F), 1)
estimates store B
coefplot A B, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Coefficient on Year Dummies") legend(label(2 "Log(emp) control") label(4 "Log(emp) + Industry controls")) note("Adj R2s: 0`r2_1', 0`r2_2'" "F-stats: `f_1', `f_2'")
graph export "$export_directory/figs/year_coefplot_comparison2.png", replace

* Year FE coefficient plot (combined)
reg ln_num_positions year_* if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
reg ln_num_positions year_* b31.naics_2 if naics_2 != 92, cluster(companyid) r
local r2_2 = round(e(r2_a), 0.01)
local f_2 = round(e(F), 1)
estimates store B
reg ln_num_positions ln_emp year_* if naics_2 != 92, cluster(companyid) r
local r2_3 = round(e(r2_a), 0.01)
local f_3 = round(e(F), 1)
estimates store C
reg ln_num_positions ln_emp year_* b31.naics_2 if naics_2 != 92, cluster(companyid) r
local r2_4 = round(e(r2_a), 0.01)
local f_4 = round(e(F), 1)
estimates store D
coefplot A B C D, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Coefficient on Year Dummies") legend(label(2 "No controls") label(4 "2-Digit Industry controls") label(6 "Log(emp) control") label(8 "Log(emp) + Industry controls")) note("Adj R2s: 0`r2_1', 0`r2_2', 0`r2_3', 0`r2_4'" "F-stats: `f_1', `f_2', `f_3', `f_4'") graphregion(color(white))
graph export "$export_directory/figs/year_coefplot_combined.png", replace

* Year FE regressions
eststo clear
eststo: reg ln_num_positions i.year if naics_2 != 92, cluster(companyid) r
estadd local naics "N"
estadd local emp "N"
eststo: reg ln_num_positions i.year b31.naics_2 if naics_2 != 92, cluster(companyid) r
estadd local naics "Y"
estadd local emp "N"
eststo: reg ln_num_positions ln_emp i.year if naics_2 != 92, cluster(companyid) r
estadd local naics "N"
estadd local emp "Y"
eststo: reg ln_num_positions ln_emp i.year b31.naics_2 if naics_2 != 92, cluster(companyid) r
estadd local naics "Y"
estadd local emp "Y"

esttab, label se s(N r2_w, label("N" "R-sq")) title(Number of positions on fixed-effects regressions\label{tab98})
esttab using "$export_directory/tables/year_fe.tex", keep(*year ln_emp) se s(N r2 r2_a F naics emp, label("N" "R-sq" "Adj R-sq" "F-stat" "NAICS FE?" "ln(Emp) Control?")) label title("Number of positions on fixed-effects regressions\label{tab1}") star(* 0.10 ** 0.05 *** 0.01) replace booktabs

* Industry FE plot
eststo clear
reg ln_num_positions year_* b31.naics_2 ln_emp if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
coefplot A, keep(*naics_2*) xtitle("Coefficient on Industry Dummies", size(2)) note("Adj R2: 0`r2_1'" "F-stat: `f_1'", size(2)) ylabel(, labsize(2)) xline(0) xlabel(, labsize(2)) sort graphregion(color(white))
graph export "$export_directory/figs/ind_coefplot_comparison.png", replace

eststo clear
reg ln_num_positions year_* b31.naics_2 if naics_2 != 92 & (emp_bucket_max == 99 | emp_bucket_max == 100), cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
coefplot A, keep(*naics_2*) xtitle("Coefficient on Industry Dummies", size(2)) note("Adj R2: 0`r2_1'" "F-stat: `f_1'", size(2)) ylabel(, labsize(2)) xline(0) xlabel(, labsize(2)) sort graphregion(color(white))
graph export "$export_directory/figs/ind_coefplot_comparison_90th.png", replace

gen c_ln_num_positions = ln_num_positions - L1.ln_num_positions
eststo clear
reg c_ln_num_positions i.year b31.naics_2 ln_emp if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
coefplot A, keep(*naics_2*) xtitle("Coefficient on Industry Dummies", size(2)) note("Adj R2: 0`r2_1'" "F-stat: `f_1'", size(2)) ylabel(, labsize(2)) xline(0) xlabel(, labsize(2)) sort graphregion(color(white))
graph export "$export_directory/figs/ind_coefplot_change.png", replace

gen c20_ln_num_positions = ln_num_positions - L20.ln_num_positions
eststo clear
reg c20_ln_num_positions year_* b31.naics_2 ln_emp if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
coefplot A, keep(*naics_2*) xtitle("Coefficient on Industry Dummies", size(2)) note("Adj R2: 0`r2_1'" "F-stat: `f_1'", size(2)) ylabel(, labsize(2)) xline(0) xlabel(, labsize(2)) sort graphregion(color(white))
graph export "$export_directory/figs/ind_coefplot_change20y.png", replace


reg ln_num_positions year_* ln_emp if naics_2 == 51, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
reg ln_num_positions year_* ln_emp if naics_2 == 52, cluster(companyid) r
local r2_2 = round(e(r2_a), 0.01)
local f_2 = round(e(F), 1)
estimates store B
reg ln_num_positions year_* ln_emp if naics_2 != 51 & naics_2 != 52, cluster(companyid) r
local r2_3 = round(e(r2_a), 0.01)
local f_3 = round(e(F), 1)
estimates store C
coefplot A B C, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Year Indicator") legend(label(2 "Only Information") label(4 "Only Finance/Insur.") label(6 "All Excl. Info & Fin/Insur")) note("Adj R2s: 0`r2_1', 0`r2_2', 0`r2_3'" "F-stats: `f_1', `f_2', `f_3'") ytitle("Coefficient on year indicator, with log number" "of C-suite positions as dependent variable") graphregion(color(white))
graph export "$export_directory/figs/year_coefplot_ind5152.png", replace

* Ind FE with other explanatroy vars
eststo clear
reg has_co year_* b31.naics_2 ln_emp if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
coefplot A, keep(*naics_2*) xtitle("Coefficient on Industry Dummies", size(2)) note("Adj R2: 0`r2_1'" "F-stat: `f_1'", size(2)) ylabel(, labsize(2)) xline(0) xlabel(, labsize(2)) sort graphregion(color(white))
graph export "$export_directory/figs/ind_coefplot_co.png", replace

eststo clear
reg has_idio year_* b31.naics_2 ln_emp if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
coefplot A, keep(*naics_2*) xtitle("Coefficient on Industry Dummies", size(2)) note("Adj R2: 0`r2_1'" "F-stat: `f_1'", size(2)) ylabel(, labsize(2)) xline(0) xlabel(, labsize(2)) sort graphregion(color(white))
graph export "$export_directory/figs/ind_coefplot_idio.png", replace


* 90th emp percentile
reg ln_num_positions year_* if naics_2 == 51 & (emp_bucket_max == 99 | emp_bucket_max == 100), cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
reg ln_num_positions year_* if naics_2 == 52 & (emp_bucket_max == 99 | emp_bucket_max == 100), cluster(companyid) r
local r2_2 = round(e(r2_a), 0.01)
local f_2 = round(e(F), 1)
estimates store B
reg ln_num_positions year_* if naics_2 != 51 & naics_2 != 52 & (emp_bucket_max == 99 | emp_bucket_max == 100), cluster(companyid) r
local r2_3 = round(e(r2_a), 0.01)
local f_3 = round(e(F), 1)
estimates store C
coefplot A B C, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Year Indicator") legend(label(2 "Only Information") label(4 "Only Finance/Insur.") label(6 "All Excl. Info & Fin/Insur")) note("Adj R2s: 0`r2_1', 0`r2_2', 0`r2_3'" "F-stats: `f_1', `f_2', `f_3'") ytitle("Coefficient on year indicator, with log number" "of C-suite positions as dependent variable") graphregion(color(white))
graph export "$export_directory/figs/year_coefplot_ind5152_90th.png", replace


* 90th emp percentile
reg ln_num_positions year_* ln_emp i.year b31.naics_2 if (emp_bucket_max == 99 | emp_bucket_max == 100), cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
reg ln_num_positions year_* ln_emp i.year b31.naics_2 if emp_bucket_max != 99 & emp_bucket_max != 100 & emp_bucket_max != ., cluster(companyid) r
local r2_2 = round(e(r2_a), 0.01)
local f_2 = round(e(F), 1)
estimates store B
coefplot A B, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Year Indicator") legend(label(2 "Only Information") label(4 "Only Finance/Insur.") label(6 "All Excl. Info & Fin/Insur")) note("Adj R2s: 0`r2_1', 0`r2_2', 0`r2_3'" "F-stats: `f_1', `f_2', `f_3'") ytitle("Coefficient on year indicator, with log number" "of C-suite positions as dependent variable") graphregion(color(white))
graph export "$export_directory/figs/year_coefplot_ind5152_90th.png", replace

* Employment indicator
eststo clear
reg ln_num_positions i.year b31.naics_2 i.emp_bucket_max if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
coefplot A, keep(*emp_bucket_max*) xtitle("Coefficient on employment indicator, with log number" "of C-suite positions as dependent variable") note("Adj R2: 0`r2_1'" "F-stat: `f_1'") xline(0) sort graphregion(color(white)) coeflabels(25.emp_bucket_max = "10-25th ptile" 50.emp_bucket_max = "25-50th ptile" 75.emp_bucket_max = "50-75th ptile" 90.emp_bucket_max = "75-90th ptile" 99.emp_bucket_max = "90-99th ptile" 100.emp_bucket_max = "99th ptile")
graph export "$export_directory/figs/emp_coefplot_comparison.png", replace

* Employment indicator (yearly change)
eststo clear
reg c_ln_num_positions i.year b31.naics_2 i.emp_bucket_max if naics_2 != 92, cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
coefplot A, keep(*emp_bucket_max*) xtitle("Coefficient on employment indicator, with yearly change in log number" "of C-suite positions as dependent variable") note("Adj R2: 0`r2_1'" "F-stat: `f_1'") xline(0) sort graphregion(color(white)) coeflabels(25.emp_bucket_max = "10-25th ptile" 50.emp_bucket_max = "25-50th ptile" 75.emp_bucket_max = "50-75th ptile" 90.emp_bucket_max = "75-90th ptile" 99.emp_bucket_max = "90-99th ptile" 100.emp_bucket_max = "99th ptile")
graph export "$export_directory/figs/emp_coefplot_change.png", replace


* Employment interaction
mark emp_90 if emp_bucket_max == 99 | emp_bucket_max == 100

matrix coefs_A = J(1,20,.)
matrix CI_A = J(2,20,.)
matrix rownames CI_A= ll95 ul95

matrix coefs_B = J(1,20,.)
matrix CI_B = J(2,20,.)
matrix rownames CI_B= ll95 ul95

* emp control
reg ln_num_positions ln_emp i.year##i.emp_90 b31.naics_2, cluster(companyid) r
forvalues y=2001/2020 {
	
	local i = `y' - 2000
	lincom `y'.year
	matrix coefs_A[1, `i'] = r(estimate)
	matrix CI_A[1, `i'] = r(lb) \ r(ub)
	
	lincom `y'.year + `y'.year#1.emp_90
	matrix coefs_B[1, `i'] = r(estimate)
	matrix CI_B[1, `i'] = r(lb) \ r(ub)
	
}
coefplot (matrix(coefs_A), ci(CI_A)) (matrix(coefs_B), ci(CI_B)), vertical graphregion(color(white)) xticks(1(2)20) xlabel(1(2)20) xtitle("Years since 2000") legend(label(2 "Below 90th ptile") label(4 "Above 90th ptile")) ytitle("Coefficient on year indicator, with log number" "of C-suite positions as dependent variable")
graph export "$export_directory/figs/year_coefplot_90th_emp.png", replace

* no emp control
reg ln_num_positions i.year##i.emp_90 b31.naics_2, cluster(companyid) r
forvalues y=2001/2020 {
	
	local i = `y' - 2000
	lincom `y'.year
	matrix coefs_A[1, `i'] = r(estimate)
	matrix CI_A[1, `i'] = r(lb) \ r(ub)
	
	lincom `y'.year + `y'.year#1.emp_90
	matrix coefs_B[1, `i'] = r(estimate)
	matrix CI_B[1, `i'] = r(lb) \ r(ub)
	
}
coefplot (matrix(coefs_A), ci(CI_A)) (matrix(coefs_B), ci(CI_B)), vertical graphregion(color(white)) xticks(1(2)20) xlabel(1(2)20) xtitle("Years since 2000") legend(label(2 "Below 90th ptile") label(4 "Above 90th ptile")) ytitle("Coefficient on year indicator, with log number" "of C-suite positions as dependent variable")
graph export "$export_directory/figs/year_coefplot_90th.png", replace


 coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Year Indicator") legend(label(2 "Only Information") label(4 "Only Finance/Insur.") label(6 "All Excl. Info & Fin/Insur")) note("Adj R2s: 0`r2_1', 0`r2_2', 0`r2_3'" "F-stats: `f_1', `f_2', `f_3'") ytitle("Coefficient on year indicator, with log number" "of C-suite positions as dependent variable") graphregion(color(white))


* Taxonomy Regressions
eststo clear
eststo: reg ln_num_positions b2.tech_taxonomy2020_i ln_emp i.year if naics_2 != 92, cluster(companyid) r
estadd local year "Y"
eststo: reg has_co b2.tech_taxonomy2020_i ln_emp i.year if naics_2 != 92, cluster(companyid) r
estadd local year "Y"
eststo: reg has_idio b2.tech_taxonomy2020_i ln_emp i.year if naics_2 != 92, cluster(companyid) r
estadd local year "Y"
esttab using "$export_directory/tables/taxonomy.tex", keep(*tech_taxonomy2020_i ln_emp _cons) se s(N r2 r2_a F year, label("N" "R-sq" "Adj R-sq" "F-stat" "Year FE?")) label title("Number of positions on tech taxonomy regressions\label{tab1}") star(* 0.10 ** 0.05 *** 0.01) replace booktabs note("Robust standard errors in parentheses. The dependent variable is the log number of C-Suite positions for each firm in a given year. High, Medium-high, Medium-low, and Low correspond to the sectoral taxonomy of digital intensity as defined in Table 3 of  Calvino et. al (2018). From the paper notes: 'High' identifies sectors in the top quartile of the distribution of the values underpinning the 'global' taxonomy, 'medium-high' the second highest quartile, 'medium-low' the second lowest, and 'low' the bottom quartile. These are treated as industry-level indicators for this regression. The regression also controls for year fixed-effects and log employment.")

* Taxonomy year FE plot
reg ln_num_positions year_* if naics_2 != 92 & tech_taxonomy2020 == " High", cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
reg ln_num_positions year_* if naics_2 != 92 & tech_taxonomy2020 == " Medium-high", cluster(companyid) r
local r2_2 = round(e(r2_a), 0.01)
local f_2 = round(e(F), 1)
estimates store B
reg ln_num_positions year_* if naics_2 != 92 & tech_taxonomy2020 == " Medium-low", cluster(companyid) r
local r2_3 = round(e(r2_a), 0.01)
local f_3 = round(e(F), 1)
estimates store C
reg ln_num_positions year_* if naics_2 != 92 & tech_taxonomy2020 == " Low", cluster(companyid) r
local r2_4 = round(e(r2_a), 0.01)
local f_4 = round(e(F), 1)
estimates store D
coefplot A B C D, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Year Indicator") legend(label(2 "High") label(4 "Medium-high") label(6 "Medium-low") label(8 "Low")) note("Adj R2s: 0`r2_1', 0`r2_2', 0`r2_3', 0`r2_4'" "F-stats: `f_1', `f_2', `f_3', `f_4'") ytitle("Coefficient on year indicator, with log number" "of C-suite positions as dependent variable") graphregion(color(white))
graph export "$export_directory/figs/year_coefplot_taxonomy.png", replace

reg ln_num_positions year_* ln_emp if naics_2 != 92 & tech_taxonomy2020 == " High", cluster(companyid) r
local r2_1 = round(e(r2_a), 0.01)
local f_1 = round(e(F), 1)
estimates store A
reg ln_num_positions year_* ln_emp if naics_2 != 92 & tech_taxonomy2020 == " Medium-high", cluster(companyid) r
local r2_2 = round(e(r2_a), 0.01)
local f_2 = round(e(F), 1)
estimates store B
reg ln_num_positions year_* ln_emp if naics_2 != 92 & tech_taxonomy2020 == " Medium-low", cluster(companyid) r
local r2_3 = round(e(r2_a), 0.01)
local f_3 = round(e(F), 1)
estimates store C
reg ln_num_positions year_* ln_emp if naics_2 != 92 & tech_taxonomy2020 == " Low", cluster(companyid) r
local r2_4 = round(e(r2_a), 0.01)
local f_4 = round(e(F), 1)
estimates store D
coefplot A B C D, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Year Indicator") legend(label(2 "High") label(4 "Medium-high") label(6 "Medium-low") label(8 "Low")) note("Adj R2s: 0`r2_1', 0`r2_2', 0`r2_3', 0`r2_4'" "F-stats: `f_1', `f_2', `f_3', `f_4'") ytitle("Coefficient on year indicator, with log number" "of C-suite positions as dependent variable") graphregion(color(white))
graph export "$export_directory/figs/year_coefplot_taxonomy2.png", replace

*xtreg ln_num_positions ln_emp c.year_2001#c.above_med_emp c.year_2002#c.above_med_emp c.year_2003#c.above_med_emp c.year_2004#c.above_med_emp c.year_2005#c.above_med_emp c.year_2006#c.above_med_emp c.year_2007#c.above_med_emp c.year_2008#c.above_med_emp c.year_2009#c.above_med_emp c.year_2010#c.above_med_emp c.year_2011#c.above_med_emp c.year_2012#c.above_med_emp c.year_2013#c.above_med_emp c.year_2014#c.above_med_emp c.year_2015#c.above_med_emp c.year_2016#c.above_med_emp c.year_2017#c.above_med_emp c.year_2018#c.above_med_emp c.year_2019#c.above_med_emp c.year_2020#c.above_med_emp b31.naics_2, vce(robust)
*coefplot, keep(*year*) vertical coeflabels(c.year_2001#c.above_med_emp = "2001" c.year_2002#c.above_med_emp = " " c.year_2003#c.above_med_emp = "2003" c.year_2004#c.above_med_emp = " " c.year_2005#c.above_med_emp = "2005" c.year_2006#c.above_med_emp = " " c.year_2007#c.above_med_emp = "2007" c.year_2008#c.above_med_emp = " " c.year_2009#c.above_med_emp = "2009" c.year_2010#c.above_med_emp = " " c.year_2011#c.above_med_emp = "2011" c.year_2012#c.above_med_emp = " " c.year_2013#c.above_med_emp = "2013" c.year_2014#c.above_med_emp = " " c.year_2015#c.above_med_emp = "2015" c.year_2016#c.above_med_emp = " " c.year_2017#c.above_med_emp = "2017" c.year_2018#c.above_med_emp = " " c.year_2019#c.above_med_emp = "2019" c.year_2020#c.above_med_emp = " ") xtitle(Interaction of Year and Above Median Employment)
*graph export "$export_directory/figs/year_interaction_coefplot.png"

eststo clear
eststo: xtreg has_idio ln_emp i.year b31.naics_2, vce(robust)
eststo: xtreg has_co ln_emp i.year b31.naics_2, vce(robust)
eststo: xtreg ln_num_positions ln_emp i.year b31.naics_2, vce(robust)

esttab, label se s(N r2_w, label("N" "R-sq")) title(Percent of firms with each C-Suite position (Balanced Sample)\label{tab98})
esttab using "$export_directory/tables/prob_reg_has_idio.tex", se s(N r2_w, label("N" "R-sq")) label title(Determinants of C-Suite Makeup\label{tab1}) star(* 0.10 ** 0.05 *** 0.01) replace booktabs longtable nogaps not compress

eststo clear
eststo: xtreg has_idio ln_emp i.year knowledge_1 knowledge_2, vce(robust)
eststo: xtreg has_co ln_emp i.year knowledge_1 knowledge_2, vce(robust)
eststo: xtreg ln_num_positions ln_emp i.year knowledge_1 knowledge_2, vce(robust)
eststo: xtreg has_idio ln_emp i.year knowledge_1 knowledge_2 bachelors, vce(robust)
eststo: xtreg has_co ln_emp i.year knowledge_1 knowledge_2 bachelors, vce(robust)
eststo: xtreg ln_num_positions ln_emp i.year knowledge_1 knowledge_2 bachelors, vce(robust)
esttab using "$export_directory/tables/prob_reg_knowledge.tex", drop(*year) se s(N r2_w, label("N" "R-sq")) label title(Determinants of C-Suite Makeup\label{tab1}) star(* 0.10 ** 0.05 *** 0.01) replace booktabs nogaps not compress

eststo clear
eststo: xtreg has_idio ln_emp i.year ln_r_d_spending_peremp bachelors i.naics_3_int, vce(cluster naics_4)
estadd local naics_fe "Y"
eststo: xtreg has_co ln_emp i.year ln_r_d_spending_peremp bachelors i.naics_3_int, vce(cluster naics_4)
estadd local naics_fe "Y"
eststo: xtreg ln_num_positions ln_emp i.year ln_r_d_spending_peremp bachelors i.naics_3_int, vce(cluster naics_4)
estadd local naics_fe "Y"
eststo: xtreg has_idio ln_emp i.year share_workers_stem bachelors i.naics_3_int, vce(cluster naics_4)
estadd local naics_fe "Y"
eststo: xtreg has_co ln_emp i.year share_workers_stem bachelors i.naics_3_int, vce(cluster naics_4)
estadd local naics_fe "Y"
eststo: xtreg ln_num_positions ln_emp i.year share_workers_stem bachelors i.naics_3_int, vce(cluster naics_4)
estadd local naics_fe "Y"

esttab using "$export_directory/tables/prob_reg_r_and_d.tex", keep(ln_r_d_spending_peremp share_workers_stem bachelors _cons) order(ln_r_d_spending_peremp share_workers_stem bachelors _cons) se s(N r2_w naics_fe, label("N" "R-sq" "3-Digit NAICS FE?")) label title(Determinants of C-Suite Makeup\label{tab1}) star(* 0.10 ** 0.05 *** 0.01) replace booktabs nogaps not compress addnote("Standard errors in parentheses, clustered by 4-digit NAICS code. R\&D spending and STEM data from Brookings report: 'America's Advanced Industries: What They Are, Where They Are, and Why They Matter' (2015), and are at the 4-digit NAICS level. Share With Bachelor's Degree data aggregated using ACS data, at the year and 3-digit industry level. Data")


eststo clear
eststo: estpost sum ln_r_d_spending_peremp share_workers_stem bachelors, detail
esttab, label cells("count mean(fmt(%9.2f)) sd min p50 max") title("Sum stats of explanatory variables")
esttab using "$export_directory/tables/r_d_sum_stats.tex", label cells("count mean(fmt(%9.2f)) sd min p50 max") title("Sum stats of explanatory variables") replace booktabs




* Bar chart
collapse (rawsum) pos_* num_positions, by( year tech_taxonomy2020 tech_taxonomy2020_i)
drop if tech_taxonomy2020 == ""
reshape long pos_, i( year tech_taxonomy2020 tech_taxonomy2020_i) j(position) string
rename pos_ number
egen tot_pos = sum(number), by( position year )
gen percent = (number / tot_pos) * 100
replace percent = 0 if percent == .
drop tech_taxonomy2020_i num_positions
replace tech_taxonomy2020 = strtrim( tech_taxonomy2020)
replace tech_taxonomy2020 = subinstr(tech_taxonomy2020, "-", "_", .)
reshape wide number percent, i( year position) j( tech_taxonomy2020) string


replace position = "Chief audit executive" if position == "CAE"
replace position = "Chief administration officer" if position == "CAO"
replace position = "Chief compliance officer" if position == "CCO_comp"
replace position = "Chief content officer" if position == "CCO_cont"
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
replace position = "Chief accounting officer" if position == "CAcc"
replace position = "Chief business officer" if position == "CBus"
replace position = "Chief commercial officer" if position == "CComm"
replace position = "Chief medical officer" if position == "CMed"
replace position = "Chief risk officer" if position == "CRisk"
replace position = "Chief scientific officer" if position == "CSci"
replace position = "Chief credit officer" if position == "CCredit"
replace position = "Chief governance officer" if position == "CGov"
replace position = "Chief talent officer" if position == "CTal"
replace position = "Chief counsel / General counsel" if position == "CCounsel"
replace position = "Chief creative officer" if position == "CCreat"
replace position = "Chief strategy officer" if position == "CStrat"
replace position = "Chief legal officer" if position == "CLegal"
replace position = "Chief investment officer" if position == "CInvest"
replace position = "Chief diversity officer" if position == "CDiv"
replace position = "Chief (other)" if position == "Chief"
replace position = "Chairperson/President" if position == "Chair"
replace position = "Chief supply chain officer" if position == "CSupp"
replace position = "Chief development officer" if position == "CDev"
replace position = "Chief tax officer" if position == "CTax"
replace position = "Chief ethics officer" if position == "CEthics"
replace position = "Chief brand officer" if position == "CBrand"
replace position = "Chief procurement officer" if position == "CProcure"
replace position = "Chief innovation officer" if position == "CInnov"
replace position = "Chief digital officer" if position == "CDigit"
replace position = "Chief sales officer" if position == "CSales"
replace position = "Chief customer officer" if position == "CCustom"
replace position = "Chief of staff officer" if position == "CStaff"
replace position = "Chief revenue officer" if position == "CRev"
replace position = "Chief banking officer" if position == "CBank"
replace position = "Chief merchandise officer" if position == "CMerch"
replace position = "Chief communications officer" if position == "CCommunication"

graph hbar (asis) percentHigh percentMedium_high percentMedium_low percentLow if year == 2020 & position != "Chief knowledge officer", over( position, sort(1) label(labsize(2))) stack legend(label(1 "High") label(2 "Medium-high") label(3 "Medium-low") label(4 "Low") title(Digital taxonomy, size(*0.5)) size(*0.5) symxsize(*0.3)) ytitle("Percent of positions in each taxonomy (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(8)
graph export "$export_directory/figs/bar_pos_taxonomy2020.png", replace

graph hbar (asis) percentHigh percentMedium_high percentMedium_low percentLow if year == 2000 & position != "Chief knowledge officer", over( position, sort(1) label(labsize(2))) stack legend(label(1 "High") label(2 "Medium-high") label(3 "Medium-low") label(4 "Low") title(Digital taxonomy, size(*0.5)) size(*0.5) symxsize(*0.3)) ytitle("Percent of positions in each taxonomy (2000)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(8)
graph export "$export_directory/figs/bar_pos_taxonomy2000.png", replace




use "$data_directory/reg_data.dta", clear

replace pos_Chief = 1 if pos_Chief > 0 & pos_Chief != .

bysort companyid: gen num_years = _N
mark balanced if num_years == 21

bysort companyid: gen index = _n

replace emp = emp * 1000
egen max_emp = max(emp), by(companyid)

sum max_emp if index == 1, d

gen emp_bucket_max = .
replace emp_bucket_max = 10 if max_emp < r(p10) & max_emp != .
replace emp_bucket_max = 25 if max_emp >= r(p10) & max_emp < r(p25) & max_emp != .
replace emp_bucket_max = 50 if max_emp >= r(p25) & max_emp < r(p50) & max_emp != .
replace emp_bucket_max = 75 if max_emp >= r(p50) & max_emp < r(p75) & max_emp != .
replace emp_bucket_max = 90 if max_emp >= r(p75) & max_emp < r(p90) & max_emp != .
replace emp_bucket_max = 99 if max_emp >= r(p90) & max_emp < r(p99) & max_emp != .
replace emp_bucket_max = 100 if max_emp >= r(p99) & max_emp != .

mark emp_90 if emp_bucket_max == 99 | emp_bucket_max == 100

foreach pos of varlist pos_* {
	
	local position = substr("`pos'", 5, .)
	display "`position'"
	gen pos90_`position' = `pos' if emp_90 == 1
	*gen `pos'90 = `pos' if emp_90 == 1
	
}

collapse (count) num_firms_all_=companyid (rawsum) num_firms_90_=emp_90 pos_* pos90_* num_positions, by( year naics_2)
drop if naics_2 == .
reshape long pos_ pos90_, i( year naics_2) j(position) string
rename pos_ number_all_
rename pos90_ number_90_

egen tot_pos_all_ = sum(number_all_), by( position year )
gen percent_all_ = (number_all_ / tot_pos_all_) * 100
replace percent_all_ = 0 if percent_all_ == .

egen tot_pos_90_ = sum(number_90_), by( position year )
gen percent_90_ = (number_90_ / tot_pos_90_) * 100
replace percent_90_ = 0 if percent_90_ == .
drop num_positions

reshape wide number_all_ percent_all_ number_90_ percent_90_ num_firms_all_ num_firms_90_, i( year position) j( naics_2)


replace position = "Chief audit executive" if position == "CAE"
replace position = "Chief administration officer" if position == "CAO"
replace position = "Chief compliance officer" if position == "CCO_comp"
replace position = "Chief content officer" if position == "CCO_cont"
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
replace position = "Chief accounting officer" if position == "CAcc"
replace position = "Chief business officer" if position == "CBus"
replace position = "Chief commercial officer" if position == "CComm"
replace position = "Chief medical officer" if position == "CMed"
replace position = "Chief risk officer" if position == "CRisk"
replace position = "Chief scientific officer" if position == "CSci"
replace position = "Chief credit officer" if position == "CCredit"
replace position = "Chief governance officer" if position == "CGov"
replace position = "Chief talent officer" if position == "CTal"
replace position = "Chief counsel / General counsel" if position == "CCounsel"
replace position = "Chief creative officer" if position == "CCreat"
replace position = "Chief strategy officer" if position == "CStrat"
replace position = "Chief legal officer" if position == "CLegal"
replace position = "Chief investment officer" if position == "CInvest"
replace position = "Chief diversity officer" if position == "CDiv"
replace position = "Chief (other)" if position == "Chief"
replace position = "Chairperson/President" if position == "Chair"
replace position = "Chief supply chain officer" if position == "CSupp"
replace position = "Chief development officer" if position == "CDev"
replace position = "Chief tax officer" if position == "CTax"
replace position = "Chief ethics officer" if position == "CEthics"
replace position = "Chief brand officer" if position == "CBrand"
replace position = "Chief procurement officer" if position == "CProcure"
replace position = "Chief innovation officer" if position == "CInnov"
replace position = "Chief digital officer" if position == "CDigit"
replace position = "Chief sales officer" if position == "CSales"
replace position = "Chief customer officer" if position == "CCustom"
replace position = "Chief of staff" if position == "CStaff"
replace position = "Chief revenue officer" if position == "CRev"
replace position = "Chief banking officer" if position == "CBank"
replace position = "Chief merchandise officer" if position == "CMerch"
replace position = "Chief communications officer" if position == "CCommunication"

egen percentOther = rowtotal(percent_all_*)
replace percentOther = percentOther-percent_all_51-percent_all_52-percent_all_53-percent_all_22-percent_all_61-percent_all_54
gen percentIncluded = percent_all_51+percent_all_52+percent_all_53+percent_all_22+percent_all_61+percent_all_54

egen total= group(percentIncluded position)
labmask total, val(position)

graph hbar (asis) percent_all_51 percent_all_52 percent_all_53 percent_all_22 percent_all_61 percent_all_54 if year == 2020 & position != "Chief knowledge officer", over( total, label(labsize(2))) stack legend(label(1 "Information") label(2 "Finance and Insurance") label(3 "Real Estate and" "Rental and Leasing") label(4 "Utilities") label(5 "Educational Services") label(6 "Professional, Scientific," "and Technical Services") title(Industry, size(*0.5)) size(*0.5) symxsize(*0.3)) ytitle("Percent of positions in each industry (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(8.5)
graph export "$export_directory/figs/bar_pos_ind2020.png", replace

graph hbar (asis) percent_all_51 percent_all_52 percent_all_53 percent_all_22 percent_all_61 percent_all_54 if year == 2000 & position != "Chief knowledge officer", over( total, label(labsize(2))) stack legend(label(1 "Information") label(2 "Finance and Insurance") label(3 "Real Estate and" "Rental and Leasing") label(4 "Utilities") label(5 "Educational Services") label(6 "Professional, Scientific," "and Technical Services") title(Industry, size(*0.5)) size(*0.5) symxsize(*0.3)) ytitle("Percent of positions in each industry (2000)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(8.5)
graph export "$export_directory/figs/bar_pos_ind2000.png", replace


gen p_with_pos = ((number_all_51+number_all_52+number_all_53+number_all_22+number_all_61+number_all_54) / (num_firms_all_51+num_firms_all_52+num_firms_all_53+num_firms_all_22+num_firms_all_61+num_firms_all_54)) * 100

gen p_with_pos2 = ((number_all_51+number_all_52) / (num_firms_all_51+num_firms_all_52)) * 100

gen p_with_pos51 = ((number_all_51) / (num_firms_all_51)) * 100
gen p_with_pos52 = ((number_all_52) / (num_firms_all_52)) * 100

encode position, gen( position1)
xtset position1 year

gen c_p_with_pos51 = p_with_pos51 - L20.p_with_pos51
gen c_p_with_pos52 = p_with_pos52 - L20.p_with_pos52

egen tot_num = rowtotal(number_all_*)
egen tot_firms = rowtotal(num_firms_all_*)

gen p_with_pos_all = (tot_num / tot_firms) * 100
gen c_p_with_pos_all = p_with_pos_all - L20.p_with_pos_all

* 90th ptile
gen p_with_pos9051 = ((number_90_51) / (num_firms_90_51)) * 100
gen p_with_pos9052 = ((number_90_52) / (num_firms_90_52)) * 100

gen c_p_with_pos9051 = p_with_pos9051 - L20.p_with_pos9051
gen c_p_with_pos9052 = p_with_pos9052 - L20.p_with_pos9052

egen tot_num90 = rowtotal(number_90*)
egen tot_firms90 = rowtotal(num_firms_90*)

gen p_with_pos_90 = (tot_num90 / tot_firms90) * 100
gen c_p_with_pos_90 = p_with_pos_90 - L20.p_with_pos_90

gen p_with_pos_rest = ((tot_num - tot_num90) / (tot_firms - tot_firms90)) * 100
gen c_p_with_pos_rest = p_with_pos_rest - L20.p_with_pos_rest

graph hbar (asis) p_with_pos_all p_with_pos if year==2020 & position != "Chief knowledge officer", over(position, sort(2) label(labsize(2))) legend(label(1 "All firms") label(2 "Top Industries")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(8.5) bar(1, fcolor(black)) bar(2, fcolor(lime))
graph export "$export_directory/figs/bar_p_pos_ind2020.png", replace width(5000)

graph hbar (asis) p_with_pos_all p_with_pos51 p_with_pos52 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange)) ysize(12)
graph export "$export_directory/figs/bar_p_pos_51522020.png", replace width(5000)

graph hbar (asis) p_with_pos_all p_with_pos51 p_with_pos52 if year==2000 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))
graph export "$export_directory/figs/bar_p_pos_51522000.png", replace width(5000)

graph hbar (asis) c_p_with_pos_all c_p_with_pos51 c_p_with_pos52 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))
graph export "$export_directory/figs/bar_c_p_pos_51522020.png", replace width(5000)


* 90th ptile
graph hbar (asis) p_with_pos_90 p_with_pos9051 p_with_pos9052 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))


graph hbar (asis) p_with_pos_90 p_with_pos9051 p_with_pos9052 if year==2000 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))

graph hbar (asis) c_p_with_pos_90 c_p_with_pos9051 c_p_with_pos9052 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))

graph hbar (asis) p_with_pos_rest p_with_pos_90 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "Below 90th ptile") label(2 "90th ptile of employment") size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))
graph export "$export_directory/figs/bar_p_pos_90_2020.png", replace width(5000)

graph hbar (asis) p_with_pos_rest p_with_pos_90 if year==2000 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "Below 90th ptile") label(2 "90th ptile of employment") size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2000)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))
graph export "$export_directory/figs/bar_p_pos_90_2000.png", replace width(5000)

graph hbar (asis) c_p_with_pos_rest c_p_with_pos_90 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "Below 90th ptile") label(2 "90th ptile of employment") size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))
graph export "$export_directory/figs/bar_c_p_pos_90_2020.png", replace width(5000)

graph hbar (asis) c_p_with_pos51 c_p_with_pos9051 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All Information") label(2 "90th ptile Information") size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))

graph hbar (asis) c_p_with_pos52 c_p_with_pos9052 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All Fin/Insur.") label(2 "90th ptile Fin/Insur.") size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))


*graph hbar (asis) p_with_pos if (year == 2000 | year==2020) & position != "Chief knowledge officer", over(year) over( position, sort(2) label(labsize(2))) legend(label(1 "2000") label(2 "2020") title(Year, size(*0.5)) size(*0.5) symxsize(*0.3)) ytitle("Percent of positions in each industry (2000)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(8.5) asyvars


sector 11 "Agriculture, Forestry, Fishing and Hunting" 21 "Mining, Quarrying, and Oil and Gas Extraction" 22 "Utilities" 23 "Construction" 31 "Manufacturing" 42 "Wholesale Trade" 44 "Retail Trade" 48 "Transportation and Warehousing" 51 "Information" 52 "Finance and Insurance" 53 "Real Estate and Rental and Leasing" 54 "Professional, Scientific, and Technical Services" 55 "Management of Companies and Enterprises" 56 "ASWMRS" 61 "Educational Services" 62 "Health Care and Social Assistance" 71 "Arts, Entertainment, and Recreation" 72 "Accommodation and Food Services" 81 "Other Services (except Public Administration)" 92 "Public Administration" 99 "Missing"


****

use "$data_directory/reg_data.dta", clear

replace pos_Chief = 1 if pos_Chief > 0 & pos_Chief != .

bysort companyid: gen num_years = _N
mark balanced if num_years == 21

bysort companyid: gen index = _n

replace emp = emp * 1000
egen max_emp = max(emp), by(companyid)

sum max_emp if index == 1, d

gen emp_bucket_max = .
replace emp_bucket_max = 10 if max_emp < r(p10) & max_emp != .
replace emp_bucket_max = 25 if max_emp >= r(p10) & max_emp < r(p25) & max_emp != .
replace emp_bucket_max = 50 if max_emp >= r(p25) & max_emp < r(p50) & max_emp != .
replace emp_bucket_max = 75 if max_emp >= r(p50) & max_emp < r(p75) & max_emp != .
replace emp_bucket_max = 90 if max_emp >= r(p75) & max_emp < r(p90) & max_emp != .
replace emp_bucket_max = 99 if max_emp >= r(p90) & max_emp < r(p99) & max_emp != .
replace emp_bucket_max = 100 if max_emp >= r(p99) & max_emp != .

mark emp_90 if emp_bucket_max == 99 | emp_bucket_max == 100

foreach pos of varlist pos_* {
	
	local position = substr("`pos'", 5, .)
	display "`position'"
	gen pos90_`position' = `pos' if emp_90 == 1
	*gen `pos'90 = `pos' if emp_90 == 1
	
}

keep if balanced == 1

collapse (count) num_firms_all_=companyid (rawsum) num_firms_90_=emp_90 pos_* pos90_* num_positions, by( year)
reshape long pos_ pos90_, i( year) j(position) string
rename pos_ number_all_
rename pos90_ number_90_

collapse (sum) num_firms_all_ num_firms_90_ number_all_ number_90_, by( year position)

gen p_all = (number_all_ / num_firms_all_) * 100
gen p_90 = (number_90_ / num_firms_90_) * 100
gen p_rest = ((number_all_-number_90_) / (num_firms_all_-num_firms_90_)) * 100


scatter p_90 year if position == "Chief", connect(L) || scatter p_rest year if position == "Chief", connect(L)

encode position, gen(position1)
xtset position1 year

gen c_num = number_all_ - L1.number_all_
egen max_change = max(c_num), by(year)
keep if max_change == c_num
sort year

gen c_num = number_90_ - L1.number_90_
egen max_change = max(c_num), by(year)
keep if max_change == c_num
sort year

use "$data_directory/reg_data.dta", clear

replace pos_Chief = 1 if pos_Chief > 0 & pos_Chief != .

bysort companyid: gen num_years = _N
mark balanced if num_years == 21

bysort companyid: gen index = _n

replace emp = emp * 1000
egen max_emp = max(emp), by(companyid)

sum max_emp if index == 1, d

gen emp_bucket_max = .
replace emp_bucket_max = 10 if max_emp < r(p10) & max_emp != .
replace emp_bucket_max = 25 if max_emp >= r(p10) & max_emp < r(p25) & max_emp != .
replace emp_bucket_max = 50 if max_emp >= r(p25) & max_emp < r(p50) & max_emp != .
replace emp_bucket_max = 75 if max_emp >= r(p50) & max_emp < r(p75) & max_emp != .
replace emp_bucket_max = 90 if max_emp >= r(p75) & max_emp < r(p90) & max_emp != .
replace emp_bucket_max = 99 if max_emp >= r(p90) & max_emp < r(p99) & max_emp != .
replace emp_bucket_max = 100 if max_emp >= r(p99) & max_emp != .

mark emp_90 if emp_bucket_max == 99 | emp_bucket_max == 100

gen has_co_90 = has_co if emp_90 == 1
gen has_co_rest = has_co if emp_90 == 0 & emp_bucket_max != .

keep if balanced == 1

collapse (mean) has_co_90 has_co_rest, by(year)

scatter has_co_90 year, connect(L) || scatter has_co_rest year, connect(L)






use "$data_directory/reg_data.dta", clear
replace pos_Chief = 1 if pos_Chief > 0 & pos_Chief != .

bysort companyid: gen num_years = _N
mark balanced if num_years == 21

bysort companyid: gen index = _n

replace emp = emp * 1000
egen max_emp = max(emp), by(companyid)

sum max_emp if index == 1, d

gen emp_bucket_max = .
replace emp_bucket_max = 10 if max_emp < r(p10) & max_emp != .
replace emp_bucket_max = 25 if max_emp >= r(p10) & max_emp < r(p25) & max_emp != .
replace emp_bucket_max = 50 if max_emp >= r(p25) & max_emp < r(p50) & max_emp != .
replace emp_bucket_max = 75 if max_emp >= r(p50) & max_emp < r(p75) & max_emp != .
replace emp_bucket_max = 90 if max_emp >= r(p75) & max_emp < r(p90) & max_emp != .
replace emp_bucket_max = 99 if max_emp >= r(p90) & max_emp < r(p99) & max_emp != .
replace emp_bucket_max = 100 if max_emp >= r(p99) & max_emp != .

mark emp_90 if emp_bucket_max == 99 | emp_bucket_max == 100

foreach pos of varlist pos_* {
	
	local position = substr("`pos'", 5, .)
	display "`position'"
	gen pos90_`position' = `pos' if emp_90 == 1
	*gen `pos'90 = `pos' if emp_90 == 1
	
}

keep if balanced == 1

gen c_coo = pos_COO - L20.pos_COO

gen change_coo = ""
replace change_coo = "lost" if c_coo == -1
replace change_coo = "unchanged" if c_coo == 0
replace change_coo = "gained" if c_coo == 1


pos_CAcc pos_CComm pos_CCO_comp pos_CCO_cont pos_CCredit pos_CDiv pos_CEthics pos_CHRO pos_CIO pos_CMed pos_CProcure pos_CSci pos_CStrat

binscatter pos_CComm c_coo if emp_bucket_max == 99 | emp_bucket_max == 100

keep if balanced == 1
keep if year == 2020
collapse (count) num_firms_all_=companyid (rawsum) num_firms_90_=emp_90 pos_* pos90_* num_positions, by( change_coo)
drop if change_coo == ""
reshape long pos_ pos90_, i( change_coo) j(position) string
rename pos_ number_all_
rename pos90_ number_90_

egen tot_pos_all_ = sum(number_all_), by( position )
gen percent_all_ = (number_all_ / tot_pos_all_) * 100
replace percent_all_ = 0 if percent_all_ == .

egen tot_pos_90_ = sum(number_90_), by( position )
gen percent_90_ = (number_90_ / tot_pos_90_) * 100
replace percent_90_ = 0 if percent_90_ == .
drop num_positions

reshape wide number_all_ percent_all_ number_90_ percent_90_ num_firms_all_ num_firms_90_, i( position) j( change_coo) string


egen tot_num = rowtotal(number_all_*)
egen tot_firms = rowtotal(num_firms_all_*)

foreach type in lost unchanged gained {
	gen p_with_pos_`type' = (number_all_`type' / num_firms_all_`type') * 100
}

graph hbar (asis) p_with_pos_unchanged p_with_pos_lost p_with_pos_gained if position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "Unchanged") label(2 "Lost COO") label(3 "Gained COO")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))





sort companyid year
gen c_ln_num_positions = ln_num_positions - L1.ln_num_positions
gen c20_ln_num_positions = ln_num_positions - L20.ln_num_positions
gen c_num_positions = num_positions - L1.num_positions
gen c20_num_positions = num_positions - L20.num_positions


binscatter ln_num_positions rd_emp, absorb(naics_2) control(i.year ln_emp) xtitle("R&D expenses per employee (millions $)") ytitle("Log number of C-Suite positions")
graph export "$export_directory/figs/rd_ln_binscatter.png", replace

binscatter c_ln_num_positions rd_emp, absorb(naics_2) control(i.year ln_emp) xtitle("R&D Expenses per employee (millions $)") ytitle("Annual change in log number of C-Suite positions")
graph export "$export_directory/figs/rd_c_binscatter.png", replace

binscatter c20_ln_num_positions rd_emp, absorb(naics_2) control(ln_emp) xtitle("R&D expenses per employee (millions $)") ytitle("20-year change in log number of C-Suite positions")
graph export "$export_directory/figs/rd_c20_binscatter.png", replace

zscore rd_emp ln_emp

label var ln_num_positions "Log(Num positions)"
label var c_ln_num_positions "Annual Change"
label var c20_ln_num_positions "20-y Change"

label var z_rd_emp "R\&D per emp (z-score)"
label var z_ln_emp "Log emp (z-score)"

eststo clear
eststo: reghdfe ln_num_positions z_rd_emp z_ln_emp , absorb(naics_2 year) cluster(companyid)
estadd local naics "Y"
estadd local year "Y"
eststo: reghdfe c_ln_num_positions z_rd_emp z_ln_emp , absorb(naics_2 year) cluster(companyid)
estadd local naics "Y"
estadd local year "Y"
eststo: reghdfe c20_ln_num_positions z_rd_emp z_ln_emp , absorb(naics_2) cluster(companyid)
estadd local naics "Y"
estadd local year "N"
esttab using "$export_directory/tables/company_level_rd.tex", se s(N r2 naics year, label("N" "R-sq" "2-Digit NAICS FE?" "Year FE?")) label title("Impact of R\&D spending on board size\label{tab1}") star(* 0.10 ** 0.05 *** 0.01) replace booktabs nogaps not compress addnote("Standard errors in parentheses, clustered by company. The dependent variable in Column (1) represents the log number of C-Suite positions by company/year. Column (2) measures the annual change in board size, while Column (3) measures the 20-year change. In Column (3), the dependent and independent variables are from 2020, while in the other columns they vary by year. Yearly R\&D spending and employment data from Compustat. Each column also contains 2-digit industry and yearly fixed-effects, except Column (3), which only contains industry FE.")

use "$data_directory/reg_data.dta", clear

replace pos_Chief = 1 if pos_Chief > 0 & pos_Chief != .

bysort companyid: gen num_years = _N
mark balanced if num_years == 21

bysort companyid: gen index = _n

replace emp = emp * 1000
egen max_emp = max(emp), by(companyid)

sum max_emp if index == 1, d

gen emp_bucket_max = .
replace emp_bucket_max = 10 if max_emp < r(p10) & max_emp != .
replace emp_bucket_max = 25 if max_emp >= r(p10) & max_emp < r(p25) & max_emp != .
replace emp_bucket_max = 50 if max_emp >= r(p25) & max_emp < r(p50) & max_emp != .
replace emp_bucket_max = 75 if max_emp >= r(p50) & max_emp < r(p75) & max_emp != .
replace emp_bucket_max = 90 if max_emp >= r(p75) & max_emp < r(p90) & max_emp != .
replace emp_bucket_max = 99 if max_emp >= r(p90) & max_emp < r(p99) & max_emp != .
replace emp_bucket_max = 100 if max_emp >= r(p99) & max_emp != .

mark emp_90 if emp_bucket_max == 99 | emp_bucket_max == 100

keep if balanced == 1


collapse (mean) pos_*, by(year emp_90)

scatter pos_CTO year if emp_90 == 1, connect(L) || scatter pos_CTO year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with CTO")
graph export "$export_directory/figs/pos_CTO_time_emp.png"

scatter pos_CDiv year if emp_90 == 1, connect(L) || scatter pos_CDiv year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with Chief Diversity Officer")
graph export "$export_directory/figs/pos_CDiv_time_emp.png"

scatter pos_CDO year if emp_90 == 1, connect(L) || scatter pos_CDO year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with Chief Data Officer")
graph export "$export_directory/figs/pos_CDO_time_emp.png"

scatter pos_CDigit year if emp_90 == 1, connect(L) || scatter pos_CDigit year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with Chief Digital Officer")
graph export "$export_directory/figs/pos_CDigit_time_emp.png"

scatter pos_CFO year if emp_90 == 1, connect(L) || scatter pos_CFO year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with CFO")
graph export "$export_directory/figs/pos_CFO_time_emp.png"

scatter pos_COO year if emp_90 == 1, connect(L) || scatter pos_COO year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with COO")
graph export "$export_directory/figs/pos_COO_time_emp.png"



scatter pos_OtherFin year if emp_90 == 1, connect(L) || scatter pos_OtherFin year if emp_90 == 0, connect(L)
scatter pos_OtherBus year if emp_90 == 1, connect(L) || scatter pos_OtherBus year if emp_90 == 0, connect(L)
scatter pos_OtherSTEM year if emp_90 == 1, connect(L) || scatter pos_OtherSTEM year if emp_90 == 0, connect(L)

scatter pos_CFO year, connect(L)
scatter pos_CDO year, connect(L)





use "$data_directory/reg_data.dta", clear

replace pos_Chief = 1 if pos_Chief > 0 & pos_Chief != .

bysort companyid: gen num_years = _N
mark balanced if num_years == 21
keep if balanced == 1

collapse (mean) pos_*, by(year naics_2)

xtset naics_2 year

foreach pos in CDigit CTO CDO CDiv CEthics CHRO CMO {
	
	gen c_`pos' = pos_`pos' - L20.pos_`pos'
	
}

foreach pos in CDigit CTO CDO CDiv CEthics CHRO CMO {

	eststo: estpost tabstat c_`pos', by(naics_2) stats(mean) nototal
	
}

esttab, not noobs nostar nonumber nomtitle cell(mean) collabels(none) mlabels("Digital" "Data" "Technology" "Diversity" "Ethics" "HR" "Marketing") title(Change in share of firms with each position (2000-2020)) varlabels(`e(labels)') label
esttab using "$export_directory/tables/change_positions_compu_bal.tex", not noobs nostar nonumber nomtitle cell(mean(fmt (%2.1f))) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position (BALANCED)\label{tab98}) replace booktabs addnote("\textbf{Other (Admin):} Chief Administration Officer, Chief Governance Officer, Chief Diversity Officer, Chief Talent Officer, Chief of Staff; /textbf{Other (Finance):} Chief Audit Executive, Chief Credit Officer, Chief Investment Officer, Chief Revenue Officer, Chief Banking Officer, Chief Tax Officer; \textbf{Other (Business/Marketing):} Chief commercial officer, Chief content office, Chief Creative Officer, Chief Product Officer, Chief Strategy Officer, Chief Customer Officer, Chief Communication Officer, Chief Merchandise Officer, Chief Sales Officer, Chief Development Officer, Chief Brand Officer; \textbf{Other (STEM-Related): } Chief Data Officer, Chief Knowledge Officer, Chief Scientific Officer, Chief Sustainability Officer, Chief Digital Officer, Chief Innovation Officer; \textbf{Other (Operations): } Chief Procurement Officer, Chief Supply Chain Officer, Chief Risk Officer, Chief Security Officer, Chief Ethics Officer")


scatter pos_CDO year if naics_2 == 51, connect(L) || scatter pos_CDO year if naics_2 == 52, connect(L) || scatter pos_CDO year if naics_2 == 53, connect(L) || scatter pos_CDO year if naics_2 == 22, connect(L)

scatter pos_CHRO year if naics_2 == 51, connect(L) || scatter pos_CHRO year if naics_2 == 52, connect(L) || scatter pos_CHRO year if naics_2 == 53, connect(L) || scatter pos_CHRO year if naics_2 == 22, connect(L)


scatter pos_CDigit year if naics_2 == 51, connect(L) || scatter pos_CDigit year if naics_2 == 52, connect(L) || scatter pos_CDigit year if naics_2 == 53, connect(L) || scatter pos_CDigit year if naics_2 == 22, connect(L)

scatter pos_CDigit year if naics_2 == 51, connect(L) || scatter pos_CDigit year if naics_2 == 72, connect(L) || scatter pos_CDigit year if naics_2 == 56, connect(L) || scatter pos_CDigit year if naics_2 == 44, connect(L)


sector 11 "Agriculture, Forestry, Fishing and Hunting" 21 "Mining, Quarrying, and Oil and Gas Extraction" 22 "Utilities" 23 "Construction" 31 "Manufacturing" 42 "Wholesale Trade" 44 "Retail Trade" 48 "Transportation and Warehousing" 51 "Information" 52 "Finance and Insurance" 53 "Real Estate and Rental and Leasing" 54 "Professional, Scientific, and Technical Services" 55 "Management of Companies and Enterprises" 56 "ASWMRS" 61 "Educational Services" 62 "Health Care and Social Assistance" 71 "Arts, Entertainment, and Recreation" 72 "Accommodation and Food Services" 81 "Other Services (except Public Administration)" 92 "Public Administration" 99 "Missing"



*** Correlation of COO change and additon of other positions
use "$data_directory/reg_data.dta", clear


bysort companyid: gen index = _n

replace emp = emp * 1000
egen max_emp = max(emp), by(companyid)

sum max_emp if index == 1, d

gen emp_bucket_max = .
replace emp_bucket_max = 10 if max_emp < r(p10) & max_emp != .
replace emp_bucket_max = 25 if max_emp >= r(p10) & max_emp < r(p25) & max_emp != .
replace emp_bucket_max = 50 if max_emp >= r(p25) & max_emp < r(p50) & max_emp != .
replace emp_bucket_max = 75 if max_emp >= r(p50) & max_emp < r(p75) & max_emp != .
replace emp_bucket_max = 90 if max_emp >= r(p75) & max_emp < r(p90) & max_emp != .
replace emp_bucket_max = 99 if max_emp >= r(p90) & max_emp < r(p99) & max_emp != .
replace emp_bucket_max = 100 if max_emp >= r(p99) & max_emp != .

mark emp_90 if emp_bucket_max == 99 | emp_bucket_max == 100

label var pos_CAE "Chief audit executive"
label var pos_CAO "Chief administration officer"
label var pos_CCO_comp "Chief compliance officer"
label var pos_CCO_cont "Chief content officer"
label var pos_CDO "Chief data officer"
label var pos_CEO "Chief executive officer"
label var pos_CFO "Chief financial officer"
label var pos_CHRO "Chief human resources officer"
label var pos_CIO "Chief information officer"
label var pos_CKO "Chief knowledge officer"
label var pos_CMO "Chief marketing officer"
label var pos_COO "Chief operating officer"
label var pos_CPO "Chief product officer"
label var pos_CSO_sec "Chief security officer"
label var pos_CSO_sus "Chief sustainability officer"
label var pos_CTO "Chief technology officer"
label var pos_CAcc "Chief accounting officer"
label var pos_CBus "Chief business officer"
label var pos_CComm "Chief commercial officer"
label var pos_CMed "Chief medical officer"
label var pos_CRisk "Chief risk officer"
label var pos_CSci "Chief scientific officer"
label var pos_CCredit "Chief credit officer"
label var pos_CGov "Chief governance officer"
label var pos_CTal "Chief talent officer"
label var pos_CCounsel "Chief counsel / General counsel"
label var pos_CCreat "Chief creative officer"
label var pos_CStrat "Chief strategy officer"
label var pos_CLegal "Chief legal officer"
label var pos_CInvest "Chief investment officer"
label var pos_CDiv "Chief diversity officer"
label var pos_Chief "Chief (other)"
label var pos_Chair "Chairperson/President"
label var pos_CSupp "Chief supply chain officer"
label var pos_CDev"Chief development officer"
label var pos_CTax "Chief tax officer"
label var pos_CEthics "Chief ethics officer"
label var pos_CBrand "Chief brand officer"
label var pos_CProcure "Chief procurement officer"
label var pos_CInnov "Chief innovation officer"
label var pos_CDigit "Chief digital officer"
label var pos_CSales "Chief sales officer"
label var pos_CCustom "Chief customer officer"
label var pos_CStaff "Chief of staff"
label var pos_CRev "Chief revenue officer"
label var pos_CBank "Chief banking officer"
label var pos_CMerch "Chief merchandise officer"
label var pos_CCommunication "Chief communications officer"

egen pos_OtherAdmin = rowmax(pos_CAO pos_CGov pos_CDiv pos_CTal pos_CStaff)
egen pos_OtherFin = rowmax(pos_CAE pos_CCredit pos_CInvest pos_CRev pos_CBank pos_CTax)
egen pos_OtherBus = rowmax(pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand)
egen pos_OtherSTEM = rowmax(pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CDigit pos_CInnov)
egen pos_OtherOper = rowmax(pos_CRisk pos_CSO_sec pos_CEthics pos_CProcure pos_CSupp)

label var pos_OtherAdmin "Other (Admin)"
label var pos_OtherFin "Other (Financial)"
label var pos_OtherBus "Other (Business/Marketing)"
label var pos_OtherSTEM "Other (STEM-Related)"
label var pos_OtherOper "Other (Operations)"


sort companyid year
foreach pos of varlist pos_* {
	
	gen c_`pos' = `pos' - L20.`pos'
	label var c_`pos' "`: var label `pos''"
	
}

foreach pos of varlist pos_* {

	pwcorr c_`pos' c_pos_COO, sig

}

eststo clear
eststo: reg c_pos_COO c_pos_Chair c_pos_CAcc c_pos_CAO c_pos_CAE c_pos_CBank c_pos_CBrand c_pos_CBus c_pos_CComm c_pos_CCommunication c_pos_CCO_comp c_pos_CCO_cont c_pos_CCounsel c_pos_CCreat c_pos_CCredit c_pos_CCustom c_pos_CDev c_pos_CDigit c_pos_CDO c_pos_CDiv c_pos_CEO c_pos_CEthics c_pos_CFO c_pos_CGov c_pos_CHRO c_pos_CInnov c_pos_CIO c_pos_CInvest c_pos_CKO c_pos_CLegal c_pos_CMO c_pos_CMed c_pos_CMerch c_pos_CPO c_pos_CProcure c_pos_CRev c_pos_CRisk c_pos_CSales c_pos_CSci c_pos_CSO_sec c_pos_CStaff c_pos_CStrat c_pos_CSO_sus c_pos_CSupp c_pos_CTal c_pos_CTax c_pos_CTO, r
esttab using "$export_directory/tables/COO_regs_all.tex", se label star(* 0.10 ** 0.05 *** 0.01) title("Reg of change in COO positions on change in other positions (2000-2020)") booktabs replace

eststo clear
eststo: reg c_pos_COO pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO, r
esttab using "$export_directory/tables/COO_regs_all_pos.tex", se label star(* 0.10 ** 0.05 *** 0.01) title("Reg of change in COO positions on indicatros for other positions (2000-2020)") booktabs replace


eststo clear
eststo: reg c_pos_COO c_pos_Chair c_pos_CEO c_pos_CFO c_pos_CAcc c_pos_CHRO c_pos_CIO c_pos_CTO c_pos_CCO_comp c_pos_CMO c_pos_CLegal c_pos_CBus c_pos_CMed c_pos_CCounsel c_pos_OtherAdmin c_pos_OtherFin c_pos_OtherBus c_pos_OtherSTEM c_pos_OtherOper, r
esttab using "$export_directory/tables/COO_regs_all_funct.tex", se label star(* 0.10 ** 0.05 *** 0.01) title("Reg of change in COO positions on change in other positions (2000-2020)") booktabs replace
