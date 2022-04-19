
/*=========================================================================*/
*	PROGRAM NAME:	eHARS Data Management - Viral Suppression #.#		 	;	
*																		    ;
*	DESCRIPTION:	To create an analysis ready data set based on simulated ;
*					eHARS data with the specific aim of determining a 		;
*					PWH time to viral suppression from initial HIV 			;
*					diagnosis. This is determined with the following		;
*					explicit inclusions:									;
*						1) 	Diagnosis in 2012, 2013, 2014, 2015, 2016, 2017,;
*							2018, 2019										;
* 						2) 	Exclude cases with missing month of diagnosis 	;
*							date and death date								;
*						3) 	Exclude cases with death dates before the 		;
*							diagnosis date                   				;
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
*	DATE CREATED:	04/06/2022											 	;
*	DATE UPDATED:														 	;
*																		    ;
*	VERSION UPDATES:													 	;
*																		    ;
*																		    ;
*	LICENSE			This work is licensed under the Creative Commons 		;
*					Attribution-NonCommercial-ShareAlike 4.0 International 	;
*					License. To view a copy of this license, visit 			;
*					http://creativecommons.org/licenses/by-nc-sa/4.0/ or 	;
*					send a letter to Creative Commons, 						;
*					PO Box 1866, Mountain View, CA 94042, USA.				;
*																		    ;
*																		    ;
*	DISCLAIMER		This program is distributed with hope that you will	 	;
*					find it useful, and is open for collaboration. 		 	;
*					Please note that while distributed in good faith,  	 	;
*					this program is WITHOUT ANY WARRANTY - without even  	;
*					the implied warranty of MERCHANTABILITY or FITNESS 	 	;
*					FOR A PARTICULAR PURPOSE. 							 	;
*																		    ;
/*=========================================================================*/


options pageno     		= 	1 		          
		yearcutoff 		= 	1915      
		compress   		= 	yes 
		reuse      		= 	yes 
		mcompilenote 	= 	noautocall 
		nofmterr 		          
		workterm 		          	          
		Threads                       
		mlogic                    
		mprint                    
		symbolgen                 
		mprintnest                
		mlogicnest;               
        goptions 
        gaccess 		= 	gsasfile 
        device 			= 	win 
        target 			= 	winprtm 
        rotate 			= 	landscape 
        ftext 			= 	swiss;

%let year1 				= 	2012;
%let year2 				= 	2013;
%let year3 				= 	2014;
%let year4				= 	2015;
%let year5				= 	2016;
%let year6				= 	2017;
%let year7				= 	2018;
%let year8				= 	2019;
%let year9				= 	2020;
%let censor_dt 			= 	20191231;
%let cutoff_VL 			= 	200;
%let CD4code 			= 	('EC-016','EC-017');
%let VLcode 			= 	('EC-014','L-010','L-011'); 
%let censor_date 		= 	'31DEC2019'D;

/*=======================================================================*/
/* This can be changed to be re-run for any of the three states included */
/* in the simulated data set, Alabama, Mississippi, Louisiana			 */
/*NOTE**** the following code is Alabama specific, this will effect the  */
/*		   creation of the Public Health Area/Distric variable that is	 */
/*		   specific to each state. Code to create this variable for 	 */
/*		   Louisiana Mississippi is available upon request.				 */
*										 								  ;

%let state	=	AL;									 				
%let site 	= 	SIMULATION;

/*======================================================================*/
/* This path would be a specific location that you designate as the 	*/
/* location for the results												*/
*																		 ;

%let path = YOUR-FILEPATH-GOES-HERE;


/*======================================================================*/
*				File location(s) of original datasets					 ;
/*======================================================================*/
*																		 ;
/* These librefs need to be the location that the simulated data sets 	*/
/* are save to. There are multiple librefs as health deparments will 	*/
/* typically house these data sets in seperate folders					*/
libname person 	"&path";
libname doc 	"&path";


/*======================================================================*/
*			  			  File location of output						 ;
/*======================================================================*/

options dlcreatedir; 
libname out 			"&path.\eHARS &Sysdate.";
libname dataout 		"&path.\eHARS &Sysdate.\Data";					/* Identifiable data location (if this code was used at public health department */
libname datasend 		"&path.\eHARS &Sysdate.\Datasend &Sysdate.";	/* Location of shareable - or nonidentifiable data */
libname output 			"&path.\eHARS &Sysdate.\Output &Sysdate.";		
%let location_output =   &path;
filename 	log      	"&location_output\eHARS Data Management Log &Sysdate..log";


/*======================================================================*/
*	eHARS Data Set			Variable Name			SAS Data Set		 ;
*																		 ;
*	doc.Document			ehars_uid				doc_pv				 ;
*							document_uid								 ;
*																		 ;
*	doc.Address				address_type_cd			address				 ;
*							state_cd									 ;
*							county_name									 ;
*							county_fips									 ;
*																		 ;
*	doc.Calc_observation	calc_obs_uid			calc_observation	 ;
*							calc_obs_value								 ;
*																		 ;
*	doc.Person				birth_sex				person				 ;
*							vital_status								 ;
*																		 ;
*	doc.Death				dod						death				 ;
*																		 ;
*	doc.Facility_event		event_cd				facility_dx			 ;
*							facility_uid								 ;
/*======================================================================*/

