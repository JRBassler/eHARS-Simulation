

/*libname dataout 		"C:\Users\st1dcrea\Documents\HIV Surveillance\Data Requests\RTZ\Call 22JUL20\Data";		/* ### */
/*libname dataout 		"C:\Users\John\Desktop\Road to Zero\Work\Simulation\Call &Sysdate.\Data";*/
/*libname dataout 		"C:\Users\John\Desktop\Road to Zero\Work\Simulation\Call 09OCT20\Data";*/
libname dataout 		"C:\Users\johnr\OneDrive\Desktop\Work\Road to Zero\Work\Simulation\Call 11APR22\Data";

%let 		site = SIMULATION;

options 	dlcreatedir; 
libname out 			"C:\Users\johnr\OneDrive\Desktop\Work\Road to Zero\Work\Simulation\Call &Sysdate.";
libname datasend 		"C:\Users\johnr\OneDrive\Desktop\Work\Road to Zero\Work\Simulation\Call &Sysdate.\Datasend &Sysdate.";
libname output 			"C:\Users\johnr\OneDrive\Desktop\Work\Road to Zero\Work\Simulation\Call &Sysdate.\Output &Sysdate.";
%let location_output =   C:\Users\johnr\OneDrive\Desktop\Work\Road to Zero\Work\Simulation\Call &Sysdate.\Output &Sysdate.;
filename 	log      	"&location_output\Analysis Log &Sysdate..log";

option nofmterr;


/*=======================================================================================================================*/
/*=======================================================================================================================*/
/*=======================================================================================================================*/


data person_analysis;
	set dataout.person_analysis;
	format sex sex. 		grace grace. 	mode mode. 		mode2 modee. 		age_grp2 age_grpp. 
		   stage3 stagex. 	PHD PHD. 		dxyr dxyr. 		dfname dfname. 		suppression_month_cat_2 vs_cat.
		   method method.	aids_insure insure.				hiv_insure insure.  current_gender $c_gender.
		   edu_cat edu.	    PHD PHD.		PHD2 PHD.		meth meth.			gender $c_gender.;

	/* Transmission Category */
  		 if trans_categ in('01','03') then method = 1; 			/*MSM*/
  	else if trans_categ in('02') 	  then method = 2; 			/*IDU*/
  	else if trans_categ in('05')  	  then method = 3; 			/*Het*/
  	else if trans_categ in('09','10') then method = 4; 			/*Unk*/
  	else                            	   method = 5; 			/*Oth*/

  		 if trans_categ in('01','03') then meth = 1; 			/*MSM*/
  	else if trans_categ in('02') 	  then meth = 2; 			/*IDU*/
  	else if trans_categ in('05')  	  then meth = 3; 			/*Het*/
  	else 								   meth = 4; 			/*Unk&Oth*/

		 if aids_insurance in('01','02','03','04','05','06','14','11','12','13') then aids_insure = 1; /*Pub*/
	else if aids_insurance in('07','08','09') 									then aids_insure = 2;  /*Pri*/
	else if aids_insurance in('10') 											then aids_insure = 3;  /*Self*/
	else if aids_insurance in('15') 											then aids_insure = 4;  /*None*/
	else if aids_insurance in('88') 											then aids_insure = 5;  /*Oth*/
	else 							 												 aids_insure = 6;  /*Unk*/

		 if hiv_insurance in('01','02','03','04','05','06','14','11','12','13') then hiv_insure = 1;   /*Pub*/
	else if hiv_insurance in('07','08','09') 									then hiv_insure = 2;   /*Pri*/
	else if hiv_insurance in('10') 												then hiv_insure = 3;   /*Self*/
	else if hiv_insurance in('15') 												then hiv_insure = 4;   /*None*/
	else if hiv_insurance in('88') 												then hiv_insure = 5;   /*Oth*/
	else if hiv_insurance in('99') 												then hiv_insure = 6;   /*Unk*/

		 if education in('1','2') then edu_cat = 1; 
	else if education in('3') 	  then edu_cat = 2; 
	else if education in('4') 	  then edu_cat = 3;
	else if education in('5','6') then edu_cat = 4; 
	else 							   edu_cat = 5; 

		 if current_gender in("MF","FM") then gender = "T";
	else 							   		  gender = birth_sex;


/*	Time2sup_scaled = 35 * log20(Time2sup);*/

