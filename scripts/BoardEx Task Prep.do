drop if pos_Chief == 0
keep RoleName
duplicates drop
sort RoleName
split RoleName, gen(role) parse("/")
reshape long role, i(RoleName) j(number)
drop if role == ""
sort role
replace role = strtrim(role)
sort role
egen id = group( role)
save "$data_directory/roles_expanded", replace
keep role id
duplicates drop
order id role
save "$data_directory/c-suite_roles", replace
export delimited "$data_directory/c-suite_roles.csv"
