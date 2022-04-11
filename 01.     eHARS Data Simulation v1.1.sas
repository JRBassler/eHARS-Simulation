
/*=========================================================================*/
*	PROGRAM NAME:	eHARS Data Simulation v#.#		 					 	;	
*																		    ;
*	PROJECT TITLE:	Road to Zero										 	;
*																		    ;
*	DESCRIPTION:	To create eHARS data sets to test program development	;
*					remotely, before final testing at public health		 	;
*					departments											 	;
*																		    ;
*	GRANT SUPPORT:														 	;
*		NIH/NHAID	R01AI142690											 	;
*		UAB CFAR	P30 AI027767-31										 	;
*																		    ;
*	CREATED BY:		John Bassler										 	;
*	CONTACT INFO: 	jbassle1@uab.edu									 	;
*																		    ;
*	PURPOSE:		The success of Ending the HIV Epidemic: A Plan for 	 	;
*					America or (EHE) will depend on innovative, targeted,	; 
*					population specific interventions. Achieving early 	 	;
*					and sustained viral suppression following diagnosis  	;
*					of HIV infection is critical to improving outcomes 	 	;
*					for persons living with HIV and reducing 			 	;
*					transmission.  A deeper understanding of the 		 	;
*					socio-contextual factors driving geographic 		 	;
*					variability of VS can also guide the development of  	;
*					evidence-informed public health approaches to achieve	;
*					timely individual and population viral control. This 	;
*					simulation is designed to randomly create realistic  	;
*					geographic components that could exist in eHARS data 	;
*					for each state, while accounting for the variability 	;
*					in this data that occurs over time. The simulated 	 	;
*					data created in this program can allow for researchers	;
*					to troubleshoot development of analytic methods, 	 	;
*					while reducing the time needed from their public 	 	;
*					health department partners.							 	;
*																		    ;
*	OPERATING SYSTEM COMPATIBILITY:										 	;
* 	UNIX SAS v9.4M3-M6 		YES										 	 	;
* 	PC SAS   v9.4M3-M6      YES											 	;
*																		    ;
*	DATE CREATED:	08/01/2019											 	;
*	DATE UPDATED:	04/06/2022											 	;
*																		    ;
*	VERSION UPDATES:													 	;
*			1.1		The 'dates4' data set has been updated to establish  	;
*					more sample dates for simulated observations that are 	;
*					diagnosed in 2019. This allows for a more robust 		;
*					simulation of viral load and cd4 counts for those		;
*					same observations.										;
*																		    ;
*					To reduce the calculation of time to viral suppression, ;
*					simulated observations that do not have a date of death	;
*					or date of stage 3 diagnosis, will hsve each subsequent ;
*					date after hiv diagnosis date reduced 					;
*																		    ;
*					Major update - Revamp of method used to simulate address;
*					data to be included. Program has been cleaned and 		;
*					additional comments have been added in preparation for	;
*					manuscript submission that refers to the creation of	;
*					the simulation related programs.						;
*																		    ;
*	DISCLAIMER		This program is free to use, redistribute, and/or 	 	;
*					modify under the terms of the GNU General Public  	 	;
*					License, published by the Free Software Foundation.  	;
*					See the GNU General Public License for more details. 	;
*																		    ;
*					https://www.gnu.org/licenses/gpl-3.0.en.html		 	;
*																		    ;
*					This program is distributed with hope that you will	 	;
*					find it useful, and is open for collaboration. 		 	;
*					Please note that while distributed in good faith,  	 	;
*					this program is WITHOUT ANY WARRANTY - without even  	;
*					the implied warranty of MERCHANTABILITY or FITNESS 	 	;
*					FOR A PARTICULAR PURPOSE. 							 	;
*																		    ;
/*=========================================================================*/


/* Number of unique observations to begin simulation */
%let NSIM 				=	180000;  


/* Change seed values with every iteration of simulation */
%let SEED_01			=	20030;  
%let SEED_02			=	20031;
%let SEED_03			=	20032;
%let SEED_04			=	20033;
%let SEED_05			=	20034;
%let SEED_06			=	20035;


/*=============================    NOTE    ================================*/
/* These global macros will eventually be the variables of a macro that    */
/* wraps around this entire program. With this being the first version	   */
/* of this simulation code, and anticipating that improvements will be 	   */
/* made, the macro version of this program will be created at a later 	   */
/* date. Until then, although tedious, the global macro variables will	   */
/* enable users to create multiple versions of eHARS data, if needed. This */
/* also gives users two options for increasing the sample size - either	   */
/* by increasing NSIM (which could exponentially increase compiling time)  */
/* or by re-running the program and changing the SEEDS and DATA SET		   */
/* options.																   */
/*=========================================================================*/


/* This is in place of the libref that is used at health department 		*/
/* This is the same location (for simulation purposes) that the simulated	*/
/* address data set is saved in												*/
libname doc 	"C:\Users\johnr\OneDrive\Desktop\Work\Road to Zero\Work";

/****** This data set is only used is for creating spatial/geographic 		*/
/*		variables. Please download the data set and save to a directory		*/
/*		in order to run code. The code used to create this address data 	*/
/*		set is also available.												*/
%let address_sim			=	doc.address_sim;

/* Change eHARS data set names with every iteration of simulation */
%let ADDRESS			=	doc.ADDRESS;
%let CALC_OBSERVATION	=	doc.CALC_OBSERVATION;
%let DEATH				=	doc.DEATH;
%let DOCUMENT			=	doc.DOCUMENT;
%let FACILITY_CODE		=	doc.FACILITY_CODE;
%let FACILITY_EVENT		=	doc.FACILITY_EVENT;
%let LAB				=	doc.LAB;
%let PERSON				=	doc.PERSON;


/* States included in analysis */
%let STATE_1 = AL;
%let STATE_2 = MS;
%let STATE_3 = LA;

/*======================================================================*/
/*	This data step is used to compartmentalize the simulation structure */
/*	The overall strategy is to create random numbers for each 			*/
/*	observation, and then in the next data step assign values 			*/
/*	to the randomly generated data, and then finally, convert those 	*/
/*	variables to the prescribed length and format assigned in eHARS 	*/
/*======================================================================*/

data data;
	/*  starting point for id's, randomly chosen */
	uid = 10268497076; * randomly selected, number has no meaning;
	/*	count variable is used in the backend of entire program to merge data sets together */
	count = 0;
	retain count;

	call streaminit(&SEED_01); 
	do i = 1 to &NSIM;
		uid	+ 1; *change id number;
		document_type_cd				=	'000';
		af_facility_uid					=   '';
		hf_facility_uid					=   '';
		death_underlying_icd_cd			=  	'';
		death_underlying_icd_cd_type	=  	'';
	
		/*	generate state_cd for RTZ partners (Alabama, Mississippi, & Louisiana) */
		sim_state_cd = int(ranuni(99)*3);
			 if sim_state_cd = 0  then state_cd2 = "&STATE_1.";
		else if sim_state_cd = 1  then state_cd2 = "&STATE_2.";
		else if sim_state_cd = 2  then state_cd2 = "&STATE_3.";
	
		/*	uniform distribution used, but most likely does not represent 	*/
		/*	the distribution of actual eHARS data. This distriubution is 	*/
		/*	used for simplicity, and the probabilities are made such that 	*/
		/*	each possible value that appears in eHARS is represented 		*/
		/*	For instance, we know that race is not uniformly distributed, 	*/
		/*	but ensure that all possibilties are being simulated, the 		*/
		/*	uniform distribution application is useful 						*/
		sim_aids_insurance 	= 	int(ranuni(100)*17);
		sim_birth_sex		= 	rand("Table", 0.33, 0.33, 0.33);
		sim_current_gender	= 	rand("Table", 0.17, 0.17, 0.17, 0.17, 0.17, 0.17);
		sim_education 		= 	int(ranuni(101)*8);
		sim_hiv_insurance 	= 	int(ranuni(102)*17);
		sim_hars_race		= 	rand("Table", 0.111, 0.111, 0.111, 0.111, 
											  0.111, 0.111, 0.111, 0.111, 0.111);
		sim_trans_categ 	= 	int(ranuni(103)*17);
		sim_status_flag		= 	rand("Table", 0.143, 0.143, 0.143, 0.143, 0.143, 
											  0.143, 0.143);
		sim_address_type_cd = 	rand("Table", 0.083, 0.083, 0.083, 0.083, 0.083, 
											  0.083, 0.083, 0.083, 0.083, 0.083, 
											  0.083, 0.083);
	 	count + 1;
	output; 
	end;
run;


/*======================================================================*/
/*	The PERSON_VIEW data set is created by combining variables of 		*/
/*	various individual eHARS data sets. instead of re-creating each 	*/
/*	data set, we will begin by creating this data set, and then using	*/
/*	this as the foundation for the data sets this it is created with. 	*/
/*	Additionally, this maintains consistency if these data sets are		*/
/*	then later, merged together											*/
/*======================================================================*/


