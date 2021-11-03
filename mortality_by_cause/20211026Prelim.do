/********** CREATING CCME DATA INCLUSIVE OF DEATHS IN 2015 TO PRESENT ************/

//Importing newest file of data from CCME?
import excel "O:\CRU\Keiki\RESEARCH PROJECTS\LOCAL PROJECTS\Medical Examiners Opioid Death Data\DATA\ALLCCMEDATA", sheet("Sheet1") firstrow case(lower) allstring clear
save "O:\Preventive Medicine\Homeless_Analysis\CCHEncounters202001-202109ForZ59.0&MRC\CCMEDATAtoMar2021", replace

//Adding updated records to our main record file
import excel "O:\Preventive Medicine\Homeless_Analysis\CCHEncounters202001-202109ForZ59.0&MRC\CCME Deaths.xlsx", sheet("Sheet1") firstrow case(lower) allstring clear
append using "O:\Preventive Medicine\Homeless_Analysis\CCHEncounters202001-202109ForZ59.0&MRC\CCMEDATAtoMar2021"

sort casenumber
quietly by casenumber: gen dup=cond(_N==1,0,_n)
tab dup
drop if dup>1
drop dup

save "O:\Preventive Medicine\Homeless_Analysis\CCHEncounters202001-202109ForZ59.0&MRC\CMEDATAtoOct2021", replace

/********** CCME CAUSE-SPECIFIC MORTALITY TREND ANALYSIS ******************/
use "O:\Preventive Medicine\Homeless_Analysis\CCHEncounters202001-202109ForZ59.0&MRC\CMEDATAtoOct2021", clear

replace primarycause=lower(primarycause)
gen overdose=1 if regexm(primarycause,"fentanyl")|regexm(primarycause,"tox")|regexm(primarycause,"alcohol")|regexm(primarycause,"ethanol")
gen alcohol=1 if regexm(primarycause,"alcohol")|regexm(primarycause,"ethanol")
gen accidentalinjury=1 if injury_description !="NULL"&manner=="ACCIDENT"
gen cvd=1 if regexm(primarycause,"cardio")|regexm(primarycause,"heart")|regexm(primarycause,"myocard")
gen pna=1 if regexm(primarycause,"pneum")
gen covid=1 if regexm(primarycause,"covid")|regexm(primarycause,"corona virus")
gen rf=1 if regexm(primarycause,"respiratory")
gen suicide=1 if manner=="SUICIDE"
gen homicide=1 if manner=="HOMICIDE"
gen opioid_forensic=1 if opioids=="Yes"
gen cold_forensic=1 if cold_related=="YES"

gen death_dt=date(death_date,"DMY")
replace death_dt=date(death_date,"DMYhms") if death_dt==.
format death_dt %td
gen death_mnth=mofd(death_dt)
format death_mnth %tm
gen death_yr=yofd(death_dt)
format death_yr %ty

#delimit;
preserve;
drop if death_dt<td(01jan2015);
collapse (sum) overdose alcohol accidentalinjury cvd pna covid rf suicide homicide opioid_forensic cold_forensic, by(death_mnth);
graph twoway line overdose alcohol accidentalinjury cvd pna covid rf suicide homicide opioid_forensic cold_forensic death_mnth;
list death_mnth overdose alcohol accidentalinjury cvd pna covid rf suicide homicide opioid_forensic cold_forensic;
graph twoway line covid alcohol opioid_forensic homicide accidentalinjury death_mnth;
graph twoway line pna covid rf cvd death_mnth;
graph twoway line overdose alcohol opioid_forensic cold_forensic death_mnth;
graph twoway line suicide homicide accidentalinjury death_mnth;
restore;

#delimit;
preserve;
drop if death_dt<td(01jan2015);
collapse (sum) overdose alcohol accidentalinjury cvd pna covid rf suicide homicide opioid_forensic cold_forensic, by(death_yr);
graph twoway line overdose alcohol accidentalinjury cvd pna covid rf suicide homicide opioid_forensic cold_forensic death_yr;
list death_yr overdose alcohol accidentalinjury cvd pna covid rf suicide homicide opioid_forensic cold_forensic;
graph twoway line pna covid rf cvd death_yr;
graph twoway line overdose alcohol opioid_forensic cold_forensic death_yr;
graph twoway line suicide homicide accidentalinjury death_yr;
restore;