proc sql;
  	create table doc_pv 			as select 	ehars_uid, 
         										document_uid, 
												status_flag		from doc.document where rep_hlth_dept_cd = "&state.";				/* ### */
  	create table address 			as select 	a.ehars_uid, 
         										address_type_cd, 
         										state_cd, 
         										county_name, 
         										county_fips,  	
												zip_cd from doc_pv 																	
									as a left join doc.address (where = (address_type_cd in ('RSA','RSH') and doc_belongs_to = 'PERSON')) 
									as b on a.document_uid = b.document_uid;
	create table calc_observation 	as select 	a.ehars_uid, 
         										calc_obs_uid, 
         										calc_obs_value 	from doc_pv 
									as a left join doc.calc_observation (where = (calc_obs_uid in ('221','285','218','281','278','282'))) 
									as b on a.document_uid = b.document_uid;
	create table death 				as select 	a.ehars_uid, 
         										dod from 			doc_pv 
									as a left join doc.death 
									as b on a.document_uid = b.document_uid;
	create table facility_dx 		as select 	a.ehars_uid, 
  										       	b.event_cd, 
         										b.facility_uid from doc_pv 
									as a left join doc.facility_event (where = (doc_belongs_to = 'PERSON' and EVENT_CD in ('01','02'))) 
									as b on a.document_uid = b.document_uid;	
quit;

/*======================================================================*/
*		  		    Calc Observation dates and values					 ;
/*======================================================================*/
*	Variables used from calc_observation SAS data set:					 ;
*		ehars_uid, calc_obs_uid											 ;
*																		 ;
*	Variables Created:													 ;
*		race, trans_categ, hiv_aids_age_yrs, aids_dx_dt, 				 ;
*		hiv_aids_dx_dt, OI_stage3_dt									 ;
/*======================================================================*/

proc sort data = calc_observation out = calc_observationx nodupkey; 
  by ehars_uid calc_obs_uid; 
run;

data calc_obs_vars 
	(keep = ehars_uid			hiv_aids_dx_dt		aids_dx_dt 
            OI_stage3_dt		trans_categ 		race 
            hiv_aids_age_yrs);

	length 	hiv_aids_dx_dt 		aids_dx_dt 			OI_stage3_dt $8 
         	race $2 	        trans_categ $2      hiv_aids_age_yrs $3;

  	retain 	hiv_aids_dx_dt 	aids_dx_dt 		OI_stage3_dt 	race 
			trans_categ 	hiv_aids_age_yrs;
  	set calc_observationx;
  	by ehars_uid;
  		if first.ehars_uid then do;
				race = ' ';
				trans_categ = ' ';
				hiv_aids_age_yrs = ' '; 
				aids_dx_dt = ' '; 
				hiv_aids_dx_dt = ' ';
				OI_stage3_dt = ' ';
  			end;

  	if      calc_obs_uid = '281' then aids_dx_dt       = calc_obs_value;
  	else if calc_obs_uid = '285' then hiv_aids_dx_dt   = calc_obs_value;
  	else if calc_obs_uid = '221' then trans_categ      = calc_obs_value;
  	else if calc_obs_uid = '218' then race             = calc_obs_value;
  	else if calc_obs_uid = '278' then hiv_aids_age_yrs = calc_obs_value;
  	else if calc_obs_uid = '282' then OI_stage3_dt     = calc_obs_value;

	if last.ehars_uid;
run;

/*======================================================================*/
*							  RSD variables								 ;
/*======================================================================*/
*	Variables used from address SAS data set:							 ;
*		ehars_uid, address_type_cd										 ;
*																		 ;
*	Variables Created:													 ;
*		rsh_state_cd, rsh_county_name, rsh_county_fips, rsa_state_cd,	 ;
*		rsa_county_name, rsa_county_fips								 ;
/*======================================================================*/

proc sort data = address 
	out = addressx nodupkey; 
  	by ehars_uid address_type_cd; 
run;

data address1 
	(keep = ehars_uid			rsh_state_cd		rsh_county_name 
            rsh_county_fips   	rsh_zip_cd			rsa_state_cd    	
			rsa_county_name 	rsa_county_fips		rsa_zip_cd);								

	length 	rsh_state_cd $2		rsh_county_name $64	rsh_county_fips $3	rsh_zip_cd	$10			
	     	rsa_state_cd $2     rsa_county_name $64 rsa_county_fips $3	rsa_zip_cd	$10;			

  	retain 	rsh_state_cd 		rsh_county_name 	rsh_county_fips 	rsh_zip_cd
			rsa_state_cd 		rsa_county_name 	rsa_county_fips		rsa_zip_cd;
  	set addressx;
  	by ehars_uid;
  	if 	first.ehars_uid then do;
			rsh_state_cd 	= ' ';
			rsh_county_name = ' ';
			rsh_county_fips = ' ';
			rsh_zip_cd		= ' ';
			rsa_state_cd 	= ' ';
			rsa_county_name = ' ';
			rsa_county_fips = ' ';
			rsa_zip_cd		= ' ';
  		end;

  	if 		address_type_cd = 'RSH' then do;
			rsh_state_cd 	= state_cd;
			rsh_county_name = county_name;
			rsh_county_fips = county_fips;
			rsh_zip_cd 		= zip_cd;												
  		end;

  	else if address_type_cd = 'RSA' then do;
			rsa_state_cd 	= state_cd;
			rsa_county_name = county_name;
			rsa_county_fips = county_fips;
			rsa_zip_cd 		= zip_cd;												
end;

  if last.ehars_uid;
run;

/*======================================================================*/
*							Diagnosis facility							 ;
/*======================================================================*/
*	Variables used from facility_dx SAS data set:						 ;
*		ehars_uid, facility_uid, event_cd								 ;
*																		 ;
*	Variables used from person SAS data set:							 ;
*		ehars_uid, birth_sex, 											 ;
*																		 ;
*	Variables used from death SAS data set:								 ;
*		ehars_uid, dod													 ;
*																		 ;
*	Variables used from address1 SAS data set:							 ;
*		ehars_uid, rsd_state_cd, rsd_county_name, rsd_county_fips		 ;
*																		 ;
*	Variables used from calc_obs_vars SAS data set:						 ;
*		ehars_uid, hiv_aids_age_yrs, race, trans_categ, OI_stage3_dt	 ;
*																		 ;
*	Variables Created:													 ;
*		rsd_state_cd, rsd_county_name, rsd_county_fips					 ;
*		df_facility_uid, hf_facility_uid, af_facility_uid,				 ;
*		dxyr, dxmo, dthyr, dthmo, diff_m,								 ;
*		sex, age_grp, grace, mode,										 ;
*		OIyr, OImo, diff_m, stage3										 ;
/*======================================================================*/