data person_view_sim;
	/* length and label for each variable is assigned based on eHARS data dictionary */
	length	hf_facility_uid					$16.
			af_facility_uid					$16.
			document_type_cd				$3.
			aids_insurance					$2.
			birth_sex						$1.				
			current_gender					$2.
			death_underlying_icd_cd			$7.
			death_underlying_icd_cd_type	$2.
			education						$1.
			hiv_insurance					$2.
			race							$1.
			rsa_address_type_cd				$3.
			rsh_address_type_cd				$3.
			trans_categ						$2.
			status_flag						$1.		;

	label	hf_facility_uid		=	"The unique identifier (eHARS assigned) of facility at HIV diagnosis"
			af_facility_uid		=	"The unique identifier (eHARS assigned) for the facility where AIDS (HIV, stage 3) was diagnosed"
			document_type_cd	=	"A code indicating the type of document"
			aids_insurance		=	"At the time of AIDS (HIV, satge 3) diagnosis, the persons primary reimbursement source for medical treatment"
			birth_sex			=	"The patients sex at birth."
			current_gender		=	"The patients current gender"
			death_underlying_icd_cd			=	"The ICD code for the patients underlying cause of death"
			death_underlying_icd_cd_type	=	"The type of ICD code (ICD-9 or ICD-10) used for the patients underlying cause of death"
			education			=	"The patients educational status"
			hiv_insurance		=	"Primary reimbursement type for the patient’s HIV medical treatment at the time of HIV diagnosis"
			race				=	"Race"
			rsa_address_type_cd =	"A code indicating the type of address reported for the residence at Stage 3 (AIDS) diagnosis, such as BAD, POS (postal) or RES (residential)."
			rsh_address_type_cd = 	"A code indicating the type of address reported for the residence at HIV infection diagnosis, such as BAD, POS (postal) or RES (residential)."
			trans_categ			=	"This calculated variable represents HIV exposure, based on a group of risk behaviors. The risk factors are grouped by adult and pediatric, based on the patients age at diagnosis of HIV."
			status_flag			=	"Person View status";

	set data(rename = (state_cd2 = state_cd));

	/*	Create aids_insurance variable */
		 if sim_aids_insurance = 0  then aids_insurance = '01';
	else if sim_aids_insurance = 1  then aids_insurance = '02';
	else if sim_aids_insurance = 2  then aids_insurance = '03';
	else if sim_aids_insurance = 3  then aids_insurance = '04';
	else if sim_aids_insurance = 4  then aids_insurance = '05';
	else if sim_aids_insurance = 5  then aids_insurance = '06';
	else if sim_aids_insurance = 6  then aids_insurance = '07';
	else if sim_aids_insurance = 7  then aids_insurance = '08';
	else if sim_aids_insurance = 8  then aids_insurance = '09';
	else if sim_aids_insurance = 9 then aids_insurance = '10';
	else if sim_aids_insurance = 10 then aids_insurance = '11';
	else if sim_aids_insurance = 11 then aids_insurance = '12';
	else if sim_aids_insurance = 12 then aids_insurance = '13';
	else if sim_aids_insurance = 13 then aids_insurance = '14';
	else if sim_aids_insurance = 14 then aids_insurance = '15';
	else if sim_aids_insurance = 15 then aids_insurance = '88';
	else if sim_aids_insurance = 16 then aids_insurance = '99';

	/*	Create current_gender variable */
		 if sim_current_gender = 1 then current_gender = 'AD';
	else if sim_current_gender = 2 then current_gender = 'F';
	else if sim_current_gender = 3 then current_gender = 'FM';
	else if sim_current_gender = 4 then current_gender = 'M';
	else if sim_current_gender = 5 then current_gender = 'MF';
	else if sim_current_gender = 6 then current_gender = 'U';

	/*	Create birth_sex variable */
		 if sim_birth_sex = 1 then birth_sex = 'F';
	else if sim_birth_sex = 2 then birth_sex = 'M';
	else if sim_birth_sex = 3 then birth_sex = 'U';

	/*	Create education variable */
		 if sim_education = 0 then education = '1';
	else if sim_education = 1 then education = '2';
	else if sim_education = 2 then education = '3';
	else if sim_education = 3 then education = '4';
	else if sim_education = 4 then education = '5';
	else if sim_education = 5 then education = '6';
	else if sim_education = 6 then education = '7';
	else if sim_education = 7 then education = '9';

	/*	Create hiv_insurance variable */
		 if sim_hiv_insurance = 0  then hiv_insurance = '01';
	else if sim_hiv_insurance = 1  then hiv_insurance = '02';
	else if sim_hiv_insurance = 2  then hiv_insurance = '03';
	else if sim_hiv_insurance = 3  then hiv_insurance = '04';
	else if sim_hiv_insurance = 4  then hiv_insurance = '05';
	else if sim_hiv_insurance = 5  then hiv_insurance = '06';
	else if sim_hiv_insurance = 6  then hiv_insurance = '07';
	else if sim_hiv_insurance = 7  then hiv_insurance = '08';
	else if sim_hiv_insurance = 8  then hiv_insurance = '09';
	else if sim_hiv_insurance = 9 then hiv_insurance = '10';
	else if sim_hiv_insurance = 10 then hiv_insurance = '11';
	else if sim_hiv_insurance = 11 then hiv_insurance = '12';
	else if sim_hiv_insurance = 12 then hiv_insurance = '13';
	else if sim_hiv_insurance = 13 then hiv_insurance = '14';
	else if sim_hiv_insurance = 14 then hiv_insurance = '15';
	else if sim_hiv_insurance = 15 then hiv_insurance = '88';
	else if sim_hiv_insurance = 16 then hiv_insurance = '99';

	/*	Create race variable */
		 if sim_hars_race = 1 then race = '1';
	else if sim_hars_race = 2 then race = '2';
	else if sim_hars_race = 3 then race = '3';
	else if sim_hars_race = 4 then race = '4';
	else if sim_hars_race = 5 then race = '5';
	else if sim_hars_race = 6 then race = '6';
	else if sim_hars_race = 7 then race = '7';
	else if sim_hars_race = 8 then race = '8';
	else if sim_hars_race = 9 then race = '9';

	/*	Create trans_categ variable */
		 if sim_trans_categ = 0  then trans_categ = '01';
	else if sim_trans_categ = 1  then trans_categ = '02';
	else if sim_trans_categ = 2  then trans_categ = '03';
	else if sim_trans_categ = 3  then trans_categ = '04';
	else if sim_trans_categ = 4  then trans_categ = '05';
	else if sim_trans_categ = 5  then trans_categ = '06';
	else if sim_trans_categ = 6  then trans_categ = '07';
	else if sim_trans_categ = 7  then trans_categ = '08';
	else if sim_trans_categ = 8  then trans_categ = '09';
	else if sim_trans_categ = 9  then trans_categ = '10';
	else if sim_trans_categ = 10 then trans_categ = '11';
	else if sim_trans_categ = 11 then trans_categ = '12';
	else if sim_trans_categ = 12 then trans_categ = '13';
	else if sim_trans_categ = 13 then trans_categ = '18';
	else if sim_trans_categ = 14 then trans_categ = '19';
	else if sim_trans_categ = 15 then trans_categ = '20';
	else if sim_trans_categ = 16 then trans_categ = '99';

	/*	Create address_type_cd variable */
	 	 if sim_address_type_cd = 1  then address_type_cd = 'BAD';
	else if sim_address_type_cd = 2  then address_type_cd = 'COR';
	else if sim_address_type_cd = 3  then address_type_cd = 'FOS';
	else if sim_address_type_cd = 4  then address_type_cd = 'HML';
	else if sim_address_type_cd = 5  then address_type_cd = 'POS';
	else if sim_address_type_cd = 6  then address_type_cd = 'RAD';
	else if sim_address_type_cd = 7  then address_type_cd = 'RBI';
	else if sim_address_type_cd = 8  then address_type_cd = 'RES';
	else if sim_address_type_cd = 9  then address_type_cd = 'SHL';
	else if sim_address_type_cd = 10 then address_type_cd = 'TMP'; 
	else if sim_address_type_cd = 11 then address_type_cd = 'RSA';
	else if sim_address_type_cd = 12 then address_type_cd = 'RSH'; 

	/*	Create rsa_address_type_cd variable */
	 	 if sim_address_type_cd = 1  then rsa_address_type_cd = 'BAD';
	else if sim_address_type_cd = 2  then rsa_address_type_cd = 'COR';
	else if sim_address_type_cd = 3  then rsa_address_type_cd = 'FOS';
	else if sim_address_type_cd = 4  then rsa_address_type_cd = 'HML';
	else if sim_address_type_cd = 5  then rsa_address_type_cd = 'POS';
	else if sim_address_type_cd = 6  then rsa_address_type_cd = 'RAD';
	else if sim_address_type_cd = 7  then rsa_address_type_cd = 'RBI';
	else if sim_address_type_cd = 8  then rsa_address_type_cd = 'RES';
	else if sim_address_type_cd = 9  then rsa_address_type_cd = 'SHL';
	else if sim_address_type_cd = 10 then rsa_address_type_cd = 'TMP'; 
	else if sim_address_type_cd = 11 then rsa_address_type_cd = 'RSA';
	else if sim_address_type_cd = 12 then rsa_address_type_cd = 'RSH'; 

	/*	Create rsh_address_type_cd variable */
	 	 if sim_address_type_cd = 1  then rsh_address_type_cd = 'BAD';
	else if sim_address_type_cd = 2  then rsh_address_type_cd = 'COR';
	else if sim_address_type_cd = 3  then rsh_address_type_cd = 'FOS';
	else if sim_address_type_cd = 4  then rsh_address_type_cd = 'HML';
	else if sim_address_type_cd = 5  then rsh_address_type_cd = 'POS';
	else if sim_address_type_cd = 6  then rsh_address_type_cd = 'RAD';
	else if sim_address_type_cd = 7  then rsh_address_type_cd = 'RBI';
	else if sim_address_type_cd = 8  then rsh_address_type_cd = 'RES';
	else if sim_address_type_cd = 9  then rsh_address_type_cd = 'SHL';
	else if sim_address_type_cd = 10 then rsh_address_type_cd = 'TMP'; 
	else if sim_address_type_cd = 11 then rsh_address_type_cd = 'RSA';
	else if sim_address_type_cd = 12 then rsh_address_type_cd = 'RSH'; 

	/*	Create status_flag variable */
		 if sim_status_flag = 1 then status_flag = 'A';
	else if sim_status_flag = 2 then status_flag = 'D';
	else if sim_status_flag = 3 then status_flag = 'E';
	else if sim_status_flag = 4 then status_flag = 'M';
	else if sim_status_flag = 5 then status_flag = 'P';
	else if sim_status_flag = 6 then status_flag = 'R';
	else if sim_status_flag = 7 then status_flag = 'W';

	/*	Create variable to randomly assign address information 		*/
	/*	The information in these DO LOOPS comprises of summary		*/
	/*	results from RTZ partner sites, and is not a reflection of	*/
	/*	the true population. Additioanlly, missing data is preserved*/
	/*	from the information provided. 								*/
	
	if state_cd = "&STATE_1." then sim 	= int(ranuni(104)*810); 
		* 811 chosen based on the number of random addresses available at		; 
		*		http://download.geonames.org/export/dump/ -> accessed 05APR2022	;
	if state_cd = "&STATE_3." then sim 	= int(ranuni(108)*718);	 
		* 719 chosen based on the number of random addresses available at		; 
		*		http://download.geonames.org/export/dump/ -> accessed 05APR2022	;
	if state_cd = "&STATE_2." then sim 	= int(ranuni(108)*530);	 
		* 531 chosen based on the number of random addresses available at		; 
		*		http://download.geonames.org/export/dump/ -> accessed 05APR2022	;

	drop sim_state_cd 			sim_aids_insurance 	sim_birth_sex 		sim_current_gender 
		 sim_education 			sim_hiv_insurance 	sim_hars_race 		sim_trans_categ 
		 sim_status_flag		sim_address_type_cd	  ;
run;

/*======================================================================*/
/*	This step is specific to merging geographic variables into the 		*/
/*	simulated PERSONVIEW data set. The addresses are used as they are 	*/
/*	freely available, and have corresponding LATITUDE and LONGITUDE 	*/
/*	values that would be possible to include when eHARS data has been 	*/
/*	geo-coded. This step includes addresses that are known to exist, 	*/
/*	and are known that geo-coding could be done. The program that 		*/
/*	creates the ADDRESS_SIM data set is also included and can be 		*/
/*	updated to include simulated addresses for all 50 states, and with 	*/
/*	more work could be used for all countries available in the GeoNames */
/*	Postal Code dataset. The main GeoNames gazetteer data extract is 	*/
/*	here: http://download.geonames.org/export/dump/						*/
/*======================================================================*/


/*Sort data sets to prepare for merging and final PERSONVIEW data set*/
proc sort data = Person_view_sim; by state_cd SIM; run;
proc sort data = &address_sim out = address_sim; by state_cd sim; run;

