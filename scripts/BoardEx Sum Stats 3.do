global data_directory "/export/home/dor/nloreedwards/Documents/BoardEx/data/"
global working_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex"
global export_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex/output"

cd "$working_directory"

global positions "pos_Chair pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_COO pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO"

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

egen pos_OtherAdmin = rowmax(pos_CAO pos_CGov pos_CDiv pos_CTal pos_CStaff)
egen pos_OtherFin = rowmax(pos_CAE pos_CCredit pos_CInvest pos_CRev pos_CBank pos_CTax)
egen pos_OtherBus = rowmax(pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand)
egen pos_OtherSTEM = rowmax(pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CDigit pos_CInnov)
egen pos_OtherOper = rowmax(pos_CRisk pos_CSO_sec pos_CEthics pos_CProcure pos_CSupp)

drop pos_CRisk pos_CSO_sec pos_CAO pos_CGov pos_CDiv pos_CTal pos_CAE pos_CCredit pos_CInvest pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CEthics pos_CStaff pos_CRev pos_CBank pos_CTax pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand pos_CDigit pos_CInnov pos_CProcure pos_CSupp

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

replace position = "Other (Risk)" if position == "OtherRisk"
replace position = "Other (Business/Marketing)" if position == "OtherBus"
replace position = "Other (Admin)" if position == "OtherAdmin"
replace position = "Other (Financial)" if position == "OtherFin"
replace position = "Other (STEM-Related)" if position == "OtherSTEM"
replace position = "Other (Operations)" if position == "OtherOper"

egen percentOther = rowtotal(percent_all_*)
replace percentOther = percentOther-percent_all_51-percent_all_52-percent_all_53-percent_all_22-percent_all_61-percent_all_54
gen percentIncluded = percent_all_51+percent_all_52+percent_all_53+percent_all_22+percent_all_61+percent_all_54

egen total= group(percentIncluded position)
labmask total, val(position)

graph hbar (asis) percent_all_51 percent_all_52 percent_all_53 percent_all_22 percent_all_61 percent_all_54 if year == 2020 & position != "Chief knowledge officer", over( total, label(labsize(2))) stack legend(label(1 "Information") label(2 "Finance and Insurance") label(3 "Real Estate and" "Rental and Leasing") label(4 "Utilities") label(5 "Educational Services") label(6 "Professional, Scientific," "and Technical Services") title(Industry, size(*0.5)) size(*0.5) symxsize(*0.3)) ytitle("Percent of positions in each industry (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(8.5)
graph export "$export_directory/figs/bar_pos_ind2020.png", replace

*graph hbar (asis) percent_all_51 percent_all_52 percent_all_53 percent_all_22 percent_all_61 percent_all_54 if year == 2000 & position != "Chief knowledge officer", over( total, label(labsize(2))) stack legend(label(1 "Information") label(2 "Finance and Insurance") label(3 "Real Estate and" "Rental and Leasing") label(4 "Utilities") label(5 "Educational Services") label(6 "Professional, Scientific," "and Technical Services") title(Industry, size(*0.5)) size(*0.5) symxsize(*0.3)) ytitle("Percent of positions in each industry (2000)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(8.5)
*graph export "$export_directory/figs/bar_pos_ind2000.png", replace


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

*graph hbar (asis) p_with_pos_all p_with_pos if year==2020 & position != "Chief knowledge officer", over(position, sort(2) label(labsize(2))) legend(label(1 "All firms") label(2 "Top Industries")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(8.5) bar(1, fcolor(black)) bar(2, fcolor(lime))
*graph export "$export_directory/figs/bar_p_pos_ind2020.png", replace// width(5000)

graph hbar (asis) p_with_pos_all p_with_pos51 p_with_pos52 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(3))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange)) ysize(8.5) // ysize(12)
graph export "$export_directory/figs/bar_p_pos_51522020.png", replace // width(5000)

