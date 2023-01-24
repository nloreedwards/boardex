global data_directory "/export/home/dor/nloreedwards/Documents/BoardEx/data/"
global working_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex"

cd "$working_directory"

use "$data_directory/kzucvmqutm4nfe5j", clear

append using "$data_directory/uylsi7xcdclfdbou"
append using "$data_directory/cqn6qq79htn1v8fy"
append using "$data_directory/6ybibdesgsivoici"

drop CompanyID

sort BoardName DirectorName AnnualReportDate

save "$data_directory/raw_data", replace

use "$data_directory/raw_data", clear

mark pos_CEO if strpos(RoleName, "CEO") | strpos(RoleName, "Chief Executive Officer")
replace pos_CEO = 1 if RoleName == "Chief Executive" | RoleName == "Chairman/Chief Executive"
replace pos_CEO = 0 if strpos(RoleName, "Deputy CEO")
replace pos_CEO = 0 if strpos(RoleName, "Regional CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division Co-CEO")

mark pos_COO if strpos(RoleName, "COO") | strpos(RoleName, "Chief Operating Officer") | strpos(RoleName, "Chief Operations Officer")

mark pos_CFO if strpos(RoleName, "CFO") | strpos(RoleName, "Chief Financial Officer") | strpos(RoleName, "Vice President - Finance")

mark pos_CIO if strpos(RoleName, "CIO") | strpos(RoleName, "Chief Information Officer")

mark pos_CTO if strpos(RoleName, "CTO") | strpos(RoleName, "Chief Technology Officer") | strpos(RoleName, "Chief Technical Officer")

mark pos_CCO_comp if strpos(RoleName, "CCO") | strpos(RoleName, "Chief Compliance Officer")

mark pos_CKO if strpos(RoleName, "CKO") | strpos(RoleName, "Chief Knowledge Officer")

mark pos_CDO if strpos(RoleName, "CDO") | strpos(RoleName, "Chief Data Officer")

mark pos_CMO if strpos(RoleName, "CMO") | strpos(RoleName, "Chief Marketing Officer")

mark pos_CSO_sec if strpos(RoleName, "CSO") | strpos(RoleName, "Chief Security Officer")

mark pos_CSO_sus if strpos(RoleName, "CSO") | strpos(RoleName, "Chief Sustainability Officer")

mark pos_CAO if strpos(RoleName, "CAO") | strpos(RoleName, "Chief Administration Officer")

mark pos_CPO if strpos(RoleName, "CPO") | strpos(RoleName, "Chief Product Officer")

mark pos_CCO_cont if strpos(RoleName, "CCO") | strpos(RoleName, "Chief Content Officer")

mark pos_CHRO if strpos(RoleName, "CHRO") | strpos(RoleName, "Chief Human Resources Officer")

egen has_pos = rowmax(pos_CEO pos_COO pos_CFO pos_CIO pos_CTO pos_CCO_comp pos_CKO pos_CDO pos_CMO pos_CSO_sec pos_CSO_sus pos_CAO pos_CPO pos_CCO_cont pos_CHRO)
drop if has_pos == 0

save "$data_directory/c_suite_data", replace


*** More Liberal Approach
use "$data_directory/raw_data", clear

mark pos_CEO if strpos(RoleName, "CEO") | strpos(RoleName, "Chief Executive Officer") | strpos(RoleName, "Chairman") | strpos(RoleName, "President") | strpos(RoleName, "Chairwoman")

*RoleName == "President" | RoleName == "Chairman" | RoleName == "Chairwoman" | RoleName == "Chairman (Executive)" | RoleName == "Chairman/President"
replace pos_CEO = 1 if RoleName == "Chief Executive" | RoleName == "Chairman/Chief Executive"
replace pos_CEO = 0 if strpos(RoleName, "Deputy CEO")
replace pos_CEO = 0 if strpos(RoleName, "Regional CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division Co-CEO")
replace pos_CEO = 0 if strpos(RoleName, "Vice Chairman")
replace pos_CEO = 0 if strpos(RoleName, "Vice Chairwoman")
replace pos_CEO = 0 if strpos(RoleName, "Vice President")

mark pos_COO if strpos(RoleName, "COO") | strpos(RoleName, "Chief Operating Officer") | strpos(RoleName, "ED - Ops") | strpos(RoleName, "Vice President - Ops") | strpos(RoleName, "Executive VP - Ops") | strpos(RoleName, "Operations Director") | strpos(RoleName, "Director - Ops") | strpos(RoleName, "Executive VP - Ops") | strpos(RoleName, "Chief Operations Officer") | strpos(RoleName, "Senior VP - Ops")

mark pos_CFO if strpos(RoleName, "CFO") | strpos(RoleName, "Chief Financial Officer") | strpos(RoleName, "Treasurer") | strpos(RoleName, "ED - Finance") | strpos(RoleName, "Director - Finance") | strpos(RoleName, "Vice President - Finance")