proc sort data = facility_dx 
	out = facility_dxx nodupkey; 
  	by ehars_uid event_cd; 
run;

proc transpose data = facility_dxx 
	out = facility_dx1 (keep 	= 	ehars_uid	
									_01
                                	_02 
                        rename 	=  (_01 = hf_facility_uid 
                                    _02 = af_facility_uid)) ;
	var facility_uid;
  	id event_cd;
  	by ehars_uid;
run;

data personview;
	set person.person;

	race_person = race;
		
	keep 	ehars_uid 			/*	eHARS unique identifier								*/		
			rsh_state_cd		/*	State of residence at HIV diagnosis 				*/		
			rsh_county_name 	/*	County of residence at HIV diagnosis				*/		
			rsh_county_fips 	/*	County FIPS code of residence at HIV diagnosis		*/		
			rsa_state_cd 		/*	State of residence at AIDS diagnosis				*/		
			rsa_county_name 	/*	County of residence at AIDS diagnosis				*/		
			rsa_county_fips 	/*	County FIPS code of residence at AIDS diagnosis		*/		
			education			/*	Education level										*/	
			hiv_insurance		/*	Primary reimbursement for medical treatment (HIV)	*/	
			aids_insurance		/*	Primary reimbursement for medical treatment (AIDS)	*/		
			current_gender		/*	Current gender										*/	
			transx_categ		/*	Expanded transmission category						*/	
			race_person			/*	Race												*/		
			transgender_ever	/*	Ever transgender or additional gender identity		*/		
			dod 				/*	Date of death										*/		
			birth_sex 			/*	Sex at birth										*/		
			vital_status 		/*	The vital status of the patient						*/		
			af_facility_uid 	/*	ID of facility at AIDS diagnosis					*/		
			hf_facility_uid 	/*	ID of facility at HIV diagnosis						*/		
			;
run; 

proc sort data = personview;  	by ehars_uid; 	run;

data personx 
	(drop = rsh_state_cd 		rsh_county_name 	rsh_county_fips 		
            rsa_state_cd    	rsa_county_name 	rsa_county_fips 		
            hf_facility_uid 	af_facility_uid);

	merge 	calc_obs_vars 	personview;
  	by ehars_uid; 

/*======================== Create RSD_ variables =======================*/

	if 	rsh_state_cd 		^= ' ' then do;
			rsd_state_cd 	= rsh_state_cd;
			rsd_county_name = rsh_county_name;
			rsd_county_fips = rsh_county_fips;
  		end;
  	else if rsa_state_cd 	^= ' ' then do;
			rsd_state_cd 	= rsa_state_cd;
			rsd_county_name = rsa_county_name;
			rsd_county_fips = rsa_county_fips;
  		end;
  	if rsd_state_cd = "&state.";													/* ### */ 

/*================ Create df_ variables (facility at dx) ================*/

  	if		hf_facility_uid ^= ' ' then df_facility_uid = hf_facility_uid;
  	else if af_facility_uid ^= ' ' then df_facility_uid = af_facility_uid;

/*=============================== Dates =================================*/

	day1  = compress(substr(HIV_AIDS_DX_DT,7,2));
		if day1 ^= '..' then dxday = input(day1,2.0);
		else if day1  = '..' then dxday = 1;						
	mon1  = substr(HIV_AIDS_DX_DT,5,2);
		if mon1 ^= '..' then dxmo = input(mon1,2.0);
		else if mon1  = '..' then dxmo = 1;						
	yr1  = compress(substr(HIV_AIDS_DX_DT,1,4));
		if yr1 ^= '....' then dxyr = input(yr1,4.0);
		else if yr1 = '....' then dxyr=1900;
		if dxday ^= . and dxmo ^= . and dxyr ^= . then HIVDATE = mdy(dxmo,dxday,dxyr);
			format HIVDATE date9.;

	day2  = compress(substr(dod,7,2));
		if day2 ^= '..' then dthday = input(day2,2.0);
		else if day2  = '..' then dthday = 1;				
	mon2  = substr(dod,5,2);
		if mon2 ^= '..' then dthmo = input(mon2,2.0);
		else if mon2  = '..' then dthmo = 1;					
	yr2  = compress(substr(dod,1,4));
		if yr2 ^= '....' then dthyr = input(yr2,4.0);
		else if yr2 = '....' then dthyr=1900;

		if dthday ^= . and dthmo ^= . and dthyr ^= . then DTHDATE = mdy(dthmo,dthday,dthyr);
			format DTHDATE date9.;

/*=============== Exclude cases with death year before 2011 =============*/

	if dxyr in (&year1.,&year2.,&year3.,&year4.,&year5.,&year6.,&year7.,&year8.) then criteria1 = 'Meets Criteria: Within Study Years'; 
 	if (dthyr >= 2011 or dthyr = .) then criteria2 = 'Meets Criteria: Death Year'; 
	if  hiv_aids_age_yrs >= 13 then criteria3 = 'Meets Criteria: Age'; 
	if criteria1 ^=" " and criteria2^= " " and criteria3 ^= " ";

/*================= Remove persons dead before diagnosis ================*/

  	if dthyr ^= . and DTHDATE < HIVDATE then delete;			

/*= Remove cases with missing months of diagnosis and death (if dead)   =*/
/*=	XX (XX%) cases with missing dxmo are removed and no dead case has   =*/
/*= missing dthmo =======================================================*/

  	if (dxmo in (0,.)) or (dthyr ne . and  dthmo in (.,0) ) then delete;
  	dummy = 1 ;

