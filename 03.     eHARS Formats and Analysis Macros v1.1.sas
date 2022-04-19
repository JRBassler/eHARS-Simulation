
/*=========================================================================*/
*	PROGRAM NAME:	eHARS Formats and Analysis Macros #.#		 			;
*																		    ;
*	DESCRIPTION:	This SAS program is designed to establish formats	 	;
*					across all procedures and run macros to be used in	 	;
*					analysis												;
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
*	DATE CREATED:	1/26/2022											 	;
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

proc format;
  value dummy 
        1 = "Overall";

  value sex 
        1 = "Male  "
	    2 = "Female";

value $c_gender	
		'AD' = 'Additional Gender			'
		'F'  = 'Female'
		'FM' = 'Transgender - Female to Male'
		'M'  = 'Male'
		'MF' = 'Transgender - Male to Female'
		'U'  = 'Unknown'
		'T'  = 'Transgender';

  value grace 
        1 = "Hispanic/Latino"
		2 = "Black"
		3 = "White"
		4 = "Other races";

  value method
  		1 = "MSM or MSM & IDU    "
		2 = "IDU Only"
		3 = "Heterosexual Contact"
		4 = "Unknown"
		5 = "Other";

  value mode 
        1 = "MSM                        "
		2 = "IDU"
		3 = "MSM&IDU"
		4 = "Heterosexual contact"
		5 = "Other transmission category";

  value modee 
        1 = "MSM                   "
		2 = "IDU or IDU&MSM        "
		3 = "Heterosexual contact  "
		4 = "Other                 ";

  value meth 
  		1 = "MSM or MSM & IDU    "
		2 = "IDU Only"
		3 = "Heterosexual Contact"
		4 = "Unknown or Other";

  value insure
  		1 = "Public	 "
		2 = "Private "
		3 = "Self Pay"
		4 = "None"
		5 = "Other"
		6 = "Unknown";
	
  value edu
  		1 = "Some high school or less            "
		2 = "High school graduate or equivalent  "
		3 = "Some college"
		4 = "College degree or post-graduate work"
		5 = "Unknown, or level unknown";

  value age_grpp 
        1 = "13-24"
		2 = "25-44"
		3 = "44+";

  value stagex 
        1 = "Stage 3    "
		0 = "Not stage 3";

  value PHA 
        1 = "PHA 01     "
		2 = "PHA 02"
		3 = "PHA 03"
		4 = "PHA 04"
		5 = "PHA 05"
		6 = "PHA 06"
		7 = "PHA 07"
		8 = "PHA 08"
		9 = "PHA 09"
		10= "PHA 10"
		11= "PHA 11"
		99= "PHA unknown";

  value PHD
        1 = "Northern District	  "
		2 = "West Central District"
		3 = "Jefferson County"
		4 = "Northeastern District"
		5 = "East Central District"
		6 = "Southwestern District"
		7 = "Southeastern District"
		8 = "Mobile County";

  value dxyr 
        2012 = "2012"
		2013 = "2013"
        2014 = "2014"
		2015 = "2015"
		2016 = "2016"
		2017 = "2017"
		2018 = "2018"
		2019 = "2019"		;

  value stagex  
        1 = "Stage 3    "
	    0 = "Not Stage 3"
	    9 = "Subtotal   ";

	value vs_cat
		1  = "90 Days or Less		   "
		2  = "> 90 Days and < 12 Months"
		3  = "> 12 Months or Not VS    ";

run;

/*=======================================================================================================================*/


%macro lifetest(TITLE = , DATA = , VAR1 = , FORMAT1 = , OUTSURV = , CONFTYPE = , NOPRINT = , TIME = , CENSOR = , MEDIAN = );

	proc sort data = &DATA; BY &VAR1; run;

    ODS OUTPUT FAILUREPLOT = &OUTSURV;
	TITLE &TITLE;
	proc lifetest DATA   	= &DATA 
				  PLOTS  	= (SURVIVAL(FAILURE TEST) LOGSURV)
		 		  CONFTYPE	= &CONFTYPE
				  &NOPRINT;
		WHERE &TIME > .;
		TIME &TIME * &CENSOR;
		STRATA &VAR1;
		ODS OUTPUT QUARTILES = &MEDIAN;
		FORMAT &VAR1 &FORMAT1;
	run; 
	
  	data &MEDIAN;
    	set &MEDIAN (rename = (Estimate = Median
                          	  LowerLimit = LCL
                          	  UpperLimit = UCL));
		if Percent = 50;
		keep &VAR1 Median LCL UCL;
  	run; 