data Person_view;
	/* length and label for each variable is assigned based on eHARS data dictionary */
	length	ehars_uid						$16.
			document_uid					$16.
			rsa_county_fips					$3.
			rsa_county_name					$64.
			rsa_state_cd					$2.
			rsa_zip_cd						$10.
			rsh_county_fips					$3.
			rsh_county_name					$64.
			rsh_state_cd					$2.
			rsh_zip_cd						$10.
			facility_type_cd				$10.;

	merge Person_view_sim(in = a) address_sim(in = b);
	by state_cd sim;
	if a;

	label	ehars_uid			=	"Identifies the person associated with each document; ehars_uid is a unique value generated by eHARS."
			document_uid		=  	"Identifies the document associated with each address record stored on the table; a unique value generated by eHARS to identify a document."      
			rsa_county_fips		=	"The FIPS code for the county of residence at the time of AIDS (HIV, stage 3) diagnosis"
			rsa_county_name		=	"The patients county of residence at the time of earliest AIDS (HIV, stage 3) diagnosis, based on the FIPS county of residence "
			rsa_state_cd		=	"The patients state of residence at the time of AIDS (HIV, stage 3) diagnosis (i.e., time of the first AIDS classifying condition) "
			rsa_zip_cd			=	"Zip code of residence at AIDS (HIV, stage 3) diagnosis"
			rsh_county_fips		=	"The FIPS code for the county of residence at the time of HIV (stage 1, 2, or unknown) diagnosis"
			rsh_county_name		=	"The patients county of residence at the time of HIV (stage 1, 2, or unknown) diagnosis, based on the FIPS county of residence "
			rsh_state_cd		=	"The patients state of residence at the time of HIV (stage 1, 2, or unknown) diagnosis (i.e., time of the first positive HIV test result or doctor diagnosis of HIV; hiv_dx_dt) "
			rsh_zip_cd			=	"Zip code of residence at HIV (stage 1, 2, or unknown) diagnosis"
			address_type_cd		=	"A code indicating the type of address reported for the residence at HIV infection diagnosis, such as BAD, POS (postal) or RES (residential).";

	/*	Create county_fips variable for Alabama */
    if state_cd = "&STATE_1." then do;
	    if PROPCASE(county_name) = 'Autauga Co.'   	then county_fips = '001';
	    if PROPCASE(county_name) = 'Baldwin Co.'   	then county_fips = '003';
	    if PROPCASE(county_name) = 'Barbour Co.'   	then county_fips = '005';
	    if PROPCASE(county_name) = 'Bibb Co.'   	then county_fips = '007';
	    if PROPCASE(county_name) = 'Blount Co.'   	then county_fips = '009';
	    if PROPCASE(county_name) = 'Bullock Co.'   	then county_fips = '011';
	    if PROPCASE(county_name) = 'Butler Co.'   	then county_fips = '013';
	    if PROPCASE(county_name) = 'Calhoun Co.'   	then county_fips = '015';
	    if PROPCASE(county_name) = 'Chambers Co.'   then county_fips = '017';
	    if PROPCASE(county_name) = 'Cherokee Co.'   then county_fips = '019';
	    if PROPCASE(county_name) = 'Chilton Co.'   	then county_fips = '021';
	    if PROPCASE(county_name) = 'Choctaw Co.'   	then county_fips = '023';
	    if PROPCASE(county_name) = 'Clarke Co.'   	then county_fips = '025';
	    if PROPCASE(county_name) = 'Clay Co.'   	then county_fips = '027';
	    if PROPCASE(county_name) = 'Cleburne Co.'   then county_fips = '029';
	    if PROPCASE(county_name) = 'Coffee Co.'   	then county_fips = '031';
	    if PROPCASE(county_name) = 'Colbert Co.'  	then county_fips = '033';
	    if PROPCASE(county_name) = 'Conecuh Co.'   	then county_fips = '035';
	    if PROPCASE(county_name) = 'Coosa Co.'   	then county_fips = '037';
	    if PROPCASE(county_name) = 'Covington Co.'  then county_fips = '039';
	    if PROPCASE(county_name) = 'Crenshaw Co.'   then county_fips = '041';
	    if PROPCASE(county_name) = 'Cullman Co.'   	then county_fips = '043';
	    if PROPCASE(county_name) = 'Dale Co.'   	then county_fips = '045';
	    if PROPCASE(county_name) = 'Dallas Co.'   	then county_fips = '047';
	    if PROPCASE(county_name) = 'DeKalb Co.'   	then county_fips = '049';
	    if PROPCASE(county_name) = 'Elmore Co.'   	then county_fips = '051';
	    if PROPCASE(county_name) = 'Escambia Co.'   then county_fips = '053';
	    if PROPCASE(county_name) = 'Etowah Co.'   	then county_fips = '055';
	    if PROPCASE(county_name) = 'Fayette Co.'   	then county_fips = '057';
	    if PROPCASE(county_name) = 'Franklin Co.'   then county_fips = '059';
	    if PROPCASE(county_name) = 'Geneva Co.'   	then county_fips = '061';
	    if PROPCASE(county_name) = 'Greene Co.'   	then county_fips = '063';
	    if PROPCASE(county_name) = 'Hale Co.'   	then county_fips = '065';
	    if PROPCASE(county_name) = 'Henry Co.'   	then county_fips = '067';
	    if PROPCASE(county_name) = 'Houston Co.'   	then county_fips = '069';
	    if PROPCASE(county_name) = 'Jackson Co.'   	then county_fips = '071';
	    if PROPCASE(county_name) = 'Jefferson Co.'  then county_fips = '073';
	    if PROPCASE(county_name) = 'Lamar Co.'   	then county_fips = '075';
	    if PROPCASE(county_name) = 'Lauderdale Co.' then county_fips = '077';
	    if PROPCASE(county_name) = 'Lawrence Co.'   then county_fips = '079';
	    if PROPCASE(county_name) = 'Lee Co.'   		then county_fips = '081';
	    if PROPCASE(county_name) = 'Limestone Co.'  then county_fips = '083';
	    if PROPCASE(county_name) = 'Lowndes Co.'   	then county_fips = '085';
	    if PROPCASE(county_name) = 'Macon Co.'   	then county_fips = '087';
	    if PROPCASE(county_name) = 'Madison Co.'   	then county_fips = '089';
	    if PROPCASE(county_name) = 'Marengo Co.'   	then county_fips = '091';
	    if PROPCASE(county_name) = 'Marion Co.'   	then county_fips = '093';
	    if PROPCASE(county_name) = 'Marshall Co.'   then county_fips = '095';
	    if PROPCASE(county_name) = 'Mobile Co.'   	then county_fips = '097';
	    if PROPCASE(county_name) = 'Monroe Co.'   	then county_fips = '099';
	    if PROPCASE(county_name) = 'Montgomery Co.' then county_fips = '101';
	    if PROPCASE(county_name) = 'Morgan Co.'   	then county_fips = '103';
	    if PROPCASE(county_name) = 'Perry Co.'   	then county_fips = '105';
	    if PROPCASE(county_name) = 'Pickens Co.'   	then county_fips = '107';
	    if PROPCASE(county_name) = 'Pike Co.'   	then county_fips = '109';
	    if PROPCASE(county_name) = 'Randolph Co.'   then county_fips = '111';
	    if PROPCASE(county_name) = 'Russell Co.'   	then county_fips = '113';
	    if PROPCASE(county_name) = 'St. Clair Co.'  then county_fips = '115';
	    if PROPCASE(county_name) = 'Shelby Co.'   	then county_fips = '117';
	    if PROPCASE(county_name) = 'Sumter Co.'   	then county_fips = '119';
	    if PROPCASE(county_name) = 'Talladega Co.'  then county_fips = '121';
	    if PROPCASE(county_name) = 'Tallapoosa Co.' then county_fips = '123';
	    if PROPCASE(county_name) = 'Tuscaloosa Co.' then county_fips = '125';
	    if PROPCASE(county_name) = 'Walker Co.'   	then county_fips = '127';
	    if PROPCASE(county_name) = 'Washington Co.' then county_fips = '129';
	    if PROPCASE(county_name) = 'Wilcox Co.'   	then county_fips = '131';
	    if PROPCASE(county_name) = 'Winston Co.'   	then county_fips = '133';
	end;

	/*	Create county_fips variable for Louisiana */
    if state_cd = "&STATE_3." then do;
	    if PROPCASE(county_name) = 'Acadia Co.'   		  then county_fips = '001';
	    if PROPCASE(county_name) = 'Allen Co.'   		  then county_fips = '003';
	    if PROPCASE(county_name) = 'Ascension Co.'   	  then county_fips = '005';
	    if PROPCASE(county_name) = 'Assumption Co.'   	  then county_fips = '007';
	    if PROPCASE(county_name) = 'Avoyelles Co.'   	  then county_fips = '009';
	    if PROPCASE(county_name) = 'Beauregard Co.'   	  then county_fips = '011';
	    if PROPCASE(county_name) = 'Bienville Co.'   	  then county_fips = '013';
	    if PROPCASE(county_name) = 'Bossier Co.'   		  then county_fips = '015';
	    if PROPCASE(county_name) = 'Caddo Co.'   		  then county_fips = '017';
	    if PROPCASE(county_name) = 'Calcasieu Co.'   	  then county_fips = '019';
	    if PROPCASE(county_name) = 'Caldwell Co.'   	  then county_fips = '021';
	    if PROPCASE(county_name) = 'Cameron Co.'   		  then county_fips = '023';
	    if PROPCASE(county_name) = 'Catahoula Co.'   	  then county_fips = '025';
	    if PROPCASE(county_name) = 'Claiborne Co.'   	  then county_fips = '027';
	    if PROPCASE(county_name) = 'Concordia Co.'   	  then county_fips = '029';
	    if PROPCASE(county_name) = 'De Soto Co.'  		  then county_fips = '031';
	    if PROPCASE(county_name) = 'East Baton Rouge Co.' then county_fips = '033';
	    if PROPCASE(county_name) = 'East Carroll Co.'  	  then county_fips = '035';
	    if PROPCASE(county_name) = 'East Feliciana Co.'   then county_fips = '037';
	    if PROPCASE(county_name) = 'Evangeline Co.'   	  then county_fips = '039';
	    if PROPCASE(county_name) = 'Franklin Co.'   	  then county_fips = '041';
	    if PROPCASE(county_name) = 'Grant Co.'   		  then county_fips = '043';
	    if PROPCASE(county_name) = 'Iberia Co.'   		  then county_fips = '045';
	    if PROPCASE(county_name) = 'Iberville Co.'   	  then county_fips = '047';
	    if PROPCASE(county_name) = 'Jackson Co.'   		  then county_fips = '049';
	    if PROPCASE(county_name) = 'Jefferson Co.'   	  then county_fips = '053';
	    if PROPCASE(county_name) = 'Jefferson Davis Co.'  then county_fips = '051';
	    if PROPCASE(county_name) = 'La Salle Co.'  	  	  then county_fips = '055';
	    if PROPCASE(county_name) = 'Lafayette Co.'  	  then county_fips = '057';
	    if PROPCASE(county_name) = 'Lafourche Co.'  	  then county_fips = '059';
	    if PROPCASE(county_name) = 'Lincoln Co.'  		  then county_fips = '061';
	    if PROPCASE(county_name) = 'Livingston Co.'  	  then county_fips = '063';
	    if PROPCASE(county_name) = 'Madison Co.'  		  then county_fips = '065';
	    if PROPCASE(county_name) = 'Morehouse Co.'  	  then county_fips = '067';
	    if PROPCASE(county_name) = 'Natchitoches Co.'  	  then county_fips = '069';
	    if PROPCASE(county_name) = 'Orleans Co.'  		  then county_fips = '071';
	    if PROPCASE(county_name) = 'Ouachita Co.'  		  then county_fips = '073';
	    if PROPCASE(county_name) = 'Plaquemines Co.' 	  then county_fips = '075';
	    if PROPCASE(county_name) = 'Pointe Coupee Co.'    then county_fips = '077';
	    if PROPCASE(county_name) = 'Rapides Co.'   		  then county_fips = '079';
	    if PROPCASE(county_name) = 'Red River Co.' 		  then county_fips = '081';
	    if PROPCASE(county_name) = 'Richland Co.'  		  then county_fips = '083';
	    if PROPCASE(county_name) = 'Sabine Co.'  		  then county_fips = '085';
	    if PROPCASE(county_name) = 'St. Bernard Co.'  	  then county_fips = '087';
	    if PROPCASE(county_name) = 'St. Charles Co.'  	  then county_fips = '089';
	    if PROPCASE(county_name) = 'St. Helena Co.'  	  then county_fips = '091';
	    if PROPCASE(county_name) = 'St. James Co.'  	  then county_fips = '093';
	    if PROPCASE(county_name) = 'St. John The Baptist Co.' then county_fips = '095';
	    if PROPCASE(county_name) = 'St. Landry Co.'  	  then county_fips = '097';
	    if PROPCASE(county_name) = 'St. Martin Co.'  	  then county_fips = '099';
	    if PROPCASE(county_name) = 'St. Mary Co.'  		  then county_fips = '101';
	    if PROPCASE(county_name) = 'St. Tammany Co.'  	  then county_fips = '103';
	    if PROPCASE(county_name) = 'Tangipahoa Co.'   	  then county_fips = '105';
	    if PROPCASE(county_name) = 'Tensas Co.'  		  then county_fips = '107';
	    if PROPCASE(county_name) = 'Terrebonne Co.'   	  then county_fips = '109';
	    if PROPCASE(county_name) = 'Union Co.'  		  then county_fips = '111';
	    if PROPCASE(county_name) = 'Vermilion Co.'  	  then county_fips = '113';
	    if PROPCASE(county_name) = 'Vernon Co.'   		  then county_fips = '115';
	    if PROPCASE(county_name) = 'Washington Co.'   	  then county_fips = '117';
	    if PROPCASE(county_name) = 'Webster Co.'   		  then county_fips = '119';
	    if PROPCASE(county_name) = 'West Baton Rouge Co.' then county_fips = '121';
	    if PROPCASE(county_name) = 'West Carroll Co.'  	  then county_fips = '123';
	    if PROPCASE(county_name) = 'West Feliciana Co.'   then county_fips = '125';
	    if PROPCASE(county_name) = 'Winn Co.'   		  then county_fips = '127';
	end;
	
	/*	Create county_fips variable for Mississippi */
    if state_cd = "&STATE_2." then do;
	    if PROPCASE(county_name) = 'Adams Co.'  		then county_fips = '001';
	    if PROPCASE(county_name) = 'Alcorn Co.'  		then county_fips = '003';
	    if PROPCASE(county_name) = 'Amite Co.'  		then county_fips = '005';
	    if PROPCASE(county_name) = 'Attala Co.'  		then county_fips = '007';
	    if PROPCASE(county_name) = 'Benton Co.'  		then county_fips = '009';
	    if PROPCASE(county_name) = 'Bolivar Co.'  		then county_fips = '011';
	    if PROPCASE(county_name) = 'Calhoun Co.'  		then county_fips = '013';
	    if PROPCASE(county_name) = 'Carroll Co.'  		then county_fips = '015';
	    if PROPCASE(county_name) = 'Chickasaw Co.'  	then county_fips = '017';
	    if PROPCASE(county_name) = 'Choctaw Co.'  		then county_fips = '019';
	    if PROPCASE(county_name) = 'Claiborne Co.'  	then county_fips = '021';
	    if PROPCASE(county_name) = 'Clarke Co.'  		then county_fips = '023';
	    if PROPCASE(county_name) = 'Clay Co.'  			then county_fips = '025';
	    if PROPCASE(county_name) = 'Coahoma Co.'  		then county_fips = '027';
	    if PROPCASE(county_name) = 'Copiah Co.'  		then county_fips = '029';
	    if PROPCASE(county_name) = 'Covington Co.'  	then county_fips = '031';
	    if PROPCASE(county_name) = 'De Soto Co.' 		then county_fips = '033';
	    if PROPCASE(county_name) = 'Forrest Co.'  		then county_fips = '035';
	    if PROPCASE(county_name) = 'Franklin Co.'  		then county_fips = '037';
	    if PROPCASE(county_name) = 'George Co.'  		then county_fips = '039';
	    if PROPCASE(county_name) = 'Greene Co.'  		then county_fips = '041';
	    if PROPCASE(county_name) = 'Grenada Co.'  		then county_fips = '043';
	    if PROPCASE(county_name) = 'Hancock Co.'  		then county_fips = '045';
	    if PROPCASE(county_name) = 'Harrison Co.'  		then county_fips = '047';
	    if PROPCASE(county_name) = 'Hinds Co.'  		then county_fips = '049';
	    if PROPCASE(county_name) = 'Holmes Co.'  		then county_fips = '051';
	    if PROPCASE(county_name) = 'Humphreys Co.'  	then county_fips = '053';
	    if PROPCASE(county_name) = 'Issaquena Co.'  	then county_fips = '055';
	    if PROPCASE(county_name) = 'Itawamba Co.'  		then county_fips = '057';
	    if PROPCASE(county_name) = 'Jackson Co.'  		then county_fips = '059';
	    if PROPCASE(county_name) = 'Jasper Co.'  		then county_fips = '061';
	    if PROPCASE(county_name) = 'Jefferson Co.'  	then county_fips = '063';
	    if PROPCASE(county_name) = 'Jefferson Davis Co.' then county_fips = '065';
	    if PROPCASE(county_name) = 'Jones Co.'  		then county_fips = '067';
	    if PROPCASE(county_name) = 'Kemper Co.'  		then county_fips = '069';
	    if PROPCASE(county_name) = 'Lafayette Co.'  	then county_fips = '071';
	    if PROPCASE(county_name) = 'Lamar Co.'  		then county_fips = '073';
	    if PROPCASE(county_name) = 'Lauderdale Co.'  	then county_fips = '075';
	    if PROPCASE(county_name) = 'Lawrence Co.'  		then county_fips = '077';
	    if PROPCASE(county_name) = 'Leake Co.'  		then county_fips = '079';
	    if PROPCASE(county_name) = 'Lee Co.'  			then county_fips = '081';
	    if PROPCASE(county_name) = 'Lefiore Co.'  		then county_fips = '083';
	    if PROPCASE(county_name) = 'Lincoln Co.'  		then county_fips = '085';
	    if PROPCASE(county_name) = 'Lowndes Co.'  		then county_fips = '087';
	    if PROPCASE(county_name) = 'Madison Co.'  		then county_fips = '089';
	    if PROPCASE(county_name) = 'Marion Co.'  		then county_fips = '091';
	    if PROPCASE(county_name) = 'Marshall Co.'  		then county_fips = '093';
	    if PROPCASE(county_name) = 'Monroe Co.'  		then county_fips = '095';
	    if PROPCASE(county_name) = 'Montgomery Co.'  	then county_fips = '097';
	    if PROPCASE(county_name) = 'Neshoba Co.'  		then county_fips = '099';
	    if PROPCASE(county_name) = 'Newton Co.'  		then county_fips = '101';
	    if PROPCASE(county_name) = 'Noxubee Co.'  		then county_fips = '103';
	    if PROPCASE(county_name) = 'Oktinneha Co.'  	then county_fips = '105';
	    if PROPCASE(county_name) = 'Panola Co.'  		then county_fips = '107';
	    if PROPCASE(county_name) = 'Pearl River Co.' 	then county_fips = '109';
	    if PROPCASE(county_name) = 'Perry Co.'  		then county_fips = '111';
	    if PROPCASE(county_name) = 'Pike Co.'  			then county_fips = '113';
	    if PROPCASE(county_name) = 'Pontotoc Co.'  		then county_fips = '115';
	    if PROPCASE(county_name) = 'Prentiss Co.'  		then county_fips = '117';
	    if PROPCASE(county_name) = 'Quitman Co.'  		then county_fips = '119';
	    if PROPCASE(county_name) = 'Rankin Co.'  		then county_fips = '121';
	    if PROPCASE(county_name) = 'Scott Co.'  		then county_fips = '123';
	    if PROPCASE(county_name) = 'Sharkey Co.'  		then county_fips = '125';
	    if PROPCASE(county_name) = 'Simpson Co.'  		then county_fips = '127';
	    if PROPCASE(county_name) = 'Smith Co.'  		then county_fips = '129';
	    if PROPCASE(county_name) = 'Stone Co.'  		then county_fips = '131';
	    if PROPCASE(county_name) = 'Sunflower Co.'  	then county_fips = '133';
	    if PROPCASE(county_name) = 'Tallahatchie Co.'  	then county_fips = '135';
	    if PROPCASE(county_name) = 'Tate Co.'  			then county_fips = '137';
	    if PROPCASE(county_name) = 'Tippah Co.'  		then county_fips = '139';
	    if PROPCASE(county_name) = 'Tishomingo Co.'  	then county_fips = '141';
	    if PROPCASE(county_name) = 'Tunica Co.'  		then county_fips = '143';
	    if PROPCASE(county_name) = 'Union Co.'  		then county_fips = '145';
	    if PROPCASE(county_name) = 'Walthall Co.'  		then county_fips = '147';
	    if PROPCASE(county_name) = 'Warren Co.'  		then county_fips = '149';
	    if PROPCASE(county_name) = 'Washington Co.'  	then county_fips = '151';
	    if PROPCASE(county_name) = 'Wayne Co.'  		then county_fips = '153';
	    if PROPCASE(county_name) = 'Webster Co.'  		then county_fips = '155';
	    if PROPCASE(county_name) = 'Wilkinson Co.'  	then county_fips = '157';
	    if PROPCASE(county_name) = 'Winston Co.'  		then county_fips = '159';
	    if PROPCASE(county_name) = 'Yalobusha Co.'  	then county_fips = '161';
	    if PROPCASE(county_name) = 'Yazoo Co.'  		then county_fips = '163';
	end;
   
	/*	Convert simulated location variables into RSA and RSH variables */
	/*	RSA = Residence at AIDS Diagnosis								*/
	/*	RSH = Residence at HIV Diagnosis 								*/
	/*	For simplicity, these are assumed to be the same, although PLWH */
	/*	may move and have different location data at the time of the	*/
	/*	respective diagnosis											*/
	rsa_county_fips		=	county_fips;
	rsa_county_name		=	county_name;
	rsa_state_cd		=	state_cd;
	rsa_zip_cd			=	zip_cd;
	rsh_county_fips		=	county_fips;
	rsh_county_name		=	county_name;
	rsh_state_cd		=	state_cd;
	rsh_zip_cd			=	zip_cd;
	hf_facility_uid 	= 	facility_uid;
	af_facility_uid 	= 	facility_uid;
	
	/*	Remove missing values in order to manage a complete data set.	*/
	/*	Missing data is over represented as a location that may have	*/
	/*	one observation, and another that may have 1000 observations	*/
	/*	are equally likely to be assigned to a randomly generated 		*/
	/*	observation; and we assume that the missing location data is 	*/
	/*	most likely from these more obscure locations.					*/
	if county_fips = '' or zip_cd = '' then delete;
	if state_cd in("&STATE_1.","&STATE_2.","&STATE_3.");

	/*	Create ehars_uid variable */
	uid3 	= compress(put(uid, best32.));
	if sim NE . then ehars_uid = upcase(rsa_state_cd) || '-' || uid3;

	/*	Create document_uid variable */
	d_uid 	= uid - 3457887543;	* randomly selected, number has no meaning;
	d_uid3 	= compress(put(d_uid, best32.));
	if sim NE . then document_uid = upcase(rsa_state_cd) || '-' || d_uid3;