/*================================= Sex ================================*/

  	if      birth_sex = 'M' then sex = 1;
  	else if birth_sex = 'F' then sex = 2;

/*============================== Age group =============================*/

  	if      13 <= hiv_aids_age_yrs <= 19 then age_grp = 1;
  	else if 20 <= hiv_aids_age_yrs <= 29 then age_grp = 2;
  	else if 30 <= hiv_aids_age_yrs <= 39 then age_grp = 3;
  	else if 40 <= hiv_aids_age_yrs <= 49 then age_grp = 4;
  	else if 50 <= hiv_aids_age_yrs <= 59 then age_grp = 5;
  	else if       hiv_aids_age_yrs >  59 then age_grp = 6;

  	if      13 <= hiv_aids_age_yrs <= 24 then age_grp2 = 1;
  	else if 24 <= hiv_aids_age_yrs <= 44 then age_grp2 = 2;
  	else if 	  hiv_aids_age_yrs >  44 then age_grp2 = 3;

/*============================== Race group ============================*/

  	if      race = '1' then grace = 1; 			/*Hispanic/Latino*/
  	else if race = '4' then grace = 2; 			/*Black*/
  	else if race = '6' then grace = 3; 			/*White*/
  	else                    grace = 4; 			/*Other races*/

/*======================== Transmission category =======================*/

  	if      trans_categ = '01' then mode = 1; 			/*MSM*/
  	else if trans_categ = '02' then mode = 2; 			/*IDU*/
  	else if trans_categ = '03' then mode = 3; 			/*MSM&IDU*/
  	else if trans_categ = '05' then mode = 4; 			/*Heter*/
  	else                            mode = 5; 			/*Other*/

  	if      trans_categ = '01' 		  then mode2 = 1; 	/*MSM Only*/
  	else if trans_categ in('02','03') then mode2 = 2; 	/*IDU or IDU&MSM*/
  	else if trans_categ = '05' 		  then mode2 = 3; 	/*Heter*/
  	else                            	   mode2 = 4; 	/*Other*/


/*============== Re-assign counties by their names (PHA) ===============*/
	******* This is specific to Alabama *******;
	*Mississippi and Louisiana are included - but commented out;

  	if      upcase(rsd_county_name) in ('JEFFERSON CO.', 'ORLEANS CO.', 'ST. BERNARD CO.', 'PLAQUEMINES CO.')                       then PHA = 1;
  	else if upcase(rsd_county_name) in ('WEST FELICIANA CO.', 'EAST FELICIANA CO.', 'POINTE COUPEE CO.', 'WEST BATON ROUGE CO.', 
										'EAST BATON ROUGE CO.',	'IBERVILLE CO.', 'ASCENSION CO.')    								then PHA = 2;
  	else if upcase(rsd_county_name) in ('ST. MARY CO.', 'ASSUMPTION CO.', 'ST. JAMES CO.', 'ST. JOHN CO.', 'ST. CHARLES CO.', 
										'TERREBONNE CO.', 'LAFOURCHE CO.') 								                            then PHA = 3;
  	else if upcase(rsd_county_name) in ('EVANGELINE CO.', 'ST. LANDRY CO.', 'ACADIA CO.', 'LAFAYETTE CO.', 'ST. MARTIN CO.', 
										'VERMILION CO.', 'IBERIA CO.')  							                                then PHA = 4;
  	else if upcase(rsd_county_name) in ('BEAUREGARD CO.', 'ALLEN CO.', 'CALCASIEU CO.', 'JEFFERSON DAVIS CO.', 'CAMERON CO.')		then PHA = 5;
  	else if upcase(rsd_county_name) in ('WINN CO.', 'GRANT CO.', 'LASALLE CO.', 'CATAHOULA CO.', 'CONCORDIA CO.', 'VERNON CO.',
										'RAPIDES CO.', 'AVOYELLES CO.') 															then PHA = 6;
  	else if upcase(rsd_county_name) in ('CADDO CO.', 'BOSSIER CO.', 'WEBSTER CO.', 'CLAIBORNE CO.', 'BIENVILLE CO.', 
										'DESOTO CO.', 'RED RIVER CO.', 'SABINE CO.', 'NATCHITOCHES CO.')           					then PHA = 7;
  	else if upcase(rsd_county_name) in ('LINCOLN CO.', 'UNION CO.', 'MOREHOUSE CO.', 'WEST CARROLL CO.', 'EAST CARROLL CO.',
										'JACKSON CO.', 'OUACHITA CO.', 'RICHLAND CO.', 'MADISON CO.', 'CALDWELL CO.',
										'FRANKLIN CO.', 'TENSAS CO.')        														then PHA = 8;
  	else if upcase(rsd_county_name) in ('ST. HELENA CO.', 'LIVINGSTON CO.', 'TANGIPAHOA CO.', 'WASHINGTON CO.', 'ST. TAMMANY CO.')	then PHA = 9;
  	else if upcase(rsd_county_name) = 'UNKNOWN'                                                                                     then PHA = 99;

/*MISSISSIPPI*/