/********** JOINING CCME 2020-2021 RECORD WITH CCH Z59.0 LIST *****************/
keep if death_yr>=2020
egen x=group(casenumber)
sum x /* N=25840 casenumbers */
drop x

gen decedent_first_name_cd=upper(decedent_first_name)
	replace decedent_first_name_cd=trim(decedent_first_name_cd)
	replace decedent_first_name_cd=subinstr(decedent_first_name_cd," ","",.)
	replace decedent_first_name_cd=subinstr(decedent_first_name_cd,"'","",.)
	replace decedent_first_name_cd=subinstr(decedent_first_name_cd,".","",.)
	replace decedent_first_name_cd=subinstr(decedent_first_name_cd,"-","",.)
gen decedent_last_name_cd=upper(decedent_last_name)
	replace decedent_last_name_cd=trim(decedent_last_name_cd)
	replace decedent_last_name_cd=subinstr(decedent_last_name_cd," ","",.)
	replace decedent_last_name_cd=subinstr(decedent_last_name_cd,"'","",.)
	replace decedent_last_name_cd=subinstr(decedent_last_name_cd,".","",.)
	replace decedent_last_name_cd=subinstr(decedent_last_name_cd,"-","",.)
	
gen firstname5=regexs(0) if(regexm(decedent_first_name_cd,"^[A-Z][A-Z][A-Z][A-Z][A-Z]"))
	replace firstname5=regexs(0) if(regexm(decedent_first_name_cd,"^[A-Z][A-Z][A-Z][A-Z]"))&firstname5==""
	replace firstname5=regexs(0) if(regexm(decedent_first_name_cd,"^[A-Z][A-Z][A-Z]"))&firstname5==""
	replace firstname5=regexs(0) if(regexm(decedent_first_name_cd,"^[A-Z][A-Z]"))&firstname5==""
	replace firstname5=regexs(0) if (regexm(decedent_first_name_cd,"^[A-Z]"))&firstname5==""
gen lastname5=regexs(0) if(regexm(decedent_last_name_cd,"^[A-Z][A-Z][A-Z][A-Z][A-Z]"))
	replace lastname5=regexs(0) if(regexm(decedent_last_name_cd,"^[A-Z][A-Z][A-Z][A-Z]"))&firstname5==""
	replace lastname5=regexs(0) if(regexm(decedent_last_name_cd,"^[A-Z][A-Z][A-Z]"))&firstname5==""
	replace lastname5=regexs(0) if(regexm(decedent_last_name_cd,"^[A-Z][A-Z]"))&lastname5==""
	replace lastname5=regexs(0) if(regexm(decedent_last_name_cd,"^[A-Z]"))&lastname5==""
	
gen dob=date(decedent_dob,"DMY")
	replace dob=date(decedent_dob,"DMYhms") if dob==.
format dob %td
gen dob_month=mofd(dob)
gen dob_year=yofd(dob)
format dob_month %tm
format dob_year %ty

rename decedent_first_name_cd first_name_cd
rename decedent_last_name_cd last_name_cd

sort firstname5 lastname5 dob
quietly by firstname5 lastname5 dob: gen dup=cond(_N==1,0,_n)
tab dup
drop dup

	
save "O:\Preventive Medicine\Homeless_Analysis\CCHEncounters202001-202109ForZ59.0&MRC\CMEDATAtoOct2021_forjoining", replace

import excel "O:\Preventive Medicine\Homeless_Analysis\CCHEncounters202001-202109ForZ59.0&MRC\CCH Encounters.xlsx", sheet("Sheet1") firstrow case(lower) clear

gen first_name_cd=upper(name_first)
	replace first_name_cd=trim(first_name_cd)
	replace first_name_cd=subinstr(first_name_cd," ","",.)
	replace first_name_cd=subinstr(first_name_cd,"'","",.)
	replace first_name_cd=subinstr(first_name_cd,".","",.)
	replace first_name_cd=subinstr(first_name_cd,"-","",.)
gen last_name_cd=upper(name_last)
	replace last_name_cd=trim(last_name_cd)
	replace last_name_cd=subinstr(last_name_cd," ","",.)
	replace last_name_cd=subinstr(last_name_cd,"'","",.)
	replace last_name_cd=subinstr(last_name_cd,".","",.)
	replace last_name_cd=subinstr(last_name_cd,"-","",.)