%mend lifetest;


/*=======================================================================================================================*/


%macro vs_cat(TITLE = , DATA = , VAR1 = , FORMAT1 = , VAR2	= , FORMAT2 = , OUT = );

	proc sort data = &DATA; BY &VAR1 suppression_month_cat_2; run;

	TITLE &TITLE;	
	proc freq data = &DATA order = data;
		TABLE &VAR1*suppression_month_cat_2 / Missprint nocol nocum nopercent;
		FORMAT suppression_month_cat_2 vs_cat. &VAR1 &FORMAT1;
	run;
	
	proc sort data = person_analysis; BY &VAR2 &VAR1 suppression_month_cat_2; run;

	TITLE &TITLE;		
	proc freq data = person_analysis NOPRINT; 
		table &VAR2*&VAR1*suppression_month_cat_2 / crosslist out = &out outpct; 
		FORMAT suppression_month_cat_2 vs_cat. &VAR1 &FORMAT1 &VAR2 &FORMAT2;
	run;
	
	data &out;
		set &out;
		PCT_ROW 	 = round(PCT_ROW,0.1);
		table_pct 	 = compress('(' ||PCT_ROW|| ')');
		table_output = COUNT || ' ' || table_pct;
	run;

%mend vs_cat;


/*=======================================================================================================================*/


%macro lifetest_over(TITLE = , DATA = , OUTSURV = , CONFTYPE = , NOPRINT = , TIME = , CENSOR = , MEDIAN = );

    ODS OUTPUT FAILUREPLOT = &OUTSURV;
	TITLE &TITLE;
	proc lifetest DATA   	= &DATA 
				  PLOTS  	= (SURVIVAL(FAILURE TEST) LOGSURV)
		 		  CONFTYPE	= &CONFTYPE
				  &NOPRINT;
		WHERE &TIME > .;
		TIME &TIME * &CENSOR;
		ODS OUTPUT QUARTILES = &MEDIAN;
	run; 
	
  	data &MEDIAN;
    	set &MEDIAN (rename = (Estimate = Median
                          	  LowerLimit = LCL
                          	  UpperLimit = UCL));
		if Percent = 50;
		keep Median LCL UCL;
  	run; 

%mend lifetest_over;


/*=======================================================================================================================*/


%macro lifetest_panel(TITLE = , DATA = , VAR1 = , FORMAT1 = , VAR2 = , FORMAT2 = , OUTSURV = , CONFTYPE = , NOPRINT = , TIME = , CENSOR = , MEDIAN = );

	proc sort data = &DATA; BY &VAR2 &VAR1; run;

	ODS OUTPUT FAILUREPLOT = &OUTSURV;
	TITLE &TITLE;
	proc lifetest DATA   	= &DATA 
				  PLOTS  	= (SURVIVAL(FAILURE TEST STRATA = PANEL) LOGSURV)
		 		  CONFTYPE	= &CONFTYPE
				  &NOPRINT;
		WHERE &TIME > .;
		TIME &TIME * &CENSOR;
		STRATA &VAR2 / GROUP = &VAR1;
		ODS OUTPUT QUARTILES = &MEDIAN;
		FORMAT &VAR1 &FORMAT1 &VAR2 &FORMAT2;
	run; 
	
  	data &MEDIAN;
    	set &MEDIAN (rename = (Estimate = Median
                          	  LowerLimit = LCL
                          	  UpperLimit = UCL));
		if Percent = 50;
		keep &VAR1 &VAR2 Median LCL UCL;
  	run; 

%mend lifetest_panel;


/*=======================================================================================================================*/
