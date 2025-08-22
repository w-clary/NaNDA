/* 	validate_voting_county_2018-0222.do
	gypin 09/20/2023: Ran for nanda_voting_County20_2018-2022.dta
*/
local version "01"					/* 2-digit version # */
local filestring "voting"			/* up to 8 characters, matches filename */
local geolevel "county"				/* tract, zcta, county, etc. */
local daterange "2018-2022"			/* date range */
local workdir "O:\NaNDA\Data\voting\voting_county_2018-2022"			
									/* complete file path incl O:\NaNDA\Data */
local sourcefile "nanda_voting_County20_2018-2022.dta"			
									/* name of file in workfiles_received */

* additional macros are built off the components above and should not change
local date: display %tdCY-N-D td(`c(current_date)')
local logfile = "code\validate_" + "`filestring'" + "_" + "`geolevel'" + "_" + "`daterange'" + "_" + "`date'" + ".log"
local workfile = "datasets\workfiles_received\" + "`sourcefile'"

capture log close
cd `workdir'
log using `logfile', replace

******************************************************************************
*Load working dataset
pwd
use `workfile', clear
display "`workfile'"

******************************************************************************
* Dataset exploration & common validation checks

describe, fullnames

* NAMES AND LABELS (is it clear what they represent? should anything be renamed or relabeled for clarity? are units obvious?)
Everything needs to be renamed and relabeled. 

* reminder of standard names for geographic units
* stcofips10


* VALUE LABELS (do any variables have value labels? what are they?)
label list
none


* NAME/LABEL FORMAT PROBLEMS (is anything named inconsistently or formatted poorly?)
year is an integer. I think we usually have it as a string. 

* DATA TYPES (are they appropriate for what we're storing?)
several variables are longs and I think should be recast as floats.

* NUMBER OF OBSERVATIONS
* counties & equivalents should be 3,143
seems pretty solid! 

summarize


* LEADING ZEROS

* all county fips codes should be text format and 5 digits long
describe fips
generate countylen = strlen(fips)
tab countylen

this is correct!  woot woot.

* STATES/REGIONS REPRESENTED

* for census tracts and counties: we can check state
* 02 Alaska 125
* 15 Hawaii 15
* 72 Puerto Rico 234
* 78 Virgin Islands n/a
generate state = substr(fips, 1, 2)
tab state

* MISSINGNESS
ssc install mdesc
mdesc
* do any variables have an unusually high level of missing?
I don't think so?


* OUTLIER VALUES
* considering what they are, do any variables seem to have unusual max, min, or average values?



* VARIABLE RELATIONSHIPS
* are there variables whose values ought to relate to one another (for example, sums or ratios), and do they do so as expected?
Seems fine.


log close