/*  	if      upcase(rsd_county_name) in ('DE SOTO CO.',	'TUNICA CO.',	'TATE CO.',	'COAHOMA CO.',	'QUITMAN CO.',	*/
/*										'PANOLA CO.',	'TALLAHATCHIE CO.',	'YALOBUSHA CO.',	'GRENADA CO.') 		THEN PHA = 1;*/
/*	else if upcase(rsd_county_name) in ('MARSHALL CO.',	'BENTON CO.',	'TIPPAH CO.',	'ALCORN CO.',	*/
/*										'TISHOMINGO CO.',	'PRENTISS CO.',	'LAFAYETTE CO.',	'UNION CO.',	*/
/*										'LEE CO.',	'PONTOTOC CO.',	'ITAWAMBA CO.')			 						THEN PHA = 2;*/
/*	else if upcase(rsd_county_name) in ('BOLIVAR CO.',	'WASHINGTON CO.',	'SUNFLOWER CO.',	'LEFLORE CO.',	*/
/*										'CARROLL CO.',	'MONTGOMERY CO.',	'HUMPHREYS CO.',	'HOLMES CO.',	*/
/*										'ATTALA CO.') 																THEN PHA = 3;*/
/*	else if upcase(rsd_county_name) in ('CALHOUN CO.',	'CHICKASAW CO.',	'MONROE.',	'WEBSTER CO.',	*/
/*										'CLAY CO.',	'CHOCTAW CO.',	'CLAY CO.',	'OKTIBBEHA CO.', 'LOWNDES CO.',	*/
/*										'WINSTON CO.',	'NOXUBEE CO.')						 						THEN PHA = 4;*/
/*	else if upcase(rsd_county_name) in ('ISSAQUENA CO.',	'SHARKEY CO.',	'YAZOO CO.',	'WARREN CO.',	*/
/*										'MADISON CO.',	'HINDS CO.',	'RANKIN CO.',	'CLAIBORNE CO.',*/
/*										'COPIAH CO.',	'SIMPSON CO.') 												THEN PHA = 5;*/
/*	else if upcase(rsd_county_name) in ('LEAKE CO.',	'NESHOBA CO.',	'KEMPER CO.',	'SCOTT CO.','NEWTON CO.',	*/
/*										'LAURDERDALE CO.',	'SMITH CO.',	'JASPER CO.',	'CLARKE CO.') 			THEN PHA = 6;*/
/*	else if upcase(rsd_county_name) in ('JEFFERSON CO.',	'ADAMS CO.',	'FRANKLIN CO.',	'LINCOLN CO.',	*/
/*										'LAWERENCE CO.','WILKINSON CO.','AMITE CO.','PIKE CO.',	'WALTHALL CO.') 	THEN PHA = 7;*/
/*	else if upcase(rsd_county_name) in ('JEFFERSON DAVIS CO.',	'COVINGTON CO.',	'JONES CO.',	'WAYNE CO.',	*/
/*										'MARION CO.',	'LAMAR CO.','FORREST CO.','PERRY CO.','GREENE CO.') 		THEN PHA = 8;*/
/*	else if upcase(rsd_county_name) in ('PEARL RIVER CO.',	'STONE CO.',	'GEORGE CO.',	'HANCOCK CO.',	*/
/*										'HARRISON CO.',	'JACKSON CO.') 												THEN PHA = 9;*/
/*	else if upcase(rsd_county_name) = 'UNKNOWN'                                                         			THEN PHA = 99;*/

/*LOUISIANA*/

/*  	if      upcase(rsd_county_name) in ('JEFFERSON CO.', 'ORLEANS CO.', 'ST. BERNARD CO.', 'PLAQUEMINES CO.')                       then PHA = 1;*/
/*  	else if upcase(rsd_county_name) in ('WEST FELICIANA CO.', 'EAST FELICIANA CO.', 'POINTE COUPEE CO.', 'WEST BATON ROUGE CO.', */
/*										'EAST BATON ROUGE CO.',	'IBERVILLE CO.', 'ASCENSION CO.')    								then PHA = 2;*/
/*  	else if upcase(rsd_county_name) in ('ST. MARY CO.', 'ASSUMPTION CO.', 'ST. JAMES CO.', 'ST. JOHN CO.', 'ST. CHARLES CO.', */
/*										'TERREBONNE CO.', 'LAFOURCHE CO.') 								                            then PHA = 3;*/
/*  	else if upcase(rsd_county_name) in ('EVANGELINE CO.', 'ST. LANDRY CO.', 'ACADIA CO.', 'LAFAYETTE CO.', 'ST. MARTIN CO.', */
/*										'VERMILION CO.', 'IBERIA CO.')  							                                then PHA = 4;*/
/*  	else if upcase(rsd_county_name) in ('BEAUREGARD CO.', 'ALLEN CO.', 'CALCASIEU CO.', 'JEFFERSON DAVIS CO.', 'CAMERON CO.')		then PHA = 5;*/
/*  	else if upcase(rsd_county_name) in ('WINN CO.', 'GRANT CO.', 'LASALLE CO.', 'CATAHOULA CO.', 'CONCORDIA CO.', 'VERNON CO.',*/
/*										'RAPIDES CO.', 'AVOYELLES CO.') 															then PHA = 6;*/
/*  	else if upcase(rsd_county_name) in ('CADDO CO.', 'BOSSIER CO.', 'WEBSTER CO.', 'CLAIBORNE CO.', 'BIENVILLE CO.', */
/*										'DESOTO CO.', 'RED RIVER CO.', 'SABINE CO.', 'NATCHITOCHES CO.')           					then PHA = 7;*/
/*  	else if upcase(rsd_county_name) in ('LINCOLN CO.', 'UNION CO.', 'MOREHOUSE CO.', 'WEST CARROLL CO.', 'EAST CARROLL CO.',*/
/*										'JACKSON CO.', 'OUACHITA CO.', 'RICHLAND CO.', 'MADISON CO.', 'CALDWELL CO.',*/
/*										'FRANKLIN CO.', 'TENSAS CO.')        														then PHA = 8;*/
/*  	else if upcase(rsd_county_name) in ('ST. HELENA CO.', 'LIVINGSTON CO.', 'TANGIPAHOA CO.', 'WASHINGTON CO.', 'ST. TAMMANY CO.')	then PHA = 9;*/
/*  	else if upcase(rsd_county_name) = 'UNKNOWN'                                                                                     then PHA = 99;*/