/*----------------------------------------------------------------------------------*/
  	if      upcase(rsd_county_name) in ('LAUDERDALE CO.',
										'LIMESTONE CO.',
										'MADISON CO.',
										'JACKSON CO.',
										'COLBERT CO.',
										'LAWRENCE CO.',
										'FRANKLIN CO.',
										'MORGAN CO.',
										'MARSHALL CO.',
										'MARION CO.',
										'WINSTON CO.',
										'CULLMAN CO.') 			THEN PHD2 = 1;
/*----------------------------------------------------------------------------------*/
	else if upcase(rsd_county_name) in ('LAMAR CO.',
										'FAYETTE CO.',
										'WALKER CO.',
										'PICKENS CO.',
										'TUSCALOOSA CO.',
										'SUMTER CO.',
										'GREENE CO.',
										'HALE CO.',
										'BIBB CO.',
										'PERRY CO.',
										'CHILTON CO.') 			THEN PHD2 = 2;
/*----------------------------------------------------------------------------------*/
	else if upcase(rsd_county_name) in ('JEFFERSON CO.') 		THEN PHD2 = 3;
/*----------------------------------------------------------------------------------*/
	else if upcase(rsd_county_name) in ('BLOUNT CO.',
										'DEKALB CO.',
										'ETOWAH CO.',
										'CHEROKEE CO.',
										'ST. CLAIR CO.',
										'CALHOUN CO.',
										'CLEBURNE CO.',
										'SHELBY CO.',
										'TALLADEGA CO.',
										'CLAY CO.',
										'RANDOLPH CO.') 		THEN PHD2 = 4;
/*----------------------------------------------------------------------------------*/
	else if upcase(rsd_county_name) in ('COOSA CO.',
										'TALLAPOOSA CO.',
										'CHAMBERS CO.',
										'AUTAUGA CO.',
										'ELMORE CO.',
										'LEE CO.',
										'LOWNDES CO.',
										'MONTGOMERY CO.',
										'MACON CO.',
										'BULLOCK CO.',
										'RUSSELL CO.') 			THEN PHD2 = 5;
/*----------------------------------------------------------------------------------*/
	else if upcase(rsd_county_name) in ('CHOCTAW CO.',
										'MARENGO CO.',
										'DALLAS CO.',
										'WILCOX CO.',
										'WASHINGTON CO.',
										'CLARKE CO.',
										'MONROE CO.',
										'CONECUH CO.',
										'ESCAMBIA CO.',
										'BALDWIN CO.') 			THEN PHD2 = 6;
/*----------------------------------------------------------------------------------*/
	else if upcase(rsd_county_name) in ('BUTLER CO.',
										'CRENSHAW CO.',
										'PIKE CO.',
										'BARBOUR CO.',
										'COVINGTON CO.',
										'COFFEE CO.',
										'DALE CO.',
										'HENRY CO.',
										'GENEVA CO.',
										'HOUSTON CO.',
										'BALDWIN CO.') 			THEN PHD2 = 7;
/*----------------------------------------------------------------------------------*/
	else if upcase(rsd_county_name) in ('MOBILE CO.') 			THEN PHD2 = 8;
/*----------------------------------------------------------------------------------*/
  	else if upcase(rsd_county_name) = 'UNKNOWN'                 THEN PHD2 = 99;
/*----------------------------------------------------------------------------------*/

	age_cont = input(hiv_aids_age_yrs, 8.);
	overall = "&site.";
	overall2 = 1;

	label overall					=	"Overall";
	label overall2					=	"Overall";
	label method 					= 	"Method of Transmission";
	label sex 						= 	"Gender at Birth (Sex)";
	label grace 					= 	"Race/Ethnicity";
	label age_grp2 					= 	"Age Group at HIV Diagnosis";
	label stage3 					= 	"Stage";
	label PHD 						= 	"Public Health District";
	label PHD2 						= 	"Public Health District";
	label dxyr 						= 	"Year of Diagnosis";
	label dfname 					= 	"Diagnosing Facility";
	label suppression_month_cat_2 	= 	"Time to VS Group";
	label aids_insure				=	"Primary Insurance (AIDS)";
	label hiv_insure				=	"Primary Insurance (HIV)";
	label current_gender			=	"Current Gender";
	label age_cont					=	"Age at HIV Diagnosis";
	label edu_cat					=	"Highest Level of Education";
	label meth 						= 	"Method of Transmission";
	label gender 					= 	"Gender";
run;