gen firstname5=regexs(0) if(regexm(first_name_cd,"^[A-Z][A-Z][A-Z][A-Z][A-Z]"))
	replace firstname5=regexs(0) if(regexm(first_name_cd,"^[A-Z][A-Z][A-Z][A-Z]"))&firstname5==""
	replace firstname5=regexs(0) if(regexm(first_name_cd,"^[A-Z][A-Z][A-Z]"))&firstname5==""
	replace firstname5=regexs(0) if(regexm(first_name_cd,"^[A-Z][A-Z]"))&firstname5==""
	replace firstname5=regexs(0) if (regexm(first_name_cd,"^[A-Z]"))&firstname5==""
gen lastname5=regexs(0) if(regexm(last_name_cd,"^[A-Z][A-Z][A-Z][A-Z][A-Z]"))
	replace lastname5=regexs(0) if(regexm(last_name_cd,"^[A-Z][A-Z][A-Z][A-Z]"))&firstname5==""
	replace lastname5=regexs(0) if(regexm(last_name_cd,"^[A-Z][A-Z][A-Z]"))&firstname5==""
	replace lastname5=regexs(0) if(regexm(last_name_cd,"^[A-Z][A-Z]"))&lastname5==""
	replace lastname5=regexs(0) if(regexm(last_name_cd,"^[A-Z]"))&lastname5==""
	
gen dob=birth_dt_tm
format dob %td
gen dob_month=mofd(dob)
gen dob_year=yofd(dob)
format dob_month %tm
format dob_year %ty

egen distinct_personid=group(person_id)
sum distinct_personid /* N=2281 distinct personid */
egen distinct_enc=group(fin_num)
sum distinct_enc /* N=14802 distinct fin_num */

#delimit;
preserve;
merge m:m lastname5 firstname5 dob_year using "O:\Preventive Medicine\Homeless_Analysis\CCHEncounters202001-202109ForZ59.0&MRC\CMEDATAtoOct2021_forjoining";
keep if _merge==3;
egen x=group(person_id);
sum x;

restore;

/* JOIN BY LASTNAME5 FIRSTNAME5 DOB_YEAR THEN EXCLUDING PATIENTS WITH RECORDED ENCOUNTERS AFTER DEATH DATE */
merge m:m lastname5 firstname5 dob_year using "O:\Preventive Medicine\Homeless_Analysis\CCHEncounters202001-202109ForZ59.0&MRC\CMEDATAtoOct2021_forjoining"
sort _merge person_id reg_dt

gen reg_dt=dofc(reg_dt_tm)
format reg_dt %td
gen false_flag=1 if reg_dt>death_dt
bysort person_id: egen false=max(false_flag)
replace _merge=1 if false==1&_merge !=2
drop false false_flag
tab _merge

#delimit;
preserve;
keep if _merge==3;
egen x=group(person_id);
sum x; /* N=48 person_id may have died in this group */
restore;


/* mortality rate = 48/2281 = 2104 per 100,000 */


tab primarycause if _merge==3, sort
gen deathcause=10 if primarycause !=""
	replace deathcause=1 if opioids=="Yes"
	replace deathcause=2 if overdose==1&opioids=="No"|alcohol==1
	replace deathcause=3 if cvd==1
	replace deathcause=4 if covid==1
	replace deathcause=5 if pna==1|rf==1|regexm(primarycause,"pulmonary")
	replace deathcause=6 if homicide==1
	replace deathcause=7 if suicide==1
	replace deathcause=8 if cold_related=="YES"
	replace deathcause=9 if primarycause=="pending"|primarycause=="null"
	label define deathcause_l 1 "opioids" 2 "other substance toxicity" 3 "cvd" 4 "covid" 5 "respiratory failure" 6 "homicide" 7 "suicide" 8 "cold related" 9 "null or pending" 10 "other"
	label val deathcause deathcause_l
	
#delimit;
preserve;
keep if _merge>1;
collapse deathcause _merge, by(casenumber);
label val deathcause deathcause_l;
label define _merge_l 2 "non CCH Z59.0" 3 "CCH Z59.0";
label val _merge _merge_l;
tab deathcause if _merge==3, sort;
tab deathcause _merge, col chi2;