/*======= Determine if the OI date is within 3 months of HIV dx =======*/
			
 	day4  = compress(substr(OI_stage3_dt,7,2));
		if day4 ^= '..' then dxday4 = input(day4,2.0);
		if day4  = '..' then dxday4 = 1;
	mon4  = substr(OI_stage3_dt,5,2);
		if mon4 ^= '..' then dxmo4 = input(mon4,2.0);
		if mon4  = '..' then dxmo4 = 1;
	yr4  = compress(substr(OI_stage3_dt,1,4));
		if yr4 ^= '....' then dxyr4 = input(yr4,4.0);
		if dxday4 ^= . and dxmo4 ^= . and dxyr4 ^= . then OIDATE = mdy(dxmo4,dxday4,dxyr4);
		format OIDATE date9.;
	OIyr = dxyr4;
	OImo = dxmo4;
  		
  	if OIyr ^= . and OImo ^= . and dxmo ^= . then diff_m = (OIyr*12+OImo)-(dxyr*12+dxmo);
  	if 0 <= diff_m <= 3 then stage3 = 1;
  	else                     stage3 = 0;
run;

/*======================================================================*/
*						Clean facility_code tables						 ;
/*======================================================================*/
*	Variables used from doc.FACILITY_CODE data set:						 ;
*		facility_uid													 ;
*																		 ;
*	Variables created in FACILITY_CODE data set:						 ;						
*		name1, name2, facility_name										 ;
/*======================================================================*/

data FACILITY_CODE 
	( keep = 	facility_uid		facility_name);

	length facility_name $200;
  	set doc.FACILITY_CODE;
	if name1 = ' ' and name2 = ' ' then facility_name = ' ';
  		else do;
			if name1 ^= ' ' then do;
	  				if name2 = name1 or name2 = ' ' then facility_name = strip(name1);
	  				else facility_name = strip(name1)||' '||strip(name2);
				end;
			else facility_name = strip(name2);
  		end;
run;

proc sql;
  	create table personxx 	as select a.*, b.facility_name 
							as df_facility_name from personx 
							as a left join facility_code 
							as b on a.df_facility_uid = b.facility_uid
  								order by ehars_uid;
quit; 

data person_out; 
  	set personxx; 
run;

/*Remove duplicate IDs*/
proc sort data = person_out out = person_out_final nodupkey; by ehars_uid; run;


/*======================================================================*/
*								Read in Labs							 ;
/*======================================================================*/

PROC SORT DATA = DOC.LAB; BY DOCUMENT_UID; RUN;
PROC SORT DATA = DOC_PV;  BY DOCUMENT_UID; RUN;

DATA LAB_A;
	MERGE DOC.LAB (IN = A) DOC_PV (IN = B);
	BY DOCUMENT_UID; 
	IF A = 1 AND B = 1;
RUN;

proc sql;
  	create table lab 		as select a.hiv_aids_dx_dt, 
         						a.dxyr, 
         						a.dxmo, 
         						b.ehars_uid, 
         						b.document_uid, 
         						b.lab_test_cd, 
         						b.result, 
         						b.result_interpretation, 
		 						b.SAMPLE_DT, 
         						b.result_units, 
         						b.facility_uid from personxx
							as a inner join LAB_A (where = (
                                      		SAMPLE_DT not in (' ','........') and 
                                      		lab_test_cd in ('EC-016','EC-017', 'EC-014','L-010','L-011'))) 
							as b on a.ehars_uid = b.ehars_uid;
quit;

data CD41 VL1;
  	set lab;
  	if      lab_test_cd in &CD4code. and RESULT not in (' ','.') then output CD41;
  	else if lab_test_cd in &VLcode.  and (RESULT not in (' ','.') or RESULT_INTERPRETATION in ('<','>','=')) then output VL1;
run;

/*======================================================================*/
*	Obtain the care facility: the facility that ordered the first 		 ;
*		CD4/VL test after dx but before the censoring date				 ;
/*======================================================================*/

proc sort data = CD41 
	(where = (hiv_aids_dx_dt <= sample_dt <= "&censor_dt." and facility_uid ^= ' ')) 
	out = CD4x nodupkey; 
  	by ehars_uid sample_dt facility_uid; 
run;

proc sort data = VL1 
	(where = (hiv_aids_dx_dt <= sample_dt <= "&censor_dt." and facility_uid^= ' '))  
	out = VLx nodupkey; 
  	by ehars_uid sample_dt facility_uid; 
run; 

/*======================================================================*/
*	  Check if any CD4 test has been ordered by different facilities	 ;
/*======================================================================*/

data cd4x1
	(keep = 	ehars_uid			sample_dt); 
	set cd4x;
  	by ehars_uid sample_dt;
  	if first.sample_dt then num = 0;
	num + 1;
  	if last.sample_dt and num > 1;
run;

data CD4_linelist;
  	merge CD4x1(in = a) CD4x;
  	by ehars_uid sample_dt;
  	if a;
run;

proc sql;
  	create table CD4_linelistx as select a.*, 
								b.facility_name from CD4_linelist 
							as a left join facility_code 
							as b on a.facility_uid = b.facility_uid
  								order by a.ehars_uid, a.sample_dt;
quit;

/*======================================================================*/
*	  Check if any VL test has been ordered by different facilities		 ;
/*======================================================================*/

data VLx1
	(keep = 	ehars_uid 			sample_dt); 
  	set VLx;
  	by ehars_uid sample_dt;
  	if first.sample_dt then num = 0;
	num+1;
  	if last.sample_dt and num > 1;
run;

data VL_linelist;
  	merge VLx1(in = a) VLx;
  	by ehars_uid sample_dt;
  	if a;
run;

proc sql;
  	create table VL_linelistx as select a.*, 
								b.facility_name from VL_linelist 
							as a left join facility_code 
							as b on a.facility_uid = b.facility_uid
 	 							order by a.ehars_uid, a.sample_dt;
quit;

/*======================================================================*/
* 	Cases with tests (all tests) ordered by multiple facilities on the 	 ;
*		same sample collection date										 ;
/*======================================================================*/