mark pos_CIO if strpos(RoleName, "CIO") | strpos(RoleName, "Chief Information Officer")

mark pos_CTO if strpos(RoleName, "CTO") | strpos(RoleName, "Chief Technology Officer") | strpos(RoleName, "Chief Technical Officer") | strpos(RoleName, "ED - Technical") | strpos(RoleName, "Director - Technical") | strpos(RoleName, "ED - IT") | strpos(RoleName, "Board Member - IT") | strpos(RoleName, "IT Director")

mark pos_CCO_comp if strpos(RoleName, "CCO") | strpos(RoleName, "Chief Compliance Officer")

mark pos_CKO if strpos(RoleName, "CKO") | strpos(RoleName, "Chief Knowledge Officer")

mark pos_CDO if strpos(RoleName, "CDO") | strpos(RoleName, "Chief Data Officer")

mark pos_CMO if strpos(RoleName, "CMO") | strpos(RoleName, "Chief Marketing Officer") | strpos(RoleName, "ED - Sales/Mktg") | strpos(RoleName, "Marketing Director") | strpos(RoleName, "ED - Mktg") | strpos(RoleName, "Director - Sales/Mktg") | strpos(RoleName, "Executive VP - Sales/Mktg")

mark pos_CSO_sec if strpos(RoleName, "CSO") | strpos(RoleName, "Chief Security Officer")

mark pos_CSO_sus if strpos(RoleName, "CSO") | strpos(RoleName, "Chief Sustainability Officer")

mark pos_CAO if strpos(RoleName, "CAO") | strpos(RoleName, "Chief Administration Officer")

mark pos_CPO if strpos(RoleName, "CPO") | strpos(RoleName, "Chief Product Officer")

mark pos_CCO_cont if strpos(RoleName, "CCO") | strpos(RoleName, "Chief Content Officer")

mark pos_CHRO if strpos(RoleName, "CHRO") | strpos(RoleName, "Chief Human Resources Officer") | strpos(RoleName, "ED - HR") | strpos(RoleName, "HR Director")

egen has_pos = rowmax(pos_CEO pos_COO pos_CFO pos_CIO pos_CTO pos_CCO_comp pos_CKO pos_CDO pos_CMO pos_CSO_sec pos_CSO_sus pos_CAO pos_CPO pos_CCO_cont pos_CHRO)
drop if has_pos == 0

save "$data_directory/c_suite_data_expanded", replace

*** Company Data
use "$data_directory/xtfqclfn2hthmbqm", clear

append using "$data_directory/dlta74rxpdkvc48g"
append using "$data_directory/diohiyjazdzgto8g"
append using "$data_directory/udf8nl05lbkqtf6e"

keep BoardID RevenueValueDate MktCapitalisation NoEmployees Revenue Currency
drop if missing(RevenueValueDate) & missing(MktCapitalisation) & missing(NoEmployees) & missing(Revenue) & missing(Currency)

duplicates drop

sort BoardID

save "$data_directory/company_size_data", replace


*** Alternate Board Data
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
	sort CompanyID CompanyName end_year
	duplicates drop CompanyID CompanyName end_year, force
	egen max_year = max(end_year), by(CompanyID)
	keep if end_year == max_year
	duplicates drop CompanyID CompanyName, force
	duplicates drop CompanyID, force
	keep CompanyID CompanyName
	rename CompanyID companyid
	save "$data_directory/company_names", replace
restore

drop CompanyName

duplicates drop

mark pos_Chief if  strpos(RoleName, "Chief")
drop if pos_Chief == 0
drop pos_Chief

reshape long year_, i(CompanyID RoleName Seniority start_year end_year) j(year)

drop if year_ == 0
drop year_

