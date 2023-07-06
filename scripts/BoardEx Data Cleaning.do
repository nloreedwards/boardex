global data_directory "/Users/nlore-edwards/Dropbox (Harvard University)/BoardEx"
global working_directory "/Users/nlore-edwards/Documents/Git Repos/boardex"

cd "$working_directory"

* Load data
use "$data_directory/szjadkbqppod3snh", clear

append using "$data_directory/qlufvmvn2xvizniz"
append using "$data_directory/loqpa6qftokutbrb"
append using "$data_directory/ajpv5zbsoh7tjplg"

duplicates drop

gen start_year = year(DateStartRole)
gen end_year = year(DateEndRole)

drop if DateStartRole == .n & DateEndRole == .n
forvalues y = 2000/2020 {
	
	mark year_`y' if (end_year >= `y' | end_year == .) & (start_year <= `y' | start_year == .)
	
}

drop DirectorID DirectorName DateStartRole DateEndRole

duplicates drop


preserve
	merge m:1 RoleName using "$data_directory/c-suite_roles_key_formerge_exp"
	egen has_pos = rowmax(pos_Chair pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_COO pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO pos_Chief)
	egen num_pos = sum(has_pos), by(CompanyID)
	sort CompanyID CompanyName end_year
	duplicates drop CompanyID CompanyName end_year, force
	egen max_year = max(end_year), by(CompanyID)
	keep if end_year == max_year
	duplicates drop CompanyID CompanyName, force
	duplicates drop CompanyID, force
	keep CompanyID CompanyName num_pos
	rename CompanyID companyid
	save "$data_directory/company_names", replace
restore

drop CompanyName

duplicates drop

* Drop clear non-C-Suite positions
*mark pos_Chief if  strpos(RoleName, "Chief")
*drop if pos_Chief == 0
*drop pos_Chief

reshape long year_, i(CompanyID RoleName Seniority start_year end_year) j(year)

drop if year_ == 0
drop year_

* Merge in classified names
merge m:1 RoleName using "$data_directory/c-suite_roles_key_formerge_exp"
drop if _merge == 2
drop _merge

egen has_pos = rowmax(pos_Chair pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_COO pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO pos_Chief)
drop if has_pos == 0

save "$data_directory/c_suite_data2_exp", replace