data CD4VL_linelistx1 
	(keep = ehars_uid			sample_dt				facility_name);
  	merge VL_linelistx CD4_linelistx;
  	by ehars_uid sample_dt;
  	if first.sample_dt then num = 0;
	num+1;
  	if last.sample_dt and num > 1;
run;

data CD4VL_linelistx12;
 	set CD4VL_linelistx1;
 	by ehars_uid;
 	if first.ehars_uid;
run;

/*======================================================================*/

data lab_care;
  	set cd4x vlx;
  	by ehars_uid sample_dt facility_uid;
  	keep ehars_uid sample_dt facility_uid lab_test_cd document_uid;
run;

proc sql;
  	create table lab_care_fac as select a.*, 
								b.facility_name from lab_care 
							as a left join facility_code 
							as b on a.facility_uid = b.facility_uid;
quit;


/*======================================================================*/
*	Obtain cd4/vl tests that were collected on the same date but 		 ;
*		ordered by different facilities									 ;
/*======================================================================*/

proc sort data = lab_care_fac 
	out = lab_care_facx nodupkey; 
  	by ehars_uid sample_dt facility_name; 
run;

data lab_care_multi_fac 
	(keep = ehars_uid			sample_dt 				num);
  	set lab_care_facx;
  	by ehars_uid sample_dt ;
  	if first.sample_dt then num = 0;
	num+1;
  	if last.sample_dt and num > 1;
run;

proc sort data = lab_care_fac; 
  	by ehars_uid sample_dt; 
run;

data lab_care_linelist;
  	merge lab_care_multi_fac(in = a) lab_care_fac;
  	by ehars_uid sample_dt;
  	if a;
run;


/*======================================================================*/	
*	   Obtain the care facility of the first CD4/VL on or after dx		 ;
/*======================================================================*/	

data lab_care_facility_temp;
  	set lab_care_facx;
  	by ehars_uid;
  	if first.ehars_uid;
run;

data lab_care_facility 
	(keep = ehars_uid			sample_dt 			facility_uid 
			facility_name 
     rename = (facility_uid = care_facility_uid 
               facility_name = care_facility_name));
  	merge lab_care_facility_temp (in = a) lab_care_multi_fac (in = b);
  	by ehars_uid sample_dt;
  	if a;
  	if a and b then facility_name = 'Multiple Facilities';
run;


/*======================================================================*/	

proc sort data = CD41 
	out = CD4 
	nodupkey;  
  	by ehars_uid sample_dt result result_units ; 
run;

proc sort data = VL1 
	out = VL 
	nodupkey;  
  	by ehars_uid sample_dt result result_interpretation result_units; 
run; 

proc sort data = VL;
	by sample_dt;
run;

data VL2;																			/* ### */
	set VL;
	by sample_dt;
	resultn = input(result,comma12.);
	if first.sample_dt and 0 <= resultn < 200 then first_sup_flag = 1;
		else first_sup_flag = 0;
	drop resultn;
run;

/*======================================================================*/	

data cd4_count cd4_percent;
  	set cd4;
  	by ehars_uid;
  	CD4yr = input(substr(sample_dt,1,4),8.);
  	CD4mo = input(substr(sample_dt,5,2),8.);

/*============= Only keep CD4 tests within 3 months of dx ==============*/

	if CD4yr ^= . and CD4mo ^= . and dxmo ^= . then diff_m = (CD4yr*12+CD4mo)-(dxyr*12+dxmo);
  	if 0 <= diff_m <= 3;
  	resultn = input(result,comma12.);

/*================= Only keep tests indicating stage 3 =================*/

  	if lab_test_cd = 'EC-016' then do;
			if 0 <= resultn < 200 then 	stage3 = 1;
			else               		    stage3 = 0;
			output cd4_count;
  		end;
  	if lab_test_cd = 'EC-017' then do;
			if 0 <= resultn <= 13 then 	stage3 = 1;
			else                   		stage3 = 0;
			output cd4_percent;
  		end;
run;

data stage3_all;
  	set personx (in = a 
    		keep = ehars_uid 	diff_m 	 stage3 
         	where = (stage3 = 1)) 
	  	cd4_count (in = b 
            keep = ehars_uid    diff_m   stage3)
	  	cd4_percent (in = c 
            keep = ehars_uid    diff_m   stage3);
  	if      a then stage_flag = 1;
  	else if b then stage_flag = 2;
  	else if c then stage_flag = 3;
run;

proc sort data = stage3_all; 
  	by ehars_uid diff_m stage_flag 
	descending stage3; 
run;

data stage3;
  	set stage3_all;
  	by ehars_uid;
  	if first.ehars_uid;
run;

/*======================================================================*/	
*  						  VL suppression								 ;
/*======================================================================*/	

proc sort data = personxx; by ehars_uid; run;
proc sort data = VL2	; by ehars_uid; run;

data dates;																	
	merge VL2(in = a) personx(in = b);											
  	by ehars_uid;																
run;


data VL_sup_2;
  	set dates;																	
  	by ehars_uid;
  	where sample_dt <= "&censor_dt.";

	day1  = compress(substr(sample_dt,7,2));
			 if day1 ^= '..'  then sample_dy = input(day1,2.0);
		else if day1  = '..'  then sample_dy = 1;						
	mon1  = substr(sample_dt,5,2);
			 if mon1 ^= '..'  then sample_mo = input(mon1,2.0);
		else if mon1  = '..'  then sample_mo = 1;						
	yr1  = compress(substr(sample_dt,1,4));
			 if yr1 ^= '....' then sample_yr = input(yr1,4.0);
		else if yr1 = '....'  then sample_yr = 1900;
	
	VSDATE = mdy(sample_mo, sample_dy, sample_yr);							
			format VSDATE date9.;													

	diff_d = intck('day', HIVDATE, VSDATE);									

