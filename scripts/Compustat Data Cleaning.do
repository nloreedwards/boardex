global data_directory "/Users/nlore-edwards/Dropbox (Harvard University)/BoardEx"
global working_directory "/Users/nlore-edwards/Documents/Git Repos/boardex"

cd "$working_directory"

* Clean Compustat data from WRDS
use "$data_directory/Compustat Global 8-30", clear

append using "$data_directory/Compustat US 8-30"

drop if isin == ""
collapse at emp revt, by(gvkey fyear exchg isin sedol conm fic stko indfmt consol popsrc datafmt tic cusip curcd cik costat naics sic)

rename fyear year

save "$data_directory/compustat", replace

* Clean Compustat-CRSP key from WRDS
use "$data_directory/compustat-crsp 8-30", clear

rename GVKEY gvkey
rename fyear year

save "$data_directory/compustat-crsp 8-30", replace

* Clean Compustat-BoardEx key from WRDS
use "$data_directory/boardex_compustat_key_clean", clear
forvalues y = 2000/2021 {
	
	mark year_`y'
	
}
reshape long year_, i(gvkey companyid1 companyid2) j(year)
drop year_
save "$data_directory/boardex_compustat_key_clean_year", replace

* Merge Compustat data with key
use "$data_directory/compustat-crsp 8-30", clear

merge m:1 gvkey year using "$data_directory/boardex_compustat_key_clean_year"
drop if _merge == 1

keep companyid* gvkey year datadate at emp revt naics sic
duplicates drop

* Add additional CapitalIQ key
destring gvkey, gen(gvkey1)
merge m:1 gvkey1 using "$data_directory/CIQ_to_GVKEY"
drop if _merge == 2
drop _merge gvkey1
reshape long companyid, i(gvkey year datadate at emp revt ciq1 ciq2 ciq3) j(set)

drop if companyid == .

* Take the modal industry and ID for each company
duplicates drop companyid revt emp at year, force

foreach var in naics sic ciq1 ciq2 ciq3 gvkey {
	egen mode_`var' = mode(`var'), by(companyid) maxmode
	replace `var' = mode_`var'
}

collapse (mean) revt emp at, by(companyid year gvkey naics sic ciq1 ciq2 ciq3)

save "$data_directory/compustat_bx_id 5-11-23", replace

* Merge in Compustat data to BoardEx
use "$data_directory/c_suite_data2_exp", clear
rename CompanyID companyid

merge m:1 companyid year using "$data_directory/compustat_bx_id 5-11-23"
mark compustat if _merge == 3
drop if _merge == 2
drop _merge

save "$data_directory/c_suite_data2_merged", replace


**** Code for RR-BoardEx Merge (not ultimately used)
use "C:\Users\nloreedwards\Dropbox (Harvard University)\RR_DB_Darwin\RR\RR_complete.dta" 
tab position
replace position = "CEO" if position == ""
keep company_id year_of_search company position ciq_ciq
duplicates drop
drop if ciqciq == ""
drop if ciq_ciq == ""
duplicates report company_id year_of_search position
duplicates report company_id year_of_search position ciq_ciq
duplicates drop company_id year_of_search position ciq_ciq, force
duplicates report company_id year_of_search position
duplicates drop company_id year_of_search position, force
by company_id year_of_search: gen position_index = _n
bysort company_id year_of_search: gen position_index = _n
reshape wide position, i(company_id year_of_search company ciq_ciq) j( position_index)
rename ciq_ciq CIQ
rename year_of_search year
save "X:\Documents\BoardEx\data\rr_companies_ciq"

use "C:\Users\nloreedwards\Dropbox (Harvard University)\RR_DB_Darwin\RR\RR_complete.dta", clear
replace position = "CEO" if position == ""
keep company_id year_of_search company position ciq_ciq
duplicates drop
drop if ciq_ciq == ""
keep ciq_ciq year_of_search position
bysort ciq_ciq year_of_search: gen position_index = _n
reshape wide position, i( year_of_search ciq_ciq) j( position_index)
rename ciq_ciq CIQ
rename year_of_search year
save "X:\Documents\BoardEx\data\rr_companies_ciq_year", replace

use "C:\Users\nloreedwards\Dropbox (Harvard University)\RR_DB_Darwin\RR\RR_complete.dta", clear
replace position = "CEO" if position == ""
keep company_id company position ciq_ciq
duplicates drop
drop if ciq_ciq == ""
keep ciq_ciq position
bysort ciq_ciq: gen position_index = _n
reshape wide position, i(ciq_ciq) j( position_index)
rename ciq_ciq CIQ
save "X:\Documents\BoardEx\data\rr_companies_ciq", replace

use "$data_directory/c_suite_data2_merged", clear

forvalues i=1/3 {
	gen CIQ = ciq`i'
	merge m:1 CIQ year using "$data_directory/rr_companies_ciq_year", update
	drop if _merge == 2
	drop _merge CIQ
}


use "$data_directory/c_suite_data2_merged", clear

forvalues i=1/3 {
	gen CIQ = ciq`i'
	merge m:1 CIQ using "$data_directory/rr_companies_ciq", update
	drop if _merge == 2
	drop _merge CIQ
}


/*
gen match_position = 0

forvalues i = 1/3 {
	replace match_position =  match_position + 1 if position`i' == "CEO" & pos_CEO == 1
	replace match_position =  match_position + 1 if position`i' == "CFO" & pos_CFO == 1
	replace match_position =  match_position + 1 if position`i' == "CHRO" & pos_CHRO == 1
	replace match_position =  match_position + 1 if position`i' == "CIO" & pos_CIO == 1
	replace match_position =  match_position + 1 if position`i' == "CISO" & pos_CIO == 1
	replace match_position =  match_position + 1 if position`i' == "CMO" & pos_CMO == 1
	replace match_position =  match_position + 1 if position`i' == "CTO" & pos_CTO == 1
	replace match_position =  match_position + 1 if position`i' == "CDO" & pos_CDO == 1
}
*/
