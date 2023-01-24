global data_directory "/export/home/dor/nloreedwards/Documents/BoardEx/data/"
global working_directory "/export/home/dor/nloreedwards/Documents/Git_Repos/boardex"

cd "$working_directory"

** File 1
import delimited "$data_directory/c-suite_roles_1_complete.csv", clear varnames(1)

drop v8
replace c_suite = "1" if unsure == "q"
destring unsure, replace ignore("q")
destring unsure, replace

replace role_classified2 = "" if role_classified2 == "??"
replace role_classified1 = "" if role_classified1 == "??"

save "$data_directory/c-suite_roles_1_complete"

gen role1_valid = 0
gen role2_valid = 0
gen role3_valid = 0
local codes "pos_CAcc pos_CAO pos_CAE pos_CBus pos_CComm pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CDO pos_CDiv pos_CEO pos_CFO pos_CGov pos_CHRO pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_COO pos_CPO pos_CRisk pos_CSci pos_CSO_sec pos_CStrat pos_CSO_sus pos_CTal pos_CTO"
foreach code in `codes' {
	
	replace role_classified1 = "`code'" if lower(role_classified1) == lower("`code'")
	replace role_classified2 = "`code'" if lower(role_classified2) == lower("`code'")
	replace role_classified3 = "`code'" if lower(role_classified3) == lower("`code'")
	
}
foreach code in `codes' {
	
	replace role1_valid = 1 if role_classified1 == "`code'"
	replace role2_valid = 1 if role_classified2 == "`code'"
	replace role3_valid = 1 if role_classified3 == "`code'"
	
}

replace role_classified1 = "" if role1_valid == 0
replace role_classified2 = "" if role2_valid == 0
replace role_classified3 = "" if role3_valid == 0
keep id role c_suite role_classified*

reshape long role_classified, i(id role c_suite) j(role_index)
duplicates drop role_classified id role c_suite, force

mark has_role if role_classified != ""
egen max_has_role = max(has_role), by(id)
drop if max_has_role == 1 & has_role == 0

keep id role c_suite role_classified

save "$data_directory/c-suite_roles_1_key"

** File 2
import delimited "$data_directory/c-suite_roles_2_complete.csv", clear varnames(1)
destring c_suite, replace

save "$data_directory/c-suite_roles_2_complete"

gen role1_valid = 0
gen role2_valid = 0
gen role3_valid = 0
local codes "pos_CAcc pos_CAO pos_CAE pos_CBus pos_CComm pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CDO pos_CDiv pos_CEO pos_CFO pos_CGov pos_CHRO pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_COO pos_CPO pos_CRisk pos_CSci pos_CSO_sec pos_CStrat pos_CSO_sus pos_CTal pos_CTO"
foreach code in `codes' {
	
	replace role_classified1 = "`code'" if lower(role_classified1) == lower("`code'")
	replace role_classified2 = "`code'" if lower(role_classified2) == lower("`code'")
	replace role_classified3 = "`code'" if lower(role_classified3) == lower("`code'")
	
}
foreach code in `codes' {
	
	replace role1_valid = 1 if role_classified1 == "`code'"
	replace role2_valid = 1 if role_classified2 == "`code'"
	replace role3_valid = 1 if role_classified3 == "`code'"
	
}

replace role_classified1 = "" if role1_valid == 0
replace role_classified2 = "" if role2_valid == 0
replace role_classified3 = "" if role3_valid == 0

keep id role c_suite role_classified*

reshape long role_classified, i(id role c_suite) j(role_index)
duplicates drop role_classified id role c_suite, force

mark has_role if role_classified != ""
egen max_has_role = max(has_role), by(id)
drop if max_has_role == 1 & has_role == 0

keep id role c_suite role_classified

save "$data_directory/c-suite_roles_2_key"

** Full Key
use "$data_directory/c-suite_roles_1_key", clear
append using "$data_directory/c-suite_roles_2_key"

duplicates drop

save "$data_directory/c-suite_roles_key"

bysort id: gen index = _n
reshape wide role_classified, i(id role c_suite) j(index)

local codes "pos_CAcc pos_CAO pos_CAE pos_CBus pos_CComm pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CDO pos_CDiv pos_CEO pos_CFO pos_CGov pos_CHRO pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_COO pos_CPO pos_CRisk pos_CSci pos_CSO_sec pos_CStrat pos_CSO_sus pos_CTal pos_CTO"
foreach code in `codes' {
	
	mark `code' if (role_classified1 == "`code'" | role_classified2 == "`code'" | role_classified2 == "`code'") & c_suite == 1
	
}

egen has_pos = rowmax(pos_CAcc pos_CAO pos_CAE pos_CBus pos_CComm pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CDO pos_CDiv pos_CEO pos_CFO pos_CGov pos_CHRO pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_COO pos_CPO pos_CRisk pos_CSci pos_CSO_sec pos_CStrat pos_CSO_sus pos_CTal pos_CTO)

mark pos_Chief if c_suite == 1 & has_pos == 0
drop has_pos

save "$data_directory/c-suite_roles_key_1-to-1"

* Manually finish classifying *
import delimited "$data_directory/c-suite_roles_key_1-to-1_exp.csv", varnames(1) clear
drop pos* _merge

local codes "pos_Chair pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_COO pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO"

foreach code in `codes' {
	
	mark `code' if (lower(role_classified1) == lower("`code'") | lower(role_classified2) == lower("`code'") | lower(role_classified3) == lower("`code'")) & c_suite == 1
	
}

egen has_pos = rowmax(pos_Chair pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_COO pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO)

mark pos_Chief if c_suite == 1 & has_pos == 0
drop has_pos

recast str132 role

save "$data_directory/c-suite_roles_key_1-to-1_exp2"

* Load role names *

merge m:1 role using "$data_directory/c-suite_roles_key_1-to-1_exp2"
drop if _merge == 2
collapse (rawsum) pos_Chair pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_COO pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO pos_Chief, by(RoleName)

save "$data_directory/c-suite_roles_key_formerge_exp", replace
