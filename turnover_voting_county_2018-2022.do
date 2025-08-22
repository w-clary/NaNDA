/* 	turnover_voting_county_d2018-2022.do
	clary 09/20/2024: nanda_voting_County20_2018-2022.dta
*/

* Parameters - update each time the script is run
local version "02"					/* 2-digit version # */
local filestring "voting"			/* up to 8 characters, matches filename */
local geolevel "county"				/* tract, zcta, county, etc. */
local daterange "2018-2022"			/* date range */
local workdir "O:\NaNDA\Data\voting\voting_county_2018-2022"			
									/* complete file path incl O:\NaNDA\Data */
local sourcefile "nanda_voting_County20_2018-2022.dta"			
									/* name of file in workfiles_received */

* additional macros are built off the components above and should not change
local logfile = "code\turnover_" + "`filestring'" + "_" + "`geolevel'" + "_" + "`daterange'" + "_" + "`version'" + ".log"
local workfile = "datasets\workfiles_received\" + "`sourcefile'"
local curatedfile = "datasets\nanda_" + "`filestring'" + "_" + "`geolevel'" + "_" + "`daterange'" + "_" + "`version'" + ".dta"
local dictionary1 = "documentation\nanda_" + "`filestring'" + "_" + "`geolevel'" + "_" + "`daterange'" + "_" + "`version'" + "_codebook.log"
* local dictionary2 = "documentation\nanda_" + "`filestring'" + "_" + "`geolevel'" + "_" + "`daterange'" + "_" + "`version'" + "_describe.log"
local dictionary2 = "documentation\nanda_" + "`filestring'" + "_" + "`geolevel'" + "_" + "`daterange'" + "_" + "`version'" + "_data_dictionary.xlsx"

capture log close
cd `workdir'
log using `logfile', replace
set linesize 120

****************************************************************************
* Section 1: Load working dataset
pwd
use `workfile', clear
display "`workfile'"

****************************************************************************
* Section 2: Curation stuff
* order variables in a way that makes sense:
* voter turnout components, voter turnout ratios, partisanship components, partisanship ratios
order fips year, before(a1a)
order cvap, after(f1a)
order reg_pct voterturnout balreg, after(cvap)
order candidatevotes_dv candidatevotes_rv, after(balreg)
order partisanship_dem_senate, after(partisanship_rep_presidential)
order partyindexdem partyindexrep, after(partisanship_rep_senate)

* sort by year then FIPS
sort year fips

* rename variables
rename fips stcofips20
rename a1a reg_voters
rename f1a ballots_cast
rename reg_pct reg_voters_pct
rename voterturnout voter_turnout_pct
rename balreg reg_voter_turnout_pct
rename candidatevotes_dv pres_dem_votes
rename candidatevotes_rv pres_rep_votes
rename uss_dv sen_dem_votes
rename uss_rv sen_rep_votes
rename partisanship_dem_presidential pres_dem_ratio
rename partisanship_rep_presidential pres_rep_ratio
rename partisanship_dem_senate sen_dem_ratio
rename partisanship_rep_senate sen_rep_ratio
rename partyindexdem partisan_index_dem
rename partyindexrep partisan_index_rep

describe 

* label variables
label variable stcofips20 "County FIPS code"
label variable year "Year"
label variable reg_voters "# registered voters"
label variable ballots_cast "Ballots cast in general election, all races"
label variable cvap "Citizen voting age population"
label variable reg_voters_pct "% eligible voters registered (reg_voters / cvap), top coded"
label variable voter_turnout_pct "% eligible voters casting ballots (ballots_cast / cvap), top coded"
label variable reg_voter_turnout_pct "% registered voters casting ballots (ballots_cast / reg_voters), top coded"
label variable pres_dem_votes "# votes for Democratic presidential candidate"
label variable pres_rep_votes "# votes for Republican presidential candidate"
label variable sen_dem_votes "# votes for Democratic senate candidate"
label variable sen_rep_votes "# votes for Republican senate candidate"
label variable pres_dem_ratio "% votes for Democratic presidential candidate"
label variable pres_rep_ratio "% votes for Republican presidential candidate"
label variable sen_dem_ratio "% votes for Democratic senate candidate"
label variable sen_rep_ratio "% votes for Republican senate candidate"
label variable partisan_index_dem "Democratic partisanship index (% votes cast, past 6 years)"
label variable partisan_index_rep "Republican partisanship index (% votes cast, past 6 years)"

* change data type of variables
* Leaving as is to be consistent with previous version of dataset.

* Drop Duplicates
tab year
codebook stcofips20
sort stcofips20 year
quietly by stcofips20 year: gen dup = cond(_N==1,0,_n)
drop if dup>1

****************************************************************************
* Section 3: QA
describe
summarize

*****************************************************************************
* Section 4: apply standard naming convention
save `curatedfile'
log close

****************************************************************************
* Section 5: create data dictionary

* Export compact codebook
log using `dictionary1'
codebook, compact
log close

* Export description
/*
log using `dictionary2'
describe
log close
*/
log using `logfile', append

describe, replace clear
keep name type varlab
rename name Variable
rename type Type
rename varlab Label

export excel using `dictionary2', firstrow(variables) replace

log close