data person_analysis_2;
	set person_analysis(rename = (suppression_month_cat_2 = suppression_month_cat_old));
	if Censor4sup = 0 then do;
				 if Time2sup = . 					  then suppression_month_cat_2 = .;
			else if Time2sup > 0  AND Time2sup <= 90  then suppression_month_cat_2 = 1;  	/* VS within three months */
			else if Time2sup > 90 AND Time2sup <= 365 then suppression_month_cat_2 = 2; 	/* VS between three and twelve months */
			else 										   suppression_month_cat_2 = 3;
			output;
		end;
run;


/*=======================================================================================================================*/
/*=======================================================================================================================*/
/*=======================================================================================================================*/

ods rtf file  = "&location_output\Survival - Time to Viral Suppression overall.rtf"  
		startpage = no;

		TITLE;
		%lifetest_over(DATA 	=	person_analysis, 
				  	   OUTSURV	=	lifetest_overallb,
				  	   MEDIAN 	=	median_overallb, 
				  	   CONFTYPE	= 	LOGLOG,
				  	   NOPRINT 	= 	,
				  	   TIME		=	Time2sup,
				  	   CENSOR	=	Censor4sup(1),
				  	   TITLE 	=	"Survival - Viral Suppression overall (b)");

ods rtf close;


/*=======================================================================================================================*/
/*=======================================================================================================================*/
/*=======================================================================================================================*/


ods rtf file  = "&location_output\Survival - Time to Viral Suppression by Year of Diagnosis.rtf"  
		startpage = no;

/* SURVIVAL Year of Diagnosis*/
		TITLE;
		%lifetest(DATA 		=	person_analysis, 
				  VAR1		=	dxyr,
				  FORMAT1	=	dxyr.,	
				  OUTSURV	=	lifetest_dxyr,
				  MEDIAN 	=	median_dxyr, 
				  CONFTYPE	= 	LOGLOG,
				  NOPRINT 	= 	,
				  TIME		=	Time2sup,
				  CENSOR	=	Censor4sup(1),
				  TITLE 	=	"Survival - Viral Suppression by Year of Diagnosis");

ods rtf close;


/*=======================================================================================================================*/
/*=======================================================================================================================*/
/*=======================================================================================================================*/


proc sort data = person_analysis; by dxyr Gender; run;

ods rtf file  = "&location_output\Survival - Time to Viral Suppression by Gender.rtf"  
		startpage = no;

/* SURVIVAL GENDER*/

		TITLE;
		%lifetest(DATA 		=	person_analysis, 
				  VAR1		=	Gender,
				  FORMAT1	=	$c_gender.,	
				  OUTSURV	=	lifetest_Gender,
 		  		  MEDIAN 	=	median_Gender,
				  CONFTYPE	= 	LOGLOG,
				  NOPRINT 	= 	,
				  TIME		=	Time2sup,
				  CENSOR	=	Censor4sup(1),
				  TITLE 	=	"Survival - Time to Viral Suppression by Gender");

ods rtf close;


/*======================================================================================================================*/


ods rtf file  = "&location_output\Survival - Time to Viral Suppression by Gender and Year of Diagnosis.rtf"  
		startpage = no;

/* Survival GENDER x DXYR */

		TITLE;
		%lifetest_panel(DATA 		=	person_analysis, 
				  	    VAR1		=	Gender,
				  	    FORMAT1		=	$c_gender.,	
					    VAR2 		= 	dxyr, 
					    FORMAT2 	= 	dxyr., 
				  	    OUTSURV		=	lifetest_gender_by_year,
				  		MEDIAN 		=	median_gender_by_year,
				  	    CONFTYPE	= 	LOGLOG,
				  	    NOPRINT 	= 	,
				  	    TIME		=	Time2sup,
				  	    CENSOR		=	Censor4sup(1),
				  	    TITLE 		=	"Survival - Time to Viral Suppression by Gender and Year of Diagnosis");

ods rtf close;

/*=======================================================================================================================*/

ods rtf file  = "&location_output\Time to Viral Suppression Category by Gender.rtf"  
		startpage = no;

/* Suppression Category Table GENDER */

		TITLE;
		%vs_cat(TITLE 	= 'Time to Viral Suppression Category by Gender', 
				DATA 	= person_analysis_2, 
				VAR1 	= Gender, 
				FORMAT1 = $c_gender., 
				VAR2	= dxyr, 
				FORMAT2 = dxyr., 
				OUT 	= vs_cat_Gender);

ods rtf close;


/*=======================================================================================================================*/
/*=======================================================================================================================*/
/*=======================================================================================================================*/


dm "log; print file = log	replace;";