drop i UID UID3 d_UID d_UID3 SIM county_name county_fips state_cd zip_cd;
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/


%let start    	= '01JAN1965'D;	
%let end1 	   	= '01JAN2000'D;
%let end2 	   	= '01JAN2020'D;
%let end3 	   	= '01JAN2070'D;
%let end4 	   	= '01JAN2170'D;


data dates;
	format 	dob yymmdd10. 			dod yymmdd10. 				  hiv_aids_dx_dt yymmdd10. 
			oi_stage3_dt yymmdd10. 	aids_categ_a_rep_dt yymmdd10. aids_rep_dt yymmdd10.;

	count = 0;
	retain count;
	call streaminit(&SEED_02); 	
	do i = 1 to &NSIM;
			/*	begin creating dates by establishing date of birth (dob) 	*/
			interval_1 		    = 	&end1 - &start;
			dob 			    = 	&end1 - ranuni(200) * interval_1;

			/*	create interval by establishing a date of death, most dod's */
			/*  will occur in the 'future' and subsequently dropped later	*/
			/*	in the program. This will limit the number of simulated 	*/
			/*	deaths at a rate that is more consisent with eHARS data 	*/		
			interval_4 		    = 	&end4 - &end1;
			dod 			    = 	dob + floor((interval_4) * rand("uniform"));
			if dob > dod then dod = .;
		
				 if dod NE . then interval_2	=	&end2 - &end1;
			else if dod = .  then interval_2	=	&end2 - dod;
		
			/*	Establishing the initial date of HIV diagnosis	*/
			hiv_aids_dx_dt	    =	&end2 - ranuni(202) * interval_2;
			if hiv_aids_dx_dt > dod then hiv_aids_dx_dt = .;
		
			/*	Establishing the initial date of AIDS diagnosis	*/
			interval_3		    =	&end3 - hiv_aids_dx_dt;
			oi_stage3_dt	    =	&end3 - ranuni(203) * interval_3;
			aids_categ_a_rep_dt =   oi_stage3_dt;
			aids_rep_dt		    =	oi_stage3_dt;
		
			/*	reset dates that occur in the 'future' to missing	*/
			if dod 					> &end2 then dod 				 = .;
			if hiv_aids_dx_dt 		> &end2 then hiv_aids_dx_dt 	 = .;
			if oi_stage3_dt 		> &end2 then oi_stage3_dt 		 = .;
			if aids_categ_a_rep_dt 	> &end2 then aids_categ_a_rep_dt = .;
			if aids_rep_dt 			> &end2 then aids_rep_dt 		 = .;
		
			/*	Create Age variables now that dates are created */
			aids_age_yrs 	    =   intck('year', dob, oi_stage3_dt);									
			hiv_aids_age_yrs    =   intck('year', dob, hiv_aids_dx_dt);									
		 	count + 1;
		output;
		end;
run;


/*	Now that dates have been created, the data set is further refined so 	*/
/*	that only those that have a HIV diagnosis date are included (this can  	*/
/*	be changed to suit other purposes, but is designed to initially serve	*/
/*	study goals for the RTZ project)										*/
data dates2;
	format 	i hiv_aids_dx_dt oi_stage3_dt dod count; 
	set dates(keep = i hiv_aids_dx_dt oi_stage3_dt dod count);
	where hiv_aids_dx_dt NE .;
	/* ensure that any diagnosis date that is simulated after a dod is reset */
	if dod NE . AND oi_stage3_dt > dod then oi_stage3_dt = .;
	keep  i hiv_aids_dx_dt oi_stage3_dt dod count;