graph hbar (asis) p_with_pos_all p_with_pos51 p_with_pos52 if year==2000 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(3))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange)) ysize(8.5) // ysize(12)
graph export "$export_directory/figs/bar_p_pos_51522000.png", replace // width(5000)

graph hbar (asis) c_p_with_pos_all c_p_with_pos51 c_p_with_pos52 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(3))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange)) ysize(8.5) // ysize(12)
graph export "$export_directory/figs/bar_c_p_pos_51522020.png", replace // width(5000)


* 90th ptile
*graph hbar (asis) p_with_pos_90 p_with_pos9051 p_with_pos9052 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))


*graph hbar (asis) p_with_pos_90 p_with_pos9051 p_with_pos9052 if year==2000 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))

*graph hbar (asis) c_p_with_pos_90 c_p_with_pos9051 c_p_with_pos9052 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All firms") label(2 "Information") label(3 "Finance and Insurance")  size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))

graph hbar (asis) p_with_pos_rest p_with_pos_90 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2.5))) legend(label(1 "Below 90th ptile") label(2 "90th ptile of employment") size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange)) ysize(8.5) // ysize(12)
graph export "$export_directory/figs/bar_p_pos_90_2020.png", replace // width(5000)

graph hbar (asis) p_with_pos_rest p_with_pos_90 if year==2000 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2.5))) legend(label(1 "Below 90th ptile") label(2 "90th ptile of employment") size(*0.5) symxsize(*0.3)) ytitle("Percent of companies with each position (2000)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange)) ysize(8.5) // ysize(12)
graph export "$export_directory/figs/bar_p_pos_90_2000.png", replace // width(5000)

graph hbar (asis) c_p_with_pos_rest c_p_with_pos_90 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2.5))) legend(label(1 "Below 90th ptile") label(2 "90th ptile of employment") size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange)) ysize(8.5) // ysize(12)
graph export "$export_directory/figs/bar_c_p_pos_90_2020.png", replace // width(5000)

*graph hbar (asis) c_p_with_pos51 c_p_with_pos9051 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All Information") label(2 "90th ptile Information") size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))

*graph hbar (asis) c_p_with_pos52 c_p_with_pos9052 if year==2020 & position != "Chief knowledge officer", over(position, sort(1) label(labsize(2))) legend(label(1 "All Fin/Insur.") label(2 "90th ptile Fin/Insur.") size(*0.5) symxsize(*0.3)) ytitle("Change in percent of companies with each position (2000-2020)", size(2)) ylabel(, labsize(2)) graphregion(color(white)) ysize(12) bar(1, fcolor(black)) bar(2, fcolor(lime)) bar(3, fcolor(orange))

*** Timeseries


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


scatter pos_CCreat year if emp_90 == 1, connect(L) || scatter pos_CCreat year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with CTO")

scatter pos_CCustom year if emp_90 == 1, connect(L) || scatter pos_CCustom year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with CTO")

scatter pos_CEthics year if emp_90 == 1, connect(L) || scatter pos_CEthics year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with CTO")

scatter pos_CInnov year if emp_90 == 1, connect(L) || scatter pos_CInnov year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with CTO")

scatter pos_CIO year if emp_90 == 1, connect(L) || scatter pos_CIO year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with CTO")

scatter pos_CInvest year if emp_90 == 1, connect(L) || scatter pos_CInvest year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with CTO")

scatter pos_CPO year if emp_90 == 1, connect(L) || scatter pos_CPO year if emp_90 == 0, connect(L) legend(label(1 "90th ptile employment") label(2 "Other")) graphregion(color(white)) ytitle("Share of firms with CTO")

*** Timeseries table
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
keep if emp_90 == 1

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

gen count = 1
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
replace change_20yr = 441 if position == "Obs"