merge m:1 RoleName using "$data_directory/c-suite_roles_key_formerge"
drop _merge
/*

mark pos_CEO if strpos(RoleName, "CEO") | strpos(RoleName, "Chief Executive Officer") | strpos(RoleName, "Chairman") | strpos(RoleName, "President") | strpos(RoleName, "Chairwoman")

replace pos_CEO = 1 if RoleName == "Chief Executive" | RoleName == "Chairman/Chief Executive"
replace pos_CEO = 0 if strpos(RoleName, "Deputy CEO")
replace pos_CEO = 0 if strpos(RoleName, "Regional CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division Co-CEO")
replace pos_CEO = 0 if strpos(RoleName, "Vice Chairman")
replace pos_CEO = 0 if strpos(RoleName, "Vice Chairwoman")
replace pos_CEO = 0 if strpos(RoleName, "Vice President")

mark pos_COO if strpos(RoleName, "COO") | strpos(RoleName, "Chief Operating Officer") | strpos(RoleName, "Chief Operations Officer")

mark pos_CFO if strpos(RoleName, "CFO") | strpos(RoleName, "Chief Financial Officer") | strpos(RoleName, "Vice President - Finance")

mark pos_CIO if strpos(RoleName, "CIO") | strpos(RoleName, "Chief Information Officer") | strpos(RoleName, "Chief Information Security Officer")

mark pos_CTO if strpos(RoleName, "CTO") | strpos(RoleName, "Chief Technology Officer") | strpos(RoleName, "Chief Technical Officer")

mark pos_CCO_comp if strpos(RoleName, "CCO") | strpos(RoleName, "Chief Compliance Officer")

mark pos_CKO if strpos(RoleName, "CKO") | strpos(RoleName, "Chief Knowledge Officer")

mark pos_CDO if strpos(RoleName, "CDO") | strpos(RoleName, "Chief Data Officer")

mark pos_CMO if strpos(RoleName, "CMO") | strpos(RoleName, "Chief Marketing Officer")

mark pos_CSO_sec if strpos(RoleName, "CSO") | strpos(RoleName, "Chief Security Officer")

mark pos_CSO_sus if strpos(RoleName, "CSO") | strpos(RoleName, "Chief Sustainability Officer")

mark pos_CAO if strpos(RoleName, "CAO") | strpos(RoleName, "Chief Administration Officer") | strpos(RoleName, "Chief Administrative Officer") | strpos(RoleName, "Chief Administration Officer")

mark pos_CPO if strpos(RoleName, "CPO") | strpos(RoleName, "Chief Product Officer")

mark pos_CCO_cont if strpos(RoleName, "CCO") | strpos(RoleName, "Chief Content Officer")

mark pos_CHRO if strpos(RoleName, "CHRO") | strpos(RoleName, "Chief Human Resources Officer") | strpos(RoleName, "Chief Human Resource Officer")

mark pos_CAcc if strpos(RoleName, "Chief Accounting Officer") | strpos(RoleName, "Chief Accountant")

mark pos_CAud if strpos(RoleName, "Chief Auditor")

mark pos_CBus if strpos(RoleName, "Chief Business Officer")

mark pos_CComm if strpos(RoleName, "Chief Commercial Officer")

mark pos_CMed if strpos(RoleName, "Chief Medical Officer")

mark pos_CNuc if strpos(RoleName, "Chief Nuclear Officer")

mark pos_CRisk if strpos(RoleName, "Chief Risk Officer")

mark pos_CSci if strpos(RoleName, "Chief Scientific Officer") | strpos(RoleName, "Chief Science Officer") | strpos(RoleName, "Chief Scientific Director") | strpos(RoleName, "Chief Scientist")

mark pos_CCredit if strpos(RoleName, "Chief Credit Officer")

mark pos_CGov if strpos(RoleName, "Chief Governance Officer")

mark pos_CTal if strpos(RoleName, "Chief Talent Officer")

mark pos_CCounsel if strpos(RoleName, "Chief Counsel")

mark pos_CCreat if strpos(RoleName, "Chief Creative Officer")

mark pos_CStrat if strpos(RoleName, "Chief Strategy Officer") | strpos(RoleName, "Chief Strategic Officer")

mark pos_CLegal if strpos(RoleName, "Chief Legal Officer")

mark pos_CArch if strpos(RoleName, "Chief Architect")

mark pos_CCulture if strpos(RoleName, "Chief Culture Officer")

mark pos_CCRO if strpos(RoleName, "Chief Customer Relations Officer")

mark pos_CDev if strpos(RoleName, "Chief Development Officer")

mark pos_CFSO if strpos(RoleName, "Chief Financial Services Officer")

mark pos_CGO if strpos(RoleName, "Chief Growth Officer")

mark pos_CInnov if strpos(RoleName, "Chief Innovation Officer")

mark pos_CInvest if strpos(RoleName, "Chief Investment Officer")

mark pos_CSA if strpos(RoleName, "Chief Software Architect")

*mark pos_CWDO if strpos(RoleName, "Chief Wind-Down Officer")

*mark pos_CALO if strpos(RoleName, "Chief Academic Learning Officer")

*mark pos_CAca if strpos(RoleName, "Chief Academic Officer")

*mark pos_CAccel if strpos(RoleName, "Chief Acceleration Officer")

mark pos_CAccess if strpos(RoleName, "Chief Accessibility Officer")

*mark pos_CAqui if strpos(RoleName, "Chief Acquisitions Officer")

mark pos_CActuary if strpos(RoleName, "Chief Actuarial Administration Officer") | strpos(RoleName, "Chief Actuarial Officer") | strpos(RoleName, "Chief Actuary")
*/
egen has_pos = rowmax(pos_Chief pos_CAcc pos_CAO pos_CAE pos_CBus pos_CComm pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CDO pos_CDiv pos_CEO pos_CFO pos_CGov pos_CHRO pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_COO pos_CPO pos_CRisk pos_CSci pos_CSO_sec pos_CStrat pos_CSO_sus pos_CTal pos_CTO)
drop if has_pos == 0

