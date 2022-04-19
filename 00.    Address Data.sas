
/*=========================================================================*/
*	PROGRAM NAME:	Address Data					 					 	;	
*																		    ;
*	DESCRIPTION:	To create simulated addresses that have the capacity to	;
*					be geocoded.											;
*																		    ;
*					The address used in this data set are derived from the 	;
*					following freely available data:						;												
*					This work is licensed under a Creative Commons 			;
*					Attribution 4.0 License. The Data is provided "as is" 	;
*					without warranty or any representation of accuracy, 	;
*					timeliness or completeness. This readme describes the 	;
*					GeoNames Postal Code dataset. The main GeoNames 		;
*					gazetteer data extract is here:							; 	
*																			;																			
* 					http://download.geonames.org/export/dump/				;
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



/*==========================================================================*/
/*																			*/
/* This is the same location (for simulation purposes) that the simulated	*/
/* address data set is saved in												*/
/*																			*/
%LET DATA = YOUR-FILEPATH-GOES-HERE;
libname DAT 	"&DATA.";

/* States included in analysis */
%let SHORT_1 = AL;
%let LONG_1  = ALABAMA;
%let SHORT_2 = MS;
%let LONG_2  = MISSISSIPPI;
%let SHORT_3 = LA;
%let LONG_3  = LOUISIANA;

/*==========================================================================*/
/*																			*/
/* The address used in this data set are derived from the following freely	*/
/* available data:															*/
/*																			*/
/* This work is licensed under a Creative Commons Attribution 4.0 License.	*/
/* The Data is provided "as is" without warranty or any representation of 	*/
/* accuracy, timeliness or completeness. This readme describes the GeoNames */
/* Postal Code dataset. The main GeoNames gazetteer data extract is here: 	*/
/*																			*/
/* 		http://download.geonames.org/export/dump/							*/
/*																			*/


proc import file	 = "&DATA\US.txt" /* US.txt must be downloaded in order for this data set to be created */
    		out		 = US
    		dbms	 = tab
			replace;
			getnames = no;
run;


%macro address(STATE = , ABBREVIATION = );

		data &STATE;
			/* length for each variable is assigned based on eHARS data dictionary */
			length 	state_cd 			$2.	
					county_name			$64.		
					facility_uid 		$16.    	
					zip_cd 				$10.
					name1 				$300.
					name2 				$300.
					facility_type_cd	$10.;
		
			format state_cd county_name zip_cd name1 name2 facility_uid facility_type_cd ship_flag Latitude Longitude Accuracy SIM;
			set US(rename = (VAR1  = Country
							 VAR2  = zip
							 VAR3  = name2
							 VAR5  = state_cd
							 VAR6  = County
							 VAR10 = Latitude
							 VAR11 = Longitude
							 VAR12 = Accuracy));
		
			where state_cd = "&ABBREVIATION.";
			SIM =_N_; 

			/* GEO data to match eHARS name and variable format construct */
			zip_cd 		 	 = compress(put(zip,8.));
			facility_uid 	 = compress(state_cd)||"00-"||compress(SIM)||compress(zip)||"-1";
			county_name  	 = compress(County)||" Co.";
			name1 		 	 = "";
			facility_type_cd = "";
			ship_flag 	 	 = "1";
		
			/*Setting_cd is arbitrary in this application, but values are simulated for completeness of data*/
				 if OBNUM < 100 		   		 then setting_cd = "   ";
			else if OBNUM >= 100 AND OBNUM < 300 then setting_cd = "001";
			else 									  setting_cd = "010";
		
			keep state_cd county_name zip_cd name1 name2 facility_uid facility_type_cd ship_flag Latitude Longitude Accuracy SIM;
		run;

%mend address;


%address(STATE = &LONG_1, 	ABBREVIATION = &SHORT_1);
%address(STATE = &LONG_2, 	ABBREVIATION = &SHORT_2);
%address(STATE = &LONG_3, 	ABBREVIATION = &SHORT_3);


data DAT.address_sim;
	set &LONG_1 &LONG_2 &LONG_3;
run;





