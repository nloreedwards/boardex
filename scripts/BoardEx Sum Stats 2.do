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

collapse (rawsum) pos* co (mean) revt emp at, by(year companyid)
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

mark has_co if co > 0
mark has_Chief if pos_Chief > 0

gen has_co_bal = has_co if balanced == 1
gen has_Chief_bal = has_Chief if balanced == 1

gen num_positions_bal = num_positions if balanced == 1

egen num_positions_nonidio = rowtotal($positions)

gen num_positions_bal_nonidio = num_positions_nonidio if balanced == 1

collapse num_positions has_co has_Chief num_positions_bal num_positions_nonidio num_positions_bal_nonidio has_co_bal has_Chief_bal, by(year)

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

replace has_co = has_co * 100
tsline has_co, ytitle("Percent of Companies with at least 1 'Co-' Position") xtitle("Year")
graph export "$export_directory/figs/has_co_over_time_compu.png", replace

replace has_co_bal = has_co_bal * 100
tsline has_co_bal, ytitle("Percent of Companies with at least 1 'Co-' Position") xtitle("Year")
graph export "$export_directory/figs/has_co_over_time_compu_bal.png", replace

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

estpost corr pos_COO pos_CHRO pos_CMO pos_CBus pos_OtherOper pos_OtherBus pos_OtherAdmin pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_3.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of operational positions")

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

esttab, not noobs nostar nonumber nomtitle cell(Mean(fmt (%2.1f))) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") title(Percent of firms with each position) varlabels(`e(labels)') label
esttab using "$export_directory/tables/change_positions_compu.tex", not noobs nostar nonumber nomtitle cell(Mean(fmt (%2.1f))) collabels(none) mlabels("Percent of firms (2000)" "Percent of firms (2020)" "Change (2000-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position\label{tab98}) replace booktabs addnote("\textbf{Other (Admin):} Chief Administration Officer, Chief Governance Officer, Chief Diversity Officer, Chief Talent Officer, Chief of Staff; /textbf{Other (Finance):} Chief Audit Executive, Chief Credit Officer, Chief Investment Officer, Chief Revenue Officer, Chief Banking Officer, Chief Tax Officer; \textbf{Other (Business/Marketing):} Chief commercial officer, Chief content office, Chief Creative Officer, Chief Product Officer, Chief Strategy Officer, Chief Customer Officer, Chief Communication Officer, Chief Merchandise Officer, Chief Sales Officer, Chief Development Officer, Chief Brand Officer; \textbf{Other (STEM-Related): } Chief Data Officer, Chief Knowledge Officer, Chief Scientific Officer, Chief Sustainability Officer, Chief Digital Officer, Chief Innovation Officer; \textbf{Other (Operations): } Chief Procurement Officer, Chief Supply Chain Officer, Chief Risk Officer, Chief Security Officer, Chief Ethics Officer")

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

* Linear probability model
use "$data_directory/c_suite_data2_merged", clear

duplicates drop RoleName companyid year, force
keep if compustat == 1

mark co if strpos(RoleName, "Co-")

collapse (rawsum) pos* co (mean) revt emp at, by(year companyid naics sic)

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

label define sector 11 "Agriculture, Forestry, Fishing and Hunting" 21 "Mining, Quarrying, and Oil and Gas Extraction" 22 "Utilities" 23 "Construction" 31 "Manufacturing" 42 "Wholesale Trade" 44 "Retail Trade" 48 "Transportation and Warehousing" 51 "Information" 52 "Finance and Insurance" 53 "Real Estate and Rental and Leasing" 54 "Professional, Scientific, and Technical Services" 55 "Management of Companies and Enterprises" 56 "Administrative and Support and Waste Management and Remediation Services" 61 "Educational Services" 62 "Health Care and Social Assistance" 71 "Arts, Entertainment, and Recreation" 72 "Accommodation and Food Services" 81 "Other Services (except Public Administration)" 92 "Public Administration" 99 "Missing"

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

gen ln_r_d_spending_peremp = ln(r_d_spending_peremp)

label var knowledge_1 "Knowledge Intensive (Tier I)"
label var knowledge_2 "Knowledge Intensive (Tier II)"
label var bachelors "Share With Bachelor's \\ Degree (Industry-Level)"
label var r_d_spending_peremp "Domestic R\&D Spending Per Worker (2009)" 
label var share_workers_stem "Share of Industry Workers \\ in STEM Occupations (2012)"
label var ln_r_d_spending_peremp "Log Domestic R\&D \\ Spending Per Worker (2009)" 

bysort companyid: gen company_index = _n

sum emp if company_index == 1, detail
mark above_med_emp if emp > `r(p50)'


label values naics_2 sector

xtset companyid year

forvalues y=2000/2020 {
	
	mark year_`y' if year == `y'
	if `y' == 2001 | `y' == 2003 | `y' == 2005 | `y' == 2007 | `y' == 2009 | `y' == 2011 | `y' == 2013 | `y' == 2015 | `y' == 2017 | `y' == 2019 {
	label var year_`y' "`y'"
	}
}

drop year_2000

xtreg ln_num_positions ln_emp year_* b31.naics_2 if above_med_emp == 1, vce(robust)
estimates store A
xtreg ln_num_positions ln_emp year_* b31.naics_2 if above_med_emp == 0, vce(robust)
estimates store B
coefplot A B, keep(year_*) vertical coeflabels(year_2002 = " " year_2004 = " " year_2006 = " " year_2008 = " " year_2010 = " " year_2012 = " " year_2014 = " " year_2016 = " " year_2018 = " " year_2020 = " ") xtitle("Coefficient on Year Dummies") legend(label(2 "Above median emp") label(4 "Below median emp"))
graph export "$export_directory/figs/year_coefplot.png", replace

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
