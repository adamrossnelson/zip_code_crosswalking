set more off
clear all
capture log close
log using zip_code_research_log.txt, text replace

// Record of building a list of zip codes to target for rural research.

// This file comes from:
// https://data.world/lukewhyte/us-population-by-zip-code-2010-2016/workspace/file?filename=pop-by-zip-code.csv
import delimited pop-by-zip-code.csv
rename ïzip_code zip_code
list in 1/5
list if zip_code == 54751
list if zip_code == 22204
save pop-by-zip-code.dta, replace
clear

// This file comes from:
// https://simplemaps.com/data/us-zips
import delimited uszips.csv
list in 1/5
save uszips.dta, replace
clear

// Merge the two datasets
use pop-by-zip-code.dta
rename zip_code zip
merge 1:1 zip using uszips.dta

// Limit data to Midwest States
keep if inlist(state_name,"Wisconsin","Illinois","Iowa", ///
                "Indiana","Ohio","Minnesota")

// Find 75th percential density of revion (low to moderate density)
preserve
sum density, detail
keep if density <= r(p75)
export delimited zip state_name density ///
using "low_moderate_density_midwest_zip_codes.csv", replace
restore
				
// Find median density of the region (low density)
sum density, detail

// Limit density to below median
keep if density <= r(p50)

// Save resulting list
export delimited zip state_name density ///
using "low_density_midwest_zip_codes.csv", replace

log close
