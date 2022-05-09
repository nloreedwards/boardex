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

mark pos_CEO if strpos(RoleName, "CEO") | strpos(RoleName, "Chief Executive Officer")
replace pos_CEO = 1 if RoleName == "Chief Executive"
replace pos_CEO = 0 if strpos(RoleName, "Deputy CEO")
replace pos_CEO = 0 if strpos(RoleName, "Regional CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division CEO")
replace pos_CEO = 0 if strpos(RoleName, "Division Co-CEO")

mark pos_COO if strpos(RoleName, "COO") | strpos(RoleName, "Chief Operating Officer")

mark pos_CFO if strpos(RoleName, "CFO") | strpos(RoleName, "Chief Financial Officer")

mark pos_CIO if strpos(RoleName, "CIO") | strpos(RoleName, "Chief Information Officer")

mark pos_CTO if strpos(RoleName, "CTO") | strpos(RoleName, "Chief Technology Officer")

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