gen change_10yr = percent_with_pos - L10.percent_with_pos
replace change_10yr = 441 if position == "Obs"

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
eststo: estpost tabstat change_10yr if year == 2010, stats(mean) by(position2020_funct) nototal
eststo: estpost tabstat percent_with_pos if year == 2010, s(mean) by(position2020_funct) nototal
eststo: estpost tabstat change_10yr if year == 2020, stats(mean) by(position2020_funct) nototal
eststo: estpost tabstat percent_with_pos if year == 2020, s(mean) by(position2020_funct) nototal

esttab, not noobs nostar nonumber nomtitle cell(mean) collabels(none) mlabels("\% of firms (2000)" "\% of firms (2010)" "$\Delta$ (2000-2010)" "\% of firms (2020)" "$\Delta$ (2010-2020)") title(Percent of firms with each position) varlabels(`e(labels)') label
esttab using "$export_directory/tables/c_pos_emp.tex", not noobs nostar nonumber nomtitle cell(mean(fmt (%2.1f))) collabels(none) mlabels("\% of firms (2000)" "\% of firms (2010)" "$\Delta$ (2000-2010)" "\% of firms (2020)" "$\Delta$ (2010-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position (BALANCED)\label{tab98}) replace booktabs addnote("\textbf{Other (Admin):} Chief Administration Officer, Chief Governance Officer, Chief Diversity Officer, Chief Talent Officer, Chief of Staff; \textbf{Other (Finance):} Chief Audit Executive, Chief Credit Officer, Chief Investment Officer, Chief Revenue Officer, Chief Banking Officer, Chief Tax Officer; \textbf{Other (Business/Marketing):} Chief commercial officer, Chief content office, Chief Creative Officer, Chief Product Officer, Chief Strategy Officer, Chief Customer Officer, Chief Communication Officer, Chief Merchandise Officer, Chief Sales Officer, Chief Development Officer, Chief Brand Officer; \textbf{Other (STEM-Related): } Chief Data Officer, Chief Knowledge Officer, Chief Scientific Officer, Chief Sustainability Officer, Chief Digital Officer, Chief Innovation Officer; \textbf{Other (Operations): } Chief Procurement Officer, Chief Supply Chain Officer, Chief Risk Officer, Chief Security Officer, Chief Ethics Officer")



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
keep if emp_90 == 0

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

gen count = 1
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
replace change_20yr = 441 if position == "Obs"

gen change_10yr = percent_with_pos - L10.percent_with_pos
replace change_10yr = 441 if position == "Obs"

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
eststo: estpost tabstat change_10yr if year == 2010, stats(mean) by(position2020_funct) nototal
eststo: estpost tabstat percent_with_pos if year == 2010, s(mean) by(position2020_funct) nototal
eststo: estpost tabstat change_10yr if year == 2020, stats(mean) by(position2020_funct) nototal
eststo: estpost tabstat percent_with_pos if year == 2020, s(mean) by(position2020_funct) nototal

esttab, not noobs nostar nonumber nomtitle cell(mean) collabels(none) mlabels("\% of firms (2000)" "\% of firms (2010)" "$\Delta$ (2000-2010)" "\% of firms (2020)" "$\Delta$ (2010-2020)") title(Percent of firms with each position) varlabels(`e(labels)') label
esttab using "$export_directory/tables/c_pos_emp0.tex", not noobs nostar nonumber nomtitle cell(mean(fmt (%2.1f))) collabels(none) mlabels("\% of firms (2000)" "\% of firms (2010)" "$\Delta$ (2000-2010)" "\% of firms (2020)" "$\Delta$ (2010-2020)") varlabels(`e(labels)') label title(Percent of firms with each C-Suite position (Below 90th ptile employment and balanced)\label{tab98}) replace booktabs addnote("\textbf{Other (Admin):} Chief Administration Officer, Chief Governance Officer, Chief Diversity Officer, Chief Talent Officer, Chief of Staff; \textbf{Other (Finance):} Chief Audit Executive, Chief Credit Officer, Chief Investment Officer, Chief Revenue Officer, Chief Banking Officer, Chief Tax Officer; \textbf{Other (Business/Marketing):} Chief commercial officer, Chief content office, Chief Creative Officer, Chief Product Officer, Chief Strategy Officer, Chief Customer Officer, Chief Communication Officer, Chief Merchandise Officer, Chief Sales Officer, Chief Development Officer, Chief Brand Officer; \textbf{Other (STEM-Related): } Chief Data Officer, Chief Knowledge Officer, Chief Scientific Officer, Chief Sustainability Officer, Chief Digital Officer, Chief Innovation Officer; \textbf{Other (Operations): } Chief Procurement Officer, Chief Supply Chain Officer, Chief Risk Officer, Chief Security Officer, Chief Ethics Officer")


*** Within-cluster correlations
use "$data_directory/reg_data.dta", clear

gen count = 1

egen pos_OtherAdmin = rowmax(pos_CAO pos_CGov pos_CDiv pos_CTal pos_CStaff)
egen pos_OtherFin = rowmax(pos_CAE pos_CCredit pos_CInvest pos_CRev pos_CBank pos_CTax)
egen pos_OtherBus = rowmax(pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand)
egen pos_OtherSTEM = rowmax(pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CDigit pos_CInnov)
egen pos_OtherOper = rowmax(pos_CRisk pos_CSO_sec pos_CEthics pos_CProcure pos_CSupp)

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
label var pos_OtherAdmin "Other (Admin)"
label var pos_OtherFin "Other (Financial)"
label var pos_OtherBus "Other (Business/Marketing)"
label var pos_OtherSTEM "Other (STEM-Related)"
label var pos_OtherOper "Other (Operations)"

estpost corr pos_CAO pos_CGov pos_CDiv pos_CTal pos_CStaff, matrix listwise
esttab using "$export_directory/tables/corr_OtherAdmin.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) title("Correlations of executive positions") booktabs replace

estpost corr pos_CAE pos_CCredit pos_CInvest pos_CRev pos_CBank pos_CTax, matrix listwise
esttab using "$export_directory/tables/corr_OtherFin.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) title("Correlations of executive positions") booktabs replace

estpost corr pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand, matrix listwise
esttab using "$export_directory/tables/corr_OtherBus.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) title("Correlations of executive positions") booktabs replace

estpost corr pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CDigit pos_CInnov, matrix listwise
esttab using "$export_directory/tables/corr_OtherSTEM.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) title("Correlations of executive positions") booktabs replace

estpost corr pos_CRisk pos_CSO_sec pos_CEthics pos_CProcure pos_CSupp, matrix listwise
esttab using "$export_directory/tables/corr_OtherOper.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) title("Correlations of executive positions") booktabs replace


*drop pos_CRisk pos_CSO_sec pos_CAO pos_CGov pos_CDiv pos_CTal pos_CAE pos_CCredit pos_CInvest pos_CComm pos_CCO_cont pos_CCreat pos_CPO pos_CStrat pos_CDO pos_CKO pos_CSci pos_CSO_sus pos_CEthics pos_CStaff pos_CRev pos_CBank pos_CTax pos_CCustom pos_CCommunication pos_CMerch pos_CSales pos_CDev pos_CBrand pos_CDigit pos_CInnov pos_CProcure pos_CSupp

replace pos_Chief = 1 if pos_Chief > 0


estpost corr pos_CEO pos_Chair pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_1.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) title("Correlations of executive positions") booktabs replace

estpost corr pos_CFO pos_CAcc pos_OtherFin pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_2.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of financial positions")

estpost corr pos_COO pos_CMO pos_CBus pos_OtherOper pos_OtherBus pos_CHRO pos_OtherAdmin pos_Chief, matrix listwise
eststo correlation3
esttab correlation3 using "$export_directory/tables/corr_3.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of operational positions")

estpost corr pos_CHRO pos_OtherAdmin, matrix listwise
esttab using "$export_directory/tables/corr_3b.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of HR positions")

estpost corr pos_CLegal pos_CCounsel pos_CCO_comp pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_4.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of legal positions")

estpost corr pos_CTO pos_CIO pos_CMed pos_OtherSTEM pos_Chief, matrix listwise
esttab using "$export_directory/tables/corr_5.tex", unstack not noobs compress label star(* 0.10 ** 0.05 *** 0.01) booktabs replace title("Correlations of technical positions")



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
	label var c_`pos' "$\Delta$ `: var label `pos''"
	
}

matrix coefs = J(2,18,.)

local i = 1
foreach pos of varlist pos_* {

	pwcorr c_`pos' c_pos_COO, sig
	if r(sig)[1,2] < 0.1 {
		
		matrix coefs[1, `i'] = "`: var label c_`pos''"
		matrix coefs[2, `i'] = r(rho)
		local i = `i' + 1
		
	}

}

eststo clear
eststo: reg c_pos_COO c_pos_Chair c_pos_CAcc c_pos_CAO c_pos_CAE c_pos_CBank c_pos_CBrand c_pos_CBus c_pos_CComm c_pos_CCommunication c_pos_CCO_comp c_pos_CCO_cont c_pos_CCounsel c_pos_CCreat c_pos_CCredit c_pos_CCustom c_pos_CDev c_pos_CDigit c_pos_CDO c_pos_CDiv c_pos_CEO c_pos_CEthics c_pos_CFO c_pos_CGov c_pos_CHRO c_pos_CInnov c_pos_CIO c_pos_CInvest c_pos_CKO c_pos_CLegal c_pos_CMO c_pos_CMed c_pos_CMerch c_pos_CPO c_pos_CProcure c_pos_CRev c_pos_CRisk c_pos_CSales c_pos_CSci c_pos_CSO_sec c_pos_CStaff c_pos_CStrat c_pos_CSO_sus c_pos_CSupp c_pos_CTal c_pos_CTax c_pos_CTO, r
esttab using "$export_directory/tables/COO_regs_all.tex", se label star(* 0.10 ** 0.05 *** 0.01) title("Reg of change in COO positions on change in other positions (2000-2020)") compress wide long booktabs replace

eststo clear
eststo: reg c_pos_COO pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO, r
esttab using "$export_directory/tables/COO_regs_all_pos.tex", se label star(* 0.10 ** 0.05 *** 0.01) title("Reg of change in COO positions on indicatros for other positions (2000-2020)") compress wide booktabs replace


eststo clear
eststo: reg c_pos_COO c_pos_Chair c_pos_CEO c_pos_CFO c_pos_CAcc c_pos_CHRO c_pos_CIO c_pos_CTO c_pos_CCO_comp c_pos_CMO c_pos_CLegal c_pos_CBus c_pos_CMed c_pos_CCounsel c_pos_OtherAdmin c_pos_OtherFin c_pos_OtherBus c_pos_OtherSTEM c_pos_OtherOper, r
esttab using "$export_directory/tables/COO_regs_all_funct.tex", se label star(* 0.10 ** 0.05 *** 0.01) title("Reg of change in COO positions on change in other positions (2000-2020)") compress wide booktabs replace



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

collapse pos_*, by(year emp_90 naics_2)

reshape wide pos_*, i(year naics_2) j(emp_90)

xtset naics_2 year

foreach var of varlist pos_* {
	
	gen c_`var' = `var' - L1.`var'
	
}

gen f3_c_pos_CIO0 = F3.c_pos_CIO0
gen f3_c_pos_CTO0 = F3.c_pos_CTO0
gen f1_c_pos_CTO0 = F1.c_pos_CTO0

binscatter f1_c_pos_CTO0 c_pos_CTO1, absorb(year)