run;

proc sort data = dates2 out = dates3; by hiv_aids_dx_dt; run;

/*	With the initial dates set, we now simulate additional dates where lab 	*/
/*	samples will later be added (simulated)									*/
data dates4;
	set dates3;
	by hiv_aids_dx_dt;
	end 		= 	&end2;
	end2 		=  '31DEC2019'D;
	/*	set first sample date as the date of initial diagnosis */
	sample_dt 	= 	hiv_aids_dx_dt;

	call streaminit(&SEED_03); 	
	retain sample_dt;
	/*	sample dates for simulated observations that have HIV, are not 	*/
	/*	diagnosied with AIDS, and are alive								*/
	if first.hiv_aids_dx_dt and hiv_aids_dx_dt <= '31DEC2018'D then do;
		if hiv_aids_dx_dt NE . AND oi_stage3_dt = . AND dod = . then
						do j = 1 to 50 until(end2 - ceil(sample_dt) <= 30);										
								if end2 - ceil(sample_dt) > 60 then sample_dt = sample_dt + rand("Integer",60, 150);
								else sample_dt = sample_dt + rand("Integer",30, 90);     
								sample_dt = ceil(sample_dt);
								format sample_dt yymmdd10.;
							output;
							end;
	
		/*	sample dates for simulated observations that have HIV, are  	*/
		/*	diagnosied with AIDS, and are alive								*/
		if hiv_aids_dx_dt NE . AND oi_stage3_dt NE . AND dod = . then
	
						do j = 1 to 50 until(end2 - ceil(sample_dt) <= 90 OR m = 10);	
								if oi_stage3_dt >= sample_dt then do k = 1 to 25 until(oi_stage3_dt - ceil(sample_dt) <= 30);
										if end2 - ceil(sample_dt) > 60 then sample_dt = sample_dt + rand("Integer",60, 150);
										else sample_dt = sample_dt +  rand("Integer",30, 90);
										sample_dt = ceil(sample_dt);
										format sample_dt yymmdd10.;
									output;
									end;
	
								else if oi_stage3_dt - ceil(sample_dt) <= 30 then sample_dt = oi_stage3_dt;
									output;
	
								do m = 1 to 30;
										sample_dt = sample_dt + rand("Integer",90, 240);
										sample_dt = ceil(sample_dt);
										format sample_dt yymmdd10.;
									output;
									end;
							output;
							end;
	
		/*	sample dates for simulated observations that have HIV, are  	*/
		/*	diagnosied with AIDS, and are not alive							*/
		if hiv_aids_dx_dt NE . AND oi_stage3_dt NE . AND dod NE . then
	
						do j = 1 to 50 until(dod - ceil(sample_dt) <= 90);	
								if oi_stage3_dt >= sample_dt then do k = 1 to 25 until(oi_stage3_dt - ceil(sample_dt) <= 30);
										if end2 - ceil(sample_dt) > 60 then sample_dt = sample_dt + rand("Integer", 60, 150);
										else sample_dt = sample_dt + rand("Integer",30, 90);
										sample_dt = ceil(sample_dt);
										format sample_dt yymmdd10.;
									output;
									end;
	
								else if oi_stage3_dt - ceil(sample_dt) <= 30 then sample_dt = oi_stage3_dt;
									output;
	
								do m = 1 to 30 until(dod - ceil(sample_dt) <= 90);
										sample_dt = sample_dt + rand("Integer",90, 240);
										sample_dt = ceil(sample_dt);
										format sample_dt yymmdd10.;
									output;
									end;
								output;
								end;
	
		/*	sample dates for simulated observations that have HIV, are not 	*/
		/*	diagnosied with AIDS, and are not alive							*/
		if hiv_aids_dx_dt NE . AND oi_stage3_dt = . AND dod NE . then
							do j = 1 to 50 until(dod - ceil(sample_dt) <= 30);										
									if end2 - ceil(sample_dt) > 60 then sample_dt = sample_dt + rand("Integer", 30, 90);
									else sample_dt = sample_dt +  rand("Integer",30, 120);
									sample_dt = ceil(sample_dt);
									format sample_dt yymmdd10.;
								output;
								end;
	end;
	
	else if first.hiv_aids_dx_dt and  hiv_aids_dx_dt > '31DEC2018'D then do; 
		if hiv_aids_dx_dt NE . AND oi_stage3_dt = . AND dod = . then
						do j = 1 to 50 until(end2 - ceil(sample_dt) <= 10);										
								if end2 - ceil(sample_dt) > 60 then sample_dt = sample_dt + rand("Integer", 30, 90);
								else sample_dt = sample_dt + rand("Integer",30, 60);     /*###*/
								sample_dt = ceil(sample_dt);
								format sample_dt yymmdd10.;
							output;
							end;
	
		/*	sample dates for simulated observations that have HIV, are  	*/
		/*	diagnosied with AIDS, and are alive								*/
		if hiv_aids_dx_dt NE . AND oi_stage3_dt NE . AND dod = . then
	
						do j = 1 to 50 until(end2 - ceil(sample_dt) <= 90 OR m = 10);	
								if oi_stage3_dt >= sample_dt then do k = 1 to 25 until(oi_stage3_dt - ceil(sample_dt) <= 30);
										if end2 - ceil(sample_dt) > 60 then sample_dt = sample_dt + rand("Integer", 30, 90);
										else sample_dt = sample_dt +  rand("Integer",30, 90);
										sample_dt = ceil(sample_dt);
										format sample_dt yymmdd10.;
									output;
									end;
	
								else if oi_stage3_dt - ceil(sample_dt) <= 30 then sample_dt = oi_stage3_dt;
									output;
	
								do m = 1 to 30;
										sample_dt = sample_dt + rand("Integer",90, 240);
										sample_dt = ceil(sample_dt);
										format sample_dt yymmdd10.;
									output;
									end;
							output;
							end;
	
		/*	sample dates for simulated observations that have HIV, are  	*/
		/*	diagnosied with AIDS, and are not alive							*/
		if hiv_aids_dx_dt NE . AND oi_stage3_dt NE . AND dod NE . then
	
						do j = 1 to 50 until(dod - ceil(sample_dt) <= 90);	
								if oi_stage3_dt >= sample_dt then do k = 1 to 25 until(oi_stage3_dt - ceil(sample_dt) <= 30);
										if end2 - ceil(sample_dt) > 60 then sample_dt = sample_dt + rand("Integer", 30, 90);
										else sample_dt = sample_dt + rand("Integer",30, 90);
										sample_dt = ceil(sample_dt);
										format sample_dt yymmdd10.;
									output;
									end;
	
								else if oi_stage3_dt - ceil(sample_dt) <= 30 then sample_dt = oi_stage3_dt;
									output;
	
								do m = 1 to 30 until(dod - ceil(sample_dt) <= 90);
										sample_dt = sample_dt + rand("Integer",90, 240);
										sample_dt = ceil(sample_dt);
										format sample_dt yymmdd10.;
									output;
									end;
								output;
								end;
	
		/*	sample dates for simulated observations that have HIV, are not 	*/
		/*	diagnosied with AIDS, and are not alive							*/
		if hiv_aids_dx_dt NE . AND oi_stage3_dt = . AND dod NE . then
							do j = 1 to 50 until(dod - ceil(sample_dt) <= 10);										
									if end2 - ceil(sample_dt) > 60 then sample_dt = sample_dt + rand("Integer", 30, 60);
									else sample_dt = sample_dt +  rand("Integer",30, 60);
									sample_dt = ceil(sample_dt);
									format sample_dt yymmdd10.;
								output;
								end;
	end;
	keep hiv_aids_dx_dt oi_stage3_dt dod sample_dt count;
run;


proc sort data = dates4 
		  out  = dates4b; 
	by count oi_stage3_dt; 
run;


data dates4c;
	set dates4b;
	by count oi_stage3_dt;
	retain sample_dt;
	/* 	create a sample date that matches AIDS diagnosis date 	*/
	if last.count and last.oi_stage3_dt then do;
			if oi_stage3_dt NE . then sample_dt = oi_stage3_dt;
		end;
	/*	delete 'future' dates 	*/
	if sample_dt >= &end2 then delete;
	/*	ensure that first sample date matches HIV diagnosis date	*/
	if first.count then sample_dt = hiv_aids_dx_dt;
run;


/* Sort and remove duplicates */
proc sort data = dates4c 
		  out  = dates5 nodupkey; 
	by count descending sample_dt; 
run;



/*	The following data steps begin the systematic process of simulating VL 	*/
/*	and CD4 counts for each sample date										*/
data dates5b;
	set dates5;
	/* 	create a counter variable 'int' that will be used in a function to create samples */
	int + 1;
	by count;
	if first.count then int = 1;
	keep hiv_aids_dx_dt oi_stage3_dt dod sample_dt count int;
run;


data dates5c;
	set dates5b;
	by count;
	/* 	create a sum variable 'int2' that will be used to partition the data sets, that  */
	/*	will ultimately determine the function used to simulate VL/CD4					 */
	if first.count then int2 = 0;
	int2 + int;
	if last.count;
	keep hiv_aids_dx_dt oi_stage3_dt dod sample_dt count int int2;
run;


proc sort data = dates5c; 
	by int; 
run;


/*	Partitiion the data set into groups that is based on the number of dates that each 	*/
/*	simulated person has. The indicator variable 'dataset' will be used in conditional	*/
/*	logic later in the program to incorporate the respective funtion for that data set	*/
data dates6a dates6b dates6c dates6d dates6e dates6f dates6g dates6h dates6i dates6j;
	set dates5c;
		 if 1541 < int2  		then do;
				dataset = 'a';
				output dates6a;
			end;
	else if 991  < int2 <= 1541 then do;
				dataset = 'b';
				output dates6b;
			end;
	else if 631  < int2 <= 991  then do;
				dataset = 'c';
				output dates6c;
			end;
	else if 326  < int2 <= 631  then do;
				dataset = 'd';
				output dates6d;
			end;
	else if 211  < int2 <= 326  then do;
				dataset = 'e';
				output dates6e;
			end;
	else if 121   < int2 <= 211  then do;
				dataset = 'f';
				output dates6f;
			end;
	else if 56   < int2 <= 121   then do;
				dataset = 'g';
				output dates6g;
			end;
	else if 16    < int2 <= 56   then do;
				dataset = 'h';
				output dates6h;
			end;
	else if 7    < int2 <= 16   then do;
			dataset = 'i';
			output dates6i;
		end;
	else if 0    < int2 <= 7   then do;
			dataset = 'j';
			output dates6j;
		end;
	keep count dataset;
run;


proc sort data = dates6a; by count; run;
proc sort data = dates6b; by count; run;
proc sort data = dates6c; by count; run;
proc sort data = dates6d; by count; run;
proc sort data = dates6e; by count; run;
proc sort data = dates6f; by count; run;
proc sort data = dates6g; by count; run;
proc sort data = dates6h; by count; run;
proc sort data = dates6i; by count; run;
proc sort data = dates6j; by count; run;

data dates7a;
	set dates6a dates6b dates6c dates6d dates6e dates6f dates6g dates6h dates6i dates6j;
	by count;
run;


proc sort data = dates7a 
		  out  = dates7b; 
	by count; 
run;


/*Merge original data sets to include indicator variable for each observation*/
data dates8a;
	merge dates5b(in = a) dates7b(in = b);
	by count;
	if a and b;
	if dod NE . and sample_dt > dod then delete;
run;


/* Sort and remove duplicates */
proc sort data = dates8a 
		  out  = dates8b 
		  nodupkey; 
	by count  sample_dt; 
run;