save "$data_directory/c_suite_data2", replace



/*
*** Alternate Board Data (Expanded)
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

drop DirectorID DirectorName DateStartRole DateEndRole CompanyName

reshape long year_, i(CompanyID RoleName Seniority start_year end_year) j(year)

drop if year_ == 0
drop year_


mark pos_CEO if strpos(RoleName, "CEO") | strpos(RoleName, "Chief Executive Officer") | strpos(RoleName, "Chairman") | strpos(RoleName, "President") | strpos(RoleName, "Chairwoman")

*RoleName == "President" | RoleName == "Chairman" | RoleName == "Chairwoman" | RoleName == "Chairman (Executive)" | RoleName == "Chairman/President"
replace pos_CEO = 1 if RoleName == "Chief Executive" | RoleName == "Chairman/Chief Executive"
replace pos_CEO = 0 if strpos(RoleName, "Deputy CEO")
replace pos_CEO = 0 if strpos(RoleName, "Regional CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division Co-CEO")
replace pos_CEO = 0 if strpos(RoleName, "Vice Chairman")
replace pos_CEO = 0 if strpos(RoleName, "Vice Chairwoman")
replace pos_CEO = 0 if strpos(RoleName, "Vice President")

mark pos_COO if strpos(RoleName, "COO") | strpos(RoleName, "Chief Operating Officer") | strpos(RoleName, "ED - Ops") | strpos(RoleName, "Vice President - Ops") | strpos(RoleName, "Executive VP - Ops") | strpos(RoleName, "Operations Director") | strpos(RoleName, "Director - Ops") | strpos(RoleName, "Executive VP - Ops") | strpos(RoleName, "Chief Operations Officer") | strpos(RoleName, "Senior VP - Ops")

mark pos_CFO if strpos(RoleName, "CFO") | strpos(RoleName, "Chief Financial Officer") | strpos(RoleName, "Treasurer") | strpos(RoleName, "ED - Finance") | strpos(RoleName, "Director - Finance") | strpos(RoleName, "Vice President - Finance")

mark pos_CIO if strpos(RoleName, "CIO") | strpos(RoleName, "Chief Information Officer")

mark pos_CTO if strpos(RoleName, "CTO") | strpos(RoleName, "Chief Technology Officer") | strpos(RoleName, "Chief Technical Officer") | strpos(RoleName, "ED - Technical") | strpos(RoleName, "Director - Technical") | strpos(RoleName, "ED - IT") | strpos(RoleName, "Board Member - IT") | strpos(RoleName, "IT Director")

mark pos_CCO_comp if strpos(RoleName, "CCO") | strpos(RoleName, "Chief Compliance Officer")

mark pos_CKO if strpos(RoleName, "CKO") | strpos(RoleName, "Chief Knowledge Officer")

mark pos_CDO if strpos(RoleName, "CDO") | strpos(RoleName, "Chief Data Officer")

mark pos_CMO if strpos(RoleName, "CMO") | strpos(RoleName, "Chief Marketing Officer") | strpos(RoleName, "ED - Sales/Mktg") | strpos(RoleName, "Marketing Director") | strpos(RoleName, "ED - Mktg") | strpos(RoleName, "Director - Sales/Mktg") | strpos(RoleName, "Executive VP - Sales/Mktg")

mark pos_CSO_sec if strpos(RoleName, "CSO") | strpos(RoleName, "Chief Security Officer")

mark pos_CSO_sus if strpos(RoleName, "CSO") | strpos(RoleName, "Chief Sustainability Officer")

mark pos_CAO if strpos(RoleName, "CAO") | strpos(RoleName, "Chief Administration Officer")

mark pos_CPO if strpos(RoleName, "CPO") | strpos(RoleName, "Chief Product Officer")

mark pos_CCO_cont if strpos(RoleName, "CCO") | strpos(RoleName, "Chief Content Officer")

mark pos_CHRO if strpos(RoleName, "CHRO") | strpos(RoleName, "Chief Human Resources Officer") | strpos(RoleName, "ED - HR") | strpos(RoleName, "HR Director")

egen has_pos = rowmax(pos_CEO pos_COO pos_CFO pos_CIO pos_CTO pos_CCO_comp pos_CKO pos_CDO pos_CMO pos_CSO_sec pos_CSO_sus pos_CAO pos_CPO pos_CCO_cont pos_CHRO)
drop if has_pos == 0

save "$data_directory/c_suite_data2_expanded", replace
*/
