program define clean_companyname
    args var

	replace `var' = subinstr(`var', "'", " ", .)
	replace `var' = subinstr(`var', ",", " ", .)
	replace `var' = subinstr(`var', ".", " ", .)
	replace `var' = subinstr(`var', "&", " ", .)
	replace `var' = subinstr(`var', "$", " ", .)
	replace `var' = subinstr(`var', "/", " ", .)
	replace `var' = subinstr(`var', "*", " ", .)
	replace `var' = subinstr(`var', "#", " ", .)
	replace `var' = subinstr(`var', "%", " ", .)
	replace `var' = subinstr(`var', "~", " ", .)
	replace `var' = subinstr(`var', "+", " ", .)
	replace `var' = subinstr(`var', "@", " ", .)
	replace `var' = subinstr(`var', "-", " ", .)
	replace `var' = subinstr(`var', "`", "", .)
	replace `var' = subinstr(`var', "=", "", .)
	replace `var' = subinstr(`var', "", "", .)
	replace `var' = subinstr(`var', "?", "", .)

	replace `var' = " " + `var' + " "
	
	local most_common_words "llc inc incorporated the company corporation s amp co c p corp plc ltd ag na limited companies"

	foreach word in `most_common_words' {
		di "`word'"
		replace `var' = subinstr(`var', " `word' ", " ", .)
	}

	replace `var' = subinstr(`var', "  ", " ", .)
	replace `var' = subinstr(`var', "  ", " ", .)
	replace `var' = subinstr(`var', "  ", " ", .)
	replace `var' = subinstr(`var', "  ", " ", .)
	replace `var' = subinstr(`var', "  ", " ", .)
	replace `var' = subinstr(`var', "  ", " ", .)
	replace `var' = strtrim(`var')
	
end

* RR companies
import delimited "$data_directory/RR_companies.csv", varnames(1) clear
rename company_id company_id_RR

gen clientname_clean = lower(clientname1)
clean_companyname clientname_clean

duplicates drop company_id clientname_clean, force

duplicates drop

save "$data_directory/RR_companies"

use "$data_directory/company_names"

split CompanyName, parse("(")
gen CompanyName_clean = strtrim(lower(CompanyName1))
clean_companyname CompanyName_clean
keep companyid CompanyName CompanyName_clean

matchit companyid CompanyName_clean using "$data_directory/RR_companies.dta", idusing(company_id_RR) txtusing(clientname_clean) override

gsort clientname_clean -similscore

save "$data_directory/RR_fullmatch"

egen max_similscore = max(similscore), by(clientname_clean)
drop if max_similscore == 1 & similscore != 1

gen match = .
replace match = 1 if similscore == 1
egen max_match = max(match), by( company_id_RR )
drop if max_match == 1 & match != 1

drop if similscore < 0.8

save "$data_directory/RR_matches", replace

* stopped at obs 738

drop if match != 1
drop max_match
save "$data_directory/RR_matches_manual", replace

**
use "W:\rsadun_burning_glass_project\NLE Work\RR/updated_RR_clean_companies", clear
*destring company_id, replace
*merge m:1 company_id using "covariates/CIQ_RR_key"

split clientname, parse("(")
replace clientname1 = strtrim(clientname1)
replace clientname1 = subinstr(clientname1, "  ", " ", .)
keep clientname clientname1 year document_id
rename document_id job_id

replace clientname1 = "AIG Insurance Management Services, Inc" if job_id == 2191007
replace clientname1 = "Village Roadshow Gold Class Cinemas LLC" if job_id == 2305645

keep clientname clientname1
duplicates drop
duplicates drop clientname1, force

save "W:\rsadun_burning_glass_project\NLE Work\RR\clientname_to_clientname1"
**

use "$data_directory/RR_matches_manual", clear
merge m:1 companyid using "$data_directory/company_names"
drop if _merge == 2
drop _merge
rename company_id_RR company_id
merge m:1 company_id clientname_clean using "$data_directory/RR_companies"
drop if _merge == 2
drop _merge
merge m:1 clientname1 using "W:\rsadun_burning_glass_project\NLE Work\RR\clientname_to_clientname1"
drop if _merge == 2
drop _merge
gsort company_id -similscore
bysort company_id: gen num_matches = _N
gsort company_id -similscore
browse if num_matches > 1
gen match2 = .

save "$data_directory/RR_matches_refined"

* manual check
replace match2 = 1 if num_matches == 1
keep if match2 == 1
save "$data_directory/RR_matches_final"

use "$data_directory/c_suite_data2_exp", clear
global positions "pos_Chair pos_CAcc pos_CAO pos_CAE pos_CBank pos_CBrand pos_CBus pos_CComm pos_CCommunication pos_CCO_comp pos_CCO_cont pos_CCounsel pos_CCreat pos_CCredit pos_CCustom pos_CDev pos_CDigit pos_CDO pos_CDiv pos_CEO pos_CEthics pos_CFO pos_CGov pos_CHRO pos_CInnov pos_CIO pos_CInvest pos_CKO pos_CLegal pos_CMO pos_CMed pos_CMerch pos_COO pos_CPO pos_CProcure pos_CRev pos_CRisk pos_CSales pos_CSci pos_CSO_sec pos_CStaff pos_CStrat pos_CSO_sus pos_CSupp pos_CTal pos_CTax pos_CTO"

duplicates drop RoleName CompanyID year, force
mark co if strpos(RoleName, "Co-")

collapse (rawsum) pos* co (count) num_people=has_pos, by(year CompanyID)
foreach position in $positions {
	
	replace `position' = 1 if `position' > 0
	
}

egen num_positions = rowtotal($positions pos_Chief)
rename co num_co

save "$data_directory/data_by_companyid_year", replace

use "$data_directory/RR_matches_final", clear

keep companyid company_id clientname1 num_pos

forvalues y=2000/2020 {
	
	gen temp`y' = 1
	
}

reshape long temp, i(companyid company_id clientname1) j(year)
drop temp
rename companyid CompanyID

merge m:1 CompanyID year using "$data_directory/data_by_companyid_year"
drop if _merge == 2

collapse (rawsum) pos_Chief num_co num_people num_positions, by( company_id clientname1 year)
collapse (rawsum) pos_Chief num_co num_people num_positions, by(clientname1 year)

foreach var in pos_Chief num_co num_people num_positions {
	
	replace `var' = . if num_positions == 0
	
}

reshape wide pos_Chief num_co num_people num_positions, i(clientname1) j(year)

replace clientname1 = subinstr(clientname1, "  ", " ", .)

save "W:\rsadun_burning_glass_project\NLE Work\covariates\boardex_company_data", replace

cd "W:\rsadun_burning_glass_project\NLE Work\"
use "RR/updated_RR_clean_companies", clear
*destring company_id, replace
*merge m:1 company_id using "covariates/CIQ_RR_key"

split clientname, parse("(")
replace clientname1 = strtrim(clientname1)
replace clientname1 = subinstr(clientname1, "  ", " ", .)
keep clientname clientname1 year document_id
rename document_id job_id

replace clientname1 = "AIG Insurance Management Services, Inc" if job_id == 2191007
replace clientname1 = "Village Roadshow Gold Class Cinemas LLC" if job_id == 2305645

merge m:1 clientname1 using "covariates/boardex_company_data"
drop _merge clientname year clientname1

reshape long pos_Chief num_co num_people num_positions, i(job_id) j(year)

save "W:\rsadun_burning_glass_project\NLE Work\covariates\boardex_jobid_data", replace