/* Added in version 1.2; This is done to reduce the time to viral suppression */
/* estimation for the Road to Zero project.									  */
data dates8c;
	set dates8b(rename = (sample_dt = s_dt));
	by count  s_dt;
	/* only reduce dates for simulated obsersvations that have missing oi_stage3_dt */

	if oi_stage3_dt = . then do;
			if hiv_aids_dx_dt <= '31DEC2016'D then do;
					if first.count then sample_dt = s_dt;
					/* reduce by 90 days */
					else sample_dt = s_dt - 90;
				end;
			else if hiv_aids_dx_dt > '31DEC2016'D then do;
					if first.count then sample_dt = s_dt;
					/* reduce by 45 days */
					else sample_dt = s_dt - 45;
				end;
		end;
	else sample_dt = s_dt;
	format sample_dt yymmdd10.;
	drop s_dt;
run;

proc sort data = dates8c 
		  out  = dates8d 
		  nodupkey; 
	by count sample_dt; 
run;

/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/


/*Add Viral Load simulated data for each sample date*/
data dates9_VL;
	set dates8d;
	by count sample_dt;

	sim_lab_test_cd = rand("Table", 0.33, 0.33, 0.33);
		 if sim_lab_test_cd = 1 then lab_test_cd = 'EC-014';
	else if sim_lab_test_cd = 2 then lab_test_cd = 'EC-014'; 
	else if sim_lab_test_cd = 3 then lab_test_cd = 'L-010';
	else if sim_lab_test_cd = 4 then lab_test_cd = 'L-011';

	result_units          = 'C/ML';
	result_interpretation = '=';
	lab_test_type         = '01';

	call streaminit(&SEED_04); 	
	/*	sample VL's for simulated observations that have HIV, are not	*/
	/*	diagnosied with AIDS, and are alive								*/
	if oi_stage3_dt = . AND dod = . then do;
				 if dataset = 'a' AND 0  <  int <= 43  then result = (1.045 ** int) * 20;
			else if dataset = 'a' AND 43 <  int <  999 then result = (1.045 ** int) * 20 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'a' AND 	    int <= 0   then result = 150;		

				 if dataset = 'b' AND 0  <  int <= 39  then result = (1.045 ** int) * 25;
			else if dataset = 'b' AND 39 <  int <  999 then result = (1.045 ** int) * 25 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'b' AND 	    int <= 0   then result = 150;	

				 if dataset = 'c' AND 0  <  int <= 31  then result = (1.045 ** int) * 35;
			else if dataset = 'c' AND 31 <  int <  999 then result = (1.045 ** int) * 35 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'c' AND 	    int <= 0   then result = 150;	

				 if dataset = 'd' AND 0  <  int <= 25  then result = (1.045 ** int) * 60;
			else if dataset = 'd' AND 25 <  int <  999 then result = (1.045 ** int) * 60 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'd' AND 	    int <= 0   then result = 150;	

				 if dataset = 'e' AND 0  <  int <= 20  then result = (1.045 ** int) * 80;
			else if dataset = 'e' AND 20 <  int <  999 then result = (1.045 ** int) * 80 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'e' AND 	    int <= 0   then result = 150;	

				 if dataset = 'f' AND 0  <  int <= 15  then result = (1.045 ** int) * 95;
			else if dataset = 'f' AND 15 <  int <  999 then result = (1.045 ** int) * 95 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'f' AND 	    int <= 0   then result = 150;	

				 if dataset = 'g' AND 0  <  int <= 13   then result = (1.045 ** int) * 110;
			else if dataset = 'g' AND 13  <  int <  999 then result = (1.045 ** int) * 110 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'g' AND 	    int <= 0   then result = 150;	

				 if dataset = 'h' AND 0  <  int <= 9   then result = (1.045 ** int) * 130;
			else if dataset = 'h' AND 9  <  int <  999 then result = (1.045 ** int) * 130 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'h' AND       int <= 0   then result = 150;	

				 if dataset = 'i' AND 0  <  int <= 4   then result = (1.045 ** int) * 165;
			else if dataset = 'i' AND 4  <  int <  999 then result = (1.045 ** int) * 165 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'i' AND       int <= 0   then result = 150;	

				 if dataset = 'j' AND 0  <  int <= 1   then result = (1.045 ** int) * 191;
			else if dataset = 'j' AND 1  <  int <  999 then result = (1.045 ** int) * 191 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'j' AND       int <= 0   then result = 150;
		end;

	/*	sample VL's for simulated observations that have HIV, are 	*/
	/*	diagnosied with AIDS, and are alive							*/
	else if oi_stage3_dt NE . AND dod = . then do;
				 if dataset = 'a' AND 0  <  int <= 31  then result = (1.045 ** int) * 185;
			else if dataset = 'a' AND 31 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'a' AND 	    int <= 0   then result = 150;		

				 if dataset = 'b' AND 0  <  int <= 29  then result = (1.045 ** int) * 185;
			else if dataset = 'b' AND 29 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'b' AND 	    int <= 0   then result = 150;	

				 if dataset = 'c' AND 0  <  int <= 27  then result = (1.045 ** int) * 185;
			else if dataset = 'c' AND 27 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'c' AND 	    int <= 0   then result = 150;	

				 if dataset = 'd' AND 0  <  int <= 25  then result = (1.045 ** int) * 185;
			else if dataset = 'd' AND 25 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'd' AND 	    int <= 0   then result = 150;	

				 if dataset = 'e' AND 0  <  int <= 18  then result = (1.045 ** int) * 185;
			else if dataset = 'e' AND 18 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'e' AND 	    int <= 0   then result = 150;	

				 if dataset = 'f' AND 0  <  int <= 14  then result = (1.045 ** int) * 185;
			else if dataset = 'f' AND 14 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'f' AND 	    int <= 0   then result = 150;	

				 if dataset = 'g' AND 0  <  int <= 8   then result = (1.045 ** int) * 185;
			else if dataset = 'g' AND 8  <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'g' AND 	    int <= 0   then result = 150;	

				 if dataset = 'h' AND 0  <  int <= 6   then result = (1.045 ** int) * 185;
			else if dataset = 'h' AND 6  <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'h' AND       int <= 0   then result = 150;	
		end;

	/*	sample VL's for simulated observations that have HIV, are 	*/
	/*	diagnosied with AIDS, and are not alive						*/
	else if oi_stage3_dt NE . AND dod NE . then do;
				 if dataset = 'a' AND 0  <  int <= 31  then result = (1.045 ** int) * 185;
			else if dataset = 'a' AND 31 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'a' AND 	    int <= 0   then result = 300;		

				 if dataset = 'b' AND 0  <  int <= 29  then result = (1.045 ** int) * 185;
			else if dataset = 'b' AND 29 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'b' AND 	    int <= 0   then result = 300;	

				 if dataset = 'c' AND 0  <  int <= 27  then result = (1.045 ** int) * 185;
			else if dataset = 'c' AND 27 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'c' AND 	    int <= 0   then result = 300;	

				 if dataset = 'd' AND 0  <  int <= 25  then result = (1.045 ** int) * 185;
			else if dataset = 'd' AND 25 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'd' AND 	    int <= 0   then result = 300;	

				 if dataset = 'e' AND 0  <  int <= 18  then result = (1.045 ** int) * 185;
			else if dataset = 'e' AND 18 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'e' AND 	    int <= 0   then result = 300;	

				 if dataset = 'f' AND 0  <  int <= 14  then result = (1.045 ** int) * 185;
			else if dataset = 'f' AND 14 <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'f' AND 	    int <= 0   then result = 300;	

				 if dataset = 'g' AND 0  <  int <= 8   then result = (1.045 ** int) * 185;
			else if dataset = 'g' AND 8  <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'g' AND 	    int <= 0   then result = 300;	

				 if dataset = 'h' AND 0  <  int <= 6   then result = (1.045 ** int) * 185;
			else if dataset = 'h' AND 6  <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'h' AND       int <= 0   then result = 300;	
		end;

	/*	sample VL's for simulated observations that have HIV, are not	*/
	/*	diagnosied with AIDS, and are not alive						*/
	else if oi_stage3_dt = . AND dod NE . then do;
				 if dataset = 'a' AND 0  <  int <= 43  then result = (1.045 ** int) * 20;
			else if dataset = 'a' AND 43 <  int <  999 then result = (1.045 ** int) * 20 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'a' AND 	    int <= 0   then result = 150;		

				 if dataset = 'b' AND 0  <  int <= 39  then result = (1.045 ** int) * 25;
			else if dataset = 'b' AND 39 <  int <  999 then result = (1.045 ** int) * 25 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'b' AND 	    int <= 0   then result = 150;	

				 if dataset = 'c' AND 0  <  int <= 31  then result = (1.045 ** int) * 35;
			else if dataset = 'c' AND 31 <  int <  999 then result = (1.045 ** int) * 35 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'c' AND 	    int <= 0   then result = 150;	

				 if dataset = 'd' AND 0  <  int <= 25  then result = (1.045 ** int) * 60;
			else if dataset = 'd' AND 25 <  int <  999 then result = (1.045 ** int) * 60 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'd' AND 	    int <= 0   then result = 150;	

				 if dataset = 'e' AND 0  <  int <= 20  then result = (1.045 ** int) * 80;
			else if dataset = 'e' AND 20 <  int <  999 then result = (1.045 ** int) * 80 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'e' AND 	    int <= 0   then result = 150;	

				 if dataset = 'f' AND 0  <  int <= 15  then result = (1.045 ** int) * 95;
			else if dataset = 'f' AND 15 <  int <  999 then result = (1.045 ** int) * 95 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'f' AND 	    int <= 0   then result = 150;	

				 if dataset = 'g' AND 0  <  int <= 13   then result = (1.045 ** int) * 110;
			else if dataset = 'g' AND 13  <  int <  999 then result = (1.045 ** int) * 110 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'g' AND 	    int <= 0   then result = 150;	

				 if dataset = 'h' AND 0  <  int <= 9   then result = (1.045 ** int) * 130;
			else if dataset = 'h' AND 9  <  int <  999 then result = (1.045 ** int) * 130 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'h' AND       int <= 0   then result = 150;	

				 if dataset = 'i' AND 0  <  int <= 4   then result = (1.045 ** int) * 165;
			else if dataset = 'i' AND 4  <  int <  999 then result = (1.045 ** int) * 165 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'i' AND       int <= 0   then result = 150;	

				 if dataset = 'j' AND 0  <  int <= 1   then result = (1.045 ** int) * 191;
			else if dataset = 'j' AND 1  <  int <  999 then result = (1.045 ** int) * 191 + (100 * abs(rand("Normal", 1, 3)));
			else if dataset = 'j' AND       int <= 0   then result = 150;
		end;
run;


proc sort data = dates9_VL 
		  out  = dates10_VL; 
	by count sample_dt; 
run;


data dates11_VL;
	set dates10_VL;
	if oi_stage3_dt NE . then do;
		if sample_dt > oi_stage3_dt then result = result * 3;
		end;

run;


proc sort data = dates11_VL; 
	by count; 
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/


