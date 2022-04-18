



/*==========================================================================*/
/*																			*/
/* This is the same location (for simulation purposes) that the simulated	*/
/* address data set is saved in												*/
/*																			*/
%LET DATA = YOUR-FILEPATH-GOES-HERE;
libname doc 	"&DATA.";

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


data doc.address_sim;
	set &LONG_1 &LONG_2 &LONG_3;
run;