/*=============== Clean VL result & result_interpretation ==============*/

	result1 = input(result,comma12.);
  	if result1 < 0 then result1 = .;
  	if result in ('<20','<48') then result1 = 1;
  	if result_interpretation = '<' and result1 = . then result1 = 0;
  	if result1 > 1E7 then result1 = 1E7;
  	result1 = round(result1);	
	if 0 <= result1 < &cutoff_VL. and diff_d <= 365 then index_m12 = 1; 
run;

proc sort data = VL_sup_2
	(keep = ehars_uid 	index_m12 
     where = (index_m12 = 1)) 
	out = VL_sup12 
	nodupkey; 
  	by ehars_uid; 
run;

proc sort data = VL_sup_2
	(keep = ehars_uid	diff_d	result1 first_sup_flag
     where = (0 <= result1 <= &cutoff_VL.)) 
	out = sup_2; 
  	by ehars_uid diff_d; 
run;

data sup_2; 
  	set sup_2; 
  	by ehars_uid; 
  	if first.ehars_uid; 
run;


/*======================================================================*/	
*	  						All merge together							 ;
/*======================================================================*/	

data Person_analysis_2;
  	merge 	person_out_final (drop = stage3)
      		vl_sup12(in = a keep = ehars_uid) 
			sup_2 (in = b keep = ehars_uid diff_d first_sup_flag)
			STAGE3 (in = c keep = ehars_uid stage3)
			lab_care_facility (in = d keep = ehars_uid care_facility_name);

	by ehars_uid;
  	if a then VL_sup12 = 1; 
  	else      VL_sup12 = 0;
  	if b then vl_sup = 1; 
  	else      vl_sup = 0;
  	if not c then stage3 = 0;
	if dthyr = . or DTHDATE > &censor_date. then do; 										
    		Censor = 1;
			Survtime = ((int(&censor_dt./1E4)*12 + int(mod(&censor_dt.,1E4)/1E2)) - (dxyr*12 + dxmo)) * 30.4375; /* ### 365.25/12 = 30.4375 */
  		end;
  	else do;
    		Censor = 0;
    		Survtime = intck('day', HIVDATE, DTHDATE); 															
  		end;
  	if dthyr ^= . and ((dthyr*12 + dthmo) - (dxyr*12 + dxmo)) <= 12 then dead_m12 = 1;
  	else                                                                 dead_m12 = 0;

  	if diff_d = . and Survtime <= 0 then do;		/* this obersvation will be dropped */
    		Time2sup = 0;							/* ================================	*/
			Censor4sup = 1;							/* ================================	*/
 		end;
  	else if diff_d = . and Survtime > 0 then do;	/* admin censor */
    		Time2sup = Survtime;
			Censor4sup = 1;
  		end;
  	else if diff_d = 0 then do;						/* this obersvation will be dropped */
    		Time2sup = 0;							/* ================================	*/
			Censor4sup = 0;							/* ================================	*/
  		end;
  	else if diff_d <= Survtime then do;
    		Time2sup = diff_d;
			Censor4sup = 0;
  		end;
  	else if diff_d > Survtime then do;
    		Time2sup = Survtime;
			Censor4sup = 1;
  		end;

	if Time2sup = . then suppression_month_cat_2 = .;
		else if Time2sup > 0 AND Time2sup <= 90 then suppression_month_cat_2 = 1;  						/* VS within three months */
		else if Time2sup > 90 AND Time2sup <= 365 then suppression_month_cat_2 = 2; 					/* VS between three and twelve months */
		else suppression_month_cat_2 = 3;

	if dxyr in(2012,2013,2014,2015) then year_cat = "2012 - 2015";
		else if dxyr in(2016,2017,2018,2019) then year_cat = "2016 - 2019";

	if diff_d = . AND Survtime <= 0 					 then remove_explanation = "No VS Date & Survtime Estimate DNE			";
	if diff_d > . AND diff_d <  0 						 then remove_explanation = "HIV DX Date is after first lab date <= 200 ";
	if diff_d = 0  										 then remove_explanation = "Elite controller or Re-Diagnosis  			";
	if diff_d > survtime and time2sup=0 and censor4sup=1 then remove_explanation= "Time to VS > Survtime Estimate (0)";

  	label dxyr 		= "Year at Diagnosis";
	label year_cat  = "Year at Diagnosis";
run;

proc sort data = Person_analysis_2;	by ehars_uid; run;

data Person_analysis NOT_Person_analysis
	(rename = (stage3 = stage));
  	set Person_analysis_2;
	by ehars_uid;
/*	Remove the following cases from analysis data set																		*/
/*		-	Elite controller or Re-Diagnosis (this is inflated, not be specfic design, but is an artifact of the simulation)*/
/*		-	HIV DX Date is after first lab date <= 200																		*/
/*		-	No VS Date & Survtime Estimate DNE 																				*/
/*	if (Censor4sup = 0 AND time2sup = 0) OR (Censor4sup = 1 AND time2sup = 0) then output NOT_Person_Analysis;*/
	if remove_explanation NE "" then output NOT_Person_Analysis;
		else output Person_analysis;
run;


		TITLE;
		proc sort data = NOT_Person_analysis; BY dxyr; run;
		proc freq data = NOT_Person_analysis order = data;
			TABLE remove_explanation*dxyr;
			TITLE "Table - Exclusion &site.";
			FORMAT dxyr dxyr.;
		run;


		TITLE;
		proc sort data = Person_analysis; BY dxyr; run;
		proc freq data = Person_analysis order = data;
			TABLE dxyr;
			TITLE "Analysis Data Set - Year of Diagnosis &site.";
			FORMAT dxyr dxyr.;
		run;

/*Permenant data creation*/
data dataout.Person_analysis;
	set Person_analysis;
run;


/*======================================================================*/	

dm "log; print file=log      replace;";
 