/*Add CD4 Count simulated data for each sample date*/
data dates9_CD4;
	set dates8d;
	by count sample_dt;

	sim_lab_test_cd = rand("Table", 0.50, 0.50);
		 if sim_lab_test_cd = 1 then lab_test_cd = 'EC-016';
	else if sim_lab_test_cd = 2 then lab_test_cd = 'EC-016';
	*'EC-017 is not included, as this denotes a percent, and we have not inlcluded percents in this version;

	result_units 		  = 	'CNT';
	result_interpretation = 	'=';

	call streaminit(&SEED_05); 
	/*	sample CD4 counts's for simulated observations that have HIV, are not	*/
	/*	diagnosied with AIDS, and are alive										*/
	if oi_stage3_dt = . AND dod = . then do;
				 if dataset = 'a' AND 0  <  int <= 31  then result = (1.045 ** int) * 210;
			else if dataset = 'a' AND 31 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'a' AND 	    int <= 0   then result = 150;		

				 if dataset = 'b' AND 0  <  int <= 29  then result = (1.045 ** int) * 210;
			else if dataset = 'b' AND 29 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'b' AND 	    int <= 0   then result = 150;	

				 if dataset = 'c' AND 0  <  int <= 27  then result = (1.045 ** int) * 210;
			else if dataset = 'c' AND 27 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'c' AND 	    int <= 0   then result = 150;	

				 if dataset = 'd' AND 0  <  int <= 25  then result = (1.045 ** int) * 210;
			else if dataset = 'd' AND 25 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'd' AND 	    int <= 0   then result = 150;	

				 if dataset = 'e' AND 0  <  int <= 18  then result = (1.045 ** int) * 210;
			else if dataset = 'e' AND 18 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'e' AND 	    int <= 0   then result = 150;	

				 if dataset = 'f' AND 0  <  int <= 14  then result = (1.045 ** int) * 210;
			else if dataset = 'f' AND 14 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'f' AND 	    int <= 0   then result = 150;	

				 if dataset = 'g' AND 0  <  int <= 8   then result = (1.045 ** int) * 210;
			else if dataset = 'g' AND 8  <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'g' AND 	    int <= 0   then result = 150;	

				 if dataset = 'h' AND 0  <  int <= 6   then result = (1.045 ** int) * 200;
			else if dataset = 'h' AND 6  <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'h' AND       int <= 0   then result = 150;	

				 if dataset = 'i' AND 0  <  int <= 2   then result = (1.045 ** int) * 195;
			else if dataset = 'i' AND 2  <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'i' AND 	    int <= 0   then result = 150;	
		end;

	/*	sample CD4 counts's for simulated observations that have HIV, are 	*/
	/*	diagnosied with AIDS, and are alive									*/
	else if oi_stage3_dt NE . AND dod = . then do;
				 if dataset = 'a' AND 0  <  int <= 31  then result = (1.045 ** int) * 50;
			else if dataset = 'a' AND 31 <  int <  999 then result = (1.045 ** int) * 50 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'a' AND 	    int <= 0   then result = 150;		

				 if dataset = 'b' AND 0  <  int <= 29  then result = (1.045 ** int) * 55;
			else if dataset = 'b' AND 29 <  int <  999 then result = (1.045 ** int) * 55 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'b' AND 	    int <= 0   then result = 150;	

				 if dataset = 'c' AND 0  <  int <= 27  then result = (1.045 ** int) * 65;
			else if dataset = 'c' AND 27 <  int <  999 then result = (1.045 ** int) * 65 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'c' AND 	    int <= 0   then result = 150;	

				 if dataset = 'd' AND 0  <  int <= 25  then result = (1.045 ** int) * 85;
			else if dataset = 'd' AND 25 <  int <  999 then result = (1.045 ** int) * 105 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'd' AND 	    int <= 0   then result = 150;	

				 if dataset = 'e' AND 0  <  int <= 18  then result = (1.045 ** int) * 115;
			else if dataset = 'e' AND 18 <  int <  999 then result = (1.045 ** int) * 130 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'e' AND 	    int <= 0   then result = 150;	

				 if dataset = 'f' AND 0  <  int <= 14  then result = (1.045 ** int) * 130;
			else if dataset = 'f' AND 14 <  int <  999 then result = (1.045 ** int) * 155 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'f' AND 	    int <= 0   then result = 150;	

				 if dataset = 'g' AND 0  <  int <= 8   then result = (1.045 ** int) * 140;
			else if dataset = 'g' AND 8  <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'g' AND 	    int <= 0   then result = 150;	

				 if dataset = 'h' AND 0  <  int <= 6   then result = (1.045 ** int) * 150;
			else if dataset = 'h' AND 6  <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'h' AND       int <= 0   then result = 150;	

				 if dataset = 'i' AND 0  <  int <= 2   then result = (1.045 ** int) * 195;
			else if dataset = 'i' AND 2  <  int <  999 then result = (1.045 ** int) * 180 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'i' AND 	    int <= 0   then result = 150;
		end;

	/*	sample CD4 counts's for simulated observations that have HIV, are 	*/
	/*	diagnosied with AIDS, and are not alive								*/
	else if oi_stage3_dt NE . AND dod NE . then do;
				 if dataset = 'a' AND 0  <  int <= 31  then result = (1.045 ** int) * 50;
			else if dataset = 'a' AND 31 <  int <  999 then result = (1.045 ** int) * 50 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'a' AND 	    int <= 0   then result = 150;		

				 if dataset = 'b' AND 0  <  int <= 29  then result = (1.045 ** int) * 55;
			else if dataset = 'b' AND 29 <  int <  999 then result = (1.045 ** int) * 55 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'b' AND 	    int <= 0   then result = 150;	

				 if dataset = 'c' AND 0  <  int <= 27  then result = (1.045 ** int) * 65;
			else if dataset = 'c' AND 27 <  int <  999 then result = (1.045 ** int) * 65 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'c' AND 	    int <= 0   then result = 150;	

				 if dataset = 'd' AND 0  <  int <= 25  then result = (1.045 ** int) * 85;
			else if dataset = 'd' AND 25 <  int <  999 then result = (1.045 ** int) * 105 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'd' AND 	    int <= 0   then result = 150;	

				 if dataset = 'e' AND 0  <  int <= 18  then result = (1.045 ** int) * 115;
			else if dataset = 'e' AND 18 <  int <  999 then result = (1.045 ** int) * 130 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'e' AND 	    int <= 0   then result = 150;	

				 if dataset = 'f' AND 0  <  int <= 14  then result = (1.045 ** int) * 130;
			else if dataset = 'f' AND 14 <  int <  999 then result = (1.045 ** int) * 155 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'f' AND 	    int <= 0   then result = 150;	

				 if dataset = 'g' AND 0  <  int <= 8   then result = (1.045 ** int) * 140;
			else if dataset = 'g' AND 8  <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'g' AND 	    int <= 0   then result = 150;	

				 if dataset = 'h' AND 0  <  int <= 6   then result = (1.045 ** int) * 150;
			else if dataset = 'h' AND 6  <  int <  999 then result = (1.045 ** int) * 175 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'h' AND       int <= 0   then result = 150;	

				 if dataset = 'i' AND 0  <  int <= 2   then result = (1.045 ** int) * 195;
			else if dataset = 'i' AND 2  <  int <  999 then result = (1.045 ** int) * 180 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'i' AND 	    int <= 0   then result = 150;
		end;

	/*	sample CD4 counts's for simulated observations that have HIV, are not	*/
	/*	diagnosied with AIDS, and are not alive									*/
	else if oi_stage3_dt = . AND dod NE . then do;
				 if dataset = 'a' AND 0  <  int <= 31  then result = (1.045 ** int) * 210;
			else if dataset = 'a' AND 31 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'a' AND 	    int <= 0   then result = 150;		

				 if dataset = 'b' AND 0  <  int <= 29  then result = (1.045 ** int) * 210;
			else if dataset = 'b' AND 29 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'b' AND 	    int <= 0   then result = 150;	

				 if dataset = 'c' AND 0  <  int <= 27  then result = (1.045 ** int) * 210;
			else if dataset = 'c' AND 27 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'c' AND 	    int <= 0   then result = 150;	

				 if dataset = 'd' AND 0  <  int <= 25  then result = (1.045 ** int) * 210;
			else if dataset = 'd' AND 25 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'd' AND 	    int <= 0   then result = 150;	

				 if dataset = 'e' AND 0  <  int <= 18  then result = (1.045 ** int) * 210;
			else if dataset = 'e' AND 18 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'e' AND 	    int <= 0   then result = 150;	

				 if dataset = 'f' AND 0  <  int <= 14  then result = (1.045 ** int) * 210;
			else if dataset = 'f' AND 14 <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'f' AND 	    int <= 0   then result = 150;	

				 if dataset = 'g' AND 0  <  int <= 8   then result = (1.045 ** int) * 210;
			else if dataset = 'g' AND 8  <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'g' AND 	    int <= 0   then result = 150;	

				 if dataset = 'h' AND 0  <  int <= 6   then result = (1.045 ** int) * 200;
			else if dataset = 'h' AND 6  <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'h' AND       int <= 0   then result = 150;	

				 if dataset = 'i' AND 0  <  int <= 2   then result = (1.045 ** int) * 195;
			else if dataset = 'i' AND 2  <  int <  999 then result = (1.045 ** int) * 90 + (100 * abs(rand("Normal", 0, 1)));
			else if dataset = 'i' AND 	    int <= 0   then result = 150;	
		end;
run;


proc sort data = dates9_CD4 
		  out  = dates10_CD4; 
	by count sample_dt; 
run;


data dates11_CD4;
	set dates10_CD4;
	if oi_stage3_dt NE . then do;
		if sample_dt >= oi_stage3_dt then result = 200 - 100*abs(rand("uniform"));
		end;

run;

proc sort data = dates11_CD4; 
	by count; 
run;


/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/


/*	Now that the labs for each combination of observation/sample date have been made, we will */
/*	merge these data sets together, but first adding components of the orignally simulated	  */
/*	PERSON data set																			  */
proc sort data = person_view; 
	by count; 
run;


data dates11_VL_merge;
	format 	ehars_uid 		document_uid 		  lab_test_cd 	receive_dt 
			sample_dt 		result_interpretation result 		result_units 
			specimen 		lab_test_type 		  dod;
	merge dates11_VL(in = a) person_view(in = b);
	by count;
	if a and b;
	receive_dt = sample_dt;
	format receive_dt yymmdd10.;
	/* Variables specific to Viral Load sample */
	specimen 	  = 'BLD';
	lab_test_type = '01'; 
	keep 	ehars_uid 		document_uid 		  lab_test_cd 	receive_dt 
			sample_dt 		result_interpretation result 		result_units 
			specimen 		lab_test_type 		  dod;
run;


data dates11_CD4_merge;
	format 	ehars_uid 		document_uid 		  lab_test_cd 	receive_dt 
			sample_dt 		result_interpretation result 		result_units 
			specimen 		lab_test_type 		  dod;
	merge dates11_CD4(in = a) person_view(in = b);
	by count;
	if a and b;
	receive_dt = sample_dt;
	format receive_dt yymmdd10.;
	/* Variables specific to CD4 Count sample */
	specimen 	  = 'BLD';
	lab_test_type = ''; 
	keep 	ehars_uid 		document_uid 		  lab_test_cd 	receive_dt 
			sample_dt 		result_interpretation result 		result_units 
			specimen 		lab_test_type 		  dod;
run;


data LAB_merge;
	set dates11_VL_merge dates11_CD4_merge;
run;


proc sort data = LAB_merge; 
	by ehars_uid receive_dt; 
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/



/*	Now that we have simulated the variables we need, each section below filters each		*/
/*	eHARS data set for the only variables therein. Additionally, all variables are 			*/
/*	converted to SAS CHARACTER formats with the appropriate lengths, to be a 				*/
/*	one-to-one match to what appears in the actual eHARS data sets. This is 				*/
/*	especially important, so that these data sets can be used in data manangement 			*/
/*	and analysis programs that would eventually be performed at State Health Departments.	*/



data FACILITY_EVENT_0;				
	count = 0;
	retain count;

	/*Variable Creation*/	
	call streaminit(&SEED_06); 	
	do i = 1 to &NSIM;
			sim_event_cd			= rand("Table", 0.2, 0.2, 0.2, 0.2, 0.2);
			sim_doc_belongs_to		= rand("Table", 0.33, 0.33, 0.33);

	/*	Create provider_uid variable */	
			provider_uid			=     '';

	/*	Create event_cd variable */	
				 if sim_event_cd = 1 then event_cd = '01';
			else if sim_event_cd = 2 then event_cd = '02';
			else if sim_event_cd = 3 then event_cd = '03';
			else if sim_event_cd = 4 then event_cd = '05';
			else if sim_event_cd = 5 then event_cd = '07';

	/*	Create doc_belongs_to variable */		
				 if sim_doc_belongs_to = 1 then doc_belongs_to = 'PERSON';
			else if sim_doc_belongs_to = 2 then doc_belongs_to = 'MOTHER';
			else if sim_doc_belongs_to = 3 then doc_belongs_to = 'CHILD';
			count + 1;
		output;
		end;
	drop sim_event_cd sim_doc_belongs_to;
run;


proc sort data = FACILITY_EVENT_0; 	by count; run;
proc sort data = person_view; 		by count; run;


