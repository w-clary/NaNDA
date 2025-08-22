use "O:\NaNDA\Data\voting\voting_county_2018-2022\datasets\nanda_voting_county_2018-2022_01.dta"

tab year

codebook stcofips20

sort stcofips20 year

quietly by stcofips20 year: gen dup = cond(_N==1,0,_n)
drop if dup>1