/*merging data sets to prevent re-simulating variables that appear in both data sets*/
data &FACILITY_EVENT;
	length 	doc_belongs_to		$7.
			document_uid		$16.
			event_cd			$2.
			facility_uid		$16.
			provider_uid		$16.		;
	
	label	doc_belongs_to		=    "Indicates if the facility event data  belong to PERSON or CHILDn."
			document_uid		=    "Identifies the document associated with a record stored on the table; document_uid is a unique value generated by eHARS to identify a document."
			event_cd			=    "A code that indicates the type of event that occurred."
			facility_uid		=    "The facility associated with a specific event' facility_uid is a unique value generated by eHARS to identify a facility."
			provider_uid		=    "Identifies the provider associated with an event; a unique value generated by eHARS to identify a provider. "         		;
	format ehars_uid event_cd facility_uid doc_belongs_to EVENT_CD document_uid;
	merge person_view(rename = (hf_facility_uid = faciltiy_uid )) FACILITY_EVENT_0;
	by count;
	if ehars_uid = '' then delete;
	keep ehars_uid event_cd facility_uid doc_belongs_to EVENT_CD document_uid;;
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/



data &FACILITY_CODE;
	length 	ehars_uid			$16.
			facility_uid		$16.
			name1				$100.
			name2				$100.;

	label	ehars_uid			=	"Identifies the person associated with each document; ehars_uid is a unique value generated by eHARS."
			facility_uid		=   "The facility associated with a specific event facility_uid is a unique value generated by eHARS to identify a facility."
			name1				=   "Primary name of a facility."         	
			name2				= 	"Secondary or alternative name of a facility.";

	set person_view(rename = (hf_facility_uid = faciltiy_uid ));
	keep ehars_uid facility_uid name1 name2;
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/



data &DOCUMENT;	
	length 	document_uid		$16.
			ehars_uid			$16.
			rep_hlth_dept_cd	$7.
			status_flag			$1.;

	label	document_uid		=    "A unique value generated by eHARS to identify a document."
			ehars_uid			=    "Identifies the person associated with each document; ehars_uid is a unique value generated by eHARS."                                                             
			rep_hlth_dept_cd	=    "The name of the reporting health department."
			status_flag			=    "A code indicating whether the report was obtained via active or passive surveillance."		;

	format ehars_uid document_uid facility_uid rep_hlth_dept_cd status_flag;
	set person_view(rename = (hf_facility_uid = faciltiy_uid rsa_state_cd = rep_hlth_dept_cd));
	keep ehars_uid document_uid facility_uid rep_hlth_dept_cd status_flag;
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/



data &ADDRESS;
	merge person_view(rename = (rsa_state_cd 	  	= state_cd
							    rsa_county_name 	= county_name
							    rsa_county_fips 	= county_fips
							    rsa_zip_cd 	  		= zip_cd))

		  &FACILITY_EVENT(keep = doc_belongs_to);

	keep ehars_uid state_cd county_name county_fips zip_cd address_type_cd doc_belongs_to document_uid;
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/



proc sort data = dates; 	  by count; run;
proc sort data = person_view; by count; run;


data calc_observation;
	merge person_view(keep = ehars_uid document_uid count race trans_categ) 
		  dates		 (keep = count aids_rep_dt hiv_aids_dx_dt hiv_aids_age_yrs OI_stage3_dt);
	by count;
	aids_dx_dt = aids_rep_dt;
	format aids_dx_dt yymmdd10.;
	if ehars_uid NE '';

	char_aids_rep_dt 	  = compress(put(aids_rep_dt,yymmdd10.),'-');
	char_hiv_aids_dx_dt   = compress(put(hiv_aids_dx_dt,yymmdd10.),'-');
	char_hiv_aids_age_yrs = compress(put(hiv_aids_age_yrs,8.));
	char_OI_stage3_dt 	  = compress(put(OI_stage3_dt,yymmdd10.),'-');

	if char_aids_rep_dt NE '' then do;
			calc_obs_uid_01 = '281';
			calc_obs_value_01 = char_aids_rep_dt;
		end;

	if char_hiv_aids_dx_dt NE '' then do;
			calc_obs_uid_02 = '285';
			calc_obs_value_02 = char_hiv_aids_dx_dt;
		end;

	if trans_categ NE '' then do;
			calc_obs_uid_03 = '221';
			calc_obs_value_03 = trans_categ;
		end;

	if race NE '' then do;
			calc_obs_uid_04 = '218';
			calc_obs_value_04 = race;
		end;

	if char_hiv_aids_age_yrs NE '' then do;
			calc_obs_uid_05 = '278';
			calc_obs_value_05 = char_hiv_aids_age_yrs;
		end;

	if char_OI_stage3_dt NE '' then do;
			calc_obs_uid_06 = '282';
			calc_obs_value_06 = char_OI_stage3_dt;
		end;

run;


data calc_aids_rep_dt;
	set calc_observation(rename = (calc_obs_uid_01 = calc_obs_uid
								   calc_obs_value_01 = calc_obs_value));
	where calc_obs_value NE '.';
	keep ehars_uid document_uid calc_obs_uid calc_obs_value;
run;


data calc_hiv_aids_dx_dt;
	set calc_observation(rename = (calc_obs_uid_02 = calc_obs_uid
								   calc_obs_value_02 = calc_obs_value));
	where calc_obs_value NE '.';
	keep ehars_uid document_uid calc_obs_uid calc_obs_value;
run;


data calc_trans_categ;
	set calc_observation(rename = (calc_obs_uid_03 = calc_obs_uid
								   calc_obs_value_03 = calc_obs_value));
	where calc_obs_value NE '.';
	keep ehars_uid document_uid calc_obs_uid calc_obs_value;
run;


data calc_race;
	set calc_observation(rename = (calc_obs_uid_04 = calc_obs_uid
								   calc_obs_value_04 = calc_obs_value));
	where calc_obs_value NE '.';
	keep ehars_uid document_uid calc_obs_uid calc_obs_value;
run;


data calc_hiv_aids_age_yrs;
	set calc_observation(rename = (calc_obs_uid_05 = calc_obs_uid
								   calc_obs_value_05 = calc_obs_value));
	where calc_obs_value NE '.';
	keep ehars_uid document_uid calc_obs_uid calc_obs_value;
run;


data calc_OI_stage3_dt;
	set calc_observation(rename = (calc_obs_uid_06 = calc_obs_uid
								   calc_obs_value_06 = calc_obs_value));
	where calc_obs_value NE '.';
	keep ehars_uid document_uid calc_obs_uid calc_obs_value;
run;


proc sort data = calc_aids_rep_dt; 		by ehars_uid; run;
proc sort data = calc_hiv_aids_dx_dt; 	by ehars_uid; run;
proc sort data = calc_trans_categ; 		by ehars_uid; run;
proc sort data = calc_race; 			by ehars_uid; run;
proc sort data = calc_hiv_aids_age_yrs; by ehars_uid; run;
proc sort data = calc_OI_stage3_dt; 	by ehars_uid; run;


data CALC_OBSERVATION;
	length 	calc_obs_uid	$16.
			calc_obs_value	$100.
			document_uid	$16.		;

	label	calc_obs_uid	=    "A unique identifier for a calculated observation."
			calc_obs_value	=    "The calculated observation's value."
			document_uid	=    "A unique value generated by eHARS to identify a document.";

	format document_uid calc_obs_uid calc_obs_value;
	set calc_aids_rep_dt calc_hiv_aids_dx_dt calc_trans_categ calc_race calc_hiv_aids_age_yrs calc_OI_stage3_dt;
	by ehars_uid;
	keep ehars_uid document_uid calc_obs_uid calc_obs_value;
run;

proc sort data = CALC_OBSERVATION
		  out  = &CALC_OBSERVATION; 
	by ehars_uid calc_obs_uid; 
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/



data death;
	set LAB_merge;
	where dod NE .;
run;

proc sort data = death nodupkey; by dod; run;

data &DEATH;
	length 	document_uid	$16.
			dod				$8.		;

	label	document_uid	=    "A unique value generated by eHARS to identify a document."
			dod				=    "A person's date of death.";

	format ehars_uid document_uid dod;
	set death(rename = (dod = dod_num));
	dod = compress(put(dod_num,yymmdd10.),'-');
	keep ehars_uid document_uid dod;
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/



proc sort data = person_view; by ehars_uid; run;
proc sort data = &DEATH;   by ehars_uid; run;


data &PERSON;
	format ehars_uid rsh_state_cd	rsh_county_name rsh_county_fips rsa_state_cd
		rsa_county_name rsa_county_fips education hiv_insurance aids_insurance
		current_gender trans_categ race dod 					
		birth_sex vital_status af_facility_uid hf_facility_uid 	;

	merge person_view doc.death(keep = ehars_uid dod);
	by ehars_uid;

		 if dod =  '' then vital_status = '1';
	else if dod NE '' then vital_status = '2';
	else 				  vital_status = '9';

	keep ehars_uid rsh_state_cd	rsh_county_name rsh_county_fips rsa_state_cd
		rsa_county_name rsa_county_fips education hiv_insurance aids_insurance
		current_gender trans_categ race dod 					
		birth_sex vital_status af_facility_uid hf_facility_uid 	;
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/



proc sort data = LAB_merge out = lab; by ehars_uid; run;
proc sort data = &FACILITY_EVENT; by ehars_uid; run;


data lab2;
	set lab(rename = (sample_dt = sample_dt_lab result = result_lab));
	sample_dt = compress(put(sample_dt_lab,yymmdd10.),'-');
	result = put(result_lab, best10.);
run;


data LAB3;
	length 	document_uid	$16.
			lab_test_cd		$7.
			result			$10.
			result_interpretation	$100.
			result_units	$4.
			sample_dt		$8.
			specimen		$3.
			lab_test_type	$3.
			facility_uid	$16.;

	label	document_uid	=   "A unique value generated by eHARS to identify a document."
			lab_test_cd		=	"The unique identifier for a lab test, such as EC-001 (the HIV-1 IA [EIA or Other] lab test)."
			result			=	"The result value, which could be characters, such as POS, or numbers, such as 10.000 (for STARHS SOD)."
			result_interpretation	=	"An interpretation of the lab result. For viral load tests, values include: (<) Undetectable - below limit; (=) Detectable - within limits; (>) Detectable - above limit"
			result_units	=	"The reported units."
			sample_dt		=	"The date the specimen was collected."
			specimen		=	"The type of specimen collected."
			lab_test_type	=	"The type of viral load test."
			facility_uid	=	"The facility associated with a specific event' facility_uid is a unique value generated by eHARS to identify a facility.";

	format ehars_uid document_uid lab_test_cd result result_interpretation SAMPLE_DT result_units facility_uid specimen;
	merge lab2(in = a) doc.facility_event(keep = ehars_uid facility_uid);
	by ehars_uid;
	if a;
	keep ehars_uid lab_test_cd lab_test_type result result_interpretation SAMPLE_DT result_units facility_uid specimen;
run;


proc sort data = person_view; by ehars_uid; run;
proc sort data = lab3; 		  by ehars_uid; run;


data &LAB;
	length 	document_uid	$16.
			lab_test_cd		$7.
			result			$10.
			result_interpretation	$100.
			result_units	$4.
			sample_dt		$8.
			specimen		$3.
			lab_test_type	$3.
			facility_uid	$16.;

	label	document_uid	=   "A unique value generated by eHARS to identify a document."
			lab_test_cd		=	"The unique identifier for a lab test, such as EC-001 (the HIV-1 IA [EIA or Other] lab test)."
			result			=	"The result value, which could be characters, such as POS, or numbers, such as 10.000 (for STARHS SOD)."
			result_interpretation	=	"An interpretation of the lab result. For viral load tests, values include: (<) Undetectable - below limit; (=) Detectable - within limits; (>) Detectable - above limit"
			result_units	=	"The reported units."
			sample_dt		=	"The date the specimen was collected."
			specimen		=	"The type of specimen collected."
			lab_test_type	=	"The type of viral load test."
			facility_uid	=	"The facility associated with a specific event' facility_uid is a unique value generated by eHARS to identify a facility.";

	format ehars_uid document_uid lab_test_cd lab_test_type result result_interpretation SAMPLE_DT result_units facility_uid specimen;
	merge lab3(in = a) person_view(in = b);
	by ehars_uid;
	if a and b;
	keep ehars_uid document_uid lab_test_cd lab_test_type result result_interpretation SAMPLE_DT result_units facility_uid specimen;
run;



/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/
/*=====================================================================================================================================================*/

